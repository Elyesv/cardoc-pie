<script setup lang="ts">
defineProps<{
  title: string
  value: string | number
  unit?: string
}>()
</script>

<template>
  <div class="bg-white p-6 rounded-xl shadow-sm">
    <h3 class="text-sm font-medium text-gray-500">{{ title }}</h3>
    <p class="mt-2 text-3xl font-semibold">
      {{ value }}
      <span v-if="unit" class="text-lg text-gray-500">{{ unit }}</span>
    </p>
  </div>
</template>