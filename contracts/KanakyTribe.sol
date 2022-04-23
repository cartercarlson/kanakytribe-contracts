// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { PaymentSplitter } from "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract KanakyTribe is ERC721, PaymentSplitter, ReentrancyGuard, Ownable {

    bytes32 private merkleRoot;
    string private baseURI;
    
    uint256 public maxSupply = 2000;
    uint256 public reserveSupply = 100;
    address public immutable reserve = 0xA18050f3688Eb81eA134B04ed822126785aC9FE2;

    constructor(
        bytes32 _merkleRoot,
        address[] memory _shareholders,
        uint256[] memory _shares
    ) ERC721 ("Kanaky Tribe", "KNKY") PaymentSplitter(_shareholders, _shares) {
        merkleRoot = _merkleRoot;
    }

    /// @dev See {ERC721-_baseURI}.
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}