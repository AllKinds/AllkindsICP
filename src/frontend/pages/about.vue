<script lang="ts" setup>
definePageMeta({
    title: "About",
    layout: 'default'
});

const app = useAppState();

if (inBrowser()) {
    //app.loadUser(0, false);
}

</script>

<template>
    <div class="w-full flex-grow flex flex-col items-center">
        <AllkindsTitle class="py-16" />

        <div class="p-8 max-w-md">
            <div class="text-xl">
                Allkinds is a web3 social network.
                <br><br>
                    It allows people to discover like-minded individuals by anonymously asking each other yes/no questions and comparing answers. 
                <br><br>
                    At the moment an MVP is launched.
                <br> 
                    We are testing the service with several groups of people.
                <br><br>
                    Read the full description of the project&nbsp;here: 

                <a class="link" target="_blank" href="https://github.com/AllKinds/AllkindsICP/wiki/Allkinds">
                    github.com/AllKinds/AllkindsICP/wiki
                </a>
            </div>
        </div>

        <div class="grow" />

        <Btn to="/">Close</Btn>

        <ICFooter />
    </div>
</template
