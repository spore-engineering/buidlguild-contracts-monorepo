// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CoderHeads is ERC721, EIP712, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => string) private _tokenURIs;

    uint256 public totalAmount = 100;
    uint256 public buidlguidlFee = 0.01 ether;
    uint256 public baezaFee = 0.01 ether;

    uint256 public price = buidlguidlFee+baezaFee;

    // 50% funds royalties go to buidlguidl.eth
    address payable public constant buidlguidl = payable(0xa81a6a910FeD20374361B35C451a4a44F86CeD46);

    // 50% funds go to baeza.eth
    address payable public constant baeza = payable(0xaEeaA55ED4f7df9E4C5688011cEd1E2A1b696772);

    constructor() ERC721("Buidlguild Coderheads", "BCH") EIP712("Buidlguild Coderheads", "1") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function safeMint(string memory uri) public payable returns (uint256) {
        require(_tokenIdCounter.current() < totalAmount, "DONE MINTING");
        require(msg.value == price, "YOU SHOULD SEND 0.02 ETH");

        (bool successBuidlguild, ) = buidlguidl.call{value: buidlguidlFee}("");
        require(successBuidlguild, "could not send buidlguidl share");

        (bool successBaeza, ) = baeza.call{value: baezaFee}("");
        require(successBaeza, "could not send baeza share");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        return tokenId;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }

        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner () {
        _setTokenURI(tokenId, _tokenURI);
    } 
}
