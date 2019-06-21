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
        nft.file("ratings", bytes32(uint(0x58653f1572ef609a6576b89be3271f0f3e2d80669953c6f9cd2172a63bd5bac)));
    }

    function getPoints() public returns (uint[8] memory) {
        uint[8] memory points = [
            0x17ff636d393ad540520e3babdedb27bd097b2fa2c33503a87f5f06e364da520e, 
            0x26c43a5974be69877a806b64c8e8f7289b8e3226ed3fb0469d3d053a3f75b6e3,
            0x0c77ac3e60830538356f581fa34c22b1a1eb2f8aa250e822eb7508b63371e0e7,
            0x078a7eabdfc327beec7600720b03c222bdf136862866df7457bd70a994898e19,
            0x02e856713cd5f4c1c912ee26369a97dca2fe4050e30051e4d4ebc7a60c3a6a0b,   
            0x30518dbe4ad00edd19fc2a1e94fdea3d0c915f5d1353904b12b5e250631c04c3,
            0x050b1558f013eb51e27211379b51c17394e9472805d9cdaf1678fca9ad969138,
            0x06c3911a0bbdc014fe2bc7995015799f5a814b1fd951bc6a507f533b552aebca
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
        //nft.file("ratings", 0x58653f1572ef609a6576b89be3271f0f3e2d80669953c6f9cd2172a63bd5bac);
        bytes32 data_root = 0xc727cb3a59edcff5ab05ab8ab84fbf553c13d03ee99119aa4d1005cf4a4bcf6d;
        
        // Setting AnchorMock to return a given root
        bytes32 sigs = 0xf29c33aee95eb75f20bb98e52ebc7497f28dc5e114c55bb8abefdbc839218378;
        bytes32 root = 0x3599531e7357cd3c415736d9d6a854e143868dcdc16ca5663739b67569747515;
        anchors.file(root, 0); 
        
        uint rating = 0x0000000000000000000000000000000000000000000000000000000000000064;
        uint amount = 0x0000000000000000000000000000000000000000000000000000000000000140;
        
        nft.mint(address(user1), 1, 1, data_root, sigs, amount, rating, getPoints());
        assertEq(address(user1), nft.ownerOf(1));
    }
}
