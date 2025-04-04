<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import Navbar from '@/components/organisms/Navbar.vue'
import VehicleForm from '@/components/organisms/VehicleForm.vue'
import { useVehicle } from '@/composables/useVehicle'

const router = useRouter()
const { addVehicle } = useVehicle()
const loading = ref(false)

const handleSubmit = async (formData) => {
  try {
    loading.value = true
    await addVehicle(formData)
    router.push('/dashboard')
  } catch (error) {
    console.error('Error adding vehicle:', error)
  } finally {
    loading.value = false
  }
}

const handleCancel = () => {
  router.push('/dashboard')
}
</script>

<template>
  <div class="flex min-h-screen bg-gray-50">
    <Navbar />
    
    <main class="flex-1">
      <VehicleForm
        :loading="loading"
        @submit="handleSubmit"
        @cancel="handleCancel"
      />
    </main>
  </div>
</template>