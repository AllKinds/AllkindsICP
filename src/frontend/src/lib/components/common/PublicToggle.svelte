<script lang="ts">
	import Eye from '$lib/assets/icons/eye.svg?component';
	import EyeSlash from '$lib/assets/icons/eye-slash.svg?component';

	export let checked: boolean;
	// const onChange = () => {
	//   checked = !checked
	//   console.log('onchange checked:', checked)
	// }
	$: {
		console.log('checked:', checked);
	}
</script>

<span class="toggle">
	<label title="Public viewable" class="p-0.5">
		<input type="checkbox" bind:checked />
		{checked ? <Eye /> : <EyeSlash />}
	</label>
</span>

<style style lang="postcss">
	.toggle input[type='checkbox'] {
		display: none;
	}
	.toggle label {
		@apply inline-block cursor-pointer transition-all ease-in-out duration-300 w-8 h-auto rounded-3xl bg-transparent hover:text-slate-400;
	}
</style>
