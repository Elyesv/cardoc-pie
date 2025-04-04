<script setup lang="ts">
import { ref } from 'vue'
import FormField from './FormField.vue'
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
  task_name: '',
  kilometers: '',
  months: '',
  description: ''
})

const handleSubmit = () => {
  emit('submit', {
    ...formData.value,
    vehicle_id: props.vehicleId,
    kilometers: parseInt(formData.value.kilometers),
    months: parseInt(formData.value.months)
  })
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="space-y-6">
    <FormField
      label="Nom de la tâche"
      v-model="formData.task_name"
      placeholder="ex: Vidange"
      required
    />

    <div class="grid grid-cols-2 gap-4">
      <FormField
        label="Kilométrage"
        type="number"
        v-model="formData.kilometers"
        placeholder="ex: 15000"
      />
      <FormField
        label="Mois"
        type="number"
        v-model="formData.months"
        placeholder="ex: 12"
      />
    </div>

    <FormField
      label="Description"
      v-model="formData.description"
      placeholder="Description de la tâche d'entretien"
    >
      <textarea
        v-model="formData.description"
        rows="3"
        class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
        placeholder="Description de la tâche d'entretien"
      ></textarea>
    </FormField>

    <div class="flex justify-end space-x-4">
      <Button variant="secondary" @click="emit('cancel')">
        Annuler
      </Button>
      <Button type="submit" variant="primary" :loading="loading">
        Enregistrer
      </Button>
    </div>
  </form>
</template>