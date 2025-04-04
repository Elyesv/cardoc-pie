<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { supabase } from '@/supabase'
import Navbar from '@/components/organisms/Navbar.vue'
import FullCalendar from '@fullcalendar/vue3'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import interactionPlugin from '@fullcalendar/interaction'
import listPlugin from '@fullcalendar/list'
import frLocale from '@fullcalendar/core/locales/fr'
import {
  WrenchIcon,
  ShieldCheckIcon,
  ClipboardDocumentCheckIcon,
  EyeIcon,
  EyeSlashIcon
} from '@heroicons/vue/24/outline'

const calendarRef = ref()
const loading = ref(true)
const events = ref<any[]>([])
const vehicles = ref<any[]>([])
const selectedVehicle = ref('all')
const showMaintenances = ref(true)
const showInsurances = ref(true)
const showInspections = ref(true)

// Types d'événements et leurs couleurs
const eventTypes = {
  maintenance: { color: '#3B82F6', icon: WrenchIcon, label: 'Entretien' },
  insurance: { color: '#10B981', icon: ShieldCheckIcon, label: 'Assurance' },
  inspection: { color: '#EF4444', icon: ClipboardDocumentCheckIcon, label: 'Contrôle technique' }
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
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

const fetchEvents = async () => {
  try {
    loading.value = true
    
    // Récupérer les véhicules
    const { data: vehiclesData } = await supabase
      .from('vehicles')
      .select('id, brand, model, license_plate')
    
    vehicles.value = vehiclesData || []

    // Récupérer les entretiens
    const { data: maintenances } = await supabase
      .from('maintenances')
      .select(`
        *,
        vehicles (brand, model, license_plate)
      `)
    
    // Récupérer les assurances
    const { data: insurances } = await supabase
      .from('insurance_policies')
      .select(`
        *,
        vehicles (brand, model, license_plate)
      `)
    
    // Récupérer les contrôles techniques
    const { data: inspections } = await supabase
      .from('technical_inspections')
      .select(`
        *,
        vehicles (brand, model, license_plate)
      `)

    // Formater les événements
    const formattedEvents = [
      ...(maintenances || []).map(m => ({
        id: m.id,
        type: 'maintenance',
        title: `Entretien - ${m.vehicles.brand} ${m.vehicles.model}`,
        start: m.date,
        description: m.description,
        vehicle_id: m.vehicle_id,
        backgroundColor: eventTypes.maintenance.color,
        borderColor: eventTypes.maintenance.color,
        extendedProps: {
          type: 'maintenance',
          vehicleName: `${m.vehicles.brand} ${m.vehicles.model}`,
          details: m.description,
          cost: m.cost
        }
      })),
      ...(insurances || []).map(i => ({
        id: i.id,
        type: 'insurance',
        title: `Assurance - ${i.vehicles.brand} ${i.vehicles.model}`,
        start: i.start_date,
        end: i.end_date,
        description: `${i.provider} - ${i.type}`,
        vehicle_id: i.vehicle_id,
        backgroundColor: eventTypes.insurance.color,
        borderColor: eventTypes.insurance.color,
        extendedProps: {
          type: 'insurance',
          vehicleName: `${i.vehicles.brand} ${i.vehicles.model}`,
          details: `${i.provider} - ${i.type}`,
          cost: i.cost
        }
      })),
      ...(inspections || []).map(i => ({
        id: i.id,
        type: 'inspection',
        title: `Contrôle technique - ${i.vehicles.brand} ${i.vehicles.model}`,
        start: i.date,
        description: `${i.center} - ${i.status}`,
        vehicle_id: i.vehicle_id,
        backgroundColor: eventTypes.inspection.color,
        borderColor: eventTypes.inspection.color,
        extendedProps: {
          type: 'inspection',
          vehicleName: `${i.vehicles.brand} ${i.vehicles.model}`,
          details: `${i.center} - ${i.status}`,
          cost: i.cost
        }
      }))
    ]

    events.value = formattedEvents
  } catch (error) {
    console.error('Error fetching events:', error)
  } finally {
    loading.value = false
  }
}

const filteredEvents = computed(() => {
  let filtered = events.value

  // Filtre par véhicule
  if (selectedVehicle.value !== 'all') {
    filtered = filtered.filter(event => event.vehicle_id === selectedVehicle.value)
  }

  // Filtre par type d'événement
  filtered = filtered.filter(event => {
    switch (event.type) {
      case 'maintenance':
        return showMaintenances.value
      case 'insurance':
        return showInsurances.value
      case 'inspection':
        return showInspections.value
      default:
        return true
    }
  })

  return filtered
})

const calendarOptions = computed(() => ({
  plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin],
  initialView: 'dayGridMonth',
  locale: frLocale,
  headerToolbar: {
    left: 'prev,next today',
    center: 'title',
    right: 'dayGridMonth,timeGridWeek,listWeek'
  },
  events: filteredEvents.value,
  eventClick: handleEventClick,
  height: 'auto',
  dayMaxEvents: true,
  eventTimeFormat: {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  }
}))

