<script lang="ts">
	import Button from '$lib/components/common/Button.svelte';
	import { user } from '$lib/stores';
	import type { Gender, User } from 'src/declarations/backend/backend.did';
	import { updateProfile } from '$lib/stores/tasks/updateProfile';
	import { 
		toNullable,
		fromNullable,
		toNullableDate, 
		fromNullableDate,
		toNullableGender,
		fromNullableGender 
	} from '$lib/utilities';

	//this could be moved to some declaration/constant somewhere else
 let genders = [
	'',
 	'Male' ,
	'Female' ,
	'Other',
	'Queer' 
 ]

let publicMode: boolean = false
let publicAbout: boolean = $user.about[1]
let publicConnect: boolean = $user.connect[1]
let publicBirth: boolean = $user.birth[1]
let publicGender: boolean = $user.gender[1]

//an user object to temporary store and change OUR values , this has NO User interface
let userObj = { 
	created: $user.created, 
	connect: fromNullable($user.connect[0]),
	about: fromNullable($user.about[0]),
	username: $user.username,
	gender: fromNullableGender($user.gender[0]), //biiitch
	birth: fromNullableDate(($user.birth[0]))
}



const handle = () => {
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

<div class="pt-10 flex mx-auto w-10/12 justify-center items-center">
	<div class="dark:bg-slate-800 w-auto flex flex-col align-items-center justify-between bg-slate-100 rounded-md p-2">
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

		<label for="gender">Gender
			<select bind:value={userObj.gender}>
				{#each genders as gender}
					<option value={gender} >
						{gender}
					</option>
				{/each}
			</select>
			<input
				type="checkbox"
				id="togglePublic"
				bind:checked={publicGender}
			/>
		</label>

		<label for="birth">birth
			<input 
				type="date" 
				id="birth" 
				class="inputfield"
				bind:value={userObj.birth}
       	min="1920-01-01" max="2022-01-01"
			/>
			<input
				type="checkbox"
				id="togglePublic"
				bind:checked={publicBirth}
			/>
		</label>			
	
		<label for="username">username
			<input
				type="text"
				id="username"
				class="inputfield"
				bind:value={userObj.username}
			/>
			<input
				type="checkbox"
				id="togglePublic"
				bind:checked={publicMode}
			/>
		</label>

		<label for="connect">email
			<input
				type="email"
				id="connect"
				class="inputfield"
				bind:value={userObj.connect}
			/>
			<input
				type="checkbox"
				bind:checked={publicConnect}
			/>
		</label>

		<label for="about">about
			<input
				type="text"
				id="about"
				class="inputfield"
				bind:value={userObj.about}
			/>
			<input
				type="checkbox"
				bind:checked={publicAbout}
			/>
		</label>

		<Button on:click={handle}>test</Button>
	
	</div>
</div>


<style style lang="postcss">
	label {
		@apply flex justify-between m-2;
	}
	.inputfield, option, select {
		@apply bg-slate-600 p-1 rounded-md ;
	}
</style>