# ----------------------------------------
# Stage 1: Build the NestJS application
# ----------------------------------------
FROM node:18-alpine AS builder

# Create app directory
WORKDIR /app

# Install deps based on the lockfile
COPY package*.json ./
RUN npm ci

# Copy source and build the app
COPY . .
RUN npm run build

# ----------------------------------------
# Stage 2: Run in a minimal Node image
# ----------------------------------------
FROM node:18-alpine AS runner

WORKDIR /app

# Copy only package.json to install prod deps
COPY package*.json ./
RUN npm ci --only=production

# Copy built app and production modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

# Expose Nest’s default port
EXPOSE 3000

# Launch the compiled app
CMD ["node", "dist/main"]
