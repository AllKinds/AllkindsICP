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
		fromNullableGender,
		convertImageToUInt8Array
	} from '$lib/utilities';
	import PublicToggle from '$lib/components/common/PublicToggle.svelte';
	import Eye from '$lib/assets/icons/eye.svg?component';
	import Spinner from '$lib/components/common/Spinner.svelte';

	//TODO : RECYCLE CODE (see other profile file)
	//TODO : DECOMPONENTIALISE parts that could be used in future

	let pending: boolean = false;
	//this could be moved to some declaration/constant somewhere else
	let genders = ['', 'Male', 'Female', 'Other', 'Queer'];

	let publicMode: boolean = true;
	let publicAbout: boolean = $user.about[1];
	let publicConnect: boolean = $user.connect[1];
	let publicBirth: boolean = $user.birth[1];
	let publicGender: boolean = $user.gender[1];
	let publicPicture: boolean = $user.picture[1];

	//a user object to temporary store and change OUR values , this has NO User interface
	let userObj = {
		created: $user.created,
		connect: fromNullable($user.connect[0]),
		about: fromNullable($user.about[0]),
		username: $user.username,
		gender: fromNullableGender($user.gender[0]), //biiitch
		birth: fromNullableDate($user.birth[0]),
		picture: fromNullable($user.picture[0])
	};

	let file : any;
	let imgSrc : any;
	let testBlob : any;

	const handleFileInput = async () => {
    const uint8Array = await convertImageToUInt8Array(file);
    const blob = new Blob([uint8Array], { type: file.type });
		testBlob = blob;
		userObj.picture = uint8Array;
    imgSrc = URL.createObjectURL(blob);
  }

	const update = async () => {
		pending = true;
		//sets the new user object to update
		const newUser: User = {
			created: $user.created,
			connect: [toNullable(userObj.connect), publicConnect],
			about: [toNullable(userObj.about), publicAbout],
			username: userObj.username,
			gender: [toNullableGender(userObj.gender), publicGender],
			birth: [toNullableDate(userObj.birth), publicBirth],
			points: $user.points,
			picture: [toNullable(userObj.picture), publicPicture]	
			//TODO : fix vulnerability with points being in userObj
		};
		await updateProfile(newUser).catch((error) => {
			console.log('errorcatch', error);
		});
		pending = false;
	};
	$: {
		console.log('pic : ',userObj.picture);
		console.log('img : ', imgSrc);
		console.log('blob : ', testBlob);
	}
</script>

<div class="flex flex-col gap-4">
	<h2 class="p-0 text-center ">Profile settings</h2>
	<span class="text-zinc-600 flex justify-center"
		><Eye /> : Allow what people can initially see about you.</span
	>
	<div class=" w-full rounded-md flex flex-col p-2 md:p-8">
		<div class="flex flex-col w-10/12">
			<span>Username</span>
			<label for="username" class="pr-8">
				<input
					type="text"
					id="username"
					class="inputfield border-main"
					bind:value={userObj.username}
				/>
			</label>

			<span>Gender</span>
			<label for="gender">
				<select bind:value={userObj.gender}>
					{#each genders as gender}
						<option value={gender}>
							{gender}
						</option>
					{/each}
				</select>
				<PublicToggle bind:checked={publicGender} />
			</label>

			<span>Birthday</span>
			<label for="birth">
				<input
					type="date"
					id="birth"
					class="inputfield border-main"
					bind:value={userObj.birth}
					min="1920-01-01"
					max="2022-01-01"
				/>
				<PublicToggle bind:checked={publicBirth} />
			</label>

			<span>Email</span>
			<label for="connect">
				<input
					type="email"
					id="connect"
					class="inputfield border-main"
					bind:value={userObj.connect}
				/>
				<PublicToggle bind:checked={publicConnect} />
			</label>

			<span>About</span>
			<label for="about">
				<textarea id="about" class="inputfield h-48 w-60 border-main" bind:value={userObj.about} />
				<PublicToggle bind:checked={publicAbout} />
			</label>

			<span>Profile picture</span>
			<label for="picture">
				<input type="file" bind:this={file} on:change={handleFileInput}/>
				<PublicToggle bind:checked={publicPicture} />
				<img src={imgSrc} alt=""/>
			</label>

		</div>

		<div class="flex flex-col justify-center items-center">
			<div class="fancy-btn-border">
				<button on:click={update} class="fancy-btn">
					{#if pending}
						<Spinner />
					{:else}
						Update
					{/if}
				</button>
			</div>
		</div>
	</div>
</div>

<style style lang="postcss">
	/* was needed for fixing gender options */
	label {
		@apply flex my-2;
	}
	span {
		@apply grow;
	}
	.inputfield,
	option,
	select,
	textarea {
		@apply bg-zinc-500/20 p-1 rounded-md mr-1 outline-none;
	}
</style>
