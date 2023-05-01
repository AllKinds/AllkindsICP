<script lang="ts">
	export let text: string;
</script>

<div class="flex flex-col justify-center items-start">
	<h3>{text}</h3>
	<div class="flex gap-2">
		<slot name="input" />
		<slot name="public" />
	</div>
</div>
