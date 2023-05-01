<script lang="ts">
	import { user } from '$lib/stores/index';
	import { fromNullableDate, fromNullableGender } from '$lib/utilities';
	import { onMount } from 'svelte';
	import { getQsAnswered, answeredQuestions, myQuestions } from '$lib/stores/tasks/getQsAnswered';
	import Qbanner from '$lib/components/app/Qbanner.svelte';
	import PlaceholderPic from '$lib/assets/icons/placeholder-pic.svg?component';
	import CustomTabs from '$lib/components/common/CustomTabs.svelte';

	//TODO make age/birth into ultility function

	let userBirth = fromNullableDate($user.birth[0]);
	let ageMs = Number(new Date()) - Number($user.birth[0]) / 1000000;
	let ageY = Math.floor(ageMs / (1000 * 3600 * 24) / 365);

	let userAge = userBirth ? ageY + ', ' : '';
	let userGender = fromNullableGender($user.gender[0])
		? fromNullableGender($user.gender[0]) + ', '
		: '';
	let userAbout = $user.about[0] ? $user.about[0] : '';
	let userConnect = $user.connect[0] ? $user.connect[0] : '';

	console.log('age', userBirth);
	console.log($user.about[0]);



	let lists: Array<{arr : Array<any>, title : String}>  = [
		{
			arr : $myQuestions,
			title : "My Questions"
		},
		{
			arr : $answeredQuestions,
			title : "All Answered"
		}
	]	
	onMount(async () => {
		//TODO change into button that then calls answered Q
		await getQsAnswered();
	});
</script>

<div class="flex flex-col gap-4">
	<div class=" w-48 h-48 rounded-full border-main bg-sub mx-auto overflow-clip">
		<PlaceholderPic class=" w-36 h-36 mx-auto mt-12"/>
	</div>

	<span
		class="text-4xl font-semibold mx-auto bg-clip-text text-transparent bg-rainbow-r drop-shadow-[0_0_20px_#404040]"
	>
		{$user.username}
	</span>

	<span class="p-0 text-xl mx-auto text-zinc-600">
		{userAge}{userGender}
		<span class="p-0 text-base mx-auto text-zinc-600">{userConnect}</span>
	</span>

	<span class="mx-auto">{userAbout}</span>

	<CustomTabs {lists} >
		<svelte:fragment slot="item" let:item>
			<Qbanner q={item}/>
		</svelte:fragment>
	</CustomTabs>
</div>
