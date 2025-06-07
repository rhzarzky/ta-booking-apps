// src/stores/booking.js

import { defineStore } from 'pinia';
import { bookingApi } from '@/api/booking-api';

export const useBookingStore = defineStore('booking', {
  state: () => ({
    bookingsByStatus: {}, // Akan menyimpan booking dikelompokkan berdasarkan status
    bookingDetail: null,
    loading: false,
    error: null,

    // State terkait review dan completion
    canReview: false,
    review: null, // Akan menyimpan objek review spesifik untuk bookingDetail
    completionStatus: null, // Akan menyimpan status completion untuk bookingDetail
    userReviews: [], // Akan menyimpan semua review yang dibuat user
  }),

  actions: {
    async fetchUserBookings() {
      this.loading = true;
      this.error = null;
      try {
        const services = await bookingApi.getUserBookings();
        // ✅ `services` sudah berbentuk objek yang dikelompokkan berdasarkan status
        this.bookingsByStatus = services || {}; 
      } catch (err) {
        this.error = 'Gagal memuat data booking.';
        this.bookingsByStatus = {};
        console.error(err);
      } finally {
        this.loading = false;
      }
    },

    async fetchBookingDetail(id) {
      this.loading = true;
      this.error = null;
      try {
        // ✅ Ini harusnya sesuai dengan return `bookingApi.getBookingDetail`
        // Jika bookingApi.getBookingDetail mengembalikan response.data.service, maka `detail` sudah objek service
        const detail = await bookingApi.getBookingDetail(id); 
        this.bookingDetail = detail || null; // Simpan objek service langsung
        
        // 🔥 Perhatian: Anda perlu juga memuat status completion dan review di sini
        // agar data lengkap saat detail booking dibuka
        await this.fetchCompletionStatus(id);
        await this.checkCanReview(id);
        await this.fetchBookingReview(id);

        if (!this.bookingDetail) {
          this.error = 'Detail booking tidak ditemukan.';
        }
      } catch (err) {
        this.error = 'Gagal memuat detail booking.';
        this.bookingDetail = null;
        console.error(err);
      } finally {
        this.loading = false;
      }
    },

    clearBookingDetail() {
      this.bookingDetail = null;
      this.review = null;
      this.completionStatus = null;
      this.canReview = false;
    },

    async completeBooking(id) {
      try {
        const response = await bookingApi.completeBooking(id);

        this.completionStatus = response.completion_status; // Update state global jika diperlukan

        // 🎉 Penting: Refresh semua booking agar ActivityCard terupdate
        await this.fetchUserBookings(); 

        // Optional: Refresh detail jika sedang melihat halaman detail
        if (this.bookingDetail && this.bookingDetail.id_booking === id) {
             await this.fetchBookingDetail(id);
        }

      } catch (error) {
        this.error = 'Gagal menyelesaikan booking.';
        console.error('Pinia Store: Error completing booking:', error); // Log error
        throw error; // Re-throw agar komponen yang memanggil bisa menangani
      }
    },

    async fetchCompletionStatus(id) {
      try {
        const data = await bookingApi.getCompletionStatus(id);
        // ✅ Controller mengembalikan data di properti 'data', contoh: `{ booking_id: 1, completion_status: 'completed' }`
        this.completionStatus = data?.completion_status || 'Pending'; // Set status completion
      } catch (error) {
        this.error = 'Gagal memuat status penyelesaian booking.';
        this.completionStatus = null;
        console.error(error);
      }
    },

    async checkCanReview(id) {
      try {
        const data = await bookingApi.canReview(id);
        // ✅ Controller mengembalikan data di properti 'data', contoh: `{ can_review: true, review_status: 'pending' }`
        this.canReview = data?.can_review || false;
      } catch (error) {
        this.error = 'Gagal memeriksa izin review.';
        this.canReview = false;
        console.error(error);
      }
    },

    async fetchBookingReview(id) {
      try {
        const data = await bookingApi.getReview(id);
        // ✅ Controller mengembalikan data di properti 'data', contoh: `{ review: {...}, booking: {...}, can_review: true }`
        this.review = data?.review || null;
      } catch (error) {
        this.error = 'Gagal memuat review.';
        this.review = null;
        console.error(error);
      }
    },

    async submitReview(id, reviewData) {
      try {
        const response = await bookingApi.submitReview(id, reviewData);
        // ✅ Controller mengembalikan objek review yang baru dibuat di properti `data`
        this.review = response || null; // response adalah objek review yang baru dibuat
        
        // Setelah submit review, refresh data booking dan status review
        await this.fetchUserBookings(); 
        await this.checkCanReview(id);
        await this.fetchBookingReview(id);

        return response;
      } catch (error) {
        this.error = 'Gagal mengirim review.';
        console.error(error);
        throw error; // Penting: lempar error kembali agar bisa ditangkap di komponen
      }
    },

    async fetchUserReviews() {
      try {
        const data = await bookingApi.getUserReviews();
        // ✅ Controller mengembalikan data di properti 'data', contoh: `{ reviews: [...] }`
        this.userReviews = data?.reviews || []; // Sesuaikan jika backend langsung mengirim array
      } catch (error) {
        this.error = 'Gagal memuat semua review user.';
        this.userReviews = [];
        console.error(error);
      }
    }
  }
});