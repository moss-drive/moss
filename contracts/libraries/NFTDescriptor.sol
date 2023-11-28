// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Base64.sol";
import "./Strings.sol";
import "./BytesLib.sol";
import "./BytesLib.sol";

import "./console.sol";

library NFTDescriptor {
	function getTokenURI(uint256 id, address creator, string memory stoneName) external pure returns (string memory) {
		if (bytes(stoneName).length == 0) {
			stoneName = string(abi.encodePacked("@Moss-", Strings.toString(id)));
		}
		string memory json = string(abi.encodePacked('{"name":"', stoneName, '","description":"', stoneName, '","external_url":"https://www.baidu.com/","image_data":"', getSVGImage(id, creator, stoneName), '","attributes":[{"trait_type":"id","value":"#', Strings.toString(id), '"}]}'));
		return string.concat("data:application/json;utf8,", json);
	}

	function getSVGImage(uint256 id, address creator, string memory stoneName) internal pure returns (bytes memory) {
		bytes memory c = abi.encodePacked(address(uint160(mulmod(uint160(creator), id + 1, type(uint160).max))));
		bytes memory c0 = BytesLib.slice(c, 0, 10);
		bytes memory c1 = BytesLib.slice(c, 10, 10);
		return
			abi.encodePacked(
				"<svg width='512' height='512' viewBox='0 0 512 512' fill='none' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'> <defs><clipPath id='cut-off'><circle cx='256' cy='256' r='256' /></clipPath></defs>",
				"<circle id='cut-off' cx='256' cy='256' r='256' fill='#000000' />",
				circle(c0),
				animationCircle(c1),
				textMoss(id, stoneName),
				textCreator(creator),
				"</svg>"
			);
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
			string(abi.encodePacked("<circle cx='", Strings.toString(uint256(cx0) + uint256(cx1)), "' cy='", Strings.toString(uint256(cy0) + uint256(cy1)), "' r='", Strings.toString(uint256(r)), "' fill='#", fill, "' fill-opacity='", Strings.toFixed(opacity, 2), "%' clip-path='url(#cut-off)' />"));
	}

	function animationCircle(bytes memory c) internal pure returns (string memory) {
		uint8 cx0 = uint8(c[0]);
		uint8 cx1 = uint8(c[1]);
		uint8 cy0 = uint8(c[2]);
		uint8 cy1 = uint8(c[3]);
		uint8 r = uint8(c[4]);
		string memory fill = Strings.toHexString(c, 5, 3);
		uint256 opacity = uint256(10000 * (512 + uint256(uint8(c[8])) + uint256(uint8(c[9])))) / 1024;
		string memory fillOpacityPCT = Strings.toFixed(opacity, 2);
		string memory animateFillOpacityPCT = Strings.toFixed(opacity, 4);
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

	function textMoss(uint256 id, string memory stoneName) internal pure returns (string memory) {
		if (bytes(stoneName).length == 0) {
			stoneName = string(abi.encodePacked("@Moss-", Strings.toString(id)));
		}
		return string(abi.encodePacked("<text x='256' y='256' fill='#ffffff' text-anchor='middle' font-size='36' font-weight='bold' font-style='italic'>", stoneName, "</text>"));
	}

	function textCreator(address creator) internal pure returns (string memory) {
		return string(abi.encodePacked("<text x='256' y='380' fill='#ffffff' text-anchor='middle' font-size='12' font-weight='bold' font-style='italic'>Creator: ", Strings.toHexString(creator), "</text>"));
	}
}
