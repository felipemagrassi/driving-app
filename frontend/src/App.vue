<script setup lang="ts">
import axios from "axios"
const input: any = {
  name: "",
  email: "",
  cpf: '',
  isDriver: false,
  isPassenger: true
}

function signup() {
  axios.post("http://localhost:4567/signup", input)
}

</script>

<template>
  <h1 class="signup-title">
    Signup
  </h1>

  <input class="signup-name" type="text" v-model="input.name" />
  <input class="signup-email" type="text" v-model="input.email" />
  <input class="signup-cpf" type="text" v-model="input.cpf" />
  <input class="signup-is-passenger" type="checkbox" v-model="input.isPassenger" />
  <input class="signup-is-driver" type="checkbox" v-model="input.isDriver" />

  <button class='signup-submit' type='submit' @click="signup()"> Submit </button>
</template>

<style scoped>
.logo {
  height: 6em;
  padding: 1.5em;
  will-change: filter;
  transition: filter 300ms;
}

.logo:hover {
  filter: drop-shadow(0 0 2em #646cffaa);
}

.logo.vue:hover {
  filter: drop-shadow(0 0 2em #42b883aa);
}
</style>
