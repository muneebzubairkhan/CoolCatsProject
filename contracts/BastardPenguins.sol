// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// CoolCars

/**
 * @title CoolCars contract
 * @dev Extends ERC721 Non-Fungible Token Standard basic implementation
 */
contract CoolCars is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string public BP_PROVENANCE = "";

    string public baseURI = "";

    uint256 public startingIndexBlock;

    uint256 public startingIndex;

    uint256 public constant carPrice = 0.02 ether; // same as 0.02 * 1e18

    uint256 public constant maxCarPurchase = 20;

    uint256 public MAX_CARS;

    bool public saleIsActive = false;

    uint256 public REVEAL_TIMESTAMP;

    bool public identityRevealed = false;

    constructor(
        string memory name,
        string memory symbol,
        uint256 maxNftSupply,
        uint256 saleStart,
        string memory _baseURI
    ) ERC721(name, symbol) {
        MAX_CARS = maxNftSupply;
        REVEAL_TIMESTAMP = saleStart + 7 days;
        baseURI = _baseURI;
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
     * Give some cars to friends
     */
    function reserveCars(address _address) public onlyOwner {
        uint256 supply = totalSupply();
        uint256 i;
        for (i = 0; i < 30; i++) {
            _safeMint(_address, supply + i);
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

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
        // _setBaseURI(baseURI);
    }

    function startSale() external onlyOwner {
        saleIsActive = true;
    }

    function stopSale() external onlyOwner {
        saleIsActive = false;
    }

    function revealIdentity() external onlyOwner {
        identityRevealed = true;
    }

    function hideIdentity() external onlyOwner {
        identityRevealed = false;
    }

    // 0,1,2,3,....
    // tokenURI(3000) = ipfs:////QMD/0
    // tokenURI(3000) = ipfs:////QMD/3070

    /**
     * Mints Cool Cars
     */
    function mintCar(uint256 numberOfTokens) public payable {
        require(totalSupply() == MAX_CARS, "We are sold out!");
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

        // 1000          // 100, 000
        // 
        // 4 7 = 77, 

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

    function getId(uint256 _tokenId) public view returns (uint256 tokenId) {
        if (_tokenId + startingIndex < MAX_CARS) tokenId = tokenId;
        else tokenId = uint256(_tokenId + startingIndex) % MAX_CARS;

        return tokenId;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (identityRevealed)
            return
                bytes(baseURI).length > 0
                    ? string(
                        abi.encodePacked(baseURI, getId(tokenId).toString())
                    )
                    : "";
        else
            return
                bytes(baseURI).length > 0
                    ? string(abi.encodePacked(baseURI, "11"))
                    : "";
    }
}
