<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/supabase'
import Navbar from '@/components/organisms/Navbar.vue'
import Button from '@/components/atoms/Button.vue'
import MaintenanceTaskList from '@/components/molecules/MaintenanceTaskList.vue'
import MaintenanceRecommendations from '@/components/molecules/MaintenanceRecommendations.vue'
import MaintenanceIntervalForm from '@/components/molecules/MaintenanceIntervalForm.vue'
import MaintenanceForm from '@/components/molecules/MaintenanceForm.vue'
import ConfirmationModal from '@/components/molecules/ConfirmationModal.vue'
import { PlusIcon } from '@heroicons/vue/24/outline'

const route = useRoute()
const router = useRouter()
const loading = ref(true)
const vehicle = ref<any>(null)
const tasks = ref<any[]>([])
const recommendations = ref<any[]>([])
const intervals = ref<any[]>([])
const showIntervalForm = ref(false)
const showMaintenanceForm = ref(false)

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

    // Récupérer les tâches d'entretien
    const { data: tasksData, error: tasksError } = await supabase
      .from('maintenance_tasks')
      .select(`
        *,
        maintenance:maintenances (
          date,
          description
        )
      `)
      .eq('vehicle_id', route.params.id)
      .order('created_at', { ascending: false })
    
    if (tasksError) throw tasksError
    tasks.value = tasksData || []

    // Récupérer les recommandations
    const { data: recommendationsData, error: recommendationsError } = await supabase
      .from('maintenance_recommendations')
      .select('*')
      .eq('vehicle_id', route.params.id)
      .order('mileage_threshold', { ascending: true })
    
    if (recommendationsError) throw recommendationsError
    recommendations.value = recommendationsData || []

    // Récupérer les intervalles d'entretien
    const { data: intervalsData, error: intervalsError } = await supabase
      .from('maintenance_intervals')
      .select('*')
      .eq('vehicle_id', route.params.id)
      .order('created_at', { ascending: false })
    
    if (intervalsError) throw intervalsError
    intervals.value = intervalsData || []
  } catch (error) {
    console.error('Error fetching data:', error)
    router.push('/maintenance')
  } finally {
    loading.value = false
  }
}

const handleTaskStatusUpdate = async (taskId: string, status: string) => {
  try {
    const { error } = await supabase
      .from('maintenance_tasks')
      .update({ status })
      .eq('id', taskId)
    
    if (error) throw error
    await fetchData()
  } catch (error) {
    console.error('Error updating task status:', error)
  }
}

const handleIntervalSubmit = async (data: any) => {
  try {
    const { error } = await supabase
      .from('maintenance_intervals')
      .insert(data)
    
    if (error) throw error
    await fetchData()
    showIntervalForm.value = false
  } catch (error) {
    console.error('Error saving interval:', error)
  }
}

const handleMaintenanceSubmit = async (data: any) => {
  try {
    const { error } = await supabase
      .from('maintenances')
      .insert({
        ...data,
        vehicle_id: vehicle.value.id
      })
    
    if (error) throw error
    await fetchData()
    showMaintenanceForm.value = false
  } catch (error) {
    console.error('Error saving maintenance:', error)
  }
}

onMounted(fetchData)
</script>

