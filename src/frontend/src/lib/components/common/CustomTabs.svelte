<script lang="ts">
  //custom reusable multi tab UI for showing array data after sorting

  let current = 0;
  export let lists: Array<{arr : Array<any>, title : String}>;

  // example of using component
  //   <CustomTabs {lists} >
  //     <svelte:fragment slot="item" let:item>
  //       <UserBanner match={item}/>
  //     </svelte:fragment>
  //   </CustomTabs>
</script>

<div class="flex flex-col gap-4">

  <div class="flex gap-3">
    {#each lists as {arr, title}, key}
      <button
        on:click={() => (current = key)}
        class:currentTab={current === key}
        class="pb-2 text-left hover-color hover-circle"
      >
        {title}{'('}{arr ? arr.length : 0}{')'}
      </button>
    {/each}
  </div>  

  <div class="rounded-md flex flex-col gap-y-2">
    {#each lists as {arr, title}, key}
      {#if arr && current == key}
        {#each arr as item}
          <slot name="item" {item} /> 
        {/each}
      {/if}
    {/each}
  </div>

</div>