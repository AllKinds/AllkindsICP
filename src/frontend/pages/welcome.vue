<script lang="ts" setup>
import { Effect } from "effect";
import { toNetworkError } from "~/helper/errors";

definePageMeta({ middleware: ["auth"] });
const app = useAppState();

</script>

<template>
    <TextBlock>
        <h1>Welcome</h1>
        <p></p>
    </TextBlock>


    <Btn to="/home">continue</Btn>
</template>
