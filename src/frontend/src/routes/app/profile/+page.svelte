<script lang="ts">
	import { user } from '$lib/stores/index';
	import type { User } from 'src/declarations/backend/backend.did';
	import { updateProfile } from '$lib/stores/tasks/updateProfile';
	import { 
		toNullable,
		fromNullable,
		toNullableDate, 
		fromNullableDate,
		toNullableGender,
		fromNullableGender 
	} from '$lib/utilities';
	import PublicToggle from '$lib/components/common/PublicToggle.svelte';
  import Eye from '$lib/assets/icons/eye.svg?component'


	//this could be moved to some declaration/constant somewhere else
 let genders = [
	'',
 	'Male' ,
	'Female' ,
	'Other',
	'Queer' 
 ]

let publicMode: boolean = true
let publicAbout: boolean = $user.about[1]
let publicConnect: boolean = $user.connect[1]
let publicBirth: boolean = $user.birth[1]
let publicGender: boolean = $user.gender[1]

//a user object to temporary store and change OUR values , this has NO User interface
let userObj = { 
	created: $user.created, 
	connect: fromNullable($user.connect[0]),
	about: fromNullable($user.about[0]),
	username: $user.username,
	gender: fromNullableGender($user.gender[0]), //biiitch
	birth: fromNullableDate(($user.birth[0]))
}



const update = () => {
	//sets the new user object to update
	const newUser: User = {
			created: $user.created,
			connect: [toNullable(userObj.connect), publicConnect],
			about: [toNullable(userObj.about), publicAbout],
			username: userObj.username,
			gender: [toNullableGender(userObj.gender), publicGender],
			birth: [toNullableDate(userObj.birth), publicBirth]
		}
		updateProfile(newUser)
}
</script>


<div class="flex flex-col gap-4">
  <h2 class="p-0">Profile settings</h2>
  <span class="text-slate-600 flex"><Eye/> : Allow what people can initially see about you.</span>
  <div class="dark:bg-slate-700 bg-slate-100 w-full rounded-md flex flex-col p-2 md:p-8">
		<!-- <strong>User data</strong><br />
		username: {$user.username}<br />
		created: {fromBigInt($user.created)}<br />
		gender: {$user.gender[1]} {$user.gender[0][0]}<br />
		birth: {$user.birth[1]} {userObj.birth}<br />
		connect: {$user.connect[1]} {$user.connect[0]}<br />
		about: {$user.about[1]} {$user.about[0]}<br />
		<br />
		<h3>Test out profile edit</h3>
		<br /> -->
		<div class="flex flex-col w-10/12">
      <span>Username</span>
      <label for="username" class="pr-8">
        <input
          type="text"
          id="username"
          class="inputfield"
          bind:value={userObj.username}
        />
      </label>

      <span>Gender</span>
      <label for="gender">
        
        <select bind:value={userObj.gender}>
          {#each genders as gender}
            <option value={gender} >
              {gender}
            </option>
          {/each}       
        </select>
        <PublicToggle bind:checked={publicGender}/>
      </label>

      <span>Birthday</span>
      <label for="birth">
        
        <input 
          type="date" 
          id="birth" 
          class="inputfield"
          bind:value={userObj.birth}
          min="1920-01-01" max="2022-01-01"
        />
      <PublicToggle bind:checked={publicBirth}/>
      </label>			
    
      <span>Email</span>
      <label for="connect">
        <input
          type="email"
          id="connect"
          class="inputfield"
          bind:value={userObj.connect}
        />
        <PublicToggle bind:checked={publicConnect}/>
      </label>

      <span>About</span>
      <label for="about">
        <textarea
          type="textfield "
          id="about"
          class="inputfield h-48 w-60"
          bind:value={userObj.about}
        />
        <PublicToggle bind:checked={publicAbout}/>
      </label>
    </div>
		

		<div class="fancy-btn-border mx-auto">
      <button on:click={update} class="fancy-btn">Update</button>
    </div>
	
	</div>
  
</div>


<style style lang="postcss">
	label {
		@apply flex my-2;
    
	}
  span {
    @apply grow;
  }

	.inputfield, option, select, textarea {
		@apply bg-slate-500 p-1 rounded-md mr-1 outline-none;
	}

</style>
