FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
COPY shared-types/package.json shared-types/package.json
COPY agent-runtime/package.json agent-runtime/package.json
RUN npm ci

FROM deps AS build
COPY tsconfig.base.json ./
COPY shared-types shared-types
COPY agent-runtime agent-runtime
RUN npm run build -w @turing/shared-types && npm run build -w @turing/agent-runtime

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/shared-types/dist ./shared-types/dist
COPY --from=build /app/shared-types/package.json ./shared-types/package.json
COPY --from=build /app/agent-runtime/dist ./agent-runtime/dist
COPY --from=build /app/agent-runtime/package.json ./agent-runtime/package.json
CMD ["node", "agent-runtime/dist/main.js"]
