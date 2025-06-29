# Stage 1: Build stage
FROM node:lts-alpine AS build

ARG VITE_BASE_URL
ARG VITE_API_PATH
ARG FRONTEND_URL
ARG VITE_MAPBOX_ACCESS_TOKEN
ARG VITE_JWT_SECRET

ENV VITE_BASE_URL=$VITE_BASE_URL
ENV VITE_API_PATH=$VITE_API_PATH
ENV FRONTEND_URL=$FRONTEND_URL
ENV VITE_MAPBOX_ACCESS_TOKEN=$VITE_MAPBOX_ACCESS_TOKEN
ENV VITE_JWT_SECRET=$VITE_JWT_SECRET

# Workdir
WORKDIR /app

# Copy package.json dan package-lock.json
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --no-audit --prefer-offline

# Copy
COPY . .

# Build
RUN VITE_BASE_URL=$VITE_BASE_URL \
    VITE_API_PATH=$VITE_API_PATH \
    FRONTEND_URL=$FRONTEND_URL \
    VITE_MAPBOX_ACCESS_TOKEN=$VITE_MAPBOX_ACCESS_TOKEN \
    VITE_JWT_SECRET=$VITE_JWT_SECRET \
    npm run build
    
# Stage 2: Production stage
FROM nginx:alpine

# Copy custom nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Salin hasil build 
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80 
EXPOSE 80

# Run
CMD ["nginx", "-g", "daemon off;"]