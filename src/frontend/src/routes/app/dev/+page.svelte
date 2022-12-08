<script lang="ts">
	import BorderBox from '$lib/components/common/BorderBox.svelte';
	import { logout } from '$lib/stores/tasks';

	import Button from '$lib/components/common/Button.svelte';
	import { user, actor, authStore } from '$lib/stores';
	import { nullable, string, z } from 'zod';
	import type { Gender, User } from 'src/declarations/backend/backend.did';

	import { updateProfile } from '$lib/stores/tasks/updateProfile';
	import { stringify } from 'postcss';
	//^^^this import is temporary


const toNullable = <T>(value?: T): [] | [T] => {
  return value ? [value] : [];
}
const fromNullable = <T>(value: [] | [T]): T | undefined => {
  return value?.[0];
}

function fromBigInt(utc: bigint) { 
		utc /= BigInt(1000000)
     return new Date(Number(utc)).toISOString(). slice(0,10) 
 }

function toBigInt(date: string) {  
  return BigInt(Number(new Date(date)) * 1000000)
}


export const toNullableDate = (value?: string): [] | [bigint] | undefined => {
  return value && !isNaN(parseInt(`${value?.[0]}`)) ? [toBigInt(value)] : [];
};

const fromNullableDate = (value?: [] | [bigint]): string | undefined => {
  const m = !isNaN(parseInt(`${value?.[0]}`)) ? value?.[0] : undefined;
	return m !== undefined ? fromBigInt(m) : m
}; 	


let publicMode: boolean = false
let publicAbout: boolean = $user.about[1]
let publicConnect: boolean = $user.connect[1]
let publicBirth: boolean = $user.birth[1]
	// const updateProfile = async () => {

// this would need typesafety
let userObj = {
	created: $user.created, //not allowed to change this shouldnt actually be part of the updateProfile motoko function
	connect: fromNullable($user.connect[0]),
	about: fromNullable($user.about[0]),
	username: $user.username,//ez
	gender: $user.gender, //biiitch
	birth: fromNullableDate(($user.birth[0]))
}



$: { //temptest
	console.log('update userObj:',  userObj)
	//console.log('fromBigIntBirth', fromBigInt(userObj.birth))
}


const handle = () => {

	const newUser: User = {
			created: $user.created,
			connect: [toNullable(userObj.connect), publicConnect],
			about: [toNullable(userObj.about), publicAbout],
			username: userObj.username,
			gender: $user.gender,
			birth: [toNullableDate(userObj.birth), publicBirth]
				// birth needs a date to bigint transform
		}

	 console.log('newV', newUser)
	 
		updateProfile(newUser)
}


//from gives undefined for empty
//to gives [ [] ] for empty 

//from gives the string for a filled para
//to gives [ (1) […] ] for a filled para

//toNullable([]) this seems to create correct empty [[]] statement, only need to add true or false in it
//true or false is always present in those that have the option (ex; not username)





		
		console.log('user', $user )
		// let value = ($user.connect === undefined ? 'works' : $user.connect[1])

</script>

<div class="pt-10 flex mx-auto w-10/12 justify-center items-center">
	<div class="dark:bg-slate-800 w-auto flex flex-col align-items-center justify-between bg-slate-100 rounded-md p-2">
		<strong>User data</strong><br />
		username: {$user.username}<br />
		created: {fromBigInt($user.created)}<br />
		gender: {$user.gender[1]} {$user.gender[0]}<br />
		birth: {$user.birth[1]} {$user.birth[0]}<br />
		connect: {$user.connect[1]} {$user.connect[0]}<br />
		about: {$user.about[1]} {$user.about[0]}<br />
	
		<br />
		<h3>Test out profile edit</h3>
		<br />

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
	.inputfield {
		@apply bg-slate-600 p-1 rounded-md ;
	}
</style>