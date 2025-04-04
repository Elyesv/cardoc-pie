import { ref, computed } from 'vue'

export const useVehicleFilters = (vehicles: any[]) => {
  const searchQuery = ref('')
  const selectedType = ref('all')
  const selectedEnergy = ref('all')
  const sortBy = ref<'date' | 'mileage' | 'brand'>('date')
  const sortOrder = ref<'asc' | 'desc'>('desc')

  const filteredVehicles = computed(() => {
    let filtered = [...vehicles]

    if (selectedType.value !== 'all') {
      filtered = filtered.filter(v => v.type === selectedType.value)
    }

    if (selectedEnergy.value !== 'all') {
      filtered = filtered.filter(v => v.energy === selectedEnergy.value)
    }

    if (searchQuery.value) {
      const query = searchQuery.value.toLowerCase()
      filtered = filtered.filter(v => 
        v.brand.toLowerCase().includes(query) ||
        v.model.toLowerCase().includes(query) ||
        v.license_plate.toLowerCase().includes(query)
      )
    }

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

  return {
    searchQuery,
    selectedType,
    selectedEnergy,
    sortBy,
    sortOrder,
    filteredVehicles,
    toggleSortOrder
  }
}