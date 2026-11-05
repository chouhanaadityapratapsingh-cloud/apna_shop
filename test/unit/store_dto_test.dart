import 'package:apna_shop/features/store_setup/data/store_dto.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('storeFromMap', () {
    test('maps every field', () {
      final created = DateTime.utc(2026, 11, 4, 10);
      final store = storeFromMap('s1', {
        'name': 'Demo Kirana Store',
        'ownerUid': 'u1',
        'currencyCode': 'INR',
        'timezone': 'Asia/Kolkata',
        'city': 'Khargone',
        'phone': '9876543210',
        'isActive': true,
        'createdAt': Timestamp.fromDate(created),
      });
      expect(store.id, 's1');
      expect(store.name, 'Demo Kirana Store');
      expect(store.ownerUid, 'u1');
      expect(store.city, 'Khargone');
      expect(store.phone, '9876543210');
      expect(store.isActive, isTrue);
      expect(store.createdAt?.isAtSameMomentAs(created), isTrue);
    });

    test('tolerates optional and pending fields', () {
      // createdAt is null in the local snapshot until the server answers.
      final store = storeFromMap('s1', {
        'name': 'Shop',
        'ownerUid': 'u1',
        'createdAt': null,
      });
      expect(store.city, isNull);
      expect(store.phone, isNull);
      expect(store.createdAt, isNull);
      expect(store.currencyCode, 'INR');
    });
  });

  group('memberFromMap', () {
    test('maps role, status and delegated permissions', () {
      final member = memberFromMap(
        storeId: 's1',
        uid: 'u2',
        data: {
          'role': 'manager',
          'status': 'active',
          'permissions': ['manageMembers', 'not-a-real-permission'],
        },
      );
      expect(member.uid, 'u2');
      expect(member.storeId, 's1');
      expect(member.role, StoreRole.manager);
      expect(member.status, MemberStatus.active);
      expect(member.permissions, {StoreAction.manageMembers});
    });

    test('unknown role falls back to staff and unknown status to inactive', () {
      final member = memberFromMap(
        storeId: 's1',
        uid: 'u2',
        data: {'role': 'superadmin', 'status': 'weird'},
      );
      expect(member.role, StoreRole.staff);
      expect(member.status, MemberStatus.inactive);
      expect(member.permissions, isEmpty);
    });
  });
}
