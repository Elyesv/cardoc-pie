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
  title: '',
  description: '',
  dueDate: '',
  dueMileage: '',
  priority: 'medium',
  status: 'pending'
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
    <FormField
      label="Titre"
      v-model="formData.title"
      placeholder="ex: Vidange à faire"
      required
    />

    <FormField
      label="Description"
      v-model="formData.description"
      placeholder="Détails du rappel"
    >
      <textarea
        v-model="formData.description"
        rows="3"
        class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
        placeholder="Détails du rappel"
      ></textarea>
    </FormField>

    <div class="grid grid-cols-2 gap-4">
      <FormField
        label="Date prévue"
        type="date"
        v-model="formData.dueDate"
        required
      />
      <FormField
        label="Kilométrage prévu"
        type="number"
        v-model="formData.dueMileage"
        placeholder="ex: 60000"
      />
    </div>

    <FormField
      label="Priorité"
      v-model="formData.priority"
    >
      <select
        v-model="formData.priority"
        class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
        required
      >
        <option value="low">Basse</option>
        <option value="medium">Moyenne</option>
        <option value="high">Haute</option>
      </select>
    </FormField>

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