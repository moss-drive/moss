// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "../core/MossHub.sol";
import "./IBlastPoints.sol";

contract BlastHub is MossHub {
	function configBlastPoint(IBlastPoints points, address op) external {
		require(msg.sender == dev, "BlastHub: caller is not dev");
		points.configurePointsOperator(op);
	}
}
