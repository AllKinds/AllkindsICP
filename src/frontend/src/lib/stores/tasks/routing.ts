import { writable } from 'svelte/store';
import type { RootState, RegiState, AppState } from '../types';


export const rootStore = writable<RootState>();
export const regiStore = writable<RegiState>();
export const appStore = writable<AppState>();