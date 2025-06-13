import api from "./api";

// GET reverse geocode API
export const reverseGeocodeApi = (lng, lat) =>
    api.get(`https://api.mapbox.com/geocoding/v5/mapbox.places/${lng},${lat}.json`);

// GET search geocode API
export const searchGeocodeApi = (searchQuery) =>
    api.get(`https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(searchQuery)}.json`);