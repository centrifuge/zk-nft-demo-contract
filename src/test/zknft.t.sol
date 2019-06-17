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
    ZKNFT    nft;
    address  self;
    User     user1;
    User     user2;
    AnchorMock anchors;

    function setUp() public {
        self = address(this);
        user1 = new User();
        user2 = new User();
        anchors = new AnchorMock();
        nft = new ZKNFT("test", "TEST", address(anchors));
        nft.file("ratings", bytes32(uint(0x058653f1572ef609a6576b89be3271f0f3e2d80669953c6f9cd2172a63bd5bac)));
    }

    function getPoints() public returns (uint[8] memory) {
        uint[8] memory points = [
            0x1b19dea8ba4e3c1643eb67a42667fd3cc50a189f54977e2f8ab0beee332b2a38,      
            0x04316b0283e31e05ca8f49baae7f1a4d52c2d2dcfacad1edb17c290a33a9cbef,
            0x269d4617a373ec216e4e730597f3924cb2e96f798f15a5a7421ebb77fb5c7012, 
            0x26e6e0ed9573550db84449bd105d2739cc3ed7c91f1982d825095fde1209c0e8,
            0x2068e2f7f8638cd53df08e8e1976c7462ae368fbf4a600bc571dbaac0baac728, 
            0x1f27463be8dad6fbbbe94b26ad170ff31f0e8bf4a009a07022457cf0e8bccccc,
            0x03f3f628e067520d9a36f714a5ba86cd2dbcae1d37e034b384786de3edb8b557,
            0x1347e3c4dbd373fd1f51129dd4ccf5882f1ecc849b76f4fdfd80f10399accdb9
        ];
        return points;
    }

    function testCheckAnchor() public logs_gas {
        bytes32 sigs = 0x7619e5834eb2b4b13e4964435a32220518a72769897e8e313eb86e0ae69c81d9;
        bytes32 data = 0x0053790d7ab6faebde5fb18ea1a7789c1728b4541e3f2662c29fad40a09d599a;
        bytes32 root = 0x9e88392297bb8724039f7bf8f7be295a8f506e81d9038620107c7ab782a89ed4;
        anchors.file(root, 0); 
        require(nft.checkAnchor(1, data, sigs));
    }
    
    function testMint() public logs_gas {
        // Setting AnchorMock to return a given root
        bytes32 sigs = 0x7619e5834eb2b4b13e4964435a32220518a72769897e8e313eb86e0ae69c81d9;
        bytes32 data = 0x0053790d7ab6faebde5fb18ea1a7789c1728b4541e3f2662c29fad40a09d599a;
        bytes32 root = 0x9e88392297bb8724039f7bf8f7be295a8f506e81d9038620107c7ab782a89ed4;
        anchors.file(root, 0); 
        
        uint rating = 0x0000000000000000000000000000000000000000000000000000000000000064;
        uint amount = 0x0000000000000000000000000000000000000000000000000000000000000140;
        
        nft.mint(address(user1), 1, 1, data, sigs, amount, rating, 1000, getPoints());
        assertEq(address(user1), nft.ownerOf(1));
    }

    function testVerify() public {
        bytes32 data_root = bytes32(uint(0x0053790d7ab6faebde5fb18ea1a7789c1728b4541e3f2662c29fad40a09d599a));
        uint rating = 0x0000000000000000000000000000000000000000000000000000000000000064;
        uint nft_amount = 0x0000000000000000000000000000000000000000000000000000000000000140;
        nft.verify(data_root, nft_amount, rating, getPoints()); 
    }
}
