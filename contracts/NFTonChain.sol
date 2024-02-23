// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract OnChainNFT is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => uint256) public tokenIdToLevels;

    constructor() ERC721("OnChainNFT", "OCN") {}

    function simplifiedFormatTokenURI(string memory imageURI)
        public
        pure
        returns (string memory)
    {
        string memory baseURL = "data:application/json;base64,";
        string memory json = string(
            abi.encodePacked(
                '{"name": "LCM ON-CHAINED", "description": "A simple SVG based on-chain NFT", "image":"',
                imageURI,
                '"}'
            )
        );
        string memory jsonBase64Encoded = Base64.encode(bytes(json));
        return string(abi.encodePacked(baseURL, jsonBase64Encoded));
    }

    function mint(string memory imageURI) public {
        /* Encode the SVG to a Base64 string and then generate the tokenURI */
        // string memory imageURI = svgToImageURI(svg);
        string memory tokenURI = simplifiedFormatTokenURI(imageURI);

        /* Increment the token id everytime we call the mint function */
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        /* Mint the token id and set the token URI */
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
    }
}