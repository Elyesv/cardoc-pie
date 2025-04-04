import { createClient } from '@supabase/supabase-js'

// S'assurer que les URLs sont valides et présentes
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Les variables d\'environnement Supabase sont manquantes')
}

// Vérifier que l'URL est valide
try {
  new URL(supabaseUrl)
} catch (e) {
  throw new Error('L\'URL Supabase est invalide')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: false // Désactiver la détection automatique de session dans l'URL
  }
})