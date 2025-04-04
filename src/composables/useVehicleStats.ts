import { computed } from 'vue'

export const useVehicleStats = (maintenances: any[], inspections: any[]) => {
  const totalCosts = computed(() => {
    const maintenanceCost = maintenances.reduce((sum, m) => sum + m.cost, 0)
    const inspectionCost = inspections.reduce((sum, i) => sum + i.cost, 0)
    return maintenanceCost + inspectionCost
  })

  const averageCost = computed(() => {
    const total = maintenances.length + inspections.length
    return total > 0 ? totalCosts.value / total : 0
  })

  const lastMaintenanceDate = computed(() => {
    if (!maintenances.length) return null
    return [...maintenances].sort((a, b) => 
      new Date(b.date).getTime() - new Date(a.date).getTime()
    )[0].date
  })

  const nextMaintenanceDate = computed(() => {
    if (!lastMaintenanceDate.value) return null
    const date = new Date(lastMaintenanceDate.value)
    date.setMonth(date.getMonth() + 6)
    return date.toISOString().split('T')[0]
  })

  return {
    totalCosts,
    averageCost,
    lastMaintenanceDate,
    nextMaintenanceDate
  }
}