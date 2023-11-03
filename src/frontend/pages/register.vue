<script lang="ts" setup>
import { Effect } from "effect";
import { EffectScope } from "vue";
import { BackendError, ErrorKey } from "~/helper/backend";

definePageMeta({ title: "Personal handle" });
const username = useState("username", () => "");
const error = useState<Error | null>("username-error", () => null);
const loading = useState("loading", () => false);

const validateUsername = (u: string): Effect.Effect<never, BackendError, void> => {
  if (u.length < 2) return Effect.fail({ tooShort: null });
  if (u.length > 20) return Effect.fail({ tooLong: null });
  if (!/^[a-zA-Z][a-zA-Z0-9]*$/.test(u)) return Effect.fail({ validationError: null });

  return Effect.succeed(null);
};

function formatError(err: Error): string {
  const key = Object.keys(err)[0] as ErrorKey;
  switch (key) {
    case "notLoggedIn":
      return "You have to be logged in to create a handle";
    case "tooShort":
      return "This handle is too short. It must be between 5 and 10 characters.";
    case "tooLong":
      return "This handle is too long. It must be between 5 and 10 characters.";
    case "alreadyRegistered":
      return "You already registed a handle.";
    case "validationError":
      return "Username must only contain letters and numbers";
    case "nameNotAvailable":
      return "This handle is taken. Please choose another one. ";

    default:
      return "Error: " + key + " " + JSON.stringify(err);
  }
}

function createUser() {
  const prog = Effect.gen(function* (_) {
    yield* _(Effect.log("start creating " + username.value));
    yield* _(validateUsername(username.value));
    yield* _(Effect.log("local validation passed"));
    const backend = yield* _(useActorOrLogin());
    yield* _(Effect.log("getting actor passed"));
    const res = yield* _(
      Effect.tryPromise({
        try: () => backend.createUser(username.value),
        catch: (err) => {
          return Effect.fail(new Error("" + err));
        },
      })
    );
    return Effect.succeed(null);
  });

  error.value = null;
  Effect.runPromise(prog).then(
    () => {
      navigateTo("/welcome");
    },
    (err) => {
      error.value = err;
    }
  );
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
        placeholder="username"
        required
        class="w-52 m-2"
        :class="{ 'input-disabled': loading }"
      />
    </div>

    <Btn
      class="m-auto mt-12"
      :class="{ 'btn-disabled': username === '' }"
      @click="createUser()"
    >
      Create
    </Btn>
  </div>
</template>
