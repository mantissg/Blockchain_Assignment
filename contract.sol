// SPDX-License-Identifier: Crypto-Kings
pragma solidity >=0.7.0 <0.9.0;

// IMPORT DateTime FROM ROLLAPROJECT //
import "https://github.com/RollaProject/solidity-datetime/blob/master/contracts/DateTimeContract.sol";

// IMPORT Strings Util FROM OPENZEPPELIN //
import "@openzeppelin/contracts/utils/Strings.sol";

contract Campaign
{
    // VOTER STRUCT //
    struct Voter
    {
        address voterAddress;
        uint indexOfVote;
        uint assignedVote; //## changed order of struct to keep data types together i.e. cheaper storage
        bool voted;
    }

    // CAMPAIGN ITEMS STRUCT //
    struct CampaignItems
    {
        string itemName;
        uint votecount;
    }

    // GLOBAL VARIABLES //
    string campaignName;
    address public contractOwner;
    uint public campaignCloseDate;
    uint public plusFiveYrs = (block.timestamp + 5 * 365 days);

    mapping(address => Voter) public voters;

    CampaignItems[] public vote_options;

    // MODIFIER FOR ONLY OWNER //
    modifier onlyOwner() 
    {
        require(msg.sender == contractOwner, "Only the owner of the contract can run this function!");
        _;
    }

    // KILL CONTRACT FUNCTION //

    // CONTRACT ROLLBACK FUNCTION - Gas limitation//

    // CONTRCUTOR FOR THE CONTRACT - SETS OWNER & CREATES A BALLOT WITH VOTING OPTIONS //
    constructor(string memory _campaignName, string[] memory _itemNames, uint _year, uint _month, uint _day, uint _hours, uint _minutes, uint _seconds)
    {
        contractOwner = msg.sender;
        
        campaignCloseDate = DateTime.timestampFromDateTime(_year, _month, _day, _hours, _minutes, _seconds);

        // Require campaignCloseDate is in the future //
        require(
                campaignCloseDate > block.timestamp,
                "Campaign must close in the future."
        );

        // Require campaignCloseDate to be wihin a reasonable time frame  i.e. 5 years //
        require(
                campaignCloseDate < plusFiveYrs,
                "A campaign window cannot be open for more than 5 years from now."
        );

        // (year, month, day, hour, minute, second) = DateTime.timestampToDateTime(campaignCloseDate);
        campaignName = _campaignName;

        for(uint i = 0; i < _itemNames.length; i++)
        {
            vote_options.push(CampaignItems({
                itemName: _itemNames[i],
                votecount: 0
            }));
        }
    }

    // ENABLE A VOTER TO VOTE WITHIN THIS CONTRACT //
    function enableVoter(address _votersAddress) public onlyOwner
    {
        require(
            (msg.sender == contractOwner) && (voters[_votersAddress].assignedVote == 0) && !voters[_votersAddress].voted
        );

        voters[_votersAddress].assignedVote = 1;
    } 

    // ALLOWS A USER TO VOTE IF THEY HAVE ENOUGH VOTE POINTS AND HAVE NOT VOTED ALREADY//
    function vote(uint _voteIndex) public
    {
        require(
            voters[msg.sender].assignedVote == 1,
            "You have not be allowed to vote! Please contact the contracts owner."
        );

        require(
            !voters[msg.sender].voted,
            "You have already voted!"
        );

        // REQUIRE VOTING WINDOW TO STILL BE OPEN //
        require(
            block.timestamp <= campaignCloseDate,
            "Voting has closed."
        );

        voters[msg.sender].voted = true;
        voters[msg.sender].indexOfVote = _voteIndex;
        vote_options[_voteIndex].votecount += voters[msg.sender].assignedVote;
        voters[msg.sender].assignedVote = 0; 
    }

    function resetVote() public 
    {
        require(
            voters[msg.sender].voted == true,
            "You have not voted yet."
        );

        // REQUIRE VOTING WINDOW TO STILL BE OPEN //
        require(
            block.timestamp <= campaignCloseDate,
            "Voting has closed."
        );
            
        voters[msg.sender].voted = false;
        uint index = voters[msg.sender].indexOfVote;
        voters[msg.sender].indexOfVote = 0;
        vote_options[index].votecount -= 1;
        voters[msg.sender].assignedVote = 1;
    }

    // RETURNS THE AMOUNT OF TIME REMAINING IN VOTING WINDOW //
    function timeRemaining() public view returns (string memory strTimeRemaining){

       uint timeRemainingUnix = campaignCloseDate - block.timestamp;
       uint secondsRemaining = timeRemainingUnix % 60;
       uint minutesRemaining = (timeRemainingUnix % 3600) / 60;
       uint hoursRemaining = (timeRemainingUnix % 86400) / 3600;
       uint daysRemaining = timeRemainingUnix / 86400;

       string memory s = Strings.toString(secondsRemaining);
       string memory m = Strings.toString(minutesRemaining);
       string memory h = Strings.toString(hoursRemaining);
       string memory d = Strings.toString(daysRemaining);

       strTimeRemaining = string.concat("Voting closes in: ",d," Days, ", h, " Hours, ", m," Minutes, ", s, " Seconds."); //Strings.toString(daysRemaining) + Strings.toString(hoursRemaining);
    }

    function currentScores() public{
        // returns current score of the voting campaign//
    }

    function winner() public view returns(uint winningItem)
    {
        //require(
            //require that the time has ended and only owner can see the results//
        //);
        
        uint i;
        uint winnerCount = 0;
            for(i=0; i < vote_options.length; i++)
            {
                if (vote_options[i].votecount > winnerCount)
                {
                    winnerCount = vote_options[i].votecount;
                    winningItem = i;
                }
            }
    }


    //     Task 2.1 (b) Design a blockchain based voting application. The application should meet the following requirements (30%)
    // -	Allows user to setup a voting campaign.                                                                                     /--DONE--\
    // -	Allows users to vote on the campaignItem.                                                                                   /--DONE--\
    // -	Only allow one vote per user.                                                                                               /--DONE--\
    // -	User can cast / change their vote as many times as they wish, until the cut-off time.                                       /--DONE--\
    // -	Allow to calculate the dynamic results of the campaign and lock final results once the campaign has concluded.              /--SEMI COMPLETE--\

    // **Ethereum Alarm Clock protocol to commit to storage and lock final results**

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


        //function that takes voter address finds the voters indexofvote, -1 from campaign item, resets voter to voted=false and assignedvote =1 from 0

        //function to see the the campaignitems in order of 1st to last

        //function to identify the winner item

        //function to rollback/failover

        //function to kill contract
}
