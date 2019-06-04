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
    }

    function testMint() public logs_gas {
        bytes32 signatures = 0x363d7ba02d8bd6af6586ae794d5ab1be9d1b281281df901f16a50aa7ef015c4a;
        bytes32 data_root = 0xc7cf649fb3c4b262c280cc013d2a0189673ad3adc59af680eecae3238192df8e;
        bytes32 root_hash = 0xde27f9ff25eedf37ac5fa789e297f950956a5787605d7dbf31e6aa832af75d13;
        anchors.file(root_hash, 0); 
        nft = new ZKNFT("test", "TEST", address(anchors));
        nft.mint(address(user1), 1, 1, data_root, signatures, 100, "chf", 10, 1000);
    }
}
