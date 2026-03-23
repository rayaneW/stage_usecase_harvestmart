import { computed, reactive } from 'vue'

const STORAGE_KEY = 'freshmart-cart'

const loadCartFromStorage = () => {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)

    if (!raw) {
      return []
    }

    const parsed = JSON.parse(raw)

    if (!Array.isArray(parsed)) {
      return []
    }

    return parsed
      .filter((item) => item && typeof item.id !== 'undefined')
      .map((item) => ({
        id: item.id,
        name: String(item.name || ''),
        price: Number(item.price || 0),
        quantity: Math.max(1, Number(item.quantity || 1)),
      }))
  } catch (error) {
    console.error('Kon mandje niet laden uit localStorage:', error)
    return []
  }
}

const state = reactive({
  items: loadCartFromStorage(),
})

const persistCart = () => {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state.items))
}

const findItem = (productId) => state.items.find((item) => item.id === productId)

const addItem = (product) => {
  if (!product || typeof product.id === 'undefined') {
    return
  }

  const existingItem = findItem(product.id)

  if (existingItem) {
    existingItem.quantity += 1
  } else {
    state.items.push({
      id: product.id,
      name: String(product.name || ''),
      price: Number(product.price || 0),
      quantity: 1,
    })
  }

  persistCart()
}

const removeItem = (productId) => {
  const index = state.items.findIndex((item) => item.id === productId)

  if (index === -1) {
    return
  }

  state.items.splice(index, 1)
  persistCart()
}

const increaseQuantity = (productId) => {
  const item = findItem(productId)

  if (!item) {
    return
  }

  item.quantity += 1
  persistCart()
}

const decreaseQuantity = (productId) => {
  const item = findItem(productId)

  if (!item) {
    return
  }

  if (item.quantity <= 1) {
    removeItem(productId)
    return
  }

  item.quantity -= 1
  persistCart()
}

const clearCart = () => {
  state.items.splice(0, state.items.length)
  persistCart()
}

const totalProducts = computed(() =>
  state.items.reduce((total, item) => total + item.quantity, 0)
)

const totalPrice = computed(() =>
  state.items.reduce((total, item) => total + item.price * item.quantity, 0)
)

export const useCart = () => ({
  items: state.items,
  addItem,
  removeItem,
  increaseQuantity,
  decreaseQuantity,
  clearCart,
  totalProducts,
  totalPrice,
})
