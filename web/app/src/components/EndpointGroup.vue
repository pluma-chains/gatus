<template>
  <div :class="endpoints.length === 0 ? 'mt-3' : 'mt-6'">
    <slot v-if="name !== 'undefined'">
      <div
        class="glass hover:shadow-2xl transition-all duration-500 hover:scale-[1.02] group cursor-pointer overflow-hidden rounded-xl border border-white/20 mb-4"
        @click="toggleGroup"
      >
        <div class="p-6 relative">
          <div
            class="absolute top-0 right-0 w-20 h-20 bg-gradient-to-br from-purple-500/20 to-transparent rounded-bl-3xl"
          ></div>
          <div class="flex items-center justify-between relative z-10">
            <div class="flex items-center space-x-4">
              <div class="relative">
                <div
                  class="w-12 h-12 bg-gradient-to-r from-purple-500 to-blue-500 rounded-xl flex items-center justify-center shadow-lg"
                >
                  <svg
                    class="h-6 w-6 text-white"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M5 12h14M5 12l4-4m-4 4l4 4"
                    ></path>
                  </svg>
                </div>
                <div
                  v-if="!unhealthyCount"
                  class="absolute -top-1 -right-1 w-4 h-4 bg-emerald-500 rounded-full flex items-center justify-center"
                >
                  <div class="w-2 h-2 bg-white rounded-full"></div>
                </div>
              </div>
              <div>
                <h3
                  class="text-xl font-bold text-white group-hover:text-purple-200 transition-colors duration-300"
                >
                  {{ name }}
                </h3>
                <p class="text-purple-200 text-sm">
                  {{ endpoints.length }}
                  {{ endpoints.length === 1 ? "endpoint" : "endpoints" }}
                </p>
              </div>
            </div>
            <div class="flex items-center space-x-4">
              <div v-if="unhealthyCount" class="flex items-center space-x-2">
                <div
                  class="w-3 h-3 bg-red-400 rounded-full animate-pulse"
                ></div>
                <span class="text-red-400 font-medium"
                  >{{ unhealthyCount }} issue{{
                    unhealthyCount > 1 ? "s" : ""
                  }}</span
                >
              </div>
              <div v-else class="flex items-center space-x-2">
                <div
                  class="w-3 h-3 bg-emerald-400 rounded-full animate-pulse"
                ></div>
                <span class="text-emerald-400 font-medium">All healthy</span>
              </div>
              <div
                class="transform transition-transform duration-300"
                :class="collapsed ? 'rotate-180' : ''"
              >
                <svg
                  class="h-5 w-5 text-purple-200"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M19 9l-7 7-7-7"
                  ></path>
                </svg>
              </div>
            </div>
          </div>
        </div>
      </div>
    </slot>
    <div
      v-if="!collapsed"
      :class="name === 'undefined' ? 'space-y-4' : 'space-y-4'"
    >
      <slot v-for="(endpoint, idx) in endpoints" :key="idx">
        <Endpoint
          :data="endpoint"
          :maximumNumberOfResults="20"
          @showTooltip="showTooltip"
          @toggleShowAverageResponseTime="toggleShowAverageResponseTime"
          :showAverageResponseTime="showAverageResponseTime"
        />
      </slot>
    </div>
  </div>
</template>

<script>
import Endpoint from "./Endpoint.vue";

export default {
  name: "EndpointGroup",
  components: {
    Endpoint,
  },
  props: {
    name: String,
    endpoints: Array,
    showAverageResponseTime: Boolean,
  },
  emits: ["showTooltip", "toggleShowAverageResponseTime"],
  methods: {
    healthCheck() {
      let unhealthyCount = 0;
      if (this.endpoints) {
        for (let i in this.endpoints) {
          if (
            this.endpoints[i].results &&
            this.endpoints[i].results.length > 0
          ) {
            if (
              !this.endpoints[i].results[this.endpoints[i].results.length - 1]
                .success
            ) {
              unhealthyCount++;
            }
          }
        }
      }
      this.unhealthyCount = unhealthyCount;
    },
    toggleGroup() {
      this.collapsed = !this.collapsed;
      localStorage.setItem(
        `gatus:endpoint-group:${this.name}:collapsed`,
        this.collapsed
      );
    },
    showTooltip(result, event) {
      this.$emit("showTooltip", result, event);
    },
    toggleShowAverageResponseTime() {
      this.$emit("toggleShowAverageResponseTime");
    },
  },
  watch: {
    endpoints: function () {
      this.healthCheck();
    },
  },
  created() {
    this.healthCheck();
  },
  data() {
    return {
      unhealthyCount: 0,
      collapsed:
        localStorage.getItem(`gatus:endpoint-group:${this.name}:collapsed`) ===
        "true",
    };
  },
};
</script>

<style>
.endpoint-group {
  cursor: pointer;
  user-select: none;
}

.glass {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}
</style>
