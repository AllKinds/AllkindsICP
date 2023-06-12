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
- fixed app not working on safari, esbuild bug (2/05/23)

Alpha v0.2.0

- first live deploy

## Testing out locally

II included for faster local authentication testing

requires atleast DFX v0.13.1 and Motoko v0.8.5 , use [mocv](https://forum.dfinity.org/t/moc-version-management/19011)

1. dfx start --clean --background
2. clone repo and navigate into folder
3. npm install
4. dfx deploy
5. npm run dev
