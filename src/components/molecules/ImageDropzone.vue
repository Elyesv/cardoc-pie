<script setup lang="ts">
import { ref } from 'vue'
import { XMarkIcon } from '@heroicons/vue/24/outline'
import { supabase } from '@/supabase'

const props = defineProps<{
  modelValue: string[]
  maxFiles?: number
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: string[]): void
  (e: 'error', message: string): void
}>()

const uploading = ref(false)
const files = ref<File[]>([])
const previewUrls = ref<string[]>(props.modelValue)

const validateFile = (file: File) => {
  // Vérifier le type de fichier
  if (!file.type.startsWith('image/')) {
    throw new Error('Seules les images sont autorisées')
  }
  
  // Vérifier la taille du fichier (5MB max)
  if (file.size > 5 * 1024 * 1024) {
    throw new Error('La taille du fichier ne doit pas dépasser 5MB')
  }
}

const handleFileDrop = async (event: DragEvent) => {
  event.preventDefault()
  
  if (!event.dataTransfer?.files) return
  
  try {
    const newFiles = Array.from(event.dataTransfer.files)
    
    // Valider chaque fichier
    newFiles.forEach(validateFile)
    
    if (props.maxFiles && (files.value.length + newFiles.length) > props.maxFiles) {
      throw new Error(`Vous ne pouvez pas ajouter plus de ${props.maxFiles} images`)
    }
    
    files.value.push(...newFiles)
    await uploadFiles(newFiles)
  } catch (error: any) {
    emit('error', error.message)
  }
}

const handleFileInput = async (event: Event) => {
  const input = event.target as HTMLInputElement
  if (!input.files) return
  
  try {
    const newFiles = Array.from(input.files)
    
    // Valider chaque fichier
    newFiles.forEach(validateFile)
    
    if (props.maxFiles && (files.value.length + newFiles.length) > props.maxFiles) {
      throw new Error(`Vous ne pouvez pas ajouter plus de ${props.maxFiles} images`)
    }
    
    files.value.push(...newFiles)
    await uploadFiles(newFiles)
  } catch (error: any) {
    emit('error', error.message)
  }
}

const uploadFiles = async (filesToUpload: File[]) => {
  try {
    uploading.value = true
    
    for (const file of filesToUpload) {
      const fileExt = file.name.split('.').pop()
      const fileName = `${Math.random().toString(36).substring(2)}.${fileExt}`
      const filePath = `${fileName}`
      
      const { error: uploadError } = await supabase.storage
        .from('vehicle-images')
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false
        })
      
      if (uploadError) throw uploadError
      
      const { data: { publicUrl } } = supabase.storage
        .from('vehicle-images')
        .getPublicUrl(filePath)
      
      previewUrls.value.push(publicUrl)
      emit('update:modelValue', [...props.modelValue, publicUrl])
    }
  } catch (error: any) {
    emit('error', error.message || 'Erreur lors du téléchargement')
  } finally {
    uploading.value = false
  }
}

const removeImage = async (index: number) => {
  try {
    const url = previewUrls.value[index]
    const filePath = url.split('/').pop()
    
    const { error } = await supabase.storage
      .from('vehicle-images')
      .remove([filePath])
    
    if (error) throw error
    
    files.value.splice(index, 1)
    previewUrls.value.splice(index, 1)
    const newValue = [...props.modelValue]
    newValue.splice(index, 1)
    emit('update:modelValue', newValue)
  } catch (error: any) {
    emit('error', error.message || 'Erreur lors de la suppression')
  }
}
</script>

<template>
  <div
    class="border-2 border-dashed border-gray-300 rounded-lg p-6"
    @dragover.prevent
    @drop="handleFileDrop"
  >
    <div v-if="uploading" class="text-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
      <p class="mt-4 text-gray-600">Téléchargement en cours...</p>
    </div>
    
    <div v-else>
      <div v-if="previewUrls.length === 0" class="text-center">
        <div class="mt-2">
          <input
            type="file"
            class="hidden"
            ref="fileInput"
            multiple
            accept="image/*"
            @change="handleFileInput"
          >
          <button
            type="button"
            class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
            @click="$refs.fileInput.click()"
          >
            Sélectionner des images
          </button>
        </div>
        <p class="mt-2 text-sm text-gray-500">
          ou glissez-déposez vos images ici
        </p>
        <p class="mt-1 text-xs text-gray-400">
          Formats acceptés : JPG, PNG, GIF - Max 5MB par image
        </p>
      </div>

      <div v-else class="grid grid-cols-2 gap-4 mt-4">
        <div
          v-for="(url, index) in previewUrls"
          :key="url"
          class="relative aspect-video rounded-lg overflow-hidden group"
        >
          <img
            :src="url"
            class="w-full h-full object-cover"
            alt="Preview"
          >
          <button
            type="button"
            class="absolute top-2 right-2 p-1 bg-white rounded-full shadow-sm opacity-0 group-hover:opacity-100 transition-opacity"
            @click="removeImage(index)"
          >
            <XMarkIcon class="w-4 h-4 text-gray-500" />
          </button>
        </div>
        
        <button
          v-if="!maxFiles || previewUrls.length < maxFiles"
          type="button"
          class="flex items-center justify-center border-2 border-dashed border-gray-300 rounded-lg hover:border-gray-400 transition-colors aspect-video"
          @click="$refs.fileInput.click()"
        >
          <span class="sr-only">Ajouter une image</span>
          <span class="text-2xl text-gray-400">+</span>
        </button>
      </div>
    </div>
  </div>
</template>