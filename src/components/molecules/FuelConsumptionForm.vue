<script setup lang="ts">
import { ref } from 'vue'
import FormField from '../atoms/FormField.vue'
import Button from '../atoms/Button.vue'

const props = defineProps<{
  vehicleId: string
  loading?: boolean
}>()

const emit = defineEmits<{
  (e: 'submit', data: any): void
  (e: 'cancel'): void
}>()

const formData = ref({
  date: new Date().toISOString().split('T')[0],
  mileage: '',
  quantity: '',
  cost: '',
  fuelType: '',
  station: '',
  fullTank: true
})

const handleSubmit = () => {
  emit('submit', {
    ...formData.value,
    vehicle_id: props.vehicleId
  })
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="space-y-6">
    <div class="grid grid-cols-2 gap-4">
      <FormField
        label="Date"
        type="date"
        v-model="formData.date"
        required
      />
      <FormField
        label="Kilométrage"
        type="number"
        v-model="formData.mileage"
        placeholder="ex: 50000"
        required
      />
    </div>

    <div class="grid grid-cols-2 gap-4">
      <FormField
        label="Quantité (L)"
        type="number"
        step="0.01"
        v-model="formData.quantity"
        placeholder="ex: 45.5"
        required
      />
      <FormField
        label="Coût total (€)"
        type="number"
        step="0.01"
        v-model="formData.cost"
        placeholder="ex: 85.50"
        required
      />
    </div>

    <FormField
      label="Type de carburant"
      v-model="formData.fuelType"
    >
      <select
        v-model="formData.fuelType"
        class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
        required
      >
        <option value="SP95">SP95</option>
        <option value="SP98">SP98</option>
        <option value="E10">E10</option>
        <option value="E85">E85</option>
        <option value="Diesel">Diesel</option>
      </select>
    </FormField>

    <FormField
      label="Station"
      v-model="formData.station"
      placeholder="ex: Total"
    />

    <div class="flex items-center space-x-2">
      <input
        type="checkbox"
        id="fullTank"
        v-model="formData.fullTank"
        class="rounded border-gray-300 text-black focus:ring-black"
      />
      <label for="fullTank" class="text-sm text-gray-700">Plein complet</label>
    </div>

    <div class="flex justify-end space-x-4 pt-4">
      <Button variant="secondary" @click="emit('cancel')">
        Annuler
      </Button>
      <Button type="submit" variant="primary" :loading="loading">
        Enregistrer
      </Button>
    </div>
  </form>
</template>