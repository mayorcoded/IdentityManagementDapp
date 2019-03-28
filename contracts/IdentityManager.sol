pragma solidity 0.5.0;

contract IdentityManager {

    /*
     * Storage
     */
    struct Identity {
        address verifiedBy;
        string signature;
        bool verified;
        uint256 timestamp;
    }

    /*owner of contract*/
    address public owner;

    /*name of the institution that owns contract*/
    string public institution;

    /*mapping of digital fingerprint to an identity struct*/
    mapping(bytes32 => Identity) identities;

    /*
     * Events
     */
    event IdentityAdded(string fingerprint, string signature, uint256 timestamp);
    event IdentityRemoved(string fingerprint, bool verified);

    /*
     * Modifiers
     */

    /* check that the sender is the contract owner */
    modifier isOwner(address sender){
        require(sender == owner, "Sender must be contract owner");
        _;
    }

    /* check that an identity is verified */
    modifier isVerified(bytes32 fingerprint){
        require(identities[fingerprint].verified, "Identity must be verified");
        _;
    }

    constructor(string memory _institution) public {
        owner = msg.sender;
        institution = _institution;
    }

    function addIdentity(string memory _fingerprint, string memory _signature, bool _verified)
    public
    isOwner(msg.sender)
    {
        bytes memory encodedFingerprint = abi.encode(_fingerprint);
        require(_verified, "Identity must be verified before adding to a blockchain");
        identities[keccak256(encodedFingerprint)] = Identity({
                verifiedBy: msg.sender,
                signature: _signature,
                verified: _verified,
                timestamp: block.timestamp
            });
        emit IdentityAdded(_fingerprint, _signature, block.timestamp);
    }

    function removeIdentity(string memory _fingerprint)
    public
    isOwner(msg.sender)
    {
        bytes memory encodedFingerprint = abi.encode(_fingerprint);
        delete identities[keccak256(encodedFingerprint)];
        emit IdentityRemoved(_fingerprint, identities[keccak256(encodedFingerprint)].verified);
    }

    function getIdentity(string memory _fingerprint)
    isVerified(keccak256(abi.encode(_fingerprint)))
    public
    view
    returns (address verifiedBy, string memory signature, bool verified, string memory fingerprint, uint256 timestamp) {
        bytes memory encodedFingerprint = abi.encode(_fingerprint);
        verifiedBy = identities[keccak256(encodedFingerprint)].verifiedBy;
        signature = identities[keccak256(encodedFingerprint)].signature;
        verified = identities[keccak256(encodedFingerprint)].verified;
        timestamp = identities[keccak256(encodedFingerprint)].timestamp;

        return (verifiedBy, signature, verified, _fingerprint , timestamp);
    }

    function removeContract()
    public
    isOwner(msg.sender)
    {
        selfdestruct(msg.sender);
    }
}
