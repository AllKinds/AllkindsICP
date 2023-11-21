<script lang="ts" setup>
import { Effect } from "effect";
import { EffectScope } from "vue";
import { BackendError, ErrorKey } from "~/helper/errors";

definePageMeta({ title: "Personal handle" });
const username = useState("username", () => "");
const contact = useState("contact", () => "");
const loading = useState("loading", () => false);

const validateUsername = (u: string): Effect.Effect<never, BackendError, void> => {
    if (u.length < 2) return Effect.fail({ tooShort: null });
    if (u.length > 20) return Effect.fail({ tooLong: null });
    if (!/^[a-zA-Z][a-zA-Z0-9]*$/.test(u)) return Effect.fail({ validationError: null });

    return Effect.succeed(null);
};

// TODO: move to backend.ts
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

    // TODO: 
    Effect.runPromise(prog).then(
        () => {
            navigateTo("/welcome");
        },
        (err) => {
        }
    );
}
</script>
<template>
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
        :class="{ 'input-disabled': loading }" />

    <div class="grow" />

    <Btn class="m-auto mt-12" :class="{ 'btn-disabled': username === '' }" @click="createUser()">
        Create
    </Btn>

    <ICFooter />
</template>
