/// Shared mutable set of temporarily banned author mids for the dynamics page.
///
/// Used by [AuthorPanel] (write) and [DynamicsTabController] (read) without
/// coupling either side to GetX.  A plain top-level set is sufficient here
/// because the list is write-once-per-session (no UI rebuild needed on change;
/// the consumer filters at fetch time).
final Set<int> tempBannedSet = <int>{};
