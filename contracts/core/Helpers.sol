// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../libraries/console.sol";
import "../interfaces/IMossHub.sol";

contract Helpers {
	IMossHub public immutable mossHub;

	struct BuyPriceInfo {
		uint256 total;
		uint256 value;
		uint256 creatorFee;
		uint256 devFee;
	}

	struct SellPriceInfo {
		uint256 total;
		uint256 value;
		uint256 creatorFee;
		uint256 devFee;
	}

	struct StoneInfo {
		uint64 k;
		uint64 minFloor;
		uint64 devFeePCT;
		uint64 defaultCreatorFeePCT;
		address creator;
		uint256 floor;
		uint256 floorSupply;
		uint256 stepment;
		uint256 fsStep;
		uint256 accountBalance;
		uint256 totalSupply;
		uint256 worth;
	}

	constructor(IMossHub _mossHub) {
		mossHub = _mossHub;
	}

	function stoneOf(address to, uint256 id) public view returns (StoneInfo memory stone) {
		stone.k = mossHub.k();
		stone.minFloor = mossHub.minFloor();
		stone.devFeePCT = mossHub.devFeePCT();
		stone.defaultCreatorFeePCT = mossHub.defaultCreatorFeePCT();
		stone.creator = mossHub.creatorOf(id);
		stone.floor = mossHub.floor(id);
		stone.floorSupply = mossHub.floorSupply(id);
		stone.stepment = mossHub.stepment(id);
		stone.fsStep = mossHub.fsStepOf(id);
		stone.accountBalance = mossHub.balanceOf(to, id);
		stone.totalSupply = mossHub.totalSupply(id);
		stone.worth = mossHub.worthOf(id);
	}

	function stoneBuy(uint256 id, uint256 amountToBuy) public view returns (BuyPriceInfo memory buy) {
		uint256 k = mossHub.k();
		uint256 floor = mossHub.floor(id);
		uint256 floorSupply = mossHub.floorSupply(id);
		uint256 totalSupply = mossHub.totalSupply(id);
		(uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) = mossHub.estimateBuy(k, totalSupply, floorSupply, floor, amountToBuy);
		buy = BuyPriceInfo({ total: total, value: value, creatorFee: creatorFee, devFee: devFee });
	}

	function stoneSell(uint256 id, uint256 amountToSell) public view returns (SellPriceInfo memory sale) {
		uint256 k = mossHub.k();
		uint256 floor = mossHub.floor(id);
		uint256 floorSupply = mossHub.floorSupply(id);
		uint256 totalSupply = mossHub.totalSupply(id);
		(uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) = mossHub.estimateSell(k, totalSupply, floorSupply, floor, amountToSell);
		sale = SellPriceInfo({ total: total, value: value, creatorFee: creatorFee, devFee: devFee });
	}
}
