<template>
  <div
    class="glass hover:shadow-2xl transition-all duration-500 hover:scale-[1.02] group cursor-pointer overflow-hidden rounded-xl border border-white/20"
    v-if="data"
  >
    <div class="p-6 relative">
      <div
        class="absolute top-0 right-0 w-20 h-20 bg-gradient-to-br from-blue-500/20 to-transparent rounded-bl-3xl"
      ></div>

      <!-- Endpoint Header -->
      <div class="flex items-start justify-between mb-6 relative z-10">
        <div class="flex items-center space-x-4">
          <div class="relative">
            <div
              :class="[
                'w-12 h-12 rounded-xl flex items-center justify-center shadow-lg transition-all duration-300',
                getStatusColor(
                  data.results && data.results.length
                    ? data.results[data.results.length - 1].success
                      ? 'online'
                      : 'offline'
                    : 'unknown'
                ),
              ]"
            >
              <div
                v-if="
                  data.results &&
                  data.results.length &&
                  data.results[data.results.length - 1].success
                "
                class="w-6 h-6 text-white"
              >
                <svg fill="currentColor" viewBox="0 0 24 24">
                  <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div
                v-else-if="data.results && data.results.length"
                class="w-6 h-6 text-white"
              >
                <svg fill="currentColor" viewBox="0 0 24 24">
                  <path
                    d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                  />
                </svg>
              </div>
              <div v-else class="w-6 h-6 text-white">
                <svg fill="currentColor" viewBox="0 0 24 24">
                  <path
                    d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
              </div>
            </div>
            <div
              v-if="
                data.results &&
                data.results.length &&
                data.results[data.results.length - 1].success
              "
              class="absolute -top-1 -right-1 w-4 h-4 bg-emerald-500 rounded-full animate-pulse flex items-center justify-center"
            >
              <div class="w-2 h-2 bg-white rounded-full"></div>
            </div>
          </div>
          <div>
            <router-link
              :to="generatePath()"
              class="text-xl font-bold text-white group-hover:text-purple-200 hover:underline transition-colors duration-300"
            >
              {{ data.name }}
            </router-link>
            <p
              v-if="
                data.results &&
                data.results.length &&
                data.results[data.results.length - 1].hostname
              "
              class="text-purple-200 text-sm mt-1"
            >
              {{ data.results[data.results.length - 1].hostname }}
            </p>
            <div class="flex items-center space-x-4 mt-2">
              <div class="flex items-center space-x-2">
                <div class="w-2 h-2 bg-blue-400 rounded-full"></div>
                <span class="text-blue-400 text-xs font-medium">Endpoint</span>
              </div>
              <div
                v-if="data.results && data.results.length"
                class="flex items-center space-x-2"
              >
                <svg
                  class="h-3 w-3 text-purple-300"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                  ></path>
                </svg>
                <span class="text-purple-300 text-xs font-medium">{{
                  generatePrettyTimeAgo(
                    data.results[data.results.length - 1].timestamp
                  )
                }}</span>
              </div>
            </div>
          </div>
        </div>
        <div class="text-right">
          <div
            v-if="data.results && data.results.length"
            class="bg-white/10 backdrop-blur-sm rounded-lg px-3 py-2 border border-white/20"
          >
            <span
              class="text-white font-mono text-lg cursor-pointer select-none hover:text-purple-200 transition-colors duration-300"
              @click="toggleShowAverageResponseTime"
              :title="
                showAverageResponseTime
                  ? 'Average response time'
                  : 'Minimum and maximum response time'
              "
            >
              <span v-if="showAverageResponseTime"
                >~{{ averageResponseTime }}ms</span
              >
              <span v-else
                >{{
                  minResponseTime === maxResponseTime
                    ? minResponseTime
                    : minResponseTime + "-" + maxResponseTime
                }}ms</span
              >
            </span>
            <div class="text-xs text-purple-200 mt-1">Response time</div>
          </div>
        </div>
      </div>

      <!-- Status History -->
      <div class="mb-4">
        <div class="flex items-center justify-between mb-2">
          <span class="text-sm font-medium text-purple-200"
            >Status History (48h)</span
          >
          <div class="flex items-center space-x-2">
            <div class="w-2 h-2 bg-emerald-400 rounded-full"></div>
            <span class="text-xs text-emerald-400">Healthy</span>
            <div class="w-2 h-2 bg-red-400 rounded-full ml-3"></div>
            <span class="text-xs text-red-400">Failed</span>
          </div>
        </div>
        <div class="flex flex-row space-x-1 h-8 items-end">
          <div v-if="data.results && data.results.length">
            <div
              v-if="data.results.length < maximumNumberOfResults"
              class="flex space-x-1"
            >
              <div
                v-for="filler in maximumNumberOfResults - data.results.length"
                :key="'filler-' + filler"
                class="w-2 h-4 bg-gray-600/30 rounded border border-dashed border-gray-500"
              ></div>
            </div>
            <div class="flex space-x-1">
              <div
                v-for="(result, index) in data.results"
                :key="'result-' + index"
                :class="[
                  'w-2 rounded cursor-pointer transition-all duration-200 hover:scale-125',
                  result.success
                    ? 'bg-emerald-500 hover:bg-emerald-400 h-8'
                    : 'bg-red-500 hover:bg-red-400 h-6',
                ]"
                @mouseenter="showTooltip(result, $event)"
                @mouseleave="showTooltip(null, $event)"
              ></div>
            </div>
          </div>
          <div v-else class="flex space-x-1">
            <div
              v-for="filler in maximumNumberOfResults"
              :key="'empty-' + filler"
              class="w-2 h-4 bg-gray-600/30 rounded border border-dashed border-gray-500"
            ></div>
          </div>
        </div>
      </div>

      <!-- Timeline -->
      <div
        v-if="data.results && data.results.length"
        class="flex justify-between text-xs text-purple-300 border-t border-white/10 pt-3"
      >
        <span>{{ generatePrettyTimeAgo(data.results[0].timestamp) }}</span>
        <span>Now</span>
      </div>
    </div>
  </div>
