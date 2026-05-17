# Proto generation

`proto/turing/v1` is the source of truth for Turing gRPC contracts.

Normal backend builds use checked-in generated code and do not require code generation.

To regenerate Go stubs:

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
tools/proto/generate.sh
```

Optional client generators are used when installed:

- `protoc-gen-dart` for Flutter
- `protoc-gen-swift` and `protoc-gen-grpc-swift` for macOS
- `grpc_csharp_plugin` for Windows
- `protoc-gen-grpc-java` for Android-compatible stubs

When optional generators are not installed, `gen/turing/v1/dart`, `gen/turing/v1/swift`, `gen/turing/v1/csharp`, and `gen/turing/v1/kotlin` may contain only `.gitkeep` placeholders. These directories are reserved for future checked-in client stubs.
