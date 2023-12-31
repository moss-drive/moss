// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./IMoss.sol";

interface IMossHub is IMoss {
	event Created(address from, uint256 id, uint256 _f, uint256 _fs, uint256 _s, uint256 _tar, uint256 value, uint256 devFee);

	event Minted(address from, uint256 id, address to, uint256 amount, uint256 value, uint256 creatorFee, uint256 devFee);

	event Burnt(address from, uint256 id, address to, uint256 amount, uint256 value, uint256 creatorFee, uint256 devFee);

	function minFloor() external view returns (uint64);

	function defaultCreatorFeePCT() external view returns (uint64);

	function devFeePCT() external view returns (uint64);

	function create(uint256 timeoutAt) external payable;

	function mint(uint256 id, address to, uint256 amount) external payable;

	function burn(uint256 id, address to, uint256 amount, uint256 minReceived) external;

	function worth(uint256 _k, uint256 _t, uint256 _fs, uint256 _f) external pure returns (uint256);

	function worthOf(uint256 id) external view returns (uint256);

	function nextFloor(uint256 id) external view returns (uint256);

	function estimateMint(uint256 id, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateBurn(uint256 id, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateMint(uint256 _k, uint256 _t, uint256 _fs, uint256 _f, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateBurn(uint256 _k, uint256 _t, uint256 _fs, uint256 _f, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateAdjust(uint256 _k, uint256 _t, uint256 _fs, uint256 _fsIncr, uint256 _f, uint256 _w, uint256 amount) external pure returns (uint256 _floor);

	function k(uint256 id) external view returns (uint256);

	function floorSupply(uint256 id) external view returns (uint256);

	function floor(uint256 id) external view returns (uint256);

	function fsStepOf(uint256 id) external view returns (uint256);

	function stepment(uint256 id) external view returns (uint256);
}
