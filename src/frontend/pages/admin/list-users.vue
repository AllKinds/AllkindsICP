<script lang="ts" setup>
const app = getAppState();

if (inBrowser()) {
  app.users.load();
  app.user.load();
}
</script>

<template>
  <div>
    <AllkindsTitle>Users</AllkindsTitle>
    <h1>You</h1>
    <NetworkDataContainer :networkdata="app.user.get()">
      {{ app.user.get().data?.user.displayName }}
      ({{ app.user.get().data?.user.username }})
      <pre>{{ JSON.stringify(app.user.get().data?.permissions, undefined, 2) }}
            </pre>
    </NetworkDataContainer>

    <h1>All users</h1>
    <NetworkDataContainer :networkdata="app.users.get()">
      <div>
        Number of registered users: {{ app.users.get().data?.length }}
      </div>
      <table class="table text-lg">
        <tr>
          <th>Name</th>
          <th>Key</th>
          <th>Contact</th>
          <th>
            <Icon name="gg:shape-hexagon" />
          </th>
          <th>Q</th>
          <th>A</th>
          <th>+</th>
          <th>Notifications</th>
        </tr>
        <tr v-for="{ user, notifications } in app.users.get().data" class="hover:bg-slate-900">
          <td>{{ user.displayName }}</td>
          <td>{{ user.username }}</td>
          <td>{{ user.contact }}</td>
          <td>{{ user.stats.points }}</td>
          <td>{{ user.stats.asked }}</td>
          <td>{{ user.stats.answered }}</td>
          <td>{{ user.stats.boosts }}</td>
          <td>{{ JSON.stringify(notifications, (_, v) => typeof v === 'bigint' ? v.toString() : v) }}</td>
        </tr>
      </table>
    </NetworkDataContainer>
  </div>
</template>