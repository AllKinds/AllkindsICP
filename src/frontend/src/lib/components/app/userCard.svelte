<script lang="ts">
	import { fromNullable , fromNullableGender} from '$lib/utilities';
	import type { User, UserMatch } from 'src/declarations/backend/backend.did';
	//export let match: [User, BigInt];
	export let match: UserMatch;
  let userBirth = fromNullable(match.birth); 
	let ageMs = Number(new Date()) - Number(match.birth) / 1000000;
	let ageY = Math.floor(ageMs / (1000 * 3600 * 24) / 365);

	//TODO : change backend so it doesn't return a User obj,
	//let it return the values that according user has made init public viewable
</script>

<!-- will only show 1 user for now, one with nearest cohesion score
TODO : finish this card, and fix cohesion score in backend for a proper result
TODO : at same time implement this into a friendlist and using same component 
TODO : backend create friendlist and connection request implementation -->

<div class="border-main p-3 flex justify-start">
	<div class="w-20 h-20 rounded-full border-main bg-sub mx-auto mr-4">
		<!-- placeholder profile picture -->
	</div>
	<div class="grow flex flex-col">
		<span class="text-sub text-2xl">{match.username}</span>
		<span>{match.about}</span>
		<span>{userBirth ? ageY : 'undefined'} , {fromNullableGender(match.gender)}</span>
		<span>{match.score}</span>
	</div>

	<!-- create and implement a Connection Request btn only when used from /home -->
</div>
