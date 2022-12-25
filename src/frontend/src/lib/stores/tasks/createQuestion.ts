import { actor } from '$lib/stores';
import { get } from 'svelte/store';


export async function createQuestion(text: string) {
  const localActor = get(actor)
  console.log('New Q is gonna be created:', text)
  await localActor.createQuestion(text).then((res) => console.log('Res after Q creation :', res))
}

