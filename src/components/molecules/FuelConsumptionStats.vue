<script setup lang="ts">
import { computed } from 'vue'
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

const props = defineProps<{
  fuelLogs: Array<{
    date: string
    quantity: number
    cost: number
    mileage: number
  }>
}>()

const sortedLogs = computed(() => {
  return [...props.fuelLogs].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime())
})

// Calcul des statistiques
const stats = computed(() => {
  if (!props.fuelLogs.length) return null

  const totalCost = props.fuelLogs.reduce((sum, log) => sum + log.cost, 0)
  const totalQuantity = props.fuelLogs.reduce((sum, log) => sum + log.quantity, 0)
  const averageCost = totalCost / totalQuantity
  
  // Calcul de la consommation moyenne
  const fullTankLogs = props.fuelLogs.filter(log => log.fullTank)
  let totalConsumption = 0
  
  for (let i = 1; i < fullTankLogs.length; i++) {
    const distance = fullTankLogs[i].mileage - fullTankLogs[i-1].mileage
    const consumption = (fullTankLogs[i].quantity / distance) * 100
    totalConsumption += consumption
  }
  
  const averageConsumption = totalConsumption / (fullTankLogs.length - 1)

  return {
    totalCost,
    totalQuantity,
    averageCost,
    averageConsumption
  }
})

// Données pour les graphiques
const consumptionData = computed(() => ({
  labels: sortedLogs.value.map(log => new Date(log.date).toLocaleDateString()),
  datasets: [
    {
      label: 'Consommation (L/100km)',
      data: sortedLogs.value.map((log, i) => {
        if (i === 0) return null
        const distance = log.mileage - sortedLogs.value[i-1].mileage
        return (log.quantity / distance) * 100
      }),
      borderColor: '#000',
      backgroundColor: 'rgba(0, 0, 0, 0.1)',
      tension: 0.4
    }
  ]
}))

const costData = computed(() => ({
  labels: sortedLogs.value.map(log => new Date(log.date).toLocaleDateString()),
  datasets: [
    {
      label: 'Coût au litre (€/L)',
      data: sortedLogs.value.map(log => log.cost / log.quantity),
      borderColor: '#2563eb',
      backgroundColor: 'rgba(37, 99, 235, 0.1)',
      tension: 0.4
    }
  ]
}))

const options = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'top' as const
    }
  },
  scales: {
    y: {
      beginAtZero: true
    }
  }
}
</script>

<template>
  <div class="space-y-6">
    <!-- Statistiques -->
    <div v-if="stats" class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <div class="bg-white p-6 rounded-xl shadow-sm">
        <h3 class="text-sm font-medium text-gray-500">Coût total</h3>
        <p class="mt-2 text-3xl font-semibold">{{ stats.totalCost.toFixed(2) }} €</p>
      </div>
      
      <div class="bg-white p-6 rounded-xl shadow-sm">
        <h3 class="text-sm font-medium text-gray-500">Volume total</h3>
        <p class="mt-2 text-3xl font-semibold">{{ stats.totalQuantity.toFixed(1) }} L</p>
      </div>
      
      <div class="bg-white p-6 rounded-xl shadow-sm">
        <h3 class="text-sm font-medium text-gray-500">Prix moyen/L</h3>
        <p class="mt-2 text-3xl font-semibold">{{ stats.averageCost.toFixed(3) }} €</p>
      </div>
      
      <div class="bg-white p-6 rounded-xl shadow-sm">
        <h3 class="text-sm font-medium text-gray-500">Conso. moyenne</h3>
        <p class="mt-2 text-3xl font-semibold">{{ stats.averageConsumption.toFixed(1) }} L/100km</p>
      </div>
    </div>

    <!-- Graphiques -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div class="bg-white p-6 rounded-xl shadow-sm">
        <h3 class="text-lg font-medium mb-4">Évolution de la consommation</h3>
        <div class="h-64">
          <Line :data="consumptionData" :options="options" />
        </div>
      </div>

      <div class="bg-white p-6 rounded-xl shadow-sm">
        <h3 class="text-lg font-medium mb-4">Évolution du prix au litre</h3>
        <div class="h-64">
          <Line :data="costData" :options="options" />
        </div>
      </div>
    </div>
  </div>
</template>