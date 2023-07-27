<script lang="ts">
	import {
		addNotification,
		clearNotifications,
		notifications
	} from '$lib/utilities/notifications';
</script>

<ul class="mx-auto w-72 mt-4 opacity-80 toasts w-fit absolute">
	{#each $notifications as notification}
		<li
			class="border-2 {notification[1] ? 'bg-red-200' : 'bg-green-300'} px-5 py-4 rounded-lg cursor-pointer"
			on:click={() => clearNotifications()}
			on:keypress={() => null}
		>
            {#if notification[1]}
                <span class="text-xl">⚠</span>
            {:else}
                <span class="text-l">🛈</span>
            {/if}
			{notification[0]}
			<span class="float-right font-thin">&times;</span>
		</li>
	{/each}
</ul>
