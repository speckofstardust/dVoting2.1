// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.9.0;

contract Election {
    address public admin;
    uint256 public candidateCount;
    uint256 public voterCount;
    bool public start;
    bool public end;

    // Improved access control with role-based flexibility
    mapping(address => bool) public admins;
    mapping(address => bool) public moderators;

    constructor() public {
        admin = msg.sender;
        admins[admin] = true;
        candidateCount = 0;
        voterCount = 0;
        start = false;
        end = false;
    }

    function getAdmin() public view returns (address) {
        // Returns account address used to deploy contract (i.e. admin)
        return admin;
    }

    function getModerator(address _moderator) public view returns (bool) {
        return moderators[_moderator];
    }
    
    // Modifier for admin-only access
    modifier onlyAdmin() {
        require(admins[msg.sender] == true, "Not an admin");
        _;
    }

    // Modifier for moderator or admin access
    modifier onlyModeratorOrAdmin() {
        require(admins[msg.sender] == true || moderators[msg.sender] == true, "Not a moderator or admin");
        _;
    }
    // Adding a moderator
    function addModerator(address _moderator) public onlyAdmin {
        moderators[_moderator] = true;
    }

    // Events for transparency
    event ElectionStarted();
    event ElectionEnded();
    event CandidateAdded(uint256 candidateId, string header, string slogan);
    event VoterRegistered(address voterAddress, bytes32 voterHash);
    event VoteCasted(uint256 candidateId, address voterAddress);
    event VoterVerified(address voterAddress, bool verified);

    // Adding an admin
    function addAdmin(address _admin) public onlyAdmin {
        admins[_admin] = true;
    }

    // Modeling a candidate
    struct Candidate {
        uint256 candidateId;
        string header;
        string slogan;
        uint256 voteCount;
    }

    mapping(uint256 => Candidate) public candidateDetails;

    // Adding a candidate with uniqueness check
    function addCandidate(string memory _header, string memory _slogan) public onlyAdmin {
        for (uint256 i = 0; i < candidateCount; i++) {
            require(
                keccak256(abi.encodePacked(candidateDetails[i].header)) != keccak256(abi.encodePacked(_header)),
                "Candidate already exists"
            );
        }
        Candidate memory newCandidate = Candidate({
            candidateId: candidateCount,
            header: _header,
            slogan: _slogan,
            voteCount: 0
        });
        candidateDetails[candidateCount] = newCandidate;
        emit CandidateAdded(candidateCount, _header, _slogan);
        candidateCount += 1;
    }

    // Election Details
    struct ElectionDetails {
        string adminName;
        string adminEmail;
        string adminTitle;
        string electionTitle;
        string organizationTitle;
    }

    ElectionDetails public electionDetails;

    function setElectionDetails(
        string memory _adminName,
        string memory _adminEmail,
        string memory _adminTitle,
        string memory _electionTitle,
        string memory _organizationTitle
    ) public onlyAdmin {
        electionDetails = ElectionDetails(
            _adminName,
            _adminEmail,
            _adminTitle,
            _electionTitle,
            _organizationTitle
        );
        start = true;
        end = false;
        emit ElectionStarted();
    }

    //get election details
    function getElectionDetails()
        public
        view
        returns (
            string memory adminName,
            string memory adminEmail,
            string memory adminTitle,
            string memory electionTitle,
            string memory organizationTitle
        )
    {
        return (
            electionDetails.adminName,
            electionDetails.adminEmail,
            electionDetails.adminTitle,
            electionDetails.electionTitle,
            electionDetails.organizationTitle
        );
    }

    // End election with an event
    function endElection() public onlyAdmin {
        require(start == true, "Election has not started");
        require(end == false, "Election has already ended");
        end = true;
        start = false;
        emit ElectionEnded();
    }

    // Modeling a voter with hashed details for privacy
    struct Voter {
        address voterAddress;
        bytes32 voterHash; // Storing hashed info (name and aadhar)
        bool isVerified;
        bool hasVoted;
        bool isRegistered;
    }

    address[] public voters; // Array to store voter addresses
    mapping(address => Voter) public voterDetails;

    // Register as voter with hashed information for privacy
    function registerAsVoter(string memory _name, string memory _aadhar) public {
        bytes32 voterHash = keccak256(abi.encodePacked(_name, _aadhar));
        Voter memory newVoter = Voter({
            voterAddress: msg.sender,
            voterHash: voterHash,
            isVerified: false,
            hasVoted: false,
            isRegistered: true
        });
        voterDetails[msg.sender] = newVoter;
        voters.push(msg.sender);
        voterCount += 1;
        emit VoterRegistered(msg.sender, voterHash);
    }

    // Verify voter by admin with event logging
    function verifyVoter(address _voterAddress, bool _verifiedStatus) public onlyModeratorOrAdmin {
        require(voterDetails[_voterAddress].isRegistered, "Voter is not registered");
        voterDetails[_voterAddress].isVerified = _verifiedStatus;
        emit VoterVerified(_voterAddress, _verifiedStatus);
    }

    // Voting with checks
    function vote(uint256 _candidateId) public {
        //admins and moderators need to vote with a voter account
        require(!admins[msg.sender], "Admin cannot vote");
        require(!moderators[msg.sender], "Moderator cannot vote");
        
        require(voterDetails[msg.sender].isRegistered, "Voter is not registered");
        require(voterDetails[msg.sender].isVerified, "Voter is not verified");
        require(!voterDetails[msg.sender].hasVoted, "Voter has already voted");
        require(start == true, "Election is not active");
        require(end == false, "Election has ended");
        require(_candidateId < candidateCount, "Invalid candidate ID");

        candidateDetails[_candidateId].voteCount += 1;
        voterDetails[msg.sender].hasVoted = true;
        emit VoteCasted(_candidateId, msg.sender);
    }

    // Get candidate with the highest votes (for election result retrieval)
    function getWinningCandidate() public view returns (uint256 candidateId, string memory header, uint256 voteCount) {
        uint256 highestVoteCount = 0;
        uint256 winningCandidateId = 0;
        for (uint256 i = 0; i < candidateCount; i++) {
            if (candidateDetails[i].voteCount > highestVoteCount) {
                highestVoteCount = candidateDetails[i].voteCount;
                winningCandidateId = i;
            }
        }
        Candidate memory winningCandidate = candidateDetails[winningCandidateId];
        return (winningCandidateId, winningCandidate.header, winningCandidate.voteCount);
    }
}
