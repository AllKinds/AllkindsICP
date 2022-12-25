import type { User } from "src/declarations/backend/backend.did";
import { actor } from '$lib/stores';
import { get } from "svelte/store";
import { syncAuth} from './auth';

export async function updateProfile(newUser: User) {
  const localActor = get(actor)
  console.log('newUserToSend', newUser)
  await localActor.updateProfile(newUser).then((res) => console.log('res', res))
  await syncAuth()
}