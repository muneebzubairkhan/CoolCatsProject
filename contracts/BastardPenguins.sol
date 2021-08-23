// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title BastardPenguins contract
 * @dev Extends ERC721 Non-Fungible Token Standard basic implementation
 */
contract BastardPenguins is ERC721, Ownable {
    string public BP_PROVENANCE = "";

    uint256 public startingIndexBlock;

    uint256 public startingIndex;

    uint256 public constant penguinPrice = 0.02 ether; // same as 0.02 * 1e18

    uint256 public constant maxPenguinPurchase = 20;

    uint256 public MAX_PENGUINS;

    bool public saleIsActive = false;

    uint256 public REVEAL_TIMESTAMP;

    constructor(
        string memory name,
        string memory symbol,
        uint256 maxNftSupply,
        uint256 saleStart
    ) ERC721(name, symbol) {
        MAX_PENGUINS = maxNftSupply;
        REVEAL_TIMESTAMP = saleStart + (86400 * 9);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        msg.sender.transfer(balance);
    }

    /**
     * Set some Bastard Penguins aside
     */
    function reservePenguins() public onlyOwner {
        uint256 supply = totalSupply();
        uint256 i;
        for (i = 0; i < 30; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    /**
     * DM Gargamel in Discord that you're standing right behind him.
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

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    /*
     * Pause sale if active, make active if paused
     */
    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    /**
     * Mints Bastard Penguins
     */
    function mintPenguin(uint256 numberOfTokens) public payable {
        require(saleIsActive, "Sale must be active to mint Penguin");
        require(
            numberOfTokens <= maxPenguinPurchase,
            "Can only mint 20 tokens at a time"
        );
        require(
            totalSupply().add(numberOfTokens) <= MAX_PENGUINS,
            "Purchase would exceed max supply of Penguins"
        );
        require(
            penguinPrice.mul(numberOfTokens) <= msg.value,
            "Ether value sent is not correct"
        );

        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_PENGUINS) {
                _safeMint(msg.sender, mintIndex);
            }
        }

        // If we haven't set the starting index and this is either 1) the last saleable token or 2) the first token to be sold after
        // the end of pre-sale, set the starting index block
        if (
            startingIndexBlock == 0 &&
            (totalSupply() == MAX_PENGUINS || block.timestamp >= REVEAL_TIMESTAMP)
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

        // random() function of bastard penguins
        // startingIndex === startingIpfsId
        startingIndex = uint256(blockhash(startingIndexBlock)) % MAX_PENGUINS;
        // Just a sanity case in the worst case if this function is called late (EVM only stores last 256 block hashes)
        if (block.number.sub(startingIndexBlock) > 255) {
            startingIndex = uint256(blockhash(block.number - 1)) % MAX_PENGUINS;
        }
        // Prevent default sequence
        if (startingIndex == 0) {
            startingIndex = startingIndex.add(1);
        }
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
