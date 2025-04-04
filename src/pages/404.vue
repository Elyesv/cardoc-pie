<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center p-4">
    <div class="max-w-md w-full text-center">
      <h1 class="text-4xl font-bold text-gray-900 mb-4">404</h1>
      <p class="text-gray-600 mb-8">La page que vous recherchez n'existe pas.</p>
      <router-link
        to="/dashboard"
        class="inline-flex items-center justify-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-black hover:bg-gray-900"
      >
        Retour au tableau de bord
      </router-link>
    </div>
  </div>
</template>