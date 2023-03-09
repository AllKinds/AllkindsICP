import type { ActorSubclass } from '@dfinity/agent';
import type { _SERVICE } from 'src/declarations/backend/backend.did';

//to declare all type structures

//Backend based
export enum AuthState {
	LoggedOut,
	LoggedIn,
	Registered
}
export type BackendActor = ActorSubclass<_SERVICE>;
//Frontend based
export enum RegiState {
	Username,
	Profile,
	Finished
}
export enum RootState {
	Landing,
	Register,
	App
}
export enum AppState {
	Home,
	People,
	User,
	Profile,
	Dev
}

//Others

// export const ProfileSchema = z.object({
//   created: z.bigint(),
//   connect:

// })

// let gender: Gender = { Male: null };
// let user: User = {
// 	created: BigInt(0),
// 	connect: [['email@mail.com'], true],
// 	about: [[a], true],
// 	username: 'shiqqqqt',
// 	gender: [[gender], false],
// 	birth: [[BigInt(0)], true]
// };

// export interface User {
// 	created: bigint;
// 	connect: [[] | [string], boolean];
// 	about: [[] | [string], boolean];
// 	username: string;
// 	gender: [[] | [Gender], boolean];
// 	birth: [[] | [bigint], boolean];
// }
