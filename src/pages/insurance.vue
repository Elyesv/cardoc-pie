<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase'
import Navbar from '@/components/organisms/Navbar.vue'
import Button from '@/components/atoms/Button.vue'
import FormField from '@/components/molecules/FormField.vue'
import { PlusIcon, ArrowDownTrayIcon, EnvelopeIcon } from '@heroicons/vue/24/outline'
import { jsPDF } from 'jspdf'
import 'jspdf-autotable'

const loading = ref(true)
const showInsuranceForm = ref(false)
const vehicles = ref([])
const insurances = ref([])

const formData = ref({
  vehicleId: '',
  provider: '',
  startDate: '',
  cost: '',
  type: 'comprehensive',
  paymentFrequency: 'monthly',
  paymentDay: '1',
  documents: []
})

const fetchData = async () => {
  try {
    loading.value = true
    
    // Récupérer les véhicules
    const { data: vehiclesData, error: vehiclesError } = await supabase
      .from('vehicles')
      .select('*')
    
    if (vehiclesError) throw vehiclesError
    vehicles.value = vehiclesData || []

    // Récupérer les assurances
    const { data: insurancesData, error: insurancesError } = await supabase
      .from('insurance_policies')
      .select(`
        *,
        vehicles (
          brand,
          model,
          license_plate
        )
      `)
      .order('start_date', { ascending: false })
    
    if (insurancesError) throw insurancesError
    insurances.value = insurancesData || []
  } catch (error) {
    console.error('Error fetching data:', error)
  } finally {
    loading.value = false
  }
}

const resetForm = () => {
  formData.value = {
    vehicleId: '',
    provider: '',
    startDate: '',
    cost: '',
    type: 'comprehensive',
    paymentFrequency: 'monthly',
    paymentDay: '1',
    documents: []
  }
}

const handleInsuranceSubmit = async () => {
  try {
    loading.value = true
    
    if (!formData.value.vehicleId) {
      throw new Error('Veuillez sélectionner un véhicule')
    }

    const insuranceData = {
      vehicle_id: formData.value.vehicleId,
      provider: formData.value.provider,
      start_date: formData.value.startDate,
      cost: parseFloat(formData.value.cost),
      type: formData.value.type,
      payment_frequency: formData.value.paymentFrequency,
      payment_day: parseInt(formData.value.paymentDay)
    }

    const { error } = await supabase
      .from('insurance_policies')
      .insert(insuranceData)

    if (error) throw error
    
    await fetchData()
    showInsuranceForm.value = false
    resetForm()
  } catch (error) {
    console.error('Error saving insurance:', error)
  } finally {
    loading.value = false
  }
}

const getPaymentAmount = (insurance: any) => {
  const annualCost = parseFloat(insurance.cost)
  switch (insurance.payment_frequency) {
    case 'monthly':
      return annualCost / 12
    case 'quarterly':
      return annualCost / 4
    case 'yearly':
      return annualCost
    default:
      return annualCost
  }
}

const getPaymentFrequencyLabel = (frequency: string) => {
  switch (frequency) {
    case 'monthly':
      return 'mensuel'
    case 'quarterly':
      return 'trimestriel'
    case 'yearly':
      return 'annuel'
    default:
      return frequency
  }
}

