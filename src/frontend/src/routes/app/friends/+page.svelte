<script lang="ts">
	import UserBanner from '$lib/components/app/UserBanner.svelte';
	import CustomTabs from '$lib/components/common/CustomTabs.svelte';
	import {
		getFriends,
		friendsApproved,
		friendsWaiting,
		friendsRequested
	} from '$lib/stores/tasks/getFriends';
	import { onMount } from 'svelte';

	const handleFindFriends = async () => {
		await getFriends().catch((error) => {
			console.log('error while getting friends', error);
		});
	};

	let lists: Array<{ arr: Array<any>; title: String }> = [
		{
			arr: $friendsApproved,
			title: 'My Friends'
		},
		{
			arr: $friendsWaiting,
			title: 'Requests'
		},
		{
			arr: $friendsRequested,
			title: 'Requests sent'
		}
	];

	onMount(() => {
		handleFindFriends();
	});
</script>

<CustomTabs {lists}>
	<svelte:fragment slot="item" let:item>
		<UserBanner match={item[0]} friendStatus={item[1]} />
	</svelte:fragment>
</CustomTabs>
