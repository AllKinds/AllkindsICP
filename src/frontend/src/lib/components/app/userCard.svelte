<script lang="ts">
	import type { User } from 'src/declarations/backend/backend.did';
	export let match: [User, BigInt];
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
		<span class="text-sub text-2xl">{match[0].username}</span>
		<span>{match[0].about}</span>
	</div>

	<!-- create and implement a Connection Request btn only when used from /home -->
</div>
