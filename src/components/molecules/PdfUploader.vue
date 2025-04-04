<script setup lang="ts">
import { ref } from 'vue'
import Button from '@/components/atoms/Button.vue'

const emit = defineEmits<{
  (e: 'extracted', data: {
    date?: string
    mileage?: string
    cost?: string
    garage?: string
    description?: string
  }): void
  (e: 'error', message: string): void
}>()

const processingPdf = ref(false)
const fileInput = ref<HTMLInputElement | null>(null)
const error = ref<string | null>(null)

const handleFileSelect = async (event: Event) => {
  const input = event.target as HTMLInputElement
  if (input.files && input.files[0]) {
    const file = input.files[0]
    if (file.type === 'application/pdf') {
      try {
        processingPdf.value = true
        error.value = null

        // Simuler l'extraction des données
        // Dans une version future, on pourrait implémenter une vraie extraction
        const mockData = {
          date: new Date().toISOString().split('T')[0],
          mileage: '',
          cost: '',
          garage: '',
          description: ''
        }

        emit('extracted', mockData)
      } catch (err: any) {
        const errorMessage = err.message || 'Une erreur est survenue lors du traitement du PDF'
        error.value = errorMessage
        emit('error', errorMessage)
      } finally {
        processingPdf.value = false
      }
    } else {
      const errorMessage = 'Veuillez sélectionner un fichier PDF'
      error.value = errorMessage
      emit('error', errorMessage)
    }
  }
}
</script>

<template>
  <div>
    <Button
      variant="secondary"
      class="w-full"
      @click="fileInput?.click()"
      :disabled="processingPdf"
    >
      <div class="flex items-center justify-center space-x-2">
        <span v-if="!processingPdf">Analyser une facture PDF</span>
        <div v-else class="flex items-center space-x-2">
          <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-black"></div>
          <span>Analyse en cours...</span>
        </div>
      </div>
    </Button>
    <input
      ref="fileInput"
      type="file"
      accept="application/pdf"
      class="hidden"
      @change="handleFileSelect"
    >
    <p class="mt-2 text-sm text-gray-500 text-center">
      Formats acceptés : PDF uniquement
    </p>
    <p v-if="error" class="mt-2 text-sm text-red-600 text-center">
      {{ error }}
    </p>
  </div>
</template>