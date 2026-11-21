/// What a tentacle "does" in the animated versions of the logo.
///
/// At rest all tentacles look alike; the role only matters in the splash screen
/// and in the pulse loader:
/// - the [serverLink] tentacle stays anchored and represents the connection
///   to the Jellyfin server (data flows IN through it);
/// - the three letter tentacles go and grab the letters "d", "r" and "e"
///   (data flows OUT through them, towards the screen).
enum IdreTentacleRole {
  /// Connection to the Jellyfin server. Never grabs a letter.
  serverLink,

  /// Grabs the letter "d" (arrives from the top in the splash screen).
  letterD,

  /// Grabs the letter "r" (arrives from the bottom in the splash screen).
  letterR,

  /// Grabs the letter "e" (arrives from the right in the splash screen).
  letterE,
}
