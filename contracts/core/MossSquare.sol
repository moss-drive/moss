// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./Moss.sol";
import "../interfaces/IMossSquare.sol";

// import "../../libraries/NFTDescriptor.sol";
import "../libraries/console.sol";

contract MossSquare is IMossSquare, Moss, ReentrancyGuardUpgradeable {
	uint64 public constant PRECISIONDECIMALS = 1e18;
	uint64 public constant minFloor = 1e12;
	uint64 public defaultCreatorFeePCT;
	uint64 public devFeePCT;

	address public dev;
	uint256 internal currentId;

	mapping(uint256 => uint256) public k;

	struct Cache {
		uint256 id;
		uint256 k;
		uint256 t;
		uint256 amount;
		address to;
	}

	function initialize(address _dev) external initializer {
		dev = _dev;
		defaultCreatorFeePCT = 25e15;
		devFeePCT = 25e15;
	}

	function create(uint256 timeoutAt) external payable nonReentrant {
		require(block.timestamp < timeoutAt, "MossSquare: tx timeout");
		_create(1e15);
	}

	function _create(uint256 _k) internal {
		uint256 id = currentId;
		(, uint256 value, , uint256 devFee) = estimateMint(_k, 0, 1);
		console.log("value", msg.value, value, devFee);
		require(_k >= minFloor, "MossSquare: k > 0");
		require(msg.value >= value + devFee, "MossSquare: insufficient funds to create");
		if (msg.value > value + devFee) {
			_transferFunds(msg.sender, msg.value - value - devFee, "MossSquare: transfer funds back failed");
		}
		_transferFunds(dev, devFee, "MossSquare: failed to receive dev fee");
		_setCreator(id, msg.sender);
		_mint(msg.sender, id, 1);
		k[id] = _k;
		currentId++;
		emit Created(msg.sender, id, _k, value, devFee);
	}

	function mint(uint256 id, address to, uint256 amount) external payable nonReentrant {
		require(amount > 0, "MossSquare: amount must be greater than 0");
		Cache memory cache = Cache({ id: id, k: k[id], t: totalSupply(id), amount: amount, to: to });
		(uint256 total, , uint256 creatorFee, uint256 devFee) = estimateMint(cache.k, cache.t, cache.amount);
		require(msg.value >= total, "MossSquare: insufficient funds to mint");
		if (msg.value > total) {
			_transferFunds(msg.sender, msg.value - total, "MossSquare: transfer funds back failed");
		}
		_transferFunds(dev, devFee, "MossSquare: failed to transfer dev fee");
		_transferFunds(creatorOf(cache.id), creatorFee, "MossSquare: failed to transfer creator fee");
		_mint(cache.to, cache.id, cache.amount);
		emit Minted(msg.sender, cache.id, cache.to, cache.amount, total, creatorFee, devFee);
	}

	function burn(uint256 id, address to, uint256 amount, uint256 minReceived) external nonReentrant {
		require(exists(id), "MossSquare: nonexsitent token");
		require(amount > 0, "MossSquare: amount must be greater than 0");
		uint256 _t = totalSupply(id);
		require(_t >= amount, "MossSquare: too much amount to burn");
		Cache memory cache = Cache({ id: id, k: k[id], t: totalSupply(id), amount: amount, to: to });
		(uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) = estimateBurn(cache.k, cache.t, cache.amount);
		require(total >= minReceived, "MossSquare: received value must be greater than or equal to minimum received");
		_burn(msg.sender, cache.id, cache.amount);
		_transferFunds(to, total, "MossSquare: transfer value failed");
		_transferFunds(dev, devFee, "MossSquare: failed to transfer dev fee");
		_transferFunds(creatorOf(cache.id), creatorFee, "MossSquare: failed to transfer creator fee");

		emit Burnt(msg.sender, cache.id, cache.to, cache.amount, value, creatorFee, devFee);
	}

	function _transferFunds(address to, uint256 value, string memory message) internal {
		(bool success, ) = to.call{ value: value }("");
		require(success, message);
	}

	function worth(uint256 _k, uint256 _t) public pure returns (uint256) {
		return (_k * _t * _t) / 2;
	}

	function worthOf(uint256 id) public view returns (uint256) {
		uint256 _k = k[id];
		uint256 _t = totalSupply(id);
		return worth(_k, _t);
	}

	function estimateMint(uint256 id, uint256 amount) public view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		require(creatorOf(id) != address(0), "MossSquare: token is not created");
		uint256 _k = k[id];
		uint256 _t = totalSupply(id);
		return estimateMint(_k, _t, amount);
	}

	function estimateBurn(uint256 id, uint256 amount) public view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		require(creatorOf(id) != address(0), "MossSquare: token is not created");
		uint256 _k = k[id];
		uint256 _t = totalSupply(id);
		return estimateBurn(_k, _t, amount);
	}

	function estimateMint(uint256 _k, uint256 _t, uint256 amount) public view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		uint256 tar = _t + amount;
		value = (_k * (tar * tar - _t * _t)) / 2;
		creatorFee = (value * defaultCreatorFeePCT) / PRECISIONDECIMALS;
		devFee = (value * devFeePCT) / PRECISIONDECIMALS;
		total = value + creatorFee + devFee;
	}

	function estimateBurn(uint256 _k, uint256 _t, uint256 amount) public view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) {
		require(_t >= amount, "MossSquare: burning amount must be less than or equal to total supply");
		uint256 tar = _t - amount;
		value = (_k * (_t * _t - tar * tar)) / 2;
		creatorFee = (value * defaultCreatorFeePCT) / PRECISIONDECIMALS;
		devFee = (value * devFeePCT) / PRECISIONDECIMALS;
		total = value - creatorFee - devFee;
	}

	function totalSupply(uint256 id) public view override(IMoss, Moss) returns (uint256) {
		return super.totalSupply(id);
	}

	function exists(uint256 id) public view override(IMoss, Moss) returns (bool) {
		return super.exists(id);
	}

	function uri(uint256 id) public view override(ERC1155Upgradeable, IERC1155MetadataURIUpgradeable) returns (string memory) {
		return "";
	}

	receive() external payable {}
}
