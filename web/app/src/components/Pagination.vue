<template>
  <div class="mt-8 flex justify-center items-center space-x-4">
    <button
      v-if="currentPage > 1"
      @click="previousPage"
      class="glass hover:shadow-xl transition-all duration-300 hover:scale-105 text-white border border-white/20 px-4 py-2 rounded-lg backdrop-blur-sm flex items-center space-x-2 group"
    >
      <svg
        class="h-4 w-4 group-hover:-translate-x-1 transition-transform duration-300"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M15 19l-7-7 7-7"
        />
      </svg>
      <span class="font-medium">Previous</span>
    </button>

    <div class="flex items-center space-x-2">
      <span class="text-purple-200 text-sm">Page</span>
      <div class="glass rounded-lg px-3 py-1 border border-white/20">
        <span class="text-white font-mono">{{ currentPage }}</span>
      </div>
      <span class="text-purple-200 text-sm">of</span>
      <div class="glass rounded-lg px-3 py-1 border border-white/20">
        <span class="text-white font-mono">{{ maxPages }}</span>
      </div>
    </div>

    <button
      v-if="currentPage < maxPages"
      @click="nextPage"
      class="glass hover:shadow-xl transition-all duration-300 hover:scale-105 text-white border border-white/20 px-4 py-2 rounded-lg backdrop-blur-sm flex items-center space-x-2 group"
    >
      <span class="font-medium">Next</span>
      <svg
        class="h-4 w-4 group-hover:translate-x-1 transition-transform duration-300"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M9 5l7 7-7 7"
        />
      </svg>
    </button>
  </div>
</template>

<script>
export default {
  name: "Pagination",
  props: {
    numberOfResultsPerPage: Number,
  },
  components: {},
  emits: ["page"],
  methods: {
    nextPage() {
      this.currentPage++;
      this.$emit("page", this.currentPage);
    },
    previousPage() {
      this.currentPage--;
      this.$emit("page", this.currentPage);
    },
  },
  computed: {
    maxPages() {
      return Math.ceil(
        parseInt(window.config.maximumNumberOfResults) /
          this.numberOfResultsPerPage
      );
    },
  },
  data() {
    return {
      currentPage: 1,
    };
  },
};
</script>
