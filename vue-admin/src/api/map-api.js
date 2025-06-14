import axios from 'axios'

const token = import.meta.env.VITE_MAPBOX_ACCESS_TOKEN

export const reverseGeocode = async (lng, lat) => {
  try {
    const res = await axios.get(
      `https://api.mapbox.com/geocoding/v5/mapbox.places/${lng},${lat}.json`,
      {
        params: {
          access_token: token
        },
        withCredentials: false
      }
    )
    return res.data.features?.[0]?.place_name || ''
  } catch (err) {
    console.error('Reverse geocode error:', err)
    return ''
  }
}

export const forwardGeocode = async (query) => {
  try {
    const trimmedQuery = encodeURIComponent(query.trim()) 
    const res = await axios.get(
      `https://api.mapbox.com/geocoding/v5/mapbox.places/${trimmedQuery}.json`,
      {
        params: {
          access_token: token,
          limit: 1
        },
        withCredentials: false
      }
    )
    const feature = res.data.features?.[0]
    return feature
      ? { lng: feature.center[0], lat: feature.center[1], name: feature.place_name }
      : null
  } catch (err) {
    console.error('Forward geocode error:', err)
    return null
  }
}
