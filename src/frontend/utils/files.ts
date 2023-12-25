
export const toDataUrl = (image: number[] | Uint8Array) => {
    if (image.length < 10) {
        // Image not set, return a white circle as placeholder
        //return "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 10 10'%3E%3Ccircle cx='5' cy='5' r='5' fill='%23ffffff'/%3E%3C/svg%3E"
        //return "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 20 20'%3E%3Ccircle cx='5' cy='10' r='5' fill='%23000000'/%3E%3Ccircle cx='15' cy='10' r='5' fill='%23000000'/%3E%3C/svg%3E"
        //return "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 20 20'%3E%3Ccircle cx='5' cy='10' r='5' fill='%23ffffff'/%3E%3Ccircle cx='15' cy='10' r='5' fill='%23ffffff'/%3E%3C/svg%3E"
        return circlesDataUrl("808", "080");
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
