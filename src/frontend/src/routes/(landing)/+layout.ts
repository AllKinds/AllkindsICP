import type { LayoutLoad } from './$types';

export const load: LayoutLoad = () => {
	return {
		sections: [
			{ slug: 'about', title: 'About' },
			{ slug: 'roadmap', title: 'Roadmap' },
			{ slug: 'whitepaper', title: 'Whitepaper' },
			{ slug: 'team', title: 'Team' },
			{ slug: 'contact', title: 'Contact' }
		]
	};
};
