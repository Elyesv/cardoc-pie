export interface Vehicle {
  id: string
  user_id: string
  brand: string
  model: string
  year: number
  image_url: string | null
  license_plate: string
  mileage: number
  type: string
  color: string
  energy: string
  date_of_first_registration: string
  date_of_purchase: string
  number_of_owners: number
  created_at: string
  updated_at: string
}

export interface VehicleFormData {
  type: string
  brand: string
  model: string
  licensePlate: string
  mileage: string
  color: string
  energy: string
  dateOfFirstRegistration: string
  dateOfPurchase: string
  numberOfOwners: string
  images: string[]
}