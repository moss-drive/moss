// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../libraries/console.sol";
import "../interfaces/IMoss.sol";

contract Helpers {
	IMoss public immutable moss;

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

	constructor(IMoss _moss) {
		moss = _moss;
	}

	function stoneOf(address to, uint256 id) public view returns (StoneInfo memory stone) {
		stone.k = moss.k();
		stone.minFloor = moss.minFloor();
		stone.devFeePCT = moss.devFeePCT();
		stone.defaultCreatorFeePCT = moss.defaultCreatorFeePCT();
		stone.creator = moss.creatorOf(id);
		stone.floor = moss.floor(id);
		stone.floorSupply = moss.floorSupply(id);
		stone.stepment = moss.stepment(id);
		stone.fsStep = moss.fsStepOf(id);
		stone.accountBalance = moss.balanceOf(to, id);
		stone.totalSupply = moss.totalSupply(id);
		stone.worth = moss.worthOf(id);
	}

	function stoneBuy(uint256 id, uint256 amountToBuy) public view returns (BuyPriceInfo memory buy) {
		uint256 k = moss.k();
		uint256 floor = moss.floor(id);
		uint256 floorSupply = moss.floorSupply(id);
		uint256 totalSupply = moss.totalSupply(id);
		(uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) = moss.estimateBuy(k, totalSupply, floorSupply, floor, amountToBuy);
		buy = BuyPriceInfo({ total: total, value: value, creatorFee: creatorFee, devFee: devFee });
	}

	function stoneSell(uint256 id, uint256 amountToSell) public view returns (SellPriceInfo memory sale) {
		uint256 k = moss.k();
		uint256 floor = moss.floor(id);
		uint256 floorSupply = moss.floorSupply(id);
		uint256 totalSupply = moss.totalSupply(id);
		(uint256 total, uint256 value, uint256 creatorFee, uint256 devFee) = moss.estimateSell(k, totalSupply, floorSupply, floor, amountToSell);
		sale = SellPriceInfo({ total: total, value: value, creatorFee: creatorFee, devFee: devFee });
	}
}
