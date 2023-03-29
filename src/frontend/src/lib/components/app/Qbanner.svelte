<script lang="ts">
	import type { Question } from 'src/declarations/backend/backend.did';

	import ChevronDown from '$lib/assets/icons/chevronDown.svg?component';

	export let q: Question;
	//let expandWindow: boolean = false;
</script>

<!-- component for Question Banner Card on a User Profile  -->
<button
	class="h-18 w-full flex justify-between bg-sub30 hover-color border-main rounded-lg padding hover:bg-sub"
>
	<snap>{q.question}</snap>
	<!-- q.points should instead be weight of answer for that user. -->
	<snap>{q.points}</snap>
</button>
