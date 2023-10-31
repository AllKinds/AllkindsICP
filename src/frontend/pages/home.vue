<script type="ts" setup>
function resize(el) {
    const t = el.target;
    t.style.height = "auto";
    const border = t.style.borderTopWidth * 2;
    const height = el.target.scrollHeight;
    const total = border + height + 2;
    el.target.style.setProperty('height', (total) + 'px');
}
const asdf = useState('asdf', () => "")
</script>

<template>
  <div class="p-5 w-full max-w-xl">
    <TextArea
      style="min-height: 1em !important"
      v-model="asdf"
      placeholder="Ask a Yes/No question…"
    ></TextArea>
  </div>
</template>
