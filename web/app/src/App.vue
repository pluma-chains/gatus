<template>
  <div>
    <Loading v-if="!retrievedConfig" class="h-64 w-64 px-4" />
    <div v-else class="min-h-screen bg-animated relative overflow-hidden">
      <!-- Animated Background Elements -->
      <div class="absolute inset-0 overflow-hidden">
        <div
          class="absolute -top-40 -right-40 w-80 h-80 bg-purple-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob"
        ></div>
        <div
          class="absolute -bottom-40 -left-40 w-80 h-80 bg-blue-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-2000"
        ></div>
        <div
          class="absolute top-40 left-40 w-80 h-80 bg-indigo-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-4000"
        ></div>
        <div
          class="absolute top-1/2 right-1/3 w-60 h-60 bg-pink-500 rounded-full mix-blend-multiply filter blur-xl opacity-15 animate-blob animation-delay-2000"
        ></div>
      </div>

      <!-- Grid Pattern Overlay -->
      <div
        class="absolute inset-0 opacity-30"
        style="
          background-image: url('data:image/svg+xml,%3Csvg width=\'60\' height=\'60\' viewBox=\'0 0 60 60\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'none\' fillRule=\'evenodd\'%3E%3Cg fill=\'%239C92AC\' fillOpacity=\'0.05\'%3E%3Ccircle cx=\'30\' cy=\'30\' r=\'1.5\'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E');
        "
      ></div>

      <div
        :class="[
          config && config.oidc && !config.authenticated ? 'hidden' : '',
          'relative z-10 container mx-auto p-6 max-w-7xl',
        ]"
        id="global"
      >
        <!-- Header -->
        <div class="flex items-center justify-between mb-12">
          <div class="flex items-center space-x-6">
            <div class="relative group">
              <div
                class="absolute -inset-1 bg-gradient-to-r from-purple-600 to-blue-600 rounded-2xl blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-pulse"
              ></div>
              <div
                class="relative w-16 h-16 bg-gradient-to-r from-purple-500 to-blue-500 rounded-2xl flex items-center justify-center shadow-2xl"
              >
                <component
                  :is="link ? 'a' : 'div'"
                  :href="link"
                  target="_blank"
                  class="flex items-center justify-center w-full h-full"
                >
                  <img
                    v-if="logo"
                    :src="logo"
                    alt="Gatus"
                    class="object-scale-down max-w-10 max-h-10"
                  />
                  <img
                    v-else
                    src="./assets/logo.svg"
                    alt="Gatus"
                    class="object-scale-down max-w-10 max-h-10 filter brightness-0 invert"
                  />
                </component>
                <div
                  class="absolute -top-2 -right-2 w-6 h-6 bg-emerald-500 rounded-full animate-pulse flex items-center justify-center"
                >
                  <div class="w-2 h-2 bg-white rounded-full"></div>
                </div>
              </div>
            </div>
            <div>
              <h1
                class="text-4xl font-bold bg-gradient-to-r from-white to-purple-200 bg-clip-text text-transparent"
              >
                {{ header }}
              </h1>
              <p class="text-purple-200 text-lg mt-1">
                Real-time service health monitoring
              </p>
              <div class="flex items-center space-x-4 mt-2">
                <div class="flex items-center space-x-2">
                  <div
                    class="w-2 h-2 bg-emerald-400 rounded-full animate-pulse"
                  ></div>
                  <span class="text-emerald-400 text-sm font-medium"
                    >Live Data</span
                  >
                </div>
                <div class="flex items-center space-x-2">
                  <svg
                    class="h-4 w-4 text-blue-400"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                    ></path>
                  </svg>
                  <span class="text-blue-400 text-sm font-medium">Secure</span>
                </div>
              </div>
              <div v-if="buttons" class="flex flex-wrap mt-3 space-x-2">
                <a
                  v-for="button in buttons"
                  :key="button.name"
                  :href="button.link"
                  target="_blank"
                  class="px-3 py-1 text-sm font-medium select-none text-purple-200 hover:text-white bg-white/10 hover:bg-white/20 border border-white/20 rounded-lg backdrop-blur-sm transition-all duration-300 hover:scale-105"
                >
                  {{ button.name }}
                </a>
              </div>
            </div>
          </div>
          <div class="flex items-center space-x-4">
            <div class="text-right">
              <div class="text-sm text-purple-200">Last Updated</div>
              <div class="text-white font-mono text-lg">
                {{ currentTime.toLocaleTimeString() }}
              </div>
              <div class="text-xs text-purple-300">
                {{ currentTime.toLocaleDateString() }}
              </div>
            </div>
          </div>
        </div>

        <router-view @showTooltip="showTooltip" />
      </div>
    </div>

    <div
      v-if="config && config.oidc && !config.authenticated"
      class="mx-auto max-w-md pt-12"
    >
      <img
        src="./assets/logo.svg"
        alt="Gatus"
        class="mx-auto"
        style="max-width: 160px; min-width: 50px; min-height: 50px"
      />
      <h2
        class="mt-4 text-center text-4xl font-extrabold text-gray-800 dark:text-gray-200"
      >
        Gatus
      </h2>
      <div class="py-7 px-4 rounded-sm sm:px-10">
        <div
          v-if="$route && $route.query.error"
          class="text-red-500 text-center mb-5"
        >
          <div class="text-sm">
            <span
              class="text-red-500"
              v-if="$route.query.error === 'access_denied'"
              >You do not have access to this status page</span
            >
            <span class="text-red-500" v-else>{{ $route.query.error }}</span>
          </div>
        </div>
        <div>
          <a
            :href="`${SERVER_URL}/oidc/login`"
            class="max-w-lg mx-auto w-full flex justify-center py-3 px-4 border border-green-800 rounded-md shadow-lg text-sm text-white bg-green-700 bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800"
          >
            Login with OIDC
          </a>
        </div>
      </div>
    </div>

    <Tooltip :result="tooltip.result" :event="tooltip.event" />
    <Social />
  </div>
</template>

<script>
import Social from "./components/Social.vue";
import Tooltip from "./components/Tooltip.vue";
import { SERVER_URL } from "@/main";
import Loading from "@/components/Loading";

export default {
  name: "App",
  components: {
    Loading,
    Social,
    Tooltip,
  },
  methods: {
    fetchConfig() {
      fetch(`${SERVER_URL}/api/v1/config`, { credentials: "include" }).then(
        (response) => {
          this.retrievedConfig = true;
          if (response.status === 200) {
            response.json().then((data) => {
              this.config = data;
            });
          }
        }
      );
    },
    showTooltip(result, event) {
      this.tooltip = { result: result, event: event };
    },
  },
  computed: {
    logo() {
      return window.config &&
        window.config.logo &&
        window.config.logo !== "{{ .UI.Logo }}"
        ? window.config.logo
        : "";
    },
    header() {
      return window.config &&
        window.config.header &&
        window.config.header !== "{{ .UI.Header }}"
        ? window.config.header
        : "Health Status";
    },
    link() {
      return window.config &&
        window.config.link &&
        window.config.link !== "{{ .UI.Link }}"
        ? window.config.link
        : null;
    },
    buttons() {
      return window.config && window.config.buttons
        ? window.config.buttons
        : [];
    },
  },
  data() {
    return {
      error: "",
      retrievedConfig: false,
      config: { oidc: false, authenticated: true },
      tooltip: {},
      SERVER_URL,
      currentTime: new Date(),
    };
  },
  created() {
    this.fetchConfig();
    // Update current time every second
    setInterval(() => {
      this.currentTime = new Date();
    }, 1000);
  },
};
</script>
