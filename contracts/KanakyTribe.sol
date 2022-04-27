// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { PaymentSplitter } from "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract KanakyTribe is ERC721, PaymentSplitter, ReentrancyGuard, Ownable {
    using Strings for uint256;

    bytes32 public merkleRoot;
    string private baseURI;
    bool private revealed;
    
    uint256 public supplyLive;
    uint256 public supplyReserveMax = 100;
    uint256 public supplyReserveMinted;
    uint256 public supplyLiveMax = 2001;
    address public immutable reserve = 0xA18050f3688Eb81eA134B04ed822126785aC9FE2;

    uint256 startPrivate = 1650913200; // 2022.04.25 17:00:00 GMT
    uint256 startPublic = startPrivate + 1 days;
    uint256 pricePrivate = 100 ether;
    uint256 pricePublic = 150 ether;
    uint256 mintMaxAmtPrivate = 5;
    uint256 mintMaxAmtPublic = 10;
    
    uint256 earnRate = 10 ether; // 10 erc20 tokens earned per day per nft
    address token;
    // key: tokenId, value: timestamp of last token claim
    mapping(uint256 => uint256) private claimDate;

    event MintPrivate(address account, uint256 amount);
    event MintPublic(address account, uint256 amount);
    event MintReserve(uint256 amount);
    event ClaimRewards(address account, uint256 id, uint256 amount);
    event SweepToken(address to, uint256 amount);

    constructor(
        bytes32 merkleRoot_,
        address[] memory shareholders_,
        uint256[] memory shares_
    ) ERC721 ("Kanaky Tribe", "KNKY") PaymentSplitter(shareholders_, shares_) {
        merkleRoot = merkleRoot_;
    }

    function setToken(address _token) external onlyOwner {
        require(token == address(0), "Already set");
        token = _token;
    }

    function setURI(string memory uri) external onlyOwner {
        require(!revealed, "revealed");
        revealed = true;
        baseURI = uri;
    }

    function mintPrivate(
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint256 index
    ) external payable nonReentrant {
        require(block.timestamp >= startPrivate, "Too soon");
        require(block.timestamp <= startPublic, "Too late");
        require(amount > 0, "Amount cannot be 0");
        require(amount <= mintMaxAmtPrivate, "Cannot mint > 5");
        require(amount + supplyLive < supplyLiveMax, "Exceeds max supply");
        bytes32 node = keccak256(abi.encodePacked(index, msg.sender, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "Invalid proof");

        uint256 mintCost = pricePrivate * amount;
        require(msg.value >= mintCost, "Not enough paid");
        if (msg.value > mintCost) { // Refund
            Address.sendValue(payable(msg.sender), msg.value - mintCost);
        }

        _mintAmountTo(amount, msg.sender);
        emit MintPrivate(msg.sender, amount);
    }


    function mintPublic(
        uint256 amount
    ) external payable nonReentrant {
        require(block.timestamp > startPublic, "Too soon");
        require(amount > 0, "Amount cannot be 0");
        require(amount <= mintMaxAmtPublic, "Cannot mint > 10");
        require(amount + supplyLive <= supplyLiveMax, "Exceeds max supply");

        uint256 mintCost = pricePublic * amount;
        require(msg.value >= mintCost, "Not enough paid");
        if (msg.value > mintCost) { // Refund
            Address.sendValue(payable(msg.sender), msg.value - mintCost);
        }

        _mintAmountTo(amount, msg.sender);
        emit MintPublic(msg.sender, amount);
    }


    function mintReserve(
        uint256 amount
    ) external nonReentrant {
        require(msg.sender == reserve, "!reserve");
        require(amount > 0, "Amount cannot be 0");
        require(amount + supplyLive <= supplyLiveMax, "Exceeds max supply");
        require(amount + supplyReserveMinted < supplyReserveMax, "Exceeds reserve allowance");
        
        supplyReserveMinted += amount;
        _mintAmountTo(amount, reserve);
        emit MintReserve(amount);
    }

    function claimRewards(uint256 id) external nonReentrant {
        require(id != 0 && id <= supplyLive, "invalid id");
        require(msg.sender == ownerOf(id), "!owner");
        uint256 earned = tokensClaimable(id);
        require(earned > 0, "No tokens earned");

        claimDate[id] = block.timestamp;
        IERC20(token).transfer(msg.sender, earned);

        emit ClaimRewards(msg.sender, id, earned);
    }

    function sweepToken(uint256 amount, address to, bool max) external onlyOwner {
        if (max) amount = IERC20(token).balanceOf(address(this));
        require(amount > 0, "Nothing to transfer");
        IERC20(token).transfer(to, amount);
        emit SweepToken(to, amount);
    }

    function _mintAmountTo(uint256 amount, address to) private {
        for (uint256 i=0; i< amount; i++) {
            _safeMint(to, ++supplyLive);
            claimDate[supplyLive] = block.timestamp;
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(tokenId != 0 && tokenId <= supplyLive, "invalid tokenId");
        return !revealed 
            ? "https://kanakytribe.mypinata.cloud/ipfs/QmXhrRxZpXsbMtNGpnvfTXTDhQ8eAirxpHZAFdmHytUZwJ/hidden.json"
            : string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    function tokensClaimable(uint256 id) public view returns (uint256 earned) {
        uint256 dayDelta = (block.timestamp - claimDate[id]) / 1 days;
        earned = dayDelta * earnRate;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

}
