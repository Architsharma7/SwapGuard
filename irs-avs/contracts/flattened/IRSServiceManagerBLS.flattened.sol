// SPDX-License-Identifier: MIT
pragma solidity =0.8.26 >=0.5.0 ^0.8.0 ^0.8.1 ^0.8.12 ^0.8.2 ^0.8.9;

// extras/Errors.sol

// SEE LICENSE IN https://files.altlayer.io/Alt-Research-License-1.md
// Copyright Alt Research Ltd. 2023. All rights reserved.
//
// You acknowledge and agree that Alt Research Ltd. ("Alt Research") (or Alt
// Research's licensors) own all legal rights, titles and interests in and to the
// work, software, application, source code, documentation and any other documents
//
//        db         888             88
//       d88b         88     88      88
//      d8'`8b        88     88      88
//     d8'  `8b       88   MM88MMM   88          ,adPPYYba,  8b       d8   ,adPPYba,  8b,dPPYb
//    d8YaaaaY8b      88     88      88          ""     `Y8  `8b     d8'  a8P_____88  88P'
//   d8""""""""8b     88     88      88          ,adPPPPP88   `8b   d8'   8PP"""""""  88
//  d8'        `8b    88     88,     88          88,    ,88    `8b,d8'    "8b,   ,aa  88
// d8'          `8b  8888    "Y888   88888888888 `"8bbdP"Y8      Y88'      `"Ybbd8"'  88
//                                                               d8'
//                                                              d8'

error AlreadySet();
error NoOngoingDeployment();
error ZeroAddress();
error ZeroValue();

// interfaces/IOperatorAllowlist.sol

/// @title IOperatorAllowlist Interface
/// @notice This interface defines the methods for managing and querying an operator allowlist
interface IOperatorAllowlist {
    /// @notice Emitted when the allowlist is updated with new operators and their status
    /// @param operators The list of operator addresses being updated
    /// @param status The corresponding status (allowed or disallowed) for each operator
    event AllowlistUpdated(address[] operators, bool[] status);

    /// @notice Emitted when the allowlist is enabled
    event AllowlistEnabled();

    /// @notice Emitted when the allowlist is disabled
    event AllowlistDisabled();

    /// @notice Emitted when the allowlist manager is changed
    /// @param previousManager The address of the previous allowlist manager
    /// @param newManager The address of the new allowlist manager
    event AllowlistManagerChanged(
        address indexed previousManager,
        address indexed newManager
    );

    /// @notice Updates the allowlist by adding or removing operators
    /// @param operators The array of operator addresses to be added or removed
    /// @param status The array of boolean values indicating whether to add (true) or remove (false) each operator
    function setAllowlist(
        address[] calldata operators,
        bool[] calldata status
    ) external;

    /// @notice Enables the allowlist, making it active for operator registration
    function enableAllowlist() external;

    /// @notice Disables the allowlist, preventing any operator registration until re-enabled
    function disableAllowlist() external;

    /// @notice Sets the allowlist manager, who has permission to modify the allowlist
    /// @param _allowlistManager The address of the new allowlist manager
    function setAllowlistManager(address _allowlistManager) external;

    /// @notice Checks whether an operator is allowed on the allowlist
    /// @param operator The address of the operator to check
    /// @return True if the operator is allowed, false otherwise
    function isOperatorAllowed(address operator) external view returns (bool);

    /// @notice Returns the number of operators in the allowlist
    /// @return The size of the allowlist
    function getAllowlistSize() external view returns (uint256);

    /// @notice Returns the operator address at a specific index in the allowlist
    /// @param index The index of the operator in the allowlist
    /// @return The operator's address at the specified index
    function getAllowlistAtIndex(uint256 index) external view returns (address);

    /// @notice Returns a list of operators from a given starting index with a specific count
    /// @param start The index to start querying operators from
    /// @param count The number of operators to return
    /// @return operators The array of operator addresses queried
    function queryOperators(
        uint256 start,
        uint256 count
    ) external view returns (address[] memory operators);
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/lib/openzeppelin-contracts/contracts/interfaces/IERC1271.sol

// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1271.sol)

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * _Available since v4.1._
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/lib/openzeppelin-contracts/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/lib/openzeppelin-contracts/contracts/utils/Strings.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/lib/openzeppelin-contracts-upgradeable/contracts/utils/AddressUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/lib/openzeppelin-contracts-upgradeable/contracts/utils/structs/EnumerableSetUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/src/contracts/interfaces/IPauserRegistry.sol

/**
 * @title Interface for the `PauserRegistry` contract.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 */
interface IPauserRegistry {
    event PauserStatusChanged(address pauser, bool canPause);

    event UnpauserChanged(address previousUnpauser, address newUnpauser);

    /// @notice Mapping of addresses to whether they hold the pauser role.
    function isPauser(address pauser) external view returns (bool);

    /// @notice Unique address that holds the unpauser role. Capable of changing *both* the pauser and unpauser addresses.
    function unpauser() external view returns (address);
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/src/contracts/interfaces/ISignatureUtils.sol

/**
 * @title The interface for common signature utilities.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 */
interface ISignatureUtils {
    // @notice Struct that bundles together a signature and an expiration time for the signature. Used primarily for stack management.
    struct SignatureWithExpiry {
        // the signature itself, formatted as a single bytes object
        bytes signature;
        // the expiration timestamp (UTC) of the signature
        uint256 expiry;
    }

    // @notice Struct that bundles together a signature, a salt for uniqueness, and an expiration time for the signature. Used primarily for stack management.
    struct SignatureWithSaltAndExpiry {
        // the signature itself, formatted as a single bytes object
        bytes signature;
        // the salt used to generate the signature
        bytes32 salt;
        // the expiration timestamp (UTC) of the signature
        uint256 expiry;
    }
}

// lib/eigenlayer-middleware/src/interfaces/IRegistry.sol

/**
 * @title Minimal interface for a `Registry`-type contract.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice Functions related to the registration process itself have been intentionally excluded
 * because their function signatures may vary significantly.
 */
interface IRegistry {
    function registryCoordinator() external view returns (address);
}

// lib/eigenlayer-middleware/src/interfaces/ISocketUpdater.sol

/**
 * @title Interface for an `ISocketUpdater` where operators can update their sockets.
 * @author Layr Labs, Inc.
 */
interface ISocketUpdater {
    // EVENTS

    event OperatorSocketUpdate(bytes32 indexed operatorId, string socket);

    // FUNCTIONS
    
    /**
     * @notice Updates the socket of the msg.sender given they are a registered operator
     * @param socket is the new socket of the operator
     */
    function updateSocket(string memory socket) external;
}

// lib/eigenlayer-middleware/src/libraries/BN254.sol

// several functions are taken or adapted from https://github.com/HarryR/solcrypto/blob/master/contracts/altbn128.sol (MIT license):
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

// The remainder of the code in this library is written by LayrLabs Inc. and is also under an MIT license

/**
 * @title Library for operations on the BN254 elliptic curve.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice Contains BN254 parameters, common operations (addition, scalar mul, pairing), and BLS signature functionality.
 */
library BN254 {
    // modulus for the underlying field F_p of the elliptic curve
    uint256 internal constant FP_MODULUS =
        21888242871839275222246405745257275088696311157297823662689037894645226208583;
    // modulus for the underlying field F_r of the elliptic curve
    uint256 internal constant FR_MODULUS =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;

    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    // Encoding of field elements is: X[1] * i + X[0]
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    function generatorG1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }

    // generator of group G2
    /// @dev Generator point in F_q2 is of the form: (x0 + ix1, y0 + iy1).
    uint256 internal constant G2x1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 internal constant G2x0 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 internal constant G2y1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 internal constant G2y0 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;

    /// @notice returns the G2 generator
    /// @dev mind the ordering of the 1s and 0s!
    ///      this is because of the (unknown to us) convention used in the bn254 pairing precompile contract
    ///      "Elements a * i + b of F_p^2 are encoded as two elements of F_p, (a, b)."
    ///      https://github.com/ethereum/EIPs/blob/master/EIPS/eip-197.md#encoding
    function generatorG2() internal pure returns (G2Point memory) {
        return G2Point([G2x1, G2x0], [G2y1, G2y0]);
    }

    // negation of the generator of group G2
    /// @dev Generator point in F_q2 is of the form: (x0 + ix1, y0 + iy1).
    uint256 internal constant nG2x1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 internal constant nG2x0 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 internal constant nG2y1 = 17805874995975841540914202342111839520379459829704422454583296818431106115052;
    uint256 internal constant nG2y0 = 13392588948715843804641432497768002650278120570034223513918757245338268106653;

    function negGeneratorG2() internal pure returns (G2Point memory) {
        return G2Point([nG2x1, nG2x0], [nG2y1, nG2y0]);
    }

    bytes32 internal constant powersOfTauMerkleRoot =
        0x22c998e49752bbb1918ba87d6d59dd0e83620a311ba91dd4b2cc84990b31b56f;

    /**
     * @param p Some point in G1.
     * @return The negation of `p`, i.e. p.plus(p.negate()) should be zero.
     */
    function negate(G1Point memory p) internal pure returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        if (p.X == 0 && p.Y == 0) {
            return G1Point(0, 0);
        } else {
            return G1Point(p.X, FP_MODULUS - (p.Y % FP_MODULUS));
        }
    }

    /**
     * @return r the sum of two points of G1
     */
    function plus(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint256[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0x80, r, 0x40)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }

        require(success, "ec-add-failed");
    }

    /**
     * @notice an optimized ecMul implementation that takes O(log_2(s)) ecAdds
     * @param p the point to multiply
     * @param s the scalar to multiply by
     * @dev this function is only safe to use if the scalar is 9 bits or less
     */ 
    function scalar_mul_tiny(BN254.G1Point memory p, uint16 s) internal view returns (BN254.G1Point memory) {
        require(s < 2**9, "scalar-too-large");

        // if s is 1 return p
        if(s == 1) {
            return p;
        }

        // the accumulated product to return
        BN254.G1Point memory acc = BN254.G1Point(0, 0);
        // the 2^n*p to add to the accumulated product in each iteration
        BN254.G1Point memory p2n = p;
        // value of most significant bit
        uint16 m = 1;
        // index of most significant bit
        uint8 i = 0;

        //loop until we reach the most significant bit
        while(s >= m){
            unchecked {
                // if the  current bit is 1, add the 2^n*p to the accumulated product
                if ((s >> i) & 1 == 1) {
                    acc = plus(acc, p2n);
                }
                // double the 2^n*p for the next iteration
                p2n = plus(p2n, p2n);

                // increment the index and double the value of the most significant bit
                m <<= 1;
                ++i;
            }
        }
        
        // return the accumulated product
        return acc;
    }

    /**
     * @return r the product of a point on G1 and a scalar, i.e.
     *         p == p.scalar_mul(1) and p.plus(p) == p.scalar_mul(2) for all
     *         points p.
     */
    function scalar_mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {
        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x60, r, 0x40)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }
        require(success, "ec-mul-failed");
    }

    /**
     *  @return The result of computing the pairing check
     *         e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
     *         For example,
     *         pairing([P1(), P1().negate()], [P2(), P2()]) should return true.
     */
    function pairing(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2
    ) internal view returns (bool) {
        G1Point[2] memory p1 = [a1, b1];
        G2Point[2] memory p2 = [a2, b2];

        uint256[12] memory input;

        for (uint256 i = 0; i < 2; i++) {
            uint256 j = i * 6;
            input[j + 0] = p1[i].X;
            input[j + 1] = p1[i].Y;
            input[j + 2] = p2[i].X[0];
            input[j + 3] = p2[i].X[1];
            input[j + 4] = p2[i].Y[0];
            input[j + 5] = p2[i].Y[1];
        }

        uint256[1] memory out;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, input, mul(12, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }

        require(success, "pairing-opcode-failed");

        return out[0] != 0;
    }

    /**
     * @notice This function is functionally the same as pairing(), however it specifies a gas limit
     *         the user can set, as a precompile may use the entire gas budget if it reverts.
     */
    function safePairing(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        uint256 pairingGas
    ) internal view returns (bool, bool) {
        G1Point[2] memory p1 = [a1, b1];
        G2Point[2] memory p2 = [a2, b2];

        uint256[12] memory input;

        for (uint256 i = 0; i < 2; i++) {
            uint256 j = i * 6;
            input[j + 0] = p1[i].X;
            input[j + 1] = p1[i].Y;
            input[j + 2] = p2[i].X[0];
            input[j + 3] = p2[i].X[1];
            input[j + 4] = p2[i].Y[0];
            input[j + 5] = p2[i].Y[1];
        }

        uint256[1] memory out;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(pairingGas, 8, input, mul(12, 0x20), out, 0x20)
        }

        //Out is the output of the pairing precompile, either 0 or 1 based on whether the two pairings are equal.
        //Success is true if the precompile actually goes through (aka all inputs are valid)

        return (success, out[0] != 0);
    }

    /// @return hashedG1 the keccak256 hash of the G1 Point
    /// @dev used for BLS signatures
    function hashG1Point(BN254.G1Point memory pk) internal pure returns (bytes32 hashedG1) {
        assembly {
            mstore(0, mload(pk))
            mstore(0x20, mload(add(0x20, pk)))
            hashedG1 := keccak256(0, 0x40)
        }
    }

    /// @return the keccak256 hash of the G2 Point
    /// @dev used for BLS signatures
    function hashG2Point(
        BN254.G2Point memory pk
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(pk.X[0], pk.X[1], pk.Y[0], pk.Y[1]));
    }

    /**
     * @notice adapted from https://github.com/HarryR/solcrypto/blob/master/contracts/altbn128.sol
     */
    function hashToG1(bytes32 _x) internal view returns (G1Point memory) {
        uint256 beta = 0;
        uint256 y = 0;

        uint256 x = uint256(_x) % FP_MODULUS;

        while (true) {
            (beta, y) = findYFromX(x);

            // y^2 == beta
            if( beta == mulmod(y, y, FP_MODULUS) ) {
                return G1Point(x, y);
            }

            x = addmod(x, 1, FP_MODULUS);
        }
        return G1Point(0, 0);
    }

    /**
     * Given X, find Y
     *
     *   where y = sqrt(x^3 + b)
     *
     * Returns: (x^3 + b), y
     */
    function findYFromX(uint256 x) internal view returns (uint256, uint256) {
        // beta = (x^3 + b) % p
        uint256 beta = addmod(mulmod(mulmod(x, x, FP_MODULUS), x, FP_MODULUS), 3, FP_MODULUS);

        // y^2 = x^3 + b
        // this acts like: y = sqrt(beta) = beta^((p+1) / 4)
        uint256 y = expMod(beta, 0xc19139cb84c680a6e14116da060561765e05aa45a1c72a34f082305b61f3f52, FP_MODULUS);

        return (beta, y);
    }

    function expMod(uint256 _base, uint256 _exponent, uint256 _modulus) internal view returns (uint256 retval) {
        bool success;
        uint256[1] memory output;
        uint[6] memory input;
        input[0] = 0x20; // baseLen = new(big.Int).SetBytes(getData(input, 0, 32))
        input[1] = 0x20; // expLen  = new(big.Int).SetBytes(getData(input, 32, 32))
        input[2] = 0x20; // modLen  = new(big.Int).SetBytes(getData(input, 64, 32))
        input[3] = _base;
        input[4] = _exponent;
        input[5] = _modulus;
        assembly {
            success := staticcall(sub(gas(), 2000), 5, input, 0xc0, output, 0x20)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }
        require(success, "BN254.expMod: call failure");
        return output[0];
    }
}

// lib/eigenlayer-middleware/src/libraries/BitmapUtils.sol

/**
 * @title Library for Bitmap utilities such as converting between an array of bytes and a bitmap and finding the number of 1s in a bitmap.
 * @author Layr Labs, Inc.
 */
library BitmapUtils {
    /**
     * @notice Byte arrays are meant to contain unique bytes.
     * If the array length exceeds 256, then it's impossible for all entries to be unique.
     * This constant captures the max allowed array length (inclusive, i.e. 256 is allowed).
     */
    uint256 internal constant MAX_BYTE_ARRAY_LENGTH = 256;

    /**
     * @notice Converts an ordered array of bytes into a bitmap.
     * @param orderedBytesArray The array of bytes to convert/compress into a bitmap. Must be in strictly ascending order.
     * @return The resulting bitmap.
     * @dev Each byte in the input is processed as indicating a single bit to flip in the bitmap.
     * @dev This function will eventually revert in the event that the `orderedBytesArray` is not properly ordered (in ascending order).
     * @dev This function will also revert if the `orderedBytesArray` input contains any duplicate entries (i.e. duplicate bytes).
     */
    function orderedBytesArrayToBitmap(bytes memory orderedBytesArray) internal pure returns (uint256) {
        // sanity-check on input. a too-long input would fail later on due to having duplicate entry(s)
        require(orderedBytesArray.length <= MAX_BYTE_ARRAY_LENGTH,
            "BitmapUtils.orderedBytesArrayToBitmap: orderedBytesArray is too long");

        // return empty bitmap early if length of array is 0
        if (orderedBytesArray.length == 0) {
            return uint256(0);
        }

        // initialize the empty bitmap, to be built inside the loop
        uint256 bitmap;
        // initialize an empty uint256 to be used as a bitmask inside the loop
        uint256 bitMask;

        // perform the 0-th loop iteration with the ordering check *omitted* (since it is unnecessary / will always pass)
        // construct a single-bit mask from the numerical value of the 0th byte of the array, and immediately add it to the bitmap
        bitmap = uint256(1 << uint8(orderedBytesArray[0]));

        // loop through each byte in the array to construct the bitmap
        for (uint256 i = 1; i < orderedBytesArray.length; ++i) {
            // construct a single-bit mask from the numerical value of the next byte of the array
            bitMask = uint256(1 << uint8(orderedBytesArray[i]));
            // check strictly ascending array ordering by comparing the mask to the bitmap so far (revert if mask isn't greater than bitmap)
            require(bitMask > bitmap, "BitmapUtils.orderedBytesArrayToBitmap: orderedBytesArray is not ordered");
            // add the entry to the bitmap
            bitmap = (bitmap | bitMask);
        }
        return bitmap;
    }

    /**
     * @notice Converts an ordered byte array to a bitmap, validating that all bits are less than `bitUpperBound`
     * @param orderedBytesArray The array to convert to a bitmap; must be in strictly ascending order
     * @param bitUpperBound The exclusive largest bit. Each bit must be strictly less than this value.
     * @dev Reverts if bitmap contains a bit greater than or equal to `bitUpperBound`
     */
    function orderedBytesArrayToBitmap(bytes memory orderedBytesArray, uint8 bitUpperBound) internal pure returns (uint256) {
        uint256 bitmap = orderedBytesArrayToBitmap(orderedBytesArray);

        require((1 << bitUpperBound) > bitmap, 
            "BitmapUtils.orderedBytesArrayToBitmap: bitmap exceeds max value"
        );

        return bitmap;
    }

    /**
     * @notice Utility function for checking if a bytes array is strictly ordered, in ascending order.
     * @param bytesArray the bytes array of interest
     * @return Returns 'true' if the array is ordered in strictly ascending order, and 'false' otherwise.
     * @dev This function returns 'true' for the edge case of the `bytesArray` having zero length.
     * It also returns 'false' early for arrays with length in excess of MAX_BYTE_ARRAY_LENGTH (i.e. so long that they cannot be strictly ordered)
     */
    function isArrayStrictlyAscendingOrdered(bytes calldata bytesArray) internal pure returns (bool) {
        // Return early if the array is too long, or has a length of 0
        if (bytesArray.length > MAX_BYTE_ARRAY_LENGTH) {
            return false;
        }

        if (bytesArray.length == 0) {
            return true;
        }

        // Perform the 0-th loop iteration by pulling the 0th byte out of the array
        bytes1 singleByte = bytesArray[0];

        // For each byte, validate that each entry is *strictly greater than* the previous
        // If it isn't, return false as the array is not ordered
        for (uint256 i = 1; i < bytesArray.length; ++i) {
            if (uint256(uint8(bytesArray[i])) <= uint256(uint8(singleByte))) {
                return false;
            }
            
            // Pull the next byte out of the array
            singleByte = bytesArray[i];
        }
        
        return true;
    }

    /**
     * @notice Converts a bitmap into an array of bytes.
     * @param bitmap The bitmap to decompress/convert to an array of bytes.
     * @return bytesArray The resulting bitmap array of bytes.
     * @dev Each byte in the input is processed as indicating a single bit to flip in the bitmap
     */
    function bitmapToBytesArray(uint256 bitmap) internal pure returns (bytes memory /*bytesArray*/) {
        // initialize an empty uint256 to be used as a bitmask inside the loop
        uint256 bitMask;
        // allocate only the needed amount of memory
        bytes memory bytesArray = new bytes(countNumOnes(bitmap));
        // track the array index to assign to
        uint256 arrayIndex = 0;
        /**
         * loop through each index in the bitmap to construct the array,
         * but short-circuit the loop if we reach the number of ones and thus are done
         * assigning to memory
         */
        for (uint256 i = 0; (arrayIndex < bytesArray.length) && (i < 256); ++i) {
            // construct a single-bit mask for the i-th bit
            bitMask = uint256(1 << i);
            // check if the i-th bit is flipped in the bitmap
            if (bitmap & bitMask != 0) {
                // if the i-th bit is flipped, then add a byte encoding the value 'i' to the `bytesArray`
                bytesArray[arrayIndex] = bytes1(uint8(i));
                // increment the bytesArray slot since we've assigned one more byte of memory
                unchecked{ ++arrayIndex; }
            }
        }
        return bytesArray;
    }

    /// @return count number of ones in binary representation of `n`
    function countNumOnes(uint256 n) internal pure returns (uint16) {
        uint16 count = 0;
        while (n > 0) {
            n &= (n - 1); // Clear the least significant bit (turn off the rightmost set bit).
            count++; // Increment the count for each cleared bit (each one encountered).
        }
        return count; // Return the total count of ones in the binary representation of n.
    }

    /// @notice Returns `true` if `bit` is in `bitmap`. Returns `false` otherwise.
    function isSet(uint256 bitmap, uint8 bit) internal pure returns (bool) {
        return 1 == ((bitmap >> bit) & 1);
    }
    
    /**
     * @notice Returns a copy of `bitmap` with `bit` set. 
     * @dev IMPORTANT: we're dealing with stack values here, so this doesn't modify
     * the original bitmap. Using this correctly requires an assignment statement:
     * `bitmap = bitmap.setBit(bit);`
     */
    function setBit(uint256 bitmap, uint8 bit) internal pure returns (uint256) {
        return bitmap | (1 << bit);
    }

    /**
     * @notice Returns true if `bitmap` has no set bits
     */
    function isEmpty(uint256 bitmap) internal pure returns (bool) {
        return bitmap == 0;
    }

    /**
     * @notice Returns true if `a` and `b` have no common set bits
     */
    function noBitsInCommon(uint256 a, uint256 b) internal pure returns (bool) {
        return a & b == 0;
    }

    /**
     * @notice Returns true if `a` is a subset of `b`: ALL of the bits in `a` are also in `b`
     */
    function isSubsetOf(uint256 a, uint256 b) internal pure returns (bool) {
        return a & b == a;
    }

    /**
     * @notice Returns a new bitmap that contains all bits set in either `a` or `b`
     * @dev Result is the union of `a` and `b`
     */
    function plus(uint256 a, uint256 b) internal pure returns (uint256) {
        return a | b;
    }

    /**
     * @notice Returns a new bitmap that clears all set bits of `b` from `a`
     * @dev Negates `b` and returns the intersection of the result with `a`
     */
    function minus(uint256 a, uint256 b) internal pure returns (uint256) {
        return a & ~b;
    }
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/ECDSA.sol)

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/src/contracts/interfaces/IAVSDirectory.sol

interface IAVSDirectory is ISignatureUtils {
    /// @notice Enum representing the status of an operator's registration with an AVS
    enum OperatorAVSRegistrationStatus {
        UNREGISTERED, // Operator not registered to AVS
        REGISTERED // Operator registered to AVS

    }

    /**
     * @notice Emitted when @param avs indicates that they are updating their MetadataURI string
     * @dev Note that these strings are *never stored in storage* and are instead purely emitted in events for off-chain indexing
     */
    event AVSMetadataURIUpdated(address indexed avs, string metadataURI);

    /// @notice Emitted when an operator's registration status for an AVS is updated
    event OperatorAVSRegistrationStatusUpdated(
        address indexed operator, address indexed avs, OperatorAVSRegistrationStatus status
    );

    /**
     * @notice Called by an avs to register an operator with the avs.
     * @param operator The address of the operator to register.
     * @param operatorSignature The signature, salt, and expiry of the operator's signature.
     */
    function registerOperatorToAVS(
        address operator,
        ISignatureUtils.SignatureWithSaltAndExpiry memory operatorSignature
    ) external;

    /**
     * @notice Called by an avs to deregister an operator with the avs.
     * @param operator The address of the operator to deregister.
     */
    function deregisterOperatorFromAVS(address operator) external;

    /**
     * @notice Called by an AVS to emit an `AVSMetadataURIUpdated` event indicating the information has updated.
     * @param metadataURI The URI for metadata associated with an AVS
     * @dev Note that the `metadataURI` is *never stored * and is only emitted in the `AVSMetadataURIUpdated` event
     */
    function updateAVSMetadataURI(string calldata metadataURI) external;

    /**
     * @notice Returns whether or not the salt has already been used by the operator.
     * @dev Salts is used in the `registerOperatorToAVS` function.
     */
    function operatorSaltIsSpent(address operator, bytes32 salt) external view returns (bool);

    /**
     * @notice Calculates the digest hash to be signed by an operator to register with an AVS
     * @param operator The account registering as an operator
     * @param avs The AVS the operator is registering to
     * @param salt A unique and single use value associated with the approver signature.
     * @param expiry Time after which the approver's signature becomes invalid
     */
    function calculateOperatorAVSRegistrationDigestHash(
        address operator,
        address avs,
        bytes32 salt,
        uint256 expiry
    ) external view returns (bytes32);

