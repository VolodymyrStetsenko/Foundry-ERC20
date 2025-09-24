# Deploy Metadata

- Network: Sepolia (chainId 11155111)
- Contract: OurToken
- Address: 0x98efCe50e393315a4aC187494E6d84Bd82B811c9
- Deploy Tx: 0xd40c121715cfc1744fbdb0e3a512ba916c31b38ef51d6f9cd776a790a1a49983
- Verified: yes
- Constructor args (hex): 0x00000000000000000000000000000000000000000000d3c21bcecceda1000000

## Quick checks
```bash
cast call 0x98efCe50e393315a4aC187494E6d84Bd82B811c9 "name()(string)"             --rpc-url $SEPOLIA_RPC_URL
cast call 0x98efCe50e393315a4aC187494E6d84Bd82B811c9 "symbol()(string)"           --rpc-url $SEPOLIA_RPC_URL
cast call 0x98efCe50e393315a4aC187494E6d84Bd82B811c9 "totalSupply()(uint256)"     --rpc-url $SEPOLIA_RPC_URL
cast call 0x98efCe50e393315a4aC187494E6d84Bd82B811c9 "balanceOf(address)(uint256)" 0xF6d3a3104b75b0BD2498856C1283e7120c315AeC --rpc-url $SEPOLIA_RPC_URL
```
