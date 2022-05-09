// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "ds-stop/stop.sol";
import "zeppelin-solidity/token/ERC1155/IERC1155.sol";

// Filter all valid ticket process:
// 1. Get length of all tickets by `ticketsLength`
// 2. Fetch all tickets by `tickets`
// 3. Filter valid ticket in current season by `check`

contract Season is DSStop {
    event Enter(address indexed user, uint256 indexed season, address ticket, uint256 id);
    event NewSeason(uint256 indexed season, uint256 indexed end);
    event NewTicket(address indexed ticket, uint256 indexed id);

    bytes4 private constant ERC1155_RECEIVED = 0xf23a6e61;
    bytes4 private constant ERC1155_BATCH_RECEIVED = 0xbc197c81;

    struct Ticket {
        uint256 id;
        address token;
    }

    // current season
    uint256 public season;
    // season => end time
    mapping(uint256 => uint256) public endOf;
    // user => (season => bool)
    mapping(address => mapping(uint256 => uint256)) public passOf;
    // ticket => id => season
    mapping(address => mapping(uint256 => uint256)) public seasonOf;
    // all tickets which can enter the season
    Ticket[] public tickets;

    // require current season is started
    modifier started {
        require(endOf[season] > block.timestamp, "!start");
        _;
    }

    // require ticket is valid in current season
    modifier current(address ticket, uint id) {
        require(check(ticket, id), "!ticket");
        _;
    }

    // enter current season
    function enter(address ticket, uint256 id) external {
        address user = msg.sender;
        if (is1155(ticket)) {
            IERC1155(ticket).safeTransferFrom(user, address(this), id, 1, "");
        } else {
            revert("!support");
        }
    }

    function _enter(address user, address ticket, uint256 id) started current(ticket, id) internal {
        require(canEnter(user) == false, "enter");
        passOf[user][season] = 1;
        emit Enter(user, season, ticket, id);
    }

    // all tickets length
    function ticketsLength() external view returns (uint) {
        return tickets.length;
    }

    // check if of the ticket is valid in this season
    function check(address ticket, uint id) public view returns (bool) {
        return seasonOf[ticket][id] == season;
    }

    // check if the user can enter the season
    function canEnter(address user) started public view returns (bool) {
        return passOf[user][season] == 1;
    }

    function is1155(address token) public view returns (bool) {
        return IERC165(token).supportsInterface(type(IERC1155).interfaceId);
    }

    function startNewSeason() external auth {
        season = season + 1;
        uint end = block.timestamp + 90 days;
        endOf[season] = end;
        emit NewSeason(season, end);
    }

    function setTicketSeason(address ticket, uint256 id, uint256 _season) external auth {
        seasonOf[ticket][id] = _season;
    }

    function addTicket(address ticket, uint256 id) external auth {
        tickets.push(
            Ticket({
                id: id,
                token: ticket
            })
        );
    }

    function onERC1155Received(
        address, /*operator*/
        address from,
        uint256 id,
        uint256 value,
        bytes calldata /*data*/
    ) external returns (bytes4) {
        require(value == 1, "!one");
        address token = msg.sender;
        _enter(from, token, id);
        return ERC1155_RECEIVED;
    }

    function onERC1155BatchReceived(
        address, /*operator*/
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata /*data*/
    ) external returns (bytes4) {
        address token = msg.sender;
        for (uint i = 0; i < ids.length; ++i) {
            require(values[i] == 1, "!one");
            _enter(from, token, ids[i]);
        }
        return ERC1155_BATCH_RECEIVED;
    }
}
