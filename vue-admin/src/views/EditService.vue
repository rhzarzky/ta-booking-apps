<script setup>
import { reactive, ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import DefaultLayout from "@/layout/DefaultLayout.vue";
import { useServicesStore } from "@/stores/service";
import { useAuthStore } from "@/stores/auth";
import AlertStatus from "@/components/alert/AlertStatus.vue";

const route = useRoute();
const router = useRouter();

const servicesStore = useServicesStore();
const authStore = useAuthStore(); // optional, if you're populating assigned users

const post = reactive({
    image: null,
    title: "",
    description: "",
    user_id: "",
    location: "",
    option: [],
    time: [],
    days: [],
    end_date: "",
});

const validation = ref([]);
const notification = ref("");
const assignedUsers = ref([]);

const cancel = () => {
    router.push({ path: "/service" });
};

const loadService = async () => {
    const { id } = route.params;
    const data = await servicesStore.fetchServiceDetail(id); // make sure this exists
    if (data) {
        post.title = data.title;
        post.description = data.description;
        post.user_id = data.user.id || ""; // assuming user_id is the assigned user
        post.location = data.location;
        post.option = data.option || [];
        post.time = data.time || [""];
        post.days = data.days || [];
        post.end_date = data.end_date;
        // Note: image cannot be set directly; user must re-upload
    }
};

const loadUsers = async () => {
    const { success, users } = await authStore.fetchUsersApi();

    if (success) {
        assignedUsers.value = users.filter(user =>
            Array.isArray(user.role) && !user.role.includes("user")
        );
    }
};

onMounted(() => {
    loadService();
    loadUsers();
});

const edit = async () => {
    const formData = new FormData();
    formData.append("_method", "PUT");
    formData.append("title", post.title);
    formData.append("description", post.description);
    formData.append("user_id", post.user_id);
    formData.append("location", post.location);
    formData.append("end_date", post.end_date);

    if (post.image) {
        formData.append("image", post.image, post.image.name);
    }

    post.option.forEach((opt, i) => {
        formData.append(`option[${i}]`, opt);
    });

    post.time.forEach((t, i) => {
        formData.append(`time[${i}]`, t);
    });

    post.days.forEach((day, i) => {
        formData.append(`days[${i}]`, day);
    });

    const { success, validationErrors } = await servicesStore.editService(route.params.id, formData);

    if (success) {
        servicesStore.showNotification("Service created successfully.", "success");
        router.push({ path: "/service" });
    } else {
        validation.value = validationErrors || {};
    }
};
</script>

<template>
    <DefaultLayout class="bg-whiteBgPrimary-100">
        <div class="max-h-fit md:p-9 p-4 flex flex-col gap-6 bg-white rounded-2xl">
            <div class="flex flex-col gap-1">
                <!-- Notifikasi -->
                <AlertStatus :message="servicesStore.notification.message" :type="servicesStore.notification.type"
                    :is-visible="servicesStore.notification.show" @close="servicesStore.notification.show = false" />
                <h2 class="text-codgray-900 md:text-2xl text-base font-semibold">Edit Service</h2>
            </div>

            <form @submit.prevent="edit" class="flex flex-col gap-6">
                <!-- Title -->
                <div class="flex flex-col gap-2">
                    <label for="title" class="text-sm md:text-base text-wildsand-600 flex gap-1">Title
                    </label>
                    <input id="title" type="text" placeholder="Enter service title" v-model="post.title"
                        class="w-full h-12 p-2 border border-wildsand-300 rounded-md text-base text-codgray-900 shadow-sm hover:border-cobalt-700 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700" />
                    <div v-if="validation.title" class="mt-2 text-red-600">
                        {{ validation.title[0] }}
                    </div>
                </div>

                <!-- Image -->
                <div class="flex flex-col gap-2">
                    <label for="image" class="text-sm md:text-base text-wildsand-600 flex gap-1">Image
                    </label>
                    <input type="file" id="image" @change="(e) => post.image = e.target.files[0]" />
                    <div v-if="validation.image" class="mt-2 text-red-600">
                        {{ validation.image[0] }}
                    </div>
                </div>

                <!-- Description -->
                <div class="flex flex-col gap-2">
                    <label for="description" class="text-sm md:text-base text-wildsand-600 flex gap-1">Description
                    </label>
                    <textarea id="description" v-model="post.description" placeholder="Enter service description"
                        class="w-full h-24 p-2 border border-wildsand-300 rounded-md text-base text-codgray-900 shadow-sm hover:border-cobalt-700 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700"></textarea>
                    <div v-if="validation.description" class="mt-2 text-red-600">
                        {{ validation.description[0] }}
                    </div>
                </div>

                <!-- Assigned -->
                <div class="flex flex-col gap-2">
                    <label for="assigned" class="text-sm md:text-base text-wildsand-600 flex gap-1">
                        Assigned
                    </label>
                    <select id="assigned" v-model="post.user_id"
                        class="w-full h-12 p-2 border border-wildsand-300 rounded-md">
                        <option value="" disabled>Select a user</option>
                        <option v-for="user in assignedUsers" :key="user.id" :value="user.id">
                            {{ user.email }}
                        </option>
                    </select>
                    <div v-if="validation.assigned" class="mt-2 text-red-600">
                        {{ validation.assigned[0] }}
                    </div>
                </div>


                <!-- Location -->
                <div class="flex flex-col gap-2">
                    <label for="location" class="text-sm md:text-base text-wildsand-600 flex gap-1">Location
                    </label>
                    <input id="location" type="text" placeholder="Enter service location" v-model="post.location"
                        class="w-full h-12 p-2 border border-wildsand-300 rounded-md text-base text-codgray-900 shadow-sm hover:border-cobalt-700 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700" />
                    <div v-if="validation.location" class="mt-2 text-red-600">
                        {{ validation.location[0] }}
                    </div>
                </div>

                <!-- Option -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm md:text-base text-wildsand-600 flex gap-1">Option
                    </label>
                    <div class="grid grid-cols-3 gap-2">
                        <label><input type="checkbox" value="Offline" v-model="post.option" /> Offline</label>
                        <label><input type="checkbox" value="Online" v-model="post.option" /> Online</label>
                    </div>
                    <div v-if="validation.option" class="mt-2 text-red-600">
                        {{ validation.option[0] }}
                    </div>
                </div>

                <!-- Time -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm md:text-base text-wildsand-600 flex gap-1">Time
                    </label>
                    <div v-for="(t, index) in post.time" :key="index" class="flex gap-2 items-center">
                        <input type="time" v-model="post.time[index]"
                            class="w-full h-12 p-2 border border-wildsand-300 rounded-md text-base text-codgray-900 shadow-sm hover:border-cobalt-700 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700" />
                        <button type="button" @click="post.time.splice(index, 1)"
                            class="text-red-500 hover:text-red-700" v-if="post.time.length > 1">&times;</button>
                    </div>
                    <button type="button" @click="post.time.push('')"
                        class="text-sm text-cobalt-700 hover:underline mt-1 w-fit">
                        + Add more time
                    </button>
                    <div v-if="validation.time" class="mt-2 text-red-600">
                        {{ validation.time[0] }}
                    </div>
                </div>

                <!-- Days -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm md:text-base text-wildsand-600 flex gap-1">Days
                    </label>
                    <div class="grid grid-cols-3 gap-2">
                        <label><input type="checkbox" value="Monday" v-model="post.days" /> Monday</label>
                        <label><input type="checkbox" value="Tuesday" v-model="post.days" /> Tuesday</label>
                        <label><input type="checkbox" value="Wednesday" v-model="post.days" /> Wednesday</label>
                        <label><input type="checkbox" value="Thursday" v-model="post.days" /> Thursday</label>
                        <label><input type="checkbox" value="Friday" v-model="post.days" /> Friday</label>
                        <label><input type="checkbox" value="Saturday" v-model="post.days" /> Saturday</label>
                        <label><input type="checkbox" value="Sunday" v-model="post.days" /> Sunday</label>
                    </div>
                    <div v-if="validation.days" class="mt-2 text-red-600">
                        {{ validation.days[0] }}
                    </div>
                </div>

                <!-- End Date -->
                <div class="flex flex-col gap-2">
                    <label for="end_date" class="text-sm md:text-base text-wildsand-600 flex gap-1">End Date
                    </label>
                    <input id="end_date" type="date" v-model="post.end_date"
                        class="w-full h-12 p-2 border border-wildsand-300 rounded-md text-base text-codgray-900 shadow-sm hover:border-cobalt-700 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700" />
                    <div v-if="validation.end_date" class="mt-2 text-red-600">
                        {{ validation.end_date[0] }}
                    </div>
                </div>

                <!-- Buttons -->
                <div class="flex justify-end gap-4">
                    <button type="button" @click="cancel"
                        class="w-36 py-2 px-4 bg-gray-200 text-gray-700 font-semibold rounded-xl hover:bg-gray-300">
                        Cancel
                    </button>
                    <button type="submit"
                        class="w-36 py-2 px-4 bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white font-semibold rounded-xl">
                        Edit Service
                    </button>
                </div>

                <!-- Notification -->
                <div v-if="notification" class="mt-4 p-4 bg-green-100 text-green-700 rounded">
                    {{ notification }}
                </div>
            </form>
        </div>
    </DefaultLayout>
</template>
