<template>
  <div class="app-shell">
    <header class="header">
      <router-link to="/" class="logo-container">
        <img
          src="@/assets/FreshMart_Logo_inv.png"
          class="logo normal"
          alt="FreshMart Logo"
        />

        <img
          src="@/assets/FreshMart_Logo.png"
          class="logo hover"
          alt="FreshMart Logo Hover"
        />
      </router-link>

      <nav>
        <router-link to="/">Home</router-link>
        <router-link to="/orders">Bestelling</router-link>
        <router-link to="/inventory">Voorraad</router-link>
        <router-link to="/restock">Restock</router-link>
        <router-link to="/cart" class="cart-link">
          <span>Mandje</span>
          <span class="cart-count">{{ totalProducts }}</span>
        </router-link>
      </nav>
    </header>

    <RouterView />
  </div>
</template>

<script setup>
import { RouterView } from 'vue-router'
import { useCart } from '@/stores/cart'

const { totalProducts } = useCart()
</script>

<style>
html, body, #app {
  margin: 0;
  padding: 0;
  min-height: 100%;
  font-family: Arial, sans-serif;
  background: #f7f7f7;
}

.header {
  background: #f24b01;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 40px 0 0;
  height: 100px;
}

.logo-container {
  position: relative;
  display: flex;
  align-items: center;
  height: 60px;
}

.logo {
  height: 100px;
  transition: opacity 0.2s ease;
}

.logo.hover {
  position: absolute;
  left: 0;
  opacity: 0;
}

.logo-container:hover .normal {
  opacity: 0;
}

.logo-container:hover .hover {
  opacity: 1;
}

nav a {
  color: white;
  margin-left: 25px;
  text-decoration: none;
  font-weight: 600;
}

nav a:hover {
  opacity: 0.8;
}

nav {
  display: flex;
  align-items: center;
}

.cart-link {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.cart-count {
  min-width: 24px;
  height: 24px;
  border-radius: 999px;
  background: #fff;
  color: #f24b01;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 0.85rem;
  font-weight: 700;
  padding: 0 6px;
}

@media (max-width: 820px) {
  .header {
    height: auto;
    padding: 10px 18px 14px;
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .logo {
    height: 82px;
  }

  nav {
    flex-wrap: wrap;
    gap: 10px 14px;
  }

  nav a {
    margin-left: 0;
  }
}
</style>