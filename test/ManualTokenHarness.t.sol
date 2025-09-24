// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {ManualToken} from "../src/ManualToken.sol";

contract ReceiverMock {
    address public lastFrom;
    uint256 public lastValue;
    address public lastToken;
    bytes public lastData;

    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external {
        lastFrom = _from;
        lastValue = _value;
        lastToken = _token;
        lastData = _extraData;
    }
}

contract ManualToken_PortfolioTest is Test {
    ManualToken t;
    ReceiverMock r;

    address owner = address(this);
    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    uint256 constant INIT = 1_000_000;

    function setUp() public {
        // ManualToken constructor: (initialSupply, name, symbol)
        t = new ManualToken(INIT, "Manual", "MNL");
        r = new ReceiverMock();
    }

    /*//////////////////////////
            METADATA
    */
    //////////////////////////*/

    function testConstructorSetsState() public view {
        // totalSupply is scaled by 1e18 inside constructor
        assertEq(t.decimals(), 18);
        assertEq(t.name(), "Manual");
        assertEq(t.symbol(), "MNL");
        assertEq(t.totalSupply(), INIT * 1e18);
        assertEq(t.balanceOf(owner), INIT * 1e18);
    }

    /*//////////////////////////
            TRANSFERS
    */
    //////////////////////////*/

    function testTransferUpdatesBalances() public {
        uint256 amount = 10 ether;
        assertTrue(t.transfer(alice, amount));
        assertEq(t.balanceOf(owner), INIT * 1e18 - amount);
        assertEq(t.balanceOf(alice), amount);
    }

    function testTransferRevertsOnInsufficientBalance() public {
        vm.prank(alice);
        vm.expectRevert(); // ManualToken не має конкретного повідомлення
        t.transfer(bob, 1);
    }

    function testTransferToZeroReverts() public {
        vm.expectRevert();
        t.transfer(address(0), 1);
    }

    /*//////////////////////////
           ALLOWANCES
    */
    //////////////////////////*/

    function testApproveAndTransferFrom() public {
        uint256 amount = 5 ether;
        assertTrue(t.approve(bob, amount));
        assertEq(t.allowance(owner, bob), amount);

        vm.prank(bob);
        assertTrue(t.transferFrom(owner, alice, 3 ether));

        assertEq(t.allowance(owner, bob), 2 ether);
        assertEq(t.balanceOf(alice), 3 ether);
        assertEq(t.balanceOf(owner), INIT * 1e18 - 3 ether);
    }

    function testTransferFromInsufficientAllowanceReverts() public {
        vm.prank(bob);
        vm.expectRevert();
        t.transferFrom(owner, alice, 1);
    }

    /*//////////////////////////
         APPROVE & CALL
    */
    //////////////////////////*/

    function testApproveAndCallNotifiesSpender() public {
        bytes memory data = "hello";
        assertTrue(t.approveAndCall(address(r), 7 ether, data));
        assertEq(r.lastFrom(), owner);
        assertEq(r.lastValue(), 7 ether);
        assertEq(r.lastToken(), address(t));
        assertEq(r.lastData(), data);
    }

    /*//////////////////////////
              BURN
    */
    //////////////////////////*/

    function testBurnReducesSupplyAndBalance() public {
        uint256 preBal = t.balanceOf(owner);
        uint256 preSup = t.totalSupply();
        assertTrue(t.burn(1 ether));
        assertEq(t.balanceOf(owner), preBal - 1 ether);
        assertEq(t.totalSupply(), preSup - 1 ether);
    }

    function testBurnFromUsesAllowance() public {
        assertTrue(t.approve(bob, 2 ether));
        uint256 preBal = t.balanceOf(owner);
        uint256 preSup = t.totalSupply();

        vm.prank(bob);
        assertTrue(t.burnFrom(owner, 2 ether));

        assertEq(t.balanceOf(owner), preBal - 2 ether);
        assertEq(t.totalSupply(), preSup - 2 ether);
        assertEq(t.allowance(owner, bob), 0);
    }

    function testBurnFromInsufficientAllowanceReverts() public {
        vm.prank(bob);
        vm.expectRevert();
        t.burnFrom(owner, 1 ether);
    }

    /*//////////////////////////
            ZERO AMOUNTS
    */
    //////////////////////////*/

    function testZeroApproveAndZeroTransfer() public {
        assertTrue(t.approve(bob, 0));
        assertEq(t.allowance(owner, bob), 0);

        // zero transfer is allowed and should be a no-op with success
        assertTrue(t.transfer(alice, 0));
        assertEq(t.balanceOf(alice), 0);
        assertEq(t.balanceOf(owner), INIT * 1e18);
    }
}
