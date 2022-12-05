import { writable } from 'svelte/store';

export enum RootState {
	Landing,
	Register,
	App
}
export const rootStore = writable<RootState>();

export enum RegiState {
	Username,
	Profile,
	Finished
}
export const regiStore = writable<RegiState>();
