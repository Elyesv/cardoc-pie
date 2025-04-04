<script setup lang="ts">
defineProps<{
  steps: Array<{
    title: string
    description: string
  }>
  currentStep: number
  progress: number
}>()
</script>

<template>
  <div class="w-64 bg-gray-50 p-6 border-r border-gray-200">
    <h2 class="text-xl font-semibold mb-6">Ajouter un véhicule</h2>
    
    <div class="space-y-4">
      <div
        v-for="(step, index) in steps"
        :key="index"
        :class="[
          'flex items-center space-x-3 p-3 rounded-lg transition-colors',
          currentStep === index ? 'bg-black text-white' : 'text-gray-600',
          index < currentStep ? 'text-green-600' : ''
        ]"
      >
        <div
          :class="[
            'w-8 h-8 rounded-full flex items-center justify-center border-2',
            currentStep === index ? 'border-white' : 'border-current'
          ]"
        >
          {{ index + 1 }}
        </div>
        <div>
          <p class="font-medium">{{ step.title }}</p>
          <p
            :class="[
              'text-sm',
              currentStep === index ? 'text-white/80' : 'text-gray-500'
            ]"
          >
            {{ step.description }}
          </p>
        </div>
      </div>
    </div>

    <div class="mt-6">
      <div class="h-2 bg-gray-200 rounded-full">
        <div
          class="h-full bg-black rounded-full transition-all duration-300"
          :style="{ width: `${progress}%` }"
        />
      </div>
      <p class="text-sm text-gray-600 mt-2">
        Étape {{ currentStep + 1 }} sur {{ steps.length }}
      </p>
    </div>
  </div>
</template>