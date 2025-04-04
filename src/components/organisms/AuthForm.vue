<script setup lang="ts">
import { ref } from 'vue'
import FormField from '../molecules/FormField.vue'
import Button from '../atoms/Button.vue'

const props = defineProps<{
  type: 'login' | 'signup'
  loading?: boolean
}>()

const emit = defineEmits<{
  (e: 'submit', data: {
    email: string
    password: string
    firstName?: string
    lastName?: string
    confirmPassword?: string
  }): void
}>()

const email = ref('')
const password = ref('')
const firstName = ref('')
const lastName = ref('')
const confirmPassword = ref('')

const handleSubmit = () => {
  if (props.type === 'login') {
    emit('submit', { email: email.value, password: password.value })
  } else {
    emit('submit', {
      email: email.value,
      password: password.value,
      firstName: firstName.value,
      lastName: lastName.value,
      confirmPassword: confirmPassword.value
    })
  }
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="space-y-6">
    <template v-if="type === 'signup'">
      <div class="grid grid-cols-2 gap-4">
        <FormField
          label="Prénom"
          v-model="firstName"
          placeholder="Votre prénom"
          required
        />
        <FormField
          label="Nom"
          v-model="lastName"
          placeholder="Votre nom"
          required
        />
      </div>
    </template>

    <FormField
      label="Email"
      type="email"
      v-model="email"
      placeholder="Votre email"
      required
    />

    <FormField
      label="Mot de passe"
      type="password"
      v-model="password"
      placeholder="Votre mot de passe"
      required
    />

    <template v-if="type === 'signup'">
      <FormField
        label="Confirmer le mot de passe"
        type="password"
        v-model="confirmPassword"
        placeholder="Confirmez votre mot de passe"
        required
      />
    </template>

    <div class="space-y-4">
      <Button type="submit" variant="primary" :loading="loading">
        {{ type === 'login' ? 'Se connecter' : 'Créer mon compte' }}
      </Button>

      <Button variant="secondary">
        <div class="flex items-center justify-center space-x-2">
          <svg class="w-5 h-5" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
          </svg>
          <span>Continuer avec Google</span>
        </div>
      </Button>
    </div>
  </form>
</template>