//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ProductPassport is ERC721URIStorage, Ownable {
    // Variables
    string public productURI;
    address[] public componentsList;
    string public defaultGeoLocation;
    
    // Digital Public Passport variables
    bool public isEuropeanRegulationApplicable;
    // Structs
    struct Batch {
        uint256 tokenId;
        uint256 ammount;
        string origin;
    }

    struct BatchLocations {
        string location;
    }

    // Batch Events  
    event BatchMinted(uint256 amount, uint256 batchNumber);
    event BatchGeoLocationUpdate(uint256 batchID, string geoLocation);
   // Future usecases
    event BurnRequestSent(uint256 amount, address componentAddress);
    event BurnRequestReceived(uint256 amount, address requester);
    // Contract level Events
    event ComponentAdded(address[] component);
    

    // Mapping
    mapping(uint256 => Batch) private _batchIdentificator;
    mapping(uint256 => BatchLocations) private _batchID;

    constructor(
        string memory _productName,
        string memory _productModel,
        string memory _initBaseURI,
        address[] memory _productComponents,
        string memory _defaultGeoLocation

         ) 
         ERC721(_productName, _productModel) Ownable(msg.sender){
            setBaseURI(_initBaseURI);
            addComponent(_productComponents);
            defaultGeoLocation = _defaultGeoLocation;

         }

    function mintBatch(uint256  _ammount, uint256 _batchNumber, string memory _origin) onlyOwner  public  {
        _safeMint(msg.sender, _batchNumber);
        _setTokenURI(_batchNumber, getBaseURL());
        setTokenRecords(_batchNumber, _ammount, _origin);
        updateBatchGeoLocations(_batchNumber, defaultGeoLocation);
        emit BatchMinted(_ammount, _batchNumber);
    }

    function getBaseURL() public view virtual returns (string memory) {
        return productURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        productURI = _newBaseURI;
        
    }

    function setTokenRecords(uint256 _batchNumber, uint256 _ammount, string memory _origin) private {
        _batchIdentificator[_batchNumber] = Batch(_batchNumber, _ammount, _origin);

    }

    function updateBatchGeoLocations(uint256 _batchNumber, string memory geoLocation) private {
        _batchID[_batchNumber] = BatchLocations(geoLocation);
        emit BatchGeoLocationUpdate(_batchNumber,geoLocation);
    }

    function addComponent(address  [] memory componentAddress) public onlyOwner {
        componentsList = componentAddress;
        emit ComponentAdded(componentAddress);
    }

    function getComponents() public view returns( address  [] memory){
    return componentsList;
    }
 
}
