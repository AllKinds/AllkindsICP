<script lang="ts">
	import Button from '$lib/components/common/Button.svelte';
	import { user } from '$lib/stores';
	import type { Gender, User } from 'src/declarations/backend/backend.did';
	import { updateProfile } from '$lib/stores/tasks/updateProfile';


//have to put these functions elsewhere
export const toNullable = <T>(value?: T): [] | [T] => {
  return value ? [value] : [];
}

export const fromNullable = <T>(value: [] | [T]): T | undefined => {
  return value?.[0];
}

export function fromBigInt(utc: bigint) { 
		utc /= BigInt(1000000)
     return new Date(Number(utc)).toISOString(). slice(0,10) 
 }

export function toBigInt(date: string) {  
  return BigInt(Number(new Date(date)) * 1000000)
}

export const toNullableDate = (value?: string): [] | [bigint] => {
  return value && !isNaN(parseInt(`${value?.[0]}`)) ? [toBigInt(value)] : [];
};

export const fromNullableDate = (value?: [] | [bigint]): string | undefined => {
  const m = !isNaN(parseInt(`${value?.[0]}`)) ? value?.[0] : undefined;
	return m !== undefined ? fromBigInt(m) : m
}; 	

export const toNullableGender = (value?: string ): [] | [Gender] => {
	return value && value !== undefined ? [<Gender>{[value] : null}] : []
};	

export const fromNullableGender = (value?: [] | [Gender]): string | undefined => {
  const m = value !== undefined ? value?.[0] : undefined;
	return m !== undefined ? Object.entries(m)[0][0] : m
}; 	

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

let userObj = { //a temporary userObj to store and change OUR values , this has NO User interface
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
		<strong>User data</strong><br />
		username: {$user.username}<br />
		created: {fromBigInt($user.created)}<br />
		gender: {$user.gender[1]} {$user.gender[0][0]}<br />
		birth: {$user.birth[1]} {userObj.birth}<br />
		connect: {$user.connect[1]} {$user.connect[0]}<br />
		about: {$user.about[1]} {$user.about[0]}<br />
		<br />
		<h3>Test out profile edit</h3>
		<br />

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