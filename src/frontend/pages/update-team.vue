<script lang="ts" setup>

definePageMeta({
    title: "Welcome",
    layout: 'default'
});

const app = useAppState();
const team = useState("team", () => "");
const name = useState("team-name", () => "");
const about = useState("team-about", () => "");
const invite = useState("invite-code", () => "");
const logo = useState("team-logo", (): number[] => []);
const listed = useState("team-listed", () => true);
const loading = useState("loading", () => true);
loading.value = false;

if (inBrowser()) {
    app.getTeam();
    app.loadUser(0);
    app.loadTeams(0);
    app.loadPrincipal(0);
}

const update = () => {
    loading.value = true;
    app.updateTeam(
        team.value,
        name.value,
        about.value,
        logo.value.slice(),
        listed.value,
        invite.value,
    ).then(() => {
        const params = new URLSearchParams({ invite: invite.value });
        navTo("/join/" + team.value + "?" + params.toString())
    }).finally(
        () => loading.value = false
    );
}

let teamLoaded = false;
const loadTeam = () => {
    if (teamLoaded) return true;
    const t = app.getTeam();
    if (t) {
        team.value = t.key;
        name.value = t.info.name;
        about.value = t.info.about;
        logo.value = t.info.logo as number[];
        listed.value = t.info.listed;
        loading.value = false;
        invite.value = t.invite + "";
        // draw image preview to canvas
        setTimeout(() => {
            drawImage(toDataUrl(t.info.logo), false);
        }, 200);
        return true;
    }
    return false;
}

const drawImage = (dataUrl: string, store: boolean = true) => {
    var canvas = document.getElementById('logoPreview') as HTMLCanvasElement;
    var ctx = canvas.getContext('2d');
    const img = new Image();
    img.onload = () => {
        const scaleFactor = Math.min(canvas.width / img.width, canvas.height / img.height);
        const newWidth = img.width * scaleFactor;
        const newHeight = img.height * scaleFactor;
        // Draw the image on the canvas
        ctx?.clearRect(0, 0, canvas.width, canvas.height);
        ctx?.drawImage(
            img,
            (canvas.width - newWidth) / 2,
            (canvas.height - newHeight) / 2,
            newWidth, newHeight
        );

        if (store) {
            canvas.toBlob((blob) => {
                blob?.arrayBuffer().then(
                    (v) => logo.value = [...new Uint8Array(v)]
                )
            }, "image/png")
        }
    };

    // Set the source of the image to the loaded data URL
    img.src = dataUrl;
}

const setFile = async (e: any) => {
    const file = e.target.files[0];

    if (file) {
        const reader = new FileReader();
        var canvas = document.getElementById('logoPreview') as HTMLCanvasElement;
        var ctx = canvas.getContext('2d');


        reader.onload = (e) => {
            // Set the source of the image to the loaded data URL
            drawImage(e.target?.result as string, true);
        };

        // Read the file as a data URL
        reader.readAsDataURL(file);
    }
}

</script>

<template>
    <div class="w-full flex-grow flex flex-col">
        <AllkindsTitle link-to="/select-team"><span /></AllkindsTitle>
        <h1 class="self-center">Update a team</h1>

        <NetworkDataContainer v-if="loadTeam()" :networkdata="app.getUser()" class="w-full flex-grow flex flex-col">
            <div v-if="app.getUser().data?.permissions.createTeam === false" class="w-full text-center mb-8 text-lg">
                You don't have permissions to create a new team. <br>
                Ask an admin to grant permissions to your user ID: <b>{{ app.getUser().data?.user.username }}</b> <br>.
            </div>

            <div class="p-4 rounded-lg my-2 w-full">

                <div class="text-xl">
                    Team name
                    <TextInput v-model.trim="name" class="w-full mt-2" />
                </div>

                <div class="mt-4">
                    Logo (square .png image, max. size 1MB)

                    <canvas id="logoPreview" width="512" height="512" style="width: 64px; height: 64px;"></canvas>
                    <input class="mt-2" type="file" @change="setFile" />
                    {{ Math.round(logo.length / 1000) }} kb
                </div>

                <p class="mt-4">
                    About the team
                    <TextArea v-model.trim="about" class="w-full mt-2" />
                </p>
                <p class="mt-4">
                    Team handle (can't be changed)
                <div class="w-full mt-2 text-lg p-4">{{ team }}</div>
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
                <Btn v-if="loading">
                    <Icon name="line-md:loading-alt-loop" />
                </Btn>
                <Btn v-else @click="update()">Update team</Btn>
            </div>
            <div class="w-2 flex-grow"></div>
        </NetworkDataContainer>
    </div>
</template>
