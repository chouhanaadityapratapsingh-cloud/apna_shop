/// Roles a member can have inside one store (blueprint section 3.1).
enum StoreRole {
  owner,
  manager,
  staff;

  /// Parses the value stored in Firestore. Returns null for unknown values.
  static StoreRole? tryParse(String? value) {
    for (final role in StoreRole.values) {
      if (role.name == value) return role;
    }
    return null;
  }
}

enum MemberStatus {
  active,
  inactive;

  /// Anything other than 'active' is treated as inactive (no access).
  static MemberStatus parse(String? value) {
    return value == 'active' ? MemberStatus.active : MemberStatus.inactive;
  }
}

/// Things a member may be allowed to do. The names are also the values stored
/// in a member's `permissions` list when an action is delegated.
enum StoreAction {
  manageStore,
  manageMembers,
  viewDashboard,
  editProducts,
  recordStock,
  adjustStock,
  viewFullAudit,
  changeSettings,
}

/// How a role relates to an action.
/// [delegated] means the owner must grant it explicitly to that member.
enum Access { allowed, denied, delegated }

/// Role table from blueprint section 3.1.
///
/// Interpretation of the blueprint's wording:
/// - "Optional if delegated", "Limited", "Basic / configurable", "Yes if
///   permitted" and "Permission required" are all [Access.delegated].
/// - Staff only see their own/relevant activity, so full audit is denied.
///
/// This is for UI decisions. Real enforcement is in Firestore rules and, from
/// M4, in the backend functions.
Access accessFor(StoreRole role, StoreAction action) {
  switch (role) {
    case StoreRole.owner:
      return Access.allowed;
    case StoreRole.manager:
      return switch (action) {
        StoreAction.manageStore => Access.denied,
        StoreAction.manageMembers ||
        StoreAction.changeSettings => Access.delegated,
        _ => Access.allowed,
      };
    case StoreRole.staff:
      return switch (action) {
        StoreAction.recordStock => Access.allowed,
        StoreAction.manageStore ||
        StoreAction.manageMembers ||
        StoreAction.viewFullAudit ||
        StoreAction.changeSettings => Access.denied,
        StoreAction.viewDashboard ||
        StoreAction.editProducts ||
        StoreAction.adjustStock => Access.delegated,
      };
  }
}
