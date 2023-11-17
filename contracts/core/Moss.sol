// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";

import "./Hiker.sol";
import "../dependencies/DelegatedOps.sol";
import "../interfaces/IMoss.sol";

contract Moss is IMoss, ERC1155SupplyUpgradeable, Hiker, DelegatedOps {
	mapping(uint256 => string) public tokenURIs;
	mapping(uint256 => address) internal creators;

	function initialize(address dev) external initializer {
		__HikerInit(dev);
	}

	function uri(uint256 id) public view override(ERC1155Upgradeable, IMoss) returns (string memory) {
		return tokenURIs[id];
	}

	function _mint(address to, uint256 id, uint256 amount) internal override {
		require(amount > 0, "Moss: zero amount");
		_mint(to, id, amount, new bytes(0));
	}

	function _burn(address to, uint256 id, uint256 amount) internal override(ERC1155Upgradeable, Hiker) {
		ERC1155Upgradeable._burn(to, id, amount);
	}

	function _setCreator(uint256 id, address creator) internal override {
		require(!exists(id), "Moss: token exists");
		creators[id] = creator;
		emit CreatorUpdated(id, creator);
	}

	function _setTokenURI(uint256 id, string memory tokenURI) internal override {
		tokenURIs[id] = tokenURI;
		emit TokenURIUpdated(id, tokenURI);
	}

	function balanceOf(address to, uint256 id) public view override(ERC1155Upgradeable, IMoss) returns (uint256) {
		return super.balanceOf(to, id);
	}

	function creatorOf(uint256 id) public view override(Hiker, IMoss) returns (address) {
		return creators[id];
	}

	function setTokenURI(uint256 id, string memory tokenURI) external callerOrDelegated(creatorOf(id)) {
		_setTokenURI(id, tokenURI);
	}

	function totalSupply(uint256 id) public view override(ERC1155SupplyUpgradeable, Hiker, IMoss) returns (uint256) {
		return ERC1155SupplyUpgradeable.totalSupply(id);
	}

	function exists(uint256 id) public view override(ERC1155SupplyUpgradeable, Hiker, IMoss) returns (bool) {
		return ERC1155SupplyUpgradeable.exists(id);
	}
}
