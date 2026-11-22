"""Generates the images of the native splash screen (Android, iOS, web).

The native splash shows the "i" of the wordmark at rest in the center: exactly the frame where the Flutter splash
starts (IdreSplashTimeline.handOffFromNativeSplashProgress). When Flutter draws its first frame the native splash
disappears, and nobody can see the switch.

Run it from the project root, then generate the native files:

    python3 tool/generate_native_splash_images.py
    dart run flutter_native_splash:create

Needs Python 3 with pycairo (`pip install pycairo`).

Output (1152 x 1152 px, transparent, the background color is set in flutter_native_splash.yaml):
    assets/splash/splash_icon_dark.png   mint "i" for the dark system mode
    assets/splash/splash_icon_light.png  forest green "i" for the light system mode

Why 1152 px: flutter_native_splash treats the image as 4x pixel density, so 1152 px = 288 logical pixels. That is
also the size Android 12+ wants for a splash icon without background (only a central circle of 768 px is visible).
The same image therefore works on every platform and is shown at 288 logical pixels everywhere.

IMPORTANT: the shapes below copy IdreWordmarkGeometry and IdreLogoGeometry (lib/brand). If the "i" of the wordmark
changes there, change it here too. The size comes from IdreSplashScreenMetrics.designUnitInLogicalPixels and is read
directly from the Dart file, so it can never be out of sync.
"""

import math
import re
from pathlib import Path

import cairo

PROJECT_ROOT = Path(__file__).resolve().parent.parent
METRICS_DART_FILE = PROJECT_ROOT / "lib" / "startup" / "idre_splash_screen_metrics.dart"
OUTPUT_FOLDER = PROJECT_ROOT / "assets" / "splash"

# ---- Native splash format ------------------------------------------------------------------------------------------
IMAGE_SIZE_IN_PIXELS = 1152
PIXELS_PER_LOGICAL_PIXEL = 4  # flutter_native_splash: "the image should be sized for 4x pixel density"
ANDROID_12_VISIBLE_CIRCLE_DIAMETER_IN_PIXELS = 768

# ---- Copied from lib/brand (design units) --------------------------------------------------------------------------
# IdreWordmarkGeometry.animatedDesignArea = Rect.fromLTRB(0, -24, 260, 150): its center is the screen center.
ANIMATED_DESIGN_AREA_CENTER = (130.0, 63.0)
# At the hand-off the "i" stands at the center of the animated area: IdreWordmarkPainter.iStartOffsetX moves its
# head from IdreWordmarkGeometry.headCenter (40, 62) to x = 130.
HEAD_CENTER = (130.0, 62.0)
HEAD_RADIUS = 9.0
STEM_TOP_Y = 86.0  # xHeightLineY
STEM_BOTTOM_Y = 130.0  # baselineY
LETTER_STROKE_WIDTH = 12.0  # also the stem of the "i"
TENTACLE_STROKE_WIDTH = 5.0
RESTING_TENTACLE_START_DISTANCE = 12.0
RESTING_TENTACLE_CONTROL_POINT_DISTANCE = 19.0
RESTING_TENTACLE_TIP_DISTANCE = 27.0
TENTACLE_TIP_FLARE_FACTOR = 1.15  # IdreLogoGeometry.tentacleTipFlareFactor
TENTACLE_BASE_ANGLES_IN_DEGREES = (-50.0, -17.0, 17.0, 50.0)  # IdreLogoGeometry.standardTentacles

# ---- Copied from IdreBrandColors -----------------------------------------------------------------------------------
LOGO_COLOR_ON_DARK_BACKGROUND = "#99E6B9"
LOGO_COLOR_ON_LIGHT_BACKGROUND = "#196739"


def read_design_unit_in_logical_pixels() -> float:
    """Reads IdreSplashScreenMetrics.designUnitInLogicalPixels from the Dart file (single source of truth)."""
    dart_source = METRICS_DART_FILE.read_text(encoding="utf-8")
    match = re.search(r"designUnitInLogicalPixels\s*=\s*([0-9.]+)\s*;", dart_source)
    if match is None:
        raise RuntimeError(f"designUnitInLogicalPixels not found in {METRICS_DART_FILE}")
    return float(match.group(1))


def point_around_head(angle_from_vertical_in_radians: float, distance_from_head_center: float) -> tuple:
    """Same as IdreWordmarkGeometry._pointAroundHead: 0 rad = up, positive = right (y grows downwards)."""
    return (
        HEAD_CENTER[0] + distance_from_head_center * math.sin(angle_from_vertical_in_radians),
        HEAD_CENTER[1] - distance_from_head_center * math.cos(angle_from_vertical_in_radians),
    )


def hex_to_rgb(hex_color: str) -> tuple:
    """'#99E6B9' -> (0.6, 0.9, 0.725), the 0-1 values cairo wants."""
    value = hex_color.lstrip("#")
    return tuple(int(value[index:index + 2], 16) / 255 for index in (0, 2, 4))


