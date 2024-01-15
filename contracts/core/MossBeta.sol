// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./Moss.sol";
import "../libraries/console.sol";
import "../interfaces/IMossBeta.sol";

contract MossBeta is IMossBeta, Moss, ReentrancyGuardUpgradeable {
	uint64 public constant PRECISIONDECIMALS = 1e18;
	uint64 public constant minFloor = 1e12;
	uint64 public defaultCreatorFeePCT;
	uint64 public devFeePCT;

	uint256 internal currentId;

	address public dev;

	mapping(uint256 => uint256) public k;

	mapping(uint256 => uint256) public f;

	mapping(uint256 => uint256) public p0;
	// p1 = p0 + (p2-p0) / 2
	mapping(uint256 => uint256) public p1;
	// p2 = p0 + (t-p0) / 2
	mapping(uint256 => uint256) public p2;

	mapping(uint256 => uint256) public h;

	modifier onlyCreated(uint256 id) {
		require(creatorOf(id) != address(0), "token is not created");
		_;
	}

	function initialize(address _dev) external initializer {
		dev = _dev;
		defaultCreatorFeePCT = 25e15;
		devFeePCT = 25e15;
	}

	function create(uint256 timeoutAt) external payable nonReentrant {
		require(block.timestamp < timeoutAt, "tx timeout");
		_create(1e15, 1e14, 10);
	}

	function _create(uint256 _k, uint256 _f, uint256 _p0) internal {
		uint256 id = currentId;
		require(_k > 0, "invalid k");
		require(_f >= minFloor, "floor must be greater than or equal to minimum floor");
		require(_p0 > 0, "floor supply must be greater than zero");
		uint256 fee = (_f * devFeePCT) / PRECISIONDECIMALS;
		require(msg.value >= _f + fee, "insufficient funds to create");
		if (msg.value > _f + fee) {
			_transferFunds(msg.sender, msg.value - _f - fee, "transfer funds back failed");
		}
		_transferFunds(dev, fee, "failed to receive fee");
		_setCreator(id, msg.sender);
		_mint(msg.sender, id, 1);
		k[id] = _k;
		f[id] = _f;
		p0[id] = _p0;
		currentId++;
		emit Created(msg.sender, id, _f, _p0, fee);
	}

	function mint(uint256 id, address to, uint256 amount) external payable nonReentrant {
		require(amount > 0, "amount must be greater than 0");
		Cache memory c = Cache({ id: id, k: k[id], f: f[id], t: totalSupply(id), h: h[id], p0: p0[id], p1: p1[id], p2: p2[id], amount: amount, to: to });
		(uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) = estimateMint(EstimationParams({ k: c.k, f: c.f, t: c.t, p0: c.p0, p1: c.p1, p2: c.p2, h: c.h, amount: c.amount }));
		require(msg.value >= total, "insufficient funds to mint");
		if (msg.value > total) {
			_transferFunds(msg.sender, msg.value - total, "transfer funds back failed");
		}
		_transferFunds(dev, devFee, "failed to transfer dev fee");
		_transferFunds(creatorOf(c.id), creatorFee, "failed to transfer creator fee");
		uint256 _w = worth(c.k, c.f, c.t, c.p0, c.p1, c.p2, c.h);
		(bool success, uint256 nf, uint256 nh, uint256 np1, uint256 np2) = estimateAdjust(AjustmentParams({ k: c.k, f: c.f, t: c.t, p0: c.p0, p1: c.p1, p2: c.p2, h: c.h, w: _w + value, amount: c.amount }));
		if (success) {
			f[c.id] = nf;
			h[c.id] = nh;
			p1[c.id] = np1;
			p2[c.id] = np2;
		}
		_mint(c.to, c.id, c.amount);
		emit Minted(msg.sender, c.id, c.to, c.amount, total, creatorFee, devFee);
	}

	function burn(uint256 id, address to, uint256 amount, uint256 minReceived) external nonReentrant {
		require(exists(id), "nonexsitent token");
		require(amount > 0, "amount must be greater than 0");
		Cache memory c = Cache({ id: id, k: k[id], f: f[id], t: totalSupply(id), h: h[id], p0: p0[id], p1: p1[id], p2: p2[id], amount: amount, to: to });
		(uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) = estimateBurn(EstimationParams({ k: c.k, f: c.f, t: c.t, p0: c.p0, p1: c.p1, p2: c.p2, h: c.h, amount: c.amount }));
		require(total >= minReceived, "received value must be greater than or equal to minimum received");
		_burn(msg.sender, c.id, c.amount);
		_transferFunds(to, total, "transfer value failed");
		_transferFunds(dev, devFee, "failed to transfer dev fee");
		_transferFunds(creatorOf(c.id), creatorFee, "failed to transfer creator fee");

		emit Burnt(msg.sender, c.id, c.to, c.amount, value, creatorFee, devFee);
	}

	function _transferFunds(address to, uint256 value, string memory message) internal {
		(bool success, ) = to.call{ value: value }("");
		require(success, message);
	}

	function worth(uint256 _k, uint256 _f, uint256 _t, uint256 _p0, uint256 _p1, uint256 _p2, uint256 _h) public pure returns (uint256) {
		if (_h > 0) {
			if (_t <= _p1) {
				return _f * _t;
			} else if (_t <= _p2) {
				uint256 k0 = (_h - _f) / (_p2 - _p1);
				uint256 temp = _t - _p1;
				return _f * _p1 + ((_f * 2 + k0 * temp) * temp) / 2;
			} else {
				uint256 temp1 = _t - _p2;
				return _f * _p1 + ((_f + _h) * (_p2 - _p1)) / 2 + ((_h * 2 + _k * temp1) * temp1) / 2;
			}
		} else {
			if (_t <= _p0) {
				return _f * _t;
			} else {
				uint256 temp = _t - _p0;
				return _f * _p0 + ((_f * 2 + _k * temp) * temp) / 2;
			}
		}
	}

	function worthOf(uint256 id) public view returns (uint256) {
		uint256 _t = totalSupply(id);
		return worth(k[id], f[id], _t, p0[id], p1[id], p2[id], h[id]);
	}

	function estimateMint(uint256 id, uint256 amount) public view onlyCreated(id) returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		return estimateMint(EstimationParams({ k: k[id], f: f[id], t: totalSupply(id), p0: p0[id], p1: p1[id], p2: p2[id], h: h[id], amount: amount }));
	}

	function estimateBurn(uint256 id, uint256 amount) public view onlyCreated(id) returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		return estimateBurn(EstimationParams({ k: k[id], f: f[id], t: totalSupply(id), p0: p0[id], p1: p1[id], p2: p2[id], h: h[id], amount: amount }));
	}

	function estimateMint(EstimationParams memory params) public view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		if (params.h > 0) {
			if (params.t <= params.p1) {
				if (params.t + params.amount <= params.p1) {
					value = params.f * params.amount;
				} else if (params.t + params.amount <= params.p2) {
					uint256 k0 = (params.h - params.f) / (params.p2 - params.p1);
					uint256 floorAmount = params.p1 - params.t;
					uint256 amount0 = params.t + params.amount - params.p1;
					value = params.f * floorAmount + (amount0 * (2 * params.f + k0 * amount0)) / 2;
				} else {
					uint256 floorAmount = params.p1 - params.t;
					uint256 amount0 = params.p2 - params.p1;
					uint256 amount1 = params.t + params.amount - params.p2;
					value = params.f * floorAmount + (((params.f + params.h) * amount0) / 2) + (((params.h * 2 + params.k * amount1) * amount1) / 2);
				}
			} else if (params.t <= params.p2) {
				if (params.t + params.amount <= params.p2) {
					uint256 k0 = (params.h - params.f) / (params.p2 - params.p1);
					value = ((2 * params.f + k0 * (2 * params.t + params.amount - 2 * params.p1)) * params.amount) / 2;
				} else {
					uint256 k0 = (params.h - params.f) / (params.p2 - params.p1);
					uint256 amount1 = (params.t + params.amount - params.p2);
					value = ((params.f + k0 * (params.t - params.p1) + params.h) * (params.p2 - params.t)) / 2 + ((2 * params.h + params.k * amount1) * amount1) / 2;
				}
			} else {
				value = ((2 * params.h + params.k * (2 * params.t + params.amount - 2 * params.p2)) * params.amount) / 2;
			}
		} else {
			if (params.t < params.p0) {
				if (params.t + params.amount <= params.p0) {
					value = params.f * params.amount;
				} else {
					uint256 floorAmount = params.p0 - params.t;
					uint256 amount0 = params.t + params.amount - params.p0;
					value = params.f * floorAmount + (amount0 * (2 * params.f + params.k * amount0)) / 2;
				}
			} else {
				value = (params.amount * (2 * params.f + params.k * (2 * params.t + params.amount - 2 * params.p0))) / 2;
			}
		}

		creatorFee = (value * defaultCreatorFeePCT) / PRECISIONDECIMALS;
		devFee = (value * devFeePCT) / PRECISIONDECIMALS;
		total = value + creatorFee + devFee;
	}

	function estimateBurn(EstimationParams memory params) public view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		require(params.t >= params.amount, "MossDoubleTrapezoid: burning amount must be less than or equal to total supply");
		if (params.h > 0) {
			if (params.t <= params.p1) {
				value = params.f * params.amount;
			} else if (params.t <= params.p2) {
				if (params.t - params.amount >= params.p1) {
					uint256 k0 = (params.h - params.f) / (params.p2 - params.p1);
					value = ((2 * params.f + k0 * (2 * params.t - params.amount - 2 * params.p1)) * params.amount) / 2;
				} else {
					uint256 k0 = (params.h - params.f) / (params.p2 - params.p1);
					uint256 amount0 = params.t - params.p1;
					uint256 floorAmount = params.amount - amount0;
					value = ((2 * params.f + k0 * amount0) * amount0) / 2 + params.f * floorAmount;
				}
			} else {
				if (params.t - params.amount >= params.p2) {
					value = ((2 * params.h + params.k * (2 * params.t - 2 * params.p2 - params.amount)) * params.amount) / 2;
				} else if (params.t - params.amount >= params.p1) {
					uint256 temp = params.t - params.p2;
					uint256 k0 = (params.h - params.f) / (params.p2 - params.p1);
					uint256 amount0 = params.amount - temp;
					value = ((2 * params.h + params.k * temp) * temp) / 2 + ((2 * params.h - k0 * amount0) * amount0) / 2;
				} else {
					uint256 temp = params.t - params.p2;
					uint256 temp1 = params.p2 - params.p1;
					uint256 floorAmount = params.amount - temp - temp1;
					value = floorAmount * params.f + ((params.f + params.h) * temp1) / 2 + ((2 * params.h + params.k * temp) * temp) / 2;
				}
			}
		} else {
			if (params.t <= params.p0) {
				value = params.f * params.amount;
			} else {
				if (params.t - params.amount >= params.p0) {
					value = (params.amount * (2 * params.f + params.k * (2 * params.t - params.amount))) / 2;
				} else {
					uint256 amount0 = params.t - params.p0;
					uint256 amount1 = params.amount - amount0;
					value = ((2 * params.f + params.k * amount0) * amount0) / 2 + params.f * amount1;
				}
			}
		}
		creatorFee = (value * defaultCreatorFeePCT) / PRECISIONDECIMALS;
		devFee = (value * devFeePCT) / PRECISIONDECIMALS;
		total = value - creatorFee - devFee;
	}

	function estimateAdjust(AjustmentParams memory params) public pure returns (bool success, uint256 nf, uint256 nh, uint256 np1, uint256 np2) {
		uint256 nt = params.t + params.amount;
		if (params.h > 0) {
			if (nt > params.p2 && nt > params.p0) {
				np2 = params.p0 + (nt - params.p0) / 2;
				np1 = params.p0 + (np2 - params.p0) / 2;
				if (np2 > np1 && np2 > params.p2) {
					uint256 _c = params.h + params.k * (nt - params.p2);
					nh = _c - params.k * (nt - np2);
					nf = (2 * params.w - (nh * (nt - np1)) - (_c * (nt - np2))) / (np1 + np2);
					if (nf > params.f) {
						success = true;
					}
				}
			}
		} else {
			if (nt > params.p0) {
				np2 = params.p0 + (nt - params.p0) / 2;
				np1 = params.p0 + (np2 - params.p0) / 2;
				if (np2 > np1) {
					uint256 _c = params.f + params.k * (nt - params.p0);
					nh = params.f + params.k * (np2 - params.p0);
					nf = (2 * params.w - (nh * (nt - np1)) - (_c * (nt - np2))) / (np1 + np2);
					if (nf > params.f) {
						success = true;
					}
				}
			}
		}
	}

	function totalSupply(uint256 id) public view override(IMossBeta, Moss) returns (uint256) {
		return super.totalSupply(id);
	}

	function exists(uint256 id) public view override(IMossBeta, Moss) returns (bool) {
		return super.exists(id);
	}

	function transferDev(address newDev) external {
		require(msg.sender == dev, "MossDoubleTrapezoid: caller is not dev");
		dev = newDev;
	}

	receive() external payable {}
}
