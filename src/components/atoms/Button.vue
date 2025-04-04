<script setup lang="ts">
defineProps<{
  type?: 'submit' | 'button'
  variant?: 'primary' | 'secondary'
  disabled?: boolean
  loading?: boolean
}>()
</script>

<template>
  <button
    :type="type || 'button'"
    :disabled="disabled || loading"
    :class="[
      'py-3 px-4 rounded-lg font-medium transition-colors w-full',
      variant === 'primary' 
        ? 'bg-black text-white hover:bg-gray-900' 
        : 'bg-white border border-gray-200 text-gray-700 hover:bg-gray-50'
    ]"
  >
    <slot></slot>
  </button>
</template>