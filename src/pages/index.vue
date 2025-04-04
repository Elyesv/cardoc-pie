<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../supabase'
import AuthLayout from '../components/organisms/AuthLayout.vue'
import AuthForm from '../components/organisms/AuthForm.vue'

const router = useRouter()
const loading = ref(false)
const errorMsg = ref('')

const handleLogin = async (data: { email: string; password: string }) => {
  try {
    loading.value = true
    const { error } = await supabase.auth.signInWithPassword({
      email: data.email,
      password: data.password,
      options: {
        persistSession: true // Active la persistance de session
      }
    })

    if (error) throw error
    router.push('/dashboard')
  } catch (error: any) {
    errorMsg.value = 'Email ou mot de passe incorrect'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <AuthLayout
    title="Bon retour!"
    subtitle="Connectez-vous pour accéder à votre compte"
    heroTitle="Tout gérer<br>Simplement"
    heroSubtitle="Gardez une trace de l'entretien de vos véhicules<br>en toute simplicité."
  >
    <AuthForm
      type="login"
      :loading="loading"
      @submit="handleLogin"
    />
    
    <p v-if="errorMsg" class="text-red-600 text-center mt-4">{{ errorMsg }}</p>

    <p class="text-center text-sm text-gray-600 mt-6">
      Vous n'avez pas de compte ?
      <router-link to="/signup" class="font-medium text-gray-900">
        S'inscrire
      </router-link>
    </p>
  </AuthLayout>
</template>