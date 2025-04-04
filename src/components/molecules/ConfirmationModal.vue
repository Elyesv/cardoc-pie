<script setup lang="ts">
import { Dialog, DialogPanel, DialogTitle } from '@headlessui/vue'
import { ExclamationTriangleIcon } from '@heroicons/vue/24/outline'

defineProps<{
  show: boolean
  title: string
  message: string
}>()

const emit = defineEmits<{
  (e: 'confirm'): void
  (e: 'cancel'): void
}>()
</script>

<template>
  <Dialog as="div" class="relative z-10" @close="emit('cancel')" :open="show">
    <div class="fixed inset-0 bg-black/25" />
    
    <div class="fixed inset-0 overflow-y-auto">
      <div class="flex min-h-full items-center justify-center p-4 text-center">
        <DialogPanel class="w-full max-w-md transform overflow-hidden rounded-2xl bg-white p-6 text-left align-middle shadow-xl transition-all">
          <div class="flex items-center space-x-4">
            <div class="flex-shrink-0">
              <ExclamationTriangleIcon class="h-6 w-6 text-red-600" />
            </div>
            <div>
              <DialogTitle as="h3" class="text-lg font-medium leading-6 text-gray-900">
                {{ title }}
              </DialogTitle>
              <p class="mt-2 text-sm text-gray-500">
                {{ message }}
              </p>
            </div>
          </div>

          <div class="mt-6 flex justify-end space-x-4">
            <button
              type="button"
              class="inline-flex justify-center rounded-lg border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none"
              @click="emit('cancel')"
            >
              Annuler
            </button>
            <button
              type="button"
              class="inline-flex justify-center rounded-lg border border-transparent bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700 focus:outline-none"
              @click="emit('confirm')"
            >
              Confirmer
            </button>
          </div>
        </DialogPanel>
      </div>
    </div>
  </Dialog>
</template>