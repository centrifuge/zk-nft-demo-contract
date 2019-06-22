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
        nft.file("ratings", bytes32(uint(0x1e24c21a525a96ba9f00f4436167fad9bbb82722f9c22748ec84e462e6cbd7e3)));
    
        bytes32 sigs = 0x66e2b39e6df8e01df6af25c56bae2e80d9ec58617aad5f0bda7497bf85c8ea84; 
        bytes32 root = 0x223dd9478e324771dde8320dcfe89a31e33a35d3dc1a00ca018bbc6d2606e4b0;
        bytes32 data_root = 0xef8a19dbd60506d2ef7d9f48fc0452e3ccd5064393d91cd9639f4a57c4d5ba24;

        // Setting AnchorMock to return a given root
        anchors.file(root, 0); 
        
        uint rating = 0x0000000000000000000000000000000000000000000000000000000000000064;
        uint amount = 0x0000000000000000000000000000000000000000000000000000000000000140;
        
        uint[8] memory points =  [
            0x0fdc3004e66336193e416adfdbf1386a3bb1897d6ffd81d2e0b388ab795f1463,
            0x26e4ef80d5b7f22f4b728cc381b1233652251a47a750b142c34e9b91773443f4,
            0x2c1ae2b2ba879614c9ee0a1b89697ae4bf4bd9187d292e4c3139ea31be70c00a,       
            0x2458c01d1b0615bab2555516af46987e31e47e72edb49675e5b8ceaabdf0a7a0,
            0x0cd751c8d760366dbb2abb09004c499f4531eea8160cecb9915e5edb92b0104a,
            0x14b279c5aaa8b61e78f542bef7c89f07d70b12ac7bc3204ed4865f6d8bd6a912,
            0x15b15fb2b3188f681730e91fb9ea194829f47430a4de559d6bc6e6648b121422,  
            0x12aea6420fbe70b9d790a0b655080d9d05d0d9ca9681436971a5df449a4b352e];

        nft.mint(address(user1), 1, 1, data_root, sigs, amount, rating, points);
        assertEq(address(user1), nft.ownerOf(1));
    }
}
