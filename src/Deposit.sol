// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./MockERC20.sol";
import "./SigUtils.sol";

contract Deposit {
    MockERC20 token;

    mapping(address => uint256) public userBalances;

    constructor(address _token) {
        token = MockERC20(_token);
    }

    function deposit(uint256 _amount) public {
        token.transferFrom(msg.sender, address(this), _amount);
        userBalances[msg.sender] += _amount;
    }

    // @notice Deposits ERC-20 tokens with a signed approval
    /// @param _amount The number of tokens to transfer
    /// @param _owner The user signing the approval
    /// @param _spender The user to transfer the tokens (ie this contract)
    /// @param _value The number of tokens to appprove the spender
    /// @param _deadline The timestamp the permit expires
    /// @param _v The 129th byte and chain id of the signature
    /// @param _r The first 64 bytes of the signature
    /// @param _s Bytes 64-128 of the signature

    function depositWithPermit(
        uint256 _amount,
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        token.permit(_owner, _spender, _value, _deadline, _v, _r, _s);
        token.transferFrom(_owner, address(this), _amount);
        userBalances[_owner] += _amount;
    }
}
