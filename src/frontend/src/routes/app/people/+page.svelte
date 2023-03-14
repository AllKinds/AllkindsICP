<script lang="ts">
	import { user } from '$lib/stores/index';
	import { makeExpiryTransform } from '@dfinity/agent';

  let expandWindow : Boolean = false;

  const handleFindMatches = async () => {

  }
	
</script>

<div class="flex flex-col gap-2">
  <div class="fancy-btn-border mx-auto mb-0">
    <button on:click={handleFindMatches} class="fancy-btn">Find a new connection</button>
  </div>
  <button
    class="w-full flex justify-between items-center"
    on:click={() => (expandWindow = !expandWindow)}
  >
    <span class="text-md font-semibold text-slate-600 mx-auto">Add filters +</span>
  </button>
  
  {#if expandWindow}
    <div class="w-full md:w-2/3 mx-auto flex bg-slate-700">
      test
    </div>
  {/if}
	

	<div class="dark:bg-slate-700 bg-slate-100 w-100% rounded-md flex flex-col p-2 md:p-8 gap-2">
		friendlist here
	</div>
  
</div>
