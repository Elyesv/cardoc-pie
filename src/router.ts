import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from './supabase'
import routes from '~pages'

// Import pages statically to avoid dynamic import issues
import VehiclePage from './pages/vehicles/[id].vue'
import VehicleEditPage from './pages/vehicles/[id]/edit.vue'
import NotFoundPage from './pages/404.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    ...routes,
    {
      path: '/vehicles/:id',
      component: VehiclePage
    },
    {
      path: '/vehicles/:id/edit',
      component: VehicleEditPage
    },
    {
      path: '/:pathMatch(.*)*',
      component: NotFoundPage
    }
  ]
})

// Navigation guard
router.beforeEach(async (to, from, next) => {
  try {
    const { data: { session }, error } = await supabase.auth.getSession()
    
    // If there's an error or no session, and we're not going to a public page,
    // redirect to login
    const publicPages = ['/', '/signup']
    const authRequired = !publicPages.includes(to.path)

    if (error || (!session && authRequired)) {
      // Clear any existing session data
      await supabase.auth.signOut()
      return next('/')
    }

    // If we have a session and trying to access a public page,
    // redirect to dashboard
    if (session && publicPages.includes(to.path)) {
      return next('/dashboard')
    }

    next()
  } catch (error) {
    console.error('Navigation error:', error)
    next('/')
  }
})

export default router