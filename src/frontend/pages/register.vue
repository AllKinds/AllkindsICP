<script lang="ts" setup>
import { Effect, pipe } from "effect";
import { FrontendError, formErr } from "../utils/errors";
import * as backend from "../utils/backend";

definePageMeta({
    title: "Allkinds",
    layout: 'default'
});
const username = useState("username", () => "");
const contact = useState("contact", () => "");
const loading = useState("loading", () => false);
const app = useAppState();

const validateUsername = (u: string): Effect.Effect<never, FrontendError, void> => {
    if (u.length < 2) return Effect.fail(formErr("tooShort"));
    if (u.length > 20) return Effect.fail(formErr("tooLong"));
    if (!/^[a-zA-Z][a-zA-Z0-9]*$/.test(u)) return Effect.fail(formErr("validationError"));

    return Effect.succeed(null);
};

// TODO: move to backend.ts
async function createUser() {
    const prog = pipe(
        validateUsername(username.value),
        () => backend.createUser(username.value, contact.value),
        Effect.match({
            onSuccess: () => { },
            onFailure: (err) => {
                if (err.tag === "backend" && getErrorKey(err.err) === "alreadyRegistered") {
                    navigateTo("/questions")
                }
            }
        }),
    );

    await runNotify(prog, "").then(() => { navigateTo("/questions") }).catch(console.warn);
}

const checkUser = () => {
    if (app.getUser().username?.length > 1) {
        navigateTo("/questions")
    }
}

if (inBrowser()) {
    app.loadUser(0, false)
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
