<script lang="ts">
	import { fromNullableGender } from "$lib/utilities";
	import type { FriendlyUserMatch } from "src/declarations/backend/backend.did";


  export let u: FriendlyUserMatch;

	let userName = u.username;
	//let userScore = Number(match.cohesion);
	let userAbout = u.about;
	let userGender = fromNullableGender(u.gender);
	//let userBirth = u.birth;
	//TODO make age utility function
	let ageMs = Number(new Date()) - Number(u.birth) / 1000000;
	let ageY = Math.floor(ageMs / (1000 * 3600 * 24) / 365);
	//TODO : return all questions (+weight) with indication which had common answer (matched)
	let answeredQuestions = u.answeredQuestions;
	let aQsize = answeredQuestions.length;
  {'('}{aQsize > 0 ? aQsize : 0}{')'}

</script>

<!-- TODO have different column for non-approved friends -->
<button class="flex bg-sub30 rounded-xl gap-2 p-2 hover-color hover:bg-sub text-left">
  <div class="w-16 h-16  min-w-min rounded-full border-main bg-sub shrink-0">
		<!-- placeholder profile picture -->
	</div>
  
  <div class="grow text-sm flex flex-col">
    <span class="text-xl">{userName}</span> 
    <span class="text-zinc-500">
      {ageY}
      {userGender}
       <!--TODO :  shorten this about string-->
    </span>
    <span class="text-zinc-600 overflow-clip">{userAbout}</span>
  </div>
  <div class="border-main h-8 w-fit p-1 px-2 rounded-full border-slate-200 shrink-0">
    {u.cohesion}
    {'(' + u.answeredQuestions.length + ')'}
  </div>
  <!-- <span>Friend status : {friend.status}</span> -->
</button>