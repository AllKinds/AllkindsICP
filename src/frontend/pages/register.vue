<script lang="ts" setup>
import { Error } from "~~/src/declarations/backend/backend.did";

definePageMeta({ title: "Personal handle" });
const username = useState("username", () => "");
const error = useState<Error | null>("username-error", () => null);

const validateUsername = () => {
  error.value = { alreadyRegistered: null };
};

function formatError(err: Error): string {
  switch (Object.keys(err)[0]) {
    case "notLoggedIn":
      return "You have to be logged in to create a handle";
    case "tooLong":
      return "This handle is too short. It must be between 5 and 10 characters.";
    case "tooLong":
      return "This handle is too long. It must be between 5 and 10 characters.";
    case "alreadyRegistered":
      return "You already registed a handle.";

    case "nameNotAvailable":
    default:
      return "This handle is taken. Please choose another one.";
  }
}
</script>
<template>
  <div class="form-control">
    <TextBlock align="text-center">
      <p>
        Your personal handle is how people will see you. <br />
        You will be also able to share your profile using this handle.
      </p>
    </TextBlock>

    <div class="text-center p-4" v-if="error" @click="error = null">
      <span class="alert alert-error">
        {{ formatError(error) }}
      </span>
    </div>

    <div class="flex items-center m-auto">
      https://allkinds.xyz/@
      <TextInput
        name="handle"
        v-model.trim="username"
        @input="validateUsername"
        placeholder="username"
        required
        class="w-52 m-2"
      />
    </div>

    <Btn class="m-auto mt-12" :class="{ 'btn-disabled': username === '' }"> Create </Btn>
  </div>
</template>
