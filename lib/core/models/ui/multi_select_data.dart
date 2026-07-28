/// Core mixin for multi-select support.
///
/// Provides a [checked] flag that UI multi-select controllers (e.g.
/// [MultiSelectController]) use to track selection state.
mixin MultiSelectData {
  bool checked = false;
}
