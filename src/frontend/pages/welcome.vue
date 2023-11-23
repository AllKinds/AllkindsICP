<script lang="ts" setup>
import { Effect } from "effect";
import { toNetworkError } from "~/utils/errors";

definePageMeta({ title: "Welcome" });
const app = useAppState();

</script>

<template>
    <AllkindsTitle>Welcome</AllkindsTitle>
    <TextBlock>
        <h1>Welcome</h1>
        <p></p>
    </TextBlock>


    <Btn to="/home">continue</Btn>
</template>
