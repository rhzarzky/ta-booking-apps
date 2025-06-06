// src/stores/bookmark.js
import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useBookmarkStore = defineStore('bookmark', () => {
  // State: Menyimpan daftar ID layanan yang dibookmark
  const bookmarkedServiceIds = ref([])

  // Inisialisasi state dari Local Storage saat store dibuat
  const loadBookmarksFromLocalStorage = () => {
    try {
      const storedBookmarks = localStorage.getItem('bookmarkedServices');
      if (storedBookmarks) {
        bookmarkedServiceIds.value = JSON.parse(storedBookmarks);
      }
    } catch (e) {
      console.error("Error loading bookmarks from local storage:", e);
      bookmarkedServiceIds.value = []; // Reset if there's an error
    }
  }

  // Action: Menyimpan state ke Local Storage
  const saveBookmarksToLocalStorage = () => {
    try {
      localStorage.setItem('bookmarkedServices', JSON.stringify(bookmarkedServiceIds.value));
    } catch (e) {
      console.error("Error saving bookmarks to local storage:", e);
    }
  }

  // Getter: Mengecek apakah suatu layanan sudah dibookmark
  const isBookmarked = (serviceId) => {
    return bookmarkedServiceIds.value.includes(serviceId);
  }

  // Action: Menambah bookmark
  const addBookmark = (serviceId) => {
    if (!isBookmarked(serviceId)) {
      bookmarkedServiceIds.value.push(serviceId);
      saveBookmarksToLocalStorage(); // Simpan perubahan
    }
  }

  // Action: Menghapus bookmark
  const removeBookmark = (serviceId) => {
    bookmarkedServiceIds.value = bookmarkedServiceIds.value.filter(id => id !== serviceId);
    saveBookmarksToLocalStorage(); // Simpan perubahan
  }

  // Panggil saat store diinisialisasi
  loadBookmarksFromLocalStorage();

  return {
    bookmarkedServiceIds,
    isBookmarked,
    addBookmark,
    removeBookmark,
    loadBookmarksFromLocalStorage // Expose if you need to manually reload
  }
})