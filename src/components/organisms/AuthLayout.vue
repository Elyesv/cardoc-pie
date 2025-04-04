<script setup lang="ts">
defineProps<{
  title: string
  subtitle: string
  heroTitle: string
  heroSubtitle: string
}>()

import waveImage from '@/assets/wave.jpeg'
</script>

<template>
  <div class="flex bg-white w-full min-h-screen">
    <!-- Left side with image -->
    <div class="w-1/2 p-8">
      <div class="w-full h-full relative rounded-3xl overflow-hidden">
        <img :src="waveImage" alt="Background" class="absolute inset-0 w-full h-full object-cover" />
        <div class="absolute inset-0 bg-gradient-to-b from-black/30 to-black/10 p-12 flex flex-col justify-end">
          <div class="text-white">
            <h1 class="text-6xl font-serif mb-6" v-html="heroTitle"></h1>
            <p class="text-white/80 text-lg" v-html="heroSubtitle"></p>
          </div>
        </div>
      </div>
    </div>

    <!-- Right side with form -->
    <div class="w-1/2 flex items-center justify-center p-8">
      <div class="w-full max-w-md">
        <div class="flex justify-end mb-16">
          <h1 class="text-2xl font-bold tracking-tight">Cardoc</h1>
        </div>

        <div class="mb-8">
          <h2 class="text-4xl font-serif mb-2">{{ title }}</h2>
          <p class="text-gray-600">{{ subtitle }}</p>
        </div>

        <slot></slot>
      </div>
    </div>
  </div>
</template>