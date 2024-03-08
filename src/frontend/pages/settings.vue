<script lang="ts" setup>
import { useAuthState } from '#imports';

definePageMeta({
  title: "Allkinds",
  layout: 'default'
});

const app = useAppState();
const auth = useAuthState();

const logout = () => {
  auth.logout();
  app.$reset();
  navTo("/");
};


const loading = ref(false);
const deleteAnswers = () => {
  const user = app.getUser().data?.user;
  if (!user) return;
  if (!window.confirm(
    "Do you really want to delete all answers you have given in this team.\n" +
    "\n" +
    "Delete answers?"
  )) return;

  if (!window.confirm(
    "Are you sure? This can not be undone!\n" +
    "\n" +
    "Delete answers?"
  )) return;

  loading.value = true;
  app.deleteAnswers(user.username).then(
    null,
    () => { addNotification("error", "Couldn't delete answers") },
  ).finally(
    () => { loading.value = false }
  );
}

const loadingDeleteUser = ref(false);
const deleteUser = () => {
  const user = app.getUser().data?.user;
  if (!user) return;
  if (!window.confirm(
    "WARNING!: you are about to delete the user " + user.username +
    "\n" +
    "You will be removed from all teams and your answers will be deleted.\n" +
    "\n" +
    "Delete user?"
  )) return;

  if (!window.confirm(
    "Are you sure? This can not be undone!\n" +
    "\n" +
    "Delete user?"
  )) return;

  loadingDeleteUser.value = true;
  app.deleteUser(user.username).then(
    () => { logout() },
    () => { addNotification("error", "Couldn't remove member") },
  ).finally(
    () => { loadingDeleteUser.value = false }
  );
}

if (inBrowser()) {
  app.loadUser();
  app.loadAnsweredQuestions();
  app.loadOwnQuestions();
}
</script>


<template>
  <div class="w-full flex-grow">
    <AllkindsTitle logo="x" logoSize="2em" linkTo="/my-profile">
      <span />
    </AllkindsTitle>

    <div class="flex flex-col">
      <Btn to="https://github.com/AllKinds/AllkindsICP/wiki/Allkinds" class="w-96">More about Allkinds</Btn>
      <Btn
        to="https://github.com/AllKinds/AllkindsICP/wiki/Allkinds#i-have-feedback-or-a-question-how-can-i-contact-you"
        class="w-96 mt-10">Get in touch
      </Btn>
      <Btn @click="logout()" class="w-96">Sign out</Btn>


      <Btn class="w-96 mt-20 bg-red-600" @click="deleteAnswers()" :loading="loading">Delete all my answers</Btn>
      <Btn class="w-96 bg-red-600" @click="deleteUser()" :loading="loadingDeleteUser">Delete my account and all data
      </Btn>
    </div>
  </div>
</template>
