<script lang="ts">
  const colors = ['red', 'green', 'blue'];

  let selectedColor = localStorage.getItem('selectedColor') || 'red';

  function setSelectedColor() {
    localStorage.setItem('selectedColor', selectedColor);
  }

  function handleChange() {
    setSelectedColor();
  }
</script>

<select bind:value={selectedColor} on:change={handleChange}>
  {#each colors as color}
    <option value={color}>{color}</option>
  {/each}
</select>