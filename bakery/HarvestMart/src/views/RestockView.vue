<template>
  <section class="restock-page">
    <header class="restock-header">
      <div>
        <h1>Restock Beheer</h1>
        <p>Vraag voorraad aan en volg de status van leveringen op.</p>
      </div>
      <RouterLink to="/inventory" class="back-link">Terug naar voorraad</RouterLink>
    </header>

    <p v-if="successMessage" class="success-message">{{ successMessage }}</p>
    <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>

    <form class="restock-form" @submit.prevent="createRestockRequest">
      <h2>Nieuwe restock request</h2>

      <label for="productId">Product ID</label>
      <input
        id="productId"
        v-model.number="form.productId"
        type="number"
        min="1"
        required
        placeholder="Bijv. 1"
      />

      <label for="requestedQuantity">Requested quantity</label>
      <input
        id="requestedQuantity"
        v-model.number="form.requestedQuantity"
        type="number"
        min="1"
        required
        placeholder="Bijv. 20"
      />

      <button class="primary-btn" type="submit" :disabled="isSubmitting">
        {{ isSubmitting ? 'Bezig...' : 'Request aanmaken' }}
      </button>
    </form>

    <div v-if="loading" class="state-message">
      Restock requests worden geladen...
    </div>

    <div v-else-if="requests.length === 0" class="empty-state">
      <h2>Nog geen restock requests</h2>
      <p>Maak hierboven een nieuwe aanvraag om voorraad aan te vullen.</p>
    </div>

    <div v-else class="requests-grid">
      <article v-for="request in requests" :key="request.id" class="request-card">
        <header class="card-header">
          <h3>{{ request.productName || `Product #${request.productId}` }}</h3>
          <span class="status-chip" :class="statusClass(request.status)">{{ request.status }}</span>
        </header>

        <div class="request-meta">
          <p><span>Requested quantity</span><strong>{{ request.requestedQuantity }}</strong></p>
          <p><span>Aangemaakt op</span><strong>{{ formatDateTime(request.createdAt) }}</strong></p>
        </div>

        <div class="card-actions">
          <button
            class="secondary-btn"
            type="button"
            :disabled="request.status !== 'PENDING' || actionLoadingId === request.id"
            @click="approveRequest(request.id)"
          >
            Approve
          </button>

          <button
            class="primary-btn"
            type="button"
            :disabled="request.status !== 'APPROVED' || actionLoadingId === request.id"
            @click="deliverRequest(request.id)"
          >
            Deliver
          </button>
        </div>
      </article>
    </div>
  </section>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'

const requests = ref([])
const loading = ref(true)
const isSubmitting = ref(false)
const actionLoadingId = ref(null)
const successMessage = ref('')
const errorMessage = ref('')

const form = reactive({
  productId: null,
  requestedQuantity: null,
})

const formatDateTime = (value) => {
  if (!value) {
    return '-'
  }

  const parsedDate = new Date(value)

  if (Number.isNaN(parsedDate.getTime())) {
    return String(value)
  }

  return new Intl.DateTimeFormat('nl-BE', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(parsedDate)
}

const statusClass = (status) => {
  if (status === 'DELIVERED') {
    return 'delivered'
  }

  if (status === 'APPROVED') {
    return 'approved'
  }

  return 'pending'
}

const readErrorMessage = async (response) => {
  try {
    const data = await response.json()
    return data?.message || 'Er ging iets mis met de request.'
  } catch {
    return 'Er ging iets mis met de request.'
  }
}

const fetchRestockRequests = async () => {
  try {
    loading.value = true
    errorMessage.value = ''

    const response = await fetch('/api/restocks')

    if (!response.ok) {
      throw new Error('Kon restock requests niet ophalen.')
    }

    const data = await response.json()
    requests.value = Array.isArray(data) ? data : []
  } catch (error) {
    errorMessage.value = 'Er ging iets mis bij het ophalen van restock requests.'
    console.error(error)
  } finally {
    loading.value = false
  }
}

const createRestockRequest = async () => {
  if (isSubmitting.value) {
    return
  }

  successMessage.value = ''
  errorMessage.value = ''
  isSubmitting.value = true

  try {
    const response = await fetch('/api/restocks', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        productId: form.productId,
        requestedQuantity: form.requestedQuantity,
      }),
    })

    if (!response.ok) {
      throw new Error(await readErrorMessage(response))
    }

    successMessage.value = 'Restock request succesvol aangemaakt.'
    form.productId = null
    form.requestedQuantity = null
    await fetchRestockRequests()
  } catch (error) {
    errorMessage.value = error.message || 'Kon restock request niet aanmaken.'
    console.error(error)
  } finally {
    isSubmitting.value = false
  }
}

