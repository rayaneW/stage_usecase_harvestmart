<template>
  <section class="orders-page">
    <header class="orders-header">
      <div>
        <h1>Bestellingen</h1>
        <p>Overzicht van alle geplaatste FreshMart bestellingen.</p>
      </div>
      <RouterLink to="/inventory" class="back-link">Terug naar voorraad</RouterLink>
    </header>

    <div v-if="loading" class="state-message">
      Bestellingen worden geladen...
    </div>

    <div v-else-if="error" class="state-message error">
      {{ error }}
    </div>

    <div v-else-if="orders.length === 0" class="empty-state">
      <h2>Nog geen bestellingen</h2>
      <p>Zodra er bestellingen geplaatst worden, zie je ze hier verschijnen.</p>
      <RouterLink to="/inventory" class="primary-btn">Ga naar voorraad</RouterLink>
    </div>

    <div v-else class="orders-grid">
      <article v-for="order in orders" :key="order.id" class="order-card">
        <header class="card-header">
          <h2>Bestelling #{{ order.id }}</h2>
          <span class="price-chip">{{ formatPrice(order.totalPrice) }}</span>
        </header>

        <div class="order-meta">
          <p><span>Klant</span><strong>{{ order.customerName }}</strong></p>
          <p><span>Filiaal</span><strong>{{ order.branch }}</strong></p>
          <p><span>Gewenste datum</span><strong>{{ formatDate(order.requestedDate) }}</strong></p>
        </div>

        <div class="items-block">
          <h3>Items</h3>
          <ul>
            <li v-for="item in order.items" :key="item.id || `${order.id}-${item.productId}`">
              <span>{{ item.productName }}</span>
              <span>{{ item.quantity }} x {{ formatPrice(item.price) }}</span>
            </li>
          </ul>
        </div>
      </article>
    </div>
  </section>
</template>

<script setup>
import { onMounted, ref } from 'vue'

const orders = ref([])
const loading = ref(true)
const error = ref('')

const formatPrice = (price) => {
  const safeNumber = Number(price || 0)

  return new Intl.NumberFormat('nl-BE', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: 2,
  }).format(safeNumber)
}

const formatDate = (dateValue) => {
  if (!dateValue) {
    return '-'
  }

  const parsedDate = new Date(dateValue)

  if (Number.isNaN(parsedDate.getTime())) {
    return String(dateValue)
  }

  return new Intl.DateTimeFormat('nl-BE', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(parsedDate)
}

const fetchOrders = async () => {
  try {
    loading.value = true
    error.value = ''

    const response = await fetch('/api/orders')

    if (!response.ok) {
      throw new Error('Kon bestellingen niet ophalen.')
    }

    const data = await response.json()
    orders.value = Array.isArray(data) ? data : []
  } catch (err) {
    error.value = 'Er ging iets mis bij het ophalen van de bestellingen.'
    console.error(err)
  } finally {
    loading.value = false
  }
}

onMounted(fetchOrders)
</script>

<style scoped>
.orders-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 32px 20px 48px;
}

.orders-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 16px;
  margin-bottom: 22px;
}

.orders-header h1 {
  margin: 0;
  color: #2b2b2b;
}

.orders-header p {
  margin: 8px 0 0;
  color: #666;
}

.back-link {
  color: #f24b01;
  text-decoration: none;
  font-weight: 700;
}

.state-message {
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  padding: 16px;
}

.state-message.error {
  color: #b00020;
}

.empty-state {
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  padding: 28px;
  text-align: center;
}

.empty-state h2 {
  margin: 0 0 10px;
  color: #2b2b2b;
}

.empty-state p {
  margin: 0 0 20px;
  color: #666;
}

.orders-grid {
  display: grid;
  gap: 16px;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
}

.order-card {
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  padding: 18px;
  display: grid;
  gap: 14px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
}

.card-header h2 {
  margin: 0;
  color: #2b2b2b;
  font-size: 1.1rem;
}

.price-chip {
  background: #fff3eb;
  color: #b63b04;
  border: 1px solid #ffd3be;
  border-radius: 999px;
  padding: 6px 10px;
  font-weight: 700;
}

.order-meta {
  display: grid;
  gap: 8px;
}

.order-meta p {
  margin: 0;
  display: flex;
  justify-content: space-between;
  gap: 10px;
  color: #4a4a4a;
}

.order-meta strong {
  color: #1e1e1e;
}

.items-block h3 {
  margin: 0 0 8px;
  color: #2b2b2b;
  font-size: 1rem;
}

.items-block ul {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 8px;
}

.items-block li {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  border: 1px solid #efefef;
  border-radius: 10px;
  padding: 8px 10px;
  color: #444;
}

.primary-btn {
  border-radius: 10px;
  font-weight: 700;
  padding: 10px 14px;
  text-decoration: none;
  border: 0;
  cursor: pointer;
  background: #f24b01;
  color: #fff;
}

.primary-btn:hover {
  background: #d94200;
}

@media (max-width: 820px) {
  .orders-header {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
