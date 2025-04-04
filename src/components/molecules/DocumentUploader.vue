<script setup lang="ts">
import { ref } from 'vue'
import { supabase } from '@/supabase'
import { PlusIcon, DocumentIcon, XMarkIcon } from '@heroicons/vue/24/outline'
import Button from '../atoms/Button.vue'

const props = defineProps<{
  vehicleId: string
  type: 'registration' | 'insurance' | 'technical_inspection' | 'invoice'
  modelValue: any[]
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: any[]): void
  (e: 'error', message: string): void
}>()

const uploading = ref(false)
const files = ref<File[]>([])

const handleFileInput = async (event: Event) => {
  const input = event.target as HTMLInputElement
  if (!input.files) return
  
  try {
    const file = input.files[0]
    if (!file.type.startsWith('application/pdf') && !file.type.startsWith('image/')) {
      throw new Error('Seuls les PDF et images sont autorisés')
    }
    
    if (file.size > 5 * 1024 * 1024) {
      throw new Error('La taille du fichier ne doit pas dépasser 5MB')
    }
    
    await uploadFile(file)
  } catch (error: any) {
    emit('error', error.message)
  }
}

const uploadFile = async (file: File) => {
  try {
    uploading.value = true
    
    const fileExt = file.name.split('.').pop()
    const fileName = `${Math.random().toString(36).substring(2)}.${fileExt}`
    const filePath = `${props.vehicleId}/${fileName}`
    
    const { error: uploadError } = await supabase.storage
      .from('documents')
      .upload(filePath, file)
    
    if (uploadError) throw uploadError
    
    const { data: { publicUrl } } = supabase.storage
      .from('documents')
      .getPublicUrl(filePath)
    
    emit('update:modelValue', [...props.modelValue, {
      name: file.name,
      url: publicUrl,
      type: props.type,
      uploaded_at: new Date().toISOString()
    }])
  } catch (error: any) {
    emit('error', error.message)
  } finally {
    uploading.value = false
  }
}

const removeDocument = async (index: number) => {
  try {
    const document = props.modelValue[index]
    const filePath = document.url.split('/').pop()
    
    const { error } = await supabase.storage
      .from('documents')
      .remove([filePath])
    
    if (error) throw error
    
    const newValue = [...props.modelValue]
    newValue.splice(index, 1)
    emit('update:modelValue', newValue)
  } catch (error: any) {
    emit('error', error.message)
  }
}
</script>

<template>
  <div class="space-y-4">
    <div class="flex items-center justify-between">
      <h3 class="text-lg font-medium">Documents</h3>
      <Button
        variant="secondary"
        class="!w-auto"
        @click="$refs.fileInput.click()"
      >
        <div class="flex items-center space-x-2">
          <PlusIcon class="w-5 h-5" />
          <span>Ajouter</span>
        </div>
      </Button>
      <input
        type="file"
        ref="fileInput"
        class="hidden"
        @change="handleFileInput"
        accept="application/pdf,image/*"
      >
    </div>

    <div v-if="uploading" class="text-center py-4">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-black mx-auto"></div>
      <p class="mt-2 text-sm text-gray-600">Téléchargement en cours...</p>
    </div>

    <div v-else-if="modelValue.length === 0" class="text-center py-8 bg-gray-50 rounded-lg">
      <DocumentIcon class="w-12 h-12 mx-auto text-gray-400" />
      <p class="mt-2 text-sm text-gray-500">Aucun document</p>
    </div>

    <div v-else class="space-y-2">
      <div
        v-for="(doc, index) in modelValue"
        :key="index"
        class="flex items-center justify-between p-4 bg-gray-50 rounded-lg"
      >
        <div class="flex items-center space-x-3">
          <DocumentIcon class="w-5 h-5 text-gray-400" />
          <div>
            <p class="font-medium">{{ doc.name }}</p>
            <p class="text-sm text-gray-500">
              Ajouté le {{ new Date(doc.uploaded_at).toLocaleDateString() }}
            </p>
          </div>
        </div>
        
        <div class="flex items-center space-x-2">
          <a
            :href="doc.url"
            target="_blank"
            class="text-sm text-gray-600 hover:text-gray-900"
          >
            Voir
          </a>
          <button
            @click="removeDocument(index)"
            class="text-gray-400 hover:text-red-600"
          >
            <XMarkIcon class="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  </div>
</template>