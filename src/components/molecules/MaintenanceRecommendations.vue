<script setup lang="ts">
import { computed } from 'vue'
import { ExclamationTriangleIcon, CheckCircleIcon } from '@heroicons/vue/24/outline'

const props = defineProps<{
  recommendations: Array<{
    id: string
    title: string
    description: string
    mileage_threshold: number
    priority: string
  }>
  currentMileage: number
}>()

const sortedRecommendations = computed(() => {
  return [...props.recommendations].sort((a, b) => {
    const aDiff = a.mileage_threshold - props.currentMileage
    const bDiff = b.mileage_threshold - props.currentMileage
    return aDiff - bDiff
  })
})

const getStatus = (threshold: number) => {
  const diff = threshold - props.currentMileage
  if (diff <= 0) return 'overdue'
  if (diff <= 1000) return 'soon'
  return 'ok'
}

const formatMileage = (mileage: number) => {
  return mileage.toLocaleString()
}
</script>

<template>
  <div class="space-y-4">
    <div
      v-for="recommendation in sortedRecommendations"
      :key="recommendation.id"
      :class="[
        'p-4 rounded-lg border',
        getStatus(recommendation.mileage_threshold) === 'overdue'
          ? 'bg-red-50 border-red-200'
          : getStatus(recommendation.mileage_threshold) === 'soon'
            ? 'bg-yellow-50 border-yellow-200'
            : 'bg-green-50 border-green-200'
      ]"
    >
      <div class="flex items-start space-x-3">
        <div class="flex-shrink-0 mt-0.5">
          <ExclamationTriangleIcon
            v-if="getStatus(recommendation.mileage_threshold) === 'overdue'"
            class="w-5 h-5 text-red-600"
          />
          <ExclamationTriangleIcon
            v-else-if="getStatus(recommendation.mileage_threshold) === 'soon'"
            class="w-5 h-5 text-yellow-600"
          />
          <CheckCircleIcon
            v-else
            class="w-5 h-5 text-green-600"
          />
        </div>
        
        <div>
          <h4 class="font-medium">{{ recommendation.title }}</h4>
          <p class="text-sm text-gray-600 mt-1">{{ recommendation.description }}</p>
          <div class="mt-2 flex items-center space-x-2">
            <span
              :class="[
                'text-sm font-medium px-2 py-1 rounded-full',
                recommendation.priority === 'high'
                  ? 'bg-red-100 text-red-700'
                  : recommendation.priority === 'medium'
                    ? 'bg-yellow-100 text-yellow-700'
                    : 'bg-green-100 text-green-700'
              ]"
            >
              {{ recommendation.priority === 'high' ? 'Haute' : recommendation.priority === 'medium' ? 'Moyenne' : 'Basse' }}
            </span>
            <span class="text-sm text-gray-500">
              À {{ formatMileage(recommendation.mileage_threshold) }} km
              ({{ formatMileage(Math.abs(recommendation.mileage_threshold - currentMileage)) }} km
              {{ recommendation.mileage_threshold > currentMileage ? 'restants' : 'dépassés' }})
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>