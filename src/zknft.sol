// Copyright (C) 2019 lucasvo

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity >=0.4.24;

import { ERC721Enumerable } from "./openzeppelin-solidity/token/ERC721/ERC721Enumerable.sol";
import { ERC721Metadata } from "./openzeppelin-solidity/token/ERC721/ERC721Metadata.sol";
import "./verifier.sol";

contract AnchorLike {
    function getAnchorById(uint) public returns (uint, bytes32, uint32);
}

contract ZKNFT is Verifier, ERC721Enumerable, ERC721Metadata {
    // --- Data ---
    AnchorLike public           anchors;
    bytes32 public              ratings; 
    string public               uri_prefix; 
    struct TokenData {
        uint amount;
        uint anchor;
        uint rating;
    }
    mapping (uint => TokenData) public data;

    string public uri;
    
    constructor (string memory name, string memory symbol, address anchors_) ERC721Enumerable() ERC721Metadata(name, symbol) public {
        anchors = AnchorLike(anchors_);
    }

    // TODO: Need auth & note
    function file(bytes32 what, bytes32 data_) public {
        if (what == "ratings") { ratings = data_; }
    }
    function file(bytes32 what, string memory data_) public {
        if (what == "uri_prefix") { uri_prefix = data_; }
    }

    // --- Utils ---
    function concat(bytes32 b1, bytes32 b2) pure internal returns (bytes memory)
    {
        bytes memory result = new bytes(64);
        assembly {
            mstore(add(result, 32), b1)
            mstore(add(result, 64), b2)
        }
        return result;
    }
    
    function uint2str(uint i) internal pure returns (string memory) {
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }

    // --- ZKNFT ---
    function checkAnchor(uint anchor, bytes32 droot, bytes32 sigs) public returns (bool) {
        bytes32 root;
        (, root, ) = anchors.getAnchorById(anchor);
        return root == sha256(concat(droot, sigs));
    }

    function mint (address usr, uint tkn, uint anchor, bytes32 data_root, bytes32 signatures_root, uint amount, uint rating, uint[8] memory points) public returns (uint) {
        require(checkAnchor(anchor, data_root, signatures_root), "anchor-root-failed");
        verify(data_root, amount, rating, points);

        data[tkn] = TokenData(amount, anchor, rating);
        _mint(usr, tkn);
    }
 
    // unpack takes one bytes32 argument and turns it into two uint256 to make it fit into a field element
    function unpack(bytes32 x) public returns (uint y, uint z) {
        bytes32 a = bytes32(x);
        bytes32 b = (a>> 128);
        bytes32 c = ((a<< 128)>> 128);
        return (uint(b), uint(c));
    }

    function verify(
        bytes32 data_root, 
        uint nft_amount, 
        uint rating,
        uint[8] memory points
    ) public {
        // NFT Amount shouldn't be bigger than a field element 
        require(nft_amount <= 2**253);

        uint[2] memory a = [points[0], points[1]];
        uint[2][2] memory b = [[points[2], points[3]], [points[4], points[5]]];
        uint[2] memory c = [points[6], points[7]];

        // inputs:
        // 0, 1 creditRatingRootHashField
        // 2 buyerRatingField
        // 3 nftAmount
        // 4, 5 documentRootHashFiel
        // 6 = one
        uint[7] memory input;
        (input[0], input[1]) = unpack(ratings);
        input[2] = rating;
        input[3] = nft_amount;
        (input[4], input[5]) = unpack(data_root);
        input[6] = 1;

        require(verifyTx(a, b, c, input));
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return string(abi.encodePacked(uri_prefix, uint2str(tokenId)));
    } 
}

