import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turing_flutter_app/features/approvals/approval_card.dart';

void main() {
  testWidgets('approval card exposes approve and deny actions', (tester) async {
    var approved = false;
    var denied = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ApprovalCard(
          toolName: 'files.update',
          argsSummary: 'Update note.txt',
          onApprove: () => approved = true,
          onDeny: () => denied = true,
        ),
      ),
    );

    await tester.tap(find.text('Approve'));
    expect(approved, true);

    await tester.tap(find.text('Deny'));
    expect(denied, true);
  });
}
