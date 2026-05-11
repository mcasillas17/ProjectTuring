# Project Turing Flutter Client

This is the v1.0 Flutter client for Project Turing. It is a thin, protocol-driven UI for the local orchestrator: the backend owns sessions, messages, model routing, approvals, tool execution, persistence, and audit state.

The client preserves the existing polished `ResponsiveShell` experience. Backend-connected chat, sessions, and settings are integrated into that shell instead of replacing it with a plain debug root.

## Current Status

Implemented in the client:

- Existing Project Turing app shell with desktop navigation rail and mobile drawer.
- Backend URL and API key settings stored through secure client storage.
- REST client for config, sessions, messages, event replay, and approval actions.
- WebSocket client for streamed session events.
- Chat tab wired to backend sessions and streamed message deltas.
- Approval cards for `approval.requested` events, cleared by approval terminal events.
- Model provider selector for `ollama` or `openai_compatible` per sent message.

Provisional until the backend orchestrator is running:

- End-to-end chat responses require the orchestrator, agent runtime, model provider, and WebSocket event stream.
- Session creation and message sending require the backend REST API.
- Approval cards require the backend/runtime to emit approval events.
- Devices, Stats, and Integrations remain placeholders.

## Run Locally

From the repository root:

```bash
cd turing-client/turing_app
flutter pub get
flutter run -d macos
```

Use `flutter devices` to choose another target, such as Chrome or a connected Android device. For physical devices, the backend URL usually needs the host machine's LAN or Tailscale address rather than `localhost`.

Run client verification:

```bash
cd turing-client/turing_app
flutter analyze
flutter test
```

## Backend Settings Flow

On first launch, or when saved credentials are missing, the app opens `SettingsScreen`.

Enter:

- **Backend URL**: typically `http://localhost:3000` on the development machine.
- **API key**: the client API key printed by the backend initialization flow.

After saving, `TuringApp` reloads stored settings and opens the existing `ResponsiveShell`. The Settings tab remains available inside the shell so backend URL or API key can be updated later.

The current client sends authenticated REST requests using:

```text
Authorization: Bearer <api-key>
```

The WebSocket client passes the API key as a connection query token because some Flutter targets do not consistently support custom WebSocket headers.

## Shell Integration

`ResponsiveShell` remains the primary app surface:

- **Chat** renders `SessionListScreen`, which lists sessions once the backend is available and opens backend-connected `ChatScreen` instances.
- **Devices** is a placeholder: `IoT Devices Dashboard`.
- **Stats** is a placeholder: `Stats & Usage`.
- **Integrations** is a placeholder: `Integrations Status`.
- **Settings** renders the real backend URL/API key settings screen.

This keeps theme logic, app colors, desktop rail behavior, mobile drawer behavior, and placeholder tabs intact while adding backend-connected client surfaces.

## Chat And Sessions

The Chat tab uses REST for commands and queries:

- `GET /api/sessions` to load session summaries.
- `POST /api/sessions` to create a new chat.
- `GET /api/sessions/:sessionId/messages` to load existing messages.
- `POST /api/sessions/:sessionId/messages` to enqueue a user message and selected model provider.
- `POST /api/approvals/:approvalId/approve` and `/deny` for approval cards.

When a session opens, `ChatScreen` loads persisted messages over REST and subscribes to WebSocket events for that session. Incoming `message.delta` events update the active assistant message locally rather than making the client own model execution.

## WebSocket Streaming

`TuringWsClient` connects to:

```text
ws://<backend-host>:3000/ws?token=<api-key>
```

On connect, it sends:

```json
{"type":"hello","sessionId":"sess_...","lastSequence":42}
```

The client handles:

- `hello_ack`: replays persisted events included by the backend.
- `event`: parses the event envelope and applies it to the chat UI.
- `resync_required`: raises a client exception indicating session state should be refetched over REST.
- `error`: raises a client exception with the backend-provided message.

Approval cards appear from `approval.requested` and are removed on `approval.approved`, `approval.denied`, `approval.expired`, or `approval.consumed`.

## Important Files

- `lib/app.dart`: loads saved client config and chooses Settings or `ResponsiveShell`.
- `lib/ui/shell/responsive_shell.dart`: polished Project Turing shell and tab integration.
- `lib/features/settings/settings_screen.dart`: backend URL/API key form.
- `lib/features/sessions/session_list_screen.dart`: backend session list and new-chat flow.
- `lib/features/chat/chat_screen.dart`: active backend-connected chat screen for message loading, sending, streaming deltas, and approvals.
- `lib/features/approvals/approval_card.dart`: approve/deny UI.
- `lib/features/chat/model_provider_selector.dart`: provider selection control.
- `lib/models/`: typed client models for sessions, messages, approvals, config, and streamed Turing events.
- `lib/networking/api_client.dart`: REST protocol client and typed API interface.
- `lib/networking/ws_client.dart`: WebSocket event stream client.
- `lib/networking/auth_storage.dart`: secure storage abstraction.
- `test/ui/responsive_shell_backend_test.dart`: shell regression test proving the polished shell still wraps backend chat.

The legacy prototype screen under `lib/ui/chat/chat_screen.dart` is not the backend-connected chat surface used by the v1 shell integration.

## Developer Notes

- Keep the Flutter client thin. Do not move orchestration, memory, routing, tool policy, approval decisions, or persistence into Flutter.
- Preserve `ResponsiveShell` as the main authenticated app surface. Add new client views as tabs or shell-integrated screens rather than replacing the root.
- Prefer the `TuringApi` and `TuringEventSource` interfaces in widgets so tests can use fakes without network access.
- Treat WebSocket `resync_required` as a signal to refetch state over REST. Do not try to reconstruct missing state from partial event history.
- Keep Devices, Stats, and Integrations visibly present but placeholder-only until their backend contracts are defined.
- Avoid claiming full end-to-end chat readiness in UI or docs until the orchestrator/runtime pipeline is available and verified.
