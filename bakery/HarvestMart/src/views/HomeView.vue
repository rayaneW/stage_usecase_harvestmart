<template>
  <div class="home">
    <section class="hero">
      <div class="hero-content">
        <h1>FreshMart Bakery</h1>
        <p>Jouw managementdashboard voor bakkerijproducten, bestellingen en voorraad</p>
      </div>
    </section>

    <main class="dashboard">
      <section class="summary-cards">
        <div class="summary-card">
          <h3>Producten</h3>
          <p class="metric">{{ productCount }}</p>
          <span class="label">totaal beschikbaar</span>
        </div>

        <div class="summary-card warning" v-if="lowStockCount > 0">
          <h3>Lage voorraad</h3>
          <p class="metric">{{ lowStockCount }}</p>
          <span class="label">producten hebben weinig stock</span>
        </div>

        <div class="summary-card">
          <h3>Mandje</h3>
          <p class="metric">{{ cartItemCount }}</p>
          <span class="label">items klaar voor checkout</span>
        </div>

        <div class="summary-card">
          <h3>Bestellingen</h3>
          <p class="metric">{{ orderCount }}</p>
          <span class="label">geplaatst</span>
        </div>
      </section>

      <section class="quick-actions">
        <h2>Snelle acties</h2>
        <div class="action-buttons">
          <RouterLink to="/inventory" class="action-btn">
            Voorraad
          </RouterLink>

          <RouterLink to="/cart" class="action-btn">
            Mandje
          </RouterLink>

          <RouterLink to="/orders" class="action-btn">
            Bestellingen
          </RouterLink>

          <RouterLink to="/restock" class="action-btn">
            Restock
          </RouterLink>
        </div>
      </section>

      <section class="low-stock" v-if="lowStockProducts.length > 0">
        <h2>Producten met lage voorraad</h2>
        <div class="low-stock-list">
          <div v-for="product in lowStockProducts" :key="product.id" class="low-stock-item">
            <div>
              <h4>{{ product.name }}</h4>
              <p class="stock-info">Huidige stock: <strong>{{ product.stock }}</strong></p>
            </div>
            <RouterLink to="/restock" class="restock-link">
              Bestel nu
            </RouterLink>
          </div>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useCart } from '@/stores/cart'

const products = ref([])
const orders = ref([])
const loading = ref(true)
const { totalProducts: cartItemCount } = useCart()

const productCount = computed(() => products.value.length)

const lowStockCount = computed(() =>
  products.value.filter((p) => (p.stock || 0) < 10).length
)

const orderCount = computed(() => orders.value.length)

const lowStockProducts = computed(() =>
  products.value
    .filter((p) => (p.stock || 0) < 10)
    .sort((a, b) => (a.stock || 0) - (b.stock || 0))
    .slice(0, 5)
)

const fetchData = async () => {
  try {
    loading.value = true

    const [productsResponse, ordersResponse] = await Promise.all([
      fetch('/api/products'),
      fetch('/api/orders'),
    ])

    if (productsResponse.ok) {
      products.value = await productsResponse.json()
    }

    if (ordersResponse.ok) {
      orders.value = await ordersResponse.json()
    }
  } catch (error) {
    console.error('Fout bij ophalen dashboardgegevens:', error)
  } finally {
    loading.value = false
  }
}

onMounted(fetchData)
</script>

<style scoped>
.home {
  background: #f7f7f7;
  min-height: calc(100vh - 100px);
}

.hero {
  background: linear-gradient(135deg, #f24b01 0%, #ff6f2a 100%);
  color: white;
  padding: 60px 20px;
  text-align: center;
}

.hero-content h1 {
  margin: 0;
  font-size: 2.5rem;
  margin-bottom: 12px;
}

.hero-content p {
  margin: 0;
  font-size: 1.1rem;
  opacity: 0.95;
}

.dashboard {
  max-width: 1200px;
  margin: 0 auto;
  padding: 32px 20px;
}

.summary-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 16px;
  margin-bottom: 32px;
}

.summary-card {
  background: white;
  border-radius: 14px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  padding: 24px;
  text-align: center;
}

.summary-card.warning {
  border-left: 4px solid #ff6f2a;
}

.summary-card h3 {
  margin: 0 0 12px;
  color: #2b2b2b;
  font-size: 0.95rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.summary-card .metric {
  margin: 0 0 8px;
  font-size: 2.5rem;
  font-weight: 700;
  color: #f24b01;
}

.summary-card .label {
  display: block;
  color: #666;
  font-size: 0.9rem;
}

.quick-actions {
  margin-bottom: 32px;
}

.quick-actions h2 {
  margin: 0 0 16px;
  color: #2b2b2b;
}

.action-buttons {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 12px;
}

.action-btn {
  background: white;
  border: 2px solid #f24b01;
  color: #f24b01;
  border-radius: 12px;
  padding: 16px;
  text-decoration: none;
  font-weight: 700;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  transition: all 0.2s ease;
}

.action-btn:hover {
  background: #f24b01;
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(242, 75, 1, 0.2);
}

.low-stock {
  background: white;
  border-radius: 14px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  padding: 24px;
}

.low-stock h2 {
  margin: 0 0 16px;
  color: #2b2b2b;
}

.low-stock-list {
  display: grid;
  gap: 12px;
}

.low-stock-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  border: 1px solid #efefef;
  border-radius: 10px;
}

.low-stock-item h4 {
  margin: 0;
  color: #2b2b2b;
}

.low-stock-item .stock-info {
  margin: 4px 0 0;
  color: #ff6f2a;
  font-size: 0.9rem;
}

.restock-link {
  background: #fff3eb;
  color: #b63b04;
  padding: 8px 12px;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 600;
  font-size: 0.9rem;
  border: 1px solid #ffd3be;
}

.restock-link:hover {
  background: #ffe6db;
}

@media (max-width: 820px) {
  .hero-content h1 {
    font-size: 1.8rem;
  }

  .summary-cards {
    grid-template-columns: repeat(2, 1fr);
  }

  .action-buttons {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>