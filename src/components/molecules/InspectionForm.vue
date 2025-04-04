<script setup lang="ts">
import { ref } from 'vue'
import FormField from '@/components/molecules/FormField.vue'
import Button from '@/components/atoms/Button.vue'
import ImageDropzone from '@/components/molecules/ImageDropzone.vue'

const props = defineProps<{
  vehicleId: string
  loading?: boolean
}>()

const emit = defineEmits<{
  (e: 'submit', data: any): void
  (e: 'cancel'): void
}>()

const formData = ref({
  date: '',
  expiryDate: '',
  mileage: '',
  center: '',
  cost: '',
  status: 'pass',
  notes: '',
  documents: [] as string[]
})

const handleSubmit = () => {
  emit('submit', {
    vehicle_id: props.vehicleId,
    date: formData.value.date,
    expiry_date: formData.value.expiryDate,
    mileage: parseInt(formData.value.mileage),
    center: formData.value.center,
    cost: parseFloat(formData.value.cost),
    status: formData.value.status,
    notes: formData.value.notes
  })
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="space-y-6">
    <div class="grid grid-cols-2 gap-4">
      <FormField
        label="Date du contrôle"
        type="date"
        v-model="formData.date"
        required
      />
      <FormField
        label="Date d'expiration"
        type="date"
        v-model="formData.expiryDate"
        required
      />
    </div>

    <div class="grid grid-cols-2 gap-4">
      <FormField
        label="Kilométrage"
        type="number"
        v-model="formData.mileage"
        placeholder="ex: 50000"
        required
      />
      <FormField
        label="Centre de contrôle"
        v-model="formData.center"
        placeholder="ex: Autovision"
        required
      />
    </div>

    <div class="grid grid-cols-2 gap-4">
      <FormField
        label="Coût"
        type="number"
        step="0.01"
        v-model="formData.cost"
        placeholder="ex: 80"
        required
      />
      <FormField
        label="Résultat"
        v-model="formData.status"
      >
        <select
          v-model="formData.status"
          class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
          required
        >
          <option value="pass">Validé</option>
          <option value="fail">Refusé</option>
          <option value="conditional_pass">Contre-visite</option>
        </select>
      </FormField>
    </div>

    <FormField
      label="Notes"
      v-model="formData.notes"
      placeholder="Points à surveiller, réparations à prévoir..."
    >
      <textarea
        v-model="formData.notes"
        rows="3"
        class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
      ></textarea>
    </FormField>

    <div>
      <label class="block text-sm font-medium text-gray-900 mb-2">Documents</label>
      <ImageDropzone
        v-model="formData.documents"
        :max-files="3"
      />
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