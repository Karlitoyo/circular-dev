    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.20;

    import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
    import "@openzeppelin/contracts/access/Ownable.sol";
    import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
    import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";


    contract ProductPassport is ERC721URIStorage, Ownable, FunctionsClient {
        using FunctionsRequest for FunctionsRequest.Request;
        // Variables
        string public productIPFSCID;
        string public ipfsBaseEndpoint = "https://ipfs.io/ipfs/";
        string public productURI;
        address[] public componentsList;
        string public defaultGeoLocation;
        // Chainlink variables
        bytes32 public s_lastRequestId;
        bytes public s_lastResponse;
        bytes public s_lastError;
        // Events
        error UnexpectedRequestID(bytes32 requestId);
        event Response(bytes32 indexed requestId, bytes response, bytes err);
        event NewGeolocation( uint256 indexed batchID, string geolocation);
        // Regulations variables
        bool public isEuropeanRegulationApplicable;

        // Structs
        struct Batch {
            uint256 tokenId;
            uint256 amount;
            string geoLocation;
            string currentRegulationData;
        }
        struct ChainlinkFunctionsConfig {
            uint64 subscriptionId;
            bytes32 donID;
            string locationAPI;
            string code;
            uint32 gasLimit;
        }

        // Events
        event BatchMinted(uint256 amount, uint256 batchNumber);
        event BatchGeoLocationUpdate(uint256 batchID, string geoLocation);
        event ComponentAdded(address[] component);
        // Chainlink events
        event ChainlinkConfigUpdated(uint256 functionID);
        event OraclePaymentUpdated(uint256 newPayment);
        event OracleRequestFulfilled(uint256 indexed batchID, uint256 indexed requestId);

        // Mapping
        mapping(uint256 => Batch) private _batchIdentifier;
        mapping(uint256 => ChainlinkFunctionsConfig) private _function;


        constructor(
            string memory _productName,
            string memory _productModel,
            string memory _initIPFSCID,
            string memory _defaultGeoLocation,
            address _router
        ) ERC721(_productName, _productModel)
        Ownable(msg.sender)
        FunctionsClient(_router)
        {
            setProductURI(_initIPFSCID);
            productIPFSCID = _initIPFSCID;
            defaultGeoLocation = _defaultGeoLocation;
        }

        function mintBatch(uint256 _amount, uint256 _batchNumber) external onlyOwner {
            _safeMint(msg.sender, _batchNumber);
            _setTokenURI(_batchNumber,getProductURL());
            setTokenRecords(_batchNumber, _amount, defaultGeoLocation,"Initial value");
            emit BatchMinted(_amount, _batchNumber);
        }

        function getBatchsInformation(uint256 _batchNumber) public view returns ( Batch memory _batchDetail) {
            _batchDetail = _batchIdentifier[_batchNumber];
    
        }

        function getProductURL() public view returns (string memory) {
            return productURI;
        }

        function setProductURI(string memory _newIPFSCID) public onlyOwner {
            productURI = string.concat(ipfsBaseEndpoint, _newIPFSCID);
        }

        function setTokenRecords(uint256 _batchNumber, uint256 _amount, string memory _geoLocation, string memory _currentRegulationData) public onlyOwner {
            _batchIdentifier[_batchNumber] = Batch(_batchNumber, _amount, _geoLocation,_currentRegulationData);
        }

        function updateBatchGeoLocations(uint256 _batchNumber, string memory _geoLocation) external onlyOwner {
            _batchIdentifier[_batchNumber].geoLocation = _geoLocation;
            string memory offChainData;
            // Trigger Chainlink API call on location change
            // Application number 1 is the regulationsChecker
            checkLocalRegulation(_geoLocation,1);
            offChainData = string(abi.encodePacked(s_lastResponse));
            _batchIdentifier[_batchNumber].currentRegulationData = offChainData;
        }

        function addComponent(address[] memory componentAddress) public onlyOwner {
            componentsList = componentAddress;
            emit ComponentAdded(componentAddress);
        }

        function getChainlinkFunctionsConfiguration(uint256 _functionID) public view returns (string memory data) {
            
            data = _function[_functionID].code;
            return data;
        }

        function updateChainlinkFunctionsConfiguration(
            uint256 _functionID, 
            uint64 _subscription,
            bytes32  _donID,
            string memory _locationAPI,
            string memory _code,
            uint32  _gasLimit

            ) external onlyOwner {
            _function[_functionID] = ChainlinkFunctionsConfig(
                _subscription,
                _donID,
                _locationAPI,
                _code,
                _gasLimit
                );
            emit ChainlinkConfigUpdated(_functionID);
        }

        function checkLocalRegulation(
            string memory _geolocation,
            uint256  functionIdentificator
            )
        private returns (
            bytes32 requestId
            ) 
            {
            FunctionsRequest.Request memory request;
            request.initializeRequestForInlineJavaScript(_function[functionIdentificator].code);
            string[] memory args = new string[](3);
            args[0] = _function[functionIdentificator].locationAPI;
            args[1] = productIPFSCID;
            args[2] = _geolocation;
            request.setArgs(args);
            s_lastRequestId = _sendRequest(
                request.encodeCBOR(),
                _function[functionIdentificator].subscriptionId,
                _function[functionIdentificator].gasLimit,
                _function[functionIdentificator].donID
            );
            requestId = s_lastRequestId;
        }


        /**
         * @notice Store latest result/error
         * @param requestId The request ID, returned by sendRequest()
         * @param response Aggregated response from the user code
         * @param err Aggregated error from the user code or from the execution pipeline
         * Either response or error parameter will be set, but never both
         */
        function fulfillRequest (
            bytes32 requestId,
            bytes memory response,
            bytes memory err
        ) internal override {
            if (s_lastRequestId != requestId) {
                revert UnexpectedRequestID(requestId);
            }
            s_lastResponse = response;

            s_lastError = err;

            emit Response(requestId, s_lastResponse, s_lastError);
        }

        /**
        * @notice Send a pre-encoded CBOR request
        * @param request CBOR-encoded request data
        * @param subscriptionId Billing ID
        * @param gasLimit The maximum amount of gas the request can consume
        * @param donID ID of the job to be invoked
        * @return requestId The ID of the sent request
        */
        function sendRequestCBOR(
            bytes memory request,
            uint64 subscriptionId,
            uint32 gasLimit,
            bytes32 donID
        ) external onlyOwner returns (bytes32 requestId) {
            s_lastRequestId = _sendRequest(
                request,
                subscriptionId,
                gasLimit,
                donID
            );
            return s_lastRequestId;
            }

    }
