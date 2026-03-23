<template>
  <section class="cart-page">
    <header class="cart-header">
      <div>
        <h1>Jouw Mandje</h1>
        <p>Beheer je geselecteerde producten voor je bestelling.</p>
      </div>
      <RouterLink to="/inventory" class="back-link">Terug naar voorraad</RouterLink>
    </header>

    <div v-if="items.length === 0" class="empty-state">
      <h2>Je mandje is nog leeg</h2>
      <p>Voeg producten toe vanuit de voorraad om je bestelling te starten.</p>
      <RouterLink to="/inventory" class="primary-btn">Ga naar voorraad</RouterLink>
    </div>

    <div v-else class="cart-content">
      <div class="table-wrap">
        <table class="cart-table">
          <thead>
            <tr>
              <th>Product</th>
              <th>Prijs per stuk</th>
              <th>Hoeveelheid</th>
              <th>Subtotaal</th>
              <th>Actie</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in items" :key="item.id">
              <td>{{ item.name }}</td>
              <td>{{ formatPrice(item.price) }}</td>
              <td>
                <div class="qty-controls">
                  <button
                    class="qty-btn"
                    type="button"
                    aria-label="Verlaag hoeveelheid"
                    @click="decreaseQuantity(item.id)"
                  >
                    -
                  </button>
                  <span>{{ item.quantity }}</span>
                  <button
                    class="qty-btn"
                    type="button"
                    aria-label="Verhoog hoeveelheid"
                    @click="increaseQuantity(item.id)"
                  >
                    +
                  </button>
                </div>
              </td>
              <td>{{ formatPrice(item.price * item.quantity) }}</td>
              <td>
                <button class="remove-btn" type="button" @click="removeItem(item.id)">
                  Verwijderen
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <footer class="cart-footer">
        <div class="totals">
          <p>
            <span>Totaal aantal items</span>
            <strong>{{ totalProducts }}</strong>
          </p>
          <p>
            <span>Totale prijs</span>
            <strong>{{ formatPrice(totalPrice) }}</strong>
          </p>
        </div>

        <div class="footer-actions">
          <button class="secondary-btn" type="button" @click="clearCart">
            Mandje leegmaken
          </button>
          <RouterLink to="/checkout" class="primary-btn">Verder naar checkout</RouterLink>
        </div>
      </footer>
    </div>
  </section>
</template>

<script setup>
import { useCart } from '@/stores/cart'

const {
  items,
  removeItem,
  increaseQuantity,
  decreaseQuantity,
  clearCart,
  totalProducts,
  totalPrice,
} = useCart()

const formatPrice = (price) => {
  const safeNumber = Number(price || 0)

  return new Intl.NumberFormat('nl-BE', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: 2,
  }).format(safeNumber)
}
</script>

<style scoped>
.cart-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 32px 20px 48px;
}

.cart-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 16px;
  margin-bottom: 24px;
}

.cart-header h1 {
  margin: 0;
  color: #2b2b2b;
}

.cart-header p {
  margin: 8px 0 0;
  color: #666;
}

.back-link {
  color: #f24b01;
  text-decoration: none;
  font-weight: 700;
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

.cart-content {
  display: grid;
  gap: 18px;
}

.table-wrap {
  overflow-x: auto;
}

.cart-table {
  width: 100%;
  border-collapse: collapse;
  background: #fff;
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
}

.cart-table thead {
  background: #f24b01;
  color: #fff;
}

.cart-table th,
.cart-table td {
  padding: 14px 16px;
  text-align: left;
  white-space: nowrap;
}

.cart-table tbody tr {
  border-bottom: 1px solid #efefef;
}

.cart-table tbody tr:last-child {
  border-bottom: none;
}

.qty-controls {
  display: inline-flex;
  align-items: center;
  gap: 10px;
}

.qty-btn {
  width: 30px;
  height: 30px;
  border-radius: 8px;
  border: 1px solid #e2e2e2;
  background: #fff;
  font-weight: 700;
  cursor: pointer;
}

.qty-btn:hover {
  border-color: #f24b01;
  color: #f24b01;
}

.remove-btn {
  border: 0;
  border-radius: 10px;
  background: #ffe6db;
  color: #b63b04;
  font-weight: 700;
  padding: 8px 12px;
  cursor: pointer;
}

.remove-btn:hover {
  background: #ffd3be;
}

.cart-footer {
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  padding: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 14px;
}

.totals {
  display: grid;
  gap: 8px;
}

.totals p {
  margin: 0;
  display: flex;
  gap: 8px;
  color: #444;
}

.totals strong {
  color: #1e1e1e;
}

.footer-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.primary-btn,
.secondary-btn {
  border-radius: 10px;
  font-weight: 700;
  padding: 10px 14px;
  text-decoration: none;
  border: 0;
  cursor: pointer;
}

.primary-btn {
  background: #f24b01;
  color: #fff;
}

.primary-btn:hover {
  background: #d94200;
}

.secondary-btn {
  background: #fff3eb;
  color: #b63b04;
  border: 1px solid #ffd3be;
}

.secondary-btn:hover {
  background: #ffe6db;
}

@media (max-width: 820px) {
  .cart-header {
    flex-direction: column;
    align-items: stretch;
  }

  .cart-footer {
    flex-direction: column;
    align-items: stretch;
  }

  .footer-actions {
    justify-content: stretch;
  }

  .primary-btn,
  .secondary-btn {
    width: 100%;
    text-align: center;
  }
}
</style>
