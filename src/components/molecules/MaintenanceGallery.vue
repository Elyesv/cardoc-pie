<script setup lang="ts">
import { ref } from 'vue'
import { Dialog } from '@headlessui/vue'
import { XMarkIcon } from '@heroicons/vue/24/outline'

const props = defineProps<{
  images: string[]
}>()

const selectedImage = ref<string | null>(null)

const openImage = (image: string) => {
  selectedImage.value = image
}

const closeImage = () => {
  selectedImage.value = null
}
</script>

<template>
  <div>
    <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
      <div
        v-for="image in images"
        :key="image"
        class="aspect-square rounded-lg overflow-hidden cursor-pointer hover:opacity-90 transition-opacity"
        @click="openImage(image)"
      >
        <img :src="image" class="w-full h-full object-cover" />
      </div>
    </div>

    <!-- Modal de visualisation -->
    <Dialog
      as="div"
      class="relative z-10"
      @close="closeImage"
      :open="!!selectedImage"
    >
      <div class="fixed inset-0 bg-black/90" aria-hidden="true" />
      
      <div class="fixed inset-0 overflow-y-auto">
        <div class="flex min-h-full items-center justify-center p-4">
          <Dialog.Panel class="relative">
            <button
              @click="closeImage"
              class="absolute top-4 right-4 text-white hover:text-gray-300"
            >
              <XMarkIcon class="w-6 h-6" />
            </button>
            
            <img
              v-if="selectedImage"
              :src="selectedImage"
              class="max-w-full max-h-[80vh] rounded-lg"
            />
          </Dialog.Panel>
        </div>
      </div>
    </Dialog>
  </div>
</template>