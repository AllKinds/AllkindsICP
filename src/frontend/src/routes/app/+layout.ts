import Cogwheel from '$lib/assets/icons/cogwheel.svg?component';
import Dev from '$lib/assets/icons/dev.svg?component';
import Home from '$lib/assets/icons/home.svg?component';
import Users from '$lib/assets/icons/users.svg?component';
import User from '$lib/assets/icons/user.svg?component';
import type { LayoutLoad } from './$types';

export const load: LayoutLoad = () => {
	return {
		sections: [
			{ slug: 'home', title: 'Home', icon: Home },
			{ slug: 'people', title: 'People', icon: Users },
			{ slug: 'user', title: 'Me', icon: User },
			{ slug: 'profile', title: 'Settings', icon: Cogwheel },
			{ slug: 'dev', title: 'Dev', icon: Dev }
		]
	};
};
