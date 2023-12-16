<script lang="ts" setup>

definePageMeta({ title: "Welcome" });
const app = useAppState();

</script>

<template>
    <AllkindsTitle>Welcome</AllkindsTitle>
    <TextBlock>
        <h1>Welcome</h1>
        <p></p>
    </TextBlock>


    <Btn to="/questions">continue</Btn>
</template>
