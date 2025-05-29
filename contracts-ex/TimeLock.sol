// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title TimeLock
 * @notice Delays execution of successful proposals.
 */
contract TimeLock is TimelockController {
    /**
     * @param minDelay Delay in seconds before a proposal can be executed
     * @param proposers List of addresses allowed to propose actions
     * @param executors List of addresses allowed to execute queued actions
     * @param admin Admin address to manage roles (can renounce later)
     */
    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors,
        address admin
    )
        TimelockController(minDelay, proposers, executors, admin)
    {}
}
