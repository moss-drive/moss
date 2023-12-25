// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./Strings.sol";
import "./BytesLib.sol";
import "./console.sol";

library NFTDescriptor {
	struct Meta {
		uint256 id;
		address creator;
		uint256 k;
		uint256 floor;
		uint256 floorSupply;
		uint256 totalSupply;
		uint256 targetSupply;
		uint256 mintingPrice;
		uint256 burningPrice;
		uint256 totalWorth;
	}

	// no need to save gas
	struct Position {
		uint256 FPY;
		uint256 FSX;
		uint256 FSY;
		uint256 TSX;
		uint256 TSY;
		string FPYstr;
		string FSXstr;
		string FSYstr;
		string TSXstr;
		string TSYstr;
		string TWXstr;
		string TWYstr;
	}

	// default margin must be greater than 30
	uint256 internal constant marginX = 50;
	uint256 internal constant marginY = 50;
	uint256 internal constant scaleX = 500;
	uint256 internal constant scaleY = 500;
	uint256 internal constant PRECISION = 1e18;

	function getTokenURI(Meta memory meta) external pure returns (string memory) {
		string memory name = string(abi.encodePacked("@Moss-", Strings.toString(meta.id)));
		string memory json = string(abi.encodePacked('{"name":"', name, '","description":"', name, '","image_data":"', getSVGImage(meta), '"}'));
		return string.concat("data:application/json;utf8,", json);
	}

	function getSVGImage(Meta memory meta) internal pure returns (string memory) {
		string memory head = string.concat(
			"<svg width='600' height='600' xmlns='http://www.w3.org/2000/svg'><style>text {font-size: 8;font-style: italic;font-weight: bold;fill: #ffffff;}line {stroke: #ffffff;stroke-width: 1;}</style><rect width='600' height='600' fill='#000000' /><line x1='50' y1='550' x2='570' y2='550' /><line x1='560' y1='545' x2='570' y2='550' /><line x1='560' y1='555' x2='570' y2='550' /><line x1='50' y1='30' x2='50' y2='550' /><line x1='45' y1='40' x2='50' y2='30' /><line x1='55' y1='40' x2='50' y2='30' /><text x='585' y='555' text-anchor='middle'>X</text><text x='50' y='22' text-anchor='middle'>Y</text>"
		);
		string memory str = string.concat(head, textName(meta.id), textPrice(meta.mintingPrice, meta.burningPrice));
		Position memory pos = getPosition(meta);
		Meta memory _meta = meta;
		bool isLittle = _meta.totalSupply <= _meta.floorSupply;
		str = string.concat(
			str,
			pathFloorSupply(_meta.floorSupply, pos.FSXstr, pos.FSYstr),
			isLittle ? pathLittleTotalSupply(pos.TSXstr, pos.TSYstr) : pathLargeTotalSupply(pos.FSXstr, pos.FSYstr, pos.TSXstr, pos.TSYstr),
			pathTargetSupply(_meta.targetSupply, pos.FSXstr, pos.FSYstr),
			textTotalSupply(_meta.totalSupply, pos.TSXstr),
			textTotalWorth(_meta.totalWorth, pos.TWXstr, pos.TWYstr),
			textFloorPrice(_meta.floor, pos.FPYstr),
			"</svg>"
		);
		return str;
	}

	function getPosition(Meta memory meta) internal pure returns (Position memory postion) {
		uint256 temp = meta.k * (meta.targetSupply - meta.floorSupply);
		uint256 max = meta.floor + temp;
		postion.FPY = marginY * PRECISION + ((scaleY * temp * PRECISION) / max);
		postion.FSX = marginX * PRECISION + ((scaleX * meta.floorSupply * PRECISION) / meta.targetSupply);
		postion.FSY = postion.FPY;
		postion.TSX = marginX * PRECISION + (PRECISION * scaleX * meta.totalSupply) / meta.targetSupply;
		if (meta.totalSupply > meta.floorSupply) {
			uint256 dy = scaleY * PRECISION * PRECISION - ((marginY + scaleY) * PRECISION - postion.FSY) * PRECISION;
			uint256 dx = ((marginX + scaleX) * PRECISION - postion.FSX);
			uint256 newK = dy / dx;
			temp = newK * (postion.TSX - postion.FSX);
			postion.TSY = postion.FSY * PRECISION - (newK * (postion.TSX - postion.FSX));
		} else {
			postion.TSY = postion.FSY * PRECISION;
		}
		postion.FPYstr = Strings.toFixed(postion.FPY, 18, 18);
		postion.FSXstr = Strings.toFixed(postion.FSX, 18, 18);
		postion.FSYstr = Strings.toFixed(postion.FSY, 18, 18);
		postion.TSXstr = Strings.toFixed(postion.TSX, 18, 18);
		postion.TSYstr = Strings.toFixed(postion.TSY, 36, 18);
		postion.TWXstr = Strings.toFixed(marginX * PRECISION + (postion.TSX - marginX * PRECISION) / 2, 18, 18);
		postion.TWYstr = Strings.toFixed(postion.FSY + ((marginX + scaleX) * PRECISION - postion.FSY) / 2, 18, 18);
	}

	function textName(uint256 id) internal pure returns (string memory) {
		string memory name = string(abi.encodePacked("@Moss-", Strings.toString(id)));
		return string.concat("<text x='570' y='30' text-anchor='end'>", name, "</text>");
	}

	function textPrice(uint256 mintingPrice, uint256 burningPrice) internal pure returns (string memory) {
		return string.concat("<text x='300' y='40' text-anchor='middle'>MP-", Strings.toFixed(mintingPrice, 18, 6), " BP-", Strings.toFixed(burningPrice, 18, 6), "</text>");
	}

	function textFloorPrice(uint256 floor, string memory FPYstr) internal pure returns (string memory) {
		return string.concat("<text x='60' y='", FPYstr, "' text-anchor='start' font-size='10'>FP-", Strings.toFixed(floor, 18, 6), "</text>");
	}

	function pathTargetSupply(uint256 targetSupply, string memory FSXstr, string memory FSYstr) internal pure returns (string memory) {
		return string.concat("<path d='M 50,", FSYstr, " L ", FSXstr, ",", FSYstr, " L 550,50 L 550,550 L 50,550 L 50,", FSYstr, "' fill='blue' opacity='0.2' /><text x='550' y='540' text-anchor='middle' font-size='10'>TARS-", Strings.toString(targetSupply), "</text>");
	}

	function pathFloorSupply(uint256 floorSupply, string memory FSXstr, string memory FSYstr) internal pure returns (string memory) {
		return string.concat("<line x1='", FSXstr, "' y1='", FSYstr, "' x2='", FSXstr, "' y2='550' stroke-dasharray='5,3' opacity='0.6' /><text x='", FSXstr, "' y='570' text-anchor='middle' font-size='10'>FS-", Strings.toString(floorSupply), "</text>");
	}

	function pathLittleTotalSupply(string memory TSXstr, string memory TSYstr) internal pure returns (string memory) {
		return string.concat("<path d='M 50,", TSYstr, " L ", TSXstr, ",", TSYstr, " L ", TSXstr, ",550 L 50,550 L 50,", TSYstr, "' fill='blue' opacity='0.5' />");
	}

	function pathLargeTotalSupply(string memory FSXstr, string memory FSYstr, string memory TSXstr, string memory TSYstr) internal pure returns (string memory) {
		return string.concat("<path d='M 50,", FSYstr, " L ", FSXstr, ",", FSYstr, " L ", TSXstr, ",", TSYstr, " L ", TSXstr, ",550 L 50,550 L 50,", FSYstr, "' fill='blue' opacity='0.5' />");
	}

	function textTotalSupply(uint256 totalSupply, string memory TSXstr) internal pure returns (string memory) {
		return string.concat("<text x='", TSXstr, "' y='570' text-anchor='middle' font-size='10'>TS-", Strings.toString(totalSupply), "</text>");
	}

	function textTotalWorth(uint256 totalWorth, string memory TWXstr, string memory TWYstr) internal pure returns (string memory) {
		return string.concat("<text x='", TWXstr, "' y='", TWYstr, "' text-anchor='middle' font-size='10'>TW-", Strings.toFixed(totalWorth, 18, 6), "</text>");
	}
}
