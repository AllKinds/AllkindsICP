import moment from "moment";


export const toDataUrl = (image: number[] | Uint8Array, mode: "team" | "user" = "team", name: string = "") => {
    if (!image || image.length < 10) {
        // Image not set, return a white circle as placeholder
        if (mode === "team")
            return circlesDataUrl("808", "080");
        else
            return circleDataUrl("880");
    }
    const blob = new Blob([image as BlobPart], { type: 'image/png' })
    return URL.createObjectURL(blob);
};

export const circlesDataUrl = (c1: string, c2: string) => {
    return "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 20 20'" +
        "%3E%3Ccircle cx='5' cy='10' r='5' fill='%23" + c1 + "'/" +
        "%3E%3Ccircle cx='15' cy='10' r='5' fill='%23" + c2 + "'/" +
        "%3E%3C/svg%3E"
}

export const circleDataUrl = (c: string) => {
    return "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 10 10'" +
        "%3E%3Ccircle cx='5' cy='5' r='5' fill='%23" + c + "'/%3E%3C/svg%3E"
}


export const formatDate = (date: bigint) => {
    const now = moment();
    const time = moment(Number(date / 1000000n));
    if (now.isBefore(time)) {
        return "now";
    }
    return time.fromNow();
}