<template>
  <div class="flex min-h-screen bg-gray-50">
    <Navbar />
    
    <main class="flex-1 p-8">
      <div class="max-w-7xl mx-auto">
        <div v-if="loading" class="flex items-center justify-center py-12">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-black"></div>
        </div>

        <template v-else-if="vehicle">
          <!-- En-tête -->
          <div class="flex justify-between items-start mb-8">
            <div>
              <h1 class="text-2xl font-bold">Carnet d'entretien</h1>
              <p class="text-gray-600">
                {{ vehicle.brand }} {{ vehicle.model }} - {{ vehicle.license_plate }}
              </p>
            </div>
            
            <div class="flex items-center space-x-4">
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

          <!-- Contenu principal -->
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <!-- Colonne de gauche : Tâches et intervalles -->
            <div class="space-y-6">
              <!-- Tâches en cours -->
              <div class="bg-white rounded-xl p-6 shadow-sm">
                <div class="flex justify-between items-center mb-4">
                  <h2 class="text-lg font-medium">Tâches en cours</h2>
                </div>
                
                <MaintenanceTaskList
                  :tasks="tasks.filter(t => t.status === 'pending')"
                  @update:status="handleTaskStatusUpdate"
                />
              </div>

              <!-- Intervalles d'entretien -->
              <div class="bg-white rounded-xl p-6 shadow-sm">
                <div class="flex justify-between items-center mb-4">
                  <h2 class="text-lg font-medium">Intervalles d'entretien</h2>
                  <Button
                    variant="secondary"
                    class="!w-auto"
                    @click="showIntervalForm = true"
                  >
                    <PlusIcon class="w-5 h-5" />
                  </Button>
                </div>

                <div v-if="showIntervalForm" class="mb-6">
                  <MaintenanceIntervalForm
                    :vehicle-id="vehicle.id"
                    @submit="handleIntervalSubmit"
                    @cancel="showIntervalForm = false"
                  />
                </div>

                <div v-else class="space-y-4">
                  <div
                    v-for="interval in intervals"
                    :key="interval.id"
                    class="p-4 bg-gray-50 rounded-lg"
                  >
                    <h3 class="font-medium">{{ interval.task_name }}</h3>
                    <div class="mt-2 space-y-1 text-sm text-gray-600">
                      <p v-if="interval.kilometers">
                        Tous les {{ interval.kilometers.toLocaleString() }} km
                      </p>
                      <p v-if="interval.months">
                        Tous les {{ interval.months }} mois
                      </p>
                    </div>
                    <p v-if="interval.description" class="mt-2 text-sm text-gray-500">
                      {{ interval.description }}
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Colonne centrale : Recommandations -->
            <div class="space-y-6">
              <div class="bg-white rounded-xl p-6 shadow-sm">
                <h2 class="text-lg font-medium mb-4">Recommandations</h2>
                <MaintenanceRecommendations
                  :recommendations="recommendations"
                  :current-mileage="vehicle.mileage"
                />
              </div>
            </div>

            <!-- Colonne de droite : Historique -->
            <div class="space-y-6">
              <div class="bg-white rounded-xl p-6 shadow-sm">
                <h2 class="text-lg font-medium mb-4">Historique</h2>
                <div class="space-y-4">
                  <div
                    v-for="task in tasks.filter(t => t.status !== 'pending')"
                    :key="task.id"
                    class="p-4 rounded-lg"
                    :class="{
                      'bg-green-50': task.status === 'completed',
                      'bg-red-50': task.status === 'skipped'
                    }"
                  >
                    <div class="flex justify-between">
                      <h3 class="font-medium">{{ task.task_name }}</h3>
                      <span
                        class="text-sm font-medium px-2 py-1 rounded-full"
                        :class="{
                          'bg-green-100 text-green-700': task.status === 'completed',
                          'bg-red-100 text-red-700': task.status === 'skipped'
                        }"
                      >
                        {{ task.status === 'completed' ? 'Terminé' : 'Ignoré' }}
                      </span>
                    </div>
                    <p v-if="task.notes" class="mt-2 text-sm text-gray-600">
                      {{ task.notes }}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Formulaire d'ajout d'entretien -->
          <div
            v-if="showMaintenanceForm"
            class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50"
          >
            <div class="bg-white rounded-xl p-6 max-w-2xl w-full">
              <h2 class="text-lg font-medium mb-6">Nouvel entretien</h2>
              <MaintenanceForm
                :vehicle-id="vehicle.id"
                @submit="handleMaintenanceSubmit"
                @cancel="showMaintenanceForm = false"
              />
            </div>
          </div>
        </template>
      </div>
    </main>
  </div>
</template>