<script lang="ts">
	import { user } from '$lib/stores/index';

  const handleFindMatches = async () => {

  }
	
</script>

<div class="flex flex-col gap-2">
  <div class="fancy-btn-border mx-auto mb-0">
    <button on:click={handleFindMatches} class="fancy-btn">Find a new connection</button>
  </div>
  <span class="text-md font-semibold text-slate-600 mx-auto">Add filters +</span>

	

	<div class="dark:bg-slate-700 bg-slate-100 w-100% rounded-md flex flex-col p-2 md:p-8 gap-2">
		friendlist here
	</div>
  
</div>