</template>

<script>
import { helper } from "@/mixins/helper";

export default {
  name: "Endpoint",
  props: {
    maximumNumberOfResults: Number,
    data: Object,
    showAverageResponseTime: Boolean,
  },
  emits: ["showTooltip", "toggleShowAverageResponseTime"],
  mixins: [helper],
  methods: {
    updateMinAndMaxResponseTimes() {
      let minResponseTime = null;
      let maxResponseTime = null;
      let totalResponseTime = 0;
      for (let i in this.data.results) {
        const responseTime = parseInt(
          (this.data.results[i].duration / 1000000).toFixed(0)
        );
        totalResponseTime += responseTime;
        if (minResponseTime == null || minResponseTime > responseTime) {
          minResponseTime = responseTime;
        }
        if (maxResponseTime == null || maxResponseTime < responseTime) {
          maxResponseTime = responseTime;
        }
      }
      if (this.minResponseTime !== minResponseTime) {
        this.minResponseTime = minResponseTime;
      }
      if (this.maxResponseTime !== maxResponseTime) {
        this.maxResponseTime = maxResponseTime;
      }
      if (this.data.results && this.data.results.length) {
        this.averageResponseTime = (
          totalResponseTime / this.data.results.length
        ).toFixed(0);
      }
    },
    generatePath() {
      if (!this.data) {
        return "/";
      }
      return `/endpoints/${this.data.key}`;
    },
    showTooltip(result, event) {
      this.$emit("showTooltip", result, event);
    },
    toggleShowAverageResponseTime() {
      this.$emit("toggleShowAverageResponseTime");
    },
    getStatusColor(status) {
      switch (status) {
        case "online":
          return "bg-gradient-to-r from-emerald-500 to-green-500";
        case "offline":
          return "bg-gradient-to-r from-red-500 to-pink-500";
        default:
          return "bg-gradient-to-r from-gray-500 to-slate-500";
      }
    },
  },
  watch: {
    data: function () {
      this.updateMinAndMaxResponseTimes();
    },
  },
  created() {
    this.updateMinAndMaxResponseTimes();
  },
  data() {
    return {
      minResponseTime: 0,
      maxResponseTime: 0,
      averageResponseTime: 0,
    };
  },
};
</script>

<style>
.glass {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}
</style>
