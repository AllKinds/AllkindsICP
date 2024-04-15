<script lang="ts" setup>

definePageMeta({
    title: "Allkinds",
    footerMenu: false,
});

const app = useAppState();


if (inBrowser()) {
    app.getTeam();
    app.loadTeams();
    app.loadUser(0);
}

</script>

<template>
    <div class="w-full flex-grow flex flex-col">

        <div class="chat-messages flex-grow flex flex-col-reverse font-light h-20 overflow-y-auto scrollbar">
            <div class="chat-message chat-other">
                Answer form someone
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
            <div class="chat-message chat-self">
                Test message from myself
                <div class="text-sm font-light w-full text-right">14:30</div>
            </div>
        </div>

        <div class="w-full flex flex-row bg-slate-900 p-2">
            <TextInput placeholder="Message" class="flex-grow rounded-full py-1 m-1" />
            <Icon name="lucide:send" size="2em" class="m-4" />
        </div>
    </div>
</template>
