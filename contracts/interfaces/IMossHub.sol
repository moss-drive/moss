// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./IMoss.sol";

interface IMossHub is IMoss {
	event Created(address from, uint256 id, uint256 _f, uint256 _fs, uint256 _s, uint256 _tar, uint256 value, uint256 devFee);

	event Bought(address from, uint256 id, address to, uint256 amount, uint256 value, uint256 creatorFee, uint256 devFee);

	event Sold(address from, uint256 id, address to, uint256 amount, uint256 value, uint256 creatorFee, uint256 devFee);

	function k() external view returns (uint64);

	function minFloor() external view returns (uint64);

	function defaultCreatorFeePCT() external view returns (uint64);

	function devFeePCT() external view returns (uint64);

	function create(uint256 id, uint256 _f, uint256 _fs, uint256 _s, uint256 _fsStep, uint256 timeoutAt, string memory stoneName) external payable;

	function buy(uint256 id, address to, uint256 amount, uint256 maxSent) external payable;

	function sell(uint256 id, address to, uint256 amount, uint256 minReceived) external;

	function worth(uint256 _k, uint256 _t, uint256 _fs, uint256 _f) external pure returns (uint256);

	function worthOf(uint256 id) external view returns (uint256);

	function estimateBuy(uint256 id, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateSell(uint256 id, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateBuy(uint256 _k, uint256 _t, uint256 _fs, uint256 _f, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateSell(uint256 _k, uint256 _t, uint256 _fs, uint256 _f, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateAdjust(uint256 _t, uint256 _fs, uint256 _fsIncr, uint256 _f, uint256 _w, uint256 amount) external pure returns (uint256 _floor);

	function floorSupply(uint256 id) external view returns (uint256);

	function floor(uint256 id) external view returns (uint256);

	function fsStepOf(uint256 id) external view returns (uint256);

	function stepment(uint256 id) external view returns (uint256);
}
