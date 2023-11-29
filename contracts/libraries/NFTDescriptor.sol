// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./Strings.sol";
import "./BytesLib.sol";
import "./console.sol";

library NFTDescriptor {
	struct Meta {
		uint256 id;
		address creator;
		uint256 mintingPrice;
		uint256 burningPrice;
		uint256 floor;
		uint256 floorSupply;
		uint256 totalSupply;
		uint256 totalWorth;
	}

	function getTokenURI(Meta memory meta) external pure returns (string memory) {
		string memory name = string(abi.encodePacked("@Moss-", Strings.toString(meta.id)));
		string memory json = string(abi.encodePacked('{"name":"', name, '","description":"', name, '","external_url":"https://www.baidu.com/","image_data":"', getSVGImage(meta), '"}'));
		return string.concat("data:application/json;utf8,", json);
	}

	function getSVGImage(Meta memory meta) internal pure returns (string memory) {
		bytes memory c = abi.encodePacked(address(uint160(mulmod(uint160(meta.creator), meta.id + 1, type(uint160).max))));
		bytes memory c0 = BytesLib.slice(c, 0, 10);
		bytes memory c1 = BytesLib.slice(c, 10, 10);
		string memory head = string.concat(
			"<svg width='512' height='512' viewBox='0 0 512 512' fill='none' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'> <defs><clipPath id='cut-off'><circle cx='256' cy='256' r='256' /></clipPath></defs>",
			"<circle id='cut-off' cx='256' cy='256' r='256' fill='#000000' />",
			circle(c0),
			animationCircle(c1)
		);
		Meta memory _meta = meta;
		string memory body = string.concat(textName(_meta.id), textMintingPrice(_meta.mintingPrice), textBurningPrice(_meta.burningPrice), textFloorPrice(_meta.floor), textFloorSupply(_meta.floorSupply), textTotalSupply(_meta.totalSupply), textTotalWorth(_meta.totalWorth));
		string memory tail = "</svg>";
		return string.concat(head, body, tail);
	}

	function circle(bytes memory c) internal pure returns (string memory) {
		uint8 cx0 = uint8(c[0]);
		uint8 cx1 = uint8(c[1]);
		uint8 cy0 = uint8(c[2]);
		uint8 cy1 = uint8(c[3]);
		uint8 r = uint8(c[4]);
		string memory fill = Strings.toHexString(c, 5, 3);
		uint256 opacity = uint256(10000 * (512 + uint256(uint8(c[8])) + uint256(uint8(c[9])))) / 1024;
		return
			string(
				abi.encodePacked("<circle cx='", Strings.toString(uint256(cx0) + uint256(cx1)), "' cy='", Strings.toString(uint256(cy0) + uint256(cy1)), "' r='", Strings.toString(uint256(r)), "' fill='#", fill, "' fill-opacity='", Strings.toFixed(opacity, 2, 2), "%' clip-path='url(#cut-off)' />")
			);
	}

	function animationCircle(bytes memory c) internal pure returns (string memory) {
		uint8 cx0 = uint8(c[0]);
		uint8 cx1 = uint8(c[1]);
		uint8 cy0 = uint8(c[2]);
		uint8 cy1 = uint8(c[3]);
		uint8 r = uint8(c[4]);
		string memory fill = Strings.toHexString(c, 5, 3);
		uint256 opacity = uint256(10000 * (512 + uint256(uint8(c[8])) + uint256(uint8(c[9])))) / 1024;
		string memory fillOpacityPCT = Strings.toFixed(opacity, 2, 2);
		string memory animateFillOpacityPCT = Strings.toFixed(opacity, 4, 4);
		return
			string(
				abi.encodePacked(
					"<circle cx='",
					Strings.toString(uint256(cx0) + uint256(cx1)),
					"' cy='",
					Strings.toString(uint256(cy0) + uint256(cy1)),
					"' r='",
					Strings.toString(uint256(r)),
					"' fill='#",
					fill,
					"' fill-opacity='",
					fillOpacityPCT,
					"%' clip-path='url(#cut-off)'><animate attributeName='fill-opacity' values='0;",
					animateFillOpacityPCT,
					";0' dur='3s' repeatCount='indefinite' /></circle>"
				)
			);
	}

	function textName(uint256 id) internal pure returns (string memory) {
		string memory name = string(abi.encodePacked("@Moss-", Strings.toString(id)));
		return string(abi.encodePacked("<text x='256' y='150' fill='#ffffff' text-anchor='middle' font-size='36' font-weight='bold' font-style='italic'>", name, "</text>"));
	}

	function textMintingPrice(uint256 mintingPrice) internal pure returns (string memory) {
		return string(abi.encodePacked("<text x='130' y='230' fill='#ffffff' text-anchor='left' font-size='16' font-weight='bold' font-style='italic'>Minting Price: ", Strings.toFixed(mintingPrice, 18, 6), "</text>"));
	}

	function textBurningPrice(uint256 burningPrice) internal pure returns (string memory) {
		return string(abi.encodePacked("<text x='130' y='260' fill='#ffffff' text-anchor='left' font-size='16' font-weight='bold' font-style='italic'>Burning Price: ", Strings.toFixed(burningPrice, 18, 6), "</text>"));
	}

	function textFloorPrice(uint256 floor) internal pure returns (string memory) {
		return string(abi.encodePacked("<text x='130' y='290' fill='#ffffff' text-anchor='left' font-size='16' font-weight='bold' font-style='italic'>Floor Price: ", Strings.toFixed(floor, 18, 6), "</text>"));
	}

	function textFloorSupply(uint256 floorSupply) internal pure returns (string memory) {
		return string(abi.encodePacked("<text x='130' y='320' fill='#ffffff' text-anchor='left' font-size='16' font-weight='bold' font-style='italic'>Floor Supply: ", Strings.toString(floorSupply), "</text>"));
	}

	function textTotalSupply(uint256 totalSupply) internal pure returns (string memory) {
		return string(abi.encodePacked("<text x='130' y='350' fill='#ffffff' text-anchor='left' font-size='16' font-weight='bold' font-style='italic'>Total Supply: ", Strings.toString(totalSupply), "</text>"));
	}

	function textTotalWorth(uint256 totalWorth) internal pure returns (string memory) {
		return string(abi.encodePacked("<text x='130' y='380' fill='#ffffff' text-anchor='left' font-size='16' font-weight='bold' font-style='italic'>Total Worth: ", Strings.toFixed(totalWorth, 18, 6), "</text>"));
	}

	function textCreator(address creator) internal pure returns (string memory) {
		return string(abi.encodePacked("<text x='256' y='440' fill='#ffffff' text-anchor='middle' font-size='12' font-weight='bold' font-style='italic'>Creator: ", Strings.toHexString(creator), "</text>"));
	}
}
