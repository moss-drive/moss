// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/IERC1155MetadataURIUpgradeable.sol";

interface IMoss is IERC1155MetadataURIUpgradeable {
	event StoneNameUpdated(uint256 id, string name);

	event CreatorUpdated(uint256 id, address creator);

	function creatorOf(uint256 id) external view returns (address);

	function stoneNameOf(uint256 id) external view returns (string memory);

	function totalSupply(uint256 id) external view returns (uint256);

	function exists(uint256 id) external view returns (bool);
}
