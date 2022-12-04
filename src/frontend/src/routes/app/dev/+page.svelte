<script lang="ts">
  import BorderBox from '$lib/components/common/BorderBox.svelte';
  import { logout, actor, user, syncAuth, authStore } from '$lib/stores/auth';
  import Button from '$lib/components/common/Button.svelte';
	import { apiCall } from '$lib/stores/api';

  // function test() {
  //   apiCall({getUser}, {}).then(res => (

  //   ))
  // }
  console.log('u', $user)
</script>

<div class='pt-10 flex flex-col justify-center items-center'>
  <BorderBox fill="brand-gradient-br">
    <div class='dark:bg-slate-800 bg-slate-100 rounded-md p-2'>
      authStore: {$authStore}<br>
      user: {$user}<br>
      actor: {$actor}<br>

       
      <strong>User data</strong><br />
      username: {$user.username}<br>
      created: {$user.created}<br>
      gender: {$user.gender[1]}<br>
      birth: {$user.birth[1]}<br>
      connect: {$user.connect[1]}<br>
      
    </div>
    <!-- <Button on:click={null}>test</Button> -->
  </BorderBox>

  <Button on:click={logout}>logout</Button>
</div>

	