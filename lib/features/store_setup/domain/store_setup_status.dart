/// Where a signed-in user stands with store setup. The router uses this to
/// decide between the splash, create-store, error and main screens.
enum StoreSetupStatus {
  /// Still finding out whether the user already has a store.
  loading,

  /// Signed in, but no store yet.
  missing,

  /// Has a store.
  ready,

  /// Could not find out (for example a permission or server problem).
  error,
}
