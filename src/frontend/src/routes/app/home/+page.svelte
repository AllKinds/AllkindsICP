<script lang="ts">
	import Qcard from "$lib/components/app/Qcard.svelte";
  import Add from "$lib/assets/icons/plus-circle.svg?component"
  import ChevronUp from "$lib/assets/icons/chevronUp.svg?component"
  import ChevronDown from "$lib/assets/icons/chevronDown.svg?component"
	import Button from "$lib/components/common/Button.svelte";

  let expandWindow: boolean = false
  let newQ: string;
</script>




<div class="flex flex-col gap-4">
  <div class="bg-slate-700 w-full rounded-md mx-auto flex-col p-1 md:p-2 lg:p-5 justify-between">

      

      <button class="w-full flex justify-between items-center hover:text-slate-300" on:click={() => expandWindow = !expandWindow}>
       <span class="text-slate-400">Create a new Yes/No question...</span> 
        
        {#if !expandWindow}
          <!-- <ChevronDown class="w-9 cursor-pointerborder-none" /> -->
          <Add class="w-9 cursor-pointerborder-none" />
        {:else if expandWindow}
          <ChevronUp class="w-9 cursor-pointerborder-none" />
        {/if}
      </button>
    
    {#if expandWindow}
        <div class="mt-8 flex flex-col justify-center items-center ">
          
            <textarea
              type="textfield"
              class="inputfield w-full min-h-fit bg-transparent outline-none text-4xl text-center"
              placeholder="What do you want to know about people?"
              bind:value={newQ}
            />

            <Button>Submit</Button>
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
