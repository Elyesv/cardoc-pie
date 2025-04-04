<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../supabase'
import AuthLayout from '../components/organisms/AuthLayout.vue'
import AuthForm from '../components/organisms/AuthForm.vue'

const router = useRouter()
const loading = ref(false)
const errorMsg = ref('')

const handleSignup = async (data: {
  email: string
  password: string
  firstName: string
  lastName: string
  confirmPassword: string
}) => {
  if (data.password !== data.confirmPassword) {
    errorMsg.value = 'Les mots de passe ne correspondent pas'
    return
  }

  try {
    loading.value = true
    const { error } = await supabase.auth.signUp({
      email: data.email,
      password: data.password,
      options: {
        data: {
          first_name: data.firstName,
          last_name: data.lastName
        }
      }
    })

    if (error) throw error
    router.push('/dashboard')
  } catch (error: any) {
    errorMsg.value = error.message
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <AuthLayout
    title="Créer un compte"
    subtitle="Remplissez les informations ci-dessous"
    heroTitle="Rejoignez<br>Cardoc"
    heroSubtitle="Créez votre compte et commencez à gérer<br>vos véhicules dès aujourd'hui."
  >
    <AuthForm
      type="signup"
      :loading="loading"
      @submit="handleSignup"
    />
    
    <p v-if="errorMsg" class="text-red-600 text-center mt-4">{{ errorMsg }}</p>

    <p class="text-center text-sm text-gray-600 mt-6">
      Vous avez déjà un compte ?
      <router-link to="/" class="font-medium text-gray-900">
        Se connecter
      </router-link>
    </p>
  </AuthLayout>
</template>