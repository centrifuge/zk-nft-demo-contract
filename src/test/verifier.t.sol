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
import "../verifier.sol";


contract VerifierTest is DSTest  {
    Verifier verifier;
    address  self;

    function setUp() public {
        self = address(this);
        verifier = new Verifier();
    }

    function testVerify() public logs_gas {
        uint[2] memory a = [
            0x1b19dea8ba4e3c1643eb67a42667fd3cc50a189f54977e2f8ab0beee332b2a38,      
            0x04316b0283e31e05ca8f49baae7f1a4d52c2d2dcfacad1edb17c290a33a9cbef
            ];

        uint[2][2] memory b = [
            [
                0x269d4617a373ec216e4e730597f3924cb2e96f798f15a5a7421ebb77fb5c7012, 
                0x26e6e0ed9573550db84449bd105d2739cc3ed7c91f1982d825095fde1209c0e8
            ], [
                0x2068e2f7f8638cd53df08e8e1976c7462ae368fbf4a600bc571dbaac0baac728, 
                0x1f27463be8dad6fbbbe94b26ad170ff31f0e8bf4a009a07022457cf0e8bccccc
            ]];
        uint[2] memory c = [
            0x03f3f628e067520d9a36f714a5ba86cd2dbcae1d37e034b384786de3edb8b557,
            0x1347e3c4dbd373fd1f51129dd4ccf5882f1ecc849b76f4fdfd80f10399accdb9
            ];

        uint256[7] memory input;
        input[0] = 0x00000000000000000000000000000000058653f1572ef609a6576b89be3271f0;
        input[1] = 0x00000000000000000000000000000000f3e2d80669953c6f9cd2172a63bd5bac;
        input[2] = 0x0000000000000000000000000000000000000000000000000000000000000064;
        input[3] = 0x0000000000000000000000000000000000000000000000000000000000000140;
        input[4] = 0x000000000000000000000000000000000053790d7ab6faebde5fb18ea1a7789c;
        input[5] = 0x000000000000000000000000000000001728b4541e3f2662c29fad40a09d599a;
        input[6] = 0x0000000000000000000000000000000000000000000000000000000000000001;
        require(verifier.verify(a, b, c, input));
    }
}
