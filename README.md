# Welcome to Optimus
We created the Optimus project to provide a foundation on which cross chain holdings can be efficiently traded using a combination of NFTs, TokenBoundAccounts and Optimals. Our vision is to be able to trade NFTs in DeFi on local and foreign chains WITHOUT having to bridge underlying assets. The idea is that only the NFT needs to be bridged with a reference to it's associated Attestation provided by the Ethereum Attestation Service (EAS). 

This enables the DeFi protocol on the foreign chain to verify the baseline contents of the NFT's Token Bound Account via EAS on the home chain. This makes capital bridging more efficient and secure as underlying assets do not move. The analogy is that of the international settlements system where cash and commodities like gold are traded virtually between countries with only periodic physical settlement i.e. where cash or gold is shipped to another geography. Optimus provides the necessary "virtual" infrastructure on Optimism for onward bridging. 

Optimus leverages EIP6551 for Token Bound Accounts. 

# Model
The architecture for Optimus is described in the diagram below: 
![enter image description here](https://github.com/cryptotwilight/optimuss/blob/main/media/optimus-model.png?raw=true)
1 **Token Bound Account** - This enables the NFT to hold assets such as ERC20 tokens
2 **Optimal** - The Optimal provides a fixed subset of assets owned by the Token Bound Account. The configuration of these assets are used to generate a fixed attestation. If the configuration of the Optimal changes then the attestation also changes
3 **EAS** - This provides the registry services for attestations on the home chain. Typically DeFi protocols on foreign chains will verify presented attestations with the Home chain EAS deployment
4 **Optimus Attestation** - This is the fixed configuration of the optimal that is changed whenever the Optimal changes
5 **Optimus Asset** - This is an asset held by the Token Bound Account that is added to the Optimal
6 **NFT** - The NFT is fully tradeable and does not lose any of it's functionality as a result of TBA and Optimal addition


# Deployments 
|Chain | Contract | Address |Description |
|------|-----------|--------|------------|
|Optimism Goerli |OptimusEASSchemaResolver||This is used by EAS to resolve the Optimus Attestation Schema|
|Optimism Goerli |Test ERC721||This is the NFT contract used to test Optimus|
|Optimism Goerli |OptimusERC6551Plant||This is used to create Token Bound Account and Optimal implementations |
|Optimism Goerli |OptimusTokenBoundAccountFactory||This is the factory for Token Bound Accounts (only callable by the plant)|
|Optimism Goerli |ERC6551Registry||This is the registry for token bound accounts |
|||

## Links
|Item | Link | 
|------|-----|
|Optimus Attestation Page | |
|Optimus UI | | 