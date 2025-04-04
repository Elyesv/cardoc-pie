<script setup lang="ts">
import StatCard from '../molecules/StatCard.vue'
import ChartCard from '../molecules/ChartCard.vue'

defineProps<{
  maintenances: any[]
}>()

const totalCost = computed(() => 
  maintenances.reduce((sum, m) => sum + m.cost, 0)
)

const averageCost = computed(() => 
  maintenances.length ? totalCost.value / maintenances.length : 0
)

const costData = computed(() => ({
  labels: maintenances.map(m => new Date(m.date).toLocaleDateString()),
  datasets: [{
    label: 'Coûts d\'entretien',
    data: maintenances.map(m => m.cost),
    borderColor: '#000',
    tension: 0.4
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
</script>

<template>
  <div class="space-y-6">
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <StatCard
        title="Total des coûts"
        :value="totalCost.toLocaleString()"
        unit="€"
      />
      <StatCard
        title="Coût moyen"
        :value="averageCost.toFixed(2)"
        unit="€"
      />
      <StatCard
        title="Nombre d'entretiens"
        :value="maintenances.length"
      />
    </div>

    <ChartCard
      title="Évolution des coûts"
      :data="costData"
      :options="options"
    />
  </div>
</template>