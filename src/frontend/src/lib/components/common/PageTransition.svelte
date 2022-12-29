<script>
	import { fly } from 'svelte/transition';
</script>

<span in:fly={{ y: -50, duration: 250, delay: 300 }} out:fly={{ y: -50, duration: 250 }}>
	<slot />
</span>
