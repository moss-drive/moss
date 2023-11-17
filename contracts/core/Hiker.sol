// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../dependencies/console.sol";
import "../interfaces/IHiker.sol";

abstract contract Hiker is IHiker, Initializable {
	uint64 public constant PRECISIONDECIMALS = 1e18;
	uint64 public constant k = 2e15;
	uint64 public constant minFloor = 1e12;
	uint64 public defaultCreatorFeePCT;
	uint64 public devFeePCT;

	address public dev;

	mapping(uint256 => uint256) internal f;

	mapping(uint256 => uint256) public fs;

	mapping(uint256 => uint256) public fsIncr;

	mapping(uint256 => uint256) internal step;

	mapping(uint256 => uint256) internal fsStep;

	struct StoneInfoCache {
		uint256 k;
		uint256 t;
		uint256 fs;
		uint256 f;
		uint256 step;
	}

	function __HikerInit(address _dev) internal {
		dev = _dev;
		defaultCreatorFeePCT = 5e16;
		devFeePCT = 5e16;
	}

	function create(uint256 id, uint256 _f, string memory _tokenURI, uint256 timeoutAt) external payable {
		require(block.timestamp < timeoutAt, "Hiker: timeout");
		_create(id, _f, 100, 200, 10);
		_setTokenURI(id, _tokenURI);
	}

	function _create(uint256 id, uint256 _f, uint256 _fs, uint256 _s, uint256 _fsStep) internal {
		require(!exists(id), "Hiker: token exists");
		require(creatorOf(id) == address(0), "Hiker: token is created");
		require(_f >= minFloor, "Hiker: floor must be greater than or equal to minimum floor");
		require(_fs > 0, "Hiker: floor supply must be greater than or equal to minimum floor supply");
		require(_s > 0, "Hiker: adjust step must greater than zero");
		require(_fsStep > 0, "Hiker: fsStep must greater than zero");
		require(_fsStep < _s, "Hiker: fsStep must be less than step");
		uint256 fee = (_f * devFeePCT) / PRECISIONDECIMALS;
		require(msg.value >= _f + fee, "Hiker: insufficient funds to create");
		if (msg.value > _f + fee) {
			(bool _success, ) = msg.sender.call{ value: msg.value - _f - fee }("");
			require(_success, "Hiker: transfer funds back failed");
		}
		(bool success, ) = dev.call{ value: fee }("");
		require(success, "Hiker: failed to receive fee ");
		_setCreator(id, msg.sender);
		_mint(msg.sender, id, 1);
		f[id] = _f;
		fs[id] = _fs;
		step[id] = _s;
		fsStep[id] = _fsStep;

		emit Created(msg.sender, id, _f, _fs, _s, _fsStep, _f, fee);
	}

	function buy(uint256 id, address to, uint256 amount, uint256 maxSent) external payable {
		require(creatorOf(id) != address(0), "Hiker: token is not created");
		require(amount > 0, "Hiker: amount must be greater than 0");
		StoneInfoCache memory stone = StoneInfoCache({ k: k, t: totalSupply(id), f: floor(id), fs: floorSupply(id), step: stepment(id) });
		uint256 _id = id;
		address _to = to;
		uint256 _amount = amount;
		(uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) = estimateBuy(stone.k, stone.t, stone.fs, stone.f, _amount);
		require(msg.value >= total, "Hiker: insufficient funds to buy");
		require(total <= maxSent, "Hiker: funds must be less than or equal to maximum sent");
		if (msg.value > total) {
			(bool _success, ) = msg.sender.call{ value: msg.value - total }("");
			require(_success, "Hiker: transfer funds back failed");
		}
		(bool success, ) = dev.call{ value: devFee }("");
		require(success, "Hiker: failed to transfer dev fee ");
		(success, ) = creatorOf(_id).call{ value: creatorFee }("");
		require(success, "Hiker: failed to transfer creator fee ");
		uint256 _fsIncr = adjustment(stone.t, fs[_id], fsStep[_id], stone.step, _amount);
		uint256 _worth = worth(stone.k, stone.t, stone.fs, stone.f);
		if (_fsIncr > fsIncr[_id]) {
			f[_id] = estimateAdjust(stone.t, fs[_id], _fsIncr, stone.f, _worth + value, _amount);
			fsIncr[_id] = _fsIncr;
		}
		_mint(_to, _id, _amount);
		emit Bought(msg.sender, _id, _to, _amount, total, creatorFee, devFee);
	}

	function sell(uint256 id, address to, uint256 amount, uint256 minReceived) external {
		require(exists(id), "Hiker: nonexsitent token");
		require(amount > 0, "Hiker: amount must be greater than 0");
		uint256 _t = totalSupply(id);
		require(_t >= amount, "Hike: amount must be less than or equal to total supply");
		StoneInfoCache memory stone = StoneInfoCache({ k: k, t: _t, f: floor(id), fs: floorSupply(id), step: stepment(id) });
		(uint256 total, , uint256 devFee) = estimateSell(stone.k, stone.t, stone.fs, stone.f, amount);
		require(total >= minReceived, "Hiker: received value must be greater than or equal to minimum received");
		_burn(msg.sender, id, amount);
		(bool _success, ) = to.call{ value: total }("");
		require(_success, "Hiker: transfer value failed");
		(_success, ) = dev.call{ value: devFee }("");
		require(_success, "Hiker: failed to transfer dev fee");
		emit Sold(msg.sender, id, to, amount, total, devFee);
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
		return worth(k, _t, _fs, _f);
	}

	function estimateBuy(uint256 id, uint256 amount) public view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		require(exists(id), "Hiker: nonexistent id");
		uint256 _k = k;
		uint256 _t = totalSupply(id);
		uint256 _fs = floorSupply(id);
		uint256 _f = floor(id);
		require(_f > 0, "Hiker: zero floor price");
		return estimateBuy(_k, _t, _fs, _f, amount);
	}

	function estimateSell(uint256 id, uint256 amount) public view returns (uint256 total, uint256 value, uint256 devFee) {
		require(exists(id), "Hiker: nonexistent id");
		uint256 _k = k;
		uint256 _t = totalSupply(id);
		uint256 _fs = floorSupply(id);
		uint256 _f = floor(id);
		return estimateSell(_k, _t, _fs, _f, amount);
	}

	function estimateBuy(uint256 _k, uint256 _t, uint256 _fs, uint256 _f, uint256 amount) public view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		if (_t + amount <= _fs) {
			value = _f * amount;
		} else {
			if (_t > _fs) {
				value = (amount * (2 * _f + _k * (2 * _t + amount - 2 * _fs))) / 2;
			} else {
				uint256 floorAmount = _fs - _t;
				uint256 hikerAmount = _t + amount - _fs;
				value = _f * floorAmount + (hikerAmount * (2 * _f + k * hikerAmount)) / 2;
			}
		}

		creatorFee = (value * defaultCreatorFeePCT) / PRECISIONDECIMALS;
		devFee = (value * devFeePCT) / PRECISIONDECIMALS;
		total = value + creatorFee + devFee;
	}

	function estimateSell(uint256 _k, uint256 _t, uint256 _fs, uint256 _f, uint256 amount) public view returns (uint256 total, uint256 value, uint256 devFee) {
		require(_t >= amount, "Hiker: sell amount must be less than total supply");
		if (_t <= _fs) {
			value = _f * amount;
		} else {
			if (_t - amount > _fs) {
				value = (amount * (2 * _f + _k * (2 * _t - amount - 2 * _fs))) / 2;
			} else {
				uint256 hikerAmount = _t - _fs;
				uint256 floorAmount = amount - hikerAmount;
				value = _f * floorAmount + (hikerAmount * (2 * _f + k * hikerAmount)) / 2;
			}
		}
		devFee = (value * devFeePCT) / PRECISIONDECIMALS;
		total = value - devFee;
	}

	function adjustment(uint256 _t, uint256 _fs, uint256 _fsStep, uint256 _step, uint256 amount) public pure returns (uint256 _fsIncr) {
		if (_t + amount > _fs) {
			uint256 mul = (_t + amount - _fs) / _step;
			_fsIncr = mul * _fsStep;
		}
	}

	function estimateAdjust(uint256 _t, uint256 _fs, uint256 _fsIncr, uint256 _f, uint256 _w, uint256 amount) public pure returns (uint256 _floor) {
		uint256 _floorSupply = _fs + _fsIncr;
		require(_t + amount > _floorSupply, "invalid parameter");
		uint256 temp = _t + amount - _floorSupply;
		_floor = (2 * _w - k * temp * temp) / (2 * (_t + amount));
		require(_floor > _f, "invalid floor");
	}

	function creatorOf(uint256 id) public view virtual returns (address);

	receive() external payable {}

	function _setCreator(uint256 id, address creator) internal virtual;

	function _setTokenURI(uint256 id, string memory tokenURI) internal virtual;

	function _mint(address to, uint256 id, uint256 amount) internal virtual;

	function _burn(address to, uint256 id, uint256 amount) internal virtual;

	function totalSupply(uint256 id) public view virtual returns (uint256);

	function exists(uint256 id) public view virtual returns (bool);

	function floorSupply(uint256 id) public view returns (uint256) {
		return fs[id] + fsIncr[id];
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
}
