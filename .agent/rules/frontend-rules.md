---
trigger: always_on
---

Standards
MUST FOLLOW THESE RULES, NO EXCEPTIONS

Stack: Vue.js, Nuxt 4, TypeScript, TailwindCSS v4, Vue Router, Pinia, Pinia Colada
Patterns: ALWAYS use Composition API + <script setup>, NEVER use Options API
ALWAYS Keep types alongside your code, use TypeScript for type safety, prefer interface over type for defining types
Stores MUST NOT be mutated outside actions
Templates are declarative, not procedural
Boolean variables MUST read as a question and avoid multiple booleans for state: (example: isLoading, hasAccess)
Keep unit and integration tests alongside the file they test: src/ui/Button.vue + src/ui/Button.spec.ts
ALWAYS use TailwindCSS classes rather than manual CSS
DO NOT hard code colors, use Tailwind's color system
ONLY add meaningful comments that explain why something is done, not what it does
Dev server is already running on http://localhost:3000 with HMR enabled. NEVER launch it yourself
NEVER render placeholders that look like real data (instead use skeleton, loader, empty state)
ALWAYS use named functions when declaring methods, use arrow functions only for callbacks
ALWAYS prefer named exports over default exports
ALWAYS Make Error Handling Contract. Errors MUST be explicit states, never silent. EXAMPLE:
status: 'idle' | 'loading' | 'ready' | 'error'
error: ApiError | null

UI Implementation example:
<ErrorState v-if="auth.status === 'error'" />

DO NOT USE catch (e) { console.log(e) } AND EMPTY catch

UI components MUST NOT know business rules.
ALWAYS use GATED RENDERING when load user details. Pinia store example:
export const useAuthStore = defineStore('auth', {
state: () => ({
user: null,
status: 'idle', // idle | loading | ready | error
}),

actions: {
async fetchMe() {
this.status = 'loading'
try {
this.user = await api.me()
this.status = 'ready'
} catch (e) {
this.status = 'error'
}
},
},
})

Layout example:
<template>
<AppLoader v-if="auth.status !== 'ready'" />
<Dashboard v-else />
</template>

USE Layout-level blocking. Example:

<script setup>
const auth = useAuthStore()

if (auth.status === 'idle') {
  await auth.fetchMe()
}
</script>

<template>
  <NuxtLoadingIndicator />
  <NuxtPage v-if="auth.status === 'ready'" />
</template>

All conditional behavior MUST be behind a flag:
BAD EXAMPLE: (if (user.plan === 'enterprise' && date > ...))
GOOD EXAMPLE (USE LIKE THAT): (if (flags.isNewBillingEnabled) { ... })

Project Structure
Keep this section up to date with the project structure. Use it as a reference to find files and directories.

EXAMPLES are there to illustrate the structure, not to be implemented as-is.

public/ # Public static files (favicon, robots.txt, static images, etc.)
src/
├── api/ # MUST export individual functions that fetch data
│ ├── users.ts # EXAMPLE file for user-related API functions
│ └── posts.ts # EXAMPLE file for post-related API functions
├── components/ # Reusable Vue components
│ ├── ui/ # Base UI components (buttons, inputs, etc.) if any
│ ├── layout/ # Layout components (header, footer, sidebar) if any
│ └── features/ # Feature-specific components
│ └── home/ # EXAMPLE of components specific to the homepage
├── composables/ # Composition functions
├── stores/ # Pinia stores for global state (NOT data fetching)
├── queries/ # Pinia Colada queries for data fetching
│ ├── users.ts # EXAMPLE file for user-related queries
│ └── posts.ts # EXAMPLE file for post-related queries
├── pages/ # Page components (Vue Router + Unplugin Vue Router)
│ ├── (home).vue # EXAMPLE index page using a group for a better name renders at /
│ ├── users.vue # EXAMPLE that renders at /users
│ └── users.[userId].vue # EXAMPLE that renders at /users/:userId
├── plugins/ # Vue plugins
├── utils/ # Global utility pure functions
├── assets/ # Static assets that are processed by Vite (e.g CSS)
├── main.ts # Entry point for the application, add and configure plugins, and mount the app
├── App.vue # Root Vue component
└── router/ # Vue Router configuration
└── index.ts # Router setup
Project Commands
Frequently used commands:

pnpm run build: bundles the project for production
pnpm run test: runs all tests
pnpm exec vitest run <test-files>: runs one or multiple specific test files
add --coverage to check missing test coverage
Development Workflow
ALWAYS follow the workflow when implementing a new feature or fixing a bug. This ensures consistency, quality, and maintainability of the codebase.

Plan your tasks, review them with user. Include tests when possible
Write code, following the project structure and conventions
ALWAYS test implementations work:
Write tests for logic and components
Use the Playwright MCP server to test like a real user
Stage your changes with git add once a feature works
Review changes and analyze the need of refactoring
Testing Workflow
Unit and Integration Tests
Test critical logic first
Split the code if needed to make it testable
Using Playwright MCP Server
Navigate to the relevant page
Wait for content to load completely
Test primary user interactions
Test secondary functionality (error states, edge cases)
Check the JS console for errors or warnings
If you see errors, investigate and fix them immediately
If you see warnings, document them and consider fixing if they affect user experience
Document any bugs found and fix them immediately
Research & Documentation
NEVER hallucinate or guess URLs
ALWAYS try accessing the llms.txt file first to find relevant documentation. EXAMPLE: https://pinia-colada.esm.dev/llms.txt
If it exists, it will contain other links to the documentation for the LLMs used in this project
ALWAYS follow existing links in table of contents or documentation indices
Verify examples and patterns from documentation before using
MCP Servers
You have these MCP servers configured globally:

Context7: Context7 MCP pulls up-to-date, version-specific documentation and code examples straight from the source — and places them directly into your prompt. (use it for getting relevant and specific documentation for Nuxt and Python if applicable)
Nuxt MCP: The MCP server provides structured access to the Nuxt documentation, making it easy for AI tools to understand and assist with Nuxt development.

Note: These are user-level servers available in all your projects.

ALWAYS USE ONLY iconify icons. Usage:
Install @iconify/vue (pnpm install --save-dev @iconify/vue) and import component from it (component is exported as named export):

js
import { Icon } from "@iconify/vue";
Then in template use Icon component with icon name as icon parameter:

jsx
<Icon icon="mdi-light:home" />
