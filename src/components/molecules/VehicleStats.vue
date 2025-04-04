<script setup lang="ts">
import StatCard from '../atoms/StatCard.vue'
import { useVehicleStats } from '@/composables/useVehicleStats'

const props = defineProps<{
  maintenances: any[]
  inspections: any[]
}>()

const { totalCosts, averageCost, lastMaintenanceDate, nextMaintenanceDate } = useVehicleStats(
  props.maintenances,
  props.inspections
)

const formatDate = (date: string | null) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}
</script>

<template>
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
    <StatCard
      title="Total des coûts"
      :value="totalCosts.toLocaleString()"
      unit="€"
    />
    
    <StatCard
      title="Coût moyen"
      :value="averageCost.toFixed(0)"
      unit="€"
    />
    
    <StatCard
      title="Dernier entretien"
      :value="formatDate(lastMaintenanceDate)"
    />
    
    <StatCard
      title="Prochain entretien"
      :value="formatDate(nextMaintenanceDate)"
    />
  </div>
</template>