import { actor } from '$lib/stores';
import type { Hash } from 'src/declarations/backend/backend.did';
import { get } from 'svelte/store';
import { getQs } from './getQs';


export async function skipQ(hash: Hash){
  const localActor = get(actor)
  console.log(hash, '= gonna be skipped')
  await localActor.submitSkip(hash).then((res) => console.log('Res after Q skipped :', res))
  getQs()
}
