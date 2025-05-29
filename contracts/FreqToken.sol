// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/utils/Nonces.sol";

/**
 * @title FreqToken
 * @notice Governance-ready ERC20 token with vote tracking, capped supply, and role-based minting.
 */
contract FreqToken is ERC20, ERC20Permit, ERC20Capped, ERC20Votes, AccessControl {
    /// @notice Role identifier for accounts allowed to mint new tokens.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /**
     * @notice Initializes the token with a capped supply and grants admin/minter roles to deployer.
     * @param cap Maximum token supply in whole tokens (e.g. 21_000_000).
     */
    constructor(uint256 cap)
        ERC20("Freq Token", "FREQ")
        ERC20Permit("Freq Token")
        ERC20Capped(cap * 10 ** decimals())
    {
        _mint(msg.sender, 21_000_000 * 10 ** decimals());
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    /**
     * @notice Override decimals to make precision explicit.
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /**
     * @notice Mints new tokens, callable only by accounts with MINTER_ROLE.
     * @param to Address to receive minted tokens.
     * @param amount Amount of tokens to mint (in wei).
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /**
     * @dev Resolves multiple inheritance of _update() between ERC20Votes and ERC20Capped.
     */
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Capped, ERC20Votes)
    {
        super._update(from, to, value);
    }

    /**
     * @dev Resolves multiple inheritance of `nonces()` from ERC20Permit and Nonces.
     */
    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}
