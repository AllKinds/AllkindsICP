# Allkinds

## Introduction
Allkinds is a social network.
On Allkinds people connect by anonymously asking and answering each other yes/no questions about what ever they consider important. Then people can discover those whose answers resonate the most and connect. Once connected people can compare their answers thus learning a lot about each other.

Essentially people connect upon values expressed by themselves through questions in a private manner.

Within this iteration of the project we've launched the MVP where individuals can discover like-minded people within groups. Please check it here: [allkinds.xyz](https://allkinds.xyz)



## Problem

Despite the presence of numerous solutions in the market, the issue of loneliness is worsening. Having a Facebook 'friend' does not equate to having a genuine friend, and Tinder-like matches often fail to lead to sustainable relationships.
People spend too much time on social media and dating services, yet they only establish shallow connections. As a result, approximately 60% of the global population considers themselves either lonely, left out, or lacking meaningful relationships.

## Solution

Allkinds is a web3 network and a protocol that allows individuals to discover like-minded people around and create meaningful relationships.

Allkinds implemented as a webapp on the [Internet Computer](https://internetcomputer.org) platform.

The interface of Allkinds is straightforward. People connect through the following algorithm:
Anonymously ask yes/no questions on topics they consider important.
Answer not only their own questions but also questions from others, indicating the importance of each question.
Allkinds calculates the cohesion score between any users (accounts) as a percentage of shared answers to the same questions, weighted by the importance indicated by each person.
This way, people can discover those who resonate more (or less) and connect.

## Local deployment for testing

II included for faster local authentication testing

requires at least DFX v0.17.0 and the [mops](https://mops.one/docs/install) packet manager.

### Initial setup

```bash
# install dfx, mops and mocv
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
npm i -g ic-mops

# enable mops toolchain
mops toolchain init
. ~/.bashrc # or restart your terminal

# get the code
git clone https://github.com/AllKinds/AllkindsICP
```

### Start dev environment

```bash
# start local testnet
dfx start --background # add --clean to start over

# load frontend dependencies
cd AllkindsICP
npm install

# deploy the canister locally
dfx deploy
```

You can also run the local dev server or generate some test data:

```bash
# create a team
dfx canister call backend createTeam '("sandbox", "testcode", record {about="Temporary test data"; logo=vec {}; name="Test data"; listed=false})'
dfx canister call backend joinTeam '("sandbox", "testcode")'
# create 20 questions and 30 users
dfx canister call backend createTestData '("sandbox", 20, 30)'


# run local server for frontend development
npm run dev
```

To create teams through the frontend navigating to `/create-team`.
You need explicit permissions to access this function.
Permissions can be granted by a controller of the canister:

```bash
# replace my-username with your actual user name
dfx canister call backend setPermissions '("my-username", record {becomeTeamMember=true; createTeam=true; createBackup=true; listAllTeams=true; suspendUser=true; editUser=true; 
restoreBackup=true; becomeTeamAdmin=true})'
```

## Maintenance

```bash
# check cycle balance
dfx canister status --network ic backend
dfx canister status --network ic frontend

# top up cycle balance
dfx canister deposit-cycles 1000000000 backend --network ic
dfx canister deposit-cycles 1000000000 frontend --network ic
```

## License

Allkinds project is licensed under the AGPL license.

## References

- [Internet Computer](https://internetcomputer.org)
- [Allkinds landing page](https://allkinds.xyz)
- [Allkinds Lite paper](https://allkinds.xyz/Allkinds_litepaper.pdf)

## Roadmap
- [x] $5K Dfinity grant approved, November 2023
- [x] The First milestone of the current grant completed, January 2024
- [x] Allkinds MVP pilot launched with a private sturtup, January 2024
- [x] Allkinds MVP launched within a few communities, January
- [ ] Final Demo milestone of the current grant completed, February 2024
- [ ] Application for the follow up grant sent
- [ ] Development of the next iteration of the project started
  - [ ] Extend core team to 5-6 people, develop mobile apps adding these features:
  - [ ] Messenger, notifications
  - [ ] Wallet
  - [ ] Geolocation features
  - [ ] Invitation system
  - [ ] Fully working tokenomics
  - [ ] Proposals
  - [ ] SNS ready
- [ ] Launch and promote Allkinds Season #1 through personal invites from the core team - June, 2024
- [ ] Launch Allkinds Season #2 publicly with SNS - December, 2024
- [ ] Launch Allkinds protocol - 2025

## Acknowledgements

- Martin (<https://github.com/f0i>)
- Denny (<https://github.com/dennyweiss>)
- Wannes (<https://github.com/wannesds>)
- Samer (<https://github.com/Web3NL>)
