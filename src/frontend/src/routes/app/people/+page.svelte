<script lang="ts">
	import { user } from '$lib/stores/index';

  import Slider from '@bulatdashiev/svelte-slider';
	import type { MatchingFilter } from 'src/declarations/backend/backend.did';
	import { bind } from 'svelte/internal';

  let expandWindow : Boolean = false;
  let ageValue = [0, 150];
  let cohesionValue = [100, 100];
  let genderValue = 'all';
  //TODO : import gender as type and directly send with Matching filter
  //TODO : ageMin and ageMax could be made into a tuple type AgeRange

  const handleFindMatches = async () => {
    let filter : MatchingFilter = {
      cohesion : cohesionValue[0],
      ageMin : ageValue[0],
      ageMax : ageValue[1]
    }
  }
	
</script>

<div class="flex flex-col gap-2">
  <div class="fancy-btn-border mx-auto mb-0">
    <button on:click={handleFindMatches} class="fancy-btn">Find a new connection</button>
  </div>
  <button
    class="w-full flex justify-between items-center text-slate-600 hover:text-slate-500"
    on:click={() => (expandWindow = !expandWindow)}
  >
    <span class="text-md font-semibold mx-auto">Change search parameters</span>
  </button>
  
  
  {#if expandWindow}
    <div class="w-full md:w-2/3 mx-auto flex flex-col md:flex-row gap-2 justify-center">

      <div class="md:w-5/12 flex flex-col bg-slate-700/20 p-2 rounded-md gap-2">
        <span class="text-md font-semibold text-slate-500 mx-auto">Age</span>
        <span class="mx-auto">{ageValue[0]} - {ageValue[1]} year</span>
        <Slider min="0" max="150" step="1" bind:value={ageValue} range order/>
      </div>

      <div class="md:w-5/12 flex flex-col bg-slate-700/20 p-2 rounded-md gap-2">
        <span class="text-md font-semibold text-slate-500 mx-auto">Cohesion</span>
        <span class="mx-auto">{cohesionValue[0]}%</span>
        <Slider bind:value={cohesionValue}/>
      </div>

      <!-- TODO : gender options, make like profile settings
      + make global declarations for let genders = ['', 'Male', 'Female', 'Other', 'Queer'];
      + label and for each for reoccuring code -->
      <div class="md:w-5/12 flex flex-col bg-slate-700/20 p-2 rounded-md gap-2">
        <span class="text-md font-semibold text-slate-500 mx-auto">Gender</span>
        <button 
          class="subtleBtn w-full active"
          class:active="{genderValue === 'all'}"
	        on:click="{() => genderValue = 'all'}"
        >Everyone</button>

        <div class="grid grid-rows-2 grid-cols-2 gap-2">
          <button 
            class="subtleBtn" 
            class:active="{genderValue === 'male'}"
	          on:click="{() => genderValue = 'male'}"
          >Male</button>

          <button 
            class="subtleBtn" 
            class:active="{genderValue === 'female'}"
	          on:click="{() => genderValue = 'female'}"
          >Female</button>

          <button 
            class="subtleBtn"
            class:active="{genderValue === 'queer'}"
	        on:click="{() => genderValue = 'queer'}"
          >Queer</button>

          <button 
            class="subtleBtn" 
            class:active="{genderValue === 'other'}"
	          on:click="{() => genderValue = 'other'}"
          >Other</button>
        </div>
      </div>

    </div>
  {/if}
	

	<div class="dark:bg-slate-700 bg-slate-100 w-100% rounded-md flex flex-col p-2 md:p-8 gap-2 mt-8">
		friendlist here?
	</div>
  
</div>
