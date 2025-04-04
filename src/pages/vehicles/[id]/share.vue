<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/supabase'
import { jsPDF } from 'jspdf'
import 'jspdf-autotable'

const route = useRoute()
const router = useRouter()
const loading = ref(true)
const vehicle = ref<any>(null)
const maintenances = ref<any[]>([])
const inspections = ref<any[]>([])

const fetchData = async () => {
  try {
    loading.value = true
    
    // Récupérer le véhicule
    const { data: vehicleData, error: vehicleError } = await supabase
      .from('vehicles')
      .select('*')
      .eq('id', route.params.id)
      .single()
    
    if (vehicleError) throw vehicleError
    vehicle.value = vehicleData

    // Récupérer les entretiens
    const { data: maintenancesData, error: maintenanceError } = await supabase
      .from('maintenances')
      .select('*')
      .eq('vehicle_id', route.params.id)
      .order('date', { ascending: false })
    
    if (maintenanceError) throw maintenanceError
    maintenances.value = maintenancesData || []

    // Récupérer les contrôles techniques
    const { data: inspectionsData, error: inspectionsError } = await supabase
      .from('technical_inspections')
      .select('*')
      .eq('vehicle_id', route.params.id)
      .order('date', { ascending: false })
    
    if (inspectionsError) throw inspectionsError
    inspections.value = inspectionsData || []
  } catch (error) {
    console.error('Error fetching data:', error)
    router.push('/vehicles')
  } finally {
    loading.value = false
  }
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const formatLicensePlate = (plate: string) => {
  const cleaned = plate.replace(/[^A-Z0-9]/gi, '').toUpperCase()
  if (cleaned.length === 7) {
    return `${cleaned.slice(0, 2)}-${cleaned.slice(2, 5)}-${cleaned.slice(5, 7)}`
  }
  return plate
}

const exportPDF = () => {
  if (!vehicle.value) return

  const doc = new jsPDF()
  
  // En-tête
  doc.setFontSize(24)
  doc.text(`${vehicle.value.brand} ${vehicle.value.model}`, 14, 20)
  
  // Informations du véhicule
  doc.setFontSize(12)
  doc.text('Informations générales', 14, 40)
  
  const vehicleInfo = [
    ['Immatriculation', formatLicensePlate(vehicle.value.license_plate)],
    ['Année', vehicle.value.year.toString()],
    ['Kilométrage', `${vehicle.value.mileage.toLocaleString()} km`],
    ['Énergie', vehicle.value.energy],
    ['Couleur', vehicle.value.color],
    ['Nombre de propriétaires', vehicle.value.number_of_owners.toString()],
    ['Mise en circulation', formatDate(vehicle.value.date_of_first_registration)]
  ]
  
  doc.autoTable({
    startY: 45,
    head: [],
    body: vehicleInfo,
    theme: 'plain',
    styles: { fontSize: 10 }
  })
  
  // Historique d'entretien
  const finalY1 = (doc as any).lastAutoTable.finalY || 45
  doc.text('Historique d\'entretien', 14, finalY1 + 15)
  
  const maintenanceData = maintenances.value.map(m => [
    formatDate(m.date),
    m.mileage.toLocaleString(),
    m.description,
    m.garage,
    `${m.cost.toLocaleString()} €`
  ])
  
  doc.autoTable({
    startY: finalY1 + 20,
    head: [['Date', 'Kilométrage', 'Description', 'Garage', 'Coût']],
    body: maintenanceData,
    theme: 'striped',
    styles: { fontSize: 8 },
    headStyles: { fillColor: [0, 0, 0] }
  })
  
  // Contrôles techniques
  const finalY2 = (doc as any).lastAutoTable.finalY || finalY1 + 20
  doc.text('Contrôles techniques', 14, finalY2 + 15)
  
  const inspectionData = inspections.value.map(i => [
    formatDate(i.date),
    formatDate(i.expiry_date),
    i.center,
    i.status === 'pass' ? 'Validé' : 'À repasser',
    i.notes || '',
    `${i.cost.toLocaleString()} €`
  ])
  
  doc.autoTable({
    startY: finalY2 + 20,
    head: [['Date', 'Expiration', 'Centre', 'Résultat', 'Notes', 'Coût']],
    body: inspectionData,
    theme: 'striped',
    styles: { fontSize: 8 },
    headStyles: { fillColor: [0, 0, 0] }
  })
  
  doc.save(`${vehicle.value.brand}_${vehicle.value.model}_${vehicle.value.license_plate}.pdf`)
}

onMounted(fetchData)
</script>

<template>
  <div class="min-h-screen bg-gray-50 p-8">
    <div class="max-w-4xl mx-auto">
      <div v-if="loading" class="flex items-center justify-center py-12">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-black"></div>
      </div>

      <template v-else-if="vehicle">
        <!-- En-tête -->
        <div class="bg-white rounded-xl p-8 shadow-sm mb-8">
          <div class="flex justify-between items-start">
            <div>
              <h1 class="text-3xl font-bold">{{ vehicle.brand }} {{ vehicle.model }}</h1>
              <p class="text-xl text-gray-600 mt-2">{{ formatLicensePlate(vehicle.license_plate) }}</p>
            </div>
            <button
              @click="exportPDF"
              class="px-6 py-3 bg-black text-white rounded-lg hover:bg-gray-900 transition-colors"
            >
              Télécharger la fiche PDF
            </button>
          </div>

          <!-- Image -->
          <div class="mt-8 aspect-video rounded-lg overflow-hidden bg-gray-100">
            <img
              :src="vehicle.image_url || 'https://placehold.co/800x600/e5e7eb/a3a3a3?text=Aucune+image'"
              :alt="`${vehicle.brand} ${vehicle.model}`"
              class="w-full h-full object-cover"
            />
          </div>
        </div>

        <!-- Informations -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
          <!-- Caractéristiques -->
          <div class="bg-white rounded-xl p-6 shadow-sm">
            <h2 class="text-lg font-medium mb-4">Caractéristiques</h2>
            <dl class="space-y-4">
              <div class="flex justify-between">
                <dt class="text-gray-600">Année</dt>
                <dd class="font-medium">{{ vehicle.year }}</dd>
              </div>
              <div class="flex justify-between">
                <dt class="text-gray-600">Kilométrage</dt>
                <dd class="font-medium">{{ vehicle.mileage.toLocaleString() }} km</dd>
              </div>
              <div class="flex justify-between">
                <dt class="text-gray-600">Énergie</dt>
                <dd class="font-medium">{{ vehicle.energy }}</dd>
              </div>
              <div class="flex justify-between">
                <dt class="text-gray-600">Couleur</dt>
                <dd class="font-medium">{{ vehicle.color }}</dd>
              </div>
              <div class="flex justify-between">
                <dt class="text-gray-600">Propriétaires</dt>
                <dd class="font-medium">{{ vehicle.number_of_owners }}</dd>
              </div>
              <div class="flex justify-between">
                <dt class="text-gray-600">Mise en circulation</dt>
                <dd class="font-medium">{{ formatDate(vehicle.date_of_first_registration) }}</dd>
              </div>
            </dl>
          </div>

          <!-- Entretien -->
          <div class="bg-white rounded-xl p-6 shadow-sm">
            <h2 class="text-lg font-medium mb-4">Entretien</h2>
            <div class="space-y-4">
              <div class="flex justify-between">
                <span class="text-gray-600">Nombre d'entretiens</span>
                <span class="font-medium">{{ maintenances.length }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-600">Dernier entretien</span>
                <span class="font-medium">
                  {{ maintenances[0] ? formatDate(maintenances[0].date) : 'N/A' }}
                </span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-600">Contrôle technique</span>
                <span class="font-medium">
                  {{ inspections[0] ? formatDate(inspections[0].date) : 'N/A' }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Historique -->
        <div class="mt-8 space-y-8">
          <!-- Entretiens -->
          <div class="bg-white rounded-xl p-6 shadow-sm">
            <h2 class="text-lg font-medium mb-4">Historique d'entretien</h2>
            <div class="space-y-4">
              <div
                v-for="maintenance in maintenances"
                :key="maintenance.id"
                class="p-4 bg-gray-50 rounded-lg"
              >
                <div class="flex justify-between">
                  <div>
                    <p class="font-medium">{{ maintenance.description }}</p>
                    <p class="text-sm text-gray-600 mt-1">{{ maintenance.garage }}</p>
                  </div>
                  <div class="text-right">
                    <p class="font-medium">{{ maintenance.cost.toLocaleString() }} €</p>
                    <p class="text-sm text-gray-600 mt-1">
                      {{ formatDate(maintenance.date) }} - {{ maintenance.mileage.toLocaleString() }} km
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Contrôles techniques -->
          <div class="bg-white rounded-xl p-6 shadow-sm">
            <h2 class="text-lg font-medium mb-4">Contrôles techniques</h2>
            <div class="space-y-4">
              <div
                v-for="inspection in inspections"
                :key="inspection.id"
                class="p-4 bg-gray-50 rounded-lg"
              >
                <div class="flex justify-between">
                  <div>
                    <p class="font-medium">{{ inspection.center }}</p>
                    <p class="text-sm text-gray-600 mt-1">
                      {{ inspection.status === 'pass' ? 'Validé' : 'À repasser' }}
                    </p>
                    <p v-if="inspection.notes" class="text-sm text-gray-500 mt-1">
                      {{ inspection.notes }}
                    </p>
                  </div>
                  <div class="text-right">
                    <p class="font-medium">{{ inspection.cost.toLocaleString() }} €</p>
                    <p class="text-sm text-gray-600 mt-1">
                      {{ formatDate(inspection.date) }}
                    </p>
                    <p class="text-sm text-gray-500">
                      Expire le {{ formatDate(inspection.expiry_date) }}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>