const storageUtil = {
    get(key) {
      try {
        return localStorage.getItem(key);
      } catch (err) {
        console.error(`[storageUtil] Failed to get "${key}":`, err);
        return null;
      }
    },
    set(key, value) {
      try {
        localStorage.setItem(key, value);
      } catch (err) {
        console.error(`[storageUtil] Failed to set "${key}":`, err);
      }
    },
    remove(key) {
      try {
        localStorage.removeItem(key);
      } catch (err) {
        console.error(`[storageUtil] Failed to remove "${key}":`, err);
      }
    },
  };
  
  export const authServices = {
    getToken() {
      return storageUtil.get("token");
    },
    setToken(token) {
      storageUtil.set("token", token);
    },
    removeToken() {
      storageUtil.remove("token");
    },
  
    getUserId() {
      return storageUtil.get("userId");
    },
    setUserId(userId) {
      storageUtil.set("userId", userId);
    },
    removeUserId() {
      storageUtil.remove("userId");
    },
  
    /**
     * Returns API key from environment (if used).
     * Can be used in axios header like x-api-key
     */
    getApiKey() {
      return import.meta.env.VITE_API_KEY || null;
    },
  
    /**
     * Checks if user is authenticated by checking token presence
     * @returns {boolean}
     */
    isAuthenticated() {
      return !!this.getToken();
    },
  
    /**
     * Optional helper to clear all auth-related data
     */
    clearAuthData() {
      this.removeToken();
      this.removeUserId();
    }
  };
  