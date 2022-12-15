import type { Gender, User } from "src/declarations/backend/backend.did";
import { actor } from '$lib/stores';
import { get } from "svelte/store";
import { syncAuth, user } from './auth';
import { goto } from '$app/navigation';


export async function updateProfile(newUser: User) {
  const localActor = get(actor)
  // const oldProfile = get(user)
	  //let gender: Gender = { Male: null }
	    // let newProfile: User = {
	    //   created: oldProfile.created,
	    //   connect: oldProfile.connect,
	    //   about: newV,
	    //   username: oldProfile.username,
	    //   gender: oldProfile.gender,
	    //   birth: oldProfile.birth
	    // }
      console.log('newUserToSend', newUser)
      await localActor.updateProfile(newUser).then((res) => console.log('res', res))
      // let result = await localActor.getUser()
		  //   user.set(result);
      
      //await $actor.updateProfile(user).then((res) => console.log('res', res))

      // connect: [["email@mail.com"], true],
      // about: [['this is about me'], true],
      // username: "shiqqqqt",
      // gender: [[gender], false],
      // birth: [[BigInt(0)], true]
}