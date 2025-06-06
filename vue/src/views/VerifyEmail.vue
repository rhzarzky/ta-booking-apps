<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-indigo-100 to-white">
    <div class="bg-white shadow-xl rounded-2xl p-8 max-w-lg w-full text-center animate-fade-in">
      <div class="flex justify-center mb-5">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 text-indigo-600" fill="none" viewBox="0 0 24 24"
             stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M16 12H8m0 0l-4 4m4-4l4-4m8 8V8a2 2 0 00-2-2H6a2 2 0 00-2 2v8a2 2 0 002 2h12a2 2 0 002-2z"/>
        </svg>
      </div>
      <h1 class="text-2xl font-bold text-gray-800 mb-2">Check Your Email</h1>
      <p class="text-gray-600 mb-6">
        We have sent a verification email to <span class="font-semibold text-indigo-600">{{ maskedEmail }}</span>.<br>
        Please click the verification link in your email to activate your account.
      </p>
      <router-link to="/login"
                   class="inline-block mt-4 text-indigo-600 font-medium hover:underline transition">
        Back to Login Page
      </router-link>
    </div>
  </div>
</template>

<script>
export default {
  name: 'VerifyEmail',
  data() {
    return {
      email: sessionStorage.getItem('verif_email') || ''
    }
  },
  computed: {
    maskedEmail() {
      const email = this.email
      if (!email || !email.includes('@')) return 'Your email'
      const [user, domain] = email.split('@')
      const maskedUser = user.length > 2 ? user.slice(0, 2) + '*'.repeat(user.length - 2) : user[0] + '*'
      return `${maskedUser}@${domain}`
    }
  }
}
</script>