    /// @notice The EIP-712 typehash for the Registration struct used by the contract
    function OPERATOR_AVS_REGISTRATION_TYPEHASH() external view returns (bytes32);
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/src/contracts/interfaces/IPausable.sol

/**
 * @title Adds pausability to a contract, with pausing & unpausing controlled by the `pauser` and `unpauser` of a PauserRegistry contract.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice Contracts that inherit from this contract may define their own `pause` and `unpause` (and/or related) functions.
 * These functions should be permissioned as "onlyPauser" which defers to a `PauserRegistry` for determining access control.
 * @dev Pausability is implemented using a uint256, which allows up to 256 different single bit-flags; each bit can potentially pause different functionality.
 * Inspiration for this was taken from the NearBridge design here https://etherscan.io/address/0x3FEFc5A4B1c02f21cBc8D3613643ba0635b9a873#code.
 * For the `pause` and `unpause` functions we've implemented, if you pause, you can only flip (any number of) switches to on/1 (aka "paused"), and if you unpause,
 * you can only flip (any number of) switches to off/0 (aka "paused").
 * If you want a pauseXYZ function that just flips a single bit / "pausing flag", it will:
 * 1) 'bit-wise and' (aka `&`) a flag with the current paused state (as a uint256)
 * 2) update the paused state to this new value
 * @dev We note as well that we have chosen to identify flags by their *bit index* as opposed to their numerical value, so, e.g. defining `DEPOSITS_PAUSED = 3`
 * indicates specifically that if the *third bit* of `_paused` is flipped -- i.e. it is a '1' -- then deposits should be paused
 */
interface IPausable {
    /// @notice Emitted when the `pauserRegistry` is set to `newPauserRegistry`.
    event PauserRegistrySet(IPauserRegistry pauserRegistry, IPauserRegistry newPauserRegistry);

    /// @notice Emitted when the pause is triggered by `account`, and changed to `newPausedStatus`.
    event Paused(address indexed account, uint256 newPausedStatus);

    /// @notice Emitted when the pause is lifted by `account`, and changed to `newPausedStatus`.
    event Unpaused(address indexed account, uint256 newPausedStatus);

    /// @notice Address of the `PauserRegistry` contract that this contract defers to for determining access control (for pausing).
    function pauserRegistry() external view returns (IPauserRegistry);

    /**
     * @notice This function is used to pause an EigenLayer contract's functionality.
     * It is permissioned to the `pauser` address, which is expected to be a low threshold multisig.
     * @param newPausedStatus represents the new value for `_paused` to take, which means it may flip several bits at once.
     * @dev This function can only pause functionality, and thus cannot 'unflip' any bit in `_paused` from 1 to 0.
     */
    function pause(uint256 newPausedStatus) external;

    /**
     * @notice Alias for `pause(type(uint256).max)`.
     */
    function pauseAll() external;

    /**
     * @notice This function is used to unpause an EigenLayer contract's functionality.
     * It is permissioned to the `unpauser` address, which is expected to be a high threshold multisig or governance contract.
     * @param newPausedStatus represents the new value for `_paused` to take, which means it may flip several bits at once.
     * @dev This function can only unpause functionality, and thus cannot 'flip' any bit in `_paused` from 0 to 1.
     */
    function unpause(uint256 newPausedStatus) external;

    /// @notice Returns the current paused status as a uint256.
    function paused() external view returns (uint256);

    /// @notice Returns 'true' if the `indexed`th bit of `_paused` is 1, and 'false' otherwise
    function paused(uint8 index) external view returns (bool);

    /// @notice Allows the unpauser to set a new pauser registry
    function setPauserRegistry(IPauserRegistry newPauserRegistry) external;
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/src/contracts/interfaces/IStrategy.sol

/**
 * @title Minimal interface for an `Strategy` contract.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice Custom `Strategy` implementations may expand extensively on this interface.
 */
interface IStrategy {
    /**
     * @notice Used to emit an event for the exchange rate between 1 share and underlying token in a strategy contract
     * @param rate is the exchange rate in wad 18 decimals
     * @dev Tokens that do not have 18 decimals must have offchain services scale the exchange rate by the proper magnitude
     */
    event ExchangeRateEmitted(uint256 rate);

    /**
     * Used to emit the underlying token and its decimals on strategy creation
     * @notice token
     * @param token is the ERC20 token of the strategy
     * @param decimals are the decimals of the ERC20 token in the strategy
     */
    event StrategyTokenSet(IERC20 token, uint8 decimals);

    /**
     * @notice Used to deposit tokens into this Strategy
     * @param token is the ERC20 token being deposited
     * @param amount is the amount of token being deposited
     * @dev This function is only callable by the strategyManager contract. It is invoked inside of the strategyManager's
     * `depositIntoStrategy` function, and individual share balances are recorded in the strategyManager as well.
     * @return newShares is the number of new shares issued at the current exchange ratio.
     */
    function deposit(IERC20 token, uint256 amount) external returns (uint256);

    /**
     * @notice Used to withdraw tokens from this Strategy, to the `recipient`'s address
     * @param recipient is the address to receive the withdrawn funds
     * @param token is the ERC20 token being transferred out
     * @param amountShares is the amount of shares being withdrawn
     * @dev This function is only callable by the strategyManager contract. It is invoked inside of the strategyManager's
     * other functions, and individual share balances are recorded in the strategyManager as well.
     */
    function withdraw(address recipient, IERC20 token, uint256 amountShares) external;

    /**
     * @notice Used to convert a number of shares to the equivalent amount of underlying tokens for this strategy.
     * @notice In contrast to `sharesToUnderlyingView`, this function **may** make state modifications
     * @param amountShares is the amount of shares to calculate its conversion into the underlying token
     * @return The amount of underlying tokens corresponding to the input `amountShares`
     * @dev Implementation for these functions in particular may vary significantly for different strategies
     */
    function sharesToUnderlying(uint256 amountShares) external returns (uint256);

    /**
     * @notice Used to convert an amount of underlying tokens to the equivalent amount of shares in this strategy.
     * @notice In contrast to `underlyingToSharesView`, this function **may** make state modifications
     * @param amountUnderlying is the amount of `underlyingToken` to calculate its conversion into strategy shares
     * @return The amount of underlying tokens corresponding to the input `amountShares`
     * @dev Implementation for these functions in particular may vary significantly for different strategies
     */
    function underlyingToShares(uint256 amountUnderlying) external returns (uint256);

    /**
     * @notice convenience function for fetching the current underlying value of all of the `user`'s shares in
     * this strategy. In contrast to `userUnderlyingView`, this function **may** make state modifications
     */
    function userUnderlying(address user) external returns (uint256);

    /**
     * @notice convenience function for fetching the current total shares of `user` in this strategy, by
     * querying the `strategyManager` contract
     */
    function shares(address user) external view returns (uint256);

    /**
     * @notice Used to convert a number of shares to the equivalent amount of underlying tokens for this strategy.
     * @notice In contrast to `sharesToUnderlying`, this function guarantees no state modifications
     * @param amountShares is the amount of shares to calculate its conversion into the underlying token
     * @return The amount of shares corresponding to the input `amountUnderlying`
     * @dev Implementation for these functions in particular may vary significantly for different strategies
     */
    function sharesToUnderlyingView(uint256 amountShares) external view returns (uint256);

    /**
     * @notice Used to convert an amount of underlying tokens to the equivalent amount of shares in this strategy.
     * @notice In contrast to `underlyingToShares`, this function guarantees no state modifications
     * @param amountUnderlying is the amount of `underlyingToken` to calculate its conversion into strategy shares
     * @return The amount of shares corresponding to the input `amountUnderlying`
     * @dev Implementation for these functions in particular may vary significantly for different strategies
     */
    function underlyingToSharesView(uint256 amountUnderlying) external view returns (uint256);

    /**
     * @notice convenience function for fetching the current underlying value of all of the `user`'s shares in
     * this strategy. In contrast to `userUnderlying`, this function guarantees no state modifications
     */
    function userUnderlyingView(address user) external view returns (uint256);

    /// @notice The underlying token for shares in this Strategy
    function underlyingToken() external view returns (IERC20);

    /// @notice The total number of extant shares in this Strategy
    function totalShares() external view returns (uint256);

    /// @notice Returns either a brief string explaining the strategy's goal & purpose, or a link to metadata that explains in more detail.
    function explanation() external view returns (string memory);
}

// lib/eigenlayer-middleware/src/interfaces/IIndexRegistry.sol

/**
 * @title Interface for a `Registry`-type contract that keeps track of an ordered list of operators for up to 256 quorums.
 * @author Layr Labs, Inc.
 */
interface IIndexRegistry is IRegistry {
    // EVENTS
    
    // emitted when an operator's index in the ordered operator list for the quorum with number `quorumNumber` is updated
    event QuorumIndexUpdate(bytes32 indexed operatorId, uint8 quorumNumber, uint32 newOperatorIndex);

    // DATA STRUCTURES

    // struct used to give definitive ordering to operators at each blockNumber. 
    struct OperatorUpdate {
        // blockNumber number from which `operatorIndex` was the operators index
        // the operator's index is the first entry such that `blockNumber >= entry.fromBlockNumber`
        uint32 fromBlockNumber;
        // the operator at this index
        bytes32 operatorId;
    }

    // struct used to denote the number of operators in a quorum at a given blockNumber
    struct QuorumUpdate {
        // The total number of operators at a `blockNumber` is the first entry such that `blockNumber >= entry.fromBlockNumber`
        uint32 fromBlockNumber;
        // The number of operators at `fromBlockNumber`
        uint32 numOperators;
    }

    /**
     * @notice Registers the operator with the specified `operatorId` for the quorums specified by `quorumNumbers`.
     * @param operatorId is the id of the operator that is being registered
     * @param quorumNumbers is the quorum numbers the operator is registered for
     * @return numOperatorsPerQuorum is a list of the number of operators (including the registering operator) in each of the quorums the operator is registered for
     * @dev access restricted to the RegistryCoordinator
     * @dev Preconditions (these are assumed, not validated in this contract):
     *         1) `quorumNumbers` has no duplicates
     *         2) `quorumNumbers.length` != 0
     *         3) `quorumNumbers` is ordered in ascending order
     *         4) the operator is not already registered
     */
    function registerOperator(bytes32 operatorId, bytes calldata quorumNumbers) external returns(uint32[] memory);

    /**
     * @notice Deregisters the operator with the specified `operatorId` for the quorums specified by `quorumNumbers`.
     * @param operatorId is the id of the operator that is being deregistered
     * @param quorumNumbers is the quorum numbers the operator is deregistered for
     * @dev access restricted to the RegistryCoordinator
     * @dev Preconditions (these are assumed, not validated in this contract):
     *         1) `quorumNumbers` has no duplicates
     *         2) `quorumNumbers.length` != 0
     *         3) `quorumNumbers` is ordered in ascending order
     *         4) the operator is not already deregistered
     *         5) `quorumNumbers` is a subset of the quorumNumbers that the operator is registered for
     */
    function deregisterOperator(bytes32 operatorId, bytes calldata quorumNumbers) external;

    /**
     * @notice Initialize a quorum by pushing its first quorum update
     * @param quorumNumber The number of the new quorum
     */
    function initializeQuorum(uint8 quorumNumber) external;

    /// @notice Returns the OperatorUpdate entry for the specified `operatorIndex` and `quorumNumber` at the specified `arrayIndex`
    function getOperatorUpdateAtIndex(
        uint8 quorumNumber,
        uint32 operatorIndex,
        uint32 arrayIndex
    ) external view returns (OperatorUpdate memory);

    /// @notice Returns the QuorumUpdate entry for the specified `quorumNumber` at the specified `quorumIndex`
    function getQuorumUpdateAtIndex(uint8 quorumNumber, uint32 quorumIndex) external view returns (QuorumUpdate memory);

    /// @notice Returns the most recent OperatorUpdate entry for the specified quorumNumber and operatorIndex
    function getLatestOperatorUpdate(uint8 quorumNumber, uint32 operatorIndex) external view returns (OperatorUpdate memory);

    /// @notice Returns the most recent QuorumUpdate entry for the specified quorumNumber
    function getLatestQuorumUpdate(uint8 quorumNumber) external view returns (QuorumUpdate memory);

    /// @notice Returns the current number of operators of this service for `quorumNumber`.
    function totalOperatorsForQuorum(uint8 quorumNumber) external view returns (uint32);

    /// @notice Returns an ordered list of operators of the services for the given `quorumNumber` at the given `blockNumber`
    function getOperatorListAtBlockNumber(uint8 quorumNumber, uint32 blockNumber) external view returns (bytes32[] memory);
}

// lib/eigenlayer-middleware/src/interfaces/IServiceManagerUI.sol

/**
 * @title Minimal interface for a ServiceManager-type contract that AVS ServiceManager contracts must implement
 * for eigenlabs to be able to index their data on the AVS marketplace frontend.
 * @author Layr Labs, Inc.
 */
interface IServiceManagerUI {
    /**
     * Metadata should follow the format outlined by this example.
        {
            "name": "EigenLabs AVS 1",
            "website": "https://www.eigenlayer.xyz/",
            "description": "This is my 1st AVS",
            "logo": "https://holesky-operator-metadata.s3.amazonaws.com/eigenlayer.png",
            "twitter": "https://twitter.com/eigenlayer"
        }
     * @notice Updates the metadata URI for the AVS
     * @param _metadataURI is the metadata URI for the AVS
     */
    function updateAVSMetadataURI(string memory _metadataURI) external;

    /**
     * @notice Forwards a call to EigenLayer's AVSDirectory contract to confirm operator registration with the AVS
     * @param operator The address of the operator to register.
     * @param operatorSignature The signature, salt, and expiry of the operator's signature.
     */
    function registerOperatorToAVS(
        address operator,
        ISignatureUtils.SignatureWithSaltAndExpiry memory operatorSignature
    ) external;

    /**
     * @notice Forwards a call to EigenLayer's AVSDirectory contract to confirm operator deregistration from the AVS
     * @param operator The address of the operator to deregister.
     */
    function deregisterOperatorFromAVS(address operator) external;

    /**
     * @notice Returns the list of strategies that the operator has potentially restaked on the AVS
     * @param operator The address of the operator to get restaked strategies for
     * @dev This function is intended to be called off-chain
     * @dev No guarantee is made on whether the operator has shares for a strategy in a quorum or uniqueness 
     *      of each element in the returned array. The off-chain service should do that validation separately
     */
    function getOperatorRestakedStrategies(address operator) external view returns (address[] memory);

    /**
     * @notice Returns the list of strategies that the AVS supports for restaking
     * @dev This function is intended to be called off-chain
     * @dev No guarantee is made on uniqueness of each element in the returned array. 
     *      The off-chain service should do that validation separately
     */
    function getRestakeableStrategies() external view returns (address[] memory);

    /// @notice Returns the EigenLayer AVSDirectory contract.
    function avsDirectory() external view returns (address);
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/lib/openzeppelin-contracts/contracts/utils/cryptography/draft-EIP712.sol

// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/lib/openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/src/contracts/interfaces/IRewardsCoordinator.sol

/**
 * @title Interface for the `IRewardsCoordinator` contract.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice Allows AVSs to make "Rewards Submissions", which get distributed amongst the AVSs' confirmed
 * Operators and the Stakers delegated to those Operators.
 * Calculations are performed based on the completed RewardsSubmission, with the results posted in
 * a Merkle root against which Stakers & Operators can make claims.
 */
interface IRewardsCoordinator {
    /// STRUCTS ///
    /**
     * @notice A linear combination of strategies and multipliers for AVSs to weigh
     * EigenLayer strategies.
     * @param strategy The EigenLayer strategy to be used for the rewards submission
     * @param multiplier The weight of the strategy in the rewards submission
     */
    struct StrategyAndMultiplier {
        IStrategy strategy;
        uint96 multiplier;
    }

    /**
     * Sliding Window for valid RewardsSubmission startTimestamp
     *
     * Scenario A: GENESIS_REWARDS_TIMESTAMP IS WITHIN RANGE
     *         <-----MAX_RETROACTIVE_LENGTH-----> t (block.timestamp) <---MAX_FUTURE_LENGTH--->
     *             <--------------------valid range for startTimestamp------------------------>
     *             ^
     *         GENESIS_REWARDS_TIMESTAMP
     *
     *
     * Scenario B: GENESIS_REWARDS_TIMESTAMP IS OUT OF RANGE
     *         <-----MAX_RETROACTIVE_LENGTH-----> t (block.timestamp) <---MAX_FUTURE_LENGTH--->
     *         <------------------------valid range for startTimestamp------------------------>
     *     ^
     * GENESIS_REWARDS_TIMESTAMP
     * @notice RewardsSubmission struct submitted by AVSs when making rewards for their operators and stakers
     * RewardsSubmission can be for a time range within the valid window for startTimestamp and must be within max duration.
     * See `createAVSRewardsSubmission()` for more details.
     * @param strategiesAndMultipliers The strategies and their relative weights
     * cannot have duplicate strategies and need to be sorted in ascending address order
     * @param token The rewards token to be distributed
     * @param amount The total amount of tokens to be distributed
     * @param startTimestamp The timestamp (seconds) at which the submission range is considered for distribution
     * could start in the past or in the future but within a valid range. See the diagram above.
     * @param duration The duration of the submission range in seconds. Must be <= MAX_REWARDS_DURATION
     */
    struct RewardsSubmission {
        StrategyAndMultiplier[] strategiesAndMultipliers;
        IERC20 token;
        uint256 amount;
        uint32 startTimestamp;
        uint32 duration;
    }

    /**
     * @notice A distribution root is a merkle root of the distribution of earnings for a given period.
     * The RewardsCoordinator stores all historical distribution roots so that earners can claim their earnings against older roots
     * if they wish but the merkle tree contains the cumulative earnings of all earners and tokens for a given period so earners (or their claimers if set)
     * only need to claim against the latest root to claim all available earnings.
     * @param root The merkle root of the distribution
     * @param rewardsCalculationEndTimestamp The timestamp (seconds) until which rewards have been calculated
     * @param activatedAt The timestamp (seconds) at which the root can be claimed against
     */
    struct DistributionRoot {
        bytes32 root;
        uint32 rewardsCalculationEndTimestamp;
        uint32 activatedAt;
        bool disabled;
    }

    /**
     * @notice Internal leaf in the merkle tree for the earner's account leaf
     * @param earner The address of the earner
     * @param earnerTokenRoot The merkle root of the earner's token subtree
     * Each leaf in the earner's token subtree is a TokenTreeMerkleLeaf
     */
    struct EarnerTreeMerkleLeaf {
        address earner;
        bytes32 earnerTokenRoot;
    }

    /**
     * @notice The actual leaves in the distribution merkle tree specifying the token earnings
     * for the respective earner's subtree. Each leaf is a claimable amount of a token for an earner.
     * @param token The token for which the earnings are being claimed
     * @param cumulativeEarnings The cumulative earnings of the earner for the token
     */
    struct TokenTreeMerkleLeaf {
        IERC20 token;
        uint256 cumulativeEarnings;
    }

    /**
     * @notice A claim against a distribution root called by an
     * earners claimer (could be the earner themselves). Each token claim will claim the difference
     * between the cumulativeEarnings of the earner and the cumulativeClaimed of the claimer.
     * Each claim can specify which of the earner's earned tokens they want to claim.
     * See `processClaim()` for more details.
     * @param rootIndex The index of the root in the list of DistributionRoots
     * @param earnerIndex The index of the earner's account root in the merkle tree
     * @param earnerTreeProof The proof of the earner's EarnerTreeMerkleLeaf against the merkle root
     * @param earnerLeaf The earner's EarnerTreeMerkleLeaf struct, providing the earner address and earnerTokenRoot
     * @param tokenIndices The indices of the token leaves in the earner's subtree
     * @param tokenTreeProofs The proofs of the token leaves against the earner's earnerTokenRoot
     * @param tokenLeaves The token leaves to be claimed
     * @dev The merkle tree is structured with the merkle root at the top and EarnerTreeMerkleLeaf as internal leaves
     * in the tree. Each earner leaf has its own subtree with TokenTreeMerkleLeaf as leaves in the subtree.
     * To prove a claim against a specified rootIndex(which specifies the distributionRoot being used),
     * the claim will first verify inclusion of the earner leaf in the tree against _distributionRoots[rootIndex].root.
     * Then for each token, it will verify inclusion of the token leaf in the earner's subtree against the earner's earnerTokenRoot.
     */
    struct RewardsMerkleClaim {
        uint32 rootIndex;
        uint32 earnerIndex;
        bytes earnerTreeProof;
        EarnerTreeMerkleLeaf earnerLeaf;
        uint32[] tokenIndices;
        bytes[] tokenTreeProofs;
        TokenTreeMerkleLeaf[] tokenLeaves;
    }

    /// EVENTS ///

    /// @notice emitted when an AVS creates a valid RewardsSubmission
    event AVSRewardsSubmissionCreated(
        address indexed avs,
        uint256 indexed submissionNonce,
        bytes32 indexed rewardsSubmissionHash,
        RewardsSubmission rewardsSubmission
    );
    /// @notice emitted when a valid RewardsSubmission is created for all stakers by a valid submitter
    event RewardsSubmissionForAllCreated(
        address indexed submitter,
        uint256 indexed submissionNonce,
        bytes32 indexed rewardsSubmissionHash,
        RewardsSubmission rewardsSubmission
    );
    /// @notice rewardsUpdater is responsible for submiting DistributionRoots, only owner can set rewardsUpdater
    event RewardsUpdaterSet(address indexed oldRewardsUpdater, address indexed newRewardsUpdater);
    event RewardsForAllSubmitterSet(
        address indexed rewardsForAllSubmitter, bool indexed oldValue, bool indexed newValue
    );
    event ActivationDelaySet(uint32 oldActivationDelay, uint32 newActivationDelay);
    event GlobalCommissionBipsSet(uint16 oldGlobalCommissionBips, uint16 newGlobalCommissionBips);
    event ClaimerForSet(address indexed earner, address indexed oldClaimer, address indexed claimer);
    /// @notice rootIndex is the specific array index of the newly created root in the storage array
    event DistributionRootSubmitted(
        uint32 indexed rootIndex,
        bytes32 indexed root,
        uint32 indexed rewardsCalculationEndTimestamp,
        uint32 activatedAt
    );
    event DistributionRootDisabled(uint32 indexed rootIndex);
    /// @notice root is one of the submitted distribution roots that was claimed against
    event RewardsClaimed(
        bytes32 root,
        address indexed earner,
        address indexed claimer,
        address indexed recipient,
        IERC20 token,
        uint256 claimedAmount
    );

    /**
     *
     *                         VIEW FUNCTIONS
     *
     */

    /// @notice The address of the entity that can update the contract with new merkle roots
    function rewardsUpdater() external view returns (address);

    /**
     * @notice The interval in seconds at which the calculation for a RewardsSubmission distribution is done.
     * @dev Rewards Submission durations must be multiples of this interval.
     */
    function CALCULATION_INTERVAL_SECONDS() external view returns (uint32);

    /// @notice The maximum amount of time (seconds) that a RewardsSubmission can span over
    function MAX_REWARDS_DURATION() external view returns (uint32);

    /// @notice max amount of time (seconds) that a submission can start in the past
    function MAX_RETROACTIVE_LENGTH() external view returns (uint32);

    /// @notice max amount of time (seconds) that a submission can start in the future
    function MAX_FUTURE_LENGTH() external view returns (uint32);

    /// @notice absolute min timestamp (seconds) that a submission can start at
    function GENESIS_REWARDS_TIMESTAMP() external view returns (uint32);

    /// @notice Delay in timestamp (seconds) before a posted root can be claimed against
    function activationDelay() external view returns (uint32);

    /// @notice Mapping: earner => the address of the entity who can call `processClaim` on behalf of the earner
    function claimerFor(address earner) external view returns (address);

    /// @notice Mapping: claimer => token => total amount claimed
    function cumulativeClaimed(address claimer, IERC20 token) external view returns (uint256);

    /// @notice the commission for all operators across all avss
    function globalOperatorCommissionBips() external view returns (uint16);

    /// @notice the commission for a specific operator for a specific avs
    /// NOTE: Currently unused and simply returns the globalOperatorCommissionBips value but will be used in future release
    function operatorCommissionBips(address operator, address avs) external view returns (uint16);

    /// @notice return the hash of the earner's leaf
    function calculateEarnerLeafHash(EarnerTreeMerkleLeaf calldata leaf) external pure returns (bytes32);

    /// @notice returns the hash of the earner's token leaf
    function calculateTokenLeafHash(TokenTreeMerkleLeaf calldata leaf) external pure returns (bytes32);

    /// @notice returns 'true' if the claim would currently pass the check in `processClaims`
    /// but will revert if not valid
    function checkClaim(RewardsMerkleClaim calldata claim) external view returns (bool);

    /// @notice The timestamp until which RewardsSubmissions have been calculated
    function currRewardsCalculationEndTimestamp() external view returns (uint32);

    /// @notice returns the number of distribution roots posted
    function getDistributionRootsLength() external view returns (uint256);

    /// @notice returns the distributionRoot at the specified index
    function getDistributionRootAtIndex(uint256 index) external view returns (DistributionRoot memory);

    /// @notice returns the current distributionRoot
    function getCurrentDistributionRoot() external view returns (DistributionRoot memory);

    /// @notice loop through the distribution roots from reverse and get latest root that is not disabled and activated
    /// i.e. a root that can be claimed against
    function getCurrentClaimableDistributionRoot() external view returns (DistributionRoot memory);

    /// @notice loop through distribution roots from reverse and return index from hash
    function getRootIndexFromHash(bytes32 rootHash) external view returns (uint32);

    /**
     *
     *                         EXTERNAL FUNCTIONS
     *
     */

    /**
     * @notice Creates a new rewards submission on behalf of an AVS, to be split amongst the
     * set of stakers delegated to operators who are registered to the `avs`
     * @param rewardsSubmissions The rewards submissions being created
     * @dev Expected to be called by the ServiceManager of the AVS on behalf of which the submission is being made
     * @dev The duration of the `rewardsSubmission` cannot exceed `MAX_REWARDS_DURATION`
     * @dev The tokens are sent to the `RewardsCoordinator` contract
     * @dev Strategies must be in ascending order of addresses to check for duplicates
     * @dev This function will revert if the `rewardsSubmission` is malformed,
     * e.g. if the `strategies` and `weights` arrays are of non-equal lengths
     */
    function createAVSRewardsSubmission(RewardsSubmission[] calldata rewardsSubmissions) external;

    /**
     * @notice similar to `createAVSRewardsSubmission` except the rewards are split amongst *all* stakers
     * rather than just those delegated to operators who are registered to a single avs and is
     * a permissioned call based on isRewardsForAllSubmitter mapping.
     */
    function createRewardsForAllSubmission(RewardsSubmission[] calldata rewardsSubmission) external;

    /**
     * @notice Claim rewards against a given root (read from _distributionRoots[claim.rootIndex]).
     * Earnings are cumulative so earners don't have to claim against all distribution roots they have earnings for,
     * they can simply claim against the latest root and the contract will calculate the difference between
     * their cumulativeEarnings and cumulativeClaimed. This difference is then transferred to recipient address.
     * @param claim The RewardsMerkleClaim to be processed.
     * Contains the root index, earner, token leaves, and required proofs
     * @param recipient The address recipient that receives the ERC20 rewards
     * @dev only callable by the valid claimer, that is
     * if claimerFor[claim.earner] is address(0) then only the earner can claim, otherwise only
     * claimerFor[claim.earner] can claim the rewards.
     */
    function processClaim(RewardsMerkleClaim calldata claim, address recipient) external;

