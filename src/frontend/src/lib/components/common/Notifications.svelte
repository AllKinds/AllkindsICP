<script lang="ts">
	import {
		addNotification,
		clearNotifications,
		notifications
	} from '$lib/utilities/notifications';
</script>

<ul class="mx-auto w-72 opacity-80">
	{#each $notifications as notification}
		<li
			class="border-2 bg-red-200 px-5 py-4 rounded-lg cursor-pointer"
			on:click={() => clearNotifications()}
			on:keypress={() => null}
		>
			<b class="text-xl">⚠</b>
			{notification}
			<span class="float-right font-thin">&times;</span>
		</li>
	{/each}
</ul>
