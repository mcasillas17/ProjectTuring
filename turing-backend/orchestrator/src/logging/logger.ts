import pino, { type DestinationStream } from "pino";

type SerializedRequest = ReturnType<typeof pino.stdSerializers.req> & { query?: unknown };

export function redactTokenQueryParam(url: string): string {
  const hashIndex = url.indexOf("#");
  const withoutHash = hashIndex === -1 ? url : url.slice(0, hashIndex);
  const hash = hashIndex === -1 ? "" : url.slice(hashIndex);
  const queryIndex = withoutHash.indexOf("?");
  if (queryIndex === -1) return url;

  const path = withoutHash.slice(0, queryIndex);
  const params = new URLSearchParams(withoutHash.slice(queryIndex + 1));
  let redacted = false;
  for (const key of Array.from(params.keys())) {
    if (key.toLowerCase() === "token") {
      params.set(key, "[redacted]");
      redacted = true;
    }
  }
  return redacted ? `${path}?${params.toString()}${hash}` : url;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function requestSerializer(request: unknown): SerializedRequest {
  const serialized = pino.stdSerializers.req(request as Parameters<typeof pino.stdSerializers.req>[0]) as SerializedRequest;
  const redacted = typeof serialized.url === "string" ? { ...serialized, url: redactTokenQueryParam(serialized.url) } : { ...serialized };
  if (isRecord(redacted.query)) {
    redacted.query = Object.fromEntries(
      Object.entries(redacted.query).map(([key, value]) => [key, key.toLowerCase() === "token" ? "[redacted]" : value])
    );
  }
  if (isRecord(redacted.headers)) {
    redacted.headers = Object.fromEntries(
      Object.entries(redacted.headers).map(([key, value]) => [key, key.toLowerCase() === "authorization" ? "[redacted]" : value])
    );
  }
  return redacted;
}

export function createLogger(level: string, destination?: DestinationStream) {
  const options = { level, serializers: { req: requestSerializer } };
  return destination ? pino(options, destination) : pino(options);
}
