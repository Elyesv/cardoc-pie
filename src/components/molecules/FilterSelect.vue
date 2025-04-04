<script setup lang="ts">
import Select from '../atoms/Select.vue'

defineProps<{
  modelValue: string
  options: Array<{
    value: string
    label: string
  }>
  label?: string
}>()

defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()
</script>

<template>
  <div class="space-y-2">
    <label v-if="label" class="block text-sm font-medium text-gray-700">
      {{ label }}
    </label>
    <Select
      :model-value="modelValue"
      :options="options"
      @update:model-value="$emit('update:modelValue', $event)"
    />
  </div>
</template>