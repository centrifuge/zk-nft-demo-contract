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

pragma solidity >=0.4.23;

import "ds-test/test.sol";
import "../zknft.sol";

contract User {
    function doMint(address registry, address usr) public {
    }
}

contract AnchorMock {
    bytes32 documentRoot;
    uint32  blockNumber;

    function file(bytes32 documentRoot_, uint32 blockNumber_) public {
        documentRoot = documentRoot_;
        blockNumber = blockNumber;
    }

    function getAnchorById(uint id) public returns (uint, bytes32, uint32) {
        return (id, documentRoot, blockNumber);
    }
}

contract ZKNFTTest is DSTest  {
    ZKNFT  nft;
    address     self;
    User        user1;
    User        user2;
    AnchorMock  anchors;

    function setUp() public {
        self = address(this);
        user1 = new User();
        user2 = new User();
        anchors = new AnchorMock();
        nft = new ZKNFT("test", "TEST", address(anchors));
    }

    function testMint() public logs_gas {
        // Set the credit rating root on the NFT contract
        nft.file("ratings", bytes32(uint(0xaba3f2af3c5c97f5aa54b81af14eb156e1c66790472354804009125b56773228)));
    
        bytes32 sigs = 0x5d9215ea8ea2c12bcc724d9690de0801a1b9658014c29c2a26d3b89eaa65cd07;
        bytes32 root = 0x86e2e64b15c97b7f8327165ff539097a745b7d44126f36978fc26cfb1c3e76fe;
        bytes32 data_root = 0x7fdb7b2d4ddb3ca67c1a79725fc9b3e4e2b8d4c15bedc8cac1873fa58a75b837;

        // Setting AnchorMock to return a given root
        anchors.file(root, 0); 
        
        uint rating = 0x0000000000000000000000000000000000000000000000000000000000000064;
        uint amount = 0x0000000000000000000000000000000000000000000000000000000000000140;
        
        uint[8] memory points =  [
            0x245c5821e1ab7f55dcf88949ac6e0386767e21eec722896070cf9aa2623fc7ff,
            0x1a5e30e3ad8b73c112f516eb9b2209ae9fb58bd0ad72c29dacf9c68ccd8b236a,
            0x16f159ecf943c151c0e42e487ecac743d837af202ab69a1c459747a0fcd27f60,
            0x12223aea498617271cf451e676881d499534b27dc03dbe654e41c28be9181c13,
            0x019b966e82081a9a2bd4afc42cc95b56098d82cfc91b922c402dc66981caf477,
            0x109f0795b87ecbe40774fd24a0a139ee4ca6ea458948da28c9f51aabb65be1bf,
            0x28c7f141a9031264fef81dea045edb05925b6548792933f2c7fed53553099cd1,
            0x28ca04fd476c030fe4e1045f19b75bc55626172adbc575e101c9a61142d8d0f5];

        nft.mint(address(user1), 1, 1, data_root, sigs, amount, rating, points);
        assertEq(address(user1), nft.ownerOf(1));
    }
}
