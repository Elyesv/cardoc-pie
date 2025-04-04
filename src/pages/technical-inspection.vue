<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase'
import Navbar from '@/components/organisms/Navbar.vue'
import Button from '@/components/atoms/Button.vue'
import InspectionForm from '@/components/molecules/InspectionForm.vue'
import { PlusIcon, ArrowDownTrayIcon } from '@heroicons/vue/24/outline'
import { jsPDF } from 'jspdf'
import 'jspdf-autotable'

const loading = ref(true)
const showInspectionForm = ref(false)
const vehicles = ref([])
const inspections = ref([])
const selectedVehicle = ref('all')

const fetchData = async () => {
  try {
    loading.value = true
    
    // Récupérer les véhicules
    const { data: vehiclesData, error: vehiclesError } = await supabase
      .from('vehicles')
      .select('*')
    
    if (vehiclesError) throw vehiclesError
    vehicles.value = vehiclesData || []

    // Récupérer les contrôles techniques
    const { data: inspectionsData, error: inspectionsError } = await supabase
      .from('technical_inspections')
      .select(`
        *,
        vehicles (
          brand,
          model,
          license_plate
        )
      `)
      .order('expiry_date', { ascending: true })
    
    if (inspectionsError) throw inspectionsError
    inspections.value = inspectionsData || []
  } catch (error) {
    console.error('Error fetching data:', error)
  } finally {
    loading.value = false
  }
}

const handleInspectionSubmit = async (data: any) => {
  try {
    loading.value = true
    const { error } = await supabase
      .from('technical_inspections')
      .insert(data)

    if (error) throw error
    
    await fetchData()
    showInspectionForm.value = false
  } catch (error) {
    console.error('Error saving inspection:', error)
  } finally {
    loading.value = false
  }
}

const isExpiringSoon = (date: string) => {
  const expiryDate = new Date(date)
  const today = new Date()
  const diffTime = expiryDate.getTime() - today.getTime()
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  return diffDays <= 30
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
  doc.text('Suivi des contrôles techniques', 14, 20)
  
  const inspectionData = inspections.value.map(i => [
    `${i.vehicles.brand} ${i.vehicles.model}`,
    i.vehicles.license_plate,
    i.center,
    formatDate(i.date),
    formatDate(i.expiry_date),
    i.status === 'pass' ? 'Validé' : 'À repasser',
    `${i.cost.toLocaleString()} €`
  ])
  
  doc.autoTable({
    startY: 40,
    head: [['Véhicule', 'Immatriculation', 'Centre', 'Date', 'Expiration', 'Statut', 'Coût']],
    body: inspectionData,
    theme: 'grid',
    styles: { fontSize: 8 },
    headStyles: { fillColor: [0, 0, 0] }
  })
  
  doc.save('controles_techniques.pdf')
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
            <h1 class="text-2xl font-bold">Contrôles techniques</h1>
            <p class="text-gray-600">Gérez vos contrôles techniques</p>
          </div>
          
          <div class="flex items-center space-x-4">
            <Button
              v-if="inspections.length > 0"
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
              @click="showInspectionForm = true"
            >
              <div class="flex items-center space-x-2 px-2">
                <PlusIcon class="w-5 h-5" />
                <span>Ajouter un contrôle</span>
              </div>
            </Button>
          </div>
        </div>

        <!-- Filtre par véhicule -->
        <div class="bg-white p-4 rounded-xl shadow-sm mb-6">
          <select
            v-model="selectedVehicle"
            class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
          >
            <option value="all">Tous les véhicules</option>
            <option
              v-for="vehicle in vehicles"
              :key="vehicle.id"
              :value="vehicle.id"
            >
              {{ vehicle.brand }} {{ vehicle.model }} - {{ vehicle.license_plate }}
            </option>
          </select>
        </div>

        <!-- Formulaire d'ajout -->
        <div v-if="showInspectionForm" class="bg-white rounded-xl p-6 shadow-sm mb-6">
          <h2 class="text-lg font-medium mb-6">Nouveau contrôle technique</h2>
          <InspectionForm
            :vehicle-id="selectedVehicle === 'all' ? '' : selectedVehicle"
            :loading="loading"
            @submit="handleInspectionSubmit"
            @cancel="showInspectionForm = false"
          />
        </div>

        <!-- Liste des contrôles techniques -->
        <div class="bg-white rounded-xl shadow-sm overflow-hidden">
          <div class="p-6 border-b border-gray-200">
            <h2 class="text-lg font-medium">Contrôles techniques</h2>
          </div>

          <div v-if="loading" class="text-center py-12">
            <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-black mx-auto"></div>
          </div>

          <div v-else class="divide-y divide-gray-200">
            <div
              v-for="inspection in inspections.filter(i => 
                selectedVehicle === 'all' || i.vehicle_id === selectedVehicle
              )"
              :key="inspection.id"
              class="p-6 hover:bg-gray-50"
            >
              <div class="flex justify-between items-start">
                <div>
                  <h3 class="font-medium">
                    {{ inspection.vehicles.brand }} {{ inspection.vehicles.model }}
                    <span class="text-sm text-gray-500">
                      ({{ inspection.vehicles.license_plate }})
                    </span>
                  </h3>
                  <p class="text-sm text-gray-600 mt-1">
                    {{ inspection.center }} - {{ inspection.status === 'pass' ? 'Validé' : 'À repasser' }}
                  </p>
                  <p v-if="inspection.notes" class="text-sm text-gray-500 mt-1">
                    {{ inspection.notes }}
                  </p>
                </div>
                
                <div class="text-right">
                  <p class="font-medium">{{ inspection.cost.toLocaleString() }} €</p>
                  <p
                    :class="[
                      'text-sm mt-1',
                      isExpiringSoon(inspection.expiry_date) ? 'text-red-600 font-medium' : 'text-gray-500'
                    ]"
                  >
                    Expire le {{ formatDate(inspection.expiry_date) }}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>