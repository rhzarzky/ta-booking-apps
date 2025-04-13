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

  // Ambil token dari localStorage
  getToken() {
    return localStorage.getItem('token')
  },

  // Hapus token dari localStorage
  removeToken() {
    localStorage.removeItem('token')
  },

  // Simpan data user
  setUser(user) {
    localStorage.setItem('user', JSON.stringify(user))
  },

  // Ambil data user
  getUser() {
    const user = localStorage.getItem('user')
    return user ? JSON.parse(user) : null
  },

  // Hapus data user
  removeUser() {
    localStorage.removeItem('user')
  },

  // ✅ Cek apakah user login berdasarkan token
  isLoggedIn() {
    return !!this.getToken()
  }
}

// 🔍 Log untuk memastikan semua fungsi tersedia
console.log('[authServices] Available methods:', Object.keys(authServices))
