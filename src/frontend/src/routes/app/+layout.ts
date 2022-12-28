import type { LayoutLoad } from './$types';
import Home from '$lib/assets/icons/home.svg?component'
import Cogwheel from '$lib/assets/icons/cogwheel.svg?component'
import Users from '$lib/assets/icons/users.svg?component'
import Dev from '$lib/assets/icons/dev.svg?component'

export const load: LayoutLoad = () => {
	return {
		sections: [
			{ slug: 'home', title: 'Home' , icon: Home },
			{ slug: 'people', title: 'People', icon: Users },
			{ slug: 'profile', title: 'Profile', icon: Cogwheel },
			{ slug: 'dev', title: 'Dev', icon: Dev }
		]
	};
};
