<script setup lang="ts">
import { Icon } from '@iconify/vue'

const features = [
  {
    icon: 'hugeicons:ai-brain-05',
    title: 'Анализ в реальном времени',
    description: 'Компьютерное зрение отслеживает ваши движения и анализирует технику выполнения упражнений мгновенно',
  },
  {
    icon: 'hugeicons:voice',
    title: 'ИИ-тренер',
    description: 'Искусственный интеллект дает мгновенные рекомендации и корректирует технику как персональный тренер',
  },
  {
    icon: 'hugeicons:workout-run',
    title: 'Персональный план',
    description: 'Индивидуальная программа тренировок, адаптированная под ваш уровень и цели',
  },
  {
    icon: 'hugeicons:analytics-up',
    title: 'Отслеживание прогресса',
    description: 'Подробная статистика тренировок, калорий и достижений для мотивации',
  },
]

const steps = [
  {
    number: 1,
    icon: 'hugeicons:camera-01',
    title: 'Камера определяет положение тела',
    description: 'Технология компьютерного зрения распознает ключевые точки вашего тела',
  },
  {
    number: 2,
    icon: 'hugeicons:ai-brain-01',
    title: 'ИИ анализирует технику',
    description: 'Нейросеть оценивает правильность выполнения упражнения в реальном времени',
  },
  {
    number: 3,
    icon: 'hugeicons:alert-02',
    title: 'Приложение подсказывает',
    description: 'Получайте мгновенную обратную связь, если техника нарушена',
  },
]

const benefits = [
  {
    icon: 'hugeicons:shield-check',
    title: 'Безопасные тренировки',
    description: 'Предотвращайте травмы благодаря контролю техники',
  },
  {
    icon: 'hugeicons:trophy',
    title: 'Эффективные результаты',
    description: 'Правильная техника = максимальный результат',
  },
  {
    icon: 'hugeicons:user-account',
    title: 'Персональный тренер',
    description: 'Тренируйтесь как с профессиональным тренером',
  },
  {
    icon: 'hugeicons:chart-increase',
    title: 'Видимый прогресс',
    description: 'Отслеживайте улучшения каждый день',
  },
]

const team = [
  {
    name: 'Sultan Karilov',
    role: 'AI Engineer & Founder',
    avatar: '👨‍💼',
    education: 'MBZUAI, выпуск 2030',
    experience: 'AI Engineer @ Zimran, основал Runvex (1000+ пользователей), выпускник nFactorial Incubator',
    responsibilities: [
      'Определяет стратегию развития продукта',
      'Отвечает за ИИ-модели и персонализацию тренировок',
      'Финансы и управление компанией',
      'Контроль ресурсов и планирование развития'
    ],
    social: {
      linkedin: 'https://linkedin.com/in/sultankarilov',
      github: 'https://github.com/sultankarilov'
    }
  },
  {
    name: 'Bizhan Ashyhatov',
    role: 'iOS & AI Engineer',
    avatar: '👨‍💻',
    education: 'AITU, 2 курс',
    experience: 'Основатель AuarAI (приобретена), CO-CEO в BachOpus, приложения с аудиторией 50k+, выпускник nFactorial Incubator',
    responsibilities: [
      'Разработка iOS-приложения',
      'Интеграция ИИ-моделей',
      'Обеспечение стабильной работы на мобильных устройствах',
      'Маркетинг и управление продвижением продукта'
    ],
    social: {
      linkedin: 'https://linkedin.com/in/bizhanashyhatov',
      github: 'https://github.com/bizhan'
    }
  },
  {
    name: 'Milan Gorislavetz',
    role: 'Fullstack Engineer',
    avatar: '🧑‍💻',
    education: 'Выпускник Seitzhan School',
    experience: 'Основатель SereneAI, CatOps, fckvibecode, ведущий frontend инженер',
    responsibilities: [
      'Разработка фронтенда и бэкенда',
      'Интеграция базы данных и облачных сервисов',
      'Дизайн и креативные материалы',
      'UI/UX, визуальная коммуникация и контент для продвижения'
    ],
    social: {
      linkedin: 'https://linkedin.com/in/milangorislavetz',
      github: 'https://github.com/milan'
    }
  }
]
</script>