const approveRequest = async (id) => {
  actionLoadingId.value = id
  successMessage.value = ''
  errorMessage.value = ''

  try {
    const response = await fetch(`/api/restocks/${id}/approve`, {
      method: 'PATCH',
    })

    if (!response.ok) {
      throw new Error(await readErrorMessage(response))
    }

    successMessage.value = `Request #${id} is goedgekeurd.`
    await fetchRestockRequests()
  } catch (error) {
    errorMessage.value = error.message || 'Kon request niet goedkeuren.'
    console.error(error)
  } finally {
    actionLoadingId.value = null
  }
}

const deliverRequest = async (id) => {
  actionLoadingId.value = id
  successMessage.value = ''
  errorMessage.value = ''

  try {
    const response = await fetch(`/api/restocks/${id}/deliver`, {
      method: 'PATCH',
    })

    if (!response.ok) {
      throw new Error(await readErrorMessage(response))
    }

    successMessage.value = `Request #${id} is geleverd en stock werd verhoogd.`
    await fetchRestockRequests()
  } catch (error) {
    errorMessage.value = error.message || 'Kon request niet leveren.'
    console.error(error)
  } finally {
    actionLoadingId.value = null
  }
}

onMounted(fetchRestockRequests)
</script>

<style scoped>
.restock-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 32px 20px 48px;
}

.restock-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 16px;
  margin-bottom: 22px;
}

.restock-header h1 {
  margin: 0;
  color: #2b2b2b;
}

.restock-header p {
  margin: 8px 0 0;
  color: #666;
}

.back-link {
  color: #f24b01;
  text-decoration: none;
  font-weight: 700;
}

.restock-form {
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  padding: 16px;
  display: grid;
  gap: 10px;
  margin-bottom: 18px;
}

.restock-form h2 {
  margin: 0 0 2px;
  color: #2b2b2b;
}

.restock-form label {
  font-weight: 600;
  color: #444;
}

.restock-form input {
  border: 1px solid #d8d8d8;
  border-radius: 10px;
  padding: 10px 12px;
  font: inherit;
}

.restock-form input:focus {
  outline: 2px solid #ffd3be;
  border-color: #f24b01;
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

.state-message {
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  padding: 16px;
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
  margin: 0;
  color: #666;
}

.requests-grid {
  display: grid;
  gap: 16px;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
}

.request-card {
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

.card-header h3 {
  margin: 0;
  color: #2b2b2b;
  font-size: 1.1rem;
}

.status-chip {
  border-radius: 999px;
  padding: 6px 10px;
  font-weight: 700;
  border: 1px solid transparent;
}

.status-chip.pending {
  background: #fff3eb;
  color: #b63b04;
  border-color: #ffd3be;
}

.status-chip.approved {
  background: #e8f1ff;
  color: #225ea8;
  border-color: #c8dbff;
}

.status-chip.delivered {
  background: #e9f9ee;
  color: #1b7f3a;
  border-color: #b6ebc5;
}

.request-meta {
  display: grid;
  gap: 8px;
}

.request-meta p {
  margin: 0;
  display: flex;
  justify-content: space-between;
  gap: 10px;
  color: #4a4a4a;
}

.request-meta strong {
  color: #1e1e1e;
}

.card-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
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

.primary-btn:disabled,
.secondary-btn:disabled {
  opacity: 0.65;
  cursor: not-allowed;
}

@media (max-width: 820px) {
  .restock-header {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
