<script setup lang="ts">
defineProps<{
  type?: string
  placeholder?: string
  required?: boolean
  modelValue: string
}>()

defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()
</script>

<template>
  <input
    :type="type || 'text'"
    :value="modelValue"
    @input="$emit('update:modelValue', ($event.target as HTMLInputElement).value)"
    :required="required"
    :placeholder="placeholder"
    class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
  />
</template>