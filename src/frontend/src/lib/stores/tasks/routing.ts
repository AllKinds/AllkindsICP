import { writable } from 'svelte/store';
import type { RootState, RegiState } from '../types';


export const rootStore = writable<RootState>();
export const regiStore = writable<RegiState>();
