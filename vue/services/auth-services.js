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
  // Token
  getToken() {
    return storageUtil.get("token");
  },

  setToken(token) {
    storageUtil.set("token", token);
  },

  removeToken() {
    storageUtil.remove("token");
  },

  // User
  setUser(user) {
    storageUtil.set("user", JSON.stringify(user));
  },

  getUser() {
    const data = storageUtil.get("user");
    return data ? JSON.parse(data) : null;
  },

  removeUser() {
    storageUtil.remove("user");
  },

  // API Key (opsional, kalau kamu pakai x-api-key)
  getApiKey() {
    return import.meta.env.VITE_API_KEY || null;
  },

  // Auth State
  isLoggedIn() {
    return !!this.getToken();
  },

  clearAuth() {
    this.removeToken();
    this.removeUser();
  },
};
