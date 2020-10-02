# freebet
A decentralized ethereum-based coinflip app

# WARNING
This app has been developed for educational purposes only.
In its current status it almost certainly contains underflow/overflow vulnerabilities and other bugs.
Currently it is not secure for use on mainnet. (Much more testing and an implementation of SafeMath would be necessary.)

# Description

## Betting vs. a liquidity pool
We have implemented a liquidity system, where providers can deposit/withdraw ethereum to the contract.
Over time, they will earn money through fees. However, in the short term they also might lose money, if the players get lucky and win a disproportionally large amount of their bets (by chance). In the long run these fluctuations should cancel out.

## Source of randomness
As is well-known, randomness is problematic on any blockchain system. In particular the use of block-header information (like blockhashes or timestamps) usually leads to severe security problems and allows for miner manipulation. We propose a (to our knowledge) novel solution to this problem.

The main idea is to use a FUTURE blockhash (at a fixed block height relative to the placement of the bet) together with the players address. In combination with a maximum bet amount and the rule that each address can only place one bet at a time, this construction makes miner manipulation infeasible.

Note that this system needs to have access to the blockhash of the block following the block where the bet was placed. Since this is only possible for the 256 last blocks, older bets will automatically be counted as lost, if the player didnt claim his win until then.

# Contract address
The current version of this contract is deployed at the address 0xB04D24fac12D10e29bEe4dbD135A6C4BBE080487 on the kovan test network.
In order to test the contract using the interface in this repository you can start a local http server (e.g., using python3, by "python -m http.server" in the root directory of this repository). Then connect to it (usually http://127.0.0.1:8000) in your browser and connect your metamask using kovan testnet.
