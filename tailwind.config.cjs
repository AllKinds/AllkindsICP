const config = {
	content: ['./src/**/*.{html,js,svelte,ts}'],
	darkMode: 'class',
	theme: {
		extend: {
			colors: {
				'DF-blue': '#29ABE2',
				'DF-red': '#ED1E79',
				'DF-purple': '#522785',
				'DF-yellow': '#FBB03B',
				'DF-orange': '#F15A24',
				'DF-navy': '#0E031F',
				accent: 'emerald-500'
			},
			fontFamily: {
				Poppins: ['Poppins']
			}
		}
	},

	plugins: []
};



module.exports = config;
