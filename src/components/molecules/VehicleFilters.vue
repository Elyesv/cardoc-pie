<script setup lang="ts">
import { ref } from 'vue'
import { FunnelIcon } from '@heroicons/vue/24/outline'
import { useVehicleFilters } from '@/composables/useVehicleFilters'

const props = defineProps<{
  vehicles: any[]
}>()

const showFilters = ref(false)

const {
  searchQuery,
  selectedType,
  selectedEnergy,
  sortBy,
  sortOrder,
  toggleSortOrder
} = useVehicleFilters(props.vehicles)

const vehicleTypes = [
  { id: 'all', label: 'Tous les types' },
  { id: 'car', label: 'Voitures' },
  { id: 'motorcycle', label: 'Motos' },
  { id: 'truck', label: 'Camions' },
  { id: 'van', label: 'Utilitaires' }
]

const energyTypes = [
  { id: 'all', label: 'Toutes les énergies' },
  { id: 'Essence', label: 'Essence' },
  { id: 'Diesel', label: 'Diesel' },
  { id: 'Électrique', label: 'Électrique' },
  { id: 'Hybride', label: 'Hybride' }
]

const sortOptions = [
  { id: 'date', label: 'Date d\'ajout' },
  { id: 'mileage', label: 'Kilométrage' },
  { id: 'brand', label: 'Marque' }
]
</script>

<template>
  <div class="bg-white rounded-xl shadow-sm">
    <div class="p-4">
      <div class="flex items-center gap-4">
        <div class="flex-1 relative">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Rechercher un véhicule..."
            class="w-full pl-4 pr-10 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-black focus:border-transparent"
          />
          <button
            @click="showFilters = !showFilters"
            class="absolute right-3 top-1/2 -translate-y-1/2 p-1 text-gray-400 hover:text-gray-600"
          >
            <FunnelIcon class="w-5 h-5" />
          </button>
        </div>
      </div>

      <div v-if="showFilters" class="mt-4 pt-4 border-t border-gray-200">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Type de véhicule</label>
            <select
              v-model="selectedType"
              class="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-black focus:border-transparent"
            >
              <option v-for="type in vehicleTypes" :key="type.id" :value="type.id">
                {{ type.label }}
              </option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Énergie</label>
            <select
              v-model="selectedEnergy"
              class="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-black focus:border-transparent"
            >
              <option v-for="type in energyTypes" :key="type.id" :value="type.id">
                {{ type.label }}
              </option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Trier par</label>
            <div class="flex space-x-2">
              <select
                v-model="sortBy"
                class="flex-1 px-3 py-2 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-black focus:border-transparent"
              >
                <option v-for="option in sortOptions" :key="option.id" :value="option.id">
                  {{ option.label }}
                </option>
              </select>
              <button
                @click="toggleSortOrder"
                class="px-3 py-2 border border-gray-200 rounded-lg hover:bg-gray-50"
                :title="sortOrder === 'asc' ? 'Ordre croissant' : 'Ordre décroissant'"
              >
                <svg
                  class="w-5 h-5"
                  :class="{ 'rotate-180': sortOrder === 'desc' }"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 4h13M3 8h9M3 12h5"
                  />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>