    /**
     * @notice Creates a new distribution root. activatedAt is set to block.timestamp + activationDelay
     * @param root The merkle root of the distribution
     * @param rewardsCalculationEndTimestamp The timestamp (seconds) until which rewards have been calculated
     * @dev Only callable by the rewardsUpdater
     */
    function submitRoot(bytes32 root, uint32 rewardsCalculationEndTimestamp) external;

    /**
     * @notice allow the rewardsUpdater to disable/cancel a pending root submission in case of an error
     * @param rootIndex The index of the root to be disabled
     */
    function disableRoot(uint32 rootIndex) external;

    /**
     * @notice Sets the address of the entity that can call `processClaim` on behalf of the earner (msg.sender)
     * @param claimer The address of the entity that can claim rewards on behalf of the earner
     * @dev Only callable by the `earner`
     */
    function setClaimerFor(address claimer) external;

    /**
     * @notice Sets the delay in timestamp before a posted root can be claimed against
     * @param _activationDelay Delay in timestamp (seconds) before a posted root can be claimed against
     * @dev Only callable by the contract owner
     */
    function setActivationDelay(uint32 _activationDelay) external;

    /**
     * @notice Sets the global commission for all operators across all avss
     * @param _globalCommissionBips The commission for all operators across all avss
     * @dev Only callable by the contract owner
     */
    function setGlobalOperatorCommission(uint16 _globalCommissionBips) external;

    /**
     * @notice Sets the permissioned `rewardsUpdater` address which can post new roots
     * @dev Only callable by the contract owner
     */
    function setRewardsUpdater(address _rewardsUpdater) external;

