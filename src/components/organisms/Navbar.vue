<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { 
  HomeIcon, 
  UserIcon, 
  CalendarIcon,
  ShieldCheckIcon,
  Squares2X2Icon,
  WrenchIcon,
  ChartBarIcon,
  Bars3Icon,
  XMarkIcon,
  ClipboardDocumentCheckIcon
} from '@heroicons/vue/24/outline'

const route = useRoute()
const isMenuOpen = ref(false)

const navigation = [
  { 
    title: 'Principal',
    items: [
      { to: '/dashboard', icon: HomeIcon, label: 'Tableau de bord' },
      { to: '/vehicles', icon: Squares2X2Icon, label: 'Mes véhicules' }
    ]
  },
  {
    title: 'Suivi',
    items: [
      { to: '/maintenance', icon: WrenchIcon, label: 'Carnet d\'entretien' },
      { to: '/insurance', icon: ShieldCheckIcon, label: 'Assurances' },
      { to: '/technical-inspection', icon: ClipboardDocumentCheckIcon, label: 'Contrôles techniques' }
    ]
  },
  {
    title: 'Planification',
    items: [
      { to: '/calendar', icon: CalendarIcon, label: 'Calendrier' }
    ]
  },
  {
    title: 'Analyse',
    items: [
      { to: '/statistics', icon: ChartBarIcon, label: 'Statistiques' }
    ]
  }
]

const currentSection = computed(() => {
  const currentPath = route.path
  return navigation.find(section => 
    section.items.some(item => item.to === currentPath)
  )?.title || ''
})

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value
}
</script>

<template>
  <!-- Version mobile -->
  <div class="lg:hidden">
    <div class="fixed top-0 left-0 right-0 h-16 bg-white border-b border-gray-200 px-4 flex items-center justify-between z-50">
      <h1 class="text-xl font-bold">Cardoc</h1>
      <button @click="toggleMenu" class="p-2">
        <Bars3Icon v-if="!isMenuOpen" class="w-6 h-6" />
        <XMarkIcon v-else class="w-6 h-6" />
      </button>
    </div>

    <!-- Menu mobile -->
    <div
      v-if="isMenuOpen"
      class="fixed inset-0 bg-black bg-opacity-50 z-40"
      @click="isMenuOpen = false"
    >
      <div
        class="absolute top-16 left-0 w-64 bg-white h-[calc(100vh-4rem)] p-6 overflow-y-auto"
        @click.stop
      >
        <div v-for="section in navigation" :key="section.title" class="mb-8">
          <h2 class="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-4">
            {{ section.title }}
          </h2>
          <div class="space-y-2">
            <router-link
              v-for="item in section.items"
              :key="item.to"
              :to="item.to"
              :class="[
                'flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors',
                route.path === item.to
                  ? 'bg-black text-white'
                  : 'text-gray-600 hover:bg-gray-100'
              ]"
              @click="isMenuOpen = false"
            >
              <component :is="item.icon" class="w-5 h-5" />
              <span class="font-medium">{{ item.label }}</span>
            </router-link>
          </div>
        </div>

        <!-- Profil en bas -->
        <div class="absolute bottom-0 left-0 right-0 p-4 border-t border-gray-200 bg-white">
          <router-link
            to="/profile"
            class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-gray-100"
            @click="isMenuOpen = false"
          >
            <UserIcon class="w-5 h-5" />
            <span class="font-medium">Profil</span>
          </router-link>
        </div>
      </div>
    </div>
  </div>

  <!-- Version desktop -->
  <nav class="hidden lg:block fixed left-0 top-0 bottom-0 w-64 bg-white border-r border-gray-200 z-50">
    <div class="h-full flex flex-col">
      <!-- En-tête -->
      <div class="p-6">
        <h1 class="text-2xl font-bold">Cardoc</h1>
        <p class="text-sm text-gray-500 mt-1">{{ currentSection }}</p>
      </div>

      <!-- Navigation -->
      <div class="flex-1 px-4 py-2 overflow-y-auto">
        <div v-for="section in navigation" :key="section.title" class="mb-8">
          <h2 class="text-xs font-semibold text-gray-400 uppercase tracking-wider px-2 mb-4">
            {{ section.title }}
          </h2>
          <div class="space-y-1">
            <router-link
              v-for="item in section.items"
              :key="item.to"
              :to="item.to"
              :class="[
                'flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors',
                route.path === item.to
                  ? 'bg-black text-white'
                  : 'text-gray-600 hover:bg-gray-100'
              ]"
            >
              <component :is="item.icon" class="w-5 h-5" />
              <span class="font-medium">{{ item.label }}</span>
            </router-link>
          </div>
        </div>
      </div>

      <!-- Profil -->
      <div class="p-4 border-t border-gray-200">
        <router-link
          to="/profile"
          :class="[
            'flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors',
            route.path === '/profile'
              ? 'bg-black text-white'
              : 'text-gray-600 hover:bg-gray-100'
          ]"
        >
          <UserIcon class="w-5 h-5" />
          <span class="font-medium">Profil</span>
        </router-link>
      </div>
    </div>
  </nav>
</template>