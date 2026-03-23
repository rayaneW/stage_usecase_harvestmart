<template>
  <section class="inventory-page">
    <header class="inventory-header">
      <div>
        <h1>Voorraad</h1>
        <p>Overzicht van alle bakkerijproducten van FreshMart.</p>
      </div>

      <div class="header-actions">
        <div class="view-toggle" role="group" aria-label="Weergave wisselen">
          <button
            class="toggle-btn"
            :class="{ active: viewMode === 'list' }"
            @click="viewMode = 'list'"
            type="button"
          >
            Lijst
          </button>
          <button
            class="toggle-btn"
            :class="{ active: viewMode === 'cards' }"
            @click="viewMode = 'cards'"
            type="button"
          >
            Kaarten
          </button>
        </div>

        <div class="cart-chip">Mandje: {{ totalProducts }}</div>
      </div>
    </header>

    <p v-if="feedbackMessage" class="feedback-message">
      {{ feedbackMessage }}
    </p>

    <div v-if="loading" class="state-message">
      Producten worden geladen...
    </div>

    <div v-else-if="error" class="state-message error">
      {{ error }}
    </div>

    <div v-else-if="products.length === 0" class="state-message">
      Geen producten gevonden.
    </div>

    <div v-else>
      <div v-if="viewMode === 'list'" class="table-wrap">
        <table class="inventory-table">
          <thead>
            <tr>
              <th>Product</th>
              <th>Prijs</th>
              <th>Voorraad</th>
              <th>Actie</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="product in products" :key="product.id">
              <td>{{ product.name }}</td>
              <td>{{ formatPrice(product.price) }}</td>
              <td>{{ product.stock }}</td>
              <td>
                <button class="add-btn" type="button" @click="addToCart(product)">
                  Toevoegen aan mandje
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-else class="cards-grid">
        <article v-for="product in products" :key="product.id" class="product-card">
          <h2>{{ product.name }}</h2>
          <p class="meta"><span>Prijs</span><strong>{{ formatPrice(product.price) }}</strong></p>
          <p class="meta"><span>Voorraad</span><strong>{{ product.stock }}</strong></p>
          <button class="add-btn" type="button" @click="addToCart(product)">
            Toevoegen aan mandje
          </button>
        </article>
      </div>
    </div>
  </section>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { useCart } from '@/stores/cart'

const products = ref([])
const loading = ref(true)
const error = ref('')
const viewMode = ref('list')
const feedbackMessage = ref('')
const { addItem, totalProducts } = useCart()

let feedbackTimeout = null

const formatPrice = (price) => {
  const safeNumber = Number(price || 0)
  return new Intl.NumberFormat('nl-BE', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: 2,
  }).format(safeNumber)
}

const showFeedback = (productName) => {
  feedbackMessage.value = `${productName} toegevoegd aan mandje`

  if (feedbackTimeout) {
    clearTimeout(feedbackTimeout)
  }

  feedbackTimeout = setTimeout(() => {
    feedbackMessage.value = ''
  }, 1800)
}

const addToCart = (product) => {
  addItem(product)
  showFeedback(product.name)
}

onMounted(async () => {
  try {
    const response = await fetch('/api/products')

    if (!response.ok) {
      throw new Error('Kon de producten niet ophalen.')
    }

    products.value = await response.json()
  } catch (err) {
    error.value = 'Er ging iets mis bij het ophalen van de producten.'
    console.error(err)
  } finally {
    loading.value = false
  }
})

onBeforeUnmount(() => {
  if (feedbackTimeout) {
    clearTimeout(feedbackTimeout)
  }
})
</script>

<style scoped>
.inventory-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 32px 20px 48px;
}

.inventory-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 20px;
  margin-bottom: 24px;
}

.inventory-header h1 {
  margin: 0;
  color: #2b2b2b;
}

.inventory-header p {
  margin: 8px 0 0;
  color: #666;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.view-toggle {
  background: #ffffff;
  border-radius: 12px;
  padding: 4px;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
}

.toggle-btn {
  border: 0;
  background: transparent;
  color: #666;
  padding: 8px 14px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
}

.toggle-btn.active {
  background: #f24b01;
  color: #fff;
}

.cart-chip {
  background: #fff;
  border-radius: 999px;
  padding: 9px 14px;
  font-weight: 700;
  color: #f24b01;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
}

.feedback-message {
  display: inline-block;
  margin: 0 0 18px;
  padding: 8px 12px;
  background: #fff3eb;
  border: 1px solid #ffd3be;
  color: #b63b04;
  border-radius: 10px;
  font-weight: 600;
}

.state-message {
  background: #fff;
  padding: 18px;
  border-radius: 14px;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
}

.state-message.error {
  color: #b00020;
}

.table-wrap {
  overflow-x: auto;
}

.inventory-table {
  width: 100%;
  border-collapse: collapse;
  background: #fff;
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
}

.inventory-table thead {
  background: #f24b01;
  color: #fff;
}

.inventory-table th,
.inventory-table td {
  padding: 14px 16px;
  text-align: left;
  white-space: nowrap;
}

.inventory-table tbody tr {
  border-bottom: 1px solid #efefef;
}

.inventory-table tbody tr:last-child {
  border-bottom: none;
}

.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 16px;
}

.product-card {
  background: #fff;
  border-radius: 14px;
  padding: 18px;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08);
}

.product-card h2 {
  margin: 0 0 16px;
  color: #2c2c2c;
  font-size: 1.1rem;
}

.meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 0 0 10px;
  color: #555;
}

.meta strong {
  color: #111;
}

.add-btn {
  border: 0;
  border-radius: 10px;
  background: #f24b01;
  color: #fff;
  font-weight: 700;
  padding: 10px 14px;
  cursor: pointer;
}

.add-btn:hover {
  background: #d94200;
}

@media (max-width: 760px) {
  .inventory-header {
    flex-direction: column;
    align-items: stretch;
  }

  .header-actions {
    justify-content: space-between;
  }

  .cart-chip {
    align-self: center;
  }
}
</style>