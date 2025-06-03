// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// File: contracts/utils/Context.sol

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: contracts/utils/Address.sol

library Address {
    function isContract(address account) internal view returns (bool) {
        // Solidity 0.8.xでは .code.length が安全
        return account.code.length > 0;
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        require(success, "Address: low-level call with value failed");

        return returndata;
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.call(data);
        return _verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function _verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: contracts/utils/math/SafeCast.sol

library SafeCast {
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }
}
// File: contracts/interfaces/IERC165.sol

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: contracts/utils/introspection/ERC165.sol

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: contracts/utils/Timers.sol

library Timers {
    struct Timer {
        uint64 _deadline;
    }

    struct Timestamp {
        uint64 _deadline;
    }

    function isPending(Timer memory timer) internal view returns (bool) {
        return timer._deadline > block.timestamp;
    }

    function isExpired(Timer memory timer) internal view returns (bool) {
        return timer._deadline <= block.timestamp;
    }

    function getDeadline(Timestamp memory timer) internal pure returns (uint64) {
        return timer._deadline;
    }

    function setDeadline(Timestamp storage timer, uint64 timestamp) internal {
        timer._deadline = timestamp;
    }

    struct BlockNumber {
        uint64 _deadline;
    }

    function isPending(BlockNumber memory timer) internal view returns (bool) {
        return timer._deadline > block.number;
    }

    function isExpired(BlockNumber memory timer) internal view returns (bool) {
        return timer._deadline <= block.number;
    }

    function getDeadline(BlockNumber memory timer) internal view returns (uint64) {
        return timer._deadline;
    }

    function setDeadline(BlockNumber storage timer, uint64 timestamp) internal {
        timer._deadline = timestamp;
    }
}

// File: contracts/interfaces/IERC6372.sol

interface IERC6372 {
    function clock() external view returns (uint48);

    function CLOCK_MODE() external view returns (string memory);
}

// File: contracts/interfaces/IERC5805.sol

interface IERC5805 is IERC6372, IERC165 {
    function getPastVotes(address account, uint256 timepoint) external view returns (uint256);

    function getPastTotalSupply(uint256 timepoint) external view returns (uint256);
}

// File: contracts/governance/IGovernor.sol

interface IGovernor is IERC165 {
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address => bool) hasVoted;
    }

    function name() external view returns (string memory);
    function version() external view returns (string memory);
    function hashProposal(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) external pure returns (uint256);
    function state(uint256 proposalId) external view returns (ProposalState);
    function proposalDeadline(uint256 proposalId) external view returns (uint256);
    function proposalSnapshot(uint256 proposalId) external view returns (uint256);
    function proposalProposer(uint256 proposalId) external view returns (address);
    function votingDelay() external view returns (uint256);
    function votingPeriod() external view returns (uint256);
    function quorum(uint256 blockNumber) external view returns (uint256);
    function getVotes(address account, uint256 blockNumber) external view returns (uint256);
    function getVotesWithParams(address account, uint256 blockNumber, bytes memory params) external view returns (uint256);
    function hasVoted(uint256 proposalId, address account) external view returns (bool);
    function COUNTING_MODE() external pure returns (string memory);

    function castVote(uint256 proposalId, uint8 support) external returns (uint256);
    function castVoteWithReason(uint256 proposalId, uint8 support, string calldata reason) external returns (uint256);
    function castVoteWithReasonAndParams(uint256 proposalId, uint8 support, string calldata reason, bytes calldata params) external returns (uint256);
    function castVoteBySig(uint256 proposalId, uint8 support, uint8 v, bytes32 r, bytes32 s) external returns (uint256);
    function castVoteWithReasonAndParamsBySig(uint256 proposalId, uint8 support, string calldata reason, bytes calldata params, uint8 v, bytes32 r, bytes32 s) external returns (uint256);

    function execute(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) external payable returns (uint256);
    function queue(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) external returns (uint256);
    function cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) external returns (uint256);
    function relay(address target, uint256 value, bytes calldata data) external;

    function CLOCK_MODE() external view returns (string memory);
    function clock() external view returns (uint48);
}

