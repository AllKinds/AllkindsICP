<script lang="ts">
	import Qcard from "$lib/components/app/Qcard.svelte";
  import Add from "$lib/assets/icons/plus-circle.svg?component"
  import ChevronUp from "$lib/assets/icons/chevronUp.svg?component"
  import ChevronDown from "$lib/assets/icons/chevronDown.svg?component"
	import Button from "$lib/components/common/Button.svelte";
	import { onMount } from "svelte";
	import { createQuestion } from "$lib/stores/tasks/createQuestion";
	import { getQuestions, questions } from "$lib/stores/tasks/getQuestions";

  let expandWindow: boolean = false
  let newQ: string;



  function submitQ() {
    console.log('rdy to submit newQ : ', newQ)
    createQuestion(newQ)
  } 

  $: {
    console.log('$;questions', $questions)
  }

   onMount(() => {
    getQuestions()
   })
</script>

<div class="flex flex-col gap-4">
  <div class="dark:bg-slate-700 bg-slate-100 w-full rounded-md mx-auto flex-col p-1 md:p-2 lg:p-5 justify-between">

      <button class="w-full flex justify-between items-center" on:click={() => expandWindow = !expandWindow}>
       <span class="dark:text-slate-400 hover:text-slate-500">Create a new Yes/No question...</span> 
        
        {#if !expandWindow}
          <!-- <ChevronDown class="w-9 cursor-pointerborder-none" /> -->
          <Add class="iconbtn" />
        {:else if expandWindow}
          <ChevronUp class="iconbtn" />
        {/if}
      </button>
    
    {#if expandWindow}
        <div class="mt-8 flex flex-col justify-center items-center ">
          
            <textarea
              type="textfield"
              class="inputfield w-full min-h-fit bg-transparent outline-none text-4xl text-center"
              placeholder="What would you like to ask?"
              bind:value={newQ}
            />

            <Button on:click={submitQ}>Submit</Button>
        </div>
      {/if}
    
  </div>

  <Qcard/>
  <!-- <Qcard/>
  <Qcard/>
  <Qcard/>
  <Qcard/>
  <Qcard/> -->
</div>
