// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaigns; //creating a mapping to access campaigns[0]..

    uint256 public numberOfCampaigns = 0;

    // avtivity status of the contract
    bool public emergencyMode; // default: false

        // Will be emitted when a main functionality executed
    // (such as: creating/deleting/updating capaigns, and etc.)
    event Action (
        uint256 id,
        string actionType,
        address indexed executor,
        uint256 timestamp
    );

    // Preventing unauthorized entity execute specific function
    modifier privilageEntity(uint _id) {
        _privilagedEntity(_id);
        _;
    }

        // To have an scape way when something bad happened in contract
    modifier notInEmergency() {
        require(!emergencyMode);
        _;
    }

    address private _owner;

    // Constructor to set the initial owner to the contract deployer
    constructor() {
        _owner = msg.sender;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

        function _nullChecker(
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
        ) internal pure {
            require((
                    bytes(_title).length > 0 
                    && bytes(_description).length > 0 
                    && _target > 0 
                    && _deadline > 0 
                    && bytes(_image).length > 0
                ), "Null value not acceptable");
    }

        // Preventing entering null values as campaign details
    modifier notNull(
        string memory title,
        string memory description,
        uint256 target,
        uint256 deadline,
        string memory image) {
            _nullChecker(title, description, target, deadline, image);
            _;
        }

    function createCampaign(address _owner, string memory _title, string memory _description, uint256 _target, uint256 _deadline, string memory _image) public returns (uint256) {

//the storage keyword is built into the Solidity programming language. It is one of 
//the two data location keywords in Solidity, the other being memory. 
//These keywords specify where variables are stored: in the blockchain's 
//persistent storage or in temporary memory.
//Persistent Storage: Variables declared with storage are stored permanently 
//on the blockchain. Any changes made to these variables are recorded in the 
//blockchain's state and persist across function calls and transactions.



        Campaign storage campaign = campaigns[numberOfCampaigns];  //first zero.
        require(campaign.deadline < block.timestamp, "Deadline should be in the future.");
        
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCampaigns++;
        return numberOfCampaigns - 1;


    }

    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        (bool sent,) = payable(campaign.owner).call{value: amount}("");

        if(sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }

/*
memory
Temporary Storage: Variables declared with memory are stored temporarily and exist only for the duration of a function call. They are erased after the function execution is complete.
Cheaper: Using memory is less expensive in terms of gas because it does not involve writing to the blockchain's permanent storage.
Typical Use Case: Parameters passed to functions, local variables within functions, and variables used for temporary computations are often declared with memory.

*/

    function getDonators(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for(uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }

    function deleteCampaign(uint256 _id) external privilageEntity(_id) notInEmergency returns (bool) {
        // to check if a capmpaign with specific id exists.
        require(campaigns[_id].owner > address(0), "No campaign exist with this ID");
        if(campaigns[_id].amountCollected > 0 wei) {
            _refundDonators(_id);
        }
        delete campaigns[_id];

        emit Action (
            _id,
            "Campaign Deleted",
            msg.sender,
            block.timestamp
        );

        numberOfCampaigns -= 1;
        return true;
    }

    function _payTo(address to, uint256 amount) internal returns (bool) {
        (bool success, ) = payable(to).call{value: amount}("");
        require(success);
        return true;
    }

    function _refundDonators(uint _id) internal {
        uint256 donationAmount;
        Campaign storage campaign = campaigns[_id];
        for(uint i; i < campaign.donators.length; i++) {
            donationAmount = campaign.donations[i];
            campaign.donations[i] = 0;
            _payTo(campaign.donators[i], donationAmount);
            // campaign.donations[i] = 0;
        }
        campaign.amountCollected = 0;
    }



    function updateCampaign(
        uint256 _id,
        string memory _title, 
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
         ) external privilageEntity(_id) notNull(_title, _description, _target, _deadline, _image) notInEmergency returns (bool) {
            require(block.timestamp <  _deadline, "Deadline must be in the future");
            
            // Making a pointer for a campaign
            Campaign storage campaign = campaigns[_id];
            require(campaign.owner > address(0), "No campaign exist with this ID");
            require(campaign.amountCollected == 0, "Update error: amount collected");

            campaign.title = _title;
            campaign.description = _description;
            campaign.target = _target;
            campaign.deadline = _deadline;
            campaign.amountCollected = 0;
            campaign.image = _image;

            emit Action (
                _id,
                "Campaign Updated",
                msg.sender,
                block.timestamp
            );
            return true;
    }

  /// @notice Preventing unauthorized entity to execute specific function
    /// @param _id campaign id
    function _privilagedEntity(uint256 _id) internal view {
        require(
            msg.sender == campaigns[_id].owner ||
            msg.sender == owner(),
            "Unauthorized Entity"
        );
    } 


}