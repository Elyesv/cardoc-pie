<script setup lang="ts">
import { computed } from 'vue'
import { WrenchIcon, DocumentIcon, PencilIcon, TrashIcon } from '@heroicons/vue/24/outline'

const props = defineProps<{
  maintenances: Array<{
    id: string
    date: string
    mileage: number
    description: string
    cost: number
    garage: string
    type: string
    invoices: string[]
  }>
}>()

const emit = defineEmits<{
  (e: 'edit', maintenance: any): void
  (e: 'delete', id: string): void
}>()

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const formatType = (type: string) => {
  switch (type) {
    case 'maintenance':
      return 'Entretien régulier'
    case 'repair':
      return 'Réparation'
    default:
      return 'Autre'
  }
}

const sortedMaintenances = computed(() => {
  return [...props.maintenances].sort((a, b) => 
    new Date(b.date).getTime() - new Date(a.date).getTime()
  )
})
</script>

<template>
  <div class="space-y-6">
    <div v-if="maintenances.length === 0" class="text-center py-8 bg-gray-50 rounded-lg">
      <WrenchIcon class="w-12 h-12 mx-auto text-gray-400" />
      <h3 class="mt-4 text-lg font-medium text-gray-900">Aucun entretien</h3>
      <p class="mt-1 text-sm text-gray-500">Commencez par ajouter votre premier entretien.</p>
    </div>

    <div v-else class="space-y-4">
      <div
        v-for="maintenance in sortedMaintenances"
        :key="maintenance.id"
        class="bg-white rounded-lg border border-gray-100 p-4 hover:shadow-md transition-shadow"
      >
        <div class="flex justify-between items-start mb-4">
          <div>
            <div class="flex items-center space-x-2">
              <span class="text-sm font-medium text-gray-900">{{ formatDate(maintenance.date) }}</span>
              <span class="text-sm text-gray-500">•</span>
              <span class="text-sm text-gray-500">{{ maintenance.mileage.toLocaleString() }} km</span>
            </div>
            <div class="mt-1">
              <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                :class="{
                  'bg-blue-100 text-blue-800': maintenance.type === 'maintenance',
                  'bg-red-100 text-red-800': maintenance.type === 'repair',
                  'bg-gray-100 text-gray-800': maintenance.type === 'other'
                }"
              >
                {{ formatType(maintenance.type) }}
              </span>
            </div>
          </div>
          <div class="flex items-center space-x-2">
            <span class="text-lg font-medium">{{ maintenance.cost.toLocaleString() }} €</span>
            <button
              @click="emit('edit', maintenance)"
              class="p-1 text-gray-400 hover:text-gray-600 transition-colors"
              title="Modifier"
            >
              <PencilIcon class="w-4 h-4" />
            </button>
            <button
              @click="emit('delete', maintenance.id)"
              class="p-1 text-gray-400 hover:text-red-600 transition-colors"
              title="Supprimer"
            >
              <TrashIcon class="w-4 h-4" />
            </button>
          </div>
        </div>

        <p class="text-gray-600 mb-4">{{ maintenance.description }}</p>

        <div class="flex justify-between items-center text-sm">
          <span class="text-gray-500">{{ maintenance.garage }}</span>
          
          <div class="flex items-center space-x-2" v-if="maintenance.invoices?.length">
            <a
              v-for="(invoice, index) in maintenance.invoices"
              :key="index"
              :href="invoice"
              target="_blank"
              class="inline-flex items-center text-gray-600 hover:text-gray-900"
            >
              <DocumentIcon class="w-4 h-4 mr-1" />
              <span>Facture {{ maintenance.invoices.length > 1 ? index + 1 : '' }}</span>
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>