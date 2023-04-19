<script lang="ts">
	import { hueStore, setColor, styleStore } from "$lib/stores/tasks/colorSelect";

  //const colors = ['red', 'green', 'blue'];

  let selectedHue = parseInt($hueStore);
  //localStorage.getItem('selectedColor') || 'red';
//hsl(214, 100%, 66.47%)
  function setSelectedColor() {
    localStorage.setItem('selectedHue', `${selectedHue}`);
    setColor(selectedHue);
  }
</script>

<input type="range" min="0" max="360" bind:value={selectedHue} on:change={setSelectedColor}/>


