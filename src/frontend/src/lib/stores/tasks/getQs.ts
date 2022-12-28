import { actor } from '$lib/stores';
import { get, writable } from 'svelte/store';

export const questions = writable<Array<[]>>()

export async function getQs() {
  const localActor = get(actor)
  return await localActor.getAskableQuestions().then((res) => {
    console.log('questions: ', res.ok)
    questions.set(res.ok)
   
    //questions.set(res.ok)
  })
  
  

  // if (result.hasOwnProperty('ok')) {
  //   console.log('ok', result.ok[0])
  //   result.ok
	// } else if (result.hasOwnProperty('err')) {
  //   console.log('err', result)
	// } else {
	// 	console.error('else', result);
	// }
}