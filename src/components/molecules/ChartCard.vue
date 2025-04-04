<script setup lang="ts">
import { Line } from 'vue-chartjs'

defineProps<{
  title: string
  data: any
  options: any
}>()
</script>

<template>
  <div class="bg-white p-6 rounded-xl shadow-sm">
    <h3 class="text-lg font-medium mb-4">{{ title }}</h3>
    <div class="h-64">
      <Line :data="data" :options="options" />
    </div>
  </div>
</template>