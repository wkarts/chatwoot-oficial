import { HorizontalBar } from 'vue-chartjs';

const fontFamily =
  '-apple-system,system-ui,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif';

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  legend: {
    labels: {
      fontFamily,
    },
  },
  scales: {
    xAxes: [
      {
        barPercentage: 1.1,
        ticks: {
          fontFamily,
        },
        gridLines: {
          drawOnChartArea: false,
        },
      },
    ],
    yAxes: [
      {
        ticks: {
          fontFamily,
          beginAtZero: true,
        },
        gridLines: {
          drawOnChartArea: false,
        },
      },
    ],
  },
};

export default {
  extends: HorizontalBar,
  props: ['collection', 'chartOptions'],
  mounted() {
    this.renderChart(this.collection, {
      ...chartOptions,
      ...this.chartOptions,
    });
  },
};
