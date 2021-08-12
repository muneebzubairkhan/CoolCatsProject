// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CoolCats is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string _baseTokenURI;
    uint256 private _reserved = 100;
    uint256 private _price = 0.06 ether;
    bool public _paused = true;

    // withdraw addresses
    address t1 = 0xfc86A64a8DE22CF25410F7601AcBd8d6630Da93D;
    address t2 = 0x4265de963cdd60629d03FEE2cd3285e6d5ff6015;
    address t3 = 0x1b33EBa79c4DD7243E5a3456fc497b930Db054b2;
    address t4 = 0x92d79ccaCE3FC606845f3A66c9AeD75d8e5487A9;

    // Cool Cats are so cool they dont need a lots of complicated code :)
    // 9999 cats in total, cos cats have 9 lives
    constructor(string memory baseURI) ERC721("Cool Cats", "COOL") {
        setBaseURI(baseURI);

        // team gets the first 4 cats
        _safeMint(t1, 0);
        _safeMint(t2, 1);
        _safeMint(t3, 2);
        _safeMint(t4, 3);
    }

    function adopt(uint256 numOfCatsToGenerate) public payable {
        uint256 supply = totalSupply();
        require(!_paused, "Sale paused");
        require(numOfCatsToGenerate < 21, "You can adopt a maximum of 20 Cats");
        require(
            supply + numOfCatsToGenerate < 10000 - _reserved, // keeping the total supply of cats
            "Exceeds maximum Cats supply" // less than 10,000
        );
        // msg.value = how many eth you send to this contract's function
        // proper amount of eth have been sent or not
        require(
            msg.value >= _price * numOfCatsToGenerate,
            "Ether sent is not correct"
        );

        for (uint256 i = 0; i < numOfCatsToGenerate; i++) {
            uint256 catId = supply + i; // if last cat was id 4 
            _safeMint(msg.sender, catId); // next cat will be id 5 and so on...
        }
        // cat0, cat1, cat2, ...
        // image1 , image2, image3, ...
        // assignImg(cat0)
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    // Just in case Eth does some crazy stuff
    function setPrice(uint256 _newPrice) public onlyOwner {
        _price = _newPrice;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function getPrice() public view returns (uint256) {
        return _price;
    }

    function giveAway(address _to, uint256 _amount) external onlyOwner {
        require(_amount <= _reserved, "Exceeds reserved Cat supply");

        uint256 supply = totalSupply();
        for (uint256 i; i < _amount; i++) {
            _safeMint(_to, supply + i);
        }

        _reserved -= _amount;
    }

    function pause(bool val) public onlyOwner {
        _paused = val; // its a simple variable used to pause or resume the sales
    }

    function withdrawAll() public payable onlyOwner {
        uint256 _each = address(this).balance / 4;
        require(payable(t1).send(_each)); // send eth stored in contract will
        require(payable(t2).send(_each)); // be sent to t1, t2, t3, t4 etc.
        require(payable(t3).send(_each));
        require(payable(t4).send(_each));
    }
}
