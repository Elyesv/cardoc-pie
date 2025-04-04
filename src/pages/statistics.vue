<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { supabase } from '@/supabase'
import Navbar from '@/components/organisms/Navbar.vue'
import { Line } from 'vue-chartjs'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js'

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
)

const loading = ref(true)
const vehicles = ref([])
const maintenances = ref([])
const insurances = ref([])
const inspections = ref([])

const fetchData = async () => {
  try {
    loading.value = true
    
    // Récupérer les véhicules
    const { data: vehiclesData } = await supabase
      .from('vehicles')
      .select('*')
    vehicles.value = vehiclesData || []

    // Récupérer les entretiens
    const { data: maintenancesData } = await supabase
      .from('maintenances')
      .select('*')
    maintenances.value = maintenancesData || []

    // Récupérer les assurances
    const { data: insurancesData } = await supabase
      .from('insurance_policies')
      .select('*')
    insurances.value = insurancesData || []

    // Récupérer les contrôles techniques
    const { data: inspectionsData } = await supabase
      .from('technical_inspections')
      .select('*')
    inspections.value = inspectionsData || []
  } catch (error) {
    console.error('Error fetching data:', error)
  } finally {
    loading.value = false
  }
}

// Statistiques globales
const globalStats = computed(() => {
  if (!vehicles.value.length) return null

  const totalMileage = vehicles.value.reduce((sum, v) => sum + v.mileage, 0)
  const totalMaintenanceCost = maintenances.value.reduce((sum, m) => sum + m.cost, 0)
  const totalInsuranceCost = insurances.value.reduce((sum, i) => sum + i.cost, 0)
  const totalInspectionCost = inspections.value.reduce((sum, i) => sum + i.cost, 0)
  const totalCost = totalMaintenanceCost + totalInsuranceCost + totalInspectionCost

  return {
    totalVehicles: vehicles.value.length,
    totalMileage,
    averageMileage: Math.round(totalMileage / vehicles.value.length),
    totalCost,
    costPerKm: totalCost / totalMileage,
    maintenanceCost: totalMaintenanceCost,
    insuranceCost: totalInsuranceCost,
    inspectionCost: totalInspectionCost
  }
})

// Données pour les graphiques
const costData = computed(() => ({
  labels: ['Entretiens', 'Assurances', 'Contrôles techniques'],
  datasets: [{
    label: 'Répartition des coûts',
    data: [
      globalStats.value?.maintenanceCost || 0,
      globalStats.value?.insuranceCost || 0,
      globalStats.value?.inspectionCost || 0
    ],
    backgroundColor: [
      'rgba(59, 130, 246, 0.5)',
      'rgba(16, 185, 129, 0.5)',
      'rgba(239, 68, 68, 0.5)'
    ],
    borderColor: [
      'rgb(59, 130, 246)',
      'rgb(16, 185, 129)',
      'rgb(239, 68, 68)'
    ],
    borderWidth: 1
  }]
}))

const options = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'top' as const
    }
  }
}

onMounted(fetchData)
</script>

<template>
  <div class="flex min-h-screen bg-gray-50">
    <Navbar />
    
    <main class="flex-1 p-8">
      <div class="max-w-7xl mx-auto">
        <h1 class="text-2xl font-bold mb-8">Statistiques</h1>

        <div v-if="loading" class="flex items-center justify-center py-12">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-black"></div>
        </div>

        <template v-else-if="globalStats">
          <!-- Statistiques globales -->
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
            <div class="bg-white p-6 rounded-xl shadow-sm">
              <h3 class="text-sm font-medium text-gray-500">Véhicules</h3>
              <p class="mt-2 text-3xl font-semibold">{{ globalStats.totalVehicles }}</p>
            </div>
            
            <div class="bg-white p-6 rounded-xl shadow-sm">
              <h3 class="text-sm font-medium text-gray-500">Kilométrage total</h3>
              <p class="mt-2 text-3xl font-semibold">{{ globalStats.totalMileage.toLocaleString() }} km</p>
            </div>
            
            <div class="bg-white p-6 rounded-xl shadow-sm">
              <h3 class="text-sm font-medium text-gray-500">Coût total</h3>
              <p class="mt-2 text-3xl font-semibold">{{ globalStats.totalCost.toLocaleString() }} €</p>
            </div>
            
            <div class="bg-white p-6 rounded-xl shadow-sm">
              <h3 class="text-sm font-medium text-gray-500">Coût par km</h3>
              <p class="mt-2 text-3xl font-semibold">{{ globalStats.costPerKm.toFixed(2) }} €</p>
            </div>
          </div>

          <!-- Graphiques -->
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
            <div class="bg-white p-6 rounded-xl shadow-sm">
              <h3 class="text-lg font-medium mb-4">Répartition des coûts</h3>
              <div class="h-64">
                <Line :data="costData" :options="options" />
              </div>
            </div>

            <div class="bg-white p-6 rounded-xl shadow-sm">
              <h3 class="text-lg font-medium mb-4">Répartition détaillée</h3>
              <div class="space-y-4">
                <div class="flex items-center justify-between">
                  <span class="text-gray-600">Entretiens</span>
                  <span class="font-medium">{{ globalStats.maintenanceCost.toLocaleString() }} €</span>
                </div>
                <div class="flex items-center justify-between">
                  <span class="text-gray-600">Assurances</span>
                  <span class="font-medium">{{ globalStats.insuranceCost.toLocaleString() }} €</span>
                </div>
                <div class="flex items-center justify-between">
                  <span class="text-gray-600">Contrôles techniques</span>
                  <span class="font-medium">{{ globalStats.inspectionCost.toLocaleString() }} €</span>
                </div>
                <div class="pt-4 border-t">
                  <div class="flex items-center justify-between font-medium">
                    <span>Total</span>
                    <span>{{ globalStats.totalCost.toLocaleString() }} €</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tableau récapitulatif -->
          <div class="bg-white rounded-xl shadow-sm overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200">
              <h3 class="text-lg font-medium">Détails par véhicule</h3>
            </div>
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Véhicule</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Kilométrage</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Coût total</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Coût/km</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr v-for="vehicle in vehicles" :key="vehicle.id">
                    <td class="px-6 py-4">
                      {{ vehicle.brand }} {{ vehicle.model }}
                    </td>
                    <td class="px-6 py-4 capitalize">
                      {{ vehicle.type }}
                    </td>
                    <td class="px-6 py-4">
                      {{ vehicle.mileage.toLocaleString() }} km
                    </td>
                    <td class="px-6 py-4">
                      {{ [...maintenances, ...insurances, ...inspections]
                        .filter(item => item.vehicle_id === vehicle.id)
                        .reduce((sum, item) => sum + item.cost, 0)
                        .toLocaleString() }} €
                    </td>
                    <td class="px-6 py-4">
                      {{ ([...maintenances, ...insurances, ...inspections]
                        .filter(item => item.vehicle_id === vehicle.id)
                        .reduce((sum, item) => sum + item.cost, 0) / vehicle.mileage)
                        .toFixed(2) }} €
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>
      </div>
    </main>
  </div>
</template>