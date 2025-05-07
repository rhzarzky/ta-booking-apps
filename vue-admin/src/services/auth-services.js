const storageUtil = {
  get(key) {
    try {
      return localStorage.getItem(key);
    } catch (err) {
      console.error(`failed to retrieve ${key}:`, err);
    }
  },
  set(key, value) {
    try {
      localStorage.setItem(key, value);
    } catch (err) {
      console.error(`failed to set ${key}:`, err);
    }
  },
  remove(key) {
    try {
      localStorage.removeItem(key);
    } catch (err) {
      console.error(`failed to removes ${key}:`, err);
    }
  },
};

export const authServices = {
  /**
   *
   * @returns {string|null} the token or nll if not found
   */
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
  getRole() {
    return storageUtil.get("role");
  },
  setRole(role) {
    storageUtil.set("role", role);
  },
  removeRole() {
    storageUtil.remove("role");
  },
  getApiKey() {
    return import.meta.env.VITE_API_KEY;
  },
  isAuthenticated() {
    return !!this.getToken();
  },
};
