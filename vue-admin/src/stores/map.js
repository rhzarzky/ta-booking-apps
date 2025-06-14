import { defineStore } from "pinia";
import { ref } from "vue";
import mapboxgl from "mapbox-gl";
import { reverseGeocode, forwardGeocode } from "@/api/map-api";

// Set token
mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_ACCESS_TOKEN;

export const useMapStore = defineStore("map", () => {
  const map = ref(null);
  const mapContainer = ref(null);
  const location = ref("");
  const lng = ref(106.816666); // Default Jakarta
  const lat = ref(-6.200000);
  const searchQuery = ref("");
  const marker = ref(null);

  const initMap = () => {
    if (!mapContainer.value) return;

    map.value = new mapboxgl.Map({
      container: mapContainer.value,
      style: "mapbox://styles/mapbox/streets-v11",
      center: [lng.value, lat.value],
      zoom: 13,
    });

    marker.value = new mapboxgl.Marker({ draggable: true })
      .setLngLat([lng.value, lat.value])
      .addTo(map.value)

    marker.value.on('dragend', async () => {
      const { lng: newLng, lat: newLat } = marker.value.getLngLat()
      lng.value = newLng
      lat.value = newLat
      const place = await reverseGeocode(newLng, newLat)
      if (place) {
        location.value = place
      }
    })

    reverseGeocode(lng.value, lat.value).then(place => {
      location.value = place;
    });
  };

  const searchLocation = async () => {
    if (!searchQuery.value) return;

    const result = await forwardGeocode(searchQuery.value);
    if (result) {
      lng.value = result.lng;
      lat.value = result.lat;
      location.value = result.name;

      map.value?.flyTo({
        center: [lng.value, lat.value],
        zoom: 14,
      });

      marker.value?.setLngLat([lng.value, lat.value]);
    }
  };

  return {
    map,
    mapContainer,
    lng,
    lat,
    location,
    searchQuery,
    initMap,
    searchLocation,
  };
});
