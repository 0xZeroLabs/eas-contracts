// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { SchemaResolver } from "../../SchemaResolver.sol";
import { IEAS, Attestation } from "../../IEAS.sol";

/**
 * @title A sample schema resolver that checks whether an attestations attest to an existing attestation.
 */
contract TestAttestationResolver is SchemaResolver {
    error Overflow();
    error OutOfBounds();

    constructor(IEAS eas) SchemaResolver(eas) {}

    function onAttest(Attestation calldata attestation) internal virtual override returns (bool) {
        return _eas.isAttestationValid(_toBytes32(attestation.data, 0));
    }

    function onRevoke(
        Attestation calldata /*attestation*/
    ) internal virtual override returns (bool) {
        return true;
    }

    function _toBytes32(bytes memory data, uint256 start) private pure returns (bytes32) {
        unchecked {
            if (start + 32 < start) {
                revert Overflow();
            }

            if (data.length < start + 32) {
                revert OutOfBounds();
            }
        }

        bytes32 tempBytes32;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            tempBytes32 := mload(add(add(data, 0x20), start))
        }

        return tempBytes32;
    }
}
