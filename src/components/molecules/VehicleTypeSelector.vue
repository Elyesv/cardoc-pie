<script setup lang="ts">
const props = defineProps<{
  modelValue: string
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()

const vehicleTypes = [
  { id: 'car', label: 'Voiture', icon: '🚗' },
  { id: 'motorcycle', label: 'Moto', icon: '🏍' },
  { id: 'truck', label: 'Camion', icon: '🚛' },
  { id: 'van', label: 'Utilitaire', icon: '🚐' }
]

const selectType = (type: string) => {
  emit('update:modelValue', type)
  emit('selected')
}
</script>

<template>
  <div class="grid grid-cols-2 gap-4">
    <button
      v-for="type in vehicleTypes"
      :key="type.id"
      @click="selectType(type.id)"
      :class="[
        'p-6 rounded-xl border-2 text-left transition-colors',
        modelValue === type.id
          ? 'border-black bg-gray-50'
          : 'border-gray-200 hover:border-gray-300'
      ]"
    >
      <span class="text-4xl mb-4 block">{{ type.icon }}</span>
      <h3 class="font-medium text-lg">{{ type.label }}</h3>
    </button>
  </div>
</template>