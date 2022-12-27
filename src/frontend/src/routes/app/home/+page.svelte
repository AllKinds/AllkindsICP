<script lang="ts">
	import Qcard from "$lib/components/app/Qcard.svelte";
  import Add from "$lib/assets/icons/plus-circle.svg?component"
  import ChevronUp from "$lib/assets/icons/chevronUp.svg?component"
  import ChevronDown from "$lib/assets/icons/chevronDown.svg?component"
	import { onMount } from "svelte";
	import { createQ } from "$lib/stores/tasks/createQ";
	import { getQs, questions } from "$lib/stores/tasks/getQs";

  let expandWindow: boolean = false
  let newQ: string

   onMount(async () => {
    await getQs()
   })

   const submit = async () => {
    await createQ(newQ)
    newQ = ''
   }
</script>

<div class="flex flex-col gap-4 ">
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
              id="questionInput"
              class="inputfield w-full min-h-fit bg-transparent outline-none text-4xl text-center"
              placeholder="What would you like to ask?"
              bind:value={newQ}
            />
            <div class="fancy-btn-border">
              <button on:click={submit} class="fancy-btn">Submit</button>
            </div>
        </div>
      {/if}
    
  </div>


  {#if $questions }
    {#each $questions as question}
      <Qcard {question}/>
    {/each}
  {/if}
</div>