const handleEventClick = (info: any) => {
  const event = info.event
  const props = event.extendedProps
  
  alert(`
    ${event.title}
    Date: ${new Date(event.start).toLocaleDateString()}
    ${props.details}
    Coût: ${props.cost}€
  `)
}

const toggleEventType = (type: string) => {
  switch (type) {
    case 'maintenance':
      showMaintenances.value = !showMaintenances.value
      break
    case 'insurance':
      showInsurances.value = !showInsurances.value
      break
    case 'inspection':
      showInspections.value = !showInspections.value
      break
  }
}

onMounted(fetchEvents)
</script>

<template>
  <div class="flex min-h-screen bg-gray-50">
    <Navbar />
    
    <main class="flex-1 p-8">
      <div class="max-w-7xl mx-auto space-y-6">
        <!-- En-tête -->
        <div class="flex justify-between items-start">
          <div>
            <h1 class="text-2xl font-bold">Calendrier</h1>
            <p class="text-gray-600">Suivez vos échéances et entretiens</p>
          </div>
        </div>

        <!-- Calendrier -->
        <div class="bg-white rounded-lg shadow-sm p-6">
          <div v-if="loading" class="h-full flex items-center justify-center">
            <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-black"></div>
          </div>
          
          <FullCalendar
            v-else
            ref="calendarRef"
            :options="calendarOptions"
            class="fc-theme-standard"
          />
        </div>

        <!-- Filtres et statistiques -->
        <div class="bg-white rounded-lg shadow-sm p-6">
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <!-- Filtres -->
            <div class="space-y-4">
              <h3 class="text-sm font-medium text-gray-500">Filtres</h3>
              
              <div class="space-y-2">
                <select
                  v-model="selectedVehicle"
                  class="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-lg text-sm"
                >
                  <option value="all">Tous les véhicules</option>
                  <option
                    v-for="vehicle in vehicles"
                    :key="vehicle.id"
                    :value="vehicle.id"
                  >
                    {{ vehicle.brand }} {{ vehicle.model }}
                  </option>
                </select>
              </div>
            </div>

            <!-- Types d'événements -->
            <div class="space-y-4">
              <h3 class="text-sm font-medium text-gray-500">Types d'événements</h3>
              <div class="space-y-3">
                <button
                  v-for="(type, key) in eventTypes"
                  :key="key"
                  class="flex items-center justify-between w-full p-2 rounded hover:bg-gray-50"
                  @click="toggleEventType(key)"
                >
                  <div class="flex items-center space-x-2">
                    <div
                      class="w-3 h-3 rounded-full"
                      :style="{ backgroundColor: type.color }"
                    ></div>
                    <span class="text-sm text-gray-600">{{ type.label }}</span>
                  </div>
                  <component
                    :is="key === 'maintenance' ? (showMaintenances ? EyeIcon : EyeSlashIcon) :
                         key === 'insurance' ? (showInsurances ? EyeIcon : EyeSlashIcon) :
                         (showInspections ? EyeIcon : EyeSlashIcon)"
                    class="w-4 h-4 text-gray-400"
                  />
                </button>
              </div>
            </div>

            <!-- Statistiques -->
            <div class="space-y-4">
              <h3 class="text-sm font-medium text-gray-500">Statistiques</h3>
              <div class="space-y-2 text-sm text-gray-600">
                <p>Total événements : {{ filteredEvents.length }}</p>
                <p>Maintenances : {{ filteredEvents.filter(e => e.type === 'maintenance').length }}</p>
                <p>Assurances : {{ filteredEvents.filter(e => e.type === 'insurance').length }}</p>
                <p>Contrôles : {{ filteredEvents.filter(e => e.type === 'inspection').length }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<style>
.fc {
  max-width: 100%;
}

.fc .fc-toolbar {
  @apply mb-4;
}

.fc .fc-toolbar-title {
  @apply text-xl font-semibold;
}

.fc .fc-button {
  @apply bg-white border border-gray-300 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500;
}

.fc .fc-button-primary:not(:disabled).fc-button-active,
.fc .fc-button-primary:not(:disabled):active {
  @apply bg-gray-100 border-gray-300 text-gray-900;
}

.fc .fc-daygrid-day {
  @apply border border-gray-200;
}

.fc .fc-daygrid-day-number {
  @apply text-sm text-gray-600 p-2;
}

.fc .fc-event {
  @apply cursor-pointer border-0 rounded px-2 py-1;
}

.fc .fc-event-title {
  @apply text-sm font-medium;
}

.fc .fc-event-time {
  @apply text-xs opacity-75;
}

.fc .fc-list-event {
  @apply cursor-pointer;
}

.fc .fc-list-event-title {
  @apply text-sm;
}

.fc .fc-list-event-time {
  @apply text-xs;
}

/* Responsive adjustments */
@media (max-width: 1024px) {
  .fc .fc-toolbar {
    @apply flex-col space-y-2;
  }
  
  .fc .fc-toolbar-title {
    @apply text-lg;
  }
}
</style>