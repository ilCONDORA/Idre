/// Where a tentacle sits on the head of the Idre "i", when the logo is at rest.
///
/// The four tentacles form a symmetric fan (2 on the left, 2 on the right),
/// so that each pair reads like the arcs of a Wi-Fi symbol.
///
/// ```text
///   innerLeft   innerRight
/// outerLeft  (●)  outerRight     ← the dot of the "i" is the head
///             ┃
///             ┃                  ← the stem of the "i" is the body
/// ```
enum IdreTentaclePosition {
  /// The left-most tentacle, closest to horizontal.
  outerLeft,

  /// The left tentacle closest to vertical.
  innerLeft,

  /// The right tentacle closest to vertical.
  innerRight,

  /// The right-most tentacle, closest to horizontal.
  outerRight,
}
