<script setup lang="ts">
import FilterSelect from '../molecules/FilterSelect.vue'

defineProps<{
  vehicles: any[]
  selectedVehicle: string
}>()

defineEmits<{
  (e: 'update:selectedVehicle', value: string): void
}>()

const vehicleOptions = computed(() => [
  { value: 'all', label: 'Tous les véhicules' },
  ...vehicles.map(v => ({
    value: v.id,
    label: `${v.brand} ${v.model} - ${v.license_plate}`
  }))
])
</script>

<template>
  <div class="bg-white p-4 rounded-xl shadow-sm">
    <div class="flex items-center space-x-4">
      <FilterSelect
        :model-value="selectedVehicle"
        :options="vehicleOptions"
        @update:model-value="$emit('update:selectedVehicle', $event)"
      />
    </div>
  </div>
</template>