<template>
  <div class="landing-page">
    <!-- Hero Section -->
    <section class="hero-section relative min-h-screen flex items-center justify-center overflow-hidden">
      <!-- Background Effects -->
      <div class="absolute inset-0 bg-gradient-radial from-neon/5 via-transparent to-transparent opacity-50"></div>
      <div class="absolute top-20 left-1/4 w-96 h-96 bg-neon/10 rounded-full blur-[120px]"></div>
      <div class="absolute bottom-20 right-1/4 w-80 h-80 bg-neon/5 rounded-full blur-[100px]"></div>

      <div class="container mx-auto px-6 py-20 relative z-10">
        <div class="grid lg:grid-cols-2 gap-12 items-center">
          <!-- Text Content -->
          <div class="hero-content space-y-8">
            <div class="space-y-4">
              <div class="inline-block px-4 py-2 bg-neon/10 border border-neon/30 rounded-full text-neon text-sm font-medium backdrop-blur-sm">
                AITU CUP 2026
              </div>
              <h1 class="text-5xl md:text-7xl font-bold leading-tight">
                Тренируйтесь <br />
                <span class="text-neon glow-text">правильно</span> с <br />
                помощью ИИ
              </h1>
            </div>

            <p class="text-xl text-gray-400 max-w-xl">
              MuscleUp Vision использует компьютерное зрение для анализа техники упражнений.
              Тренируйтесь безопасно и эффективно с персональным ИИ-тренером.
            </p>

            <div class="flex flex-col sm:flex-row gap-4">
              <NuxtLink to="https://app.muscleup.fitness/"
                class="group px-8 py-4 bg-neon text-black font-bold text-lg rounded-2xl hover:brightness-110 transition-all duration-300 shadow-neon hover:shadow-neon-lg flex items-center justify-center gap-3"
              >
                Начать тренировку
                <Icon icon="hugeicons:arrow-right-02" class="text-2xl group-hover:translate-x-1 transition-transform" />
              </NuxtLink>
              <a
                href="#how-it-works"
                class="px-8 py-4 bg-white/5 border border-white/10 text-white font-bold text-lg rounded-2xl hover:bg-white/10 hover:border-neon/50 transition-all duration-300 backdrop-blur-sm flex items-center justify-center gap-3"
              >
                Как это работает
              </a>
            </div>

            <!-- Stats -->
            <div class="flex gap-8 pt-8">
              <div>
                <div class="text-3xl font-bold text-neon">95%</div>
                <div class="text-sm text-gray-500">Точность анализа</div>
              </div>
              <div>
                <div class="text-3xl font-bold text-neon">24/7</div>
                <div class="text-sm text-gray-500">Доступность</div>
              </div>
              <div>
                <div class="text-3xl font-bold text-neon">0₸</div>
                <div class="text-sm text-gray-500">Бесплатно</div>
              </div>
            </div>
          </div>

          <!-- Hero Image -->
          <div class="relative">
            <div class="absolute inset-0 bg-gradient-to-t from-neon/20 via-transparent to-transparent rounded-3xl blur-2xl"></div>
            <div class="relative">
              <img
                src="/girl.png"
                alt="MuscleUp Vision AI Fitness"
                class="w-full h-auto drop-shadow-2xl"
              />
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Features Section -->
    <section class="features-section py-32 relative">
      <div class="container mx-auto px-6">
        <div class="text-center mb-16 space-y-4">
          <h2 class="text-4xl md:text-6xl font-bold">
            Возможности <span class="text-neon">платформы</span>
          </h2>
          <p class="text-xl text-gray-400 max-w-2xl mx-auto">
            Передовые технологии искусственного интеллекта для вашего прогресса
          </p>
        </div>

        <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div
            v-for="(feature, index) in features"
            :key="index"
            class="feature-card group bg-card rounded-3xl p-8 hover:bg-card-hover transition-all duration-300 border border-white/5 hover:border-neon/50 hover:shadow-neon-card"
          >
            <div class="w-16 h-16 rounded-2xl bg-neon/10 flex items-center justify-center mb-6 group-hover:bg-neon/20 transition-all duration-300">
              <Icon :icon="feature.icon" class="text-4xl text-neon" />
            </div>
            <h3 class="text-xl font-bold mb-3">{{ feature.title }}</h3>
            <p class="text-gray-400 leading-relaxed">{{ feature.description }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- How It Works Section -->
    <section id="how-it-works" class="how-it-works-section py-32 relative">
      <!-- Background Effect -->
      <div class="absolute inset-0 bg-gradient-to-b from-transparent via-neon/5 to-transparent"></div>

      <div class="container mx-auto px-6 relative z-10">
        <div class="text-center mb-20 space-y-4">
          <h2 class="text-4xl md:text-6xl font-bold">
            Как это <span class="text-neon">работает</span>
          </h2>
          <p class="text-xl text-gray-400 max-w-2xl mx-auto">
            Три простых шага до идеальной техники выполнения упражнений
          </p>
        </div>

        <div class="max-w-5xl mx-auto space-y-8">
          <div
            v-for="(step, index) in steps"
            :key="index"
            class="step-card relative"
          >
            <div class="flex flex-col md:flex-row gap-8 items-start md:items-center bg-card rounded-3xl p-8 border border-white/5 hover:border-neon/30 transition-all duration-300 hover:shadow-neon-card">
              <div class="flex-shrink-0 relative">
                <div class="w-32 h-32 rounded-2xl bg-neon flex items-center justify-center shadow-neon">
                  <Icon :icon="step.icon" class="text-6xl text-black" />
                </div>
                <div class="absolute -top-3 -right-3 w-12 h-12 rounded-xl bg-black border-2 border-neon flex items-center justify-center text-2xl font-bold text-neon">
                  {{ step.number }}
                </div>
              </div>

              <!-- Step Content -->
              <div class="flex-1 space-y-3">
                <h3 class="text-2xl font-bold">{{ step.title }}</h3>
                <p class="text-lg text-gray-400 leading-relaxed">{{ step.description }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Benefits Section -->
    <section class="benefits-section py-32 relative">
      <div class="container mx-auto px-6">
        <div class="text-center mb-16 space-y-4">
          <h2 class="text-4xl md:text-6xl font-bold">
            Почему <span class="text-neon">MuscleUp Vision</span>
          </h2>
          <p class="text-xl text-gray-400 max-w-2xl mx-auto">
            Преимущества тренировок с искусственным интеллектом
          </p>
        </div>

        <div class="grid md:grid-cols-2 gap-8 max-w-6xl mx-auto">
          <div
            v-for="(benefit, index) in benefits"
            :key="index"
            class="benefit-card group bg-gradient-to-br from-card to-card-hover rounded-3xl p-10 border border-white/5 hover:border-neon/50 transition-all duration-300 hover:shadow-neon-card"
          >
            <div class="flex items-start gap-6">
              <div class="w-20 h-20 rounded-2xl bg-neon/10 flex items-center justify-center flex-shrink-0 group-hover:bg-neon/20 transition-all duration-300">
                <Icon :icon="benefit.icon" class="text-5xl text-neon" />
              </div>
              <div class="space-y-3">
                <h3 class="text-2xl font-bold">{{ benefit.title }}</h3>
                <p class="text-gray-400 text-lg leading-relaxed">{{ benefit.description }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Team Section -->
    <section class="team-section py-32 relative">
      <!-- Background Effect -->
      <div class="absolute inset-0 bg-gradient-to-b from-neon/5 via-transparent to-neon/5"></div>

      <div class="container mx-auto px-6 relative z-10">
        <div class="text-center mb-16 space-y-4">
          <h2 class="text-4xl md:text-6xl font-bold">
            Команда <span class="text-neon">MuscleUp</span>
          </h2>
          <p class="text-xl text-gray-400 max-w-3xl mx-auto">
            Успех MuscleUp обеспечивается опытной командой специалистов с сильным бэкграундом в ИИ, мобильной разработке и стартапах
          </p>
        </div>

        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8 max-w-7xl mx-auto">
          <div
            v-for="(member, index) in team"
            :key="index"
            class="team-card group bg-gradient-to-br from-card to-card-hover rounded-3xl p-8 border border-white/5 hover:border-neon/50 transition-all duration-300 hover:shadow-neon-card"
          >
            <!-- Avatar & Role -->
            <div class="text-center mb-6">
              <div class="w-24 h-24 mx-auto mb-4 rounded-2xl bg-neon/10 flex items-center justify-center text-5xl group-hover:bg-neon/20 transition-all duration-300">
                {{ member.avatar }}
              </div>
              <h3 class="text-2xl font-bold mb-1">{{ member.name }}</h3>
              <p class="text-neon font-semibold text-sm">{{ member.role }}</p>
            </div>

            <!-- Education & Experience -->
            <div class="space-y-4 mb-6">
              <div class="space-y-2">
                <div class="flex items-start gap-2">
                  <Icon icon="hugeicons:mortarboard-02" class="text-neon text-lg mt-0.5 flex-shrink-0" />
                  <p class="text-sm text-gray-400">{{ member.education }}</p>
                </div>
                <div class="flex items-start gap-2">
                  <Icon icon="hugeicons:briefcase-02" class="text-neon text-lg mt-0.5 flex-shrink-0" />
                  <p class="text-sm text-gray-400">{{ member.experience }}</p>
                </div>
              </div>

              <!-- Responsibilities -->
              <div class="space-y-2">
                <div class="flex items-center gap-2 mb-2">
                  <Icon icon="hugeicons:check-list" class="text-neon text-lg" />
                  <span class="text-xs font-semibold text-gray-500 uppercase">Роль в проекте</span>
                </div>
                <ul class="space-y-1.5 ml-6">
                  <li v-for="(resp, idx) in member.responsibilities" :key="idx" class="text-xs text-gray-400 flex items-start gap-2">
                    <span class="text-neon mt-1">•</span>
                    <span>{{ resp }}</span>
                  </li>
                </ul>
              </div>
            </div>

            <!-- Social Links -->
            <div class="flex gap-3 pt-4 border-t border-white/5">
              <a
                v-if="member.social.linkedin"
                :href="member.social.linkedin"
                target="_blank"
                class="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-white/5 hover:bg-neon/10 rounded-xl transition-all duration-300 text-sm"
              >
                <Icon icon="hugeicons:linkedin-02" class="text-lg" />
                <span>LinkedIn</span>
              </a>
              <a
                v-if="member.social.github"
                :href="member.social.github"
                target="_blank"
                class="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-white/5 hover:bg-neon/10 rounded-xl transition-all duration-300 text-sm"
              >
                <Icon icon="hugeicons:github" class="text-lg" />
                <span>GitHub</span>
              </a>
            </div>
          </div>
        </div>

        <!-- Team Stats -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-6 max-w-4xl mx-auto mt-16">
          <div class="text-center p-6 bg-card rounded-2xl border border-white/5">
            <div class="text-3xl font-bold text-neon mb-2">3</div>
            <div class="text-sm text-gray-400">Члена команды</div>
          </div>
          <div class="text-center p-6 bg-card rounded-2xl border border-white/5">
            <div class="text-3xl font-bold text-neon mb-2">50k+</div>
            <div class="text-sm text-gray-400">Пользователей</div>
          </div>
          <div class="text-center p-6 bg-card rounded-2xl border border-white/5">
            <div class="text-3xl font-bold text-neon mb-2">5+</div>
            <div class="text-sm text-gray-400">Проектов запущено</div>
          </div>
          <div class="text-center p-6 bg-card rounded-2xl border border-white/5">
            <div class="text-3xl font-bold text-neon mb-2">100%</div>
            <div class="text-sm text-gray-400">Преданность делу</div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section class="cta-section py-32 relative overflow-hidden">
      <!-- Background Effects -->
      <div class="absolute inset-0 bg-gradient-radial from-neon/10 via-transparent to-transparent"></div>
      <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-neon/5 rounded-full blur-[150px]"></div>

      <div class="container mx-auto px-6 relative z-10">
        <div class="max-w-4xl mx-auto text-center space-y-8">
          <h2 class="text-4xl md:text-6xl lg:text-7xl font-bold leading-tight">
            Начните тренироваться <br />
            <span class="text-neon glow-text">правильно сегодня</span>
          </h2>

          <p class="text-xl md:text-2xl text-gray-400 max-w-2xl mx-auto">
            Присоединяйтесь к революции в фитнесе. Персональный ИИ-тренер всегда с вами.
          </p>

          <div class="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <NuxtLink to="https://app.muscleup.fitness/"
              class="group px-10 py-5 bg-neon text-black font-bold text-xl rounded-2xl hover:brightness-110 transition-all duration-300 shadow-neon-lg hover:shadow-neon-xl flex items-center gap-3"
            >
              Начать тренировку
              <Icon icon="hugeicons:arrow-right-02" class="text-2xl group-hover:translate-x-1 transition-transform" />
          </NuxtLink>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="py-12 border-t border-white/5">
      <div class="container mx-auto px-6">
        <div class="flex flex-col md:flex-row justify-between items-center gap-6">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-neon flex items-center justify-center">
              <Icon icon="hugeicons:workout-run" class="text-2xl text-black" />
            </div>
            <span class="text-xl font-bold">MuscleUp Vision</span>
          </div>

          <div class="text-center md:text-right text-gray-500">
            <p>© 2026 AITU CUP. Made by Milan, Bizhan and Sultan.</p>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<style scoped>
/* Custom CSS Variables */
:root {
  --color-neon: #ccff00;
  --color-bg: #000000;
  --color-card: #111111;
  --color-card-hover: #1a1a1a;
}

/* Glow Effects */
.glow-text {
  text-shadow: 0 0 20px rgba(204, 255, 0, 0.3),
               0 0 40px rgba(204, 255, 0, 0.2),
               0 0 60px rgba(204, 255, 0, 0.1);
}

.shadow-neon {
  box-shadow: 0 0 20px rgba(204, 255, 0, 0.3),
              0 0 40px rgba(204, 255, 0, 0.2);
}

.shadow-neon-lg {
  box-shadow: 0 0 30px rgba(204, 255, 0, 0.4),
              0 0 60px rgba(204, 255, 0, 0.3),
              0 10px 80px rgba(204, 255, 0, 0.2);
}

.shadow-neon-xl {
  box-shadow: 0 0 40px rgba(204, 255, 0, 0.5),
              0 0 80px rgba(204, 255, 0, 0.4),
              0 10px 100px rgba(204, 255, 0, 0.3);
}

.shadow-neon-card {
  box-shadow: 0 0 20px rgba(204, 255, 0, 0.1),
              0 10px 40px rgba(0, 0, 0, 0.5);
}

/* Gradient utilities */
.bg-gradient-radial {
  background: radial-gradient(circle, var(--tw-gradient-stops));
}

/* Tailwind color utilities */
.text-neon {
  color: var(--color-neon);
}

.bg-neon {
  background-color: var(--color-neon);
}

.bg-card {
  background-color: var(--color-card);
}

.bg-card-hover {
  background-color: var(--color-card-hover);
}

.border-neon {
  border-color: var(--color-neon);
}
</style>
