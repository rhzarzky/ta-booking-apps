const storageUtil = {
  get(key) {
    try {
      return localStorage.getItem(key);
    } catch (err) {
      console.error(`Failed to retrieve ${key}:`, err);
      return null;
    }
  },

  set(key, value) {
    try {
      localStorage.setItem(key, value);
    } catch (err) {
      console.error(`Failed to set ${key}:`, err);
    }
  },

  remove(key) {
    try {
      localStorage.removeItem(key);
    } catch (err) {
      console.error(`Failed to remove ${key}:`, err);
    }
  },
};

export const authServices = {
  // Simpan token ke localStorage
  setToken(token) {
    localStorage.setItem('token', token)
  },

  getToken() {
    return localStorage.getItem('token')
  },

  removeToken() {
    localStorage.removeItem('token')
  },

  // Simpan data user
  setUser(user) {
    localStorage.setItem('user', JSON.stringify(user))
  },

  getUser() {
    const user = localStorage.getItem('user')
    return user ? JSON.parse(user) : null
  },

  removeUser() {
    localStorage.removeItem('user')
  },

  // ✅ Tambahan untuk ID user
  setUserId(id) {
    localStorage.setItem('user_id', id)
  },
  getUserId() {
    return localStorage.getItem('user_id')
  },
  removeUserId() {
    localStorage.removeItem('user_id')
  },

  // ✅ Cek login
  isLoggedIn() {
    return !!this.getToken()
  }
}

// 🔍 Log untuk memastikan semua fungsi tersedia
console.log('[authServices] Available methods:', Object.keys(authServices))
