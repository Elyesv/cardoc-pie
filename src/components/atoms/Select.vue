<script setup lang="ts">
defineProps<{
  modelValue: string
  options: Array<{
    value: string
    label: string
  }>
  placeholder?: string
  required?: boolean
}>()

defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()
</script>

<template>
  <select
    :value="modelValue"
    @input="$emit('update:modelValue', ($event.target as HTMLSelectElement).value)"
    :required="required"
    class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-black focus:border-transparent"
  >
    <option v-if="placeholder" value="">{{ placeholder }}</option>
    <option
      v-for="option in options"
      :key="option.value"
      :value="option.value"
    >
      {{ option.label }}
    </option>
  </select>
</template>