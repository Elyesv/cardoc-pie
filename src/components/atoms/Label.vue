<script setup lang="ts">
defineProps<{
  text: string
}>()
</script>

<template>
  <label class="block text-sm font-medium text-gray-900 mb-2">{{ text }}</label>
</template>