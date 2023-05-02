# Allkinds

[Mainnet deployed Dapp](https://tp4bo-yaaaa-aaaap-aa5la-cai.icp0.io/)
Have fun testing ^^ , Don't overconsume cycles pls

## Releases

Alpha v0.2.1 (1/05/23) (BREAKING CHANGE: ONLY questions have been reset)

- Reverted UI colors back and removed custom accent slider
- Added color selection instead of slider for questions
- Removed footer from /app sections
- Extracted some reuasble components , finetuned & optimized code
- Added userCard toggle on userbanners at friendlist
- Fixed slider issues at matchingFilter
- Fixed age bug when birth was not set
- Several smaller bug fixes/UI tweaks
- + fixed app not working on safari, esbuild bug (2/05/23)

Alpha v0.2.0

- first live deploy

## Testing out locally

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
