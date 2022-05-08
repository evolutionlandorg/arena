pragma solidity ^0.8.13;

import "ds-stop/stop.sol";
import "zeppelin-solidity/token/ERC20/IERC20.sol";
import "zeppelin-solidity/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ITicket.sol";
import "./interfaces/ISeason.sol";

contract Shop is DSStop {
    using SafeERC20 for IERC20;

    event Buy(address indexed user, uint256 indexed season, Chest chest, uint256 amount);
	event ClaimedTokens(address indexed token, address indexed to, uint256 amount);

    enum Chest {
        COO,
        Ticket
    }

    address public immutable USDT;
    address public immutable TICKET;
    address public immutable SEASON;

    uint256 public ticketFee = 20e6;
    uint256 public cooFee = 20e6;

    constructor(address usdt, address ticket, address season) {
        USDT = usdt;
        TICKET = ticket;
        SEASON = season;
    }

    function buy(Chest chest, uint amount) external {
        if (Chest.COO == chest) {
            buyCOO(amount);
        } else if (Chest.Ticket == chest) {
            buyTicket(amount);
        } else {
            revert("!chest");
        }
    }

    function buyCOO(uint256 amount) public stoppable {
        require(amount > 0, "!amount");
        uint season = ISeason(SEASON).season();
        require(season > 0, "!start");
        address user = msg.sender;
        IERC20(USDT).safeTransferFrom(user, address(this), cooFee * amount);
        emit Buy(user, season, Chest.COO, amount);
    }

    function buyTicket(uint amount) public stoppable {
        require(amount > 0, "!amount");
        uint season = ISeason(SEASON).season();
        require(season > 0, "!start");
        uint end = ISeason(SEASON).endOf(season);
        address user = msg.sender;
        require(end - 7 days > block.timestamp, "end");
        IERC20(USDT).safeTransferFrom(user, address(this), ticketFee * amount);
        _giveTicket(user, season, amount);
        emit Buy(user, season, Chest.Ticket, amount);
    }

    function _giveTicket(address user, uint season, uint amount) internal returns (uint) {
        return ITicket(TICKET).create(user, season, amount);
    }

    function setFee(uint256 _ticketFee, uint256 _cooFee) external auth {
        ticketFee = _ticketFee;
        cooFee = _cooFee;
    }

    function claimTokens(address _token) external auth {
        if (_token == address(0)) {
            payable(owner).transfer(address(this).balance);
            return;
        }
        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner, balance);
        emit ClaimedTokens(_token, owner, balance);
    }
}
