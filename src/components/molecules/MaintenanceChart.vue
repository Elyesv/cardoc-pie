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
  maintenances: Array<{
    date: string
    cost: number
    mileage: number
  }>
}>()

const sortedMaintenances = computed(() => {
  return [...props.maintenances].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime())
})

const costData = computed(() => ({
  labels: sortedMaintenances.value.map(m => new Date(m.date).toLocaleDateString()),
  datasets: [
    {
      label: 'Coûts d\'entretien',
      data: sortedMaintenances.value.map(m => m.cost),
      borderColor: '#000',
      backgroundColor: 'rgba(0, 0, 0, 0.1)',
      tension: 0.4
    }
  ]
}))

const mileageData = computed(() => ({
  labels: sortedMaintenances.value.map(m => new Date(m.date).toLocaleDateString()),
  datasets: [
    {
      label: 'Kilométrage',
      data: sortedMaintenances.value.map(m => m.mileage),
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
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <div class="bg-white p-6 rounded-xl shadow-sm">
      <h3 class="text-lg font-medium mb-4">Évolution des coûts</h3>
      <div class="h-64">
        <Line :data="costData" :options="options" />
      </div>
    </div>

    <div class="bg-white p-6 rounded-xl shadow-sm">
      <h3 class="text-lg font-medium mb-4">Évolution du kilométrage</h3>
      <div class="h-64">
        <Line :data="mileageData" :options="options" />
      </div>
    </div>
  </div>
</template>