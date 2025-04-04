<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const props = defineProps<{
  to: string
  icon: any
  label: string
}>()

const route = useRoute()
const isActive = computed(() => route.path === props.to)
</script>

<template>
  <router-link
    :to="to"
    :class="[
      'flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors',
      isActive ? 'bg-black text-white' : 'text-gray-600 hover:bg-gray-100'
    ]"
  >
    <component :is="icon" class="w-5 h-5" />
    <span class="font-medium">{{ label }}</span>
  </router-link>
</template>