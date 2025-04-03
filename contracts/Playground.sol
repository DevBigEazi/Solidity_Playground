// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Slot {
    mapping(address => uint256) public bal; // slot 0
    mapping(address user => mapping(address token => uint)) public tokenBal; //slot 1

    function updateBal(
        uint256 _bal1,
        uint256 _bal2,
        uint256 _tokenBal
    ) external returns (bytes32, bytes32, bytes32) {
        address key1 = 0x504DbB5Dc821445b142312b74693d778a1B60b2f;
        address key2 = address(0x02);

        bal[key1] = _bal1;
        bal[key2] = _bal2;

        // How do we know the which slots each of these state variable are being stored? Their base slot is zero
        // bytes32 storageSlot = keccak256(bytes32(key) + bytes32(balBaseSlot) the concantenation of key a the base slot of the mapping

        uint256 balBaseSlot = 0;

        bytes32 storageSlot1 = keccak256(abi.encode(key1, balBaseSlot));
        bytes32 storageSlot2 = keccak256(abi.encode(key2, balBaseSlot));

        //
        address user = address(0x01);
        address token = address(0x04);

        tokenBal[user][token] = _tokenBal;
        // to get the slot of nested mapping, we have to concat the first key to the base slot and concat the resulting hash to the second key
        bytes32 initHash = keccak256(abi.encode(user, uint256(1)));
        bytes32 slotHash = keccak256(abi.encode(token, initHash));

        return (storageSlot1, storageSlot2, slotHash);
    }

    function assemblyVersion(
        uint256 _bal1,
        uint256 _bal2,
        uint256 _tokenBal
    ) external returns (bytes32 storageSlot1, bytes32 storageSlot2) {
        bal[address(0x0001)] = _bal1;
        bal[address(0x000002)] = _bal2;
        tokenBal[address(0x00000004)][address(0x11)] = _tokenBal;

        uint256 balSlot;
        uint256 tokenBalSlot;
        assembly {
            balSlot := bal.slot
            tokenBalSlot := tokenBal.slot
        }

        storageSlot1 = keccak256(abi.encode(address(0x0001), balSlot));

        bytes32 storageSlotHash = keccak256(
            abi.encode(address(0x00000004), tokenBalSlot)
        );
        storageSlot2 = keccak256(abi.encode(address(0x11), storageSlotHash));

        return (storageSlot1, storageSlot2);
    }

    mapping(address => mapping(uint256 => uint256)) public balance;

    constructor() {
        balance[address(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)][1111] = 10;
    }

    function getStorageSlot(
        address _key1,
        uint256 _key2
    ) external pure returns (bytes32 slot) {
        uint256 mappingSlot;

        assembly {
            mappingSlot := balance.slot
        }

        bytes32 initialHash = keccak256(abi.encode(_key1, mappingSlot));
        slot = keccak256(abi.encode(_key2, initialHash));
    }

    function getSlotValue(bytes32 _slot) external view returns (uint256 value) {
        assembly {
            value := sload(_slot)
        }
    }
}
