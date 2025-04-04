<script setup lang="ts">
import { ref, onMounted } from 'vue'
import FormField from '@/components/molecules/FormField.vue'
import Button from '@/components/atoms/Button.vue'
import ImageDropzone from '@/components/molecules/ImageDropzone.vue'
import PdfUploader from '@/components/molecules/PdfUploader.vue'

const props = defineProps<{
  vehicleId: string
  loading?: boolean
  initialData?: any
}>()

const emit = defineEmits<{
  (e: 'submit', data: any): void
  (e: 'cancel'): void
}>()

const formData = ref({
  date: '',
  mileage: '',
  description: '',
  cost: '',
  garage: '',
  type: 'maintenance',
  invoices: [] as string[]
})

onMounted(() => {
  if (props.initialData) {
    formData.value = { ...props.initialData }
  }
})

const handleSubmit = () => {
  emit('submit', {
    ...formData.value,
    vehicle_id: props.vehicleId
  })
}

const handlePdfExtracted = (data: any) => {
  Object.assign(formData.value, data)
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="space-y-6">
    <!-- Bouton PDF -->
    <div class="mb-6">
      <PdfUploader
        @extracted="handlePdfExtracted"
      />
    </div>

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

    <FormField
      label="Type d'intervention"
      v-model="formData.type"
    >
      <select
        v-model="formData.type"
        class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
      >
        <option value="maintenance">Entretien régulier</option>
        <option value="repair">Réparation</option>
        <option value="other">Autre</option>
      </select>
    </FormField>

    <FormField
      label="Description"
      v-model="formData.description"
      placeholder="Décrivez l'intervention effectuée"
      required
    >
      <textarea
        v-model="formData.description"
        rows="3"
        class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
        placeholder="Décrivez l'intervention effectuée"
        required
      ></textarea>
    </FormField>

    <div class="grid grid-cols-2 gap-4">
      <FormField
        label="Coût"
        type="number"
        v-model="formData.cost"
        placeholder="ex: 150"
        required
      />
      <FormField
        label="Garage"
        v-model="formData.garage"
        placeholder="Nom du garage"
        required
      />
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-900 mb-2">Facture(s)</label>
      <ImageDropzone
        v-model="formData.invoices"
        :max-files="3"
      />
    </div>

    <div class="flex justify-end space-x-4 pt-4">
      <Button variant="secondary" @click="emit('cancel')">
        Annuler
      </Button>
      <Button type="submit" variant="primary" :loading="loading">
        {{ props.initialData ? 'Modifier' : 'Enregistrer' }}
      </Button>
    </div>
  </form>
</template>