// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./IMoss.sol";

interface IMossSquare is IMoss {
	event Created(address creator, uint256 id, uint256 k, uint256 value, uint256 fee);
	event Minted(address from, uint256 id, address to, uint256 amount, uint256 total, uint256 creatorFee, uint256 devFee);
	event Burnt(address from, uint256 id, address to, uint256 amount, uint256 value, uint256 creatorFee, uint256 devFee);

	function create(uint256 timeoutAt) external payable;

	function mint(uint256 id, address to, uint256 amount) external payable;

	function burn(uint256 id, address to, uint256 amount, uint256 minReceived) external;

	function worth(uint256 _k, uint256 _t) external pure returns (uint256);

	function worthOf(uint256 id) external view returns (uint256);

	function estimateMint(uint256 id, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateBurn(uint256 id, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateMint(uint256 _k, uint256 _t, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateBurn(uint256 _k, uint256 _t, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);
}
