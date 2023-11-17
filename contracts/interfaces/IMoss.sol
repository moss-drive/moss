// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./IHiker.sol";

interface IMoss is IHiker {
	event TokenURIUpdated(uint256 id, string tokenURI);

	event CreatorUpdated(uint256 id, address creator);

	function uri(uint256 id) external view returns (string memory);

	function creatorOf(uint256 id) external view returns (address);

	function totalSupply(uint256 id) external view returns (uint256);

	function balanceOf(address to, uint256 id) external view returns (uint256);

	function exists(uint256 id) external view returns (bool);
}
