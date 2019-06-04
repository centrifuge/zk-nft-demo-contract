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

import { ERC721Metadata } from "./openzeppelin-solidity/token/ERC721/ERC721Metadata.sol";

contract AnchorLike {
    function getAnchorById(uint) public returns (uint, bytes32, uint32);
}

contract IdentityFactoryLike {
}

contract ZKNFT is ERC721Metadata {
    // --- Data ---
    AnchorLike public           anchors;
    IdentityFactoryLike public  identities;
    bytes32 public              ratings; 
    
    struct TokenData {
        uint    amount;
        bytes   currency;
        uint48  due_date;
        uint anchor;
    }
    mapping (uint => TokenData) public data;

    string public uri;
    
    constructor (string memory name, string memory symbol, address anchors_) ERC721Metadata(name, symbol) public {
        anchors = AnchorLike(anchors_);
        //identities = IdentityFactoryLike(identities_);
    }

    function file(bytes32 what, bytes32 data_) public {
        // TODO Needs auth
        if (what == "credit_rating") { ratings = data_; }
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
    function checkAnchorRoot(bytes32 doc_root, bytes32 data_root, bytes32 signatures) pure internal returns (bool) {
        return doc_root == sha256(concat(data_root, signatures));
    }

    function mint (address usr, uint tkn, uint anchor, bytes32 data_root, bytes32 signatures_root, uint amount, bytes memory currency, uint rating, uint48 due_date) public returns (uint) {
        bytes32 doc_root;
        (, doc_root, ) = anchors.getAnchorById(anchor);
        require(checkAnchorRoot(doc_root, data_root, signatures_root), "anchor-root-failed");
        require(verify(data_root, ratings, amount, rating), "snark-not-verified");

        data[tkn] = TokenData(amount, currency, due_date, anchor);
        _mint(usr, tkn);
    }
   
    function verify(bytes32 data_root, bytes32 credit_rating_root, uint nft_amount, uint rating) pure internal returns (bool) {
      // mock zokrates call
      return true;
    }
} 


