<script lang="ts">

	import type { AnswerKind, LikeKind, Question } from 'src/declarations/backend/backend.did';

	import EllipsisVertical from '$lib/assets/icons/ellipsis-vertical.svg?component';
  import NavX from '$lib/assets/icons/navX.svg?component';
	import Qcontent from './Qcontent.svelte';


	export let question: Question;
  let expandWindow : boolean = false;

	
</script>

<div
	class="odd:dark:bg-slate-900/30 even:dark:bg-slate-900/40 odd:bg-slate-100 even:bg-slate-200/50 dark:border-none h-fit w-full border rounded-lg p-2 md:p-3 lg:p-5"
>
  <button 
    class="flex h-full w-full text-slate-500 hover:text-slate-200"
    on:click={() => expandWindow = !expandWindow}
  > 
    <span class="break-all text-2xl text-left grow text-slate-200">
      {#if !expandWindow}
        {question.question}
        <div class="mt-14"/> 
      {/if}
    </span>

    <div class="">
      {#if !expandWindow}
        <EllipsisVertical />
      {:else}
        <NavX />
      {/if}
      
    </div>
  </button>

  {#if expandWindow}
    <Qcontent {question}/>
  {/if}
</div>