def draw_resting_i(context: cairo.Context, logo_color: str) -> None:
    """Draws the "i" with its 4 resting tentacles, in design units (the caller sets the transform)."""
    context.set_source_rgb(*hex_to_rgb(logo_color))
    context.set_line_cap(cairo.LINE_CAP_ROUND)
    context.set_line_join(cairo.LINE_JOIN_ROUND)

    # Tentacles: quadratic Bézier curves (start -> control -> tip), drawn as the equivalent cubic curve.
    context.set_line_width(TENTACLE_STROKE_WIDTH)
    for base_angle_in_degrees in TENTACLE_BASE_ANGLES_IN_DEGREES:
        base_angle = math.radians(base_angle_in_degrees)
        start = point_around_head(base_angle, RESTING_TENTACLE_START_DISTANCE)
        control = point_around_head(base_angle, RESTING_TENTACLE_CONTROL_POINT_DISTANCE)
        tip = point_around_head(base_angle * TENTACLE_TIP_FLARE_FACTOR, RESTING_TENTACLE_TIP_DISTANCE)
        first_control = (start[0] + 2 / 3 * (control[0] - start[0]), start[1] + 2 / 3 * (control[1] - start[1]))
        second_control = (tip[0] + 2 / 3 * (control[0] - tip[0]), tip[1] + 2 / 3 * (control[1] - tip[1]))
        context.move_to(*start)
        context.curve_to(*first_control, *second_control, *tip)
        context.stroke()

    # Stem: a vertical line with round ends.
    context.set_line_width(LETTER_STROKE_WIDTH)
    context.move_to(HEAD_CENTER[0], STEM_TOP_Y)
    context.line_to(HEAD_CENTER[0], STEM_BOTTOM_Y)
    context.stroke()

    # Head: a filled circle.
    context.arc(HEAD_CENTER[0], HEAD_CENTER[1], HEAD_RADIUS, 0, 2 * math.pi)
    context.fill()


def check_android_12_visible_circle(surface: cairo.ImageSurface) -> None:
    """Fails if any painted pixel is outside the circle Android 12+ shows (it would be cut away)."""
    width = surface.get_width()
    stride = surface.get_stride()
    pixel_bytes = surface.get_data()
    center = IMAGE_SIZE_IN_PIXELS / 2
    visible_radius = ANDROID_12_VISIBLE_CIRCLE_DIAMETER_IN_PIXELS / 2
    farthest_painted_distance = 0.0
    for y in range(IMAGE_SIZE_IN_PIXELS):
        row_start = y * stride
        for x in range(width):
            alpha = pixel_bytes[row_start + x * 4 + 3]  # ARGB32 is stored as B, G, R, A on little-endian machines
            if alpha:
                farthest_painted_distance = max(farthest_painted_distance, math.hypot(x + 0.5 - center, y + 0.5 - center))
    if farthest_painted_distance > visible_radius:
        raise RuntimeError(
            f"The 'i' reaches {farthest_painted_distance:.0f} px from the center, but Android 12+ shows only "
            f"{visible_radius:.0f} px: lower designUnitInLogicalPixels."
        )
    print(f"  Android 12 check OK: farthest pixel {farthest_painted_distance:.0f} px from the center (limit {visible_radius:.0f})")


def generate_image(file_name: str, logo_color: str, design_unit_in_logical_pixels: float) -> None:
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, IMAGE_SIZE_IN_PIXELS, IMAGE_SIZE_IN_PIXELS)
    context = cairo.Context(surface)
    context.set_antialias(cairo.ANTIALIAS_BEST)

    # Design units -> pixels: the center of the animated design area goes to the center of the image,
    # exactly like the Flutter splash, which is centered on the screen.
    pixels_per_design_unit = design_unit_in_logical_pixels * PIXELS_PER_LOGICAL_PIXEL
    context.translate(IMAGE_SIZE_IN_PIXELS / 2, IMAGE_SIZE_IN_PIXELS / 2)
    context.scale(pixels_per_design_unit, pixels_per_design_unit)
    context.translate(-ANIMATED_DESIGN_AREA_CENTER[0], -ANIMATED_DESIGN_AREA_CENTER[1])

    draw_resting_i(context, logo_color)
    surface.flush()

    output_path = OUTPUT_FOLDER / file_name
    print(f"{output_path.relative_to(PROJECT_ROOT)}")
    check_android_12_visible_circle(surface)
    surface.write_to_png(str(output_path))


def main() -> None:
    OUTPUT_FOLDER.mkdir(parents=True, exist_ok=True)
    design_unit_in_logical_pixels = read_design_unit_in_logical_pixels()
    print(f"designUnitInLogicalPixels = {design_unit_in_logical_pixels}")
    generate_image("splash_icon_dark.png", LOGO_COLOR_ON_DARK_BACKGROUND, design_unit_in_logical_pixels)
    generate_image("splash_icon_light.png", LOGO_COLOR_ON_LIGHT_BACKGROUND, design_unit_in_logical_pixels)


if __name__ == "__main__":
    main()
