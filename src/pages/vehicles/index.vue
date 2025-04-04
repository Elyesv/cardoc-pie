<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { PlusIcon, ListBulletIcon, Squares2X2Icon, FunnelIcon } from '@heroicons/vue/24/outline'
import Navbar from '@/components/organisms/Navbar.vue'
import VehicleCard from '@/components/molecules/VehicleCard.vue'
import Button from '@/components/atoms/Button.vue'
import { useVehicle } from '@/composables/useVehicle'

const router = useRouter()
const { vehicles, loading, fetchVehicles } = useVehicle()
const searchQuery = ref('')
const selectedType = ref('all')
const selectedEnergy = ref('all')
const viewMode = ref<'grid' | 'list'>('grid')
const sortBy = ref<'date' | 'mileage' | 'brand'>('date')
const sortOrder = ref<'asc' | 'desc'>('desc')
const showFilters = ref(false)

// Types de véhicules
const vehicleTypes = [
  { id: 'all', label: 'Tous les types' },
  { id: 'car', label: 'Voitures' },
  { id: 'motorcycle', label: 'Motos' },
  { id: 'truck', label: 'Camions' },
  { id: 'van', label: 'Utilitaires' }
]

// Types d'énergie
const energyTypes = [
  { id: 'all', label: 'Toutes les énergies' },
  { id: 'Essence', label: 'Essence' },
  { id: 'Diesel', label: 'Diesel' },
  { id: 'Électrique', label: 'Électrique' },
  { id: 'Hybride', label: 'Hybride' }
]

// Options de tri
const sortOptions = [
  { id: 'date', label: 'Date d\'ajout' },
  { id: 'mileage', label: 'Kilométrage' },
  { id: 'brand', label: 'Marque' }
]

// Véhicules filtrés et triés
const filteredVehicles = computed(() => {
  let filtered = [...vehicles.value]

  // Filtre par type
  if (selectedType.value !== 'all') {
    filtered = filtered.filter(v => v.type === selectedType.value)
  }

  // Filtre par énergie
  if (selectedEnergy.value !== 'all') {
    filtered = filtered.filter(v => v.energy === selectedEnergy.value)
  }

  // Filtre par recherche
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(v => 
      v.brand.toLowerCase().includes(query) ||
      v.model.toLowerCase().includes(query) ||
      v.license_plate.toLowerCase().includes(query)
    )
  }

  // Tri
  filtered.sort((a, b) => {
    let comparison = 0
    switch (sortBy.value) {
      case 'date':
        comparison = new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
        break
      case 'mileage':
        comparison = b.mileage - a.mileage
        break
      case 'brand':
        comparison = a.brand.localeCompare(b.brand)
        break
    }
    return sortOrder.value === 'desc' ? comparison : -comparison
  })

  return filtered
})

const toggleSortOrder = () => {
  sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
}

const handleAddClick = () => {
  router.push('/vehicles/add')
}

onMounted(fetchVehicles)
</script>

<template>
  <div class="flex min-h-screen bg-gray-50">
    <Navbar />
    
    <main class="flex-1 p-8">
      <div class="max-w-7xl mx-auto">
        <div class="flex justify-between items-start mb-8">
          <div>
            <h1 class="text-2xl font-bold">Mes véhicules</h1>
            <p class="text-gray-600">Gérez vos véhicules et suivez leur entretien</p>
          </div>
          
          <Button variant="primary" @click="handleAddClick" class="!w-auto">
            <div class="flex items-center space-x-2 px-2">
              <PlusIcon class="w-5 h-5" />
              <span>Ajouter un véhicule</span>
            </div>
          </Button>
        </div>

        <!-- Barre de recherche et filtres -->
        <div class="bg-white rounded-xl shadow-sm mb-6">
          <div class="p-4">
            <div class="flex flex-col lg:flex-row lg:items-center gap-4">
              <!-- Recherche -->
              <div class="flex-1">
                <div class="relative">
                  <input
                    type="text"
                    v-model="searchQuery"
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

              <!-- Vue grille/liste -->
              <div class="flex rounded-lg border border-gray-200 overflow-hidden">
                <button
                  @click="viewMode = 'grid'"
                  class="p-3 hover:bg-gray-50"
                  :class="{ 'bg-gray-100': viewMode === 'grid' }"
                >
                  <Squares2X2Icon class="w-5 h-5" />
                </button>
                <button
                  @click="viewMode = 'list'"
                  class="p-3 hover:bg-gray-50"
                  :class="{ 'bg-gray-100': viewMode === 'list' }"
                >
                  <ListBulletIcon class="w-5 h-5" />
                </button>
              </div>
            </div>

            <!-- Filtres avancés -->
            <div v-if="showFilters" class="mt-4 pt-4 border-t border-gray-200">
              <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <!-- Type de véhicule -->
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

                <!-- Type d'énergie -->
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

                <!-- Tri -->
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

        <!-- Liste des véhicules -->
        <section>
          <div v-if="loading" class="text-center py-12">
            <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-black mx-auto"></div>
          </div>

          <div v-else-if="vehicles.length === 0" class="text-center py-12 bg-white rounded-xl border border-gray-100">
            <h3 class="text-lg font-medium text-gray-900">Aucun véhicule</h3>
            <p class="mt-1 text-sm text-gray-500">Commencez par ajouter votre premier véhicule.</p>
            <Button variant="primary" @click="handleAddClick" class="mt-4">
              <div class="flex items-center justify-center space-x-2">
                <PlusIcon class="w-5 h-5" />
                <span>Ajouter un véhicule</span>
              </div>
            </Button>
          </div>

          <template v-else>
            <!-- Vue grille -->
            <div
              v-if="viewMode === 'grid'"
              class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
            >
              <VehicleCard
                v-for="vehicle in filteredVehicles"
                :key="vehicle.id"
                v-bind="vehicle"
              />
            </div>

            <!-- Vue liste -->
            <div v-else class="bg-white rounded-xl shadow-sm overflow-hidden">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Véhicule
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Type
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Énergie
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Kilométrage
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Plaque
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Dernière mise à jour
                    </th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr
                    v-for="vehicle in filteredVehicles"
                    :key="vehicle.id"
                    class="hover:bg-gray-50 cursor-pointer"
                    @click="router.push(`/vehicles/${vehicle.id}`)"
                  >
                    <td class="px-6 py-4">
                      <div class="flex items-center">
                        <div class="h-10 w-10 flex-shrink-0">
                          <img
                            :src="vehicle.image_url || 'https://placehold.co/100x100/e5e7eb/a3a3a3?text=NA'"
                            class="h-10 w-10 rounded-full object-cover"
                          />
                        </div>
                        <div class="ml-4">
                          <div class="font-medium text-gray-900">
                            {{ vehicle.brand }} {{ vehicle.model }}
                          </div>
                          <div class="text-sm text-gray-500">
                            {{ vehicle.year }}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td class="px-6 py-4">
                      <span class="capitalize">{{ vehicle.type }}</span>
                    </td>
                    <td class="px-6 py-4">
                      {{ vehicle.energy }}
                    </td>
                    <td class="px-6 py-4">
                      {{ vehicle.mileage.toLocaleString() }} km
                    </td>
                    <td class="px-6 py-4">
                      {{ vehicle.license_plate }}
                    </td>
                    <td class="px-6 py-4 text-gray-500">
                      {{ new Date(vehicle.updated_at).toLocaleDateString() }}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </template>
        </section>
      </div>
    </main>
  </div>
</template>