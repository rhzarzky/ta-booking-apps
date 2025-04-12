// Utility untuk penyimpanan di localStorage
const storageUtil = {
    // Mengambil nilai dari localStorage berdasarkan key
    get(key) {
      try {
        return localStorage.getItem(key);
      } catch (err) {
        console.error(`[storageUtil] Failed to get "${key}":`, err);
        return null;
      }
    },
    
    // Menyimpan nilai ke localStorage berdasarkan key
    set(key, value) {
      try {
        localStorage.setItem(key, value);
      } catch (err) {
        console.error(`[storageUtil] Failed to set "${key}":`, err);
      }
    },
    
    // Menghapus nilai dari localStorage berdasarkan key
    remove(key) {
      try {
        localStorage.removeItem(key);
      } catch (err) {
        console.error(`[storageUtil] Failed to remove "${key}":`, err);
      }
    },
  };
  
  // authServices untuk menangani operasi terkait autentikasi
  export const authServices = {
    // Mengambil token dari localStorage
    getToken() {
      return storageUtil.get("token");
    },
    
    // Menyimpan token ke localStorage
    setToken(token) {
      storageUtil.set("token", token);
    },
    
    // Menghapus token dari localStorage
    removeToken() {
      storageUtil.remove("token");
    },
    
    // Mengambil userId dari localStorage
    getUserId() {
      return storageUtil.get("userId");
    },
    
    // Menyimpan userId ke localStorage
    setUserId(userId) {
      storageUtil.set("userId", userId);
    },
    
    // Menghapus userId dari localStorage
    removeUserId() {
      storageUtil.remove("userId");
    },
    
    /**
     * Mengambil API key dari environment, jika digunakan
     * Digunakan untuk header axios seperti `x-api-key`
     */
    getApiKey() {
      return import.meta.env.VITE_API_KEY || null;
    },
    
    /**
     * Memeriksa apakah pengguna sudah terautentikasi dengan memeriksa keberadaan token
     * @returns {boolean} True jika pengguna terautentikasi
     */
    isAuthenticated() {
      return !!this.getToken(); // Memeriksa apakah token ada
    },
    
    /**
     * Membersihkan semua data autentikasi terkait (token dan userId)
     */
    clearAuthData() {
      this.removeToken();
      this.removeUserId();
    },
  };
  