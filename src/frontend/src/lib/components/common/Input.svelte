<script lang="ts">
	export let text: string;
</script>

<div class="flex flex-col items-center">
	<h3>{text}</h3>
	<div class="flex gap-1">
		<slot name="input" style="background-color: antiquewhite;"/>
		<slot name="public" />
	</div>
</div>
