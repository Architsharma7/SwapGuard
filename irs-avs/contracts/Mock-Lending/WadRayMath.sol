// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library WadRayMath {
    uint256 internal constant WAD = 1e18;
    uint256 internal constant RAY = 1e27;

    function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * b) / RAY;
    }

    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * RAY) / b;
    }
}
