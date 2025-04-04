<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase'
import Navbar from '@/components/organisms/Navbar.vue'
import Button from '@/components/atoms/Button.vue'
import MaintenanceForm from '@/components/molecules/MaintenanceForm.vue'
import MaintenanceList from '@/components/molecules/MaintenanceList.vue'
import MaintenanceChart from '@/components/molecules/MaintenanceChart.vue'
import ConfirmationModal from '@/components/molecules/ConfirmationModal.vue'
import { PlusIcon, ArrowDownTrayIcon } from '@heroicons/vue/24/outline'
import { jsPDF } from 'jspdf'
import 'jspdf-autotable'

const loading = ref(true)
const saving = ref(false)
const showMaintenanceForm = ref(false)
const showDeleteModal = ref(false)
const maintenanceToDelete = ref<string | null>(null)
const editingMaintenance = ref(null)
const vehicles = ref<any[]>([])
const maintenances = ref<any[]>([])
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

    // Récupérer les entretiens
    const { data: maintenancesData, error: maintenanceError } = await supabase
      .from('maintenances')
      .select(`
        *,
        vehicles (
          brand,
          model,
          license_plate
        )
      `)
      .order('date', { ascending: false })
    
    if (maintenanceError) throw maintenanceError
    maintenances.value = maintenancesData || []
  } catch (error) {
    console.error('Error fetching data:', error)
    maintenances.value = []
    vehicles.value = []
  } finally {
    loading.value = false
  }
}

const handleMaintenanceSubmit = async (data: any) => {
  try {
    saving.value = true
    
    if (editingMaintenance.value) {
      const { error } = await supabase
        .from('maintenances')
        .update(data)
        .eq('id', editingMaintenance.value.id)
      
      if (error) throw error
    } else {
      const { error } = await supabase
        .from('maintenances')
        .insert(data)
      
      if (error) throw error
    }
    
    await fetchData()
    showMaintenanceForm.value = false
    editingMaintenance.value = null
  } catch (error) {
    console.error('Error saving maintenance:', error)
  } finally {
    saving.value = false
  }
}

const handleEditMaintenance = (maintenance: any) => {
  editingMaintenance.value = maintenance
  showMaintenanceForm.value = true
}

const handleDeleteMaintenance = (id: string) => {
  maintenanceToDelete.value = id
  showDeleteModal.value = true
}

const confirmDeleteMaintenance = async () => {
  if (!maintenanceToDelete.value) return
  
  try {
    saving.value = true
    const { error } = await supabase
      .from('maintenances')
      .delete()
      .eq('id', maintenanceToDelete.value)
    
    if (error) throw error
    
    await fetchData()
  } catch (error) {
    console.error('Error deleting maintenance:', error)
  } finally {
    showDeleteModal.value = false
    maintenanceToDelete.value = null
    saving.value = false
  }
}

const exportMaintenancePDF = () => {
  const doc = new jsPDF()
  
  // En-tête
  doc.setFontSize(20)
  doc.text('Historique d\'entretien', 14, 20)
  
  const maintenanceData = maintenances.value.map(m => [
    formatDate(m.date),
    m.mileage.toLocaleString(),
    m.type === 'maintenance' ? 'Entretien' : 'Réparation',
    m.description,
    m.garage,
    `${m.cost.toLocaleString()} €`
  ])
  
  doc.autoTable({
    startY: 40,
    head: [['Date', 'Kilométrage', 'Type', 'Description', 'Garage', 'Coût']],
    body: maintenanceData,
    theme: 'grid',
    styles: { fontSize: 8 },
    headStyles: { fillColor: [0, 0, 0] }
  })
  
  doc.save('historique_entretien.pdf')
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
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
            <h1 class="text-2xl font-bold">Entretiens</h1>
            <p class="text-gray-600">Gérez l'historique d'entretien de vos véhicules</p>
          </div>
          
          <div class="flex items-center space-x-4">
            <Button
              v-if="maintenances.length > 0"
              variant="secondary"
              class="!w-auto"
              @click="exportMaintenancePDF"
            >
              <div class="flex items-center space-x-2 px-2">
                <ArrowDownTrayIcon class="w-5 h-5" />
                <span>Exporter PDF</span>
              </div>
            </Button>

            <Button
              variant="primary"
              class="!w-auto"
              @click="showMaintenanceForm = true"
            >
              <div class="flex items-center space-x-2 px-2">
                <PlusIcon class="w-5 h-5" />
                <span>Ajouter un entretien</span>
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

        <div v-if="loading" class="text-center py-12">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-black mx-auto"></div>
        </div>

        <template v-else>
          <div v-if="showMaintenanceForm" class="bg-white rounded-xl p-6 shadow-sm mb-6">
            <h2 class="text-lg font-medium mb-6">
              {{ editingMaintenance ? 'Modifier l\'entretien' : 'Nouvel entretien' }}
            </h2>
            
            <MaintenanceForm
              :vehicle-id="selectedVehicle === 'all' ? '' : selectedVehicle"
              :loading="saving"
              :initial-data="editingMaintenance"
              @submit="handleMaintenanceSubmit"
              @cancel="showMaintenanceForm = false; editingMaintenance = null"
            />
          </div>

          <MaintenanceChart
            v-if="maintenances.length > 0"
            :maintenances="maintenances.filter(m => 
              selectedVehicle === 'all' || m.vehicle_id === selectedVehicle
            )"
            class="mb-6"
          />

          <MaintenanceList
            :maintenances="maintenances.filter(m => 
              selectedVehicle === 'all' || m.vehicle_id === selectedVehicle
            )"
            @edit="handleEditMaintenance"
            @delete="handleDeleteMaintenance"
          />
        </template>

        <ConfirmationModal
          :show="showDeleteModal"
          title="Supprimer l'entretien"
          message="Êtes-vous sûr de vouloir supprimer cet entretien ? Cette action est irréversible."
          @confirm="confirmDeleteMaintenance"
          @cancel="showDeleteModal = false"
        />
      </div>
    </main>
  </div>
</template>