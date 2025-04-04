<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '@/supabase'
import { jsPDF } from 'jspdf'
import 'jspdf-autotable'
import Navbar from '@/components/organisms/Navbar.vue'
import Button from '@/components/atoms/Button.vue'
import MaintenanceForm from '@/components/molecules/MaintenanceForm.vue'
import MaintenanceList from '@/components/molecules/MaintenanceList.vue'
import MaintenanceChart from '@/components/molecules/MaintenanceChart.vue'
import ConfirmationModal from '@/components/molecules/ConfirmationModal.vue'
import FuelLogForm from '@/components/molecules/FuelLogForm.vue'
import FuelConsumptionStats from '@/components/molecules/FuelConsumptionStats.vue'
import {
  WrenchIcon,
  CalendarIcon,
  HashtagIcon,
  SwatchIcon,
  BoltIcon,
  UserGroupIcon,
  TrashIcon,
  PlusIcon,
  ArrowDownTrayIcon
} from '@heroicons/vue/24/outline'

const router = useRouter()
const route = useRoute()
const loading = ref(true)
const vehicle = ref<any>(null)
const maintenances = ref<any[]>([])
const showMaintenanceForm = ref(false)
const showDeleteModal = ref(false)
const showDeleteMaintenanceModal = ref(false)
const savingMaintenance = ref(false)
const editingMaintenance = ref(null)
const maintenanceToDelete = ref<string | null>(null)
const fuelLogs = ref<any[]>([])
const showFuelForm = ref(false)
const savingFuel = ref(false)

const maintenanceStats = computed(() => {
  if (!maintenances.value.length) return null

  const total = maintenances.value.reduce((sum, m) => sum + m.cost, 0)
  const average = total / maintenances.value.length
  const sortedDates = [...maintenances.value].sort((a, b) => 
    new Date(b.date).getTime() - new Date(a.date).getTime()
  )
  const lastDate = sortedDates[0]?.date
  // Simulate next maintenance date (6 months after last maintenance)
  const nextDate = lastDate ? 
    new Date(new Date(lastDate).setMonth(new Date(lastDate).getMonth() + 6)).toISOString().split('T')[0] 
    : null

  return {
    total,
    average,
    lastDate,
    nextDate
  }
})

const formatLicensePlate = (plate: string) => {
  // Supprime tous les caractères non alphanumériques
  const cleaned = plate.replace(/[^A-Z0-9]/gi, '').toUpperCase()
  
  if (cleaned.length === 7) {
    // Format XX-111-XX
    return `${cleaned.slice(0, 2)}-${cleaned.slice(2, 5)}-${cleaned.slice(5, 7)}`
  }
  return plate
}

const formatDate = (date: string) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const fetchVehicle = async () => {
  try {
    loading.value = true
    const { data: vehicleData, error: vehicleError } = await supabase
      .from('vehicles')
      .select('*')
      .eq('id', route.params.id)
      .single()

    if (vehicleError) throw vehicleError
    vehicle.value = vehicleData

    const { data: maintenanceData, error: maintenanceError } = await supabase
      .from('maintenances')
      .select('*')
      .eq('vehicle_id', route.params.id)
      .order('date', { ascending: false })

    if (maintenanceError) throw maintenanceError
    maintenances.value = maintenanceData

    // Fetch fuel logs
    const { data: fuelData, error: fuelError } = await supabase
      .from('fuel_logs')
      .select('*')
      .eq('vehicle_id', route.params.id)
      .order('date', { ascending: false })

    if (fuelError) throw fuelError
    fuelLogs.value = fuelData || []
  } catch (error) {
    console.error('Error fetching vehicle:', error)
    router.push('/dashboard')
  } finally {
    loading.value = false
  }
}

const handleMaintenanceSubmit = async (data: any) => {
  try {
    savingMaintenance.value = true
    
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
    
    await fetchVehicle()
    showMaintenanceForm.value = false
    editingMaintenance.value = null
  } catch (error) {
    console.error('Error saving maintenance:', error)
  } finally {
    savingMaintenance.value = false
  }
}

const handleEditMaintenance = (maintenance: any) => {
  editingMaintenance.value = maintenance
  showMaintenanceForm.value = true
}

const handleDeleteMaintenance = (id: string) => {
  maintenanceToDelete.value = id
  showDeleteMaintenanceModal.value = true
}

const confirmDeleteMaintenance = async () => {
  if (!maintenanceToDelete.value) return
  
  try {
    const { error } = await supabase
      .from('maintenances')
      .delete()
      .eq('id', maintenanceToDelete.value)
    
    if (error) throw error
    
    await fetchVehicle()
  } catch (error) {
    console.error('Error deleting maintenance:', error)
  } finally {
    showDeleteMaintenanceModal.value = false
    maintenanceToDelete.value = null
  }
}

const handleDeleteVehicle = () => {
  showDeleteModal.value = true
}

const confirmDeleteVehicle = async () => {
  try {
    const { error } = await supabase
      .from('vehicles')
      .delete()
      .eq('id', route.params.id)
    
    if (error) throw error
    
    router.push('/dashboard')
  } catch (error) {
    console.error('Error deleting vehicle:', error)
  } finally {
    showDeleteModal.value = false
  }
}

