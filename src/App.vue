<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue'
import { useAuth } from './composables/useAuth'
import { useRouter } from 'vue-router'

const router = useRouter()
const { initializeAuth, loading } = useAuth()
let cleanup: (() => void) | undefined

onMounted(async () => {
  cleanup = await initializeAuth()
})

onUnmounted(() => {
  if (cleanup) cleanup()
})
</script>

<template>
  <router-view v-if="!loading" />
  <div v-else class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-black"></div>
  </div>
</template>

<style>
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  padding: 0;
  min-height: 100vh;
  width: 100vw;
  overflow-x: hidden;
}

#app {
  width: 100%;
  min-height: 100vh;
  margin: 0;
  padding: 0;
}
</style>