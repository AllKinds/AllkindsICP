import fs from "fs";

const network = process.env["DFX_NETWORK"] ?? "local";
const isDev = network !== "ic";
const isStaging = network === "staging";

const APP_NAME = "Allkinds";
const LOGO_URL = "https://allkinds.xyz/img/allkinds_logo_white.svg"

type Network = "ic" | "local" | "staging";

const canisterIdFile = isDev ? "./.dfx/" + network + "/canister_ids.json" : "./canister_ids.json";
if (isDev) {
    console.warn("Building in dev mode");
}

let canisterIds = { frontend: {}, backend: {}, internet_identity: {} } as any
if (fs.existsSync(canisterIdFile)) {
    canisterIds = JSON.parse(fs.readFileSync(canisterIdFile).toString());
} else {
    console.warn("Canister ID file does not exist:", canisterIdFile);
};

const ids = {
    frontend: (canisterIds.frontend || {})[network],
    backend: (canisterIds.backend || {})[network],
    ii: isDev ? (canisterIds.internet_identity || {})[network] : undefined,
}

const II_URL = isDev ? "http://" + ids.ii + ".localhost:4943" : "https://identity.ic0.app";

const NFID_URL = isDev ? II_URL : ("https://nfid.one" +
    "/authenticate/?applicationName=" +
    APP_NAME +
    "&applicationLogo=" +
    LOGO_URL +
    "#authorize"
);
const FRONTEND_URL = isDev ? "http://" + ids.frontend + ".localhost:4943"
    : "https://" + ids.frontend + ".icp0.io";

const host = isDev ? "http://localhost:4943" : "https://icp-api.io";

export function dfx_env() {
    return {
        network, isDev, isStaging,
        II_URL, NFID_URL,
        FRONTEND_URL,
        canisterIds: ids,
        host,
    }
}

console.log("dfx_env:", dfx_env());