// File: contracts/governance/Governor.sol

using Address for address;
abstract contract Governor is Context, ERC165, IGovernor {
    using SafeCast for uint256;
    using Timers for Timers.BlockNumber;
    using Address for address;

    event ProposalCreated(
        uint256 indexed proposalId,
        address proposer,
        address[] targets,
        uint256[] values,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );

    event ProposalExecuted(uint256 proposalId);
    event ProposalQueued(uint256 proposalId);
    event ProposalCanceled(uint256 proposalId);

    string private _name;
    uint256 private _proposalsCounter;

    struct ProposalCore {
        address proposer;
        Timers.BlockNumber voteStart;
        Timers.BlockNumber voteEnd;
        bool executed;
        bool canceled;
    }

    mapping(uint256 => ProposalCore) private _proposals;

    constructor(string memory name_) {
        _name = name_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return interfaceId == type(IGovernor).interfaceId || super.supportsInterface(interfaceId);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function version() public view virtual override returns (string memory) {
        return "1";
    }

    function COUNTING_MODE() public pure virtual override returns (string memory) {
        return "support=bravo&quorum=for,abstain";
    }

    function hashProposal(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public pure virtual override returns (uint256) {
        return uint256(keccak256(abi.encode(targets, values, calldatas, descriptionHash)));
    }

    function state(uint256 proposalId) public view virtual override returns (ProposalState) {
        ProposalCore storage proposal = _proposals[proposalId];

        if (proposal.executed) return ProposalState.Executed;
        if (proposal.canceled) return ProposalState.Canceled;

        uint256 snapshot = proposal.voteStart.getDeadline();
        if (snapshot == 0) revert("Governor: unknown proposal id");

        if (block.number <= snapshot) return ProposalState.Pending;

        uint256 deadline = proposal.voteEnd.getDeadline();
        if (block.number <= deadline) return ProposalState.Active;

        return (_quorumReached(proposalId) && _voteSucceeded(proposalId))
            ? ProposalState.Succeeded
            : ProposalState.Defeated;
    }

    function proposalSnapshot(uint256 proposalId) public view virtual override returns (uint256) {
        return _proposals[proposalId].voteStart.getDeadline();
    }

    function proposalDeadline(uint256 proposalId) public view virtual override returns (uint256) {
        return _proposals[proposalId].voteEnd.getDeadline();
    }

    function proposalProposer(uint256 proposalId) public view virtual override returns (address) {
        return _proposals[proposalId].proposer;
    }

    /// @notice Base placeholder for proposalThreshold()
    /// @dev This is overridden in GovernorSettings
    function proposalThreshold() public view virtual returns (uint256) {
        return 0;
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public virtual returns (uint256) {
        require(
            getVotes(msg.sender, block.number - 1) >= proposalThreshold(),
            "Governor: proposer votes below threshold"
        );

        uint256 proposalId = hashProposal(targets, values, calldatas, keccak256(bytes(description)));

        require(
            _proposals[proposalId].voteStart.getDeadline() == 0,
            "Governor: proposal already exists"
        );

        uint64 snapshot = block.number.toUint64() + votingDelay().toUint64();
        uint64 deadline = snapshot + votingPeriod().toUint64();

        _proposals[proposalId].proposer = msg.sender;
        _proposals[proposalId].voteStart.setDeadline(snapshot);
        _proposals[proposalId].voteEnd.setDeadline(deadline);

        emit ProposalCreated(proposalId, msg.sender, targets, values, calldatas, snapshot, deadline, description);
        return proposalId;
    }

    function _quorumReached(uint256 proposalId) internal view virtual returns (bool);
    function _voteSucceeded(uint256 proposalId) internal view virtual returns (bool);

    function votingDelay() public view virtual override returns (uint256);
    function votingPeriod() public view virtual override returns (uint256);

    function quorum(uint256 blockNumber) public view virtual override returns (uint256);

    function getVotesWithParams(address account, uint256 blockNumber, bytes memory)
        public
        view
        virtual
        override
        returns (uint256);

    function getVotes(address account, uint256 blockNumber)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return getVotesWithParams(account, blockNumber, "");
    }

    function hasVoted(uint256 proposalId, address account)
        public
        view
        virtual
        override
        returns (bool)
    {
        revert("Governor: hasVoted not implemented");
    }

    function relay(address target, uint256 value, bytes calldata data) external virtual override {
        require(_executor() == msg.sender, "Governor: only executor can relay");
        target.functionCallWithValue(data, value);
    }

    function _executor() internal view virtual returns (address);

    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public payable virtual override returns (uint256 proposalId) {
        proposalId = hashProposal(targets, values, calldatas, descriptionHash);
        require(
            state(proposalId) == ProposalState.Succeeded || proposalNeedsQueuing(proposalId),
            "Governor: proposal not successful"
        );
        _executeOperations(proposalId, targets, values, calldatas, descriptionHash);
        _proposals[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }

    function queue(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public virtual override returns (uint256 proposalId) {
        proposalId = hashProposal(targets, values, calldatas, descriptionHash);
        require(state(proposalId) == ProposalState.Succeeded, "Governor: proposal not successful");
        _queueOperations(proposalId, targets, values, calldatas, descriptionHash);
        emit ProposalQueued(proposalId);
    }

    function cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public virtual override returns (uint256 proposalId) {
        proposalId = _cancel(targets, values, calldatas, descriptionHash);
        _proposals[proposalId].canceled = true;
        emit ProposalCanceled(proposalId);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual returns (uint256);

    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual returns (uint48);

    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual;

    function proposalNeedsQueuing(uint256 proposalId)
        public
        view
        virtual
        returns (bool);

    function CLOCK_MODE() public view virtual override returns (string memory) {
        return "mode=blocknumber&from=default";
    }

    function clock() public view virtual override returns (uint48) {
        return uint48(block.number);
    }
}

// File: contracts/governance/extensions/GovernorSettings.sol

abstract contract GovernorSettings is Governor {
    uint256 private _votingDelay;
    uint256 private _votingPeriod;
    uint256 private _proposalThreshold;

    constructor(uint256 initialVotingDelay, uint256 initialVotingPeriod, uint256 initialProposalThreshold) {
        _setVotingDelay(initialVotingDelay);
        _setVotingPeriod(initialVotingPeriod);
        _setProposalThreshold(initialProposalThreshold);
    }

    function votingDelay() public view virtual override returns (uint256) {
        return _votingDelay;
    }

    function votingPeriod() public view virtual override returns (uint256) {
        return _votingPeriod;
    }

    function proposalThreshold() public view virtual override returns (uint256) {
        return _proposalThreshold;
    }

    function _setVotingDelay(uint256 newVotingDelay) internal virtual {
        require(newVotingDelay > 0, "GovernorSettings: voting delay must be greater than 0");
        _votingDelay = newVotingDelay;
    }

    function _setVotingPeriod(uint256 newVotingPeriod) internal virtual {
        require(newVotingPeriod > 0, "GovernorSettings: voting period must be greater than 0");
        _votingPeriod = newVotingPeriod;
    }

    function _setProposalThreshold(uint256 newProposalThreshold) internal virtual {
        _proposalThreshold = newProposalThreshold;
    }
}

// File: contracts/governance/extensions/GovernorCountingSimple.sol

abstract contract GovernorCountingSimple is Governor {
    using SafeCast for uint256;

    mapping(uint256 => IGovernor.ProposalVote) private _proposalVotes;

    function COUNTING_MODE() public pure virtual override returns (string memory) {
        return "support=bravo&quorum=for,abstain";
    }

    function _quorumReached(uint256 proposalId) internal view virtual override returns (bool) {
        IGovernor.ProposalVote storage proposalVote = _proposalVotes[proposalId];
        return proposalVote.forVotes + proposalVote.abstainVotes >= quorum(proposalSnapshot(proposalId));
    }

    function _voteSucceeded(uint256 proposalId) internal view virtual override returns (bool) {
        IGovernor.ProposalVote storage proposalVote = _proposalVotes[proposalId];
        return proposalVote.forVotes > proposalVote.againstVotes;
    }

    function hasVoted(uint256 proposalId, address account) public view virtual override returns (bool) {
        return _proposalVotes[proposalId].hasVoted[account];
    }

    function _countVote(uint256 proposalId, address account, uint8 support, uint256 weight) internal virtual {
        IGovernor.ProposalVote storage proposalVote = _proposalVotes[proposalId];

        require(!proposalVote.hasVoted[account], "GovernorCountingSimple: vote already cast");
        proposalVote.hasVoted[account] = true;

        if (support == 0) {
            proposalVote.againstVotes += weight;
        } else if (support == 1) {
            proposalVote.forVotes += weight;
        } else if (support == 2) {
            proposalVote.abstainVotes += weight;
        } else {
            revert("GovernorCountingSimple: invalid value for support");
        }
    }
}

// File: contracts/governance/extensions/GovernorVotes.sol

abstract contract GovernorVotes is Governor {
    IVotes public immutable token;

    constructor(IVotes tokenAddress) {
        token = tokenAddress;
    }

    function getVotesWithParams(address account, uint256 blockNumber, bytes memory) public view virtual override returns (uint256) {
        return token.getPastVotes(account, blockNumber);
    }
}

// File: contracts/governance/extensions/GovernorVotesQuorumFraction.sol

abstract contract GovernorVotesQuorumFraction is GovernorVotes {
    uint256 private _quorumNumerator;

    /// @notice Emitted when quorum numerator is updated
    event QuorumNumeratorUpdated(uint256 oldQuorumNumerator, uint256 newQuorumNumerator);

    /// @notice Initializes quorum numerator (e.g. 4 means 4%)
    constructor(uint256 quorumNumeratorValue) {
        _updateQuorumNumerator(quorumNumeratorValue);
    }

    /// @notice Calculates the quorum required for a given block
    /// @dev Override of Governor.quorum
    function quorum(uint256 blockNumber)
        public
        view
        virtual
        override(Governor)
        returns (uint256)
    {
        return (token.getPastTotalSupply(blockNumber) * _quorumNumerator) / 100;
    }

    /// @notice Returns the quorum numerator (e.g. 4 means 4%)
    function quorumNumerator() public view virtual returns (uint256) {
        return _quorumNumerator;
    }

    /// @notice Updates the quorum numerator (internal)
    function _updateQuorumNumerator(uint256 newQuorumNumerator) internal virtual {
        require(newQuorumNumerator <= 100, "GovernorVotesQuorumFraction: quorum too high");
        uint256 old = _quorumNumerator;
        _quorumNumerator = newQuorumNumerator;
        emit QuorumNumeratorUpdated(old, newQuorumNumerator);
    }
}

// File: contracts/governance/extensions/GovernorTimelockControl.sol

abstract contract GovernorTimelockControl is Governor {
    TimelockController private _timelock;

    constructor(TimelockController timelock_) {
        _updateTimelock(timelock_);
    }

    function timelock() public view virtual returns (TimelockController) {
        return _timelock;
    }

    function _updateTimelock(TimelockController newTimelock) internal virtual {
        _timelock = newTimelock;
    }

    function state(uint256 proposalId) public view virtual override(Governor) returns (ProposalState) {
        ProposalState status = super.state(proposalId);
        if (status != ProposalState.Succeeded) {
            return status;
        }

        bytes32 operationId = _timelockOperationId(proposalId);
        if (_timelock.isOperationDone(operationId)) {
            return ProposalState.Executed;
        } else if (_timelock.isOperationPending(operationId)) {
            return ProposalState.Queued;
        } else {
            return status;
        }
    }

    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual override returns (uint48) {
        bytes32 operationId = _timelockOperationId(proposalId);
        _timelock.scheduleBatch(targets, values, calldatas, bytes32(0), descriptionHash, _timelock.getMinDelay());
        return uint48(block.timestamp + _timelock.getMinDelay());
    }

    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual override {
        bytes32 operationId = _timelockOperationId(proposalId);
        _timelock.executeBatch{value: msg.value}(targets, values, calldatas, bytes32(0), descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual override returns (uint256 proposalId) {
        proposalId = hashProposal(targets, values, calldatas, descriptionHash);
        _timelock.cancel(_timelockOperationId(proposalId));
    }

    function _executor() internal view virtual override returns (address) {
        return address(_timelock);
    }

    function proposalNeedsQueuing(uint256 proposalId) public view virtual override returns (bool) {
        return state(proposalId) == ProposalState.Succeeded;
    }

    function _timelockOperationId(uint256 proposalId) private pure returns (bytes32) {
        return bytes32(proposalId);
    }
}
// File: contracts/governance/TimelockController.sol

contract TimelockController {
    function isOperationDone(bytes32 id) public view returns (bool) {}
    function isOperationPending(bytes32 id) public view returns (bool) {}
    function scheduleBatch(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 predecessor, bytes32 salt, uint256 delay) public {}
    function executeBatch(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 predecessor, bytes32 salt) public payable {}
    function cancel(bytes32 id) public {}
    function getMinDelay() public view returns (uint256) {}
}

// File: contracts/governance/utils/IVotes.sol

interface IVotes is IERC5805 {
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256);
    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256);
}
// File: contracts/token/ERC20/extensions/ERC20Votes.sol

abstract contract ERC20Votes is IVotes {
    function getPastVotes(address account, uint256 blockNumber) public view virtual override returns (uint256);
    function getPastTotalSupply(uint256 blockNumber) public view virtual override returns (uint256);
}
// File: GovernorContract.sol

contract GovernorContract is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    using Address for address;

    constructor(
        IVotes _token,
        TimelockController _timelock
    )
        Governor("GovernorContract")
        GovernorSettings(
            1,          // votingDelay: 1 block
            45818,      // votingPeriod: ~1 week
            1000e18     // proposalThreshold: 1,000 FREQ
        )
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4) // 4% quorum
        GovernorTimelockControl(_timelock)
    {}

    function COUNTING_MODE()
        public
        pure
        override(Governor, GovernorCountingSimple)
        returns (string memory)
    {
        return super.COUNTING_MODE();
    }

    function hasVoted(uint256 proposalId, address account)
        public
        view
        override(Governor, GovernorCountingSimple)
        returns (bool)
    {
        return super.hasVoted(proposalId, account);
    }

    function castVote(uint256, uint8) external pure override returns (uint256) {
        revert("Not implemented");
    }

    function castVoteBySig(uint256, uint8, uint8, bytes32, bytes32) external pure override returns (uint256) {
        revert("Not implemented");
    }

    function castVoteWithReason(uint256, uint8, string calldata) external pure override returns (uint256) {
        revert("Not implemented");
    }

    function castVoteWithReasonAndParams(
        uint256,
        uint8,
        string calldata,
        bytes calldata
    ) external pure override returns (uint256) {
        revert("Not implemented");
    }

    function castVoteWithReasonAndParamsBySig(
        uint256,
        uint8,
        string calldata,
        bytes calldata,
        uint8,
        bytes32,
        bytes32
    ) external pure override returns (uint256) {
        revert("Not implemented");
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

    function votingDelay()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(Governor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function proposalNeedsQueuing(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.proposalNeedsQueuing(proposalId);
    }

    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint48)
    {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}