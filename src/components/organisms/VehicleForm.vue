<script setup lang="ts">
import { useVehicleForm } from '@/composables/useVehicleForm'
import StepProgress from '@/components/molecules/StepProgress.vue'
import VehicleTypeSelector from '@/components/molecules/VehicleTypeSelector.vue'
import FormField from '@/components/molecules/FormField.vue'
import Button from '@/components/atoms/Button.vue'
import ImageDropzone from '@/components/molecules/ImageDropzone.vue'

const props = defineProps<{
  loading?: boolean
}>()

const emit = defineEmits<{
  (e: 'submit', data: any): void
  (e: 'cancel'): void
}>()

const {
  formData,
  currentStep,
  steps,
  progress,
  canGoNext,
  onTypeSelected,
  goToNextStep,
  goToPreviousStep,
  reset
} = useVehicleForm()

const handleSubmit = () => {
  emit('submit', formData.value)
  reset()
}
</script>

<template>
  <div class="flex h-screen">
    <StepProgress
      :steps="steps"
      :current-step="currentStep"
      :progress="progress"
    />

    <div class="flex-1 p-8">
      <div class="max-w-2xl mx-auto">
        <form @submit.prevent="handleSubmit" class="space-y-6">
          <!-- Step 1: Vehicle Type -->
          <div v-if="currentStep === 0">
            <VehicleTypeSelector
              v-model="formData.type"
              @selected="onTypeSelected"
            />
          </div>

          <!-- Step 2: Basic Information -->
          <div v-if="currentStep === 1" class="space-y-6">
            <FormField
              label="Plaque d'immatriculation"
              v-model="formData.licensePlate"
              placeholder="AB-123-CD"
              required
            />
            <FormField
              label="Nom du véhicule"
              v-model="formData.vehicleName"
              placeholder="Mon véhicule"
            />
            <div class="grid grid-cols-2 gap-4">
              <FormField
                label="Marque"
                v-model="formData.brand"
                placeholder="ex: Renault"
                required
              />
              <FormField
                label="Modèle"
                v-model="formData.model"
                placeholder="ex: Clio"
                required
              />
            </div>
          </div>

          <!-- Step 3: Technical Details -->
          <div v-if="currentStep === 2" class="space-y-6">
            <FormField
              label="Kilométrage"
              v-model="formData.mileage"
              type="number"
              placeholder="ex: 50000"
              required
            />
            <FormField
              label="Couleur"
              v-model="formData.color"
              placeholder="ex: Noir"
              required
            />
            <FormField
              label="Énergie"
              v-model="formData.energy"
              placeholder="ex: Essence"
              required
            />
          </div>

          <!-- Step 4: History -->
          <div v-if="currentStep === 3" class="space-y-6">
            <FormField
              label="Date de première mise en circulation"
              v-model="formData.dateOfFirstRegistration"
              type="date"
              required
            />
            <FormField
              label="Date d'achat"
              v-model="formData.dateOfPurchase"
              type="date"
              required
            />
            <FormField
              label="Nombre de propriétaires"
              v-model="formData.numberOfOwners"
              type="number"
              placeholder="ex: 2"
              required
            />
          </div>

          <!-- Step 5: Images -->
          <div v-if="currentStep === 4">
            <ImageDropzone
              v-model="formData.images"
              :max-files="5"
            />
          </div>

          <!-- Navigation buttons -->
          <div class="flex justify-between pt-6">
            <Button
              variant="secondary"
              @click="currentStep === 0 ? emit('cancel') : goToPreviousStep()"
            >
              {{ currentStep === 0 ? 'Annuler' : 'Précédent' }}
            </Button>
            
            <Button
              variant="primary"
              :disabled="!canGoNext"
              @click="currentStep === steps.length - 1 ? handleSubmit() : goToNextStep()"
              :loading="loading"
            >
              {{ currentStep === steps.length - 1 ? 'Terminer' : 'Suivant' }}
            </Button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>