import { randomUUID } from "node:crypto";
import Fastify from "fastify";
import websocket from "@fastify/websocket";
import { loadConfig, type OrchestratorConfig } from "./config.js";
import { createLogger } from "./logging/logger.js";
import { requireBearer } from "./security/auth.js";
import { openDatabase, type TuringDatabase } from "./db/connection.js";
import { applyMigrations } from "./db/migrations.js";
import { registerPublicRoutes } from "./api/routes.js";
import { registerInternalRoutes } from "./internal/routes.js";
import { createWsHub, registerWebSocket } from "./ws/gateway.js";

type ServerDeps = { config?: OrchestratorConfig; db?: TuringDatabase; hub?: ReturnType<typeof createWsHub> };

function isAuthExemptPath(requestUrl: string, routeUrl?: string): boolean {
  const path = requestUrl.split("?", 1)[0];
  return routeUrl === "/health" || routeUrl === "/version" || routeUrl === "/ws" || path === "/health" || path === "/version" || path === "/ws";
}

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
    if (isAuthExemptPath(request.url, request.routeOptions.url)) return;
    await requireBearer(config.clientApiKey)(request, reply);
  });

  if (deps.hub) await registerWebSocket(app, { db, clientApiKey: config.clientApiKey, hub: deps.hub });
  await registerPublicRoutes(app, { db, config, hub: deps.hub });
  return app;
}

export async function buildInternalServer(deps: ServerDeps = {}) {
  const config = deps.config ?? loadConfig();
  const db = deps.db ?? openDatabase(config.databasePath);
  if (!deps.db) applyMigrations(db);

  const app = Fastify({ loggerInstance: createLogger(config.logLevel), genReqId: () => randomUUID() });
  app.decorate("db", db);
  if (!deps.db) app.addHook("onClose", async () => db.close());

  app.addHook("preHandler", requireBearer(config.internalToken));
  app.get("/internal/health", async () => ({ ok: true }));
  await registerInternalRoutes(app, { db, config, hub: deps.hub });
  return app;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const config = loadConfig();
  const db = openDatabase(config.databasePath);
  applyMigrations(db);

  const hub = createWsHub();
  const publicServer = await buildPublicServer({ config, db, hub });
  const internalServer = await buildInternalServer({ config, db, hub });

  await internalServer.listen({ host: "0.0.0.0", port: config.internalPort });
  await publicServer.listen({ host: "0.0.0.0", port: config.publicPort });

  process.once("SIGTERM", async () => {
    await Promise.all([publicServer.close(), internalServer.close()]);
    db.close();
  });
}
