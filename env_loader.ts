import fs from "fs";
import dfxJson from "./dfx.json";
import join from "path";
import { frontend } from "./src/declarations/frontend";

const network = process.env["DFX_NETWORK"] ?? "local";
const isDev = network !== "ic";
const isStaging = network === "staging";

const APP_NAME = "Allkinds";
const LOGO_URL = "https://allkinds.xyz/img/allkinds_logo_white.svg"

type Network = "ic" | "local" | "staging";

const cansisterIdFile = isDev ? "./.dfx/" + network + "/canister_ids.json" : "./canister_ids.json";

const canisterIds = JSON.parse(fs.readFileSync(cansisterIdFile).toString());

const ids = {
    frontend: canisterIds.frontend[network],
    backend: canisterIds.backend[network],
    ii: canisterIds.internet_identity[network],
}

const II_URL = isDev ? "http://" + ids.ii + ".localhost:4943" : "https://identity.ic0.app";
const NFID_URL = isDev ? II_URL : ("https://nfid.one" +
    "/authenticate/?applicationName=" +
    APP_NAME +
    "&applicationLogo=" +
    LOGO_URL +
    "#authorize"
);

export function dfx_env() {
    return {
        network, isDev, isStaging,
        II_URL, NFID_URL,
        canisterIds: ids,
    }
}
