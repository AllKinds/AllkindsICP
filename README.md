# Allkinds

Allkinds allows individuals to find like-minded people or organizations in a very precise and private manner. This happens in a very natural way - by asking questions about what people consider important and answering questions from other people. Allkinds then calculates the cohesion score by the number of the same questions weighted on the importance of every question for each user.

You can try our MVP here: <https://xroyo-niaaa-aaaal-act6a-cai.icp0.io/>

## Introduction

### Problem

Despite the presence of numerous solutions in the market, the issue of loneliness is worsening. Having a Facebook 'friend' does not equate to having a genuine friend, and Tinder-like matches often fail to lead to sustainable relationships.
People spend too much time on social media and dating services, yet they only establish shallow connections. As a result, approximately 60% of the global population considers themselves either lonely, left out, or lacking meaningful relationships.

### Solution

Allkinds is a web3 protocol that empowers individuals and organizations to create comprehensive meta profiles encompassing their values, traits, interests, and more. By comparing these meta profiles with others, Allkinds enables users to discover precisely aligned like-minded individuals or organizations.

## Local deployment for testing

II included for faster local authentication testing

requires at least DFX v0.15.2, Motoko v0.10.2 (use [mocv](https://forum.dfinity.org/t/moc-version-management/19011)) and the [mops](https://mops.one/docs/install) packet manager.

```bash
# install dfx, mops and mocv
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
npm i -g ic-mops
npm i -g mocv

# set compiler version
mocv use 0.10.2

# start local testnet
dfx start --clean --background

# get the code
git clone https://github.com/AllKinds/AllkindsICP && cd AllkindsICP
npm install
# deploy the canister locally
dfx deploy
```

You can also run the local dev server or generate some test data:

```bash
# create a team
dfx canister call backend createTeam '("sandbox", "test-invite-code", record {about="Temporary test data"; logo=vec {}; name="Test data"; listed=false})'
dfx canister call backend joinTeam '("sandbox", "test-invite-code")'
# create 20 questions and 30 users
dfx canister call backend createTestData '("sandbox", 20, 30)'


# run local server for frontend development
npm run dev
```

To create teams through the frontend navigating to `/create-team`.
Currently this requires your principal to be a controller of the backend canister.

```bash
# replace xxxxx... with your principal (shown on /create-team)
dfx canister update-settings --add-controller xxxxx-xxxxx-xxxxx-xxxxx-xxxxx-xxx backend
```


## License

Allkinds project is licensed under the AGPL license.

## References

- [Internet Computer](https://internetcomputer.org)
- [Allkinds landing page](https://allkinds.xyz)
- [Allkinds Lite paper](https://allkinds.xyz/Allkinds_litepaper.pdf)

## Roadmap

- [x] Landing page
- [x] Fully working MVP (II&NFID auth, question/answers, basic cohesion algorithm) built on the ICP
- [ ] Redesign
- [ ] Share my profile/invite features
- [ ] NLP/AI functionality (recommendation system for question, cohesion on categories, etc.)
- [ ] Geo-location services
- [ ] Organization accounts
- [ ] Built-in/integrated messenger
- [ ] DAO&Protocol functionality

## Acknowledgements

- Martin (<https://github.com/f0i>)
- Denny (<https://github.com/dennyweiss>)
- Wannes (<https://github.com/wannesds>)
- Samer (<https://github.com/Web3NL>)
