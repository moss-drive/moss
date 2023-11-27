// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Base64.sol";
import "./Strings.sol";
import "./BytesLib.sol";
import "./console.sol";

library NFTDescriptor {
	function getTokenURI(uint256 id, address creator) external pure returns (string memory) {
		string memory symbol = string(abi.encodePacked("@Moss-", Strings.toString(id)));
		string memory json = string(abi.encodePacked('{"name":"', symbol, '","description":"', symbol, '","image_data":"', getSVGImage(id, creator), '","attributes":[{"trait_type":"id","value":"#', Strings.toString(id), '"}]}'));
		return string.concat("data:application/json;utf8,", json);
	}

	function getSVGImageBase64Encoded(uint256 id, address creator) internal pure returns (string memory) {
		return Base64.encode(getSVGImage(id, creator));
	}

	function getSVGImage(uint256 id, address creator) internal pure returns (bytes memory) {
		bytes memory c = abi.encodePacked(creator);
		bytes memory c0 = BytesLib.slice(c, 0, 10);
		bytes memory c1 = BytesLib.slice(c, 10, 10);
		return
			abi.encodePacked(
				"<svg width='512' height='512' viewBox='0 0 512 512' fill='none' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'> <defs><clipPath id='cut-off'><circle cx='256' cy='256' r='256' /></clipPath></defs>",
				"<circle id='cut-off' cx='256' cy='256' r='256' fill='#000000' />",
				circle(c0),
				animationCircle(c1),
				text(id),
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
		uint256 opacity = uint256(100 * (512 + uint256(uint8(c[8])) + uint256(uint8(c[9])))) / 1024;
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
					Strings.toString(uint256(opacity)),
					"%' clip-path='url(#cut-off)' />"
				)
			);
	}

	function animationCircle(bytes memory c) internal pure returns (string memory) {
		uint8 cx0 = uint8(c[0]);
		uint8 cx1 = uint8(c[1]);
		uint8 cy0 = uint8(c[2]);
		uint8 cy1 = uint8(c[3]);
		uint8 r = uint8(c[4]);
		string memory fill = Strings.toHexString(c, 5, 3);
		uint256 opacity = uint256(100 * (512 + uint256(uint8(c[8])) + uint256(uint8(c[9])))) / 1024;
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
					Strings.toString(uint256(opacity)),
					"%' clip-path='url(#cut-off)'><animate attributeName='fill-opacity' values='0;0.",
					Strings.toString(uint256(opacity)),
					";0' dur='3s' repeatCount='indefinite' /></circle>"
				)
			);
	}

	function text(uint256 id) internal pure returns (string memory) {
		return string(abi.encodePacked("<text x='256' y='256' fill='#ffffff' text-anchor='middle' font-size='36' font-weight='bold' font-style='italic'>@Moss-", Strings.toString(id), "</text>"));
	}
}