const getNextPaymentDate = (insurance: any) => {
  const today = new Date()
  const paymentDay = insurance.payment_day
  let nextDate = new Date(today.getFullYear(), today.getMonth(), paymentDay)
  
  if (nextDate <= today) {
    switch (insurance.payment_frequency) {
      case 'monthly':
        nextDate.setMonth(nextDate.getMonth() + 1)
        break
      case 'quarterly':
        nextDate.setMonth(nextDate.getMonth() + 3)
        break
      case 'yearly':
        nextDate.setFullYear(nextDate.getFullYear() + 1)
        break
    }
  }
  
  return nextDate
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const exportPDF = () => {
  const doc = new jsPDF()
  
  // En-tête
  doc.setFontSize(20)
  doc.text('Suivi des assurances', 14, 20)
  
  const insuranceData = insurances.value.map(i => [
    `${i.vehicles.brand} ${i.vehicles.model}`,
    i.vehicles.license_plate,
    i.provider,
    formatDate(i.start_date),
    `${i.cost.toLocaleString()} €`,
    `${getPaymentFrequencyLabel(i.payment_frequency)} (${i.payment_day})`,
    `${getPaymentAmount(i).toFixed(2)} €`
  ])
  
  doc.autoTable({
    startY: 45,
    head: [['Véhicule', 'Immatriculation', 'Assureur', 'Date début', 'Coût annuel', 'Paiement', 'Montant/Paiement']],
    body: insuranceData,
    theme: 'grid',
    styles: { fontSize: 8 },
    headStyles: { fillColor: [0, 0, 0] }
  })
  
  doc.save('suivi_assurances.pdf')
}

const shareByEmail = (id: string) => {
  // Implémentation à venir : envoi par email via une API
  console.log(`Partage par email : ${id}`)
}

onMounted(fetchData)
</script>

<template>
  <div class="flex min-h-screen bg-gray-50">
    <Navbar />
    
    <main class="flex-1 p-8">
      <div class="max-w-7xl mx-auto">
        <div class="flex justify-between items-start mb-8">
          <div>
            <h1 class="text-2xl font-bold">Assurances</h1>
            <p class="text-gray-600">Gérez vos assurances</p>
          </div>
          
          <div class="flex items-center space-x-4">
            <Button
              variant="secondary"
              class="!w-auto"
              @click="exportPDF"
            >
              <div class="flex items-center space-x-2 px-2">
                <ArrowDownTrayIcon class="w-5 h-5" />
                <span>Exporter PDF</span>
              </div>
            </Button>

            <Button
              variant="primary"
              class="!w-auto"
              @click="showInsuranceForm = true"
            >
              <div class="flex items-center space-x-2 px-2">
                <PlusIcon class="w-5 h-5" />
                <span>Ajouter une assurance</span>
              </div>
            </Button>
          </div>
        </div>

        <div v-if="loading" class="text-center py-12">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-black mx-auto"></div>
        </div>

        <div v-else class="space-y-8">
          <!-- Formulaire d'ajout d'assurance -->
          <div v-if="showInsuranceForm" class="bg-white rounded-xl p-6 shadow-sm">
            <h2 class="text-lg font-medium mb-6">Nouvelle assurance</h2>
            
            <form @submit.prevent="handleInsuranceSubmit" class="space-y-6">
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-900 mb-2">Véhicule</label>
                  <select
                    v-model="formData.vehicleId"
                    class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    required
                  >
                    <option value="">Sélectionnez un véhicule</option>
                    <option
                      v-for="vehicle in vehicles"
                      :key="vehicle.id"
                      :value="vehicle.id"
                    >
                      {{ vehicle.brand }} {{ vehicle.model }} - {{ vehicle.license_plate }}
                    </option>
                  </select>
                </div>

                <FormField
                  label="Assureur"
                  v-model="formData.provider"
                  placeholder="ex: AXA"
                  required
                />
              </div>

              <div class="grid grid-cols-2 gap-4">
                <FormField
                  label="Date de début"
                  type="date"
                  v-model="formData.startDate"
                  required
                />
                <FormField
                  label="Coût annuel"
                  type="number"
                  step="0.01"
                  v-model="formData.cost"
                  placeholder="ex: 500"
                  required
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-900 mb-2">Type d'assurance</label>
                <select
                  v-model="formData.type"
                  class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                  required
                >
                  <option value="comprehensive">Tous risques</option>
                  <option value="third_party">Au tiers</option>
                  <option value="liability">Responsabilité civile</option>
                </select>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-900 mb-2">Fréquence de paiement</label>
                  <select
                    v-model="formData.paymentFrequency"
                    class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    required
                  >
                    <option value="monthly">Mensuel</option>
                    <option value="quarterly">Trimestriel</option>
                    <option value="yearly">Annuel</option>
                  </select>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-900 mb-2">Jour de prélèvement</label>
                  <select
                    v-model="formData.paymentDay"
                    class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    required
                  >
                    <option v-for="day in 28" :key="day" :value="day">
                      {{ day }}
                    </option>
                  </select>
                </div>
              </div>

              <div class="flex justify-end space-x-4 pt-4">
                <Button 
                  variant="secondary" 
                  @click="showInsuranceForm = false; resetForm()"
                >
                  Annuler
                </Button>
                <Button type="submit" variant="primary" :loading="loading">
                  Enregistrer
                </Button>
              </div>
            </form>
          </div>

          <!-- Liste des assurances -->
          <div class="bg-white rounded-xl shadow-sm overflow-hidden">
            <div class="p-6 border-b border-gray-200">
              <h2 class="text-lg font-medium">Assurances en cours</h2>
            </div>

            <div class="divide-y divide-gray-200">
              <div
                v-for="insurance in insurances"
                :key="insurance.id"
                class="p-6 hover:bg-gray-50"
              >
                <div class="flex justify-between items-start">
                  <div>
                    <h3 class="font-medium">
                      {{ insurance.vehicles.brand }} {{ insurance.vehicles.model }}
                      <span class="text-sm text-gray-500">
                        ({{ insurance.vehicles.license_plate }})
                      </span>
                    </h3>
                    <p class="text-sm text-gray-600 mt-1">
                      {{ insurance.provider }}
                    </p>
                    <div class="mt-2 space-y-1">
                      <p class="text-sm text-gray-600">
                        Paiement {{ getPaymentFrequencyLabel(insurance.payment_frequency) }}
                        le {{ insurance.payment_day }} du mois
                      </p>
                      <p class="text-sm font-medium">
                        {{ getPaymentAmount(insurance).toFixed(2) }}€
                        par {{ getPaymentFrequencyLabel(insurance.payment_frequency).replace('annuel', 'an') }}
                      </p>
                      <p class="text-sm text-gray-500">
                        Prochain paiement le {{ formatDate(getNextPaymentDate(insurance)) }}
                      </p>
                    </div>
                  </div>
                  
                  <div class="text-right">
                    <div class="flex items-center space-x-4 mb-2">
                      <button
                        @click="shareByEmail(insurance.id)"
                        class="text-gray-400 hover:text-gray-600"
                        title="Partager par email"
                      >
                        <EnvelopeIcon class="w-5 h-5" />
                      </button>
                      <p class="font-medium">{{ insurance.cost.toLocaleString() }} €/an</p>
                    </div>
                    <p class="text-sm text-gray-500">
                      Depuis le {{ formatDate(insurance.start_date) }}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>