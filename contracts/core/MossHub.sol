// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./Moss.sol";
import "../interfaces/IMossHub.sol";
import "../libraries/NFTDescriptor.sol";
import "../libraries/console.sol";

contract MossHub is IMossHub, Moss, ReentrancyGuardUpgradeable {
	uint64 public constant PRECISIONDECIMALS = 1e18;
	uint64 public constant minFloor = 1e12;
	uint64 public defaultCreatorFeePCT;
	uint64 public devFeePCT;

	address public dev;
	uint256 internal currentId;

	mapping(uint256 => uint64) public k;

	mapping(uint256 => uint256) internal f;

	mapping(uint256 => uint256) public ifs;

	mapping(uint256 => uint256) public fsIncr;

	mapping(uint256 => uint256) internal step;

	mapping(uint256 => uint256) internal fsStep;

	struct Cache {
		uint256 id;
		uint64 k;
		uint256 t;
		uint256 fs;
		uint256 f;
		uint256 step;
		uint256 amount;
		address to;
	}

	function initialize(address _dev) external initializer {
		dev = _dev;
		defaultCreatorFeePCT = 25e15;
		devFeePCT = 25e15;
	}

	function create(uint256 timeoutAt) external payable nonReentrant {
		require(block.timestamp < timeoutAt, "MossHub: tx timeout");
		_create(1e15, 1e14, 1, 10, 2);
	}

	function _create(uint64 _k, uint256 _f, uint256 _fs, uint256 _s, uint256 _fsStep) internal {
		uint256 id = currentId;
		require(_f >= minFloor, "MossHub: floor must be greater than or equal to minimum floor");
		require(_fs > 0, "MossHub: floor supply must be greater than zero");
		require(_s > 0, "MossHub: step must greater than zero");
		require(_fsStep > 0, "MossHub: fsStep must greater than zero");
		require(_fsStep <= _s / 5, "MossHub: fsStep must be less than step/10");
		uint256 fee = (_f * devFeePCT) / PRECISIONDECIMALS;
		require(msg.value >= _f + fee, "MossHub: insufficient funds to create");
		if (msg.value > _f + fee) {
			_transferFunds(msg.sender, msg.value - _f - fee, "MossHub: transfer funds back failed");
		}
		_transferFunds(dev, fee, "MossHub: failed to receive fee");
		_setCreator(id, msg.sender);
		_mint(msg.sender, id, 1);
		k[id] = _k;
		f[id] = _f;
		ifs[id] = _fs;
		step[id] = _s;
		fsStep[id] = _fsStep;
		currentId++;
		emit Created(msg.sender, id, _f, _fs, _s, _fsStep, _f, fee);
	}

	function mint(uint256 id, address to, uint256 amount) external payable nonReentrant {
		require(amount > 0, "MossHub: amount must be greater than 0");
		Cache memory cache = Cache({ k: k[id], t: totalSupply(id), f: floor(id), fs: floorSupply(id), step: stepment(id), amount: amount, id: id, to: to });
		(uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) = estimateMint(cache.k, cache.t, cache.fs, cache.f, cache.amount);
		require(msg.value >= total, "MossHub: insufficient funds to mint");
		if (msg.value > total) {
			_transferFunds(msg.sender, msg.value - total, "MossHub: transfer funds back failed");
		}
		_transferFunds(dev, devFee, "MossHub: failed to transfer dev fee");
		_transferFunds(creatorOf(cache.id), creatorFee, "MossHub: failed to transfer creator fee");
		uint256 _fsIncr = adjustment(cache.t, ifs[cache.id], fsStep[cache.id], cache.step, cache.amount);
		uint256 _worth = worth(cache.k, cache.t, cache.fs, cache.f);
		if (_fsIncr > fsIncr[cache.id]) {
			f[cache.id] = estimateAdjust(k[id], cache.t, ifs[cache.id], _fsIncr, cache.f, _worth + value, cache.amount);
			fsIncr[cache.id] = _fsIncr;
		}
		_mint(cache.to, cache.id, cache.amount);
		emit Minted(msg.sender, cache.id, cache.to, cache.amount, total, creatorFee, devFee);
	}

	function burn(uint256 id, address to, uint256 amount, uint256 minReceived) external nonReentrant {
		require(exists(id), "MossHub: nonexsitent token");
		require(amount > 0, "MossHub: amount must be greater than 0");
		uint256 _t = totalSupply(id);
		require(_t >= amount, "MossHub: too much amount to burn");
		Cache memory cache = Cache({ k: k[id], t: _t, f: floor(id), fs: floorSupply(id), step: stepment(id), id: id, amount: amount, to: to });
		(uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) = estimateBurn(cache.k, cache.t, cache.fs, cache.f, cache.amount);
		require(total >= minReceived, "MossHub: received value must be greater than or equal to minimum received");
		_burn(msg.sender, cache.id, cache.amount);
		_transferFunds(to, total, "MossHub: transfer value failed");
		_transferFunds(dev, devFee, "MossHub: failed to transfer dev fee");
		_transferFunds(creatorOf(cache.id), creatorFee, "MossHub: failed to transfer creator fee");

		emit Burnt(msg.sender, cache.id, cache.to, cache.amount, value, creatorFee, devFee);
	}

	function _transferFunds(address to, uint256 value, string memory message) internal {
		(bool success, ) = to.call{ value: value }("");
		require(success, message);
	}

	function worth(uint256 _k, uint256 _t, uint256 _fs, uint256 _f) public pure returns (uint256) {
		if (_t <= _fs) {
			return _f * _t;
		} else {
			uint256 temp = _t - _fs;
			return _f * _t + (_k * temp * temp) / 2;
		}
	}

	function worthOf(uint256 id) public view returns (uint256) {
		uint256 _t = totalSupply(id);
		uint256 _fs = floorSupply(id);
		uint256 _f = floor(id);
		return worth(k[id], _t, _fs, _f);
	}

	function estimateMint(uint256 id, uint256 amount) public view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		require(creatorOf(id) != address(0), "MossHub: token is not created");
		uint64 _k = k[id];
		uint256 _t = totalSupply(id);
		uint256 _fs = floorSupply(id);
		uint256 _f = floor(id);
		require(_f > 0, "MossHub: zero floor price");
		return estimateMint(_k, _t, _fs, _f, amount);
	}

	function estimateBurn(uint256 id, uint256 amount) public view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		require(creatorOf(id) != address(0), "MossHub: token is not created");
		uint64 _k = k[id];
		uint256 _t = totalSupply(id);
		uint256 _fs = floorSupply(id);
		uint256 _f = floor(id);
		return estimateBurn(_k, _t, _fs, _f, amount);
	}

	function estimateMint(uint64 _k, uint256 _t, uint256 _fs, uint256 _f, uint256 amount) public view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		if (_t + amount <= _fs) {
			value = _f * amount;
		} else {
			if (_t > _fs) {
				value = (amount * (2 * _f + _k * (2 * _t + amount - 2 * _fs))) / 2;
			} else {
				uint256 floorAmount = _fs - _t;
				uint256 amount0 = _t + amount - _fs;
				value = _f * floorAmount + (amount0 * (2 * _f + _k * amount0)) / 2;
			}
		}

		creatorFee = (value * defaultCreatorFeePCT) / PRECISIONDECIMALS;
		devFee = (value * devFeePCT) / PRECISIONDECIMALS;
		total = value + creatorFee + devFee;
	}

	function estimateBurn(uint64 _k, uint256 _t, uint256 _fs, uint256 _f, uint256 amount) public view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		require(_t >= amount, "MossHub: burning amount must be less than or equal to total supply");
		if (_t <= _fs) {
			value = _f * amount;
		} else {
			if (_t - amount > _fs) {
				value = (amount * (2 * _f + _k * (2 * _t - amount - 2 * _fs))) / 2;
			} else {
				uint256 amount0 = _t - _fs;
				uint256 floorAmount = amount - amount0;
				value = _f * floorAmount + (amount0 * (2 * _f + _k * amount0)) / 2;
			}
		}
		creatorFee = (value * defaultCreatorFeePCT) / PRECISIONDECIMALS;
		devFee = (value * devFeePCT) / PRECISIONDECIMALS;
		total = value - creatorFee - devFee;
	}

	function adjustment(uint256 _t, uint256 _fs, uint256 _fsStep, uint256 _step, uint256 amount) public pure returns (uint256 _fsIncr) {
		if (_t + amount > _fs) {
			uint256 mul = (_t + amount - _fs) / _step;
			_fsIncr = mul * _fsStep;
		}
	}

	function estimateAdjust(uint64 _k, uint256 _t, uint256 _fs, uint256 _fsIncr, uint256 _f, uint256 _w, uint256 amount) public pure returns (uint256 _floor) {
		uint256 _floorSupply = _fs + _fsIncr;
		require(_t + amount > _floorSupply, "MossHub: floor supply is gte total supply");
		uint256 temp = _t + amount - _floorSupply;
		_floor = (2 * _w - _k * temp * temp) / (2 * (_t + amount));
		require(_floor > _f, "MossHub: adjusted floor price is lte original floor price");
	}

	function floorSupply(uint256 id) public view returns (uint256) {
		return ifs[id] + fsIncr[id];
	}

	function floor(uint256 id) public view returns (uint256) {
		return f[id];
	}

	function fsStepOf(uint256 id) public view returns (uint256) {
		return fsStep[id];
	}

	function stepment(uint256 id) public view returns (uint256) {
		return step[id];
	}

	function totalSupply(uint256 id) public view override(IMoss, Moss) returns (uint256) {
		return super.totalSupply(id);
	}

	function exists(uint256 id) public view override(IMoss, Moss) returns (bool) {
		return super.exists(id);
	}

	function uri(uint256 id) public view override(ERC1155Upgradeable, IERC1155MetadataURIUpgradeable) returns (string memory) {
		NFTDescriptor.Meta memory meta;
		meta.id = id;
		meta.k = k[id];
		meta.creator = creatorOf(id);
		meta.floor = floor(id);
		meta.floorSupply = floorSupply(id);
		meta.totalSupply = totalSupply(id);
		meta.targetSupply = targetSupply(id);
		meta.totalWorth = worth(k[id], meta.totalSupply, meta.floorSupply, meta.floor);
		(, meta.mintingPrice, , ) = estimateMint(k[id], meta.totalSupply, meta.floorSupply, meta.floor, 1);
		(, meta.burningPrice, , ) = estimateBurn(k[id], meta.totalSupply, meta.floorSupply, meta.floor, 1);
		return NFTDescriptor.getTokenURI(meta);
	}

	function targetSupply(uint256 id) public view returns (uint256) {
		return ifs[id] + (fsIncr[id] / fsStep[id]) * step[id] + step[id];
	}

	function nextFloor(uint256 id) public view returns (uint256) {
		uint64 _k = k[id];
		uint256 _t = targetSupply(id);
		uint256 _fs = floorSupply(id);
		uint256 _f = floor(id);
		uint256 _w = worth(_k, _t, _fs, _f);
		uint256 _fsIncr = adjustment(_t, ifs[id], fsStepOf(id), stepment(id), 0);
		return estimateAdjust(_k, _t, ifs[id], _fsIncr, _f, _w, 0);
	}

	receive() external payable {}
}
