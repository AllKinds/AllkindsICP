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
				'DF-navy': '#0E031F'
			},
			fontFamily: {
				'noto-sans': ['Noto-sans', 'sans-serif'],
				roboto: ['Roboto', 'sans-serif'],
				montserrat: ['Montserrat', 'sans-serif'],
				montserratAlt: ['Montserrat Alternates', 'sans-serif']
				//todo: revamp and comment out unused
			}
		}
	},

	plugins: []
};

module.exports = config;
