import tailwindcss from "@tailwindcss/vite";
export default defineNuxtConfig({
  compatibilityDate: "2025-07-15",
  devtools: { enabled: true },
  css: ['./app/assets/css/main.css'],
  modules: ['@nuxt/image', '@nuxt/fonts', '@nuxt/eslint'],
  vite: {
    plugins: [
      tailwindcss(),
    ],
  },
});