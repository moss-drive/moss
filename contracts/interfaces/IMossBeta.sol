// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IMossBeta {
	struct Cache {
		uint256 id;
		uint256 k;
		uint256 f;
		uint256 t;
		uint256 h;
		uint256 p0;
		uint256 p1;
		uint256 p2;
		uint256 amount;
		address to;
	}

	struct EstimationParams {
		uint256 k;
		uint256 f;
		uint256 t;
		uint256 p0;
		uint256 p1;
		uint256 p2;
		uint256 h;
		uint256 amount;
	}

	struct AjustmentParams {
		uint256 k;
		uint256 f;
		uint256 t;
		uint256 p0;
		uint256 p1;
		uint256 p2;
		uint256 h;
		uint256 w;
		uint256 amount;
	}

	event Created(address creator, uint256 k, uint256 f, uint256 p0, uint256 fee);

	event Minted(address from, uint256 id, address to, uint256 amount, uint256 value, uint256 creatorFee, uint256 devFee);

	event Burnt(address from, uint256 id, address to, uint256 amount, uint256 value, uint256 creatorFee, uint256 devFee);

	function create(uint256 timeoutAt) external payable;

	function mint(uint256 id, address to, uint256 amount) external payable;

	function burn(uint256 id, address to, uint256 amount, uint256 minReceived) external;

	function worth(uint256 _k, uint256 _f, uint256 _t, uint256 _p0, uint256 _p1, uint256 _p2, uint256 _h) external pure returns (uint256);

	function worthOf(uint256 id) external view returns (uint256);

	function estimateMint(uint256 id, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateBurn(uint256 id, uint256 amount) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateMint(EstimationParams memory params) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateBurn(EstimationParams memory params) external view returns (uint256 total, uint256 value, uint256 creatorFee, uint256 devFee);

	function estimateAdjust(AjustmentParams memory params) external pure returns (bool success, uint256 nf, uint256 nh, uint256 np1, uint256 np2);

	function totalSupply(uint256 id) external view returns (uint256);

	function exists(uint256 id) external view returns (bool);
}
