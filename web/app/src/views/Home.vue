<template>
  <Loading v-if="!retrievedData" class="h-64 w-64 px-4 my-24" />
  <div v-show="retrievedData">
    <!-- Stats Overview -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
      <div
        class="glass hover:shadow-2xl transition-all duration-500 hover:scale-105 group overflow-hidden rounded-xl border border-white/20 p-6"
      >
        <div
          class="absolute top-0 right-0 w-20 h-20 bg-gradient-to-br from-purple-500/20 to-transparent rounded-bl-3xl"
        ></div>
        <div class="flex items-center justify-between relative z-10">
          <div>
            <p class="text-purple-200 text-sm font-medium">Total Services</p>
            <p
              class="text-3xl font-bold text-white group-hover:scale-110 transition-transform duration-300"
            >
              {{ totalEndpoints }}
            </p>
            <p class="text-xs text-purple-300 mt-1">Being monitored</p>
          </div>
          <div class="relative">
            <svg
              class="h-8 w-8 text-purple-400 group-hover:rotate-12 transition-transform duration-300"
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
            <div
              class="absolute -top-1 -right-1 w-3 h-3 bg-purple-500 rounded-full animate-ping"
            ></div>
          </div>
        </div>
      </div>

      <div
        class="glass hover:shadow-2xl transition-all duration-500 hover:scale-105 group overflow-hidden rounded-xl border border-white/20 p-6"
      >
        <div
          class="absolute top-0 right-0 w-20 h-20 bg-gradient-to-br from-emerald-500/20 to-transparent rounded-bl-3xl"
        ></div>
        <div class="flex items-center justify-between relative z-10">
          <div>
            <p class="text-purple-200 text-sm font-medium">Healthy</p>
            <p
              class="text-3xl font-bold text-emerald-400 group-hover:scale-110 transition-transform duration-300"
            >
              {{ healthyEndpoints }}
            </p>
            <p class="text-xs text-emerald-300 mt-1">
              {{
                totalEndpoints > 0
                  ? ((healthyEndpoints / totalEndpoints) * 100).toFixed(1)
                  : 0
              }}% uptime
            </p>
          </div>
          <svg
            class="h-8 w-8 text-emerald-400 group-hover:rotate-12 transition-transform duration-300"
            fill="currentColor"
            viewBox="0 0 24 24"
          >
            <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
      </div>

      <div
        class="glass hover:shadow-2xl transition-all duration-500 hover:scale-105 group overflow-hidden rounded-xl border border-white/20 p-6"
      >
        <div
          class="absolute top-0 right-0 w-20 h-20 bg-gradient-to-br from-yellow-500/20 to-transparent rounded-bl-3xl"
        ></div>
        <div class="flex items-center justify-between relative z-10">
          <div>
            <p class="text-purple-200 text-sm font-medium">Avg Response</p>
            <p
              class="text-3xl font-bold text-white group-hover:scale-110 transition-transform duration-300"
            >
              {{ averageResponseTime }}ms
            </p>
            <p class="text-xs text-yellow-300 mt-1">Response time</p>
          </div>
          <svg
            class="h-8 w-8 text-yellow-400 group-hover:rotate-12 transition-transform duration-300"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M13 10V3L4 14h7v7l9-11h-7z"
            />
          </svg>
        </div>
      </div>

      <div
        class="glass hover:shadow-2xl transition-all duration-500 hover:scale-105 group overflow-hidden rounded-xl border border-white/20 p-6"
      >
        <div
          class="absolute top-0 right-0 w-20 h-20 bg-gradient-to-br from-red-500/20 to-transparent rounded-bl-3xl"
        ></div>
        <div class="flex items-center justify-between relative z-10">
          <div>
            <p class="text-purple-200 text-sm font-medium">Issues</p>
            <p
              class="text-3xl font-bold text-white group-hover:scale-110 transition-transform duration-300"
            >
              {{ unhealthyEndpoints }}
            </p>
            <p class="text-xs text-red-300 mt-1">Need attention</p>
          </div>
          <svg
            class="h-8 w-8 text-red-400 group-hover:rotate-12 transition-transform duration-300"
            fill="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
            />
          </svg>
        </div>
      </div>
    </div>

    <!-- Endpoints List -->
    <Endpoints
      :endpointStatuses="endpointStatuses"
      :showStatusOnHover="true"
      @showTooltip="showTooltip"
      @toggleShowAverageResponseTime="toggleShowAverageResponseTime"
      :showAverageResponseTime="showAverageResponseTime"
    />

    <Pagination
      v-show="retrievedData"
      @page="changePage"
      :numberOfResultsPerPage="20"
    />
  </div>
  <Settings @refreshData="fetchData" />
