import Fastify from "fastify";
import websocket from "@fastify/websocket";
import { loadConfig } from "./config.js";
import { createLogger } from "./logging/logger.js";
import { requireBearer } from "./security/auth.js";

const config = loadConfig();
const logger = createLogger(config.logLevel);

export async function buildPublicServer() {
  const app = Fastify({ logger, genReqId: () => crypto.randomUUID() });
  await app.register(websocket);

  app.get("/health", async () => ({ ok: true }));
  app.get("/version", async () => ({ version: "1.0.0", schemaVersion: "0001" }));

  app.addHook("preHandler", async (request, reply) => {
    if (request.routeOptions.url === "/health" || request.routeOptions.url === "/version" || request.routeOptions.url === "/ws") return;
    await requireBearer(config.clientApiKey)(request, reply);
  });

  return app;
}

export async function buildInternalServer() {
  const app = Fastify({ logger, genReqId: () => crypto.randomUUID() });
  app.addHook("preHandler", requireBearer(config.internalToken));
  app.get("/internal/health", async () => ({ ok: true }));
  return app;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const publicServer = await buildPublicServer();
  const internalServer = await buildInternalServer();

  await internalServer.listen({ host: "0.0.0.0", port: config.internalPort });
  await publicServer.listen({ host: "0.0.0.0", port: config.publicPort });
}
