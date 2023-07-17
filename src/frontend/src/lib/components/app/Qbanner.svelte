<script lang="ts">
	import type { Question } from 'src/declarations/backend/backend.did';

	export let q: Question;
</script>

<div class="{q.color} h-18 w-full flex justify-between rounded-lg px-2 py-1">
	{q.question}
	<span class="right text-zinc-500 hidden">{q.points}</span>
</div>
