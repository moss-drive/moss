// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.8.19;

contract Voter {
	event Voted(address token, uint256 amount, address origin, address indexed voter, address grantAddress, bytes32 indexed projectId, uint256 applicationIndex, address indexed roundAddress);
}
