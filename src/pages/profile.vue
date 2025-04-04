<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../supabase'
import { useRouter } from 'vue-router'
import Navbar from '../components/organisms/Navbar.vue'
import Button from '../components/atoms/Button.vue'
import FormField from '../components/molecules/FormField.vue'
import { 
  UserIcon, 
  BellIcon, 
  ShieldCheckIcon, 
  KeyIcon,
  DocumentTextIcon,
  TrashIcon
} from '@heroicons/vue/24/outline'

const router = useRouter()
const loading = ref(true)
const saving = ref(false)
const activeTab = ref('personal')
const showDeleteModal = ref(false)
const error = ref('')
const successMessage = ref('')

const formData = ref({
  firstName: '',
  lastName: '',
  email: '',
  phone: '',
  address: '',
  notifications: {
    email: true,
    maintenance: true,
    insurance: true,
    inspection: true
  },
  language: 'fr',
  theme: 'light'
})

const passwordForm = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const showMessage = (message: string, isError = false) => {
  if (isError) {
    error.value = message
    successMessage.value = ''
  } else {
    successMessage.value = message
    error.value = ''
  }
  setTimeout(() => {
    error.value = ''
    successMessage.value = ''
  }, 5000)
}

onMounted(async () => {
  try {
    const { data: { session } } = await supabase.auth.getSession()
    if (!session) {
      router.push('/')
      return
    }

    const { data: { user } } = await supabase.auth.getUser()
    if (user) {
      formData.value = {
        ...formData.value,
        firstName: user.user_metadata?.first_name || '',
        lastName: user.user_metadata?.last_name || '',
        email: user.email || '',
        phone: user.user_metadata?.phone || '',
        address: user.user_metadata?.address || '',
        notifications: user.user_metadata?.notifications || formData.value.notifications,
        language: user.user_metadata?.language || 'fr',
        theme: user.user_metadata?.theme || 'light'
      }
    }
  } catch (err: any) {
    showMessage(err.message || 'Erreur lors du chargement du profil', true)
  } finally {
    loading.value = false
  }
})

const handleUpdateProfile = async () => {
  try {
    saving.value = true
    const { error: updateError } = await supabase.auth.updateUser({
      data: {
        first_name: formData.value.firstName,
        last_name: formData.value.lastName,
        phone: formData.value.phone,
        address: formData.value.address,
        notifications: formData.value.notifications,
        language: formData.value.language,
        theme: formData.value.theme
      }
    })
    if (updateError) throw updateError
    showMessage('Profil mis à jour avec succès')
  } catch (err: any) {
    showMessage(err.message || 'Erreur lors de la mise à jour du profil', true)
  } finally {
    saving.value = false
  }
}

const handleUpdatePassword = async () => {
  if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
    showMessage('Les mots de passe ne correspondent pas', true)
    return
  }

  if (passwordForm.value.newPassword.length < 6) {
    showMessage('Le mot de passe doit contenir au moins 6 caractères', true)
    return
  }
  
  try {
    saving.value = true
    const { error: updateError } = await supabase.auth.updateUser({
      password: passwordForm.value.newPassword
    })
    if (updateError) throw updateError
    
    passwordForm.value = {
      currentPassword: '',
      newPassword: '',
      confirmPassword: ''
    }
    showMessage('Mot de passe mis à jour avec succès')
  } catch (err: any) {
    showMessage(err.message || 'Erreur lors de la mise à jour du mot de passe', true)
  } finally {
    saving.value = false
  }
}

const handleDeleteAccount = async () => {
  try {
    saving.value = true
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('Utilisateur non trouvé')

    // Supprimer les données de l'utilisateur
    const { error: deleteError } = await supabase
      .from('vehicles')
      .delete()
      .eq('user_id', user.id)

    if (deleteError) throw deleteError

    // Déconnexion
    await supabase.auth.signOut()
    showDeleteModal.value = false
    router.push('/')
  } catch (err: any) {
    showMessage(err.message || 'Erreur lors de la suppression du compte', true)
  } finally {
    saving.value = false
  }
}

const handleSignOut = async () => {
  try {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
    router.push('/')
  } catch (err: any) {
    showMessage(err.message || 'Erreur lors de la déconnexion', true)
  }
}
</script>

