<template>
  <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
    <div
      v-for="card in summaryCards"
      :key="card.status"
      class="rounded-xl p-6 text-white"
      :style="card.style"
    >
      <h2 class="text-3xl font-semibold">{{ card.count }}</h2>
      <p class="text-lg font-semibold mt-1">{{ card.label }}</p>
      <p class="text-sm mt-2">
        Last 30 days
        <span :class="card.trendColor + ' font-semibold ml-1'">{{ card.trend }}</span>
      </p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SummaryCards',
  props: {
    stats: {
      type: Object,
      required: true,
    },
  },
  computed: {
    summaryCards() {
      return [
        {
          status: 'Approved',
          label: 'Approved Event',
          count: this.stats.Approved || 0,
          style: 'background: linear-gradient(135deg, #7f00ff, #3c8ce7)',
          trend: `+${this.stats.Approved || 0} ▲`,
          trendColor: 'text-green-500',
        },
        {
          status: 'Pending',
          label: 'Under Review',
          count: this.stats.Pending || 0,
          style: 'background: linear-gradient(135deg, #a8c66c, #4b5320)',
          trend: `+${this.stats.Pending || 0} ▲`,
          trendColor: 'text-green-500',
        },
        {
          status: 'Declined',
          label: 'Declined Event',
          count: this.stats.Declined || 0,
          style: 'background: linear-gradient(135deg, #808080, #505050)',
          trend: `-${this.stats.Declined || 0} ▼`,
          trendColor: 'text-red-500',
        },
      ];
    },
  },
};
</script>
