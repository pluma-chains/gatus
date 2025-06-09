<template>
  <div id="tooltip" ref="tooltip" :class="hidden ? 'invisible' : ''" :style="'top:' + top + 'px; left:' + left + 'px'">
    <slot v-if="result">
      <div class="tooltip-title">Timestamp:</div>
      <code id="tooltip-timestamp">{{ prettifyTimestamp(result.timestamp) }}</code>
      <div class="tooltip-title">Response time:</div>
      <code id="tooltip-response-time">{{ (result.duration / 1000000).toFixed(0) }}ms</code>
      <slot v-if="result.conditionResults && result.conditionResults.length">
        <div class="tooltip-title">Conditions:</div>
        <code id="tooltip-conditions">
          <slot v-for="conditionResult in result.conditionResults" :key="conditionResult">
            {{ conditionResult.success ? "&#10003;" : "X" }} ~ {{ conditionResult.condition }}<br/>
          </slot>
        </code>
      </slot>
      <div id="tooltip-errors-container" v-if="result.errors && result.errors.length">
        <div class="tooltip-title">Errors:</div>
        <code id="tooltip-errors">
          <slot v-for="error in result.errors" :key="error">
            - {{ error }}<br/>
          </slot>
        </code>
      </div>
    </slot>
  </div>
</template>


<script>
import {helper} from "@/mixins/helper";

export default {
  name: 'Endpoints',
  props: {
    event: Event,
    result: Object
  },
  mixins: [helper],
  methods: {
    htmlEntities(s) {
      return String(s)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;')
          .replace(/'/g, '&apos;');
    },
    reposition() {
      if (this.event && this.event.type) {
        if (this.event.type === 'mouseenter') {
          let targetTopPosition = this.event.target.getBoundingClientRect().y + 30;
          let targetLeftPosition = this.event.target.getBoundingClientRect().x;
          let tooltipBoundingClientRect = this.$refs.tooltip.getBoundingClientRect();
          if (targetLeftPosition + window.scrollX + tooltipBoundingClientRect.width + 50 > document.body.getBoundingClientRect().width) {
            targetLeftPosition = this.event.target.getBoundingClientRect().x - tooltipBoundingClientRect.width + this.event.target.getBoundingClientRect().width;
            if (targetLeftPosition < 0) {
              targetLeftPosition += -targetLeftPosition;
            }
          }
          if (targetTopPosition + window.scrollY + tooltipBoundingClientRect.height + 50 > document.body.getBoundingClientRect().height && targetTopPosition >= 0) {
            targetTopPosition = this.event.target.getBoundingClientRect().y - (tooltipBoundingClientRect.height + 10);
            if (targetTopPosition < 0) {
              targetTopPosition = this.event.target.getBoundingClientRect().y + 30;
            }
          }
          this.top = targetTopPosition;
          this.left = targetLeftPosition;
        } else if (this.event.type === 'mouseleave') {
          this.hidden = true;
        }
      }
    }
  },
  watch: {
    event: function (value) {
      if (value && value.type) {
        if (value.type === 'mouseenter') {
          this.hidden = false;
        } else if (value.type === 'mouseleave') {
          this.hidden = true;
        }
      }
    }
  },
  updated() {
    this.reposition();
  },
  created() {
    this.reposition();
  },
  data() {
    return {
      hidden: true,
      top: 0,
      left: 0
    }
  }
}
</script>


<style>
#tooltip {
  position: fixed;
  z-index: 9999; /* High z-index to ensure tooltip appears above all other components */
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  padding: 12px;
  font-size: 13px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  max-width: 300px;
  pointer-events: none; /* Prevent tooltip from interfering with mouse events */
}

#tooltip code {
  color: #1f2937;
  line-height: 1.4;
  background: rgba(243, 244, 246, 0.8);
  padding: 2px 6px;
  border-radius: 4px;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 12px;
}

#tooltip .tooltip-title {
  font-weight: 600;
  margin-bottom: 4px;
  display: block;
  color: #374151;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

#tooltip .tooltip-title {
  margin-top: 12px;
}

#tooltip > .tooltip-title:first-child {
  margin-top: 0;
}

/* Dark mode support */
@media (prefers-color-scheme: dark) {
  #tooltip {
    background: rgba(17, 24, 39, 0.95);
    border: 1px solid rgba(55, 65, 81, 0.3);
  }
  
  #tooltip code {
    color: #e5e7eb;
    background: rgba(55, 65, 81, 0.8);
  }
  
  #tooltip .tooltip-title {
    color: #d1d5db;
  }
}
</style>
