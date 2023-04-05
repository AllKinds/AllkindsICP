<script lang="ts">
	import { fromNullableGender } from '$lib/utilities';
	import type { FriendlyUserMatch } from 'src/declarations/backend/backend.did';
	import CheckCircle from '$lib/assets/icons/check-circle.svg?component';
	import XCircle from '$lib/assets/icons/x-circle.svg?component';
	import { answerFriendRequest } from '$lib/stores/tasks/answerFriendRequest';
	import Spinner from '../common/Spinner.svelte';

	export let u: FriendlyUserMatch;

	let userName = u.username;
	let pending = 0;
	let answer: boolean;
	//let userScore = Number(match.cohesion);
	let userAbout = u.about;
	let userGender = fromNullableGender(u.gender);
	//let userBirth = u.birth;
	//TODO make age utility function
	let ageMs = Number(new Date()) - Number(u.birth) / 1000000;
	let ageY = Math.floor(ageMs / (1000 * 3600 * 24) / 365);
	//TODO : return all questions (+weight) with indication which had common answer (matched)
	let answeredQuestions = u.answered;
	let aQsize = answeredQuestions.length;

	const handleRequest = async () => {
		pending = 1;
		await answerFriendRequest(u.principal, answer).catch((err) => {
			console.log('error while answering request : ', err);
		});
	};
</script>

<!-- TODO have different column for non-approved friends -->
<button class="flex bg-sub30 rounded-xl gap-2 p-2 hover:bg-sub text-left">
	<div class="w-16 h-16  min-w-min rounded-full border-main bg-sub shrink-0">
		<!-- placeholder profile picture -->
	</div>

	<div class="grow text-sm flex flex-col">
		<span class="text-xl">{userName}</span>
		<span class="text-sub">
			{ageY}
			{userGender}
			<!--TODO :  shorten this about string-->
		</span>
		<span class="overflow-clip text-sub">{userAbout}</span>
	</div>
	<div class="shrink-0">
		<div class="border-main h-8 w-fit p-1 px-2 rounded-full border-slate-200">
			{u.cohesion}
			{'('}{aQsize > 0 ? aQsize : 0}{')'}
		</div>
		{#if Object.entries(u.status)[0][0] == 'Waiting'}
			<Spinner />
		{:else if pending}
			<div class="h-8 w-full rounded-full mt-1">
				<button class="text-red-500/50 hover:text-red-500">
					<XCircle class="w-8 h-8" />
				</button>
				<button class="text-green-500/50 hover:text-green-500">
					<CheckCircle class="w-8 h-8" />
				</button>
			</div>
		{/if}
	</div>
	<!-- <span>Friend status : {friend.status}</span> -->
</button>
