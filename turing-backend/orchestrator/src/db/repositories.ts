export type JsonObject = Record<string, unknown>;

export function parseJson<T>(value: string): T {
  return JSON.parse(value) as T;
}
