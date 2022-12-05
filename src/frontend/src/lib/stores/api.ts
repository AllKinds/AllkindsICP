import { actor } from '$lib/stores/auth';
import { get } from 'svelte/store';

//1) Maybe we create and import a convertor function to change values based on the service/their type
//that way we keep the convertions in one place.
//2) Type safety with Zod could be put in the functions that call for api and connect to html

export async function apiCall({ service, value }) {
	const Actor = get(actor);
	let result: any; //should be of promise type I think
	switch (service) {
		case 'updateProfile': {
			//first convertor function to change the value?
			result = await Actor.updateProfile(value);
			break;
		}
		case 'getUser': {
			//first convertor function to change the value?
			result = await Actor.getUser(value);
			break;
		}
	}

	return result;
}

//////TEMPORARY JS <-> CANDID FROM TYPESCRIPT UTILITIES POST//////

//NULABLE CONVERT
// export const toNullable = <T>(value?: T): [] | [T] => {
//   return value ? [value] : [];
// };

// export const fromNullable = <T>(value: [] | [T]): T | undefined => {
//   return value?.[0];
// };

//EXAMPLE FOR DATETIME
// export const fromTimestamp = (value: Time): Date => {
//   return new Date(Number(value) / (1000 * 1000));
// };

//EXAMPLE FOR VALUES WITH OPTIONAL NULL

// export const toNullableTimestamp = (value?: Date): [] | [Time] => {
//   const time: number | undefined = value?.getTime();
//   return value && !isNaN(time) ? [toTimestamp(value)] : [];
// };
// export const fromNullableTimestamp =
//        (value?: [] | [Time]): Date | undefined => {
//   return !isNaN(parseInt(`${value?.[0]}`)) ?
//             fromTimestamp(value[0]) : undefined;
// };
