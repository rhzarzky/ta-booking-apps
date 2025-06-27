# Stage 1: Build stage
FROM node:lts-alpine AS build

# Workdir
WORKDIR /app

# Copy package.json dan package-lock.json
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --no-audit --prefer-offline

# Copy
COPY . .

# Build
RUN npm run build

# Stage 2: Production stage
FROM nginx:alpine

# Salin hasil build 
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80 
EXPOSE 80

# Run
CMD ["nginx", "-g", "daemon off;"]