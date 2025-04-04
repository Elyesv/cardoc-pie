import { ref, computed } from 'vue'

export interface VehicleFormData {
  licensePlate: string
  vehicleName: string
  type: string
  brand: string
  model: string
  mileage: string
  color: string
  energy: string
  dateOfFirstRegistration: string
  dateOfPurchase: string
  numberOfOwners: string
  images: string[]
}

export const useVehicleForm = () => {
  const formData = ref<VehicleFormData>({
    licensePlate: '',
    vehicleName: '',
    type: '',
    brand: '',
    model: '',
    mileage: '',
    color: '',
    energy: '',
    dateOfFirstRegistration: '',
    dateOfPurchase: '',
    numberOfOwners: '',
    images: []
  })

  const currentStep = ref(0)

  const steps = [
    {
      title: 'Type de véhicule',
      description: 'Sélectionnez le type de votre véhicule'
    },
    {
      title: 'Informations de base',
      description: 'Entrez les informations principales'
    },
    {
      title: 'Détails techniques',
      description: 'Spécifiez les caractéristiques techniques'
    },
    {
      title: 'Historique',
      description: 'Renseignez l\'historique du véhicule'
    },
    {
      title: 'Images',
      description: 'Ajoutez des photos de votre véhicule'
    }
  ]

  const progress = computed(() => {
    return ((currentStep.value + 1) / steps.length) * 100
  })

  const canGoNext = computed(() => {
    switch (currentStep.value) {
      case 0:
        return !!formData.value.type
      case 1:
        return !!formData.value.licensePlate && !!formData.value.brand && !!formData.value.model
      case 2:
        return !!formData.value.mileage && !!formData.value.color && !!formData.value.energy
      case 3:
        return !!formData.value.dateOfFirstRegistration && !!formData.value.dateOfPurchase
      case 4:
        return formData.value.images.length > 0
      default:
        return false
    }
  })

  const onTypeSelected = () => {
    goToNextStep()
  }

  const goToNextStep = () => {
    if (currentStep.value < steps.length - 1) {
      currentStep.value++
    }
  }

  const goToPreviousStep = () => {
    if (currentStep.value > 0) {
      currentStep.value--
    }
  }

  const reset = () => {
    currentStep.value = 0
    formData.value = {
      licensePlate: '',
      vehicleName: '',
      type: '',
      brand: '',
      model: '',
      mileage: '',
      color: '',
      energy: '',
      dateOfFirstRegistration: '',
      dateOfPurchase: '',
      numberOfOwners: '',
      images: []
    }
  }

  return {
    formData,
    currentStep,
    steps,
    progress,
    canGoNext,
    onTypeSelected,
    goToNextStep,
    goToPreviousStep,
    reset
  }
}