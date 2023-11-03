import { BackendError } from "./backend"

export type ErrorTags = "backend" | "network"
export type FrontendError = { tag: "backend", err: BackendError }
    | { tag: "network", err: string }
    | { tag: "notLoggedIn" } 
