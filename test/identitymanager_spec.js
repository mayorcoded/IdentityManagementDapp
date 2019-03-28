const IdentityManager = require("Embark/contracts/IdentityManager");
let accounts = [];

config({
    contracts: {
        IdentityManager: {
            args: ["National Youth Service Corps"]
        }
    }
},(err, _accounts) => {
    accounts = _accounts
});

const expectedInstitution = "National Youth Service Corps";
const fingerprint = "jrjaaenfaljf097809";
const signature = "094u3nr29r3hr";

contract('IdentityManager', () => {

    it("Should work", () => {
        assert.ok(true);
    });

    it("Contracts should be owner by first account", async () => {
        const owner = await IdentityManager.methods.owner().call();
        const expectedOwner = accounts[0];
        assert.equal(owner, expectedOwner)
    });

    it("Should be defined institution", async () => {
        const institution = await IdentityManager.methods.institution().call();
        assert.equal(institution, expectedInstitution)
    });

    it("Should be able to add identity and verify its content via contract event", async () => {
        const identity = await IdentityManager.methods.addIdentity(fingerprint, signature, true).send();
        const addIdentityEvent =  identity.events.IdentityAdded;
        assert.equal(fingerprint, addIdentityEvent.returnValues.fingerprint);
        assert.equal(signature, addIdentityEvent.returnValues.signature);
    });

    it("Should not be able to add unverified identity", async () => {
        try {
            await IdentityManager.methods.addIdentity(fingerprint, signature, false).send();
        }catch (error) {
            assert.ok(error.toString().includes("revert"))
        }
    });

    it("Should be able to get a verified identity", async () => {
        await IdentityManager.methods.addIdentity(fingerprint, signature, true).send();
        const identity = await IdentityManager.methods.getIdentity(fingerprint).call();
        assert.equal(accounts[0], identity.verifiedBy);
        assert.equal(fingerprint, identity.fingerprint);
        assert.equal(signature, identity.signature);
        assert.ok(identity.verified)
    });

    it("should remove a verified identity form the blockchain and verify with contract event", async () => {
        await IdentityManager.methods.addIdentity(fingerprint, signature, true).send();
        const removeIdentity = await IdentityManager.methods.removeIdentity(fingerprint).send();
        const removeIdentityEvent = removeIdentity.events.IdentityRemoved;
        assert.equal(false,removeIdentityEvent.returnValues.verified);
    });

    it("should throw error when trying to get an identity that has been removed", async () => {

        try {
            await IdentityManager.methods.addIdentity(fingerprint, signature, true).send();
            await IdentityManager.methods.removeIdentity(fingerprint).send();
            await IdentityManager.methods.getIdentity(fingerprint).call();
        }catch (error) {
            assert.ok(error.toString().includes("revert"))
        }
    });

});