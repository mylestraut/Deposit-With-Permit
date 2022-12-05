pragma solidity 0.8.17;

import "lib/solmate/src/tokens/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("MockERC20", "MERC20", 18) {}

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}
