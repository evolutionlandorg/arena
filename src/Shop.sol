pragma solidity ^0.8.7;

import "ds-stop/stop.sol";
import "zeppelin-solidity/proxy/Initializable.sol";
import "zeppelin-solidity/token/ERC20/IERC20.sol";
import "zeppelin-solidity/token/ERC20/SafeERC20.sol";
import "../interfaces/ITicket.sol";
import "../interfaces/ISeason.sol";

contract Shop is Initializable, DSStop {
    using SafeERC20 for IERC20;

    event Buy(address indexed user, uint256 indexed season, Chest chest);
	event ClaimedTokens(address indexed token, address indexed to, uint256 amount);

    enum Chest {
        COO,
        Ticket
    }

    address public immutable USDT;
    address public immutable TICKET;
    address public immutable SEASON;

    uint256 public ticketFee;
    uint256 public cooFee;

    function initialize(address _registry) public initializer {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
        ticketFee = 20e6;
        cooFee = 20e6;
    }

    function buy(Chest chest, uint ticketAmount) external {
        if (Chest.COO == chest) {
            buyCOO();
        } else if (Chest.Ticket == chest) {
            buyTicket(ticketAmount);
        } else {
            revert("!chest");
        }
    }

    function buyCOO() public stoppable {
        uint season = ISeason(SEASON).season();
        require(season > 0, "!start");
        address user = msg.sender;
        IERC20(USDT).safeTransferFrom(user, address(this), cooFee);
        emit Buy(user, season, Chest.COO);
    }

    function buyTicket(uint amount) public stoppable {
        uint season = ISeason(SEASON).season();
        require(season > 0, "!start");
        uint end = ISeason(SEASON).endOf(season);
        address user = msg.sender;
        require(end - 7 days > block.timestamp, "!start");
        IERC20(USDT).safeTransferFrom(user, address(this), ticketFee * amount);
        _giveTicket(user, season, amount);
        emit Buy(user, season, Chest.Ticket);
    }

    function _giveTicket(address user, uint season, uint amount) internal {
        require(ITicket(TICKET).createTicket(user, season, amount), "!give");
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
