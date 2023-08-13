# Welcome to Optimus
We created the Optimus project to provide a foundation on which cross chain holdings can be efficiently traded using a combination of NFTs, TokenBoundAccounts and Optimals. Our vision is to be able to trade NFTs in DeFi on local and foreign chains WITHOUT having to bridge underlying assets. The idea is that only the NFT needs to be bridged with a reference to it's associated Attestation provided by the Ethereum Attestation Service (EAS). 

This enables the DeFi protocol on the foreign chain to verify the baseline contents of the NFT's Token Bound Account via EAS on the home chain. This makes capital bridging more efficient and secure as underlying assets do not move. The analogy is that of the international settlements system where cash and commodities like gold are traded virtually between countries with only periodic physical settlement i.e. where cash or gold is shipped to another geography. Optimus provides the necessary "virtual" infrastructure on Optimism for onward bridging. 

Optimus leverages EIP6551 for Token Bound Accounts. 

# Model
The architecture for Optimus is described in the diagram below: 
![enter image description here](https://github.com/cryptotwilight/optimuss/blob/main/media/optimus-model.png?raw=true)
<br/>
- **1** **Token Bound Account** - This enables the NFT to hold assets such as ERC20 tokens
- **2** **Optimal** - The Optimal provides a fixed subset of assets owned by the Token Bound Account. The configuration of these assets are used to generate a fixed attestation. If the configuration of the Optimal changes then the attestation also changes
- **3** **EAS** - This provides the registry services for attestations on the home chain. Typically DeFi protocols on foreign chains will verify presented attestations with the Home chain EAS deployment
- **4** **Optimus Attestation** - This is the fixed configuration of the optimal that is changed whenever the Optimal changes
- **5** **Optimus Asset** - This is an asset held by the Token Bound Account that is added to the Optimal
- **6** **NFT** - The NFT is fully tradeable and does not lose any of it's functionality as a result of TBA and Optimal addition


# Deployments 
|Chain | Contract | Address |Description |
|------|-----------|--------|------------|
|Optimism Goerli |OptimusEASSchemaResolver|0x102081CB2C65233A12BF3060cffEc8a9861C0Eff|This is used by EAS to resolve the Optimus Attestation Schema|
|Optimism Goerli |Test ERC721|0x75F239B434F4Fc37ED53C8160C670110727CB564|This is the NFT contract used to test Optimus|
|Optimism Goerli |OptimusERC6551Plant||This is used to create Token Bound Account and Optimal implementations |
|Optimism Goerli |OptimusTokenBoundAccountFactory|0xBe385590107441E6073ec4435D6C521BB91618C1|This is the factory for Token Bound Accounts (only callable by the plant)|
|Optimism Goerli |ERC6551Registry|0x4E8312378f6E51DE765A79e45dd65906c27ae622|This is the registry for token bound accounts |
|||

## Links
|Item | Link | 
|------|-----|
|Optimus Attestation Page |[UID:0x557d1add7ee9c61d2d0f2e5c715e7f459857afd214c4494f100e613738e19193](https://optimism-goerli-bedrock.easscan.org/schema/view/0x557d1add7ee9c61d2d0f2e5c715e7f459857afd214c4494f100e613738e19193) |
|Optimus UI | | 


