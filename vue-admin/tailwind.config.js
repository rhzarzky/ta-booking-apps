/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{vue,js,ts,jsx,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        Poppins: ["Poppins"],
        CourierPrime: ["Courier Prime"],
      },
      colors: {
        whiteBgPrimary: {
          100: "#EEEEEE",
        },
        wildsand: {
          50: "#f6f6f6",
          100: "#efefef",
          200: "#dcdcdc",
          300: "#bdbdbd",
          400: "#989898",
          500: "#7c7c7c",
          600: "#656565",
          700: "#525252",
          800: "#464646",
          900: "#3d3d3d",
          950: "#292929",
        },
        codgray: {
          600: "#686069",
          700: "#564e56",
          800: "#494349",
          900: "#3e3b3f",
          950: "#0d0c0d",
        },
        cobalt: {
          50: "#eff7ff",
          100: "#daecff",
          200: "#bddfff",
          300: "#90ccff",
          400: "#5caffe",
          500: "#368dfb",
          600: "#206ef0",
          700: "#1858dd",
          800: "#1a48b3",
          900: "#1d4496",
          950: "#152856",
        },
        success: "#006E2F",
        danger: "#72000F",
        warning: "#FFA70B",
        skeltonBg:{
          50: '#f0f0f0',
          100: '#e0e0e0'
        }
      },
    },
  },
  plugins: [],
};
