FROM node:20-alpine AS deps
WORKDIR /repo
COPY package*.json ./
COPY shared-types/package.json shared-types/package.json
COPY orchestrator/package.json orchestrator/package.json
RUN npm install

FROM deps AS builder
COPY tsconfig.base.json ./
COPY shared-types shared-types
COPY orchestrator orchestrator
RUN npm run build -w @turing/shared-types && npm run build -w @turing/orchestrator

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=deps /repo/node_modules /app/node_modules
COPY --from=builder /repo/shared-types/package.json /app/shared-types/package.json
COPY --from=builder /repo/shared-types/dist /app/shared-types/dist
COPY --from=builder /repo/orchestrator/dist /app/dist
COPY --from=builder /repo/orchestrator/migrations /app/migrations
COPY orchestrator/package.json /app/package.json
EXPOSE 3000 3001
CMD ["node", "dist/server.js"]
