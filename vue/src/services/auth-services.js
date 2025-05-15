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

  clearAuthData() {
    this.removeToken();
    this.removeUserId();
  },

  isAuthenticated() {
    return !!this.getToken();
  },
};
