import type { LayoutLoad } from './$types';

export const load: LayoutLoad = () => {
	return {
		sections: [
			{ slug: 'home', title: 'Home' },
			{ slug: 'people', title: 'People' },
			{ slug: 'profile', title: 'Profile' },
			{ slug: 'dev', title: 'Dev'}
		]
	};
};
