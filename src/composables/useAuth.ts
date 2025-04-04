import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/supabase'

const INACTIVITY_TIMEOUT = 5 * 60 * 1000 // 5 minutes in milliseconds
let inactivityTimer: NodeJS.Timeout

export const useAuth = () => {
  const router = useRouter()
  const user = ref(null)
  const loading = ref(true)
  const error = ref<string | null>(null)

  const resetInactivityTimer = () => {
    if (inactivityTimer) clearTimeout(inactivityTimer)
    inactivityTimer = setTimeout(signOut, INACTIVITY_TIMEOUT)
  }

  const setupInactivityDetection = () => {
    const events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart']
    
    events.forEach(event => {
      window.addEventListener(event, resetInactivityTimer)
    })

    resetInactivityTimer()

    return () => {
      events.forEach(event => {
        window.removeEventListener(event, resetInactivityTimer)
      })
      if (inactivityTimer) clearTimeout(inactivityTimer)
    }
  }

  const signOut = async () => {
    try {
      if (inactivityTimer) clearTimeout(inactivityTimer)
      await supabase.auth.signOut()
      user.value = null
      router.push('/')
    } catch (err: any) {
      error.value = err.message
      console.error('Error signing out:', err)
    }
  }

  const refreshSession = async () => {
    try {
      const { data: { session }, error: refreshError } = await supabase.auth.getSession()
      
      if (refreshError) throw refreshError
      
      if (!session) {
        await signOut()
        return false
      }
      
      return true
    } catch (err) {
      console.error('Error refreshing session:', err)
      await signOut()
      return false
    }
  }

  const initializeAuth = async () => {
    try {
      const { data: { session } } = await supabase.auth.getSession()
      
      if (session) {
        user.value = session.user
        const cleanup = setupInactivityDetection()
        
        // Check if user is on login page
        if (router.currentRoute.value.path === '/') {
          router.push('/dashboard')
        }
        
        return cleanup
      } else if (router.currentRoute.value.path !== '/' && router.currentRoute.value.path !== '/signup') {
        router.push('/')
      }
      
      const { data: { subscription } } = supabase.auth.onAuthStateChange(async (_event, session) => {
        user.value = session?.user || null
        
        if (session) {
          setupInactivityDetection()
          if (router.currentRoute.value.path === '/') {
            router.push('/dashboard')
          }
        } else {
          if (inactivityTimer) clearTimeout(inactivityTimer)
          if (router.currentRoute.value.path !== '/' && router.currentRoute.value.path !== '/signup') {
            router.push('/')
          }
        }
      })

      return () => {
        subscription.unsubscribe()
      }
    } catch (err: any) {
      error.value = err.message
      console.error('Error initializing auth:', err)
    } finally {
      loading.value = false
    }
  }

  return {
    user,
    loading,
    error,
    signOut,
    initializeAuth,
    refreshSession
  }
}