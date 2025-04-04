<script setup lang="ts">
import { ref } from 'vue'
import { CheckIcon, XMarkIcon } from '@heroicons/vue/24/outline'

const props = defineProps<{
  tasks: Array<{
    id: string
    task_name: string
    status: string
    notes?: string
  }>
}>()

const emit = defineEmits<{
  (e: 'update:status', id: string, status: string): void
}>()

const updateStatus = (taskId: string, newStatus: string) => {
  emit('update:status', taskId, newStatus)
}
</script>

<template>
  <div class="space-y-4">
    <div
      v-for="task in tasks"
      :key="task.id"
      class="flex items-center justify-between p-4 bg-gray-50 rounded-lg"
    >
      <div>
        <p class="font-medium">{{ task.task_name }}</p>
        <p v-if="task.notes" class="text-sm text-gray-500 mt-1">{{ task.notes }}</p>
      </div>
      
      <div class="flex items-center space-x-2">
        <button
          @click="updateStatus(task.id, 'completed')"
          :class="[
            'p-2 rounded-full',
            task.status === 'completed'
              ? 'bg-green-100 text-green-600'
              : 'hover:bg-gray-100'
          ]"
        >
          <CheckIcon class="w-5 h-5" />
        </button>
        <button
          @click="updateStatus(task.id, 'skipped')"
          :class="[
            'p-2 rounded-full',
            task.status === 'skipped'
              ? 'bg-red-100 text-red-600'
              : 'hover:bg-gray-100'
          ]"
        >
          <XMarkIcon class="w-5 h-5" />
        </button>
      </div>
    </div>
  </div>
</template>