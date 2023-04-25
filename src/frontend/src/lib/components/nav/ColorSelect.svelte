<script lang="ts">
	import { color } from "$lib/stores/tasks/colorSelect";

	//colourfull colors will use main text color as default based on dark/light mode
	let colors = [
		'bg-black text-zinc-200',
		'bg-zinc-800 text-zinc-300',
		'bg-zinc-400 text-zinc-900',
		'bg-zinc-200 text-zinc-800', 
		'bg-purple-400', 
		'bg-red-400', 
		'bg-green-400', 
		'bg-blue-400',
		'bg-cyan-400',
		'bg-yellow-400',
		'bg-orange-400',
		'bg-pink-400'
	];

	const changeColor = (c: string) => {
		color.set(c)
		console.log($color);
	}
</script>

<div class="flex flex-row gap-1 w-full justify-center">
	{#each colors as c}
		<button class="w-10 h-14 rounded-full border-main hover:border-4 {c}" on:click={() => changeColor(c)}/>
	{/each}
</div>
