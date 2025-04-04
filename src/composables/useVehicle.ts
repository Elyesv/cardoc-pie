import { ref } from 'vue'
import type { Vehicle } from '@/types/vehicle'
import { supabase } from '@/supabase'

export const useVehicle = () => {
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
    const { user } = await getCurrentUser()
    const vehicleData = formatVehicleData(formData, user.id)
    await insertVehicle(vehicleData)
    await fetchVehicles()
  }

  return {
    vehicles,
    loading,
    fetchVehicles,
    addVehicle
  }
}

// Helpers
const getCurrentUser = async () => {
  const { data: { user }, error } = await supabase.auth.getUser()
  if (error) throw error
  if (!user) throw new Error('User not authenticated')
  return { user }
}

const formatVehicleData = (formData: any, userId: string) => {
  const year = new Date(formData.dateOfFirstRegistration).getFullYear()
  
  return {
    user_id: userId,
    brand: formData.brand,
    model: formData.model,
    type: formData.type,
    year,
    license_plate: formData.licensePlate,
    mileage: parseInt(formData.mileage),
    color: formData.color,
    energy: formData.energy,
    date_of_first_registration: formData.dateOfFirstRegistration,
    date_of_purchase: formData.dateOfPurchase,
    number_of_owners: parseInt(formData.numberOfOwners),
    image_url: formData.images[0] || null
  }
}

const insertVehicle = async (vehicleData: any) => {
  const { error } = await supabase
    .from('vehicles')
    .insert(vehicleData)
  
  if (error) throw error
}