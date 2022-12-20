import type { LayoutLoad } from './$types';
import Home from '$lib/assets/icons/home.svg?component';

export const load: LayoutLoad = () => {
	return {
		sections: [
			{ slug: 'home', title: 'Home' , icon: Home},
			{ slug: 'people', title: 'People' },
			{ slug: 'profile', title: 'Profile' },
			{ slug: 'dev', title: 'Dev' }
		]
	};
};
