import { actor } from '$lib/stores';
import type { LikeKind, Hash } from 'src/declarations/backend/backend.did';
import { get } from 'svelte/store';

export async function likeQ(hash: Hash, like: LikeKind) {
	const localActor = get(actor);
	console.log(hash, ' = gonna be answerLiked with: ', like);
	await localActor
		.submitLike(hash, like)
		.then((res) => console.log('Res after like submitted :', res));
}