const handleShare = () => {
  router.push(`/vehicles/${route.params.id}/share`)
}

const handleFuelSubmit = async (data: any) => {
  try {
    savingFuel.value = true
    const { error } = await supabase
      .from('fuel_logs')
      .insert(data)
    
    if (error) throw error
    
    await fetchVehicle()
    showFuelForm.value = false
  } catch (error) {
    console.error('Error saving fuel log:', error)
  } finally {
    savingFuel.value = false
  }
}

const exportMaintenancePDF = () => {
  const doc = new jsPDF()
  
  // En-tête
  doc.setFontSize(20)
  doc.text(`Historique d'entretien - ${vehicle.value.brand} ${vehicle.value.model}`, 14, 20)
  doc.setFontSize(12)
  doc.text(`Immatriculation : ${formatLicensePlate(vehicle.value.license_plate)}`, 14, 30)
  
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
  
  // Statistiques
  if (maintenanceStats.value) {
    const finalY = (doc as any).lastAutoTable.finalY || 40
    doc.text('Statistiques', 14, finalY + 20)
    doc.text(`Coût total : ${maintenanceStats.value.total.toLocaleString()} €`, 14, finalY + 30)
    doc.text(`Coût moyen : ${maintenanceStats.value.average.toFixed(2)} €`, 14, finalY + 40)
  }
  
  doc.save(`entretien_${vehicle.value.brand}_${vehicle.value.model}.pdf`)
}

onMounted(fetchVehicle)
</script>

