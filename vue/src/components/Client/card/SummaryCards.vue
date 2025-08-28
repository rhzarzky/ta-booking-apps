<template>
  <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-5 gap-4 mb-8">
    <div
      v-for="card in summaryCards"
      :key="card.status"
      class="rounded-lg p-4 text-white cursor-pointer hover:shadow-xl transition"
      :style="card.style"
      @click="goToStatus(card.status)"
    >
      <h2 class="text-2xl font-semibold">{{ card.count }}</h2>
      <p class="text-base font-semibold mt-1">{{ card.label }}</p>
      <p class="text-xs mt-2">
        Last 30 days
        <span :class="card.trendColor + ' font-semibold ml-1'">{{ card.trend }}</span>
      </p>
    </div>
  </div>
</template>


<script>
import { useRouter } from 'vue-router'

export default {
  name: 'SummaryCards',
  props: {
    stats: {
      type: Object,
      required: true,
    },
  },
  setup() {
    const router = useRouter()
    const goToStatus = (status) => {
      if (status === 'Total') {
        router.push({ name: 'client-history' })
      } else {
        router.push({
          name: 'client-history',
          query: { status: status }
        })
      }
    }
    return { goToStatus }
  },
  computed: {
    summaryCards() {
      const totalCount =
        this.stats.total !== undefined ? this.stats.total :
        (this.stats.pending || 0) +
        (this.stats.approved || 0) +
        (this.stats.completed || 0) +
        (this.stats.declined || 0);

      return [
        {
          status: 'Total', 
          label: 'Total',
          count: totalCount,
          style: 'background: linear-gradient(135deg, #4F46E5, #3730A3)', 
          trend: `+${totalCount} ▲`, 
          trendColor: 'text-white', 
        },
        {
          status: 'Pending',
          label: 'Pending',
          count: this.stats.pending || 0,
          style: 'background: linear-gradient(135deg, #a8c66c, #4b5320)',
          trend: `+${this.stats.pending || 0} ▲`,
          trendColor: 'text-green-500',
        },
        {
          status: 'Approved',
          label: 'Approved',
          count: this.stats.approved || 0,
          style: 'background: linear-gradient(135deg, #7f00ff, #a78bfa)',
          trend: `+${this.stats.approved || 0} ▲`,
          trendColor: 'text-green-500',
        },
        {
          status: 'Completed',
          label: 'Completed',
          count: this.stats.completed || 0,
          style: 'background: linear-gradient(135deg, #3b82f6, #1e40af)',
          trend: `+${this.stats.completed || 0} ▲`,
          trendColor: 'text-emerald-400',
        },
        {
          status: 'Declined',
          label: 'Declined',
          count: this.stats.declined || 0,
          style: 'background: linear-gradient(135deg, #ef4444, #991b1b)',
          trend: `-${this.stats.declined || 0} ▼`,
          trendColor: 'text-red-500',
        },
      ];
    },
  },
};
</script>

<style scoped>
.hover\:shadow-xl:hover {
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}
.transition {
  transition-property: all;
  transition-duration: 300ms;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}
</style>