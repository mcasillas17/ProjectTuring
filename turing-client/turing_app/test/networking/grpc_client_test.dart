import 'package:flutter_test/flutter_test.dart';
import 'package:turing_flutter_app/networking/grpc_client.dart';

void main() {
  test('adds bearer token metadata', () {
    final metadata = GrpcAuthMetadata(apiKey: 'client-key').headers();

    expect(metadata['authorization'], 'Bearer client-key');
  });
}
