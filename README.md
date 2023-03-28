## Allkinds

## Test out

Decided to use nns for II in testing authentication. No wallet support build in yet.
If using your own II canister don't forget to change canisterID in stores/tasks/auth.ts (at the bottom).

branches: 
  Master > required DFX v0.13.1 (recommend Node v18, seems stable)
  Dev > requires moc 0.8.3 (check mocv cli)

1. dfx start --clean --background
2. dfx nns install
3. clone repo and navigate into folder
4. npm install
5. dfx deploy
6. npm run dev
