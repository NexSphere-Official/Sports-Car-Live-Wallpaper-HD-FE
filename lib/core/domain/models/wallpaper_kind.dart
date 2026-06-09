/// The intrinsic type of a wallpaper as returned by the API (`type` field).
///
/// `still` corresponds to the API value `"static"` (a `.webp` image),
/// `live` corresponds to `"live"` (an `.mp4` video). `static` is a reserved
/// word in Dart, so `still` is used in code.
enum WallpaperKind { live, still }