<template>
  <div class="flex min-h-screen bg-gray-50">
    <Navbar />
    
    <main class="flex-1 p-8">
      <div class="max-w-4xl mx-auto">
        <!-- Loading state -->
        <div v-if="loading" class="flex items-center justify-center min-h-[60vh]">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-black"></div>
        </div>

        <!-- Vehicle details -->
        <template v-else-if="vehicle">
          <!-- Header -->
          <div class="flex justify-between items-center mb-8">
            <div>
              <h1 class="text-3xl font-bold">{{ vehicle.brand }} {{ vehicle.model }}</h1>
              <p class="text-gray-600 mt-2">{{ formatLicensePlate(vehicle.license_plate) }}</p>
            </div>
            <div class="flex items-center space-x-4">
              <Button
                variant="secondary"
                @click="handleShare"
                class="!w-auto"
              >
                Partager la fiche
              </Button>
              <button
                @click="router.push('/dashboard')"
                class="px-4 py-2 text-gray-600 hover:text-gray-900"
              >
                Retour
              </button>
              <button
                @click="handleDeleteVehicle"
                class="flex items-center space-x-2 px-4 py-2 text-red-600 hover:text-red-700"
              >
                <TrashIcon class="w-5 h-5" />
                <span>Supprimer</span>
              </button>
            </div>
          </div>

          <!-- Main content -->
          <div class="space-y-6">
            <!-- Vehicle Info -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
              <!-- Left column with image -->
              <div class="md:col-span-2">
                <div class="bg-white rounded-xl overflow-hidden shadow-sm h-[400px]">
                  <img
                    :src="vehicle.image_url || 'https://placehold.co/800x600/e5e7eb/a3a3a3?text=Aucune+image'"
                    :alt="`${vehicle.brand} ${vehicle.model}`"
                    class="w-full h-full object-cover"
                    @error="$event.target.src = 'https://placehold.co/800x600/e5e7eb/a3a3a3?text=Erreur+de+chargement'"
                  />
                </div>
              </div>

              <!-- Right column with details -->
              <div class="bg-white rounded-xl p-6 shadow-sm space-y-6">
                <!-- Vehicle info -->
                <div class="grid grid-cols-2 gap-4">
                  <div class="space-y-1">
                    <div class="text-sm text-gray-500">Kilométrage</div>
                    <div class="flex items-center text-gray-900">
                      <WrenchIcon class="w-5 h-5 mr-2 text-gray-400" />
                      {{ vehicle.mileage.toLocaleString() }} km
                    </div>
                  </div>

                  <div class="space-y-1">
                    <div class="text-sm text-gray-500">Année</div>
                    <div class="flex items-center text-gray-900">
                      <CalendarIcon class="w-5 h-5 mr-2 text-gray-400" />
                      {{ vehicle.year }}
                    </div>
                  </div>

                  <div class="space-y-1">
                    <div class="text-sm text-gray-500">Plaque</div>
                    <div class="flex items-center text-gray-900">
                      <HashtagIcon class="w-5 h-5 mr-2 text-gray-400" />
                      {{ formatLicensePlate(vehicle.license_plate) }}
                    </div>
                  </div>

                  <div class="space-y-1">
                    <div class="text-sm text-gray-500">Couleur</div>
                    <div class="flex items-center text-gray-900">
                      <SwatchIcon class="w-5 h-5 mr-2 text-gray-400" />
                      {{ vehicle.color }}
                    </div>
                  </div>

                  <div class="space-y-1">
                    <div class="text-sm text-gray-500">Énergie</div>
                    <div class="flex items-center text-gray-900">
                      <BoltIcon class="w-5 h-5 mr-2 text-gray-400" />
                      {{ vehicle.energy }}
                    </div>
                  </div>

                  <div class="space-y-1">
                    <div class="text-sm text-gray-500">Propriétaires</div>
                    <div class="flex items-center text-gray-900">
                      <UserGroupIcon class="w-5 h-5 mr-2 text-gray-400" />
                      {{ vehicle.number_of_owners }}
                    </div>
                  </div>
                </div>

                <!-- Dates -->
                <div class="border-t pt-4">
                  <h3 class="text-sm font-medium text-gray-900 mb-3">Historique</h3>
                  <div class="space-y-2">
                    <div class="flex justify-between text-sm">
                      <span class="text-gray-500">Première mise en circulation</span>
                      <span class="text-gray-900">{{ formatDate(vehicle.date_of_first_registration) }}</span>
                    </div>
                    <div class="flex justify-between text-sm">
                      <span class="text-gray-500">Date d'achat</span>
                      <span class="text-gray-900">{{ formatDate(vehicle.date_of_purchase) }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Maintenance Stats -->
            <div v-if="maintenanceStats" class="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div class="bg-white p-4 rounded-xl shadow-sm">
                <h3 class="text-xs font-medium text-gray-500 mb-1">Total des coûts</h3>
                <p class="text-2xl font-semibold">{{ maintenanceStats.total.toLocaleString() }} €</p>
              </div>
              
              <div class="bg-white p-4 rounded-xl shadow-sm">
                <h3 class="text-xs font-medium text-gray-500 mb-1">Coût moyen</h3>
                <p class="text-2xl font-semibold">{{ maintenanceStats.average.toFixed(0) }} €</p>
              </div>
              
              <div class="bg-white p-4 rounded-xl shadow-sm">
                <h3 class="text-xs font-medium text-gray-500 mb-1">Dernier entretien</h3>
                <p class="text-2xl font-semibold">{{ formatDate(maintenanceStats.lastDate) }}</p>
              </div>
              
              <div class="bg-white p-4 rounded-xl shadow-sm">
                <h3 class="text-xs font-medium text-gray-500 mb-1">Prochain entretien</h3>
                <p class="text-2xl font-semibold">{{ formatDate(maintenanceStats.nextDate) }}</p>
              </div>
            </div>

            <!-- Maintenance Charts -->
            <MaintenanceChart
              v-if="maintenances.length > 0"
              :maintenances="maintenances"
            />

            <!-- Maintenance Section -->
            <div class="bg-white rounded-xl p-6 shadow-sm">
              <div class="flex justify-between items-center mb-6">
                <h2 class="text-xl font-bold">Historique d'entretien</h2>
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
                    v-if="!showMaintenanceForm"
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

              <MaintenanceForm
                v-if="showMaintenanceForm"
                :vehicle-id="vehicle.id"
                :loading="savingMaintenance"
                :initial-data="editingMaintenance"
                @submit="handleMaintenanceSubmit"
                @cancel="showMaintenanceForm = false; editingMaintenance = null"
              />

              <MaintenanceList
                v-else
                :maintenances="maintenances"
                @edit="handleEditMaintenance"
                @delete="handleDeleteMaintenance"
              />
            </div>

            <!-- Fuel Consumption Section -->
            <div class="bg-white rounded-xl p-6 shadow-sm">
              <div class="flex justify-between items-center mb-6">
                <h2 class="text-xl font-bold">Consommation de carburant</h2>
                <Button
                  v-if="!showFuelForm"
                  variant="primary"
                  class="!w-auto"
                  @click="showFuelForm = true"
                >
                  <div class="flex items-center space-x-2 px-2">
                    <PlusIcon class="w-5 h-5" />
                    <span>Ajouter un plein</span>
                  </div>
                </Button>
              </div>

              <FuelLogForm
                v-if="showFuelForm"
                :vehicle-id="vehicle.id"
                :loading="savingFuel"
                @submit="handleFuelSubmit"
                @cancel="showFuelForm = false"
              />

              <FuelConsumptionStats
                v-else-if="fuelLogs.length > 0"
                :fuel-logs="fuelLogs"
              />

              <div v-else class="text-center py-8">
                <p class="text-gray-500">Aucun historique de carburant</p>
                <p class="text-sm text-gray-400 mt-1">Ajoutez votre premier plein pour commencer à suivre votre consommation</p>
              </div>
            </div>
          </div>
        </template>
      </div>

      <!-- Confirmation Modals -->
      <ConfirmationModal
        :show="showDeleteModal"
        title="Supprimer le véhicule"
        message="Êtes-vous sûr de vouloir supprimer ce véhicule ? Cette action est irréversible."
        @confirm="confirmDeleteVehicle"
        @cancel="showDeleteModal = false"
      />

      <ConfirmationModal
        :show="showDeleteMaintenanceModal"
        title="Supprimer l'entretien"
        message="Êtes-vous sûr de vouloir supprimer cet entretien ?"
        @confirm="confirmDeleteMaintenance"
        @cancel="showDeleteMaintenanceModal = false"
      />
    </main>
  </div>
</template>