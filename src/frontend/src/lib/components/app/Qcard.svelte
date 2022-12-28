<script lang="ts">
	import { answerQ } from "$lib/stores/tasks/answerQ";
	import { getQs } from "$lib/stores/tasks/getQs";
	import { skipQ } from "$lib/stores/tasks/skipQ";
	import { fromBigInt } from "$lib/utilities";
	import type { AnswerKind } from "src/declarations/backend/backend.did";

  export let question: any;
  let skipPending: boolean = false
  let answerPending: boolean | undefined = undefined
  

  const submitAnswer = async(bool: boolean) => {
    answerPending = bool
    let answer: AnswerKind = { Bool: bool }
    await answerQ(question.hash, answer).then(res => {
      answerPending = undefined
    })
    getQs()
  }

  const skipQuestion = async() => {
    skipPending = true
    await skipQ(question.hash).then(res => {
      skipPending = false
    })
    getQs()
  }
 
</script>
<div class="odd:dark:bg-slate-700 even:dark:bg-slate-700/50 odd:bg-slate-100 even:bg-slate-200/50 dark:border-none w-full border rounded-md mx-auto flex flex-col justify-center items-center p-2 md:p-3 lg:p-5">
  <h2 class=" w-fit">{question.question}</h2>
  <span>Created: {fromBigInt(question.created)}</span>
  <!-- <span>Hash: {question.hash}</span>
  <span>Color: {question.color[0]}</span> -->
  <!--   -->
  <div class="w-full flex flex-row justify-center items-center dark:text-slate-700 pt-3 gap-2 md:gap-4">
      <button on:click={() => submitAnswer(true)} class="bg-green-400 hover:bg-green-500 h-14 w-5/12 rounded-xl flex justify-center items-center">
        <h3>
          {#if answerPending == true}
            Loading...
          {:else}
            YES
          {/if}
        </h3>
      </button>
      <button on:click={skipQuestion} class="dark:bg-slate-600 h-14 w-10 md:w-14 rounded-xl dark:hover:bg-slate-700 bg-slate-200 hover:bg-slate-300">
        <span class=" text-slate-400">
          {#if !skipPending}
            skip
          {:else if skipPending}
            O
          {/if}
        </span>
      </button>
      <button on:click={() => submitAnswer(false)} class="bg-red-400 hover:bg-red-500 h-14 w-5/12 rounded-xl flex justify-center items-center">
        <h3>
          {#if answerPending == false}
            Loading...
          {:else }
            NO
          {/if}
        </h3>
      </button>
  </div>
</div>