<template>
  <div class="flex min-h-screen bg-gray-50">
    <Navbar />
    
    <main class="flex-1 p-8">
      <div class="max-w-4xl mx-auto">
        <h1 class="text-2xl font-bold mb-8">Mon profil</h1>

        <!-- Loading state -->
        <div v-if="loading" class="flex items-center justify-center py-12">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-black"></div>
        </div>

        <template v-else>
          <!-- Messages -->
          <div v-if="error || successMessage" class="mb-6">
            <div
              v-if="error"
              class="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-lg"
            >
              {{ error }}
            </div>
            <div
              v-if="successMessage"
              class="bg-green-50 border border-green-200 text-green-600 px-4 py-3 rounded-lg"
            >
              {{ successMessage }}
            </div>
          </div>

          <!-- Tabs -->
          <div class="mb-6 border-b border-gray-200">
            <div class="flex space-x-8">
              <button
                v-for="tab in [
                  { id: 'personal', icon: UserIcon, label: 'Informations personnelles' },
                  { id: 'notifications', icon: BellIcon, label: 'Notifications' },
                  { id: 'security', icon: ShieldCheckIcon, label: 'Sécurité' }
                ]"
                :key="tab.id"
                @click="activeTab = tab.id"
                :class="[
                  'pb-4 flex items-center space-x-2',
                  activeTab === tab.id
                    ? 'border-b-2 border-black text-black'
                    : 'text-gray-500 hover:text-gray-700'
                ]"
              >
                <component :is="tab.icon" class="w-5 h-5" />
                <span>{{ tab.label }}</span>
              </button>
            </div>
          </div>

          <!-- Tab content -->
          <div class="space-y-6">
            <!-- Personal Information -->
            <div v-if="activeTab === 'personal'" class="bg-white rounded-xl p-6 shadow-sm">
              <form @submit.prevent="handleUpdateProfile" class="space-y-6">
                <div class="grid grid-cols-2 gap-4">
                  <FormField
                    label="Prénom"
                    v-model="formData.firstName"
                    placeholder="Votre prénom"
                  />
                  <FormField
                    label="Nom"
                    v-model="formData.lastName"
                    placeholder="Votre nom"
                  />
                </div>

                <FormField
                  label="Email"
                  type="email"
                  v-model="formData.email"
                  disabled
                />

                <FormField
                  label="Téléphone"
                  v-model="formData.phone"
                  placeholder="Votre numéro de téléphone"
                />

                <FormField
                  label="Adresse"
                  v-model="formData.address"
                  placeholder="Votre adresse"
                >
                  <textarea
                    v-model="formData.address"
                    rows="3"
                    class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="Votre adresse"
                  ></textarea>
                </FormField>

                <div class="flex justify-end">
                  <Button type="submit" variant="primary" :loading="saving">
                    Enregistrer
                  </Button>
                </div>
              </form>
            </div>

            <!-- Notifications -->
            <div v-if="activeTab === 'notifications'" class="bg-white rounded-xl p-6 shadow-sm">
              <form @submit.prevent="handleUpdateProfile" class="space-y-6">
                <div class="space-y-4">
                  <div class="flex items-center justify-between">
                    <div>
                      <h3 class="text-sm font-medium text-gray-900">Notifications par email</h3>
                      <p class="text-sm text-gray-500">Recevoir les notifications par email</p>
                    </div>
                    <button
                      type="button"
                      @click="formData.notifications.email = !formData.notifications.email"
                      :class="[
                        'relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none',
                        formData.notifications.email ? 'bg-black' : 'bg-gray-200'
                      ]"
                    >
                      <span
                        :class="[
                          'pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out',
                          formData.notifications.email ? 'translate-x-5' : 'translate-x-0'
                        ]"
                      />
                    </button>
                  </div>

                  <div class="flex items-center justify-between">
                    <div>
                      <h3 class="text-sm font-medium text-gray-900">Rappels d'entretien</h3>
                      <p class="text-sm text-gray-500">Être notifié des entretiens à venir</p>
                    </div>
                    <button
                      type="button"
                      @click="formData.notifications.maintenance = !formData.notifications.maintenance"
                      :class="[
                        'relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none',
                        formData.notifications.maintenance ? 'bg-black' : 'bg-gray-200'
                      ]"
                    >
                      <span
                        :class="[
                          'pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out',
                          formData.notifications.maintenance ? 'translate-x-5' : 'translate-x-0'
                        ]"
                      />
                    </button>
                  </div>

                  <div class="flex items-center justify-between">
                    <div>
                      <h3 class="text-sm font-medium text-gray-900">Rappels d'assurance</h3>
                      <p class="text-sm text-gray-500">Être notifié des échéances d'assurance</p>
                    </div>
                    <button
                      type="button"
                      @click="formData.notifications.insurance = !formData.notifications.insurance"
                      :class="[
                        'relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none',
                        formData.notifications.insurance ? 'bg-black' : 'bg-gray-200'
                      ]"
                    >
                      <span
                        :class="[
                          'pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out',
                          formData.notifications.insurance ? 'translate-x-5' : 'translate-x-0'
                        ]"
                      />
                    </button>
                  </div>

                  <div class="flex items-center justify-between">
                    <div>
                      <h3 class="text-sm font-medium text-gray-900">Rappels de contrôle technique</h3>
                      <p class="text-sm text-gray-500">Être notifié des contrôles techniques à venir</p>
                    </div>
                    <button
                      type="button"
                      @click="formData.notifications.inspection = !formData.notifications.inspection"
                      :class="[
                        'relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none',
                        formData.notifications.inspection ? 'bg-black' : 'bg-gray-200'
                      ]"
                    >
                      <span
                        :class="[
                          'pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out',
                          formData.notifications.inspection ? 'translate-x-5' : 'translate-x-0'
                        ]"
                      />
                    </button>
                  </div>
                </div>

                <div class="flex justify-end">
                  <Button type="submit" variant="primary" :loading="saving">
                    Enregistrer
                  </Button>
                </div>
              </form>
            </div>

            <!-- Security -->
            <div v-if="activeTab === 'security'" class="space-y-6">
              <!-- Change Password -->
              <div class="bg-white rounded-xl p-6 shadow-sm">
                <h3 class="text-lg font-medium mb-6">Changer le mot de passe</h3>
                <form @submit.prevent="handleUpdatePassword" class="space-y-6">
                  <FormField
                    label="Mot de passe actuel"
                    type="password"
                    v-model="passwordForm.currentPassword"
                    placeholder="Votre mot de passe actuel"
                  />

                  <FormField
                    label="Nouveau mot de passe"
                    type="password"
                    v-model="passwordForm.newPassword"
                    placeholder="Votre nouveau mot de passe"
                  />

                  <FormField
                    label="Confirmer le mot de passe"
                    type="password"
                    v-model="passwordForm.confirmPassword"
                    placeholder="Confirmez votre nouveau mot de passe"
                  />

                  <div class="flex justify-end">
                    <Button type="submit" variant="primary" :loading="saving">
                      Mettre à jour
                    </Button>
                  </div>
                </form>
              </div>

              <!-- Danger Zone -->
              <div class="bg-white rounded-xl p-6 shadow-sm border border-red-200">
                <h3 class="text-lg font-medium text-red-600 mb-6">Zone dangereuse</h3>
                <div class="space-y-4">
                  <div class="flex items-center justify-between">
                    <div>
                      <p class="font-medium">Supprimer le compte</p>
                      <p class="text-sm text-gray-500">
                        Cette action est irréversible. Toutes vos données seront supprimées.
                      </p>
                    </div>
                    <Button
                      variant="secondary"
                      class="!bg-red-50 !text-red-600 hover:!bg-red-100"
                      @click="showDeleteModal = true"
                    >
                      Supprimer
                    </Button>
                  </div>

                  <div class="flex items-center justify-between">
                    <div>
                      <p class="font-medium">Se déconnecter</p>
                      <p class="text-sm text-gray-500">
                        Déconnectez-vous de toutes les sessions actives.
                      </p>
                    </div>
                    <Button
                      variant="secondary"
                      @click="handleSignOut"
                    >
                      Déconnexion
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Delete Account Modal -->
          <div
            v-if="showDeleteModal"
            class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50"
          >
            <div class="bg-white rounded-xl p-6 max-w-md w-full">
              <div class="flex items-center space-x-4 mb-6">
                <div class="flex-shrink-0">
                  <TrashIcon class="w-6 h-6 text-red-600" />
                </div>
                <div>
                  <h3 class="text-lg font-medium">Supprimer le compte</h3>
                  <p class="text-sm text-gray-500">
                    Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.
                  </p>
                </div>
              </div>

              <div class="flex justify-end space-x-4">
                <Button
                  variant="secondary"
                  @click="showDeleteModal = false"
                >
                  Annuler
                </Button>
                <Button
                  variant="primary"
                  class="!bg-red-600 hover:!bg-red-700"
                  :loading="saving"
                  @click="handleDeleteAccount"
                >
                  Supprimer
                </Button>
              </div>
            </div>
          </div>
        </template>
      </div>
    </main>
  </div>
</template>
```