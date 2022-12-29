import { writable } from 'svelte/store';
import type { AppState, RegiState, RootState } from '../types';

export const rootStore = writable<RootState>();
export const regiStore = writable<RegiState>();
export const appStore = writable<AppState>();
