import WebSocket from "ws";

/**
 * smoke-ws.mjs
 * 
 * Verifies WebSocket /ws with token auth, live event streaming, and replay.
 * Part of Task 16: End-to-end Docker smoke and local documentation.
 */

const [apiKey, sessionId, runId] = process.argv.slice(2);
if (!apiKey || !sessionId || !runId) {
  console.error("Usage: node scripts/smoke-ws.mjs <api-key> <session-id> <run-id>");
  process.exit(2);
}

const BACKEND_URL = process.env.BACKEND_URL || "http://localhost:3000";
const WS_URL = BACKEND_URL.replace(/^http/, "ws") + "/ws";

async function connectAndHello(lastSequence, waitForCompleted = false) {
  return new Promise((resolve, reject) => {
    // Platform adaptation: some platforms might need token in query param or subprotocol
    const url = `${WS_URL}?token=${encodeURIComponent(apiKey)}`;
    const ws = new WebSocket(url);
    
    let ack;
    const timeout = setTimeout(() => {
      ws.close();
      reject(new Error(waitForCompleted ? `Timed out waiting for message.completed for run ${runId}` : "Timed out waiting for WebSocket hello_ack"));
    }, waitForCompleted ? 90000 : 5000);

    ws.on("open", () => {
      console.log(`[WS] Connected to ${WS_URL}`);
      ws.send(JSON.stringify({ type: "hello", sessionId, lastSequence }));
    });

    ws.on("message", (raw) => {
      const message = JSON.parse(raw.toString());
      
      if (message.type === "hello_ack") {
        console.log(`[WS] Received hello_ack. Latest sequence: ${message.latestSequence}`);
        ack = message;
        
        // If we are just checking replay and the event is already in replayedEvents
        if (waitForCompleted && Array.isArray(message.replayedEvents) && message.replayedEvents.some((event) => 
          event.type === "message.completed" && event.runId === runId)) {
          console.log("[WS] Found message.completed in replayedEvents");
          clearTimeout(timeout);
          ws.close();
          resolve(message);
        }
        
        if (!waitForCompleted) {
          clearTimeout(timeout);
          ws.close();
          resolve(message);
        }
      }

      if (waitForCompleted && message.type === "event" && message.event?.type === "message.completed" && message.event.runId === runId) {
        console.log("[WS] Received live message.completed event");
        clearTimeout(timeout);
        ws.close();
        resolve({ ...ack, latestSequence: message.event.sequence ?? ack?.latestSequence ?? 0, completedEvent: message.event });
      }

      if (message.type === "error") {
        console.error("[WS] Received error:", message);
        clearTimeout(timeout);
        ws.close();
        reject(new Error(`WebSocket error: ${message.message}`));
      }
    });

    ws.on("error", (err) => {
      console.error("[WS] Connection error:", err);
      clearTimeout(timeout);
      ws.close();
      reject(err);
    });
  });
}

try {
  console.log(`[Smoke] Testing WebSocket for session ${sessionId}, waiting for run ${runId}...`);
  
  // 1. Connect and wait for live completion
  const firstAck = await connectAndHello(0, true);
  const latestSequence = firstAck.latestSequence ?? 0;
  
  if (latestSequence < 1) {
    throw new Error("Expected at least one persisted event before replay smoke");
  }

  console.log(`[Smoke] Live event verified. Testing replay from sequence ${latestSequence - 1}...`);

  // 2. Reconnect and verify replay
  const replayAck = await connectAndHello(latestSequence - 1);
  if (!Array.isArray(replayAck.replayedEvents) || replayAck.replayedEvents.length < 1) {
    throw new Error("Expected replayedEvents to include the missed event");
  }

  console.log(`[Smoke] WebSocket reconnect/replay OK for ${sessionId} at sequence ${latestSequence}`);
  process.exit(0);
} catch (err) {
  console.error("[Smoke] WebSocket test failed:", err.message);
  process.exit(1);
}
