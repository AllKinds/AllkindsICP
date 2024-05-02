<script lang="ts" setup>
import { Effect, pipe } from "effect";
import { type FrontendError, formErr, notifyError } from "../utils/errors";
import * as backend from "../utils/backend";

definePageMeta({
    title: "Allkinds",
    layout: 'default'
});
const username = ref("");
const about = ref("");
const contact = ref("");
const loading = ref(false);
const app = useAppState();

const validateUsername = (u: string): Effect.Effect<never, FrontendError, void> => {
    if (u.length < 2) return Effect.fail(formErr("tooShort"));
    if (u.length > 20) return Effect.fail(formErr("tooLong"));
    if (!/^[a-zA-Z][a-zA-Z0-9]*$/.test(u)) return Effect.fail(formErr("validationError"));

    return Effect.succeed(null);
};

const getUsernameError = (u: string): FrontendError | null => {
    if (u.length < 2) return formErr("tooShort");
    if (u.length > 20) return formErr("tooLong");
    if (!/^[a-zA-Z][a-zA-Z0-9]*$/.test(u)) return formErr("validationError");

    return null;
}

var redirect = true;
// TODO: move to backend.ts
async function createUser() {
    const err = getUsernameError(username.value);
    if (err) { notifyError(err); return; }

    const prog = pipe(
        validateUsername(username.value),
        () => backend.createUser(username.value, about.value, contact.value),
        Effect.tapBoth({
            onSuccess: (a) => {
                redirect = false;
                navTo("/intro-1");
                return Effect.succeed(a);
            },
            onFailure: (err) => {
                if (err.tag === "backend" && getErrorKey(err.err) === "alreadyRegistered") {
                    navTo("/logged-in")
                }
                return Effect.fail(err)
            }
        }),
    );

    await runNotify(prog, "").catch(console.warn);
}

const checkUser = () => {
    if ((app.getUser().data?.user.username.length || 0) > 1 && redirect) {
        navTo("/logged-in")
    }
}

if (inBrowser()) {
    app.loadUser(0, false).then(() => {
        console.error("Navigate to /register, but already registered. Something is wrong. Redirecting to /logged-in");
        navTo("/logged-in")
    })
}

</script>
<template>
    <div class="w-full flex-grow flex flex-col items-center">
        {{ checkUser() }}
        <AllkindsTitle>Register</AllkindsTitle>

        <TextBlock align="text-left">
            Nickname
        </TextBlock>

        <TextInput name="handle" v-model.trim="username" placeholder="" required class="w-full m-2"
            :class="{ 'input-disabled': loading }" />

        <TextBlock align="text-left">
            A few words about yourself
        </TextBlock>

        <TextArea name="about" v-model.trim="about" placeholder="" required class="w-full m-2 text-md"
            :class="{ 'input-disabled': loading }" />

        <TextBlock align="text-left">
            Any contact
        </TextBlock>

        <TextInput name="handle" v-model.trim="contact" placeholder="e.g. john@example.com" required class="w-full m-2"
            :class="{ 'input-disabled': loading }" @keyup.enter="createUser()" />

        <div class="grow" />

        <Btn class="mt-12" :class="{ 'btn-disabled': username === '' }" @click="createUser()">
            Join
        </Btn>

        <div class="grow" />

        <ICFooter />
    </div>
</template>
