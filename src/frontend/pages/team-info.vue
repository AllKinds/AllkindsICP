<script lang="ts" setup>
definePageMeta({ title: "Welcome" });

const app = useAppState();

if (inBrowser()) {
    app.loadTeams(0);
}
</script>

<template>
    <AllkindsTitle logo="ph:x-circle" link-to="/questions">
    </AllkindsTitle>

    <NetworkDataContainer :networkdata="app.getTeams()" class="w-full text-lg">
        <div class="w-full text-center mb-8">
            <div class="inline-block">
                <img :src="toDataUrl(app.getTeam()?.info.logo || [])" height="150" width="150" class="rounded-xl" />
            </div>
            <div class="text-2xl mt-4 w-full">
                {{ app.getTeam()?.info.name }}
            </div>
            <div class="w-full">
                Visibility: {{ app.getTeam()?.info.listed ? 'listed' : 'unlisted' }}
            </div>
            <div class="w-full text-left">
                <b>{{ 0 }}</b> users <br>
                <b>{{ 0 }}</b> questions asked <br>
                <b>{{ 0 }}</b> answers <br>
                <b>{{ 0 }}</b> connections created <br>
            </div>
            <TextBlock>
                <h2>About:</h2>
                {{ app.getTeam()?.info.about }}
            </TextBlock>
        </div>


        <Icon v-if="app.getTeam()?.permissions.isAdmin" name="tabler:user-shield" size="2em"
            class="float-right text-green-600" />
        <Icon v-if="app.getTeam()?.permissions.isMember" name="tabler:user-check" size="2em"
            class="float-right text-green-600" />

        <Btn class="w-80">Copy invite link</Btn>
        <Btn class="w-80">Ask and answer questions</Btn>
        <Btn class="w-80">Team members</Btn>
        <Btn class="w-80">Questions</Btn>
        <Btn class="w-80">Watch demo</Btn>

    </NetworkDataContainer>
</template>