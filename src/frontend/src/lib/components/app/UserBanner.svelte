<script lang="ts">
	import { fromNullable, fromNullableGender } from '$lib/utilities';
	import type { FriendlyUserMatch } from 'src/declarations/backend/backend.did';
	import CheckCircle from '$lib/assets/icons/check-circle.svg?component';
	import PlaceholderPic from '$lib/assets/icons/placeholder-pic.svg?component';
	import XCircle from '$lib/assets/icons/x-circle.svg?component';
	import { answerFriendRequest } from '$lib/stores/tasks/answerFriendRequest';
	import Spinner from '../common/Spinner.svelte';
	import { getFriends } from '$lib/stores/tasks/getFriends';
	import ArrowLeft from '$lib/assets/icons/arrowLeft.svg?component';
	import EllipsisVertical from '$lib/assets/icons/ellipsis-vertical.svg?component';
	import NavX from '$lib/assets/icons/navX.svg?component';
	import UserCard from './userCard.svelte';
	import { syncAuth } from '$lib/stores/tasks';

	export let match: any;

	let userCardWindow: boolean = false;

	let userName = match.username;
	let userPicture: any;
	let pending = false;
	//let userScore = Number(match.cohesion);
	let userAbout = match.about;
	let userGender = fromNullableGender(match.gender);
	//let userBirth = u.birth;
	//TODO make age utility function

	let ageMs = Number(new Date()) - Number(match.birth) / 1000000;
	let ageY = Math.floor(ageMs / (1000 * 3600 * 24) / 365);
	let answered = match.answered;
	let aQsize = answered.length;

	const handleRequest = async (answer: boolean) => {
		pending = true;
		await answerFriendRequest(match.principal, answer).catch((err) => {
			console.log('error while answering request : ', err);
		});
		await getFriends().catch((error) => {
			console.log('error while getting friends', error);
		});

		pending = false;
	};

	let a = fromNullable(match.picture);
	console.log(match.picture);
	if (a != undefined) {
		let image = new Uint8Array(a);
		let blob = new Blob([image], { type: 'image/png' });
		let reader = new FileReader();
		reader.readAsDataURL(blob);
		reader.onload = (res) => {
			userPicture = res.target?.result;
		};
		console.log('userpic', userPicture);
	} else {
		userPicture = undefined;
	}
</script>

<div class="flex bg-sub30 rounded-xl gap-2 p-2 text-left">
	{#if !userCardWindow}
		<button on:click={() => (userCardWindow = true)}>
			<EllipsisVertical class="w-10 hover-circle hover-color" />
		</button>
		<!-- <div class="w-16 h-16  min-w-min rounded-full border-main bg-sub shrink-0 overflow-clip">
			<PlaceholderPic class="w-12 mx-auto mt-4" />
		</div> -->
		<div class=" w-16 h-16 rounded-full border-main bg-sub mx-auto overflow-clip">
			{#if userPicture == undefined}
				<PlaceholderPic class=" w-12 h-12 mx-auto" />
			{:else}
				<img src={userPicture} alt="." class="w-auto h-auto mx-auto rounded-full" />
			{/if}
		</div>
		<div class="grow text-sm flex flex-col">
			<span class="text-xl">{userName}</span>
			<span class="text-sub">
				{match.birth.length ? ageY : ''}
				{userGender ? userGender : ''}
				<!--TODO :  shorten this about string-->
			</span>
			<span class="overflow-clip text-sub">{userAbout}</span>
		</div>
		<div class="shrink-0">
			<div class="border-main h-8 w-full p-1 px-2 rounded-full border-slate-200 text-center">
				{match.cohesion}
				{'('}{aQsize > 0 ? aQsize : 0}{')'}
			</div>
			<!-- show accept & reject control when target user requested to connect -->
			{#if Object.entries(match.status)[0][0] == 'Waiting'}
				<div class="h-8 w-fit pt-1 mx-auto">
					{#if pending}
						<Spinner />
					{:else}
						<button
							on:click={() => handleRequest(false)}
							class="text-red-500/50 hover:text-red-500"
						>
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
	{:else}
		<button on:click={() => (userCardWindow = false)}>
			<EllipsisVertical class="w-12 hover-circle hover-color" />
		</button>
		<div class="w-full sm:w-[600px] rounded-md flex flex-col gap-2 mx-auto">
			<button on:click={() => (userCardWindow = false)}>
				<ArrowLeft class="w-12 hover-circle hover-color" />
			</button>

			{#if match}
				<UserCard {match} />
			{:else}
				<span class="text-slate-700 mx-auto">Oops, Something went wrong!</span>
			{/if}
		</div>
	{/if}
</div>
