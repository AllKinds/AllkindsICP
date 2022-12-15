import type { Gender } from 'src/declarations/backend/backend.did';

export const toNullable = <T>(value?: T): [] | [T] => {
  return value ? [value] : [];
}

export const fromNullable = <T>(value: [] | [T]): T | undefined => {
  return value?.[0];
}

export function fromBigInt(utc: bigint) { 
		utc /= BigInt(1000000)
     return new Date(Number(utc)).toISOString(). slice(0,10) 
 }

export function toBigInt(date: string) {  
  return BigInt(Number(new Date(date)) * 1000000)
}

export const toNullableDate = (value?: string): [] | [bigint] => {
  return value && !isNaN(parseInt(`${value?.[0]}`)) ? [toBigInt(value)] : [];
};

export const fromNullableDate = (value?: [] | [bigint]): string | undefined => {
  const m = !isNaN(parseInt(`${value?.[0]}`)) ? value?.[0] : undefined;
	return m !== undefined ? fromBigInt(m) : m
}; 	

export const toNullableGender = (value?: string ): [] | [Gender] => {
	return value && value !== undefined ? [<Gender>{[value] : null}] : []
};	

export const fromNullableGender = (value?: [] | [Gender]): string | undefined => {
  const m = value !== undefined ? value?.[0] : undefined;
	return m !== undefined ? Object.entries(m)[0][0] : m
}; 	