<script lang="ts">
	import { sendFriendRequest } from '$lib/stores/tasks/sendFriendRequest';
	import { fromNullable, fromNullableGender } from '$lib/utilities';
	import type { Principal } from '@dfinity/principal';
	import type { FriendlyUserMatch } from 'src/declarations/backend/backend.did';
	import PlaceholderPic from '$lib/assets/icons/placeholder-pic.svg?component';
	import Spinner from '../common/Spinner.svelte';
	import Qbanner from './Qbanner.svelte';
	import QbannerNoColor from './QbannerNoColor.svelte';
	import CustomTabs from '../common/CustomTabs.svelte';
	import { onMount } from 'svelte';

	export let match: FriendlyUserMatch;

	let pending: boolean = false;
	let succes: boolean = false;
	let current = 0;

	let userPicture: any;
	let userPrincipal: Principal = match.principal;
	let userName = match.username;
	let userScore = match.cohesion;
	let userAbout = match.about;
	let userGender = fromNullableGender(match.gender);
	let userBirth = match.birth;
	//TODO make age utility function
	let ageMs = Number(new Date()) - Number(match.birth) / 1000000;
	let ageY = Math.floor(ageMs / (1000 * 3600 * 24) / 365);
	//TODO : return all questions (+weight) with indication which had common answer (matched)
	let answered = match.answered;
	let uncommon = match.uncommon;
	let aQsize = answered.length;
	let uQsize = uncommon.length;

	const handleConnectionRequest = async () => {
		pending = true;
		succes = false;
		await sendFriendRequest(userPrincipal).catch((err) => {
			console.log('error while sending connection request', err);
		});
		succes = true;
		pending = false;
	};
	//console.log("PIC TEST", match)

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

	let lists: Array<{ arr: Array<any>; title: String }> = [
		{
			arr: answered,
			title: 'All Questions'
		},
		{
			arr: uncommon,
			title: 'Find Out'
		}
	];
</script>

<!-- NOTE: this component sizes according to parent -->
<div class="w-full flex flex-col justify-between mx-auto">
	<!-- <div class="w-full h-72 sm:h-96 mx-auto rounded-md bg-sub overflow-clip">
		<PlaceholderPic class=" h-56 sm:h-72 mx-auto mt-24" />
	</div> -->
	<div class=" w-40 h-40 rounded-full border-main bg-sub mx-auto overflow-clip">
		{#if userPicture == undefined}
			<PlaceholderPic class=" w-36 h-36 mx-auto mt-12" />
		{:else}
			<img src={userPicture} alt="." class="w-auto h-auto mx-auto rounded-full" />
		{/if}
	</div>

	<div class="p-1 sm:p-2 flex flex-col">
		<div class="flex p-1 text-2xl font-bold justify-between">
			<span>{userName}</span>
			<span>
				{userScore}
				{'(' + aQsize + ')'}
			</span>
		</div>
		<span class="p-1 text-slate-600"
			>{userBirth ? ageY + ', ' : ''}{userGender ? userGender : ''}</span
		>
		<span class="p-1 ">{userAbout ? userAbout : ''}</span>

		{#if succes}
			<span class="mx-auto text-slate-600 py-8">Connection request send!</span>
		{:else}
			<div class="mx-auto fancy-btn-border">
				<button on:click={handleConnectionRequest} class="fancy-btn bg-main90">
					{#if pending}
						<Spinner />
					{:else}
						Connect
					{/if}
				</button>
			</div>
		{/if}

		<CustomTabs {lists}>
			<svelte:fragment slot="item" let:item>
				{#if item[1]}
					<QbannerNoColor q={item[0]} b={item[1]} />
				{:else}
					<Qbanner q={item} />
				{/if}
			</svelte:fragment>
		</CustomTabs>
	</div>
</div>
