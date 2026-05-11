import { randomUUID } from "node:crypto";
import Fastify from "fastify";
import websocket from "@fastify/websocket";
import { loadConfig, type OrchestratorConfig } from "./config.js";
import { createLogger } from "./logging/logger.js";
import { requireBearer } from "./security/auth.js";
import { openDatabase, type TuringDatabase } from "./db/connection.js";
import { applyMigrations } from "./db/migrations.js";
import { registerPublicRoutes } from "./api/routes.js";

type BroadcastHub = { broadcast(event: unknown): void };
type ServerDeps = { config?: OrchestratorConfig; db?: TuringDatabase; hub?: BroadcastHub };

export async function buildPublicServer(deps: ServerDeps = {}) {
  const config = deps.config ?? loadConfig();
  const db = deps.db ?? openDatabase(config.databasePath);
  if (!deps.db) applyMigrations(db);

  const app = Fastify({ loggerInstance: createLogger(config.logLevel), genReqId: () => randomUUID() });
  await app.register(websocket);
  app.decorate("db", db);
  if (!deps.db) app.addHook("onClose", async () => db.close());

  app.get("/health", async () => ({ ok: true }));
  app.get("/version", async () => ({ version: "1.0.0", schemaVersion: "0001" }));

  app.addHook("preHandler", async (request, reply) => {
    if (request.routeOptions.url === "/health" || request.routeOptions.url === "/version" || request.routeOptions.url === "/ws") return;
    await requireBearer(config.clientApiKey)(request, reply);
  });

  await registerPublicRoutes(app, { db, config, hub: deps.hub });
  return app;
}

export async function buildInternalServer(deps: ServerDeps = {}) {
  const config = deps.config ?? loadConfig();
  const app = Fastify({ loggerInstance: createLogger(config.logLevel), genReqId: () => randomUUID() });
  app.addHook("preHandler", requireBearer(config.internalToken));
  app.get("/internal/health", async () => ({ ok: true }));
  return app;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const config = loadConfig();
  const db = openDatabase(config.databasePath);
  applyMigrations(db);

  const publicServer = await buildPublicServer({ config, db });
  const internalServer = await buildInternalServer({ config, db });

  await internalServer.listen({ host: "0.0.0.0", port: config.internalPort });
  await publicServer.listen({ host: "0.0.0.0", port: config.publicPort });
}
