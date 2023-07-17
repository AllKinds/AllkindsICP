<script lang="ts">
	import type { AnswerDiff, Question } from 'src/declarations/backend/backend.did';
	import { onMount } from 'svelte';

	export let q: Question;
	export let d: AnswerDiff;

</script>

<div class="h-18 w-full flex justify-between rounded-lg px-2 py-1 bg-sub text-main {d.sameAnswer ? 'same-answer' : ''}">
	{q.question}
	<!-- <slot name="weight" /> -->
</div>
