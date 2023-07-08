<script lang="ts">
	import { avatar, user } from '$lib/stores/index';
	import type { Social, User } from 'src/declarations/backend/backend.did';
	import { updateProfile } from '$lib/stores/tasks/updateProfile';
	import {
		toNullable,
		fromNullable,
		toNullableDate,
		fromNullableDate,
		toNullableGender,
		fromNullableGender
		//convertImageToUInt8Array
	} from '$lib/utilities';
	import PublicToggle from '$lib/components/common/PublicToggle.svelte';
	import Eye from '$lib/assets/icons/eye.svg?component';
	import PlaceholderPic from '$lib/assets/icons/placeholder-pic.svg?component';

	import Spinner from '$lib/components/common/Spinner.svelte';

	//TODO : RECYCLE CODE (see other profile file)
	//TODO : DECOMPONENTIALISE parts that could be used in future

	let pending: boolean = false;
	let _avatar: any = $avatar;
	let fileInput: any;
	//this could be moved to some declaration/constant somewhere else
	let genders = ['', 'Male', 'Female', 'Other', 'Queer'];

	let publicMode: boolean = true;
	let publicAbout: boolean = $user.about[1];
    let publicEmail: boolean = $user.socials[0] ? $user.socials[0][1] : true;
	let publicAge: boolean = $user.age[1];
	let publicGender: boolean = $user.gender[1];
	let publicPicture: boolean = $user.picture[1];

	//a user object to temporary store and change OUR values , this has NO User interface
	let userObj = {
		created: $user.created,
		email: $user.socials[0] ? $user.socials[0][0].handle : '',
		about: fromNullable($user.about[0]),
		username: $user.username,
		gender: fromNullableGender($user.gender[0]),
		age: fromNullable($user.age[0]),
		picture: fromNullable($user.picture[0])
	};

	// let file: any;
	// let imgSrc: any;
	// let testBlob: any;

	const onFileSelected = (e: any) => {
		//reads file and shows in UI
		let image = e.target?.files[0];
		let reader = new FileReader();
		reader.readAsDataURL(image);
		reader.onload = (res) => {
			_avatar = res.target?.result;
		};
		console.log('avatar', avatar);

		//transforms file to array for backend
		let writer = new FileReader();
		writer.readAsArrayBuffer(image);
		writer.onload = (res) => {
			let avatarArr: any = res.target?.result;
			userObj.picture = new Uint8Array(avatarArr);
		};
		console.log('userObj.picture :', userObj.picture);
	};

	const update = async () => {
		pending = true;
		//sets the new user object to update
        let social : Social = {network: {email: null}, handle: userObj.email}; 
		const newUser: User = {
			created: $user.created,
			socials: [[social, publicEmail]],
			about: [toNullable(userObj.about), publicAbout],
			username: userObj.username,
			gender: [toNullableGender(userObj.gender), publicGender],
			age: [toNullable(userObj.age), publicAge],
			points: $user.points,
			picture: [toNullable(userObj.picture), publicPicture]
			//TODO : fix vulnerability with points being in userObj
		};
		await updateProfile(newUser).catch((error) => {
			console.log('errorcatch', error);
		});
		pending = false;
	};
</script>

<div class="flex flex-col gap-2">
	<h2 class="p-0 text-center ">Profile settings</h2>

		<!-- <label for="picture">
				<input type="file" bind:this={file} on:change={handleFileInput} />
				<img src={imgSrc} alt="" />
			</label>
			 -->

		<button
			class=""
			on:click={() => {
				fileInput.click();
			}}
		>
			<div class=" w-40 h-40 rounded-full border-main bg-sub mx-auto overflow-clip">
				{#if _avatar == undefined}
					<PlaceholderPic class=" w-36 h-36 mx-auto mt-12" />
				{:else}
					<img src={_avatar} alt="." class="w-auto h-auto mx-auto rounded-full" />
				{/if}
			</div>
			<input
				style="display:none"
				type="file"
				accept=".jpg, .jpeg, .png"
				on:change={(e) => onFileSelected(e)}
				bind:this={fileInput}
				disabled={pending}
			/>
		</button>
		
	</div>

	<div class=" w-fit rounded-md flex flex-col p-2 md:p-8 mx-auto">
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

		<span>Age</span>
		<label for="birth">
			<input
				type="number"
				id="birth"
				class="inputfield border-main"
				bind:value={userObj.age}
			/>
			<PublicToggle bind:checked={publicAge} />
		</label>

		<span>Email</span>
		<label for="connect">
			<input
				type="email"
				id="connect"
				class="inputfield border-main"
				bind:value={userObj.email}
			/>
			<PublicToggle bind:checked={publicEmail} />
		</label>

		<span>About</span>
		<label for="about">
			<textarea id="about" class="inputfield h-24 w-60 border-main" bind:value={userObj.about} />
			<PublicToggle bind:checked={publicAbout} />
		</label>

		
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
		@apply bg-zinc-500/20 p-1 rounded-md mr-1 outline-none w-60;
	}
</style>
