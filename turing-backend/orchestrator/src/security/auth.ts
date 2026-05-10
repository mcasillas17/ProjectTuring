import { Buffer } from "node:buffer";
import { timingSafeEqual } from "node:crypto";
import type { FastifyReply, FastifyRequest } from "fastify";

export function bearerTokenFromHeader(header: string | undefined): string | undefined {
  if (!header) return undefined;
  const [scheme, token] = header.split(" ");
  return scheme === "Bearer" && token ? token : undefined;
}

export function tokenMatches(actual: string | undefined, expected: string): boolean {
  if (!actual || !expected) return false;
  const actualBytes = Buffer.from(actual);
  const expectedBytes = Buffer.from(expected);
  return actualBytes.length === expectedBytes.length && timingSafeEqual(actualBytes, expectedBytes);
}

export function requireBearer(expectedToken: string) {
  return async (request: FastifyRequest, reply: FastifyReply): Promise<void> => {
    const token = bearerTokenFromHeader(request.headers.authorization);
    if (!tokenMatches(token, expectedToken)) {
      await reply.code(401).send({
        error: {
          code: "unauthorized",
          message: "Invalid or missing bearer token",
          requestId: request.id
        }
      });
    }
  };
}
