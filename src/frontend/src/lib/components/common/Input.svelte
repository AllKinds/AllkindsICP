<script lang="ts">
	import BorderBox from "./BorderBox.svelte";


  export let text: string;
</script>



<div class="flex flex-col justify-center items-start">
  <h3>{text}</h3>
  <div class="flex gap-2">
    <BorderBox fill="brand-gradient-br">
      <slot name="input"/>
    </BorderBox>
    <slot name="public" />
  </div>
</div>

 