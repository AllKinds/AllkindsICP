<script lang="ts">
	import { styleStore } from '$lib/stores/tasks/colorSelect';

	export let text: string;
</script>

<div style={$styleStore} class="flex flex-col justify-center items-start">
	<h3>{text}</h3>
	<div class="flex gap-2">
		<div class="flex flex-col p-0.5 rounded-lg bg-fancy">
			<slot name="input" />
		</div>
		<slot name="public" />
	</div>
</div>
