// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "../core/MossHub.sol";
import "./IBlastPoints.sol";

contract BlastMossHub is MossHub {
	function configBlastPoint(IBlastPoints points, address op) external {
		require(msg.sender == dev, "BlastMossHub: caller is not dev");
		points.configurePointsOperator(op);
	}
}
