import { writable } from 'svelte/store';

export const hueStore = writable<string>();
export const styleStore = writable<string>();

export async function setColor(hue: number) {
	let cssVariables = {
		'primary-color': `hsl(${hue} 100% 60%)`,
		'secondary-color': `hsl(${hue} 100% 40%)`,
		'glow-color': `hsl(${hue} 20% 30%)`
	};

	let styleValues = Object.entries(cssVariables)
		.map(([key, value]) => `--${key}:${value}`)
		.join(';');
	hueStore.set(`${hue}`);
	styleStore.set(styleValues);
}

export async function getColor() {
	const hue = localStorage.getItem('selectedHue') || '1';
	setColor(parseInt(hue));
}
