<script lang="ts" setup>
import { Effect, pipe } from "effect";
import { FrontendError, formErr, notifyError } from "../utils/errors";
import * as backend from "../utils/backend";

definePageMeta({
    title: "Allkinds",
    layout: 'default'
});
const username = ref("");
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

// TODO: move to backend.ts
async function createUser() {
    const err = getUsernameError(username.value);
    if (err) { notifyError(err); return; }

    const prog = pipe(
        validateUsername(username.value),
        () => backend.createUser(username.value, contact.value),
        Effect.match({
            onSuccess: () => {
                navigateTo("/intro-1");
            },
            onFailure: (err) => {
                if (err.tag === "backend" && getErrorKey(err.err) === "alreadyRegistered") {
                    navigateTo("/logged-in")
                }
            }
        }),
    );

    await runNotify(prog, "").catch(console.warn);
}

const checkUser = () => {
    if ((app.getUser().data?.user.username.length || 0) > 1) {
        navigateTo("/logged-in")
    }
}

if (inBrowser()) {
    app.loadUser(0, false).then(() => {
        console.error("Navigate to /register, but already registered. Something is wrong. Redirecting to /logged-in");
        navigateTo("/logged-in")
    })
}

</script>
<template>
    <div class="w-full flex-grow flex flex-col items-center">
        {{ checkUser() }}
        <AllkindsTitle>Register</AllkindsTitle>

        <TextBlock align="text-left">
            Your nickname can be anything
        </TextBlock>

        <TextInput name="handle" v-model.trim="username" placeholder="username" required class="w-full m-2"
            :class="{ 'input-disabled': loading }" />

        <TextBlock align="text-left">
            If you consider to get in touch with people, leave a way to contact you here.
            <br />
            (tg, fb, discord, phone, email)
        </TextBlock>

        <TextInput name="handle" v-model.trim="contact" placeholder="Contact" required class="w-full m-2"
            :class="{ 'input-disabled': loading }" @keyup.enter="createUser()" />

        <div class="grow" />
        <div class="grow" />

        <Btn class="mt-12" :class="{ 'btn-disabled': username === '' }" @click="createUser()">
            Join
        </Btn>

        <div class="grow" />

        <ICFooter />
    </div>
</template>
