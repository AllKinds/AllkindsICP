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
	import Input from '$lib/components/common/Input.svelte';
	import PublicToggle from '$lib/components/common/PublicToggle.svelte';


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
	<span>(You can also do this later)</span>

	<div class=" justify-around p-5">
		<Input text="Gender">
		<select bind:value={userObj.gender} slot="input">
			{#each [ '', 'Male' , 'Female' , 'Other', 'Queer' ] as gender}
				<option value={gender} >
					{gender}
				</option>
			{/each}
		</select>
		<PublicToggle slot="public" bind:checked={publicGender}/>
	</Input>

	<Input text="Birthday">
		<input
			type="date"
			class="inputfield"
			slot="input"
			bind:value={userObj.birth}
			min="1920-01-01" max="2022-01-01"
		/>
		<PublicToggle slot="public" bind:checked={publicBirth}/>
	</Input> 	

	<Input text="Email">
		<input
			type="email"
			class="inputfield"
			slot="input"
			bind:value={userObj.connect}
		/>
		<PublicToggle slot="public" bind:checked={publicConnect}/>
	</Input> 

	<Input text="About you">
		<textarea
			type="textfield"
			class="inputfield"
			slot="input"
			bind:value={userObj.about}
		/>
		
		<PublicToggle slot="public" bind:checked={publicAbout}/>
	</Input> 
	</div>
	

	<Button on:click={submit}>Continue</Button>
</div>


<style style lang="postcss">
	.inputfield, option, select, input {
		@apply bg-slate-600 p-1 rounded-md ;
	}
</style>
