// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

// CoolCars

/**
 * @title CoolCars contract
 * @dev Extends ERC721 Non-Fungible Token Standard basic implementation
 */
contract CoolCars is ERC721Enumerable, Ownable {
    string public BP_PROVENANCE = "";

    uint256 public startingIndexBlock;

    uint256 public startingIndex;

    uint256 public constant carPrice = 0.02 ether; // same as 0.02 * 1e18

    uint256 public constant maxCarPurchase = 20;

    uint256 public MAX_CARS;

    bool public saleIsActive = false;

    uint256 public REVEAL_TIMESTAMP;

    constructor(
        string memory name,
        string memory symbol,
        uint256 maxNftSupply,
        uint256 saleStart
    ) ERC721(name, symbol) {
        MAX_CARS = maxNftSupply;
        REVEAL_TIMESTAMP = saleStart + 7 days;
    }

    // function withdraw() public onlyOwner {
    //     uint256 balance = address(this).balance;
    //     // msg.sender.transfer(balance);
    // }

    /**
     * Set some Cool Cars aside
     */
    function reserveCars() public onlyOwner {
        uint256 supply = totalSupply();
        uint256 i;
        for (i = 0; i < 30; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    /**
     * Owner can change the data on which identity will be revealed for people
     */
    function setRevealTimestamp(uint256 revealTimeStamp) public onlyOwner {
        REVEAL_TIMESTAMP = revealTimeStamp;
    }

    /*
     * Set provenance once it's calculated
     */
    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        BP_PROVENANCE = provenanceHash;
    }

    // function setBaseURI(string memory baseURI) public onlyOwner {
    //     _setBaseURI(baseURI);
    // }

    function stopSale() external onlyOwner {
        saleIsActive = false;
    }

    function startSale() external onlyOwner {
        saleIsActive = true;
    }

    /**
     * Mints Cool Cars
     */
    function mintCar(uint256 numberOfTokens) public payable {
        require(numberOfTokens > 0, "Minimum 1 car NFT need to be minted");
        require(saleIsActive, "Sale must be active to mint Car");
        require(
            numberOfTokens <= maxCarPurchase,
            "Can only mint 20 NFT at a time"
        );
        require(
            totalSupply() + (numberOfTokens) <= MAX_CARS,
            "Purchase would exceed max supply of Cars"
        );
        require(
            carPrice * (numberOfTokens) <= msg.value,
            "Ether value sent is not correct"
        );

        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_CARS) {
                _safeMint(msg.sender, mintIndex);
            }
        }

        // If we haven't set the starting index and this is either 1) the last saleable NFT or 2) the first NFT to be sold after
        // the end of pre-sale, set the starting index block
        if (
            startingIndexBlock == 0 && // if we have not set the startingIndexBlock
            (totalSupply() == MAX_CARS || // all cars are sold out
                block.timestamp >= REVEAL_TIMESTAMP) //
            //                             1000th        >=          1500th
        ) {
            startingIndexBlock = block.number; // Identity is revealed //
        }
    }

    /**
     * Set the starting index for the collection
     */
    function setStartingIndex() public {
        require(startingIndex == 0, "Starting index is already set");
        require(startingIndexBlock != 0, "Starting index block must be set");

        // random() function of cool cars
        // startingIndex === startingIpfsId
        startingIndex = uint256(blockhash(startingIndexBlock)) % MAX_CARS;
        // Just a sanity case in the worst case if this function is called late (EVM only stores last 256 block hashes)
        if (block.number - startingIndexBlock > 255) {
            startingIndex = uint256(blockhash(block.number - 1)) % MAX_CARS;
        }
        // Prevent default sequence
        if (startingIndex == 0) {
            startingIndex = startingIndex + 1;
        }
    }

    function burn(uint256 _tokenId) public {
        require(_exists(_tokenId), "Burn: NFT does not exist.");
        require(
            ownerOf(_tokenId) == _msgSender(),
            "Burn: caller is not NFT owner."
        );
        _burn(_tokenId);
    }

    /**
     * Set the starting index block for the collection, essentially unblocking
     * setting starting index
     */
    function emergencySetStartingIndexBlock() public onlyOwner {
        require(startingIndex == 0, "Starting index is already set");

        startingIndexBlock = block.number;
    }
}
