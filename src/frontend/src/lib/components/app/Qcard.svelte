<script lang="ts">
	import { skipQ } from "$lib/stores/tasks/skipQ";
	import { fromBigInt } from "$lib/utilities";

  export let question: any;
 
</script>

<div class="odd:dark:bg-slate-700 even:dark:bg-slate-700/50 odd:bg-slate-100 even:bg-slate-100/50 w-full rounded-md mx-auto flex flex-col justify-center items-center p-2 md:p-3 lg:p-5">
  <h2 class=" w-fit">{question.question}</h2>
  <span>Created: {fromBigInt(question.created)}</span>
  <span>Hash: {question.hash}</span>
  <span>Color: {question.color[0]}</span>
  <span>Creator: {question.creater}</span>
  <div class="w-full flex flex-row justify-center items-center dark:text-slate-700 pt-3 gap-2 md:gap-4">
      <button class="bg-green-400 hover:bg-green-500 h-14 w-4/12 rounded-xl flex justify-center items-center">
        <h3>YES</h3>
      </button>
      <button on:click={() => skipQ(question.hash)} class="bg-slate-600 h-14 w-10 md:w-14 rounded-xl hover:bg-slate-700">
        <span class=" text-slate-400">skip</span>
      </button>
      <button class="bg-red-400 hover:bg-red-500 h-14 w-4/12 rounded-xl flex justify-center items-center">
        <h3>NO</h3>
      </button>
  </div>
</div>