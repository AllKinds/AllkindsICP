import { stringify } from 'postcss';
import type { Gender } from 'src/declarations/backend/backend.did';

export const toNullable = <T>(value?: T): [] | [T] => {
    return value ? [value] : [];
};

export const fromNullable = <T>(value: [] | [T]): T | undefined => {
    return value?.[0];
};

export function fromBigInt(utc: bigint): string {
    utc /= BigInt(1000000);
    return new Date(Number(utc)).toISOString().slice(0, 10);
}

export function toBigInt(date: string): bigint {
    return BigInt(Number(new Date(date)) * 1000000);
}

export const toNullableDate = (value?: string): [] | [bigint] => {
    return value && !isNaN(parseInt(`${value?.[0]}`)) ? [toBigInt(value)] : [];
};

export const fromNullableDate = (value?: [] | [bigint]): string | undefined => {
    const m = !isNaN(parseInt(`${value?.[0]}`)) ? value?.[0] : undefined;
    return m !== undefined ? fromBigInt(m) : m;
};

export const toNullableGender = (value?: string): [] | [Gender] => {
    return value && value !== undefined ? [<Gender>{ [value]: null }] : [];
};

export const fromNullableGender = (value?: [] | [Gender]): string | undefined => {
    const m = value !== undefined ? value?.[0] : undefined;
    return m !== undefined ? Object.entries(m)[0][0] : m;
};

export const capitalize = (word: string): string => {
    if (word == "") return "";
    return word.charAt(0).toUpperCase() + word.slice(1);
}

// export const convertImageToUInt8Array = async (file: any): Promise<Uint8Array> => {
// 	//not working properly yet
// 	return new Promise<Uint8Array>((resolve, reject) => {
// 		const reader = new FileReader();
// 		reader.onload = () => {
// 			if (reader.result instanceof ArrayBuffer) {
// 				const uint8Array = new Uint8Array(reader.result);
// 				resolve(uint8Array);
// 			} else {
// 				reject(new Error('Unable to convert file to UInt8Array'));
// 			}
// 		};
// 		reader.onerror = () => {
// 			reject(reader.error);
// 		};
// 		reader.readAsArrayBuffer(file);
// 	});
// };
