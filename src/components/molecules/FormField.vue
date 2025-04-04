<script setup lang="ts">
import Label from '../atoms/Label.vue'
import Input from '../atoms/Input.vue'

defineProps<{
  label: string
  modelValue: string
  type?: string
  placeholder?: string
  required?: boolean
}>()

defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()
</script>

<template>
  <div>
    <Label :text="label" />
    <Input
      :type="type"
      :model-value="modelValue"
      @update:model-value="$emit('update:modelValue', $event)"
      :placeholder="placeholder"
      :required="required"
    />
  </div>
</template>