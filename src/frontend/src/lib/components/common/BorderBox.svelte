<script lang="ts">
	export let fill: any;
</script>

<!-- this could be enhanced and things like button.svelte possibly removed  -->

<div class="flex flex-col p-0.5 rounded-lg {fill}">
	<slot />
</div>
