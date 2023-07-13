<script lang="ts">
	import { user, avatar } from '$lib/stores/index';
	import { capitalize, fromNullableDate, fromNullableGender } from '$lib/utilities';
	import { onMount } from 'svelte';
	import { getQsAnswered, answeredQuestions, myQuestions } from '$lib/stores/tasks/getQsAnswered';
	import Qbanner from '$lib/components/app/Qbanner.svelte';
	import PlaceholderPic from '$lib/assets/icons/placeholder-pic.svg?component';
	import CustomTabs from '$lib/components/common/CustomTabs.svelte';
	import type { Social } from 'src/declarations/backend/backend.did';


	let userAge = $user.age ? $user.age[0] + ', ' : '';
	let userGender = fromNullableGender($user.gender[0])
		? fromNullableGender($user.gender[0]) + ', '
		: '';
	let userAbout = $user.about[0] ? $user.about[0] : '';
	let userEmail  = $user.socials[0] ? $user.socials[0][0].handle : '';
	let userPicture : any = $avatar;

	console.log('age', userAge);
	console.log($user.about[0]);

	$: lists = [
		{
			arr: $myQuestions,
			title: 'My Questions'
		},
		{
			arr: $answeredQuestions,
			title: 'All Answered'
		}
	];
	onMount(async () => {
		//TODO change into button that then calls answered Q
		console.log('temptest:::', userPicture);
		await getQsAnswered();
	});
</script>

<div class="flex flex-col gap-4">
	<div class=" w-40 h-40 rounded-full border-main bg-sub mx-auto overflow-clip">
		{#if userPicture == undefined}
			<PlaceholderPic class=" w-36 h-36 mx-auto mt-12" />
		{:else}
			<img src={userPicture} alt="." class="w-auto h-auto mx-auto rounded-full" />
		{/if}
	</div>

	<span
		class="text-4xl font-semibold mx-auto bg-clip-text text-transparent bg-rainbow-r drop-shadow-[0_0_20px_#404040]"
	>
		{$user.username}
	</span>

	<span class="p-0 text-xl mx-auto text-zinc-600">
		{userAge} {capitalize(userGender)}
		<span class="p-0 text-base mx-auto text-zinc-600">{userEmail}</span>
	</span>

	<span class="mx-auto">{userAbout}</span>

	<CustomTabs {lists}>
		<svelte:fragment slot="item" let:item>
			<Qbanner q={item} />
		</svelte:fragment>
	</CustomTabs>
</div>
