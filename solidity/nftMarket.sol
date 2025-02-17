// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./baseERC20.sol";

contract NFTMarket {
    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(uint256 => Listing) public listings; // NFT ID -> Listing
    BaseERC20 public token; // 使用的 ERC20 Token
    IERC721 public nft; // NFT 合约

    constructor(BaseERC20 _token, IERC721 _nft) {
        token = _token;
        nft = _nft;
    }

    // 上架 NFT
    function list(uint256 tokenId, uint256 price) external {
        require(nft.ownerOf(tokenId) == msg.sender, "You are not the owner");
        require(price > 0, "Price must be greater than 0");
        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price
        });
    }

    // 购买 NFT
    function buyNFT(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.price > 0, "NFT not listed");
        require(token.balanceOf(msg.sender) >= listing.price, "Insufficient token balance");
        token.transferFrom(msg.sender, listing.seller, listing.price);
        nft.safeTransferFrom(listing.seller, msg.sender, tokenId);
        delete listings[tokenId];
    }
}
