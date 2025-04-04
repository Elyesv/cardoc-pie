import { defineStore } from 'pinia'
import { ref } from 'vue'
import { supabase } from '@/supabase'

export interface Vehicle {
  id: string
  brand: string
  model: string
  year: number
  image_url: string
  license_plate: string
  mileage: number
  type: string
  color: string
  energy: string
  date_of_first_registration: string
  date_of_purchase: string
  number_of_owners: number
}

export const useVehicleStore = defineStore('vehicle', () => {
  const vehicles = ref<Vehicle[]>([])
  const loading = ref(false)

  const fetchVehicles = async () => {
    try {
      loading.value = true
      const { data, error } = await supabase
        .from('vehicles')
        .select('*')
        .order('created_at', { ascending: false })
      
      if (error) throw error
      vehicles.value = data || []
    } catch (error) {
      console.error('Error fetching vehicles:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  const addVehicle = async (formData: any) => {
    try {
      // Récupérer l'utilisateur courant
      const { data: { user }, error: userError } = await supabase.auth.getUser()
      if (userError) throw userError
      if (!user) throw new Error('User not authenticated')

      // Extraire l'année de la date de première mise en circulation
      const year = new Date(formData.dateOfFirstRegistration).getFullYear()

      const { error } = await supabase
        .from('vehicles')
        .insert({
          user_id: user.id,
          brand: formData.brand,
          model: formData.model,
          type: formData.type,
          year: year, // Ajout de l'année
          license_plate: formData.licensePlate,
          mileage: parseInt(formData.mileage),
          color: formData.color,
          energy: formData.energy,
          date_of_first_registration: formData.dateOfFirstRegistration,
          date_of_purchase: formData.dateOfPurchase,
          number_of_owners: parseInt(formData.numberOfOwners),
          image_url: formData.images[0] || null
        })

      if (error) throw error
      await fetchVehicles()
    } catch (error) {
      console.error('Error adding vehicle:', error)
      throw error
    }
  }

  return {
    vehicles,
    loading,
    fetchVehicles,
    addVehicle
  }
})