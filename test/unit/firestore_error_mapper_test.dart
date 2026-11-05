import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/store_setup/data/firestore_error_mapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

AppErrorType _map(String code) => mapFirestoreException(
  FirebaseException(plugin: 'cloud_firestore', code: code),
).type;

void main() {
  test('maps connection problems to network', () {
    expect(_map('unavailable'), AppErrorType.network);
    expect(_map('deadline-exceeded'), AppErrorType.network);
  });

  test('maps access problems to permissionDenied', () {
    expect(_map('permission-denied'), AppErrorType.permissionDenied);
    expect(_map('unauthenticated'), AppErrorType.permissionDenied);
  });

  test('maps everything else to unknown and keeps the code', () {
    final mapped = mapFirestoreException(
      FirebaseException(plugin: 'cloud_firestore', code: 'aborted'),
    );
    expect(mapped.type, AppErrorType.unknown);
    expect(mapped.debugCode, 'aborted');
  });

  test('does not copy the original message (it can contain paths)', () {
    final mapped = mapFirestoreException(
      FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Missing permission for stores/secret-store-id',
      ),
    );
    expect(mapped.toString(), isNot(contains('secret-store-id')));
  });
}
