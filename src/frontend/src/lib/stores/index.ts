//groups all stores
import { rootStore, regiStore, appStore } from './tasks/routing';
import { authStore, actor, user } from './tasks/auth';
import { questions } from './tasks/getQuestions';


export {
  authStore,
  actor,
  user,
  rootStore,
  regiStore,
  appStore,
  questions
}