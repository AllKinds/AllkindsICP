# Allkinds

Alpha v0.2
[Test live!](https://tp4bo-yaaaa-aaaap-aa5la-cai.icp0.io/), Don't overconsume cycles pls

## Test out

Decided to use nns for II in testing authentication. No wallet support build in yet.
If using your own II canister don't forget to change canisterID in stores/tasks/auth.ts (at the bottom).
check notes.md for more info

requires DFX v0.13.1 and Motoko v0.8.5 , use [mocv](https://forum.dfinity.org/t/moc-version-management/19011)

1. dfx start --clean --background
2. dfx nns install
3. clone repo and navigate into folder
4. npm install
5. dfx deploy
6. npm run dev
