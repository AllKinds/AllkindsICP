<script lang="ts" setup>
import { useAppState } from "~/composables/appState";
import { Effect } from "effect";
import { toNetworkError } from "~/helper/errors";

definePageMeta({ middleware: ["auth"] });
const app = useAppState();
const backend = useActor();

if (backend.value)
    backend.value
        .getUser()
        .then((u) => { app.value.user = u.ok })
        .then(() => console.log("appState set to", app.value));

const load = () => {
    const prog = Effect.gen(function* (_) {
        const actor = yield* _(useActorOrLogin())

        const getUser = Effect.tryPromise({
            try: actor.getUser,
            catch: toNetworkError,
        });

        app.value.user = yield _(getUser);
    });

    Effect.runPromise(prog).catch(() => addNotification("error", "couldn't load user"));
}

function showInfo(i: AppState) {
    console.log("i is", i);
    const user = i.user;
    return user?.username + ": " + user?.points + " points";
}
</script>

<template>
    <TextBlock>
        <h1>Welcome</h1>
        <p></p>
    </TextBlock>

    {{ showInfo(app) }}

    <Btn to="/home">continue</Btn>
</template>