</template>

<script>
import Settings from "@/components/Settings.vue";
import Endpoints from "@/components/Endpoints.vue";
import Pagination from "@/components/Pagination";
import Loading from "@/components/Loading";
import { SERVER_URL } from "@/main.js";

export default {
  name: "Home",
  components: {
    Loading,
    Pagination,
    Endpoints,
    Settings,
  },
  emits: ["showTooltip", "toggleShowAverageResponseTime"],
  methods: {
    fetchData() {
      fetch(
        `${SERVER_URL}/api/v1/endpoints/statuses?page=${this.currentPage}`,
        { credentials: "include" }
      ).then((response) => {
        this.retrievedData = true;
        if (response.status === 200) {
          response.json().then((data) => {
            if (
              JSON.stringify(this.endpointStatuses) !== JSON.stringify(data)
            ) {
              this.endpointStatuses = data;
            }
          });
        } else {
          response.text().then((text) => {
            console.log(`[Home][fetchData] Error: ${text}`);
          });
        }
      });
    },
    changePage(page) {
      this.retrievedData = false; // Show loading only on page change or on initial load
      this.currentPage = page;
      this.fetchData();
    },
    showTooltip(result, event) {
      this.$emit("showTooltip", result, event);
    },
    toggleShowAverageResponseTime() {
      this.showAverageResponseTime = !this.showAverageResponseTime;
    },
  },
  computed: {
    totalEndpoints() {
      if (!this.endpointStatuses || !Array.isArray(this.endpointStatuses)) {
        return 0;
      }
      return this.endpointStatuses.length;
    },
    healthyEndpoints() {
      if (!this.endpointStatuses || !Array.isArray(this.endpointStatuses)) {
        return 0;
      }
      return this.endpointStatuses.filter(
        (endpoint) =>
          endpoint.results &&
          endpoint.results.length > 0 &&
          endpoint.results[endpoint.results.length - 1].success
      ).length;
    },
    unhealthyEndpoints() {
      if (!this.endpointStatuses || !Array.isArray(this.endpointStatuses)) {
        return 0;
      }
      return this.endpointStatuses.filter(
        (endpoint) =>
          endpoint.results &&
          endpoint.results.length > 0 &&
          !endpoint.results[endpoint.results.length - 1].success
      ).length;
    },
    averageResponseTime() {
      if (!this.endpointStatuses || !Array.isArray(this.endpointStatuses)) {
        return 0;
      }

      const endpointsWithResults = this.endpointStatuses.filter(
        (endpoint) => endpoint.results && endpoint.results.length > 0
      );

      if (endpointsWithResults.length === 0) {
        return 0;
      }

      const totalResponseTime = endpointsWithResults.reduce((acc, endpoint) => {
        const latestResult = endpoint.results[endpoint.results.length - 1];
        if (latestResult && latestResult.duration) {
          return acc + latestResult.duration / 1000000; // Convert nanoseconds to milliseconds
        }
        return acc;
      }, 0);

      return Math.round(totalResponseTime / endpointsWithResults.length);
    },
  },
  data() {
    return {
      endpointStatuses: [],
      currentPage: 1,
      showAverageResponseTime: true,
      retrievedData: false,
    };
  },
  created() {
    this.retrievedData = false; // Show loading only on page change or on initial load
    this.fetchData();
  },
};
</script>