    /**
     * @notice Sets the permissioned `rewardsForAllSubmitter` address which can submit createRewardsForAllSubmission
     * @dev Only callable by the contract owner
     * @param _submitter The address of the rewardsForAllSubmitter
     * @param _newValue The new value for isRewardsForAllSubmitter
     */
    function setRewardsForAllSubmitter(address _submitter, bool _newValue) external;
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/src/contracts/permissions/Pausable.sol

/**
 * @title Adds pausability to a contract, with pausing & unpausing controlled by the `pauser` and `unpauser` of a PauserRegistry contract.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice Contracts that inherit from this contract may define their own `pause` and `unpause` (and/or related) functions.
 * These functions should be permissioned as "onlyPauser" which defers to a `PauserRegistry` for determining access control.
 * @dev Pausability is implemented using a uint256, which allows up to 256 different single bit-flags; each bit can potentially pause different functionality.
 * Inspiration for this was taken from the NearBridge design here https://etherscan.io/address/0x3FEFc5A4B1c02f21cBc8D3613643ba0635b9a873#code.
 * For the `pause` and `unpause` functions we've implemented, if you pause, you can only flip (any number of) switches to on/1 (aka "paused"), and if you unpause,
 * you can only flip (any number of) switches to off/0 (aka "paused").
 * If you want a pauseXYZ function that just flips a single bit / "pausing flag", it will:
 * 1) 'bit-wise and' (aka `&`) a flag with the current paused state (as a uint256)
 * 2) update the paused state to this new value
 * @dev We note as well that we have chosen to identify flags by their *bit index* as opposed to their numerical value, so, e.g. defining `DEPOSITS_PAUSED = 3`
 * indicates specifically that if the *third bit* of `_paused` is flipped -- i.e. it is a '1' -- then deposits should be paused
 */
contract Pausable is IPausable {
    /// @notice Address of the `PauserRegistry` contract that this contract defers to for determining access control (for pausing).
    IPauserRegistry public pauserRegistry;

    /// @dev whether or not the contract is currently paused
    uint256 private _paused;

    uint256 internal constant UNPAUSE_ALL = 0;
    uint256 internal constant PAUSE_ALL = type(uint256).max;

    /// @notice
    modifier onlyPauser() {
        require(pauserRegistry.isPauser(msg.sender), "msg.sender is not permissioned as pauser");
        _;
    }

    modifier onlyUnpauser() {
        require(msg.sender == pauserRegistry.unpauser(), "msg.sender is not permissioned as unpauser");
        _;
    }

    /// @notice Throws if the contract is paused, i.e. if any of the bits in `_paused` is flipped to 1.
    modifier whenNotPaused() {
        require(_paused == 0, "Pausable: contract is paused");
        _;
    }

    /// @notice Throws if the `indexed`th bit of `_paused` is 1, i.e. if the `index`th pause switch is flipped.
    modifier onlyWhenNotPaused(uint8 index) {
        require(!paused(index), "Pausable: index is paused");
        _;
    }

    /// @notice One-time function for setting the `pauserRegistry` and initializing the value of `_paused`.
    function _initializePauser(IPauserRegistry _pauserRegistry, uint256 initPausedStatus) internal {
        require(
            address(pauserRegistry) == address(0) && address(_pauserRegistry) != address(0),
            "Pausable._initializePauser: _initializePauser() can only be called once"
        );
        _paused = initPausedStatus;
        emit Paused(msg.sender, initPausedStatus);
        _setPauserRegistry(_pauserRegistry);
    }

    /**
     * @notice This function is used to pause an EigenLayer contract's functionality.
     * It is permissioned to the `pauser` address, which is expected to be a low threshold multisig.
     * @param newPausedStatus represents the new value for `_paused` to take, which means it may flip several bits at once.
     * @dev This function can only pause functionality, and thus cannot 'unflip' any bit in `_paused` from 1 to 0.
     */
    function pause(uint256 newPausedStatus) external onlyPauser {
        // verify that the `newPausedStatus` does not *unflip* any bits (i.e. doesn't unpause anything, all 1 bits remain)
        require((_paused & newPausedStatus) == _paused, "Pausable.pause: invalid attempt to unpause functionality");
        _paused = newPausedStatus;
        emit Paused(msg.sender, newPausedStatus);
    }

    /**
     * @notice Alias for `pause(type(uint256).max)`.
     */
    function pauseAll() external onlyPauser {
        _paused = type(uint256).max;
        emit Paused(msg.sender, type(uint256).max);
    }

    /**
     * @notice This function is used to unpause an EigenLayer contract's functionality.
     * It is permissioned to the `unpauser` address, which is expected to be a high threshold multisig or governance contract.
     * @param newPausedStatus represents the new value for `_paused` to take, which means it may flip several bits at once.
     * @dev This function can only unpause functionality, and thus cannot 'flip' any bit in `_paused` from 0 to 1.
     */
    function unpause(uint256 newPausedStatus) external onlyUnpauser {
        // verify that the `newPausedStatus` does not *flip* any bits (i.e. doesn't pause anything, all 0 bits remain)
        require(
            ((~_paused) & (~newPausedStatus)) == (~_paused), "Pausable.unpause: invalid attempt to pause functionality"
        );
        _paused = newPausedStatus;
        emit Unpaused(msg.sender, newPausedStatus);
    }

    /// @notice Returns the current paused status as a uint256.
    function paused() public view virtual returns (uint256) {
        return _paused;
    }

    /// @notice Returns 'true' if the `indexed`th bit of `_paused` is 1, and 'false' otherwise
    function paused(uint8 index) public view virtual returns (bool) {
        uint256 mask = 1 << index;
        return ((_paused & mask) == mask);
    }

    /// @notice Allows the unpauser to set a new pauser registry
    function setPauserRegistry(IPauserRegistry newPauserRegistry) external onlyUnpauser {
        _setPauserRegistry(newPauserRegistry);
    }

    /// internal function for setting pauser registry
    function _setPauserRegistry(IPauserRegistry newPauserRegistry) internal {
        require(
            address(newPauserRegistry) != address(0),
            "Pausable._setPauserRegistry: newPauserRegistry cannot be the zero address"
        );
        emit PauserRegistrySet(pauserRegistry, newPauserRegistry);
        pauserRegistry = newPauserRegistry;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;
}

// lib/eigenlayer-middleware/src/interfaces/IBLSApkRegistry.sol

/**
 * @title Minimal interface for a registry that keeps track of aggregate operator public keys across many quorums.
 * @author Layr Labs, Inc.
 */
interface IBLSApkRegistry is IRegistry {
    // STRUCTS
    /// @notice Data structure used to track the history of the Aggregate Public Key of all operators
    struct ApkUpdate {
        // first 24 bytes of keccak256(apk_x0, apk_x1, apk_y0, apk_y1)
        bytes24 apkHash;
        // block number at which the update occurred
        uint32 updateBlockNumber;
        // block number at which the next update occurred
        uint32 nextUpdateBlockNumber;
    }

    /**
     * @notice Struct used when registering a new public key
     * @param pubkeyRegistrationSignature is the registration message signed by the private key of the operator
     * @param pubkeyG1 is the corresponding G1 public key of the operator 
     * @param pubkeyG2 is the corresponding G2 public key of the operator
     */     
    struct PubkeyRegistrationParams {
        BN254.G1Point pubkeyRegistrationSignature;
        BN254.G1Point pubkeyG1;
        BN254.G2Point pubkeyG2;
    }

    // EVENTS
    /// @notice Emitted when `operator` registers with the public keys `pubkeyG1` and `pubkeyG2`.
    event NewPubkeyRegistration(address indexed operator, BN254.G1Point pubkeyG1, BN254.G2Point pubkeyG2);

    // @notice Emitted when a new operator pubkey is registered for a set of quorums
    event OperatorAddedToQuorums(
        address operator,
        bytes32 operatorId,
        bytes quorumNumbers
    );

    // @notice Emitted when an operator pubkey is removed from a set of quorums
    event OperatorRemovedFromQuorums(
        address operator, 
        bytes32 operatorId,
        bytes quorumNumbers
    );

    /**
     * @notice Registers the `operator`'s pubkey for the specified `quorumNumbers`.
     * @param operator The address of the operator to register.
     * @param quorumNumbers The quorum numbers the operator is registering for, where each byte is an 8 bit integer quorumNumber.
     * @dev access restricted to the RegistryCoordinator
     * @dev Preconditions (these are assumed, not validated in this contract):
     *         1) `quorumNumbers` has no duplicates
     *         2) `quorumNumbers.length` != 0
     *         3) `quorumNumbers` is ordered in ascending order
     *         4) the operator is not already registered
     */
    function registerOperator(address operator, bytes calldata quorumNumbers) external;

    /**
     * @notice Deregisters the `operator`'s pubkey for the specified `quorumNumbers`.
     * @param operator The address of the operator to deregister.
     * @param quorumNumbers The quorum numbers the operator is deregistering from, where each byte is an 8 bit integer quorumNumber.
     * @dev access restricted to the RegistryCoordinator
     * @dev Preconditions (these are assumed, not validated in this contract):
     *         1) `quorumNumbers` has no duplicates
     *         2) `quorumNumbers.length` != 0
     *         3) `quorumNumbers` is ordered in ascending order
     *         4) the operator is not already deregistered
     *         5) `quorumNumbers` is a subset of the quorumNumbers that the operator is registered for
     */ 
    function deregisterOperator(address operator, bytes calldata quorumNumbers) external;
    
    /**
     * @notice Initializes a new quorum by pushing its first apk update
     * @param quorumNumber The number of the new quorum
     */
    function initializeQuorum(uint8 quorumNumber) external;

    /**
     * @notice mapping from operator address to pubkey hash.
     * Returns *zero* if the `operator` has never registered, and otherwise returns the hash of the public key of the operator.
     */
    function operatorToPubkeyHash(address operator) external view returns (bytes32);

    /**
     * @notice mapping from pubkey hash to operator address.
     * Returns *zero* if no operator has ever registered the public key corresponding to `pubkeyHash`,
     * and otherwise returns the (unique) registered operator who owns the BLS public key that is the preimage of `pubkeyHash`.
     */
    function pubkeyHashToOperator(bytes32 pubkeyHash) external view returns (address);

    /**
     * @notice Called by the RegistryCoordinator register an operator as the owner of a BLS public key.
     * @param operator is the operator for whom the key is being registered
     * @param params contains the G1 & G2 public keys of the operator, and a signature proving their ownership
     * @param pubkeyRegistrationMessageHash is a hash that the operator must sign to prove key ownership
     */
    function registerBLSPublicKey(
        address operator,
        PubkeyRegistrationParams calldata params,
        BN254.G1Point calldata pubkeyRegistrationMessageHash
    ) external returns (bytes32 operatorId);

    /**
     * @notice Returns the pubkey and pubkey hash of an operator
     * @dev Reverts if the operator has not registered a valid pubkey
     */
    function getRegisteredPubkey(address operator) external view returns (BN254.G1Point memory, bytes32);

    /// @notice Returns the current APK for the provided `quorumNumber `
    function getApk(uint8 quorumNumber) external view returns (BN254.G1Point memory);

    /// @notice Returns the index of the quorumApk index at `blockNumber` for the provided `quorumNumber`
    function getApkIndicesAtBlockNumber(bytes calldata quorumNumbers, uint256 blockNumber) external view returns(uint32[] memory);

    /// @notice Returns the `ApkUpdate` struct at `index` in the list of APK updates for the `quorumNumber`
    function getApkUpdateAtIndex(uint8 quorumNumber, uint256 index) external view returns (ApkUpdate memory);

    /// @notice Returns the operator address for the given `pubkeyHash`
    function getOperatorFromPubkeyHash(bytes32 pubkeyHash) external view returns (address);

    /**
     * @notice get 24 byte hash of the apk of `quorumNumber` at `blockNumber` using the provided `index`;
     * called by checkSignatures in BLSSignatureChecker.sol.
     * @param quorumNumber is the quorum whose ApkHash is being retrieved
     * @param blockNumber is the number of the block for which the latest ApkHash will be retrieved
     * @param index is the index of the apkUpdate being retrieved from the list of quorum apkUpdates in storage
     */
    function getApkHashAtBlockNumberAndIndex(uint8 quorumNumber, uint32 blockNumber, uint256 index) external view returns (bytes24);

    /// @notice returns the ID used to identify the `operator` within this AVS.
    /// @dev Returns zero in the event that the `operator` has never registered for the AVS
    function getOperatorId(address operator) external view returns (bytes32);
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/src/contracts/interfaces/IDelegationManager.sol

/**
 * @title DelegationManager
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice  This is the contract for delegation in EigenLayer. The main functionalities of this contract are
 * - enabling anyone to register as an operator in EigenLayer
 * - allowing operators to specify parameters related to stakers who delegate to them
 * - enabling any staker to delegate its stake to the operator of its choice (a given staker can only delegate to a single operator at a time)
 * - enabling a staker to undelegate its assets from the operator it is delegated to (performed as part of the withdrawal process, initiated through the StrategyManager)
 */
interface IDelegationManager is ISignatureUtils {
    // @notice Struct used for storing information about a single operator who has registered with EigenLayer
    struct OperatorDetails {
        /// @notice DEPRECATED -- this field is no longer used, payments are handled in PaymentCoordinator.sol
        address __deprecated_earningsReceiver;
        /**
         * @notice Address to verify signatures when a staker wishes to delegate to the operator, as well as controlling "forced undelegations".
         * @dev Signature verification follows these rules:
         * 1) If this address is left as address(0), then any staker will be free to delegate to the operator, i.e. no signature verification will be performed.
         * 2) If this address is an EOA (i.e. it has no code), then we follow standard ECDSA signature verification for delegations to the operator.
         * 3) If this address is a contract (i.e. it has code) then we forward a call to the contract and verify that it returns the correct EIP-1271 "magic value".
         */
        address delegationApprover;
        /**
         * @notice A minimum delay -- measured in blocks -- enforced between:
         * 1) the operator signalling their intent to register for a service, via calling `Slasher.optIntoSlashing`
         * and
         * 2) the operator completing registration for the service, via the service ultimately calling `Slasher.recordFirstStakeUpdate`
         * @dev note that for a specific operator, this value *cannot decrease*, i.e. if the operator wishes to modify their OperatorDetails,
         * then they are only allowed to either increase this value or keep it the same.
         */
        uint32 stakerOptOutWindowBlocks;
    }

    /**
     * @notice Abstract struct used in calculating an EIP712 signature for a staker to approve that they (the staker themselves) delegate to a specific operator.
     * @dev Used in computing the `STAKER_DELEGATION_TYPEHASH` and as a reference in the computation of the stakerDigestHash in the `delegateToBySignature` function.
     */
    struct StakerDelegation {
        // the staker who is delegating
        address staker;
        // the operator being delegated to
        address operator;
        // the staker's nonce
        uint256 nonce;
        // the expiration timestamp (UTC) of the signature
        uint256 expiry;
    }

    /**
     * @notice Abstract struct used in calculating an EIP712 signature for an operator's delegationApprover to approve that a specific staker delegate to the operator.
     * @dev Used in computing the `DELEGATION_APPROVAL_TYPEHASH` and as a reference in the computation of the approverDigestHash in the `_delegate` function.
     */
    struct DelegationApproval {
        // the staker who is delegating
        address staker;
        // the operator being delegated to
        address operator;
        // the operator's provided salt
        bytes32 salt;
        // the expiration timestamp (UTC) of the signature
        uint256 expiry;
    }

    /**
     * Struct type used to specify an existing queued withdrawal. Rather than storing the entire struct, only a hash is stored.
     * In functions that operate on existing queued withdrawals -- e.g. completeQueuedWithdrawal`, the data is resubmitted and the hash of the submitted
     * data is computed by `calculateWithdrawalRoot` and checked against the stored hash in order to confirm the integrity of the submitted data.
     */
    struct Withdrawal {
        // The address that originated the Withdrawal
        address staker;
        // The address that the staker was delegated to at the time that the Withdrawal was created
        address delegatedTo;
        // The address that can complete the Withdrawal + will receive funds when completing the withdrawal
        address withdrawer;
        // Nonce used to guarantee that otherwise identical withdrawals have unique hashes
        uint256 nonce;
        // Block number when the Withdrawal was created
        uint32 startBlock;
        // Array of strategies that the Withdrawal contains
        IStrategy[] strategies;
        // Array containing the amount of shares in each Strategy in the `strategies` array
        uint256[] shares;
    }

    struct QueuedWithdrawalParams {
        // Array of strategies that the QueuedWithdrawal contains
        IStrategy[] strategies;
        // Array containing the amount of shares in each Strategy in the `strategies` array
        uint256[] shares;
        // The address of the withdrawer
        address withdrawer;
    }

    // @notice Emitted when a new operator registers in EigenLayer and provides their OperatorDetails.
    event OperatorRegistered(address indexed operator, OperatorDetails operatorDetails);

    /// @notice Emitted when an operator updates their OperatorDetails to @param newOperatorDetails
    event OperatorDetailsModified(address indexed operator, OperatorDetails newOperatorDetails);

    /**
     * @notice Emitted when @param operator indicates that they are updating their MetadataURI string
     * @dev Note that these strings are *never stored in storage* and are instead purely emitted in events for off-chain indexing
     */
    event OperatorMetadataURIUpdated(address indexed operator, string metadataURI);

    /// @notice Emitted whenever an operator's shares are increased for a given strategy. Note that shares is the delta in the operator's shares.
    event OperatorSharesIncreased(address indexed operator, address staker, IStrategy strategy, uint256 shares);

    /// @notice Emitted whenever an operator's shares are decreased for a given strategy. Note that shares is the delta in the operator's shares.
    event OperatorSharesDecreased(address indexed operator, address staker, IStrategy strategy, uint256 shares);

    /// @notice Emitted when @param staker delegates to @param operator.
    event StakerDelegated(address indexed staker, address indexed operator);

    /// @notice Emitted when @param staker undelegates from @param operator.
    event StakerUndelegated(address indexed staker, address indexed operator);

    /// @notice Emitted when @param staker is undelegated via a call not originating from the staker themself
    event StakerForceUndelegated(address indexed staker, address indexed operator);

    /**
     * @notice Emitted when a new withdrawal is queued.
     * @param withdrawalRoot Is the hash of the `withdrawal`.
     * @param withdrawal Is the withdrawal itself.
     */
    event WithdrawalQueued(bytes32 withdrawalRoot, Withdrawal withdrawal);

    /// @notice Emitted when a queued withdrawal is completed
    event WithdrawalCompleted(bytes32 withdrawalRoot);

    /// @notice Emitted when the `minWithdrawalDelayBlocks` variable is modified from `previousValue` to `newValue`.
    event MinWithdrawalDelayBlocksSet(uint256 previousValue, uint256 newValue);

    /// @notice Emitted when the `strategyWithdrawalDelayBlocks` variable is modified from `previousValue` to `newValue`.
    event StrategyWithdrawalDelayBlocksSet(IStrategy strategy, uint256 previousValue, uint256 newValue);

    /**
     * @notice Registers the caller as an operator in EigenLayer.
     * @param registeringOperatorDetails is the `OperatorDetails` for the operator.
     * @param metadataURI is a URI for the operator's metadata, i.e. a link providing more details on the operator.
     *
     * @dev Once an operator is registered, they cannot 'deregister' as an operator, and they will forever be considered "delegated to themself".
     * @dev Note that the `metadataURI` is *never stored * and is only emitted in the `OperatorMetadataURIUpdated` event
     */
    function registerAsOperator(
        OperatorDetails calldata registeringOperatorDetails,
        string calldata metadataURI
    ) external;

    /**
     * @notice Updates an operator's stored `OperatorDetails`.
     * @param newOperatorDetails is the updated `OperatorDetails` for the operator, to replace their current OperatorDetails`.
     *
     * @dev The caller must have previously registered as an operator in EigenLayer.
     */
    function modifyOperatorDetails(OperatorDetails calldata newOperatorDetails) external;

    /**
     * @notice Called by an operator to emit an `OperatorMetadataURIUpdated` event indicating the information has updated.
     * @param metadataURI The URI for metadata associated with an operator
     * @dev Note that the `metadataURI` is *never stored * and is only emitted in the `OperatorMetadataURIUpdated` event
     */
    function updateOperatorMetadataURI(string calldata metadataURI) external;

    /**
     * @notice Caller delegates their stake to an operator.
     * @param operator The account (`msg.sender`) is delegating its assets to for use in serving applications built on EigenLayer.
     * @param approverSignatureAndExpiry Verifies the operator approves of this delegation
     * @param approverSalt A unique single use value tied to an individual signature.
     * @dev The approverSignatureAndExpiry is used in the event that:
     *          1) the operator's `delegationApprover` address is set to a non-zero value.
     *                  AND
     *          2) neither the operator nor their `delegationApprover` is the `msg.sender`, since in the event that the operator
     *             or their delegationApprover is the `msg.sender`, then approval is assumed.
     * @dev In the event that `approverSignatureAndExpiry` is not checked, its content is ignored entirely; it's recommended to use an empty input
     * in this case to save on complexity + gas costs
     */
    function delegateTo(
        address operator,
        SignatureWithExpiry memory approverSignatureAndExpiry,
        bytes32 approverSalt
    ) external;

    /**
     * @notice Caller delegates a staker's stake to an operator with valid signatures from both parties.
     * @param staker The account delegating stake to an `operator` account
     * @param operator The account (`staker`) is delegating its assets to for use in serving applications built on EigenLayer.
     * @param stakerSignatureAndExpiry Signed data from the staker authorizing delegating stake to an operator
     * @param approverSignatureAndExpiry is a parameter that will be used for verifying that the operator approves of this delegation action in the event that:
     * @param approverSalt Is a salt used to help guarantee signature uniqueness. Each salt can only be used once by a given approver.
     *
     * @dev If `staker` is an EOA, then `stakerSignature` is verified to be a valid ECDSA stakerSignature from `staker`, indicating their intention for this action.
     * @dev If `staker` is a contract, then `stakerSignature` will be checked according to EIP-1271.
     * @dev the operator's `delegationApprover` address is set to a non-zero value.
     * @dev neither the operator nor their `delegationApprover` is the `msg.sender`, since in the event that the operator or their delegationApprover
     * is the `msg.sender`, then approval is assumed.
     * @dev This function will revert if the current `block.timestamp` is equal to or exceeds the expiry
     * @dev In the case that `approverSignatureAndExpiry` is not checked, its content is ignored entirely; it's recommended to use an empty input
     * in this case to save on complexity + gas costs
     */
    function delegateToBySignature(
        address staker,
        address operator,
        SignatureWithExpiry memory stakerSignatureAndExpiry,
        SignatureWithExpiry memory approverSignatureAndExpiry,
        bytes32 approverSalt
    ) external;

    /**
     * @notice Undelegates the staker from the operator who they are delegated to. Puts the staker into the "undelegation limbo" mode of the EigenPodManager
     * and queues a withdrawal of all of the staker's shares in the StrategyManager (to the staker), if necessary.
     * @param staker The account to be undelegated.
     * @return withdrawalRoot The root of the newly queued withdrawal, if a withdrawal was queued. Otherwise just bytes32(0).
     *
     * @dev Reverts if the `staker` is also an operator, since operators are not allowed to undelegate from themselves.
     * @dev Reverts if the caller is not the staker, nor the operator who the staker is delegated to, nor the operator's specified "delegationApprover"
     * @dev Reverts if the `staker` is already undelegated.
     */
    function undelegate(address staker) external returns (bytes32[] memory withdrawalRoot);

    /**
     * Allows a staker to withdraw some shares. Withdrawn shares/strategies are immediately removed
     * from the staker. If the staker is delegated, withdrawn shares/strategies are also removed from
     * their operator.
     *
     * All withdrawn shares/strategies are placed in a queue and can be fully withdrawn after a delay.
     */
    function queueWithdrawals(QueuedWithdrawalParams[] calldata queuedWithdrawalParams)
        external
        returns (bytes32[] memory);

    /**
     * @notice Used to complete the specified `withdrawal`. The caller must match `withdrawal.withdrawer`
     * @param withdrawal The Withdrawal to complete.
     * @param tokens Array in which the i-th entry specifies the `token` input to the 'withdraw' function of the i-th Strategy in the `withdrawal.strategies` array.
     * This input can be provided with zero length if `receiveAsTokens` is set to 'false' (since in that case, this input will be unused)
     * @param middlewareTimesIndex is the index in the operator that the staker who triggered the withdrawal was delegated to's middleware times array
     * @param receiveAsTokens If true, the shares specified in the withdrawal will be withdrawn from the specified strategies themselves
     * and sent to the caller, through calls to `withdrawal.strategies[i].withdraw`. If false, then the shares in the specified strategies
     * will simply be transferred to the caller directly.
     * @dev middlewareTimesIndex should be calculated off chain before calling this function by finding the first index that satisfies `slasher.canWithdraw`
     * @dev beaconChainETHStrategy shares are non-transferrable, so if `receiveAsTokens = false` and `withdrawal.withdrawer != withdrawal.staker`, note that
     * any beaconChainETHStrategy shares in the `withdrawal` will be _returned to the staker_, rather than transferred to the withdrawer, unlike shares in
     * any other strategies, which will be transferred to the withdrawer.
     */
    function completeQueuedWithdrawal(
        Withdrawal calldata withdrawal,
        IERC20[] calldata tokens,
        uint256 middlewareTimesIndex,
        bool receiveAsTokens
    ) external;

    /**
     * @notice Array-ified version of `completeQueuedWithdrawal`.
     * Used to complete the specified `withdrawals`. The function caller must match `withdrawals[...].withdrawer`
     * @param withdrawals The Withdrawals to complete.
     * @param tokens Array of tokens for each Withdrawal. See `completeQueuedWithdrawal` for the usage of a single array.
     * @param middlewareTimesIndexes One index to reference per Withdrawal. See `completeQueuedWithdrawal` for the usage of a single index.
     * @param receiveAsTokens Whether or not to complete each withdrawal as tokens. See `completeQueuedWithdrawal` for the usage of a single boolean.
     * @dev See `completeQueuedWithdrawal` for relevant dev tags
     */
    function completeQueuedWithdrawals(
        Withdrawal[] calldata withdrawals,
        IERC20[][] calldata tokens,
        uint256[] calldata middlewareTimesIndexes,
        bool[] calldata receiveAsTokens
    ) external;

    /**
     * @notice Increases a staker's delegated share balance in a strategy.
     * @param staker The address to increase the delegated shares for their operator.
     * @param strategy The strategy in which to increase the delegated shares.
     * @param shares The number of shares to increase.
     *
     * @dev *If the staker is actively delegated*, then increases the `staker`'s delegated shares in `strategy` by `shares`. Otherwise does nothing.
     * @dev Callable only by the StrategyManager or EigenPodManager.
     */
    function increaseDelegatedShares(address staker, IStrategy strategy, uint256 shares) external;

    /**
     * @notice Decreases a staker's delegated share balance in a strategy.
     * @param staker The address to increase the delegated shares for their operator.
     * @param strategy The strategy in which to decrease the delegated shares.
     * @param shares The number of shares to decrease.
     *
     * @dev *If the staker is actively delegated*, then decreases the `staker`'s delegated shares in `strategy` by `shares`. Otherwise does nothing.
     * @dev Callable only by the StrategyManager or EigenPodManager.
     */
    function decreaseDelegatedShares(address staker, IStrategy strategy, uint256 shares) external;

    /**
     * @notice returns the address of the operator that `staker` is delegated to.
     * @notice Mapping: staker => operator whom the staker is currently delegated to.
     * @dev Note that returning address(0) indicates that the staker is not actively delegated to any operator.
     */
    function delegatedTo(address staker) external view returns (address);

    /**
     * @notice Returns the OperatorDetails struct associated with an `operator`.
     */
    function operatorDetails(address operator) external view returns (OperatorDetails memory);

    /**
     * @notice Returns the delegationApprover account for an operator
     */
    function delegationApprover(address operator) external view returns (address);

    /**
     * @notice Returns the stakerOptOutWindowBlocks for an operator
     */
    function stakerOptOutWindowBlocks(address operator) external view returns (uint256);

    /**
     * @notice Given array of strategies, returns array of shares for the operator
     */
    function getOperatorShares(
        address operator,
        IStrategy[] memory strategies
    ) external view returns (uint256[] memory);

    /**
     * @notice Given a list of strategies, return the minimum number of blocks that must pass to withdraw
     * from all the inputted strategies. Return value is >= minWithdrawalDelayBlocks as this is the global min withdrawal delay.
     * @param strategies The strategies to check withdrawal delays for
     */
    function getWithdrawalDelay(IStrategy[] calldata strategies) external view returns (uint256);

    /**
     * @notice returns the total number of shares in `strategy` that are delegated to `operator`.
     * @notice Mapping: operator => strategy => total number of shares in the strategy delegated to the operator.
     * @dev By design, the following invariant should hold for each Strategy:
     * (operator's shares in delegation manager) = sum (shares above zero of all stakers delegated to operator)
     * = sum (delegateable shares of all stakers delegated to the operator)
     */
    function operatorShares(address operator, IStrategy strategy) external view returns (uint256);

    /**
     * @notice Returns 'true' if `staker` *is* actively delegated, and 'false' otherwise.
     */
    function isDelegated(address staker) external view returns (bool);

    /**
     * @notice Returns true is an operator has previously registered for delegation.
     */
    function isOperator(address operator) external view returns (bool);

    /// @notice Mapping: staker => number of signed delegation nonces (used in `delegateToBySignature`) from the staker that the contract has already checked
    function stakerNonce(address staker) external view returns (uint256);

    /**
     * @notice Mapping: delegationApprover => 32-byte salt => whether or not the salt has already been used by the delegationApprover.
     * @dev Salts are used in the `delegateTo` and `delegateToBySignature` functions. Note that these functions only process the delegationApprover's
     * signature + the provided salt if the operator being delegated to has specified a nonzero address as their `delegationApprover`.
     */
    function delegationApproverSaltIsSpent(address _delegationApprover, bytes32 salt) external view returns (bool);

    /**
     * @notice Minimum delay enforced by this contract for completing queued withdrawals. Measured in blocks, and adjustable by this contract's owner,
     * up to a maximum of `MAX_WITHDRAWAL_DELAY_BLOCKS`. Minimum value is 0 (i.e. no delay enforced).
     * Note that strategies each have a separate withdrawal delay, which can be greater than this value. So the minimum number of blocks that must pass
     * to withdraw a strategy is MAX(minWithdrawalDelayBlocks, strategyWithdrawalDelayBlocks[strategy])
     */
    function minWithdrawalDelayBlocks() external view returns (uint256);

    /**
     * @notice Minimum delay enforced by this contract per Strategy for completing queued withdrawals. Measured in blocks, and adjustable by this contract's owner,
     * up to a maximum of `MAX_WITHDRAWAL_DELAY_BLOCKS`. Minimum value is 0 (i.e. no delay enforced).
     */
    function strategyWithdrawalDelayBlocks(IStrategy strategy) external view returns (uint256);

    /// @notice return address of the beaconChainETHStrategy
    function beaconChainETHStrategy() external view returns (IStrategy);

    /**
     * @notice Calculates the digestHash for a `staker` to sign to delegate to an `operator`
     * @param staker The signing staker
     * @param operator The operator who is being delegated to
     * @param expiry The desired expiry time of the staker's signature
     */
    function calculateCurrentStakerDelegationDigestHash(
        address staker,
        address operator,
        uint256 expiry
    ) external view returns (bytes32);

    /**
     * @notice Calculates the digest hash to be signed and used in the `delegateToBySignature` function
     * @param staker The signing staker
     * @param _stakerNonce The nonce of the staker. In practice we use the staker's current nonce, stored at `stakerNonce[staker]`
     * @param operator The operator who is being delegated to
     * @param expiry The desired expiry time of the staker's signature
     */
    function calculateStakerDelegationDigestHash(
        address staker,
        uint256 _stakerNonce,
        address operator,
        uint256 expiry
    ) external view returns (bytes32);

    /**
     * @notice Calculates the digest hash to be signed by the operator's delegationApprove and used in the `delegateTo` and `delegateToBySignature` functions.
     * @param staker The account delegating their stake
     * @param operator The account receiving delegated stake
     * @param _delegationApprover the operator's `delegationApprover` who will be signing the delegationHash (in general)
     * @param approverSalt A unique and single use value associated with the approver signature.
     * @param expiry Time after which the approver's signature becomes invalid
     */
    function calculateDelegationApprovalDigestHash(
        address staker,
        address operator,
        address _delegationApprover,
        bytes32 approverSalt,
        uint256 expiry
    ) external view returns (bytes32);

    /// @notice The EIP-712 typehash for the contract's domain
    function DOMAIN_TYPEHASH() external view returns (bytes32);

    /// @notice The EIP-712 typehash for the StakerDelegation struct used by the contract
    function STAKER_DELEGATION_TYPEHASH() external view returns (bytes32);

    /// @notice The EIP-712 typehash for the DelegationApproval struct used by the contract
    function DELEGATION_APPROVAL_TYPEHASH() external view returns (bytes32);

    /**
     * @notice Getter function for the current EIP-712 domain separator for this contract.
     *
     * @dev The domain separator will change in the event of a fork that changes the ChainID.
     * @dev By introducing a domain separator the DApp developers are guaranteed that there can be no signature collision.
     * for more detailed information please read EIP-712.
     */
    function domainSeparator() external view returns (bytes32);

    /// @notice Mapping: staker => cumulative number of queued withdrawals they have ever initiated.
    /// @dev This only increments (doesn't decrement), and is used to help ensure that otherwise identical withdrawals have unique hashes.
    function cumulativeWithdrawalsQueued(address staker) external view returns (uint256);

    /// @notice Returns the keccak256 hash of `withdrawal`.
    function calculateWithdrawalRoot(Withdrawal memory withdrawal) external pure returns (bytes32);
}

// lib/eigenlayer-middleware/lib/eigenlayer-contracts/src/contracts/libraries/EIP1271SignatureUtils.sol

/**
 * @title Library of utilities for making EIP1271-compliant signature checks.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 */
library EIP1271SignatureUtils {
    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 internal constant EIP1271_MAGICVALUE = 0x1626ba7e;

    /**
     * @notice Checks @param signature is a valid signature of @param digestHash from @param signer.
     * If the `signer` contains no code -- i.e. it is not (yet, at least) a contract address, then checks using standard ECDSA logic
     * Otherwise, passes on the signature to the signer to verify the signature and checks that it returns the `EIP1271_MAGICVALUE`.
     */
    function checkSignature_EIP1271(address signer, bytes32 digestHash, bytes memory signature) internal view {
        /**
         * check validity of signature:
         * 1) if `signer` is an EOA, then `signature` must be a valid ECDSA signature from `signer`,
         * indicating their intention for this action
         * 2) if `signer` is a contract, then `signature` must will be checked according to EIP-1271
         */
        if (Address.isContract(signer)) {
            require(
                IERC1271(signer).isValidSignature(digestHash, signature) == EIP1271_MAGICVALUE,
                "EIP1271SignatureUtils.checkSignature_EIP1271: ERC1271 signature verification failed"
            );
        } else {
            require(
                ECDSA.recover(digestHash, signature) == signer,
                "EIP1271SignatureUtils.checkSignature_EIP1271: signature not from signer"
            );
        }
    }
}

// lib/eigenlayer-middleware/src/interfaces/IServiceManager.sol

/**
 * @title Minimal interface for a ServiceManager-type contract that forms the single point for an AVS to push updates to EigenLayer
 * @author Layr Labs, Inc.
 */
interface IServiceManager is IServiceManagerUI {
    /**
     * @notice Creates a new rewards submission to the EigenLayer RewardsCoordinator contract, to be split amongst the
     * set of stakers delegated to operators who are registered to this `avs`
     * @param rewardsSubmissions The rewards submissions being created
     * @dev Only callabe by the permissioned rewardsInitiator address
     * @dev The duration of the `rewardsSubmission` cannot exceed `MAX_REWARDS_DURATION`
     * @dev The tokens are sent to the `RewardsCoordinator` contract
     * @dev Strategies must be in ascending order of addresses to check for duplicates
     * @dev This function will revert if the `rewardsSubmission` is malformed,
     * e.g. if the `strategies` and `weights` arrays are of non-equal lengths
     */
    function createAVSRewardsSubmission(IRewardsCoordinator.RewardsSubmission[] calldata rewardsSubmissions) external;

    // EVENTS
    event RewardsInitiatorUpdated(address prevRewardsInitiator, address newRewardsInitiator);
}

// lib/eigenlayer-middleware/src/interfaces/IStakeRegistry.sol

/**
 * @title Interface for a `Registry` that keeps track of stakes of operators for up to 256 quorums.
 * @author Layr Labs, Inc.
 */
interface IStakeRegistry is IRegistry {
    
    // DATA STRUCTURES

    /// @notice struct used to store the stakes of an individual operator or the sum of all operators' stakes, for storage
    struct StakeUpdate {
        // the block number at which the stake amounts were updated and stored
        uint32 updateBlockNumber;
        // the block number at which the *next update* occurred.
        /// @notice This entry has the value **0** until another update takes place.
        uint32 nextUpdateBlockNumber;
        // stake weight for the quorum
        uint96 stake;
    }

    /**
     * @notice In weighing a particular strategy, the amount of underlying asset for that strategy is
     * multiplied by its multiplier, then divided by WEIGHTING_DIVISOR
     */
    struct StrategyParams {
        IStrategy strategy;
        uint96 multiplier;
    }

    // EVENTS

    /// @notice emitted whenever the stake of `operator` is updated
    event OperatorStakeUpdate(
        bytes32 indexed operatorId,
        uint8 quorumNumber,
        uint96 stake
    );
    /// @notice emitted when the minimum stake for a quorum is updated
    event MinimumStakeForQuorumUpdated(uint8 indexed quorumNumber, uint96 minimumStake);
    /// @notice emitted when a new quorum is created
    event QuorumCreated(uint8 indexed quorumNumber);
    /// @notice emitted when `strategy` has been added to the array at `strategyParams[quorumNumber]`
    event StrategyAddedToQuorum(uint8 indexed quorumNumber, IStrategy strategy);
    /// @notice emitted when `strategy` has removed from the array at `strategyParams[quorumNumber]`
    event StrategyRemovedFromQuorum(uint8 indexed quorumNumber, IStrategy strategy);
    /// @notice emitted when `strategy` has its `multiplier` updated in the array at `strategyParams[quorumNumber]`
    event StrategyMultiplierUpdated(uint8 indexed quorumNumber, IStrategy strategy, uint256 multiplier);

    /**
     * @notice Registers the `operator` with `operatorId` for the specified `quorumNumbers`.
     * @param operator The address of the operator to register.
     * @param operatorId The id of the operator to register.
     * @param quorumNumbers The quorum numbers the operator is registering for, where each byte is an 8 bit integer quorumNumber.
     * @return The operator's current stake for each quorum, and the total stake for each quorum
     * @dev access restricted to the RegistryCoordinator
     * @dev Preconditions (these are assumed, not validated in this contract):
     *         1) `quorumNumbers` has no duplicates
     *         2) `quorumNumbers.length` != 0
     *         3) `quorumNumbers` is ordered in ascending order
     *         4) the operator is not already registered
     */
    function registerOperator(
        address operator, 
        bytes32 operatorId, 
        bytes memory quorumNumbers
    ) external returns (uint96[] memory, uint96[] memory);

    /**
     * @notice Deregisters the operator with `operatorId` for the specified `quorumNumbers`.
     * @param operatorId The id of the operator to deregister.
     * @param quorumNumbers The quorum numbers the operator is deregistering from, where each byte is an 8 bit integer quorumNumber.
     * @dev access restricted to the RegistryCoordinator
     * @dev Preconditions (these are assumed, not validated in this contract):
     *         1) `quorumNumbers` has no duplicates
     *         2) `quorumNumbers.length` != 0
     *         3) `quorumNumbers` is ordered in ascending order
     *         4) the operator is not already deregistered
     *         5) `quorumNumbers` is a subset of the quorumNumbers that the operator is registered for
     */
    function deregisterOperator(bytes32 operatorId, bytes memory quorumNumbers) external;

    /**
     * @notice Initialize a new quorum created by the registry coordinator by setting strategies, weights, and minimum stake
     */
    function initializeQuorum(uint8 quorumNumber, uint96 minimumStake, StrategyParams[] memory strategyParams) external;

    /// @notice Adds new strategies and the associated multipliers to the @param quorumNumber.
    function addStrategies(
        uint8 quorumNumber,
        StrategyParams[] memory strategyParams
    ) external;

    /**
     * @notice This function is used for removing strategies and their associated weights from the
     * mapping strategyParams for a specific @param quorumNumber.
     * @dev higher indices should be *first* in the list of @param indicesToRemove, since otherwise
     * the removal of lower index entries will cause a shift in the indices of the other strategiesToRemove
     */
    function removeStrategies(uint8 quorumNumber, uint256[] calldata indicesToRemove) external;

    /**
     * @notice This function is used for modifying the weights of strategies that are already in the
     * mapping strategyParams for a specific
     * @param quorumNumber is the quorum number to change the strategy for
     * @param strategyIndices are the indices of the strategies to change
     * @param newMultipliers are the new multipliers for the strategies
     */
    function modifyStrategyParams(
        uint8 quorumNumber,
        uint256[] calldata strategyIndices,
        uint96[] calldata newMultipliers
    ) external;

    /// @notice Constant used as a divisor in calculating weights.
    function WEIGHTING_DIVISOR() external pure returns (uint256);

    /// @notice Returns the EigenLayer delegation manager contract.
    function delegation() external view returns (IDelegationManager);

    /// @notice In order to register for a quorum i, an operator must have at least `minimumStakeForQuorum[i]`
    function minimumStakeForQuorum(uint8 quorumNumber) external view returns (uint96);

    /// @notice Returns the length of the dynamic array stored in `strategyParams[quorumNumber]`.
    function strategyParamsLength(uint8 quorumNumber) external view returns (uint256);

    /// @notice Returns the strategy and weight multiplier for the `index`'th strategy in the quorum `quorumNumber`
    function strategyParamsByIndex(
        uint8 quorumNumber,
        uint256 index
    ) external view returns (StrategyParams memory);

    /**
     * @notice This function computes the total weight of the @param operator in the quorum @param quorumNumber.
     * @dev reverts in the case that `quorumNumber` is greater than or equal to `quorumCount`
     */
    function weightOfOperatorForQuorum(uint8 quorumNumber, address operator) external view returns (uint96);

    /**
     * @notice Returns the entire `operatorIdToStakeHistory[operatorId][quorumNumber]` array.
     * @param operatorId The id of the operator of interest.
     * @param quorumNumber The quorum number to get the stake for.
     */
    function getStakeHistory(bytes32 operatorId, uint8 quorumNumber) external view returns (StakeUpdate[] memory);

    function getTotalStakeHistoryLength(uint8 quorumNumber) external view returns (uint256);

    /**
     * @notice Returns the `index`-th entry in the dynamic array of total stake, `totalStakeHistory` for quorum `quorumNumber`.
     * @param quorumNumber The quorum number to get the stake for.
     * @param index Array index for lookup, within the dynamic array `totalStakeHistory[quorumNumber]`.
     */
    function getTotalStakeUpdateAtIndex(uint8 quorumNumber, uint256 index) external view returns (StakeUpdate memory);

    /// @notice Returns the indices of the operator stakes for the provided `quorumNumber` at the given `blockNumber`
    function getStakeUpdateIndexAtBlockNumber(bytes32 operatorId, uint8 quorumNumber, uint32 blockNumber)
        external
        view
        returns (uint32);

    /// @notice Returns the indices of the total stakes for the provided `quorumNumbers` at the given `blockNumber`
    function getTotalStakeIndicesAtBlockNumber(uint32 blockNumber, bytes calldata quorumNumbers) external view returns(uint32[] memory) ;

    /**
     * @notice Returns the `index`-th entry in the `operatorIdToStakeHistory[operatorId][quorumNumber]` array.
     * @param quorumNumber The quorum number to get the stake for.
     * @param operatorId The id of the operator of interest.
     * @param index Array index for lookup, within the dynamic array `operatorIdToStakeHistory[operatorId][quorumNumber]`.
     * @dev Function will revert if `index` is out-of-bounds.
     */
    function getStakeUpdateAtIndex(uint8 quorumNumber, bytes32 operatorId, uint256 index)
        external
        view
        returns (StakeUpdate memory);

    /**
     * @notice Returns the most recent stake weight for the `operatorId` for a certain quorum
     * @dev Function returns an StakeUpdate struct with **every entry equal to 0** in the event that the operator has no stake history
     */
    function getLatestStakeUpdate(bytes32 operatorId, uint8 quorumNumber) external view returns (StakeUpdate memory);

    /**
     * @notice Returns the stake weight corresponding to `operatorId` for quorum `quorumNumber`, at the
     * `index`-th entry in the `operatorIdToStakeHistory[operatorId][quorumNumber]` array if the entry 
     * corresponds to the operator's stake at `blockNumber`. Reverts otherwise.
     * @param quorumNumber The quorum number to get the stake for.
     * @param operatorId The id of the operator of interest.
     * @param index Array index for lookup, within the dynamic array `operatorIdToStakeHistory[operatorId][quorumNumber]`.
     * @param blockNumber Block number to make sure the stake is from.
     * @dev Function will revert if `index` is out-of-bounds.
     * @dev used the BLSSignatureChecker to get past stakes of signing operators
     */
    function getStakeAtBlockNumberAndIndex(uint8 quorumNumber, uint32 blockNumber, bytes32 operatorId, uint256 index)
        external
        view
        returns (uint96);

    /**
     * @notice Returns the total stake weight for quorum `quorumNumber`, at the `index`-th entry in the 
     * `totalStakeHistory[quorumNumber]` array if the entry corresponds to the total stake at `blockNumber`. 
     * Reverts otherwise.
     * @param quorumNumber The quorum number to get the stake for.
     * @param index Array index for lookup, within the dynamic array `totalStakeHistory[quorumNumber]`.
     * @param blockNumber Block number to make sure the stake is from.
     * @dev Function will revert if `index` is out-of-bounds.
     * @dev used the BLSSignatureChecker to get past stakes of signing operators
     */
    function getTotalStakeAtBlockNumberFromIndex(uint8 quorumNumber, uint32 blockNumber, uint256 index) external view returns (uint96);

    /**
     * @notice Returns the most recent stake weight for the `operatorId` for quorum `quorumNumber`
     * @dev Function returns weight of **0** in the event that the operator has no stake history
     */
    function getCurrentStake(bytes32 operatorId, uint8 quorumNumber) external view returns (uint96);

    /// @notice Returns the stake of the operator for the provided `quorumNumber` at the given `blockNumber`
    function getStakeAtBlockNumber(bytes32 operatorId, uint8 quorumNumber, uint32 blockNumber)
        external
        view
        returns (uint96);

    /**
     * @notice Returns the stake weight from the latest entry in `_totalStakeHistory` for quorum `quorumNumber`.
     * @dev Will revert if `_totalStakeHistory[quorumNumber]` is empty.
     */
    function getCurrentTotalStake(uint8 quorumNumber) external view returns (uint96);

    /**
     * @notice Called by the registry coordinator to update an operator's stake for one
     * or more quorums.
     *
     * If the operator no longer has the minimum stake required for a quorum, they are
     * added to the
     * @return A bitmap of quorums where the operator no longer meets the minimum stake
     * and should be deregistered.
     */
    function updateOperatorStake(
        address operator, 
        bytes32 operatorId, 
        bytes calldata quorumNumbers
    ) external returns (uint192);
}

// src/OperatorAllowlist.sol

// SEE LICENSE IN https://files.altlayer.io/Alt-Research-License-1.md
// Copyright Alt Research Ltd. 2023. All rights reserved.
//
// You acknowledge and agree that Alt Research Ltd. ("Alt Research") (or Alt
// Research's licensors) own all legal rights, titles and interests in and to the
// work, software, application, source code, documentation and any other documents
//
//        db         888             88
//       d88b         88     88      88
//      d8'`8b        88     88      88
//     d8'  `8b       88   MM88MMM   88          ,adPPYYba,  8b       d8   ,adPPYba,  8b,dPPYb
//    d8YaaaaY8b      88     88      88          ""     `Y8  `8b     d8'  a8P_____88  88P'
//   d8""""""""8b     88     88      88          ,adPPPPP88   `8b   d8'   8PP"""""""  88
//  d8'        `8b    88     88,     88          88,    ,88    `8b,d8'    "8b,   ,aa  88
// d8'          `8b  8888    "Y888   88888888888 `"8bbdP"Y8      Y88'      `"Ybbd8"'  88
//                                                               d8'
//                                                              d8'

abstract contract OperatorAllowlist is
    IOperatorAllowlist,
    ContextUpgradeable,
    OwnableUpgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    error NotAllowed();
    error NotAllowlistManager();
    error AlreadyEnabled();
    error AlreadyDisabled();

    /// @notice Set of operators that are allowed to register
    EnumerableSetUpgradeable.AddressSet private _allowlist;

    /// @notice Whether or not the allowlist is enabled
    bool public allowlistEnabled;

    /// @notice Role for whitelisting operators
    address public allowlistManager;

    // storage gap for upgradeability
    // slither-disable-next-line shadowing-state
    uint256[47] private __GAP;

    /**
     * @dev Ensures that the function is only callable by the `allowlistManager`.
     */
    modifier onlyAllowlistManager() {
        if (_msgSender() != allowlistManager) {
            revert NotAllowlistManager();
        }
        _;
    }

    function __OperatorAllowlist_init(
        address _allowlistManager,
        bool _allowlistEnabled
    ) internal onlyInitializing {
        _setAllowlistManager(_allowlistManager);
        allowlistEnabled = _allowlistEnabled;
    }

    function setAllowlist(
        address[] calldata operators,
        bool[] calldata status
    ) external onlyAllowlistManager {
        require(
            operators.length == status.length,
            "Input arrays length mismatch"
        );

        for (uint256 i = 0; i < operators.length; ++i) {
            address operator = operators[i];

            if (operator == address(0)) {
                revert ZeroAddress();
            }

            if (status[i]) {
                _allowlist.add(operator);
            } else {
                _allowlist.remove(operator);
            }
        }
        emit AllowlistUpdated(operators, status);
    }

    function enableAllowlist() external onlyOwner {
        _setAllowlistStatus(true);
    }

    function disableAllowlist() external onlyOwner {
        _setAllowlistStatus(false);
    }

    function setAllowlistManager(address _allowlistManager) external onlyOwner {
        _setAllowlistManager(_allowlistManager);
    }

    function isOperatorAllowed(address operator) public view returns (bool) {
        return _allowlist.contains(operator);
    }

    function getAllowlistSize() public view returns (uint256) {
        return _allowlist.length();
    }

    function getAllowlistAtIndex(uint256 index) public view returns (address) {
        return _allowlist.at(index);
    }

    function queryOperators(
        uint256 start,
        uint256 count
    ) external view returns (address[] memory operators) {
        uint256 length = _allowlist.length();
        require(start < length, "Start index out of bounds");

        uint256 end = start + count;
        if (end > length) {
            end = length;
        }

        uint256 querySize = end - start;
        operators = new address[](querySize);

        for (uint256 i = 0; i < querySize; ++i) {
            operators[i] = _allowlist.at(start + i);
        }

        return operators;
    }

    /**
     *  @dev Sets the allowlist status
     *  @param enable A boolean indicating whether to enable or disable the allowlist
     */
    function _setAllowlistStatus(bool enable) internal {
        if (enable) {
            if (allowlistEnabled) {
                revert AlreadyEnabled();
            } else {
                allowlistEnabled = true;
                emit AllowlistEnabled();
            }
        } else {
            if (!allowlistEnabled) {
                revert AlreadyDisabled();
            } else {
                allowlistEnabled = false;
                emit AllowlistDisabled();
            }
        }
    }

    /**
     *  @dev Changes the allowlistManager
     */
    function _setAllowlistManager(address allowlistManager_) internal {
        emit AllowlistManagerChanged(allowlistManager, allowlistManager_);
        allowlistManager = allowlistManager_;
    }
}

// lib/eigenlayer-middleware/src/interfaces/IRegistryCoordinator.sol

/**
 * @title Interface for a contract that coordinates between various registries for an AVS.
 * @author Layr Labs, Inc.
 */
interface IRegistryCoordinator {
    // EVENTS

    /// Emits when an operator is registered
    event OperatorRegistered(address indexed operator, bytes32 indexed operatorId);

    /// Emits when an operator is deregistered
    event OperatorDeregistered(address indexed operator, bytes32 indexed operatorId);

    event OperatorSetParamsUpdated(uint8 indexed quorumNumber, OperatorSetParam operatorSetParams);

    event ChurnApproverUpdated(address prevChurnApprover, address newChurnApprover);

    event EjectorUpdated(address prevEjector, address newEjector);

    /// @notice emitted when all the operators for a quorum are updated at once
    event QuorumBlockNumberUpdated(uint8 indexed quorumNumber, uint256 blocknumber);

    // DATA STRUCTURES
    enum OperatorStatus
    {
        // default is NEVER_REGISTERED
        NEVER_REGISTERED,
        REGISTERED,
        DEREGISTERED
    }

    // STRUCTS

    /**
     * @notice Data structure for storing info on operators
     */
    struct OperatorInfo {
        // the id of the operator, which is likely the keccak256 hash of the operator's public key if using BLSRegistry
        bytes32 operatorId;
        // indicates whether the operator is actively registered for serving the middleware or not
        OperatorStatus status;
    }

    /**
     * @notice Data structure for storing info on quorum bitmap updates where the `quorumBitmap` is the bitmap of the 
     * quorums the operator is registered for starting at (inclusive)`updateBlockNumber` and ending at (exclusive) `nextUpdateBlockNumber`
     * @dev nextUpdateBlockNumber is initialized to 0 for the latest update
     */
    struct QuorumBitmapUpdate {
        uint32 updateBlockNumber;
        uint32 nextUpdateBlockNumber;
        uint192 quorumBitmap;
    }

    /**
     * @notice Data structure for storing operator set params for a given quorum. Specifically the 
     * `maxOperatorCount` is the maximum number of operators that can be registered for the quorum,
     * `kickBIPsOfOperatorStake` is the basis points of a new operator needs to have of an operator they are trying to kick from the quorum,
     * and `kickBIPsOfTotalStake` is the basis points of the total stake of the quorum that an operator needs to be below to be kicked.
     */ 
     struct OperatorSetParam {
        uint32 maxOperatorCount;
        uint16 kickBIPsOfOperatorStake;
        uint16 kickBIPsOfTotalStake;
    }

    /**
     * @notice Data structure for the parameters needed to kick an operator from a quorum with number `quorumNumber`, used during registration churn.
     * `operator` is the address of the operator to kick
     */
    struct OperatorKickParam {
        uint8 quorumNumber;
        address operator;
    }

    /// @notice Returns the operator set params for the given `quorumNumber`
    function getOperatorSetParams(uint8 quorumNumber) external view returns (OperatorSetParam memory);
    /// @notice the Stake registry contract that will keep track of operators' stakes
    function stakeRegistry() external view returns (IStakeRegistry);
    /// @notice the BLS Aggregate Pubkey Registry contract that will keep track of operators' BLS aggregate pubkeys per quorum
    function blsApkRegistry() external view returns (IBLSApkRegistry);
    /// @notice the index Registry contract that will keep track of operators' indexes
    function indexRegistry() external view returns (IIndexRegistry);

    /**
     * @notice Ejects the provided operator from the provided quorums from the AVS
     * @param operator is the operator to eject
     * @param quorumNumbers are the quorum numbers to eject the operator from
     */
    function ejectOperator(
        address operator, 
        bytes calldata quorumNumbers
    ) external;

    /// @notice Returns the number of quorums the registry coordinator has created
    function quorumCount() external view returns (uint8);

    /// @notice Returns the operator struct for the given `operator`
    function getOperator(address operator) external view returns (OperatorInfo memory);

    /// @notice Returns the operatorId for the given `operator`
    function getOperatorId(address operator) external view returns (bytes32);

    /// @notice Returns the operator address for the given `operatorId`
    function getOperatorFromId(bytes32 operatorId) external view returns (address operator);

    /// @notice Returns the status for the given `operator`
    function getOperatorStatus(address operator) external view returns (IRegistryCoordinator.OperatorStatus);

    /// @notice Returns the indices of the quorumBitmaps for the provided `operatorIds` at the given `blockNumber`
    function getQuorumBitmapIndicesAtBlockNumber(uint32 blockNumber, bytes32[] memory operatorIds) external view returns (uint32[] memory);

    /**
     * @notice Returns the quorum bitmap for the given `operatorId` at the given `blockNumber` via the `index`
     * @dev reverts if `index` is incorrect 
     */ 
    function getQuorumBitmapAtBlockNumberByIndex(bytes32 operatorId, uint32 blockNumber, uint256 index) external view returns (uint192);

    /// @notice Returns the `index`th entry in the operator with `operatorId`'s bitmap history
    function getQuorumBitmapUpdateByIndex(bytes32 operatorId, uint256 index) external view returns (QuorumBitmapUpdate memory);

    /// @notice Returns the current quorum bitmap for the given `operatorId`
    function getCurrentQuorumBitmap(bytes32 operatorId) external view returns (uint192);

    /// @notice Returns the length of the quorum bitmap history for the given `operatorId`
    function getQuorumBitmapHistoryLength(bytes32 operatorId) external view returns (uint256);

    /// @notice Returns the registry at the desired index
    function registries(uint256) external view returns (address);

    /// @notice Returns the number of registries
    function numRegistries() external view returns (uint256);

    /**
     * @notice Returns the message hash that an operator must sign to register their BLS public key.
     * @param operator is the address of the operator registering their BLS public key
     */
    function pubkeyRegistrationMessageHash(address operator) external view returns (BN254.G1Point memory);

    /// @notice returns the blocknumber the quorum was last updated all at once for all operators
    function quorumUpdateBlockNumber(uint8 quorumNumber) external view returns (uint256);

    /// @notice The owner of the registry coordinator
    function owner() external view returns (address);
}

// lib/eigenlayer-middleware/src/interfaces/IBLSSignatureChecker.sol

/**
 * @title Used for checking BLS aggregate signatures from the operators of a EigenLayer AVS with the RegistryCoordinator/BLSApkRegistry/StakeRegistry architechture.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice This is the contract for checking the validity of aggregate operator signatures.
 */
interface IBLSSignatureChecker {
    // DATA STRUCTURES

    struct NonSignerStakesAndSignature {
        uint32[] nonSignerQuorumBitmapIndices; // is the indices of all nonsigner quorum bitmaps
        BN254.G1Point[] nonSignerPubkeys; // is the G1 pubkeys of all nonsigners
        BN254.G1Point[] quorumApks; // is the aggregate G1 pubkey of each quorum
        BN254.G2Point apkG2; // is the aggregate G2 pubkey of all signers
        BN254.G1Point sigma; // is the aggregate G1 signature of all signers
        uint32[] quorumApkIndices; // is the indices of each quorum aggregate pubkey
        uint32[] totalStakeIndices; // is the indices of each quorums total stake
        uint32[][] nonSignerStakeIndices; // is the indices of each non signers stake within a quorum
    }

    /**
     * @notice this data structure is used for recording the details on the total stake of the registered
     * operators and those operators who are part of the quorum for a particular taskNumber
     */

    struct QuorumStakeTotals {
        // total stake of the operators in each quorum
        uint96[] signedStakeForQuorum;
        // total amount staked by all operators in each quorum
        uint96[] totalStakeForQuorum;
    }

    // EVENTS

    /// @notice Emitted when `staleStakesForbiddenUpdate` is set
    event StaleStakesForbiddenUpdate(bool value);   
    
    // CONSTANTS & IMMUTABLES

    function registryCoordinator() external view returns (IRegistryCoordinator);
    function stakeRegistry() external view returns (IStakeRegistry);
    function blsApkRegistry() external view returns (IBLSApkRegistry);
    function delegation() external view returns (IDelegationManager);

    /**
     * @notice This function is called by disperser when it has aggregated all the signatures of the operators
     * that are part of the quorum for a particular taskNumber and is asserting them into onchain. The function
     * checks that the claim for aggregated signatures are valid.
     *
     * The thesis of this procedure entails:
     * - getting the aggregated pubkey of all registered nodes at the time of pre-commit by the
     * disperser (represented by apk in the parameters),
     * - subtracting the pubkeys of all the signers not in the quorum (nonSignerPubkeys) and storing 
     * the output in apk to get aggregated pubkey of all operators that are part of quorum.
     * - use this aggregated pubkey to verify the aggregated signature under BLS scheme.
     * 
     * @dev Before signature verification, the function verifies operator stake information.  This includes ensuring that the provided `referenceBlockNumber`
     * is correct, i.e., ensure that the stake returned from the specified block number is recent enough and that the stake is either the most recent update
     * for the total stake (or the operator) or latest before the referenceBlockNumber.
     */
    function checkSignatures(
        bytes32 msgHash, 
        bytes calldata quorumNumbers,
        uint32 referenceBlockNumber, 
        NonSignerStakesAndSignature memory nonSignerStakesAndSignature
    ) 
        external 
        view
        returns (
            QuorumStakeTotals memory,
            bytes32
        );
}

// lib/eigenlayer-middleware/src/BLSApkRegistryStorage.sol

abstract contract BLSApkRegistryStorage is Initializable, IBLSApkRegistry {
    /// @notice the hash of the zero pubkey aka BN254.G1Point(0,0)
    bytes32 internal constant ZERO_PK_HASH = hex"ad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5";

    /// @notice the registry coordinator contract
    address public immutable registryCoordinator;

    // storage for individual pubkeys
    /// @notice maps operator address to pubkey hash
    mapping(address => bytes32) public operatorToPubkeyHash;
    /// @notice maps pubkey hash to operator address
    mapping(bytes32 => address) public pubkeyHashToOperator;
    /// @notice maps operator address to pubkeyG1
    mapping(address => BN254.G1Point) public operatorToPubkey;

    // storage for aggregate pubkeys (APKs)
    /// @notice maps quorumNumber => historical aggregate pubkey updates
    mapping(uint8 => ApkUpdate[]) public apkHistory;
    /// @notice maps quorumNumber => current aggregate pubkey of quorum
    mapping(uint8 => BN254.G1Point) public currentApk;

    constructor(IRegistryCoordinator _registryCoordinator) {
        registryCoordinator = address(_registryCoordinator);
        // disable initializers so that the implementation contract cannot be initialized
        _disableInitializers();
    }

    // storage gap for upgradeability
    uint256[45] private __GAP;
}

// lib/eigenlayer-middleware/src/BLSSignatureChecker.sol

/**
 * @title Used for checking BLS aggregate signatures from the operators of a `BLSRegistry`.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice This is the contract for checking the validity of aggregate operator signatures.
 */
contract BLSSignatureChecker is IBLSSignatureChecker {
    using BN254 for BN254.G1Point;

    // CONSTANTS & IMMUTABLES

    // gas cost of multiplying 2 pairings
    uint256 internal constant PAIRING_EQUALITY_CHECK_GAS = 120_000;

    IRegistryCoordinator public immutable registryCoordinator;
    IStakeRegistry public immutable stakeRegistry;
    IBLSApkRegistry public immutable blsApkRegistry;
    IDelegationManager public immutable delegation;
    /// @notice If true, check the staleness of the operator stakes and that its within the delegation withdrawalDelayBlocks window.
    bool public staleStakesForbidden;

    modifier onlyCoordinatorOwner() {
        require(
            msg.sender == registryCoordinator.owner(),
            "BLSSignatureChecker.onlyCoordinatorOwner: caller is not the owner of the registryCoordinator"
        );
        _;
    }

    constructor(IRegistryCoordinator _registryCoordinator) {
        registryCoordinator = _registryCoordinator;
        stakeRegistry = _registryCoordinator.stakeRegistry();
        blsApkRegistry = _registryCoordinator.blsApkRegistry();
        delegation = stakeRegistry.delegation();
    }

    /**
     * /**
     * RegistryCoordinator owner can either enforce or not that operator stakes are staler
     * than the delegation.minWithdrawalDelayBlocks() window.
     * @param value to toggle staleStakesForbidden
     */
    function setStaleStakesForbidden(bool value) external onlyCoordinatorOwner {
        _setStaleStakesForbidden(value);
    }

    struct NonSignerInfo {
        uint256[] quorumBitmaps;
        bytes32[] pubkeyHashes;
    }

    /**
     * @notice This function is called by disperser when it has aggregated all the signatures of the operators
     * that are part of the quorum for a particular taskNumber and is asserting them into onchain. The function
     * checks that the claim for aggregated signatures are valid.
     *
     * The thesis of this procedure entails:
     * - getting the aggregated pubkey of all registered nodes at the time of pre-commit by the
     * disperser (represented by apk in the parameters),
     * - subtracting the pubkeys of all the signers not in the quorum (nonSignerPubkeys) and storing
     * the output in apk to get aggregated pubkey of all operators that are part of quorum.
     * - use this aggregated pubkey to verify the aggregated signature under BLS scheme.
     *
     * @dev Before signature verification, the function verifies operator stake information.  This includes ensuring that the provided `referenceBlockNumber`
     * is correct, i.e., ensure that the stake returned from the specified block number is recent enough and that the stake is either the most recent update
     * for the total stake (of the operator) or latest before the referenceBlockNumber.
     * @param msgHash is the hash being signed
     * @dev NOTE: Be careful to ensure `msgHash` is collision-resistant! This method does not hash
     * `msgHash` in any way, so if an attacker is able to pass in an arbitrary value, they may be able
     * to tamper with signature verification.
     * @param quorumNumbers is the bytes array of quorum numbers that are being signed for
     * @param referenceBlockNumber is the block number at which the stake information is being verified
     * @param params is the struct containing information on nonsigners, stakes, quorum apks, and the aggregate signature
     * @return quorumStakeTotals is the struct containing the total and signed stake for each quorum
     * @return signatoryRecordHash is the hash of the signatory record, which is used for fraud proofs
     */
    function checkSignatures(
        bytes32 msgHash,
        bytes calldata quorumNumbers,
        uint32 referenceBlockNumber,
        NonSignerStakesAndSignature memory params
    ) public view returns (QuorumStakeTotals memory, bytes32) {
        require(
            quorumNumbers.length != 0,
            "BLSSignatureChecker.checkSignatures: empty quorum input"
        );

        require(
            (quorumNumbers.length == params.quorumApks.length) &&
                (quorumNumbers.length == params.quorumApkIndices.length) &&
                (quorumNumbers.length == params.totalStakeIndices.length) &&
                (quorumNumbers.length == params.nonSignerStakeIndices.length),
            "BLSSignatureChecker.checkSignatures: input quorum length mismatch"
        );

        require(
            params.nonSignerPubkeys.length ==
                params.nonSignerQuorumBitmapIndices.length,
            "BLSSignatureChecker.checkSignatures: input nonsigner length mismatch"
        );

        require(
            referenceBlockNumber < uint32(block.number),
            "BLSSignatureChecker.checkSignatures: invalid reference block"
        );

        // This method needs to calculate the aggregate pubkey for all signing operators across
        // all signing quorums. To do that, we can query the aggregate pubkey for each quorum
        // and subtract out the pubkey for each nonsigning operator registered to that quorum.
        //
        // In practice, we do this in reverse - calculating an aggregate pubkey for all nonsigners,
        // negating that pubkey, then adding the aggregate pubkey for each quorum.
        BN254.G1Point memory apk = BN254.G1Point(0, 0);

        // For each quorum, we're also going to query the total stake for all registered operators
        // at the referenceBlockNumber, and derive the stake held by signers by subtracting out
        // stakes held by nonsigners.
        QuorumStakeTotals memory stakeTotals;
        stakeTotals.totalStakeForQuorum = new uint96[](quorumNumbers.length);
        stakeTotals.signedStakeForQuorum = new uint96[](quorumNumbers.length);

        NonSignerInfo memory nonSigners;
        nonSigners.quorumBitmaps = new uint256[](
            params.nonSignerPubkeys.length
        );
        nonSigners.pubkeyHashes = new bytes32[](params.nonSignerPubkeys.length);

        {
            // Get a bitmap of the quorums signing the message, and validate that
            // quorumNumbers contains only unique, valid quorum numbers
            uint256 signingQuorumBitmap = BitmapUtils.orderedBytesArrayToBitmap(
                quorumNumbers,
                registryCoordinator.quorumCount()
            );

            for (uint256 j = 0; j < params.nonSignerPubkeys.length; j++) {
                // The nonsigner's pubkey hash doubles as their operatorId
                // The check below validates that these operatorIds are sorted (and therefore
                // free of duplicates)
                nonSigners.pubkeyHashes[j] = params
                    .nonSignerPubkeys[j]
                    .hashG1Point();
                if (j != 0) {
                    require(
                        uint256(nonSigners.pubkeyHashes[j]) >
                            uint256(nonSigners.pubkeyHashes[j - 1]),
                        "BLSSignatureChecker.checkSignatures: nonSignerPubkeys not sorted"
                    );
                }

                // Get the quorums the nonsigner was registered for at referenceBlockNumber
                nonSigners.quorumBitmaps[j] = registryCoordinator
                    .getQuorumBitmapAtBlockNumberByIndex({
                        operatorId: nonSigners.pubkeyHashes[j],
                        blockNumber: referenceBlockNumber,
                        index: params.nonSignerQuorumBitmapIndices[j]
                    });

                // Add the nonsigner's pubkey to the total apk, multiplied by the number
                // of quorums they have in common with the signing quorums, because their
                // public key will be a part of each signing quorum's aggregate pubkey
                apk = apk.plus(
                    params.nonSignerPubkeys[j].scalar_mul_tiny(
                        BitmapUtils.countNumOnes(
                            nonSigners.quorumBitmaps[j] & signingQuorumBitmap
                        )
                    )
                );
            }
        }

        // Negate the sum of the nonsigner aggregate pubkeys - from here, we'll add the
        // total aggregate pubkey from each quorum. Because the nonsigners' pubkeys are
        // in these quorums, this initial negation ensures they're cancelled out
        apk = apk.negate();

        /**
         * For each quorum (at referenceBlockNumber):
         * - add the apk for all registered operators
         * - query the total stake for each quorum
         * - subtract the stake for each nonsigner to calculate the stake belonging to signers
         */
        {
            bool _staleStakesForbidden = staleStakesForbidden;
            uint256 withdrawalDelayBlocks = _staleStakesForbidden
                ? delegation.minWithdrawalDelayBlocks()
                : 0;

            for (uint256 i = 0; i < quorumNumbers.length; i++) {
                // If we're disallowing stale stake updates, check that each quorum's last update block
                // is within withdrawalDelayBlocks
                if (_staleStakesForbidden) {
                    require(
                        registryCoordinator.quorumUpdateBlockNumber(
                            uint8(quorumNumbers[i])
                        ) +
                            withdrawalDelayBlocks >
                            referenceBlockNumber,
                        "BLSSignatureChecker.checkSignatures: StakeRegistry updates must be within withdrawalDelayBlocks window"
                    );
                }

                // Validate params.quorumApks is correct for this quorum at the referenceBlockNumber,
                // then add it to the total apk
                require(
                    bytes24(params.quorumApks[i].hashG1Point()) ==
                        blsApkRegistry.getApkHashAtBlockNumberAndIndex({
                            quorumNumber: uint8(quorumNumbers[i]),
                            blockNumber: referenceBlockNumber,
                            index: params.quorumApkIndices[i]
                        }),
                    "BLSSignatureChecker.checkSignatures: quorumApk hash in storage does not match provided quorum apk"
                );
                apk = apk.plus(params.quorumApks[i]);

                // Get the total and starting signed stake for the quorum at referenceBlockNumber
                stakeTotals.totalStakeForQuorum[i] = stakeRegistry
                    .getTotalStakeAtBlockNumberFromIndex({
                        quorumNumber: uint8(quorumNumbers[i]),
                        blockNumber: referenceBlockNumber,
                        index: params.totalStakeIndices[i]
                    });
                stakeTotals.signedStakeForQuorum[i] = stakeTotals
                    .totalStakeForQuorum[i];

                // Keep track of the nonSigners index in the quorum
                uint256 nonSignerForQuorumIndex = 0;

                // loop through all nonSigners, checking that they are a part of the quorum via their quorumBitmap
                // if so, load their stake at referenceBlockNumber and subtract it from running stake signed
                for (uint256 j = 0; j < params.nonSignerPubkeys.length; j++) {
                    // if the nonSigner is a part of the quorum, subtract their stake from the running total
                    if (
                        BitmapUtils.isSet(
                            nonSigners.quorumBitmaps[j],
                            uint8(quorumNumbers[i])
                        )
                    ) {
                        stakeTotals.signedStakeForQuorum[i] -= stakeRegistry
                            .getStakeAtBlockNumberAndIndex({
                                quorumNumber: uint8(quorumNumbers[i]),
                                blockNumber: referenceBlockNumber,
                                operatorId: nonSigners.pubkeyHashes[j],
                                index: params.nonSignerStakeIndices[i][
                                    nonSignerForQuorumIndex
                                ]
                            });
                        unchecked {
                            ++nonSignerForQuorumIndex;
                        }
                    }
                }
            }
        }
        {
            // verify the signature
            (
                bool pairingSuccessful,
                bool signatureIsValid
            ) = trySignatureAndApkVerification(
                    msgHash,
                    apk,
                    params.apkG2,
                    params.sigma
                );
            require(
                pairingSuccessful,
                "BLSSignatureChecker.checkSignatures: pairing precompile call failed"
            );
            require(
                signatureIsValid,
                "BLSSignatureChecker.checkSignatures: signature is invalid"
            );
        }
        // set signatoryRecordHash variable used for fraudproofs
        bytes32 signatoryRecordHash = keccak256(
            abi.encodePacked(referenceBlockNumber, nonSigners.pubkeyHashes)
        );

        // return the total stakes that signed for each quorum, and a hash of the information required to prove the exact signers and stake
        return (stakeTotals, signatoryRecordHash);
    }

    /**
     * trySignatureAndApkVerification verifies a BLS aggregate signature and the veracity of a calculated G1 Public key
     * @param msgHash is the hash being signed
     * @param apk is the claimed G1 public key
     * @param apkG2 is provided G2 public key
     * @param sigma is the G1 point signature
     * @return pairingSuccessful is true if the pairing precompile call was successful
     * @return siganatureIsValid is true if the signature is valid
     */
    function trySignatureAndApkVerification(
        bytes32 msgHash,
        BN254.G1Point memory apk,
        BN254.G2Point memory apkG2,
        BN254.G1Point memory sigma
    ) public view returns (bool pairingSuccessful, bool siganatureIsValid) {
        // gamma = keccak256(abi.encodePacked(msgHash, apk, apkG2, sigma))
        uint256 gamma = uint256(
            keccak256(
                abi.encodePacked(
                    msgHash,
                    apk.X,
                    apk.Y,
                    apkG2.X[0],
                    apkG2.X[1],
                    apkG2.Y[0],
                    apkG2.Y[1],
                    sigma.X,
                    sigma.Y
                )
            )
        ) % BN254.FR_MODULUS;
        // verify the signature
        (pairingSuccessful, siganatureIsValid) = BN254.safePairing(
            sigma.plus(apk.scalar_mul(gamma)),
            BN254.negGeneratorG2(),
            BN254.hashToG1(msgHash).plus(BN254.generatorG1().scalar_mul(gamma)),
            apkG2,
            PAIRING_EQUALITY_CHECK_GAS
        );
    }

    function _setStaleStakesForbidden(bool value) internal {
        staleStakesForbidden = value;
        emit StaleStakesForbiddenUpdate(value);
    }

    // storage gap for upgradeability
    // slither-disable-next-line shadowing-state
    uint256[49] private __GAP;
}

// lib/eigenlayer-middleware/src/BLSApkRegistry.sol

contract BLSApkRegistry is BLSApkRegistryStorage {
    using BN254 for BN254.G1Point;

    /// @notice when applied to a function, only allows the RegistryCoordinator to call it
    modifier onlyRegistryCoordinator() {
        _checkRegistryCoordinator();
        _;
    }

    /// @notice Sets the (immutable) `registryCoordinator` address
    constructor(
        IRegistryCoordinator _registryCoordinator
    ) BLSApkRegistryStorage(_registryCoordinator) {}

    /*******************************************************************************
                      EXTERNAL FUNCTIONS - REGISTRY COORDINATOR
    *******************************************************************************/

    /**
     * @notice Registers the `operator`'s pubkey for the specified `quorumNumbers`.
     * @param operator The address of the operator to register.
     * @param quorumNumbers The quorum numbers the operator is registering for, where each byte is an 8 bit integer quorumNumber.
     * @dev access restricted to the RegistryCoordinator
     * @dev Preconditions (these are assumed, not validated in this contract):
     *         1) `quorumNumbers` has no duplicates
     *         2) `quorumNumbers.length` != 0
     *         3) `quorumNumbers` is ordered in ascending order
     *         4) the operator is not already registered
     */
    function registerOperator(
        address operator,
        bytes memory quorumNumbers
    ) public virtual onlyRegistryCoordinator {
        // Get the operator's pubkey. Reverts if they have not registered a key
        (BN254.G1Point memory pubkey, ) = getRegisteredPubkey(operator);

        // Update each quorum's aggregate pubkey
        _processQuorumApkUpdate(quorumNumbers, pubkey);

        // Return pubkeyHash, which will become the operator's unique id
        emit OperatorAddedToQuorums(operator, getOperatorId(operator), quorumNumbers);
    }

    /**
     * @notice Deregisters the `operator`'s pubkey for the specified `quorumNumbers`.
     * @param operator The address of the operator to deregister.
     * @param quorumNumbers The quorum numbers the operator is deregistering from, where each byte is an 8 bit integer quorumNumber.
     * @dev access restricted to the RegistryCoordinator
     * @dev Preconditions (these are assumed, not validated in this contract):
     *         1) `quorumNumbers` has no duplicates
     *         2) `quorumNumbers.length` != 0
     *         3) `quorumNumbers` is ordered in ascending order
     *         4) the operator is not already deregistered
     *         5) `quorumNumbers` is a subset of the quorumNumbers that the operator is registered for
     */
    function deregisterOperator(
        address operator,
        bytes memory quorumNumbers
    ) public virtual onlyRegistryCoordinator {
        // Get the operator's pubkey. Reverts if they have not registered a key
        (BN254.G1Point memory pubkey, ) = getRegisteredPubkey(operator);

        // Update each quorum's aggregate pubkey
        _processQuorumApkUpdate(quorumNumbers, pubkey.negate());
        emit OperatorRemovedFromQuorums(operator, getOperatorId(operator), quorumNumbers);
    }

    /**
     * @notice Initializes a new quorum by pushing its first apk update
     * @param quorumNumber The number of the new quorum
     */
    function initializeQuorum(uint8 quorumNumber) public virtual onlyRegistryCoordinator {
        require(apkHistory[quorumNumber].length == 0, "BLSApkRegistry.initializeQuorum: quorum already exists");

        apkHistory[quorumNumber].push(ApkUpdate({
            apkHash: bytes24(0),
            updateBlockNumber: uint32(block.number),
            nextUpdateBlockNumber: 0
        }));
    }

    /**
     * @notice Called by the RegistryCoordinator register an operator as the owner of a BLS public key.
     * @param operator is the operator for whom the key is being registered
     * @param params contains the G1 & G2 public keys of the operator, and a signature proving their ownership
     * @param pubkeyRegistrationMessageHash is a hash that the operator must sign to prove key ownership
     */
    function registerBLSPublicKey(
        address operator,
        PubkeyRegistrationParams calldata params,
        BN254.G1Point calldata pubkeyRegistrationMessageHash
    ) external onlyRegistryCoordinator returns (bytes32 operatorId) {
        bytes32 pubkeyHash = BN254.hashG1Point(params.pubkeyG1);
        require(
            pubkeyHash != ZERO_PK_HASH, "BLSApkRegistry.registerBLSPublicKey: cannot register zero pubkey"
        );
        require(
            operatorToPubkeyHash[operator] == bytes32(0),
            "BLSApkRegistry.registerBLSPublicKey: operator already registered pubkey"
        );
        require(
            pubkeyHashToOperator[pubkeyHash] == address(0),
            "BLSApkRegistry.registerBLSPublicKey: public key already registered"
        );

        // gamma = h(sigma, P, P', H(m))
        uint256 gamma = uint256(keccak256(abi.encodePacked(
            params.pubkeyRegistrationSignature.X, 
            params.pubkeyRegistrationSignature.Y, 
            params.pubkeyG1.X, 
            params.pubkeyG1.Y, 
            params.pubkeyG2.X, 
            params.pubkeyG2.Y, 
            pubkeyRegistrationMessageHash.X, 
            pubkeyRegistrationMessageHash.Y
        ))) % BN254.FR_MODULUS;
        
        // e(sigma + P * gamma, [-1]_2) = e(H(m) + [1]_1 * gamma, P') 
        require(BN254.pairing(
            params.pubkeyRegistrationSignature.plus(params.pubkeyG1.scalar_mul(gamma)),
            BN254.negGeneratorG2(),
            pubkeyRegistrationMessageHash.plus(BN254.generatorG1().scalar_mul(gamma)),
            params.pubkeyG2
        ), "BLSApkRegistry.registerBLSPublicKey: either the G1 signature is wrong, or G1 and G2 private key do not match");

        operatorToPubkey[operator] = params.pubkeyG1;
        operatorToPubkeyHash[operator] = pubkeyHash;
        pubkeyHashToOperator[pubkeyHash] = operator;

        emit NewPubkeyRegistration(operator, params.pubkeyG1, params.pubkeyG2);
        return pubkeyHash;
    }

    /*******************************************************************************
                            INTERNAL FUNCTIONS
    *******************************************************************************/

    function _processQuorumApkUpdate(bytes memory quorumNumbers, BN254.G1Point memory point) internal {
        BN254.G1Point memory newApk;

        for (uint256 i = 0; i < quorumNumbers.length; i++) {
            // Validate quorum exists and get history length
            uint8 quorumNumber = uint8(quorumNumbers[i]);
            uint256 historyLength = apkHistory[quorumNumber].length;
            require(historyLength != 0, "BLSApkRegistry._processQuorumApkUpdate: quorum does not exist");

            // Update aggregate public key for this quorum
            newApk = currentApk[quorumNumber].plus(point);
            currentApk[quorumNumber] = newApk;
            bytes24 newApkHash = bytes24(BN254.hashG1Point(newApk));

            // Update apk history. If the last update was made in this block, update the entry
            // Otherwise, push a new historical entry and update the prev->next pointer
            ApkUpdate storage lastUpdate = apkHistory[quorumNumber][historyLength - 1];
            if (lastUpdate.updateBlockNumber == uint32(block.number)) {
                lastUpdate.apkHash = newApkHash;
            } else {
                lastUpdate.nextUpdateBlockNumber = uint32(block.number);
                apkHistory[quorumNumber].push(ApkUpdate({
                    apkHash: newApkHash,
                    updateBlockNumber: uint32(block.number),
                    nextUpdateBlockNumber: 0
                }));
            }
        }
    }

    /*******************************************************************************
                            VIEW FUNCTIONS
    *******************************************************************************/
    /**
     * @notice Returns the pubkey and pubkey hash of an operator
     * @dev Reverts if the operator has not registered a valid pubkey
     */
    function getRegisteredPubkey(address operator) public view returns (BN254.G1Point memory, bytes32) {
        BN254.G1Point memory pubkey = operatorToPubkey[operator];
        bytes32 pubkeyHash = operatorToPubkeyHash[operator];

        require(
            pubkeyHash != bytes32(0),
            "BLSApkRegistry.getRegisteredPubkey: operator is not registered"
        );
        
        return (pubkey, pubkeyHash);
    }

    /**
     * @notice Returns the indices of the quorumApks index at `blockNumber` for the provided `quorumNumbers`
     * @dev Returns the current indices if `blockNumber >= block.number`
     */
    function getApkIndicesAtBlockNumber(
        bytes calldata quorumNumbers,
        uint256 blockNumber
    ) external view returns (uint32[] memory) {
        uint32[] memory indices = new uint32[](quorumNumbers.length);
        
        for (uint256 i = 0; i < quorumNumbers.length; i++) {
            uint8 quorumNumber = uint8(quorumNumbers[i]);
            
            uint256 quorumApkUpdatesLength = apkHistory[quorumNumber].length;
            if (quorumApkUpdatesLength == 0 || blockNumber < apkHistory[quorumNumber][0].updateBlockNumber) {
                revert("BLSApkRegistry.getApkIndicesAtBlockNumber: blockNumber is before the first update");
            }

            // Loop backward through apkHistory until we find an entry that preceeds `blockNumber`
            for (uint256 j = quorumApkUpdatesLength; j > 0; j--) {
                if (apkHistory[quorumNumber][j - 1].updateBlockNumber <= blockNumber) {
                    indices[i] = uint32(j - 1);
                    break;
                }
            }
        }
        return indices;
    }

    /// @notice Returns the current APK for the provided `quorumNumber `
    function getApk(uint8 quorumNumber) external view returns (BN254.G1Point memory) {
        return currentApk[quorumNumber];
    }

    /// @notice Returns the `ApkUpdate` struct at `index` in the list of APK updates for the `quorumNumber`
    function getApkUpdateAtIndex(uint8 quorumNumber, uint256 index) external view returns (ApkUpdate memory) {
        return apkHistory[quorumNumber][index];
    }

    /**
     * @notice get hash of the apk of `quorumNumber` at `blockNumber` using the provided `index`;
     * called by checkSignatures in BLSSignatureChecker.sol.
     * @param quorumNumber is the quorum whose ApkHash is being retrieved
     * @param blockNumber is the number of the block for which the latest ApkHash will be retrieved
     * @param index is the index of the apkUpdate being retrieved from the list of quorum apkUpdates in storage
     */
    function getApkHashAtBlockNumberAndIndex(
        uint8 quorumNumber,
        uint32 blockNumber,
        uint256 index
    ) external view returns (bytes24) {
        ApkUpdate memory quorumApkUpdate = apkHistory[quorumNumber][index];

        /**
         * Validate that the update is valid for the given blockNumber:
         * - blockNumber should be >= the update block number
         * - the next update block number should be either 0 or strictly greater than blockNumber
         */
        require(
            blockNumber >= quorumApkUpdate.updateBlockNumber,
            "BLSApkRegistry._validateApkHashAtBlockNumber: index too recent"
        );
        require(
            quorumApkUpdate.nextUpdateBlockNumber == 0 || blockNumber < quorumApkUpdate.nextUpdateBlockNumber,
            "BLSApkRegistry._validateApkHashAtBlockNumber: not latest apk update"
        );

        return quorumApkUpdate.apkHash;
    }

    /// @notice Returns the length of ApkUpdates for the provided `quorumNumber`
    function getApkHistoryLength(uint8 quorumNumber) external view returns (uint32) {
        return uint32(apkHistory[quorumNumber].length);
    }

    /// @notice Returns the operator address for the given `pubkeyHash`
    function getOperatorFromPubkeyHash(bytes32 pubkeyHash) public view returns (address) {
        return pubkeyHashToOperator[pubkeyHash];
    }

    /// @notice returns the ID used to identify the `operator` within this AVS
    /// @dev Returns zero in the event that the `operator` has never registered for the AVS
    function getOperatorId(address operator) public view returns (bytes32) {
        return operatorToPubkeyHash[operator];
    }

    function _checkRegistryCoordinator() internal view {
        require(
            msg.sender == address(registryCoordinator),
            "BLSApkRegistry.onlyRegistryCoordinator: caller is not the registry coordinator"
        );
    }
}

// lib/eigenlayer-middleware/src/RegistryCoordinatorStorage.sol

abstract contract RegistryCoordinatorStorage is IRegistryCoordinator {

    /*******************************************************************************
                               CONSTANTS AND IMMUTABLES 
    *******************************************************************************/

    /// @notice The EIP-712 typehash for the `DelegationApproval` struct used by the contract
    bytes32 public constant OPERATOR_CHURN_APPROVAL_TYPEHASH =
        keccak256("OperatorChurnApproval(address registeringOperator,bytes32 registeringOperatorId,OperatorKickParam[] operatorKickParams,bytes32 salt,uint256 expiry)OperatorKickParam(uint8 quorumNumber,address operator)");
    /// @notice The EIP-712 typehash used for registering BLS public keys
    bytes32 public constant PUBKEY_REGISTRATION_TYPEHASH = keccak256("BN254PubkeyRegistration(address operator)");
    /// @notice The maximum value of a quorum bitmap
    uint256 internal constant MAX_QUORUM_BITMAP = type(uint192).max;
    /// @notice The basis point denominator
    uint16 internal constant BIPS_DENOMINATOR = 10000;
    /// @notice Index for flag that pauses operator registration
    uint8 internal constant PAUSED_REGISTER_OPERATOR = 0;
    /// @notice Index for flag that pauses operator deregistration
    uint8 internal constant PAUSED_DEREGISTER_OPERATOR = 1;
    /// @notice Index for flag pausing operator stake updates
    uint8 internal constant PAUSED_UPDATE_OPERATOR = 2;
    /// @notice The maximum number of quorums this contract supports
    uint8 internal constant MAX_QUORUM_COUNT = 192;

    /// @notice the ServiceManager for this AVS, which forwards calls onto EigenLayer's core contracts
    IServiceManager public immutable serviceManager;
    /// @notice the BLS Aggregate Pubkey Registry contract that will keep track of operators' aggregate BLS public keys per quorum
    IBLSApkRegistry public immutable blsApkRegistry;
    /// @notice the Stake Registry contract that will keep track of operators' stakes
    IStakeRegistry public immutable stakeRegistry;
    /// @notice the Index Registry contract that will keep track of operators' indexes
    IIndexRegistry public immutable indexRegistry;

    /*******************************************************************************
                                       STATE 
    *******************************************************************************/

    /// @notice the current number of quorums supported by the registry coordinator
    uint8 public quorumCount;
    /// @notice maps quorum number => operator cap and kick params
    mapping(uint8 => OperatorSetParam) internal _quorumParams;
    /// @notice maps operator id => historical quorums they registered for
    mapping(bytes32 => QuorumBitmapUpdate[]) internal _operatorBitmapHistory;
    /// @notice maps operator address => operator id and status
    mapping(address => OperatorInfo) internal _operatorInfo;
    /// @notice whether the salt has been used for an operator churn approval
    mapping(bytes32 => bool) public isChurnApproverSaltUsed;
    /// @notice mapping from quorum number to the latest block that all quorums were updated all at once
    mapping(uint8 => uint256) public quorumUpdateBlockNumber;

    /// @notice the dynamic-length array of the registries this coordinator is coordinating
    address[] public registries;
    /// @notice the address of the entity allowed to sign off on operators getting kicked out of the AVS during registration
    address public churnApprover;
    /// @notice the address of the entity allowed to eject operators from the AVS
    address public ejector;

    /// @notice the last timestamp an operator was ejected
    mapping(address => uint256) public lastEjectionTimestamp;
    /// @notice the delay in seconds before an operator can reregister after being ejected
    uint256 public ejectionCooldown;

    constructor(
        IServiceManager _serviceManager,
        IStakeRegistry _stakeRegistry,
        IBLSApkRegistry _blsApkRegistry,
        IIndexRegistry _indexRegistry
    ) {
        serviceManager = _serviceManager;
        stakeRegistry = _stakeRegistry;
        blsApkRegistry = _blsApkRegistry;
        indexRegistry = _indexRegistry;
    }

    // storage gap for upgradeability
    // slither-disable-next-line shadowing-state
    uint256[39] private __GAP;
}

// lib/eigenlayer-middleware/src/ServiceManagerBaseStorage.sol

/**
 * @title Storage variables for the `ServiceManagerBase` contract.
 * @author Layr Labs, Inc.
 * @notice This storage contract is separate from the logic to simplify the upgrade process.
 */
abstract contract ServiceManagerBaseStorage is IServiceManager, OwnableUpgradeable {
    /**
     *
     *                            CONSTANTS AND IMMUTABLES
     *
     */
    IAVSDirectory internal immutable _avsDirectory;
    IRewardsCoordinator internal immutable _rewardsCoordinator;
    IRegistryCoordinator internal immutable _registryCoordinator;
    IStakeRegistry internal immutable _stakeRegistry;

    /**
     *
     *                            STATE VARIABLES
     *
     */

    /// @notice The address of the entity that can initiate rewards
    address public rewardsInitiator;

    /// @notice Sets the (immutable) `_avsDirectory`, `_rewardsCoordinator`, `_registryCoordinator`, and `_stakeRegistry` addresses
    constructor(
        IAVSDirectory __avsDirectory,
        IRewardsCoordinator __rewardsCoordinator,
        IRegistryCoordinator __registryCoordinator,
        IStakeRegistry __stakeRegistry
    ) {
        _avsDirectory = __avsDirectory;
        _rewardsCoordinator = __rewardsCoordinator;
        _registryCoordinator = __registryCoordinator;
        _stakeRegistry = __stakeRegistry;
    }

    // storage gap for upgradeability
    uint256[49] private __GAP;
}

// lib/eigenlayer-middleware/src/ServiceManagerBase.sol

/**
 * @title Minimal implementation of a ServiceManager-type contract.
 * This contract can be inherited from or simply used as a point-of-reference.
 * @author Layr Labs, Inc.
 */
abstract contract ServiceManagerBase is ServiceManagerBaseStorage {
    using BitmapUtils for *;

    /// @notice when applied to a function, only allows the RegistryCoordinator to call it
    modifier onlyRegistryCoordinator() {
        require(
            msg.sender == address(_registryCoordinator),
            "ServiceManagerBase.onlyRegistryCoordinator: caller is not the registry coordinator"
        );
        _;
    }

    /// @notice only rewardsInitiator can call createAVSRewardsSubmission
    modifier onlyRewardsInitiator() {
        _checkRewardsInitiator();
        _;
    }

    function _checkRewardsInitiator() internal view {
        require(
            msg.sender == rewardsInitiator,
            "ServiceManagerBase.onlyRewardsInitiator: caller is not the rewards initiator"
        );
    }

    /// @notice Sets the (immutable) `_registryCoordinator` address
    constructor(
        IAVSDirectory __avsDirectory,
        IRewardsCoordinator __rewardsCoordinator,
        IRegistryCoordinator __registryCoordinator,
        IStakeRegistry __stakeRegistry
    )
        ServiceManagerBaseStorage(
            __avsDirectory,
            __rewardsCoordinator,
            __registryCoordinator,
            __stakeRegistry
        )
    {
        _disableInitializers();
    }

    function __ServiceManagerBase_init(
        address initialOwner,
        address _rewardsInitiator
    ) internal virtual onlyInitializing {
        _transferOwnership(initialOwner);
        _setRewardsInitiator(_rewardsInitiator);
    }

    /**
     * @notice Updates the metadata URI for the AVS
     * @param _metadataURI is the metadata URI for the AVS
     * @dev only callable by the owner
     */
    function updateAVSMetadataURI(string memory _metadataURI) public virtual onlyOwner {
        _avsDirectory.updateAVSMetadataURI(_metadataURI);
    }

    /**
     * @notice Creates a new rewards submission to the EigenLayer RewardsCoordinator contract, to be split amongst the
     * set of stakers delegated to operators who are registered to this `avs`
     * @param rewardsSubmissions The rewards submissions being created
     * @dev Only callabe by the permissioned rewardsInitiator address
     * @dev The duration of the `rewardsSubmission` cannot exceed `MAX_REWARDS_DURATION`
     * @dev The tokens are sent to the `RewardsCoordinator` contract
     * @dev Strategies must be in ascending order of addresses to check for duplicates
     * @dev This function will revert if the `rewardsSubmission` is malformed,
     * e.g. if the `strategies` and `weights` arrays are of non-equal lengths
     */
    function createAVSRewardsSubmission(IRewardsCoordinator.RewardsSubmission[] calldata rewardsSubmissions)
        public
        virtual
        onlyRewardsInitiator
    {
        for (uint256 i = 0; i < rewardsSubmissions.length; ++i) {
            // transfer token to ServiceManager and approve RewardsCoordinator to transfer again
            // in createAVSRewardsSubmission() call
            rewardsSubmissions[i].token.transferFrom(msg.sender, address(this), rewardsSubmissions[i].amount);
            uint256 allowance =
                rewardsSubmissions[i].token.allowance(address(this), address(_rewardsCoordinator));
            rewardsSubmissions[i].token.approve(
                address(_rewardsCoordinator), rewardsSubmissions[i].amount + allowance
            );
        }

        _rewardsCoordinator.createAVSRewardsSubmission(rewardsSubmissions);
    }

    /**
     * @notice Forwards a call to EigenLayer's AVSDirectory contract to confirm operator registration with the AVS
     * @param operator The address of the operator to register.
     * @param operatorSignature The signature, salt, and expiry of the operator's signature.
     */
    function registerOperatorToAVS(
        address operator,
        ISignatureUtils.SignatureWithSaltAndExpiry memory operatorSignature
    ) public virtual onlyRegistryCoordinator {
        _avsDirectory.registerOperatorToAVS(operator, operatorSignature);
    }

    /**
     * @notice Forwards a call to EigenLayer's AVSDirectory contract to confirm operator deregistration from the AVS
     * @param operator The address of the operator to deregister.
     */
    function deregisterOperatorFromAVS(address operator) public virtual onlyRegistryCoordinator {
        _avsDirectory.deregisterOperatorFromAVS(operator);
    }

    /**
     * @notice Sets the rewards initiator address
     * @param newRewardsInitiator The new rewards initiator address
     * @dev only callable by the owner
     */
    function setRewardsInitiator(address newRewardsInitiator) external onlyOwner {
        _setRewardsInitiator(newRewardsInitiator);
    }

    function _setRewardsInitiator(address newRewardsInitiator) internal {
        emit RewardsInitiatorUpdated(rewardsInitiator, newRewardsInitiator);
        rewardsInitiator = newRewardsInitiator;
    }

    /**
     * @notice Returns the list of strategies that the AVS supports for restaking
     * @dev This function is intended to be called off-chain
     * @dev No guarantee is made on uniqueness of each element in the returned array.
     *      The off-chain service should do that validation separately
     */
    function getRestakeableStrategies() external view returns (address[] memory) {
        uint256 quorumCount = _registryCoordinator.quorumCount();

        if (quorumCount == 0) {
            return new address[](0);
        }

        uint256 strategyCount;
        for (uint256 i = 0; i < quorumCount; i++) {
            strategyCount += _stakeRegistry.strategyParamsLength(uint8(i));
        }

        address[] memory restakedStrategies = new address[](strategyCount);
        uint256 index = 0;
        for (uint256 i = 0; i < _registryCoordinator.quorumCount(); i++) {
            uint256 strategyParamsLength = _stakeRegistry.strategyParamsLength(uint8(i));
            for (uint256 j = 0; j < strategyParamsLength; j++) {
                restakedStrategies[index] =
                    address(_stakeRegistry.strategyParamsByIndex(uint8(i), j).strategy);
                index++;
            }
        }
        return restakedStrategies;
    }

    /**
     * @notice Returns the list of strategies that the operator has potentially restaked on the AVS
     * @param operator The address of the operator to get restaked strategies for
     * @dev This function is intended to be called off-chain
     * @dev No guarantee is made on whether the operator has shares for a strategy in a quorum or uniqueness
     *      of each element in the returned array. The off-chain service should do that validation separately
     */
    function getOperatorRestakedStrategies(address operator)
        external
        view
        returns (address[] memory)
    {
        bytes32 operatorId = _registryCoordinator.getOperatorId(operator);
        uint192 operatorBitmap = _registryCoordinator.getCurrentQuorumBitmap(operatorId);

        if (operatorBitmap == 0 || _registryCoordinator.quorumCount() == 0) {
            return new address[](0);
        }

        // Get number of strategies for each quorum in operator bitmap
        bytes memory operatorRestakedQuorums = BitmapUtils.bitmapToBytesArray(operatorBitmap);
        uint256 strategyCount;
        for (uint256 i = 0; i < operatorRestakedQuorums.length; i++) {
            strategyCount += _stakeRegistry.strategyParamsLength(uint8(operatorRestakedQuorums[i]));
        }

        // Get strategies for each quorum in operator bitmap
        address[] memory restakedStrategies = new address[](strategyCount);
        uint256 index = 0;
        for (uint256 i = 0; i < operatorRestakedQuorums.length; i++) {
            uint8 quorum = uint8(operatorRestakedQuorums[i]);
            uint256 strategyParamsLength = _stakeRegistry.strategyParamsLength(quorum);
            for (uint256 j = 0; j < strategyParamsLength; j++) {
                restakedStrategies[index] =
                    address(_stakeRegistry.strategyParamsByIndex(quorum, j).strategy);
                index++;
            }
        }
        return restakedStrategies;
    }

    /// @notice Returns the EigenLayer AVSDirectory contract.
    function avsDirectory() external view override returns (address) {
        return address(_avsDirectory);
    }
}

// lib/eigenlayer-middleware/src/RegistryCoordinator.sol

/**
 * @title A `RegistryCoordinator` that has three registries:
 *      1) a `StakeRegistry` that keeps track of operators' stakes
 *      2) a `BLSApkRegistry` that keeps track of operators' BLS public keys and aggregate BLS public keys for each quorum
 *      3) an `IndexRegistry` that keeps track of an ordered list of operators for each quorum
 * 
 * @author Layr Labs, Inc.
 */
contract RegistryCoordinator is 
    EIP712, 
    Initializable, 
    Pausable,
    OwnableUpgradeable,
    RegistryCoordinatorStorage, 
    ISocketUpdater, 
    ISignatureUtils
{
    using BitmapUtils for *;
    using BN254 for BN254.G1Point;

    modifier onlyEjector {
        _checkEjector();
        _;
    }

    /// @dev Checks that `quorumNumber` corresponds to a quorum that has been created
    /// via `initialize` or `createQuorum`
    modifier quorumExists(uint8 quorumNumber) {
        _checkQuorumExists(quorumNumber);
        _;
    }

    constructor(
        IServiceManager _serviceManager,
        IStakeRegistry _stakeRegistry,
        IBLSApkRegistry _blsApkRegistry,
        IIndexRegistry _indexRegistry
    ) 
        RegistryCoordinatorStorage(_serviceManager, _stakeRegistry, _blsApkRegistry, _indexRegistry)
        EIP712("AVSRegistryCoordinator", "v0.0.1") 
    {
        _disableInitializers();
    }

    /**
     * @param _initialOwner will hold the owner role
     * @param _churnApprover will hold the churnApprover role, which authorizes registering with churn
     * @param _ejector will hold the ejector role, which can force-eject operators from quorums
     * @param _pauserRegistry a registry of addresses that can pause the contract
     * @param _initialPausedStatus pause status after calling initialize
     * Config for initial quorums (see `createQuorum`):
     * @param _operatorSetParams max operator count and operator churn parameters
     * @param _minimumStakes minimum stake weight to allow an operator to register
     * @param _strategyParams which Strategies/multipliers a quorum considers when calculating stake weight
     */
    function initialize(
        address _initialOwner,
        address _churnApprover,
        address _ejector,
        IPauserRegistry _pauserRegistry,
        uint256 _initialPausedStatus,
        OperatorSetParam[] memory _operatorSetParams,
        uint96[] memory _minimumStakes,
        IStakeRegistry.StrategyParams[][] memory _strategyParams
    ) external initializer {
        require(
            _operatorSetParams.length == _minimumStakes.length && _minimumStakes.length == _strategyParams.length,
            "RegistryCoordinator.initialize: input length mismatch"
        );
        
        // Initialize roles
        _transferOwnership(_initialOwner);
        _initializePauser(_pauserRegistry, _initialPausedStatus);
        _setChurnApprover(_churnApprover);
        _setEjector(_ejector);

        // Add registry contracts to the registries array
        registries.push(address(stakeRegistry));
        registries.push(address(blsApkRegistry));
        registries.push(address(indexRegistry));

        // Create quorums
        for (uint256 i = 0; i < _operatorSetParams.length; i++) {
            _createQuorum(_operatorSetParams[i], _minimumStakes[i], _strategyParams[i]);
        }
    }

    /*******************************************************************************
                            EXTERNAL FUNCTIONS 
    *******************************************************************************/

    /**
     * @notice Registers msg.sender as an operator for one or more quorums. If any quorum exceeds its maximum
     * operator capacity after the operator is registered, this method will fail.
     * @param quorumNumbers is an ordered byte array containing the quorum numbers being registered for
     * @param socket is the socket of the operator (typically an IP address)
     * @param params contains the G1 & G2 public keys of the operator, and a signature proving their ownership
     * @param operatorSignature is the signature of the operator used by the AVS to register the operator in the delegation manager
     * @dev `params` is ignored if the caller has previously registered a public key
     * @dev `operatorSignature` is ignored if the operator's status is already REGISTERED
     */
    function registerOperator(
        bytes calldata quorumNumbers,
        string calldata socket,
        IBLSApkRegistry.PubkeyRegistrationParams calldata params,
        SignatureWithSaltAndExpiry memory operatorSignature
    ) external onlyWhenNotPaused(PAUSED_REGISTER_OPERATOR) {
        /**
         * If the operator has NEVER registered a pubkey before, use `params` to register
         * their pubkey in blsApkRegistry
         *
         * If the operator HAS registered a pubkey, `params` is ignored and the pubkey hash
         * (operatorId) is fetched instead
         */
        bytes32 operatorId = _getOrCreateOperatorId(msg.sender, params);

        // Register the operator in each of the registry contracts and update the operator's
        // quorum bitmap and registration status
        uint32[] memory numOperatorsPerQuorum = _registerOperator({
            operator: msg.sender, 
            operatorId: operatorId,
            quorumNumbers: quorumNumbers, 
            socket: socket,
            operatorSignature: operatorSignature
        }).numOperatorsPerQuorum;

        // For each quorum, validate that the new operator count does not exceed the maximum
        // (If it does, an operator needs to be replaced -- see `registerOperatorWithChurn`)
        for (uint256 i = 0; i < quorumNumbers.length; i++) {
            uint8 quorumNumber = uint8(quorumNumbers[i]);

            require(
                numOperatorsPerQuorum[i] <= _quorumParams[quorumNumber].maxOperatorCount,
                "RegistryCoordinator.registerOperator: operator count exceeds maximum"
            );
        }
    }

    /**
     * @notice Registers msg.sender as an operator for one or more quorums. If any quorum reaches its maximum operator
     * capacity, `operatorKickParams` is used to replace an old operator with the new one.
     * @param quorumNumbers is an ordered byte array containing the quorum numbers being registered for
     * @param params contains the G1 & G2 public keys of the operator, and a signature proving their ownership
     * @param operatorKickParams used to determine which operator is removed to maintain quorum capacity as the
     * operator registers for quorums
     * @param churnApproverSignature is the signature of the churnApprover over the `operatorKickParams`
     * @param operatorSignature is the signature of the operator used by the AVS to register the operator in the delegation manager
     * @dev `params` is ignored if the caller has previously registered a public key
     * @dev `operatorSignature` is ignored if the operator's status is already REGISTERED
     */
    function registerOperatorWithChurn(
        bytes calldata quorumNumbers, 
        string calldata socket,
        IBLSApkRegistry.PubkeyRegistrationParams calldata params,
        OperatorKickParam[] calldata operatorKickParams,
        SignatureWithSaltAndExpiry memory churnApproverSignature,
        SignatureWithSaltAndExpiry memory operatorSignature
    ) external onlyWhenNotPaused(PAUSED_REGISTER_OPERATOR) {
        require(operatorKickParams.length == quorumNumbers.length, "RegistryCoordinator.registerOperatorWithChurn: input length mismatch");
        
        /**
         * If the operator has NEVER registered a pubkey before, use `params` to register
         * their pubkey in blsApkRegistry
         *
         * If the operator HAS registered a pubkey, `params` is ignored and the pubkey hash
         * (operatorId) is fetched instead
         */
        bytes32 operatorId = _getOrCreateOperatorId(msg.sender, params);

        // Verify the churn approver's signature for the registering operator and kick params
        _verifyChurnApproverSignature({
            registeringOperator: msg.sender,
            registeringOperatorId: operatorId,
            operatorKickParams: operatorKickParams,
            churnApproverSignature: churnApproverSignature
        });

        // Register the operator in each of the registry contracts and update the operator's
        // quorum bitmap and registration status
        RegisterResults memory results = _registerOperator({
            operator: msg.sender,
            operatorId: operatorId,
            quorumNumbers: quorumNumbers,
            socket: socket,
            operatorSignature: operatorSignature
        });

        // Check that each quorum's operator count is below the configured maximum. If the max
        // is exceeded, use `operatorKickParams` to deregister an existing operator to make space
        for (uint256 i = 0; i < quorumNumbers.length; i++) {
            OperatorSetParam memory operatorSetParams = _quorumParams[uint8(quorumNumbers[i])];
            
            /**
             * If the new operator count for any quorum exceeds the maximum, validate
             * that churn can be performed, then deregister the specified operator
             */
            if (results.numOperatorsPerQuorum[i] > operatorSetParams.maxOperatorCount) {
                _validateChurn({
                    quorumNumber: uint8(quorumNumbers[i]),
                    totalQuorumStake: results.totalStakes[i],
                    newOperator: msg.sender,
                    newOperatorStake: results.operatorStakes[i],
                    kickParams: operatorKickParams[i],
                    setParams: operatorSetParams
                });

                _deregisterOperator(operatorKickParams[i].operator, quorumNumbers[i:i+1]);
            }
        }
    }

    /**
     * @notice Deregisters the caller from one or more quorums
     * @param quorumNumbers is an ordered byte array containing the quorum numbers being deregistered from
     */
    function deregisterOperator(
        bytes calldata quorumNumbers
    ) external onlyWhenNotPaused(PAUSED_DEREGISTER_OPERATOR) {
        _deregisterOperator({
            operator: msg.sender, 
            quorumNumbers: quorumNumbers
        });
    }

    /**
     * @notice Updates the StakeRegistry's view of one or more operators' stakes. If any operator
     * is found to be below the minimum stake for the quorum, they are deregistered.
     * @dev stakes are queried from the Eigenlayer core DelegationManager contract
     * @param operators a list of operator addresses to update
     */
    function updateOperators(address[] calldata operators) external onlyWhenNotPaused(PAUSED_UPDATE_OPERATOR) {
        for (uint256 i = 0; i < operators.length; i++) {
            address operator = operators[i];
            OperatorInfo memory operatorInfo = _operatorInfo[operator];
            bytes32 operatorId = operatorInfo.operatorId;

            // Update the operator's stake for their active quorums
            uint192 currentBitmap = _currentOperatorBitmap(operatorId);
            bytes memory quorumsToUpdate = BitmapUtils.bitmapToBytesArray(currentBitmap);
            _updateOperator(operator, operatorInfo, quorumsToUpdate);
        }
    }

    /**
     * @notice For each quorum in `quorumNumbers`, updates the StakeRegistry's view of ALL its registered operators' stakes.
     * Each quorum's `quorumUpdateBlockNumber` is also updated, which tracks the most recent block number when ALL registered
     * operators were updated.
     * @dev stakes are queried from the Eigenlayer core DelegationManager contract
     * @param operatorsPerQuorum for each quorum in `quorumNumbers`, this has a corresponding list of operators to update.
     * @dev Each list of operator addresses MUST be sorted in ascending order
     * @dev Each list of operator addresses MUST represent the entire list of registered operators for the corresponding quorum
     * @param quorumNumbers is an ordered byte array containing the quorum numbers being updated
     * @dev invariant: Each list of `operatorsPerQuorum` MUST be a sorted version of `IndexRegistry.getOperatorListAtBlockNumber`
     * for the corresponding quorum.
     * @dev note on race condition: if an operator registers/deregisters for any quorum in `quorumNumbers` after a txn to 
     * this method is broadcast (but before it is executed), the method will fail
     */
    function updateOperatorsForQuorum(
        address[][] calldata operatorsPerQuorum,
        bytes calldata quorumNumbers
    ) external onlyWhenNotPaused(PAUSED_UPDATE_OPERATOR) {
        // Input validation 
        // - all quorums should exist (checked against `quorumCount` in orderedBytesArrayToBitmap)
        // - there should be no duplicates in `quorumNumbers`
        // - there should be one list of operators per quorum
        uint192 quorumBitmap = uint192(BitmapUtils.orderedBytesArrayToBitmap(quorumNumbers, quorumCount));
        require(
            operatorsPerQuorum.length == quorumNumbers.length,
            "RegistryCoordinator.updateOperatorsForQuorum: input length mismatch"
        );

        // For each quorum, update ALL registered operators
        for (uint256 i = 0; i < quorumNumbers.length; ++i) {
            uint8 quorumNumber = uint8(quorumNumbers[i]);

            // Ensure we've passed in the correct number of operators for this quorum
            address[] calldata currQuorumOperators = operatorsPerQuorum[i];
            require(
                currQuorumOperators.length == indexRegistry.totalOperatorsForQuorum(quorumNumber),
                "RegistryCoordinator.updateOperatorsForQuorum: number of updated operators does not match quorum total"
            );

            address prevOperatorAddress = address(0);
            // For each operator:
            // - check that they are registered for this quorum
            // - check that their address is strictly greater than the last operator
            // ... then, update their stakes
            for (uint256 j = 0; j < currQuorumOperators.length; ++j) {
                address operator = currQuorumOperators[j];
                
                OperatorInfo memory operatorInfo = _operatorInfo[operator];
                bytes32 operatorId = operatorInfo.operatorId;
                
                {
                    uint192 currentBitmap = _currentOperatorBitmap(operatorId);
                    // Check that the operator is registered
                    require(
                        BitmapUtils.isSet(currentBitmap, quorumNumber),
                        "RegistryCoordinator.updateOperatorsForQuorum: operator not in quorum"
                    );
                    // Prevent duplicate operators
                    require(
                        operator > prevOperatorAddress,
                        "RegistryCoordinator.updateOperatorsForQuorum: operators array must be sorted in ascending address order"
                    );
                }
                
                // Update the operator
                _updateOperator(operator, operatorInfo, quorumNumbers[i:i+1]);
                prevOperatorAddress = operator;
            }

            // Update timestamp that all operators in quorum have been updated all at once
            quorumUpdateBlockNumber[quorumNumber] = block.number;
            emit QuorumBlockNumberUpdated(quorumNumber, block.number);
        }
    }

    /**
     * @notice Updates the socket of the msg.sender given they are a registered operator
     * @param socket is the new socket of the operator
     */
    function updateSocket(string memory socket) external {
        require(_operatorInfo[msg.sender].status == OperatorStatus.REGISTERED, "RegistryCoordinator.updateSocket: operator is not registered");
        emit OperatorSocketUpdate(_operatorInfo[msg.sender].operatorId, socket);
    }

    /*******************************************************************************
                            EXTERNAL FUNCTIONS - EJECTOR
    *******************************************************************************/

    /**
     * @notice Forcibly deregisters an operator from one or more quorums
     * @param operator the operator to eject
     * @param quorumNumbers the quorum numbers to eject the operator from
     * @dev possible race condition if prior to being ejected for a set of quorums the operator self deregisters from a subset
     */
    function ejectOperator(
        address operator, 
        bytes calldata quorumNumbers
    ) external onlyEjector {
        lastEjectionTimestamp[operator] = block.timestamp;

        OperatorInfo storage operatorInfo = _operatorInfo[operator];
        bytes32 operatorId = operatorInfo.operatorId;
        uint192 quorumsToRemove = uint192(BitmapUtils.orderedBytesArrayToBitmap(quorumNumbers, quorumCount));
        uint192 currentBitmap = _currentOperatorBitmap(operatorId);
        if(
            operatorInfo.status == OperatorStatus.REGISTERED && 
            !quorumsToRemove.isEmpty() &&
            quorumsToRemove.isSubsetOf(currentBitmap) 
        ){
            _deregisterOperator({
                operator: operator, 
                quorumNumbers: quorumNumbers
            });
        }
    }

    /*******************************************************************************
                            EXTERNAL FUNCTIONS - OWNER
    *******************************************************************************/

    /**
     * @notice Creates a quorum and initializes it in each registry contract
     * @param operatorSetParams configures the quorum's max operator count and churn parameters
     * @param minimumStake sets the minimum stake required for an operator to register or remain
     * registered
     * @param strategyParams a list of strategies and multipliers used by the StakeRegistry to
     * calculate an operator's stake weight for the quorum
     */
    function createQuorum(
        OperatorSetParam memory operatorSetParams,
        uint96 minimumStake,
        IStakeRegistry.StrategyParams[] memory strategyParams
    ) external virtual onlyOwner {
        _createQuorum(operatorSetParams, minimumStake, strategyParams);
    }

    /**
     * @notice Updates an existing quorum's configuration with a new max operator count
     * and operator churn parameters
     * @param quorumNumber the quorum number to update
     * @param operatorSetParams the new config
     * @dev only callable by the owner
     */
    function setOperatorSetParams(
        uint8 quorumNumber, 
        OperatorSetParam memory operatorSetParams
    ) external onlyOwner quorumExists(quorumNumber) {
        _setOperatorSetParams(quorumNumber, operatorSetParams);
    }

    /**
     * @notice Sets the churnApprover, which approves operator registration with churn
     * (see `registerOperatorWithChurn`)
     * @param _churnApprover the new churn approver
     * @dev only callable by the owner
     */
    function setChurnApprover(address _churnApprover) external onlyOwner {
        _setChurnApprover(_churnApprover);
    }

    /**
     * @notice Sets the ejector, which can force-deregister operators from quorums
     * @param _ejector the new ejector
     * @dev only callable by the owner
     */
    function setEjector(address _ejector) external onlyOwner {
        _setEjector(_ejector);
    }

    /**
     * @notice Sets the ejection cooldown, which is the time an operator must wait in 
     * seconds afer ejection before registering for any quorum
     * @param _ejectionCooldown the new ejection cooldown in seconds
     * @dev only callable by the owner
     */
    function setEjectionCooldown(uint256 _ejectionCooldown) external onlyOwner {
        ejectionCooldown = _ejectionCooldown;
    }

    /*******************************************************************************
                            INTERNAL FUNCTIONS
    *******************************************************************************/

    struct RegisterResults {
        uint32[] numOperatorsPerQuorum;
        uint96[] operatorStakes;
        uint96[] totalStakes;
    }

    /** 
     * @notice Register the operator for one or more quorums. This method updates the
     * operator's quorum bitmap, socket, and status, then registers them with each registry.
     */
    function _registerOperator(
        address operator, 
        bytes32 operatorId,
        bytes calldata quorumNumbers,
        string memory socket,
        SignatureWithSaltAndExpiry memory operatorSignature
    ) internal virtual returns (RegisterResults memory results) {
        /**
         * Get bitmap of quorums to register for and operator's current bitmap. Validate that:
         * - we're trying to register for at least 1 quorum
         * - the quorums we're registering for exist (checked against `quorumCount` in orderedBytesArrayToBitmap)
         * - the operator is not currently registered for any quorums we're registering for
         * Then, calculate the operator's new bitmap after registration
         */
        uint192 quorumsToAdd = uint192(BitmapUtils.orderedBytesArrayToBitmap(quorumNumbers, quorumCount));
        uint192 currentBitmap = _currentOperatorBitmap(operatorId);
        require(!quorumsToAdd.isEmpty(), "RegistryCoordinator._registerOperator: bitmap cannot be 0");
        require(quorumsToAdd.noBitsInCommon(currentBitmap), "RegistryCoordinator._registerOperator: operator already registered for some quorums being registered for");
        uint192 newBitmap = uint192(currentBitmap.plus(quorumsToAdd));

        // Check that the operator can reregister if ejected
        require(lastEjectionTimestamp[operator] + ejectionCooldown < block.timestamp, "RegistryCoordinator._registerOperator: operator cannot reregister yet");

        /**
         * Update operator's bitmap, socket, and status. Only update operatorInfo if needed:
         * if we're `REGISTERED`, the operatorId and status are already correct.
         */
        _updateOperatorBitmap({
            operatorId: operatorId,
            newBitmap: newBitmap
        });

        emit OperatorSocketUpdate(operatorId, socket);

        // If the operator wasn't registered for any quorums, update their status
        // and register them with this AVS in EigenLayer core (DelegationManager)
        if (_operatorInfo[operator].status != OperatorStatus.REGISTERED) {
            _operatorInfo[operator] = OperatorInfo({
                operatorId: operatorId,
                status: OperatorStatus.REGISTERED
            });

            // Register the operator with the EigenLayer core contracts via this AVS's ServiceManager
            serviceManager.registerOperatorToAVS(operator, operatorSignature);

            emit OperatorRegistered(operator, operatorId);
        }

        // Register the operator with the BLSApkRegistry, StakeRegistry, and IndexRegistry
        blsApkRegistry.registerOperator(operator, quorumNumbers);
        (results.operatorStakes, results.totalStakes) = 
            stakeRegistry.registerOperator(operator, operatorId, quorumNumbers);
        results.numOperatorsPerQuorum = indexRegistry.registerOperator(operatorId, quorumNumbers);

        return results;
    }

    /**
     * @notice Checks if the caller is the ejector
     * @dev Reverts if the caller is not the ejector
     */
    function _checkEjector() internal view {
        require(msg.sender == ejector, "RegistryCoordinator.onlyEjector: caller is not the ejector");
    }

    /**
     * @notice Checks if a quorum exists
     * @param quorumNumber The quorum number to check
     * @dev Reverts if the quorum does not exist
     */
    function _checkQuorumExists(uint8 quorumNumber) internal view {
        require(
            quorumNumber < quorumCount, 
            "RegistryCoordinator.quorumExists: quorum does not exist"
        );
    }

    /**
     * @notice Fetches an operator's pubkey hash from the BLSApkRegistry. If the
     * operator has not registered a pubkey, attempts to register a pubkey using
     * `params`
     * @param operator the operator whose pubkey to query from the BLSApkRegistry
     * @param params contains the G1 & G2 public keys of the operator, and a signature proving their ownership
     * @dev `params` can be empty if the operator has already registered a pubkey in the BLSApkRegistry
     */
    function _getOrCreateOperatorId(
        address operator,
        IBLSApkRegistry.PubkeyRegistrationParams calldata params
    ) internal returns (bytes32 operatorId) {
        operatorId = blsApkRegistry.getOperatorId(operator);
        if (operatorId == 0) {
            operatorId = blsApkRegistry.registerBLSPublicKey(operator, params, pubkeyRegistrationMessageHash(operator));
        }
        return operatorId;
    }

    /**
     * @notice Validates that an incoming operator is eligible to replace an existing
     * operator based on the stake of both
     * @dev In order to churn, the incoming operator needs to have more stake than the
     * existing operator by a proportion given by `kickBIPsOfOperatorStake`
     * @dev In order to be churned out, the existing operator needs to have a proportion
     * of the total quorum stake less than `kickBIPsOfTotalStake`
     * @param quorumNumber `newOperator` is trying to replace an operator in this quorum
     * @param totalQuorumStake the total stake of all operators in the quorum, after the
     * `newOperator` registers
     * @param newOperator the incoming operator
     * @param newOperatorStake the incoming operator's stake
     * @param kickParams the quorum number and existing operator to replace
     * @dev the existing operator's registration to this quorum isn't checked here, but
     * if we attempt to deregister them, this will be checked in `_deregisterOperator`
     * @param setParams config for this quorum containing `kickBIPsX` stake proportions
     * mentioned above
     */
    function _validateChurn(
        uint8 quorumNumber, 
        uint96 totalQuorumStake,
        address newOperator, 
        uint96 newOperatorStake,
        OperatorKickParam memory kickParams, 
        OperatorSetParam memory setParams
    ) internal view {
        address operatorToKick = kickParams.operator;
        bytes32 idToKick = _operatorInfo[operatorToKick].operatorId;
        require(newOperator != operatorToKick, "RegistryCoordinator._validateChurn: cannot churn self");
        require(kickParams.quorumNumber == quorumNumber, "RegistryCoordinator._validateChurn: quorumNumber not the same as signed");

        // Get the target operator's stake and check that it is below the kick thresholds
        uint96 operatorToKickStake = stakeRegistry.getCurrentStake(idToKick, quorumNumber);
        require(
            newOperatorStake > _individualKickThreshold(operatorToKickStake, setParams),
            "RegistryCoordinator._validateChurn: incoming operator has insufficient stake for churn"
        );
        require(
            operatorToKickStake < _totalKickThreshold(totalQuorumStake, setParams),
            "RegistryCoordinator._validateChurn: cannot kick operator with more than kickBIPsOfTotalStake"
        );
    }

    /**
     * @dev Deregister the operator from one or more quorums
     * This method updates the operator's quorum bitmap and status, then deregisters
     * the operator with the BLSApkRegistry, IndexRegistry, and StakeRegistry
     */
    function _deregisterOperator(
        address operator, 
        bytes memory quorumNumbers
    ) internal virtual {
        // Fetch the operator's info and ensure they are registered
        OperatorInfo storage operatorInfo = _operatorInfo[operator];
        bytes32 operatorId = operatorInfo.operatorId;
        require(operatorInfo.status == OperatorStatus.REGISTERED, "RegistryCoordinator._deregisterOperator: operator is not registered");
        
        /**
         * Get bitmap of quorums to deregister from and operator's current bitmap. Validate that:
         * - we're trying to deregister from at least 1 quorum
         * - the quorums we're deregistering from exist (checked against `quorumCount` in orderedBytesArrayToBitmap)
         * - the operator is currently registered for any quorums we're trying to deregister from
         * Then, calculate the operator's new bitmap after deregistration
         */
        uint192 quorumsToRemove = uint192(BitmapUtils.orderedBytesArrayToBitmap(quorumNumbers, quorumCount));
        uint192 currentBitmap = _currentOperatorBitmap(operatorId);
        require(!quorumsToRemove.isEmpty(), "RegistryCoordinator._deregisterOperator: bitmap cannot be 0");
        require(quorumsToRemove.isSubsetOf(currentBitmap), "RegistryCoordinator._deregisterOperator: operator is not registered for specified quorums");
        uint192 newBitmap = uint192(currentBitmap.minus(quorumsToRemove));

        // Update operator's bitmap and status
        _updateOperatorBitmap({
            operatorId: operatorId,
            newBitmap: newBitmap
        });

        // If the operator is no longer registered for any quorums, update their status and deregister 
        // them from the AVS via the EigenLayer core contracts
        if (newBitmap.isEmpty()) {
            operatorInfo.status = OperatorStatus.DEREGISTERED;
            serviceManager.deregisterOperatorFromAVS(operator);
            emit OperatorDeregistered(operator, operatorId);
        }

        // Deregister operator with each of the registry contracts
        blsApkRegistry.deregisterOperator(operator, quorumNumbers);
        stakeRegistry.deregisterOperator(operatorId, quorumNumbers);
        indexRegistry.deregisterOperator(operatorId, quorumNumbers);
    }

    /**
     * @notice Updates the StakeRegistry's view of the operator's stake in one or more quorums.
     * For any quorums where the StakeRegistry finds the operator is under the configured minimum
     * stake, `quorumsToRemove` is returned and used to deregister the operator from those quorums
     * @dev does nothing if operator is not registered for any quorums.
     */
    function _updateOperator(
        address operator,
        OperatorInfo memory operatorInfo,
        bytes memory quorumsToUpdate
    ) internal {
        if (operatorInfo.status != OperatorStatus.REGISTERED) {
            return;
        }
        bytes32 operatorId = operatorInfo.operatorId;
        uint192 quorumsToRemove = stakeRegistry.updateOperatorStake(operator, operatorId, quorumsToUpdate);

        if (!quorumsToRemove.isEmpty()) {
            _deregisterOperator({
                operator: operator,
                quorumNumbers: BitmapUtils.bitmapToBytesArray(quorumsToRemove)
            });    
        }
    }

    /**
     * @notice Returns the stake threshold required for an incoming operator to replace an existing operator
     * The incoming operator must have more stake than the return value.
     */
    function _individualKickThreshold(uint96 operatorStake, OperatorSetParam memory setParams) internal pure returns (uint96) {
        return operatorStake * setParams.kickBIPsOfOperatorStake / BIPS_DENOMINATOR;
    }

    /**
     * @notice Returns the total stake threshold required for an operator to remain in a quorum.
     * The operator must have at least the returned stake amount to keep their position.
     */
    function _totalKickThreshold(uint96 totalStake, OperatorSetParam memory setParams) internal pure returns (uint96) {
        return totalStake * setParams.kickBIPsOfTotalStake / BIPS_DENOMINATOR;
    }

    /// @notice verifies churnApprover's signature on operator churn approval and increments the churnApprover nonce
    function _verifyChurnApproverSignature(
        address registeringOperator,
        bytes32 registeringOperatorId, 
        OperatorKickParam[] memory operatorKickParams, 
        SignatureWithSaltAndExpiry memory churnApproverSignature
    ) internal {
        // make sure the salt hasn't been used already
        require(!isChurnApproverSaltUsed[churnApproverSignature.salt], "RegistryCoordinator._verifyChurnApproverSignature: churnApprover salt already used");
        require(churnApproverSignature.expiry >= block.timestamp, "RegistryCoordinator._verifyChurnApproverSignature: churnApprover signature expired");   

        // set salt used to true
        isChurnApproverSaltUsed[churnApproverSignature.salt] = true;    

        // check the churnApprover's signature 
        EIP1271SignatureUtils.checkSignature_EIP1271(
            churnApprover, 
            calculateOperatorChurnApprovalDigestHash(registeringOperator, registeringOperatorId, operatorKickParams, churnApproverSignature.salt, churnApproverSignature.expiry), 
            churnApproverSignature.signature
        );
    }

    /**
     * @notice Creates a quorum and initializes it in each registry contract
     * @param operatorSetParams configures the quorum's max operator count and churn parameters
     * @param minimumStake sets the minimum stake required for an operator to register or remain
     * registered
     * @param strategyParams a list of strategies and multipliers used by the StakeRegistry to
     * calculate an operator's stake weight for the quorum
     */
    function _createQuorum(
        OperatorSetParam memory operatorSetParams,
        uint96 minimumStake,
        IStakeRegistry.StrategyParams[] memory strategyParams
    ) internal {
        // Increment the total quorum count. Fails if we're already at the max
        uint8 prevQuorumCount = quorumCount;
        require(prevQuorumCount < MAX_QUORUM_COUNT, "RegistryCoordinator.createQuorum: max quorums reached");
        quorumCount = prevQuorumCount + 1;
        
        // The previous count is the new quorum's number
        uint8 quorumNumber = prevQuorumCount;

        // Initialize the quorum here and in each registry
        _setOperatorSetParams(quorumNumber, operatorSetParams);
        stakeRegistry.initializeQuorum(quorumNumber, minimumStake, strategyParams);
        indexRegistry.initializeQuorum(quorumNumber);
        blsApkRegistry.initializeQuorum(quorumNumber);
    }

    /**
     * @notice Record an update to an operator's quorum bitmap.
     * @param newBitmap is the most up-to-date set of bitmaps the operator is registered for
     */
    function _updateOperatorBitmap(bytes32 operatorId, uint192 newBitmap) internal {

        uint256 historyLength = _operatorBitmapHistory[operatorId].length;

        if (historyLength == 0) {
            // No prior bitmap history - push our first entry
            _operatorBitmapHistory[operatorId].push(QuorumBitmapUpdate({
                updateBlockNumber: uint32(block.number),
                nextUpdateBlockNumber: 0,
                quorumBitmap: newBitmap
            }));
        } else {
            // We have prior history - fetch our last-recorded update
            QuorumBitmapUpdate storage lastUpdate = _operatorBitmapHistory[operatorId][historyLength - 1];

            /**
             * If the last update was made in the current block, update the entry.
             * Otherwise, push a new entry and update the previous entry's "next" field
             */
            if (lastUpdate.updateBlockNumber == uint32(block.number)) {
                lastUpdate.quorumBitmap = newBitmap;
            } else {
                lastUpdate.nextUpdateBlockNumber = uint32(block.number);
                _operatorBitmapHistory[operatorId].push(QuorumBitmapUpdate({
                    updateBlockNumber: uint32(block.number),
                    nextUpdateBlockNumber: 0,
                    quorumBitmap: newBitmap
                }));
            }
        }
    }

    /// @notice Get the most recent bitmap for the operator, returning an empty bitmap if
    /// the operator is not registered.
    function _currentOperatorBitmap(bytes32 operatorId) internal view returns (uint192) {
        uint256 historyLength = _operatorBitmapHistory[operatorId].length;
        if (historyLength == 0) {
            return 0;
        } else {
            return _operatorBitmapHistory[operatorId][historyLength - 1].quorumBitmap;
        }
    }

    /**
     * @notice Returns the index of the quorumBitmap for the provided `operatorId` at the given `blockNumber`
     * @dev Reverts if the operator had not yet (ever) registered at `blockNumber`
     * @dev This function is designed to find proper inputs to the `getQuorumBitmapAtBlockNumberByIndex` function
     */
    function _getQuorumBitmapIndexAtBlockNumber(
        uint32 blockNumber, 
        bytes32 operatorId
    ) internal view returns (uint32 index) {
        uint256 length = _operatorBitmapHistory[operatorId].length;

        // Traverse the operator's bitmap history in reverse, returning the first index
        // corresponding to an update made before or at `blockNumber`
        for (uint256 i = 0; i < length; i++) {
            index = uint32(length - i - 1);

            if (_operatorBitmapHistory[operatorId][index].updateBlockNumber <= blockNumber) {
                return index;
            }
        }

        revert(
            "RegistryCoordinator.getQuorumBitmapIndexAtBlockNumber: no bitmap update found for operatorId at block number"
        );
    }

    function _setOperatorSetParams(uint8 quorumNumber, OperatorSetParam memory operatorSetParams) internal {
        _quorumParams[quorumNumber] = operatorSetParams;
        emit OperatorSetParamsUpdated(quorumNumber, operatorSetParams);
    }
    
    function _setChurnApprover(address newChurnApprover) internal {
        emit ChurnApproverUpdated(churnApprover, newChurnApprover);
        churnApprover = newChurnApprover;
    }

    function _setEjector(address newEjector) internal {
        emit EjectorUpdated(ejector, newEjector);
        ejector = newEjector;
    }

    /*******************************************************************************
                            VIEW FUNCTIONS
    *******************************************************************************/

    /// @notice Returns the operator set params for the given `quorumNumber`
    function getOperatorSetParams(uint8 quorumNumber) external view returns (OperatorSetParam memory) {
        return _quorumParams[quorumNumber];
    }

    /// @notice Returns the operator struct for the given `operator`
    function getOperator(address operator) external view returns (OperatorInfo memory) {
        return _operatorInfo[operator];
    }

    /// @notice Returns the operatorId for the given `operator`
    function getOperatorId(address operator) external view returns (bytes32) {
        return _operatorInfo[operator].operatorId;
    }

    /// @notice Returns the operator address for the given `operatorId`
    function getOperatorFromId(bytes32 operatorId) external view returns (address) {
        return blsApkRegistry.getOperatorFromPubkeyHash(operatorId);
    }

    /// @notice Returns the status for the given `operator`
    function getOperatorStatus(address operator) external view returns (IRegistryCoordinator.OperatorStatus) {
        return _operatorInfo[operator].status;
    }

    /**
     * @notice Returns the indices of the quorumBitmaps for the provided `operatorIds` at the given `blockNumber`
     * @dev Reverts if any of the `operatorIds` was not (yet) registered at `blockNumber`
     * @dev This function is designed to find proper inputs to the `getQuorumBitmapAtBlockNumberByIndex` function
     */
    function getQuorumBitmapIndicesAtBlockNumber(
        uint32 blockNumber, 
        bytes32[] memory operatorIds
    ) external view returns (uint32[] memory) {
        uint32[] memory indices = new uint32[](operatorIds.length);
        for (uint256 i = 0; i < operatorIds.length; i++) {
            indices[i] = _getQuorumBitmapIndexAtBlockNumber(blockNumber, operatorIds[i]);
        }
        return indices;
    }

    /**
     * @notice Returns the quorum bitmap for the given `operatorId` at the given `blockNumber` via the `index`,
     * reverting if `index` is incorrect
     * @dev This function is meant to be used in concert with `getQuorumBitmapIndicesAtBlockNumber`, which
     * helps off-chain processes to fetch the correct `index` input
     */ 
    function getQuorumBitmapAtBlockNumberByIndex(
        bytes32 operatorId, 
        uint32 blockNumber, 
        uint256 index
    ) external view returns (uint192) {
        QuorumBitmapUpdate memory quorumBitmapUpdate = _operatorBitmapHistory[operatorId][index];
        
        /**
         * Validate that the update is valid for the given blockNumber:
         * - blockNumber should be >= the update block number
         * - the next update block number should be either 0 or strictly greater than blockNumber
         */
        require(
            blockNumber >= quorumBitmapUpdate.updateBlockNumber, 
            "RegistryCoordinator.getQuorumBitmapAtBlockNumberByIndex: quorumBitmapUpdate is from after blockNumber"
        );
        require(
            quorumBitmapUpdate.nextUpdateBlockNumber == 0 || blockNumber < quorumBitmapUpdate.nextUpdateBlockNumber,
            "RegistryCoordinator.getQuorumBitmapAtBlockNumberByIndex: quorumBitmapUpdate is from before blockNumber"
        );

        return quorumBitmapUpdate.quorumBitmap;
    }

    /// @notice Returns the `index`th entry in the operator with `operatorId`'s bitmap history
    function getQuorumBitmapUpdateByIndex(
        bytes32 operatorId, 
        uint256 index
    ) external view returns (QuorumBitmapUpdate memory) {
        return _operatorBitmapHistory[operatorId][index];
    }

    /// @notice Returns the current quorum bitmap for the given `operatorId` or 0 if the operator is not registered for any quorum
    function getCurrentQuorumBitmap(bytes32 operatorId) external view returns (uint192) {
        return _currentOperatorBitmap(operatorId);
    }

    /// @notice Returns the length of the quorum bitmap history for the given `operatorId`
    function getQuorumBitmapHistoryLength(bytes32 operatorId) external view returns (uint256) {
        return _operatorBitmapHistory[operatorId].length;
    }

    /// @notice Returns the number of registries
    function numRegistries() external view returns (uint256) {
        return registries.length;
    }

    /**
     * @notice Public function for the the churnApprover signature hash calculation when operators are being kicked from quorums
     * @param registeringOperatorId The id of the registering operator 
     * @param operatorKickParams The parameters needed to kick the operator from the quorums that have reached their caps
     * @param salt The salt to use for the churnApprover's signature
     * @param expiry The desired expiry time of the churnApprover's signature
     */
    function calculateOperatorChurnApprovalDigestHash(
        address registeringOperator,
        bytes32 registeringOperatorId,
        OperatorKickParam[] memory operatorKickParams,
        bytes32 salt,
        uint256 expiry
    ) public view returns (bytes32) {
        // calculate the digest hash
        return _hashTypedDataV4(keccak256(abi.encode(OPERATOR_CHURN_APPROVAL_TYPEHASH, registeringOperator, registeringOperatorId, operatorKickParams, salt, expiry)));
    }

    /**
     * @notice Returns the message hash that an operator must sign to register their BLS public key.
     * @param operator is the address of the operator registering their BLS public key
     */
    function pubkeyRegistrationMessageHash(address operator) public view returns (BN254.G1Point memory) {
        return BN254.hashToG1(
            _hashTypedDataV4(
                keccak256(abi.encode(PUBKEY_REGISTRATION_TYPEHASH, operator))
            )
        );
    }

    /// @dev need to override function here since its defined in both these contracts
    function owner()
        public
        view
        override(OwnableUpgradeable, IRegistryCoordinator)
        returns (address)
    {
        return OwnableUpgradeable.owner();
    }
}

// src/TaskManager.sol

/// @title TaskManager Contract
/// @dev This contract is responsible for managing tasks, responses, and interactions between the aggregator and task generator.
abstract contract TaskManager is BLSSignatureChecker, OwnableUpgradeable {
    event NewTaskCreated(uint32 indexed taskIndex, Task task);
    event TaskResponded(
        TaskResponse taskResponse,
        TaskResponseMetadata taskResponseMetadata
    );

    /// @notice Emitted when the aggregator address is updated.
    /// @param oldAggregator The previous aggregator address.
    /// @param newAggregator The new aggregator address.
    event AggregatorUpdated(
        address indexed oldAggregator,
        address indexed newAggregator
    );

    /// @notice Emitted when the generator address is updated.
    /// @param oldGenerator The previous generator address.
    /// @param newGenerator The new generator address.
    event GeneratorUpdated(
        address indexed oldGenerator,
        address indexed newGenerator
    );

    // STRUCTS

    /// @dev Defines the structure of a task.
    struct Task {
        uint32 taskCreatedBlock;
        uint32 quorumThresholdPercentage;
        bytes message;
        bytes quorumNumbers;
    }

    // Task response is hashed and signed by operators.
    // these signatures are aggregated and sent to the contract as response.
    struct TaskResponse {
        // Can be obtained by the operator from the event NewTaskCreated.
        uint32 referenceTaskIndex;
        // This is just the response that the operator has to compute by itself.
        bytes message;
    }

    // Extra information related to taskResponse, which is filled inside the contract.
    // It thus cannot be signed by operators, so we keep it in a separate struct than TaskResponse
    // This metadata is needed by the challenger, so we emit it in the TaskResponded event
    struct TaskResponseMetadata {
        uint32 taskResponsedBlock;
        bytes32 hashOfNonSigners;
    }

    /* CONSTANT */
    uint256 internal constant _THRESHOLD_DENOMINATOR = 100;

    // The number of blocks from the task initialization within which the aggregator has to respond to
    uint32 public immutable TASK_RESPONSE_WINDOW_BLOCK;

    /* STORAGE */
    // The latest task index
    uint32 public latestTaskNum;

    // mapping of task indices to all tasks hashes
    // when a task is created, task hash is stored here,
    // and responses need to pass the actual task,
    // which is hashed onchain and checked against this mapping
    mapping(uint32 => bytes32) public allTaskHashes;

    // mapping of task indices to hash of abi.encode(taskResponse, taskResponseMetadata)
    mapping(uint32 => bytes32) public allTaskResponses;

    address public aggregator;
    address public generator;

    // storage gap for upgradeability
    // slither-disable-next-line shadowing-state
    uint256[45] private __GAP;

    /* MODIFIERS */

    /// @dev Modifier to allow only the aggregator to call certain functions.
    modifier onlyAggregator() {
        require(msg.sender == aggregator, "Aggregator must be the caller");
        _;
    }

    /// @dev Modifier to allow only the task generator to create new tasks.
    modifier onlyTaskGenerator() {
        require(msg.sender == generator, "Task generator must be the caller");
        _;
    }

    /// @notice Constructor to initialize the contract.
    /// @param _registryCoordinator Address of the registry coordinator.
    /// @param _taskResponseWindowBlock Number of blocks within which the aggregator has to respond to a task.
    constructor(
        IRegistryCoordinator _registryCoordinator,
        uint32 _taskResponseWindowBlock
    ) BLSSignatureChecker(_registryCoordinator) {
        TASK_RESPONSE_WINDOW_BLOCK = _taskResponseWindowBlock;
    }

    /// @notice Initializes the contract with aggregator and generator addresses and transfers ownership.
    /// @param _aggregator Address of the aggregator.
    /// @param _generator Address of the task generator.
    /// @param initialOwner Address of the initial owner.
    function __TaskManager_init(
        address _aggregator,
        address _generator,
        address initialOwner
    ) public onlyInitializing {
        __Ownable_init();
        transferOwnership(initialOwner);
        _setAggregator(_aggregator);
        _setGenerator(_generator);
    }

    /// @notice Sets a new aggregator address.
    /// @dev Only callable by the contract owner.
    /// @param newAggregator Address of the new aggregator.
    function setAggregator(address newAggregator) external onlyOwner {
        _setAggregator(newAggregator);
    }

    /// @notice Sets a new generator address.
    /// @dev Only callable by the contract owner.
    /// @param newGenerator Address of the new task generator.
    function setGenerator(address newGenerator) external onlyOwner {
        _setGenerator(newGenerator);
    }

    /* FUNCTIONS */

    /// @notice Creates a new task and assigns it a taskId.
    /// @param message Message payload of the task.
    /// @param quorumThresholdPercentage Minimum percentage of quorum required.
    /// @param quorumNumbers Numbers representing the quorum.
    /// @dev Only callable by the task generator.
    function _createNewTask(
        bytes calldata message,
        uint32 quorumThresholdPercentage,
        bytes calldata quorumNumbers
    ) internal onlyTaskGenerator {
        Task memory newTask;
        newTask.message = message;
        newTask.taskCreatedBlock = uint32(block.number);
        newTask.quorumThresholdPercentage = quorumThresholdPercentage;
        newTask.quorumNumbers = quorumNumbers;

        allTaskHashes[latestTaskNum] = keccak256(abi.encode(newTask));
        emit NewTaskCreated(latestTaskNum, newTask);
        latestTaskNum++;
    }

    /// @notice Responds to an existing task.
    /// @param task The task being responded to.
    /// @param taskResponse The response data to the task.
    /// @param nonSignerStakesAndSignature Signature and stakes of non-signers for verification.
    /// @dev Only callable by the aggregator.
    function _respondToTask(
        Task calldata task,
        TaskResponse calldata taskResponse,
        NonSignerStakesAndSignature memory nonSignerStakesAndSignature
    ) internal onlyAggregator {
        uint32 taskCreatedBlock = task.taskCreatedBlock;
        bytes calldata quorumNumbers = task.quorumNumbers;
        uint32 quorumThresholdPercentage = task.quorumThresholdPercentage;

        require(
            keccak256(abi.encode(task)) ==
                allTaskHashes[taskResponse.referenceTaskIndex],
            "Supplied task does not match the one recorded in the contract"
        );
        require(
            allTaskResponses[taskResponse.referenceTaskIndex] == bytes32(0),
            "Aggregator has already responded to the task"
        );
        require(
            uint32(block.number) <=
                taskCreatedBlock + TASK_RESPONSE_WINDOW_BLOCK,
            "Aggregator has responded too late"
        );

        bytes32 message = keccak256(abi.encode(taskResponse));

        (
            QuorumStakeTotals memory quorumStakeTotals,
            bytes32 hashOfNonSigners
        ) = checkSignatures(
                message,
                quorumNumbers,
                taskCreatedBlock,
                nonSignerStakesAndSignature
            );

        for (uint256 i = 0; i < quorumNumbers.length; i++) {
            require(
                quorumStakeTotals.signedStakeForQuorum[i] *
                    _THRESHOLD_DENOMINATOR >=
                    quorumStakeTotals.totalStakeForQuorum[i] *
                        uint8(quorumThresholdPercentage),
                "Signatories do not own at least threshold percentage of a quorum"
            );
        }

        TaskResponseMetadata memory taskResponseMetadata = TaskResponseMetadata(
            uint32(block.number),
            hashOfNonSigners
        );
        allTaskResponses[taskResponse.referenceTaskIndex] = keccak256(
            abi.encode(taskResponse, taskResponseMetadata)
        );

        emit TaskResponded(taskResponse, taskResponseMetadata);
    }

    /* INTERNAL FUNCTIONS */

    /// @dev Internal function to set a new task generator.
    /// @param newGenerator Address of the new generator.
    function _setGenerator(address newGenerator) internal {
        require(newGenerator != address(0), "Generator cannot be zero address");
        address oldGenerator = generator;
        generator = newGenerator;
        emit GeneratorUpdated(oldGenerator, newGenerator);
    }

    /// @dev Internal function to set a new aggregator.
    /// @param newAggregator Address of the new aggregator.
    function _setAggregator(address newAggregator) internal {
        require(
            newAggregator != address(0),
            "Aggregator cannot be zero address"
        );
        address oldAggregator = aggregator;
        aggregator = newAggregator;
        emit AggregatorUpdated(oldAggregator, newAggregator);
    }
}

// src/IRSServiceManager.sol

contract IRSServiceManager is
    ServiceManagerBase,
    TaskManager,
    Pausable,
    OperatorAllowlist
{
    enum TaskType {
        SWAP_VALIDATION,
        RATE_AND_SETTLEMENT
    }

    struct Swap {
        address owner;
        uint256 notionalAmount;
        uint256 fixedRate; // In basis points (1% = 100)
        bool isPayingFixed;
        uint256 margin;
        uint256 startTime;
        uint256 duration;
        uint256 lastSettlement;
        bool isActive;
        bool matched;
        uint256 matchedWith;
    }

    // ERRORS
    error InsufficientMargin();
    error InvalidTask();
    error PaymentFailed();

    // CONSTANTS
    uint256 public constant INITIAL_MARGIN_PERCENTAGE = 10_00; // 10%
    uint256 public constant BASIS_POINTS_DIVISOR = 10000;
    uint256 public constant SETTLEMENT_PERIOD = 30 days;

    // STATE
    mapping(uint256 => Swap) public swaps;
    uint256 public nextSwapId;

    // EVENTS
    event SwapCreated(
        uint256 indexed swapId,
        address indexed owner,
        uint256 notionalAmount,
        uint256 fixedRate,
        bool isPayingFixed,
        uint256 margin
    );

    event SwapsMatched(uint256 indexed swap1Id, uint256 indexed swap2Id);

    event SwapSettled(
        uint256 indexed swapId,
        uint256 variableRate,
        uint256 payment,
        address indexed payer,
        address indexed receiver
    );

    constructor(
        IAVSDirectory __avsDirectory,
        IRewardsCoordinator __rewardsCoordinator,
        IRegistryCoordinator __registryCoordinator,
        IStakeRegistry __stakeRegistry,
        uint32 _taskResponseWindowBlock
    )
        ServiceManagerBase(
            __avsDirectory,
            __rewardsCoordinator,
            __registryCoordinator,
            __stakeRegistry
        )
        TaskManager(__registryCoordinator, _taskResponseWindowBlock)
    {
        _disableInitializers();
    }

    function initialize(
        IPauserRegistry pauserRegistry_,
        uint256 initialPausedStatus_,
        address initialOwner_,
        address rewardsInitiator_,
        address allowlistManager_,
        address aggregator_,
        address generator_
    ) external initializer {
        _initializePauser(pauserRegistry_, initialPausedStatus_);
        __ServiceManagerBase_init(initialOwner_, rewardsInitiator_);
        __OperatorAllowlist_init(allowlistManager_, true);
        __TaskManager_init(aggregator_, generator_, initialOwner_);
    }

    function createTask(
        bytes calldata message,
        uint32 quorumThresholdPercentage,
        bytes calldata quorumNumbers
    ) external payable whenNotPaused {
        // Verify margin for swap validation tasks
        (TaskType taskType, ) = abi.decode(message, (TaskType, bytes));
        if (taskType == TaskType.SWAP_VALIDATION) {
            (, address user, uint256 notionalAmount, , , , ) = abi.decode(
                message,
                (TaskType, address, uint256, uint256, bool, uint256, uint256)
            );

            uint256 requiredMargin = (notionalAmount *
                INITIAL_MARGIN_PERCENTAGE) / BASIS_POINTS_DIVISOR;
            if (msg.value < requiredMargin) revert InsufficientMargin();
        }

        // Store task hash
        allTaskHashes[latestTaskNum] = keccak256(
            abi.encode(
                Task({
                    taskCreatedBlock: uint32(block.number),
                    quorumThresholdPercentage: quorumThresholdPercentage,
                    message: message,
                    quorumNumbers: quorumNumbers
                })
            )
        );

        _createNewTask(message, quorumThresholdPercentage, quorumNumbers);
    }

    function respondToTask(
        Task calldata task,
        TaskResponse calldata taskResponse,
        NonSignerStakesAndSignature memory nonSignerStakesAndSignature
    ) external onlyAggregator whenNotPaused {
        // Verify task matches
        if (
            keccak256(abi.encode(task)) !=
            allTaskHashes[taskResponse.referenceTaskIndex]
        ) revert InvalidTask();

        // Verify signatures and quorum
        (
            QuorumStakeTotals memory quorumStakeTotals,
            bytes32 hashOfNonSigners
        ) = checkSignatures(
                keccak256(abi.encode(taskResponse)),
                task.quorumNumbers,
                task.taskCreatedBlock,
                nonSignerStakesAndSignature
            );

        // Verify quorum threshold
        for (uint256 i = 0; i < task.quorumNumbers.length; i++) {
            if (
                quorumStakeTotals.signedStakeForQuorum[i] * 100 <
                quorumStakeTotals.totalStakeForQuorum[i] *
                    task.quorumThresholdPercentage
            ) revert("Insufficient quorum");
        }

        // Process task based on type
        (TaskType taskType, bytes memory data) = abi.decode(
            task.message,
            (TaskType, bytes)
        );

        if (taskType == TaskType.SWAP_VALIDATION) {
            processSwapValidation(data);
        } else {
            processRateAndSettlement(data);
        }

        // Store task response
        allTaskResponses[taskResponse.referenceTaskIndex] = keccak256(
            abi.encode(
                taskResponse,
                TaskResponseMetadata(uint32(block.timestamp), hashOfNonSigners)
            )
        );

        emit TaskResponded(
            taskResponse,
            TaskResponseMetadata(uint32(block.timestamp), hashOfNonSigners)
        );
    }

    function processSwapValidation(bytes memory data) internal {
        (
            address owner,
            uint256 notionalAmount,
            uint256 fixedRate,
            bool isPayingFixed,
            uint256 margin,
            uint256 duration,
            uint256 matchedWithId
        ) = abi.decode(
                data,
                (address, uint256, uint256, bool, uint256, uint256, uint256)
            );

        uint256 swapId = nextSwapId++;

        swaps[swapId] = Swap({
            owner: owner,
            notionalAmount: notionalAmount,
            fixedRate: fixedRate,
            isPayingFixed: isPayingFixed,
            margin: margin,
            startTime: block.timestamp,
            duration: duration,
            lastSettlement: block.timestamp,
            isActive: true,
            matched: matchedWithId != 0,
            matchedWith: matchedWithId
        });

        emit SwapCreated(
            swapId,
            owner,
            notionalAmount,
            fixedRate,
            isPayingFixed,
            margin
        );

        if (matchedWithId != 0) {
            Swap storage matchedSwap = swaps[matchedWithId];
            matchedSwap.matched = true;
            matchedSwap.matchedWith = swapId;

            emit SwapsMatched(swapId, matchedWithId);
        }
    }

    function processRateAndSettlement(bytes memory data) internal {
        (uint256[] memory swapsToSettle, uint256 validatedRate) = abi.decode(
            data,
            (uint256[], uint256)
        );

        for (uint256 i = 0; i < swapsToSettle.length; i++) {
            settleSwap(swapsToSettle[i], validatedRate);
        }
    }

    function settleSwap(uint256 swapId, uint256 validatedRate) internal {
        Swap storage swap = swaps[swapId];
        require(swap.isActive && swap.matched, "Invalid swap");
        require(
            block.timestamp >= swap.lastSettlement + SETTLEMENT_PERIOD,
            "Too early"
        );

        Swap storage matchedSwap = swaps[swap.matchedWith];

        uint256 timePassed = block.timestamp - swap.lastSettlement;
        uint256 payment = calculatePayment(
            swap.notionalAmount,
            validatedRate,
            swap.fixedRate,
            timePassed
        );

        // Determine payer and receiver
        (
            address payer,
            address receiver,
            Swap storage payerSwap
        ) = validatedRate > swap.fixedRate
                ? (swap.owner, matchedSwap.owner, swap)
                : (matchedSwap.owner, swap.owner, matchedSwap);

        if (payerSwap.margin < payment) revert InsufficientMargin();
        payerSwap.margin -= payment;

        (bool success, ) = payable(receiver).call{value: payment}("");
        if (!success) revert PaymentFailed();

        // Check if duration expired
        if (block.timestamp >= swap.startTime + swap.duration) {
            swap.isActive = false;
            matchedSwap.isActive = false;

            // Return remaining margins
            if (swap.margin > 0) {
                (bool s1, ) = payable(swap.owner).call{value: swap.margin}("");
                if (!s1) revert PaymentFailed();
                swap.margin = 0;
            }
            if (matchedSwap.margin > 0) {
                (bool s2, ) = payable(matchedSwap.owner).call{
                    value: matchedSwap.margin
                }("");
                if (!s2) revert PaymentFailed();
                matchedSwap.margin = 0;
            }
        } else {
            swap.lastSettlement = block.timestamp;
            matchedSwap.lastSettlement = block.timestamp;
        }

        emit SwapSettled(swapId, validatedRate, payment, payer, receiver);
    }

    function calculatePayment(
        uint256 notional,
        uint256 variableRate,
        uint256 fixedRate,
        uint256 timeElapsed
    ) internal pure returns (uint256) {
        uint256 rateDiff = variableRate > fixedRate
            ? variableRate - fixedRate
            : fixedRate - variableRate;

        return
            (notional * rateDiff * timeElapsed) /
            (365 days * BASIS_POINTS_DIVISOR);
    }

    receive() external payable {}
}
