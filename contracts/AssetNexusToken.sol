// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

contract AssetNexusToken is ERC20, Ownable, ERC20Pausable {
    constructor() ERC20("AssetNexus", "AN") Ownable(msg.sender) {}

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }

    function mint(address account, uint256 value) public onlyOwner {
        _mint(account, value);
    }
}
