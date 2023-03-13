<script lang="ts">
	import { user } from '$lib/stores/index';
	import type { User } from 'src/declarations/backend/backend.did';
	import { updateProfile } from '$lib/stores/tasks/updateProfile';
	import {
		toNullable,
		fromNullable,
		toNullableDate,
		fromNullableDate,
		toNullableGender,
		fromNullableGender,
		toBigInt
	} from '$lib/utilities';
	import PublicToggle from '$lib/components/common/PublicToggle.svelte';
	import Eye from '$lib/assets/icons/eye.svg?component';
	import Spinner from '$lib/components/common/Spinner.svelte';
	import { is_empty, is_void, null_to_empty, to_number } from 'svelte/internal';
	import { login } from '$lib/stores/tasks';



	let userBirth = fromNullableDate($user.birth[0]);
	//ISSUE date ms is counted from 1970, anyone born before might have issues (prob wrong date-time used in createProfile)
	let ageMs = Number(new Date()) - (Number($user.birth[0]) / 1000000);
	let ageY = Math.floor((ageMs / (1000 * 3600 * 24)) / 365)

	console.log('age', userBirth);
	console.log($user.about[0])

</script>

<div class="flex flex-col gap-4">
	<span class=" text-4xl font-semibold mx-auto">{$user.username}</span>
	<span class="p-0 text-xl text-slate-600 mx-auto">
		<!-- TEMP FIX : check and manually give undefined bcs of date-time issue -->
		{userBirth ? ageY : 'undefined'} , {fromNullableGender($user.gender[0])}
	</span>
	<span class="mx-auto">{$user.about[0] ? $user.about[0] : ''}</span>
	
	<div class="dark:bg-slate-700 bg-slate-100 w-100% rounded-md flex flex-col p-2 md:p-8">

		<div class="flex flex-col ">
			Feed for my created/answered questions
		</div>
		
	</div>
</div>

