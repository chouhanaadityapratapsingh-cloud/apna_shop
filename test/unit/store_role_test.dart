import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:flutter_test/flutter_test.dart';

StoreMember _member(
  StoreRole role, {
  MemberStatus status = MemberStatus.active,
  Set<StoreAction> permissions = const <StoreAction>{},
}) {
  return StoreMember(
    uid: 'u1',
    storeId: 's1',
    role: role,
    status: status,
    permissions: permissions,
  );
}

void main() {
  group('owner', () {
    test('can do everything', () {
      final owner = _member(StoreRole.owner);
      for (final action in StoreAction.values) {
        expect(owner.can(action), isTrue, reason: action.name);
      }
    });
  });

  group('manager', () {
    test('cannot create or close the store', () {
      expect(_member(StoreRole.manager).can(StoreAction.manageStore), isFalse);
    });

    test('can run daily work without delegation', () {
      final manager = _member(StoreRole.manager);
      for (final action in [
        StoreAction.viewDashboard,
        StoreAction.editProducts,
        StoreAction.recordStock,
        StoreAction.adjustStock,
        StoreAction.viewFullAudit,
      ]) {
        expect(manager.can(action), isTrue, reason: action.name);
      }
    });

    test('needs delegation to manage members or change settings', () {
      expect(
        _member(StoreRole.manager).can(StoreAction.manageMembers),
        isFalse,
      );
      expect(
        _member(StoreRole.manager).can(StoreAction.changeSettings),
        isFalse,
      );
      final delegated = _member(
        StoreRole.manager,
        permissions: {StoreAction.manageMembers, StoreAction.changeSettings},
      );
      expect(delegated.can(StoreAction.manageMembers), isTrue);
      expect(delegated.can(StoreAction.changeSettings), isTrue);
    });
  });

  group('staff', () {
    test('can always record stock', () {
      expect(_member(StoreRole.staff).can(StoreAction.recordStock), isTrue);
    });

    test('is denied owner-only actions even if a permission is listed', () {
      final staff = _member(
        StoreRole.staff,
        permissions: {
          StoreAction.manageStore,
          StoreAction.manageMembers,
          StoreAction.viewFullAudit,
          StoreAction.changeSettings,
        },
      );
      expect(staff.can(StoreAction.manageStore), isFalse);
      expect(staff.can(StoreAction.manageMembers), isFalse);
      expect(staff.can(StoreAction.viewFullAudit), isFalse);
      expect(staff.can(StoreAction.changeSettings), isFalse);
    });

    test('needs delegation for dashboard, product edits and adjustments', () {
      expect(_member(StoreRole.staff).can(StoreAction.editProducts), isFalse);
      expect(_member(StoreRole.staff).can(StoreAction.adjustStock), isFalse);
      expect(_member(StoreRole.staff).can(StoreAction.viewDashboard), isFalse);
      final delegated = _member(
        StoreRole.staff,
        permissions: {StoreAction.editProducts},
      );
      expect(delegated.can(StoreAction.editProducts), isTrue);
      expect(delegated.can(StoreAction.adjustStock), isFalse);
    });
  });

  test('an inactive member can do nothing', () {
    final inactiveOwner = _member(
      StoreRole.owner,
      status: MemberStatus.inactive,
    );
    for (final action in StoreAction.values) {
      expect(inactiveOwner.can(action), isFalse, reason: action.name);
    }
  });

  group('parsing', () {
    test('StoreRole.tryParse returns null for unknown values', () {
      expect(StoreRole.tryParse('owner'), StoreRole.owner);
      expect(StoreRole.tryParse('manager'), StoreRole.manager);
      expect(StoreRole.tryParse('staff'), StoreRole.staff);
      expect(StoreRole.tryParse('admin'), isNull);
      expect(StoreRole.tryParse(null), isNull);
    });

    test('MemberStatus treats anything but active as inactive', () {
      expect(MemberStatus.parse('active'), MemberStatus.active);
      expect(MemberStatus.parse('removed'), MemberStatus.inactive);
      expect(MemberStatus.parse(null), MemberStatus.inactive);
    });
  });
}
