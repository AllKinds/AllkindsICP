<script lang="ts">
	import type { User } from "src/declarations/backend/backend.did";
  export let match : [User, BigInt];
</script>

<!-- will only show 1 user for now, one with nearest cohesion score
TODO : finish this card, and fix cohesion score in backend for a proper result
TODO : at same time implement this into a friendlist and using same component 
TODO : backend create friendlist and connection request implementation -->

<div class="border-main bg-sub">
  {match[0].username}
  score: {match[1]}

  <!-- create and implement a Connection Request btn only when used from /home -->
</div>