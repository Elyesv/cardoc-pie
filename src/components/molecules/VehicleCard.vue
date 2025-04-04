<script setup lang="ts">
import { WrenchIcon, CalendarIcon, HashtagIcon } from '@heroicons/vue/24/outline'
import { useRouter } from 'vue-router'

const props = defineProps<{
  id: string
  brand: string
  model: string
  year: number
  image_url: string | null
  license_plate: string // Changé de licensePlate à license_plate
  mileage: number
}>()

const router = useRouter()

const formatLicensePlate = (plate: string) => {
  // Supprime tous les caractères non alphanumériques
  const cleaned = plate.replace(/[^A-Z0-9]/gi, '').toUpperCase()
  
  if (cleaned.length === 7) {
    // Format XX-111-XX
    return `${cleaned.slice(0, 2)}-${cleaned.slice(2, 5)}-${cleaned.slice(5, 7)}`
  }
  return plate
}

const handleClick = () => {
  router.push(`/vehicles/${props.id}`)
}
</script>

<template>
  <div 
    class="group bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-lg transition-all duration-300 cursor-pointer"
    @click="handleClick"
  >
    <!-- Image Container -->
    <div class="aspect-video relative bg-gray-100 overflow-hidden">
      <img 
        :src="image_url || 'https://placehold.co/600x400/e5e7eb/a3a3a3?text=Aucune+image'" 
        :alt="`${brand} ${model}`" 
        class="w-full h-full object-cover transform group-hover:scale-105 transition-transform duration-300"
        @error="$event.target.src = 'https://placehold.co/600x400/e5e7eb/a3a3a3?text=Erreur+de+chargement'"
      />
      <!-- Overlay avec le kilométrage -->
      <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent p-4">
        <div class="flex items-center text-white">
          <WrenchIcon class="w-4 h-4 mr-2" />
          <span class="text-sm font-medium">{{ mileage.toLocaleString() }} km</span>
        </div>
      </div>
    </div>

    <!-- Contenu -->
    <div class="p-4">
      <!-- En-tête avec marque et modèle -->
      <div class="mb-4">
        <h3 class="text-lg font-semibold text-gray-900">{{ brand }} {{ model }}</h3>
        <p class="text-sm text-gray-500 mt-1">{{ formatLicensePlate(license_plate) }}</p>
      </div>

      <!-- Informations détaillées -->
      <div class="grid grid-cols-2 gap-3">
        <!-- Année -->
        <div class="flex items-center text-sm text-gray-600">
          <CalendarIcon class="w-4 h-4 mr-2" />
          <span>{{ year }}</span>
        </div>
        <!-- Plaque -->
        <div class="flex items-center text-sm text-gray-600">
          <HashtagIcon class="w-4 h-4 mr-2" />
          <span>{{ formatLicensePlate(license_plate) }}</span>
        </div>
      </div>

      <!-- Bouton d'action -->
      <button class="w-full mt-4 py-2 px-4 bg-gray-50 text-gray-600 rounded-lg text-sm font-medium hover:bg-gray-100 transition-colors flex items-center justify-center space-x-2">
        <WrenchIcon class="w-4 h-4" />
        <span>Voir les détails</span>
      </button>
    </div>
  </div>
</template>