<script lang="ts">
	import Button from '$lib/components/common/Button.svelte';
	import BorderBox from '$lib/components/common/BorderBox.svelte';
	import { regiStore } from '$lib/stores';
	import { RegiState } from '$lib/stores/types';

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
	import { syncAuth } from '$lib/stores/tasks';

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

	async function submit() {
		const newUser: User = {
			created: $user.created,
			connect: [toNullable(userObj.connect), publicConnect],
			about: [toNullable(userObj.about), publicAbout],
			username: userObj.username,
			gender: [toNullableGender(userObj.gender), publicGender],
			birth: [toNullableDate(userObj.birth), publicBirth]
		}
		await updateProfile(newUser)
		regiStore.set(RegiState.Finished);
	}
</script>

<div class="flex flex-col justify-center items-center">
	
	<h2>Setup your profile</h2>
	<span>You can also do this later</span>
	<br/>
	<BorderBox fill="brand-gradient-br">
		<div class="dark:bg-slate-800 w-auto flex flex-col align-items-center justify-between bg-slate-100 rounded-md p-2">

			

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
		</div>
	</BorderBox>
	<div class="w-fit h-fit mx-auto">
		<Button on:click={submit}>Continue</Button>
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
