// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";

import "../dependencies/DelegatedOps.sol";
import "../interfaces/IMoss.sol";

abstract contract Moss is IMoss, ERC1155SupplyUpgradeable, DelegatedOps {
	mapping(uint256 => address) internal creators;
	mapping(uint256 => string) internal stoneNames;

	modifier onlyCreatorOrApprovals(uint256 id) {
		address _account = creatorOf(id);
		require(msg.sender == _account || isApprovedDelegate[_account][msg.sender], "Moss: Delegate not approved");
		_;
	}

	function _mint(address to, uint256 id, uint256 amount) internal {
		require(amount > 0, "Moss: zero amount");
		_mint(to, id, amount, new bytes(0));
		emit URI("", id);
	}

	function _burn(address to, uint256 id, uint256 amount) internal override(ERC1155Upgradeable) {
		ERC1155Upgradeable._burn(to, id, amount);
		if (totalSupply(id) > 0) {
			emit URI("", id);
		}
	}

	function _setCreator(uint256 id, address creator) internal {
		require(!exists(id), "Moss: token exists");
		creators[id] = creator;
		emit CreatorUpdated(id, creator);
	}

	function updateStoneName(uint256 id, string memory stoneName) external onlyCreatorOrApprovals(id) {
		_updateStoneName(id, stoneName);
	}

	function _updateStoneName(uint256 id, string memory stoneName) internal {
		stoneNames[id] = stoneName;
		emit StoneNameUpdated(id, stoneName);
	}

	function creatorOf(uint256 id) public view returns (address) {
		return creators[id];
	}

	function stoneNameOf(uint256 id) public view returns (string memory) {
		return stoneNames[id];
	}

	function totalSupply(uint256 id) public view virtual override(ERC1155SupplyUpgradeable, IMoss) returns (uint256) {
		return super.totalSupply(id);
	}

	function exists(uint256 id) public view virtual override(ERC1155SupplyUpgradeable, IMoss) returns (bool) {
		return super.totalSupply(id) > 0;
	}
}
