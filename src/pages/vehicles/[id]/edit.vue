<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/supabase'
import Navbar from '@/components/organisms/Navbar.vue'
import FormField from '@/components/molecules/FormField.vue'
import Button from '@/components/atoms/Button.vue'
import ImageDropzone from '@/components/molecules/ImageDropzone.vue'

const route = useRoute()
const router = useRouter()
const loading = ref(true)
const saving = ref(false)

const formData = ref({
  brand: '',
  model: '',
  type: '',
  license_plate: '',
  mileage: '',
  color: '',
  energy: '',
  date_of_first_registration: '',
  date_of_purchase: '',
  number_of_owners: '',
  images: [] as string[]
})

const fetchVehicle = async () => {
  try {
    const { data, error } = await supabase
      .from('vehicles')
      .select('*')
      .eq('id', route.params.id)
      .single()

    if (error) throw error

    formData.value = {
      ...data,
      images: data.image_url ? [data.image_url] : []
    }
  } catch (error) {
    console.error('Error fetching vehicle:', error)
    router.push('/dashboard')
  } finally {
    loading.value = false
  }
}

const handleSubmit = async () => {
  try {
    saving.value = true
    const { error } = await supabase
      .from('vehicles')
      .update({
        brand: formData.value.brand,
        model: formData.value.model,
        type: formData.value.type,
        license_plate: formData.value.license_plate,
        mileage: parseInt(formData.value.mileage as string),
        color: formData.value.color,
        energy: formData.value.energy,
        date_of_first_registration: formData.value.date_of_first_registration,
        date_of_purchase: formData.value.date_of_purchase,
        number_of_owners: parseInt(formData.value.number_of_owners as string),
        image_url: formData.value.images[0] || null
      })
      .eq('id', route.params.id)

    if (error) throw error
    router.push(`/vehicles/${route.params.id}`)
  } catch (error) {
    console.error('Error updating vehicle:', error)
  } finally {
    saving.value = false
  }
}

onMounted(fetchVehicle)
</script>

<template>
  <div class="flex min-h-screen bg-gray-50">
    <Navbar />
    
    <main class="flex-1 p-8">
      <div class="max-w-2xl mx-auto">
        <div class="flex justify-between items-center mb-8">
          <h1 class="text-2xl font-bold">Modifier le véhicule</h1>
          <button
            @click="router.push(`/vehicles/${route.params.id}`)"
            class="text-gray-600 hover:text-gray-900"
          >
            Retour
          </button>
        </div>

        <div v-if="loading" class="flex items-center justify-center py-12">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-black"></div>
        </div>

        <form v-else @submit.prevent="handleSubmit" class="space-y-6">
          <div class="bg-white rounded-xl p-6 shadow-sm space-y-6">
            <div class="grid grid-cols-2 gap-4">
              <FormField
                label="Marque"
                v-model="formData.brand"
                placeholder="ex: Renault"
                required
              />
              <FormField
                label="Modèle"
                v-model="formData.model"
                placeholder="ex: Clio"
                required
              />
            </div>

            <FormField
              label="Type de véhicule"
              v-model="formData.type"
            >
              <select
                v-model="formData.type"
                class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                required
              >
                <option value="car">Voiture</option>
                <option value="motorcycle">Moto</option>
                <option value="truck">Camion</option>
                <option value="van">Utilitaire</option>
              </select>
            </FormField>

            <FormField
              label="Plaque d'immatriculation"
              v-model="formData.license_plate"
              placeholder="AB-123-CD"
              required
            />

            <div class="grid grid-cols-2 gap-4">
              <FormField
                label="Kilométrage"
                type="number"
                v-model="formData.mileage"
                placeholder="ex: 50000"
                required
              />
              <FormField
                label="Couleur"
                v-model="formData.color"
                placeholder="ex: Noir"
                required
              />
            </div>

            <FormField
              label="Énergie"
              v-model="formData.energy"
              placeholder="ex: Essence"
              required
            />

            <div class="grid grid-cols-2 gap-4">
              <FormField
                label="Date de première mise en circulation"
                type="date"
                v-model="formData.date_of_first_registration"
                required
              />
              <FormField
                label="Date d'achat"
                type="date"
                v-model="formData.date_of_purchase"
                required
              />
            </div>

            <FormField
              label="Nombre de propriétaires"
              type="number"
              v-model="formData.number_of_owners"
              placeholder="ex: 2"
              required
            />

            <div>
              <label class="block text-sm font-medium text-gray-900 mb-2">Photo du véhicule</label>
              <ImageDropzone
                v-model="formData.images"
                :max-files="1"
              />
            </div>

            <div class="flex justify-end space-x-4 pt-4">
              <Button
                variant="secondary"
                @click="router.push(`/vehicles/${route.params.id}`)"
              >
                Annuler
              </Button>
              <Button
                type="submit"
                variant="primary"
                :loading="saving"
              >
                Enregistrer
              </Button>
            </div>
          </div>
        </form>
      </div>
    </main>
  </div>
</template>