import pino, { type DestinationStream } from "pino";

type SerializedRequest = ReturnType<typeof pino.stdSerializers.req> & { query?: unknown };

export function redactTokenQueryParam(url: string): string {
  return url.replace(/([?&]token=)[^&#]*/gi, "$1[redacted]");
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function requestSerializer(request: unknown): SerializedRequest {
  const serialized = pino.stdSerializers.req(request as Parameters<typeof pino.stdSerializers.req>[0]) as SerializedRequest;
  const redacted = typeof serialized.url === "string" ? { ...serialized, url: redactTokenQueryParam(serialized.url) } : { ...serialized };
  if (isRecord(redacted.query) && "token" in redacted.query) {
    redacted.query = { ...redacted.query, token: "[redacted]" };
  }
  return redacted;
}

export function createLogger(level: string, destination?: DestinationStream) {
  const options = { level, serializers: { req: requestSerializer } };
  return destination ? pino(options, destination) : pino(options);
}
