pragma solidity ^0.8.13;

contract Season is DSStop {
    event Enter(address indexed user, uint256 indexed season, address token, uint256 id);
    event NewSeason(uint256 indexed season, uint256 indexed end);

    bytes4 private constant ERC1155_RECEIVED = 0xf23a6e61;
    bytes4 private constant ERC1155_BATCH_RECEIVED = 0xbc197c81;

    uint256 public season;
    // season => end time
    mapping(uint256 => uint256) public endOf;
    // token => id => season
    mapping(address => mapping(uint256 => uint256)) seasonOf;
    // user => (season => bool)
    mapping(address => mapping(uint256 => uint256) public passOf;

    function enter(address ticket, uint256 id) external {
        address user = msg.sender;
        if (is1155(ticket)) {
            IERC1155(ticket).safeTransferFrom(user, address(this), id, 1, "");
        } else {
            revert("!support");
        }
    }

    function _enter(address user, address ticket, uint256 id) internal {
        require(endOf(season) > block.timestamp, "!start");
        require(seasonOf[ticket][id] == season, "!ticket");
        require(canEnter(user) == false, "enter");
        passOf[user][season] = 1;
        Enter(user, season, ticket, id);
    }

    function canEnter(address user) external returns (bool) {
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

    function setTicketSeason(address ticket, uint256 id, uint256 season) external auth {
        seasonOf[ticket][id] = season;
    }

    function onERC1155Received(
        address, /*operator*/
        address, from
        uint256 id,
        uint256 value,
        bytes calldata /*data*/
    ) external pure returns (bytes4) {
        require(value == 1, "!one");
        address token = msg.sender;
        _enter(from, token, id);
        return ERC1155_RECEIVED;
    }

    function onERC1155BatchReceived(
        address, /*operator*/
        address, /*from*/
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata /*data*/
    ) external pure returns (bytes4) {
        address token = msg.sender;
        for (uint i = 0; i < ids.length; ++i) {
            require(values[i] == 1, "!one");
            _enter(from, token, ids[i]);
        }
        return ERC1155_BATCH_RECEIVED;
    }
}
