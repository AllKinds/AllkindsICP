<script>
	import Logo from './Logo.svelte';
	import IcBadge from '$lib/assets/images/ic-badge.svg?component';
	import { goto } from '$app/navigation';
</script>

<div class="border-t-[1px] border-zinc-700 m-2 flex flex-col pb-10 p-4 gap-3">
	<button class="logo" on:click={() => goto("/landing")} >Allkinds</button>
	<div class="text-sub">
		<a href="https://twitter.com/Allkinds12">Twitter</a> |
		<a href="https://discord.gg/kXAYeYWR5E">Discord</a> |
		<a href="https://github.com/AllKinds">Github</a>
	</div>
	<IcBadge />
	<snap class="text-sub">© 2023 Allkinds. All rights reserved.</snap>
</div>
