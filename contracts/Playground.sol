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
        address key1,
        uint256 key2
    ) external pure returns (uint256 slot) {
        uint256 mappingSlot;

        assembly {
            mappingSlot := balance.slot
        }

        bytes32 initialHash = keccak256(abi.encode(key1, mappingSlot));
        slot = uint256(keccak256(abi.encode(key2, initialHash))); // was inittially byte32
    }

    function getSlotValue(bytes32 _slot) external view returns (uint256 value) {
        assembly {
            value := sload(_slot)
        }
    }
}

contract DynamicArray {
    uint256 private someNumber; // storage slot 0
    address private someAddress; // storage slot 1
    uint256[] private myArr = [3, 4, 5, 9, 7]; // storage slot 2

    function getSlotValueInDynamicArray(
        uint256 _index
    ) public view returns (uint256 value, uint256 slot) {
        slot = uint256(keccak256(abi.encode(2))) + _index;

        assembly {
            value := sload(slot)
        }
    }
}

// when elements don’t use up a storage slot space
contract DynArray {
    uint256 private someNumber; // storage slot 0
    address private someAddress; // storage slot 1
    uint32[] private myArr = [3, 4, 5, 9, 7]; // storage slot 2

    function getSlotValue(
        uint256 _index
    ) public view returns (bytes32 value, uint256 slot) {
        slot = uint256(keccak256(abi.encode(2))) + _index;
        assembly {
            value := sload(slot)
        }
    }
}

contract NestedArray {
    uint256 private someNumber; // storage slot 0

    // Initialize nested array
    uint256[][] private a = [[2, 9, 6, 3], [7, 4, 8, 10]]; // storage slot 1

    function getSlot(
        uint256 baseSlot,
        uint256 _index1,
        uint256 _index2
    ) public pure returns (uint256 _finalSlot) {
        // keccak256(baseSlot) + _index1
        uint256 _initialSlot = uint256(keccak256(abi.encode(baseSlot))) +
            _index1;

        // keccak256(_initialSlot) + _index2
        _finalSlot = uint256(
            uint256(keccak256(abi.encode(_initialSlot))) + _index2
        );
    }

    function getSlotValue(uint256 _slot) public view returns (uint256 value) {
        assembly {
            value := sload(_slot)
        }
    }
}
