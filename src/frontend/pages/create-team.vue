<script lang="ts" setup>
import { fileURLToPath } from 'url';


definePageMeta({ title: "Welcome" });
const app = useAppState();
const team = useState("team", () => "");
const name = useState("team-name", () => "");
const about = useState("team-about", () => "");
const invite = useState("invite-code", () => "");
const logo = useState("team-logo", (): number[] => []);
const listed = useState("team-listed", () => true);

if (inBrowser()) {
    app.loadTeams(0)
    app.loadPrincipal(0)
}

const create = () => {
    app.createTeam(
        team.value,
        name.value,
        about.value,
        logo.value.slice(),
        listed.value,
        invite.value,
    ).then(() => { navigateTo("/welcome") });
}


const setFile = async (e: any) => {
    const file = e.target.files[0];
    const tooBig = file.size > 1000500;
    const wrongType = file.type !== "image/png";
    if (tooBig || wrongType) {
        addNotification("error", tooBig ? "File is too large" : "File is not a .png image")
        logo.value = [];
        e.target.value = null;
        return false;
    }

    logo.value = [...new Uint8Array(await file.slice().arrayBuffer())];
}

</script>

<template>
    <AllkindsTitle link-to="/welcome">Allkinds.teams</AllkindsTitle>
    <TextBlock>
        <h1>Create a team</h1>
    </TextBlock>

    <NetworkDataContainer :networkdata="app.getPrincipal()" class="w-full flex-grow flex flex-col">
        <div class="w-full text-center mb-8 text-lg">
            Principal <br><b>{{ app.getPrincipal().data?.toText() }}</b> <br> must be set as an admin to create new teams.
        </div>

        <div class="p-4 rounded-lg my-2 w-full">

            <div class="text-xl">
                Team name
                <TextInput v-model.trim="name" class="w-full mt-2" />
            </div>

            <div class="mt-4">
                Logo (.png image, max. size 1MB)

                <input class="mt-2" type="file" @change="setFile" />
                {{ Math.round(logo.length / 1000) }} kb
            </div>

            <p class="mt-4">
                About the team
                <TextArea v-model:trim="about" class="w-full mt-2" />
            </p>
            <p class="mt-4">
                Team handle (must only contain lower case letters)
                <TextInput v-model.trim="team" class="w-full mt-2" />
            </p>

            <p class="mt-4">
                Invite code
                <TextInput v-model.trim="invite" class="w-full mt-2" />
            </p>

            <p class="mt-4">
                Listed (publicly show that team exists)

            <div class="w-full text-center mt-2 cursor-pointer">
                <NuxtLink class="text-xl" @click="listed = !listed">
                    Listed
                    <Icon v-if="listed" name="tabler:checkbox" />
                    <Icon v-else name="ci:checkbox-unchecked" />
                </NuxtLink>
            </div>
            </p>


        </div>

        <div class="w-2 flex-grow"></div>

        <div class="text-center w-full">
            <Btn @click="create()">Create team</Btn>
        </div>
        <div class="w-2 flex-grow"></div>
    </NetworkDataContainer>
</template>
