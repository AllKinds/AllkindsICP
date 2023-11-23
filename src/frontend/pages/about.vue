<script lang="ts" setup>
definePageMeta({ title: "Privacy" });

</script>

<template>
    <AllkindsTitle>Hello</AllkindsTitle>

    <TextBlock align="text-left" class="w-96">
        <p>
            Allkinds.Team is build fully on blockchain, the Internet Computer.
        </p>

        <p>
            One of it's main features is to guarantee your privacy while asking and answering each others questions.
        </p>

        <p>
            While we are just piloting with you, we would like to ask you to track your actions so we can understand how to
            improve the service.
        </p>
    </TextBlock>

    <div class="grow" />

    <Btn to="/register">Agree</Btn>

    <ICFooter />
</template>
