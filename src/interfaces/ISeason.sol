pragma solidity ^0.8.13;

interface ISeason {
    function season() external view returns (uint);
    function endOf(uint season) external view returns (uint);
}
