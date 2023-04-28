<script lang="ts">
	import type { Question } from 'src/declarations/backend/backend.did';

	export let q: Question;

</script>

<!-- component for Question Banner Card on a User Profile  -->
<div
	class="{q.color} h-18 w-full flex justify-between rounded-lg px-2 py-1"
>
	{q.question}
	<!-- <slot name="weight" /> -->
</div>
