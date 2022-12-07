// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "lib/forge-std/src/Test.sol";
import "../src/SigUtils.sol";
import "../src/MockERC20.sol";
import "../src/Deposit.sol";

contract DepositTest is Test {
    MockERC20 token;
    SigUtils sigUtils;
    Deposit deposit;

    uint256 ownerPrivateKey;

    address owner;
    address spender;

    function setUp() public {
        token = new MockERC20();
        sigUtils = new SigUtils(token.DOMAIN_SEPARATOR());
        deposit = new Deposit(address(token));

        ownerPrivateKey = 0xA11C;
        owner = vm.addr(ownerPrivateKey);

        token.mint(owner, 1e18);
    }

    function testDepositWithPermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(deposit),
            value: 1e18,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        assertEq(token.balanceOf(owner), 1e18);
        assertEq(token.balanceOf(address(deposit)), 0);
        assertEq(token.allowance(owner, address(deposit)), 0);

        deposit.depositWithPermit(
            1e18,
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(address(deposit)), 1e18);
        assertEq(token.allowance(owner, address(deposit)), 0);
        assertEq(deposit.userBalances(owner), 1e18);
    }

    function testDepositWithMaxPermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(deposit),
            value: type(uint256).max,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        assertEq(token.balanceOf(owner), 1e18);
        assertEq(token.balanceOf(address(deposit)), 0);
        assertEq(token.allowance(owner, address(deposit)), 0);

        deposit.depositWithPermit(
            1e18,
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(address(deposit)), 1e18);
        assertEq(token.allowance(owner, address(deposit)), type(uint256).max);
        assertEq(deposit.userBalances(owner), 1e18);
    }

    function testDeposit() public {
        assertEq(token.allowance(owner, address(deposit)), 0);

        // 1st transaction
        vm.prank(owner);
        token.approve(address(deposit), 1e18);
        assertEq(token.allowance(owner, address(deposit)), 1e18);

        //2nd transaction
        vm.prank(owner);
        deposit.deposit(1e18);

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(address(deposit)), 1e18);
    }
}
