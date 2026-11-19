/// Looks a printed bill can have. All are plain bills (no GST).
enum BillTemplate {
  /// Boxed header, bordered table. Looks like a traditional cash memo.
  classic,

  /// Coloured header band and striped rows.
  modern,

  /// Narrow roll-receipt layout (80 mm wide) for a thermal printer later.
  thermal,

  /// Lots of white space, thin lines.
  minimal,
}
