
export const toDataUrl = (image: Uint8Array) => {
    const blob = new Blob([image], { type: 'image/png' })
    return URL.createObjectURL(blob);
};