<script lang="ts">
	import { fromNullableGender } from '$lib/utilities';
	import type { FriendlyUserMatch } from 'src/declarations/backend/backend.did';
	import CheckCircle from '$lib/assets/icons/check-circle.svg?component';
	import PlaceholderPic from '$lib/assets/icons/placeholder-pic.svg?component';
	import XCircle from '$lib/assets/icons/x-circle.svg?component';
	import { answerFriendRequest } from '$lib/stores/tasks/answerFriendRequest';
	import Spinner from '../common/Spinner.svelte';
	import { getFriends } from '$lib/stores/tasks/getFriends';

	export let u: FriendlyUserMatch;

	let userName = u.username;
	let pending = false;
	//let userScore = Number(match.cohesion);
	let userAbout = u.about;
	let userGender = fromNullableGender(u.gender);
	//let userBirth = u.birth;
	//TODO make age utility function
	console.log("userBirth", u.birth)
	let ageMs = Number(new Date()) - Number(u.birth) / 1000000;
	let ageY = Math.floor(ageMs / (1000 * 3600 * 24) / 365);
	let answered = u.answered;
	let aQsize = answered.length;

	const handleRequest = async (answer: boolean) => {
		pending = true;
		await answerFriendRequest(u.principal, answer)
			.catch((err) => {
				console.log('error while answering request : ', err);
			});
		await getFriends().catch((error) => {
			console.log('error while getting friends', error);
		});
			
		pending = false;
	};
</script>

<!-- TODO have different column for non-approved friends -->
<button class="flex bg-sub30 rounded-xl gap-2 p-2 hover:bg-sub text-left">
	<div class="w-16 h-16  min-w-min rounded-full border-main bg-sub shrink-0 overflow-clip">
		<PlaceholderPic class="w-12 mx-auto mt-4"/>
	</div>

	<div class="grow text-sm flex flex-col">
		<span class="text-xl">{userName}</span>
		<span class="text-sub">
			{u.birth.length ? ageY : ''}
			{userGender ? userGender : ''}
			<!--TODO :  shorten this about string-->
		</span>
		<span class="overflow-clip text-sub">{userAbout}</span>
	</div>
	<div class="shrink-0">
		<div class="border-main h-8 w-full p-1 px-2 rounded-full border-slate-200 text-center">
			{u.cohesion}
			{'('}{aQsize > 0 ? aQsize : 0}{')'}
		</div>
		<!-- show accept & reject control when target user requested to connect -->
		{#if Object.entries(u.status)[0][0] == 'Waiting'}
			<div class="h-8 w-fit pt-1 mx-auto">
				{#if pending}
					<Spinner />
				{:else}
					<button on:click={() => handleRequest(false)} class="text-red-500/50 hover:text-red-500">
						<XCircle class="w-8 h-8" />
					</button>
					<button
						on:click={() => handleRequest(true)}
						class="text-green-500/50 hover:text-green-500"
					>
						<CheckCircle class="w-8 h-8" />
					</button>
				{/if}
			</div>
		{/if}
	</div>
	<!-- <span>Friend status : {friend.status}</span> -->
</button>
