<template>
  <section class="checkout-page">
    <header class="checkout-header">
      <div>
        <h1>Checkout</h1>
        <p>Controleer je mandje en plaats je bestelling.</p>
      </div>
      <RouterLink to="/cart" class="back-link">Terug naar mandje</RouterLink>
    </header>

    <p v-if="successMessage" class="success-message">{{ successMessage }}</p>
    <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>

    <div v-if="items.length === 0" class="empty-state">
      <h2>Je mandje is leeg</h2>
      <p>Voeg eerst producten toe vanuit de voorraad.</p>
      <RouterLink to="/inventory" class="primary-btn">Ga naar voorraad</RouterLink>
    </div>

    <div v-else class="checkout-content">
      <div class="table-wrap">
        <table class="checkout-table">
          <thead>
            <tr>
              <th>Product</th>
              <th>Prijs per stuk</th>
              <th>Hoeveelheid</th>
              <th>Subtotaal</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in items" :key="item.id">
              <td>{{ item.name }}</td>
              <td>{{ formatPrice(item.price) }}</td>
              <td>{{ item.quantity }}</td>
              <td>{{ formatPrice(item.price * item.quantity) }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="summary-card">
        <p>
          <span>Totaal aantal items</span>
          <strong>{{ totalProducts }}</strong>
        </p>
        <p>
          <span>Totale prijs</span>
          <strong>{{ formatPrice(totalPrice) }}</strong>
        </p>
      </div>

      <form class="checkout-form" @submit.prevent="submitOrder">
        <h2>Bestelgegevens</h2>

        <label for="customerName">Klantnaam</label>
        <input
          id="customerName"
          v-model.trim="form.customerName"
          type="text"
          required
          placeholder="Bijv. Jan Peeters"
        />

        <label for="branch">Filiaal</label>
        <input
          id="branch"
          v-model.trim="form.branch"
          type="text"
          required
          placeholder="Bijv. FreshMart Gent"
        />

        <label for="requestedDate">Gewenste datum</label>
        <input
          id="requestedDate"
          v-model="form.requestedDate"
          type="date"
          required
        />

        <button class="primary-btn" type="submit" :disabled="isSubmitting">
          {{ isSubmitting ? 'Bestelling plaatsen...' : 'Bestelling plaatsen' }}
        </button>
      </form>
    </div>
  </section>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useCart } from '@/stores/cart'

const router = useRouter()
const { items, totalProducts, totalPrice, clearCart } = useCart()

const isSubmitting = ref(false)
const successMessage = ref('')
const errorMessage = ref('')

const form = reactive({
  customerName: '',
  branch: '',
  requestedDate: '',
})

const formatPrice = (price) => {
  const safeNumber = Number(price || 0)

  return new Intl.NumberFormat('nl-BE', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: 2,
  }).format(safeNumber)
}

const buildPayload = () => ({
  customerName: form.customerName,
  branch: form.branch,
  requestedDate: form.requestedDate,
  items: items.map((item) => ({
    productId: item.id,
    productName: item.name,
    quantity: item.quantity,
    price: item.price,
  })),
  totalPrice: Number(totalPrice.value.toFixed(2)),
})

const submitOrder = async () => {
  if (items.length === 0 || isSubmitting.value) {
    return
  }

  errorMessage.value = ''
  successMessage.value = ''
  isSubmitting.value = true

  try {
    const response = await fetch('/api/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(buildPayload()),
    })

    if (!response.ok) {
      let errorText = 'Kon bestelling niet plaatsen.'

      try {
        const errorBody = await response.json()
        if (errorBody?.message) {
          errorText = errorBody.message
        }
      } catch {
        // Keep default message when error body is not JSON.
      }

      throw new Error(errorText)
    }

    successMessage.value = 'Bestelling succesvol geplaatst. Je wordt doorgestuurd...'
    clearCart()

    setTimeout(() => {
      router.push('/inventory')
    }, 1200)
  } catch (error) {
    errorMessage.value = error?.message || 'Er ging iets mis bij het plaatsen van je bestelling.'
    console.error(error)
  } finally {
    isSubmitting.value = false
  }
}
</script>

<style scoped>
.checkout-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 32px 20px 48px;
}

.checkout-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 16px;
  margin-bottom: 22px;
}

.checkout-header h1 {
  margin: 0;
  color: #2b2b2b;
}

.checkout-header p {
  margin: 8px 0 0;
  color: #666;
}

.back-link {
  color: #f24b01;
  text-decoration: none;
  font-weight: 700;
}

.success-message,
.error-message {
  margin: 0 0 14px;
  padding: 10px 12px;
  border-radius: 10px;
  font-weight: 600;
}

.success-message {
  background: #e9f9ee;
  border: 1px solid #b6ebc5;
  color: #1b7f3a;
}

.error-message {
  background: #ffecec;
  border: 1px solid #ffc8c8;
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

.checkout-content {
  display: grid;
  gap: 18px;
}

.table-wrap {
  overflow-x: auto;
}

.checkout-table {
  width: 100%;
  border-collapse: collapse;
  background: #fff;
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
}

.checkout-table thead {
  background: #f24b01;
  color: #fff;
}

.checkout-table th,
.checkout-table td {
  padding: 14px 16px;
  text-align: left;
  white-space: nowrap;
}

.checkout-table tbody tr {
  border-bottom: 1px solid #efefef;
}

.checkout-table tbody tr:last-child {
  border-bottom: none;
}

.summary-card {
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  padding: 16px;
  display: grid;
  gap: 8px;
}

.summary-card p {
  margin: 0;
  display: flex;
  gap: 8px;
  color: #444;
}

.summary-card strong {
  color: #1e1e1e;
}

.checkout-form {
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  padding: 16px;
  display: grid;
  gap: 10px;
}

.checkout-form h2 {
  margin: 0 0 2px;
  color: #2b2b2b;
}

.checkout-form label {
  font-weight: 600;
  color: #444;
}

.checkout-form input {
  border: 1px solid #d8d8d8;
  border-radius: 10px;
  padding: 10px 12px;
  font: inherit;
}

.checkout-form input:focus {
  outline: 2px solid #ffd3be;
  border-color: #f24b01;
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

.primary-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

@media (max-width: 820px) {
  .checkout-header {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
