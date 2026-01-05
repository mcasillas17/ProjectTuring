# Stage 1: Build the TypeScript code
FROM node:20-alpine AS builder
WORKDIR /app

# Copy dependency definitions
COPY package*.json ./
RUN npm install

# Copy source code and build
COPY . .
# Assumes you have a "build" script in package.json (tsc)
RUN npm run build

# Stage 2: Run the production app (Smaller image)
FROM node:20-alpine
WORKDIR /app

COPY package*.json ./
RUN npm install --production

# Copy built JS files from the builder stage
COPY --from=builder /app/dist ./dist

# Expose the WebSocket port
EXPOSE 3000

# Start the Fastify server
CMD ["node", "dist/server.js"]