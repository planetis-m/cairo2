when declared(use_pkg_config) or declared(use_pkg_config_static):
  {.pragma: libcairo, cdecl.}
  when defined(use_pkg_config_static):
    {.passl: gorge("pkg-config cairo --libs --static").}
  else:
    {.passl: gorge("pkg-config cairo --libs").}
else:
  when defined(windows):
    const LibCairo* = "libcairo-2.dll"
  elif defined(macosx):
    const LibCairo* = "libcairo(|.2).dylib"
  else:
    const LibCairo* = "libcairo.so(|.2)"
  {.pragma: libcairo, cdecl, dynlib: LibCairo.}

type
  Operator* = enum
    OperatorClear,
    OperatorSource,
    OperatorOver,
    OperatorIn,
    OperatorOut,
    OperatorAtop,
    OperatorDest,
    OperatorDestOver,
    OperatorDestIn,
    OperatorDestOut,
    OperatorDestAtop,
    OperatorXor,
    OperatorAdd,
    OperatorSaturate,
    OperatorMultiply,
    OperatorScreen,
    OperatorOverlay,
    OperatorDarken,
    OperatorLighten,
    OperatorColorDodge,
    OperatorColorBurn,
    OperatorHardLight,
    OperatorSoftLight,
    OperatorDifference,
    OperatorExclusion,
    OperatorHslHue,
    OperatorHslSaturation,
    OperatorHslColor,
    OperatorHslLuminosity

  Antialias* = enum
    AntialiasDefault, AntialiasNone, AntialiasGray, AntialiasSubpixel
  FillRule* = enum
    FillRuleWinding, FillRuleEvenOdd
  LineCap* = enum
    LineCapButt, LineCapRound, LineCapSquare
  LineJoin* = enum
    LineJoinMiter, LineJoinRound, LineJoinBevel
  FontSlant* = enum
    FontSlantNormal, FontSlantItalic, FontSlantOblique
  FontWeight* = enum
    FontWeightNormal, FontWeightBold
  SubpixelOrder* = enum
    SubpixelOrderDefault, SubpixelOrderRgb, SubpixelOrderBgr,
    SubpixelOrderVrgb, SubpixelOrderVbgr
  HintStyle* = enum
    HintStyleDefault, HintStyleNone, HintStyleSlight, HintStyleMedium,
    HintStyleFull
  HintMetrics* = enum
    HintMetricsDefault, HintMetricsOff, HintMetricsOn
  PathSegmentKind* = enum
    MoveTo, LineTo, CurveTo, ClosePath
  Content* = enum
    ContentColor = 0x00001000, ContentAlpha = 0x00002000,
    ContentColorAlpha = 0x00003000
  Format* = enum
    FormatArgb32, FormatRgb24, FormatA8, FormatA1
  Extend* = enum
    ExtendNone, ExtendRepeat, ExtendReflect, ExtendPad
  Filter* = enum
    FilterFast, FilterGood, FilterBest, FilterNearest, FilterBilinear,
    FilterGaussian
  FontType* = enum
    FontTypeToy, FontTypeFt, FontTypeWin32, FontTypeAtsui
  PatternType* = enum
    PatternTypeSolid, PatternTypeSurface, PatternTypeLinear,
    PatternTypeRadial
  SurfaceType* = enum
    SurfaceTypeImage, SurfaceTypePdf, SurfaceTypePs, SurfaceTypeXlib,
    SurfaceTypeXcb, SurfaceTypeGlitz, SurfaceTypeQuartz,
    SurfaceTypeWin32, SurfaceTypeBeos, SurfaceTypeDirectfb,
    SurfaceTypeSvg, SurfaceTypeOs2
  SvgVersion* = enum
    SvgVersion11, SvgVersion12
  CairoBool = int32
  DestroyFunc* = proc (data: pointer) {.cdecl.}
  WriteFunc* = proc (closure: pointer, data: cstring, len: int32): Status {.cdecl.}
  ReadFunc* = proc (closure: pointer, data: cstring, len: int32): Status {.cdecl.}
  TContext = object
  TSurface = object
  TPattern = object
  TScaledFont = object
  TFontFace = object
  TFontOptions = object
  Matrix* {.byref.} = object
    xx*: float64
    yx*: float64
    xy*: float64
    yy*: float64
    x0*: float64
    y0*: float64

  UserDataKey* {.byref.} = object
    unused*: int32

  TGlyph* {.byref.} = object
    index*: int32
    x*: float64
    y*: float64

  TTextExtents* {.byref.} = object
    xBearing* {.importc: "x_bearing".}: float64
    yBearing* {.importc: "y_bearing".}: float64
    width*: float64
    height*: float64
    xAdvance* {.importc: "x_advance".}: float64
    yAdvance* {.importc: "y_advance".}: float64

  TFontExtents* {.byref.} = object
    ascent*: float64
    descent*: float64
    height*: float64
    maxXAdvance* {.importc: "max_x_advance".}: float64
    maxYAdvance* {.importc: "max_y_advance".}: float64

  Header = object
    dataType {.importc: "type".}: PathSegmentKind
    length: int32

  Point* = object
    x*: float64
    y*: float64

  TPathData {.byref, union.} = object
    header: Header
    point: Point

  TPath* = object
    status*: Status
    data*: ptr UncheckedArray[TPathData]
    numData* {.importc: "num_data".}: int32

  Rectangle* {.byref.} = object
    x*, y*, width*, height*: float64

  TRectangleList* = object
    status*: Status
    rectangles*: ptr UncheckedArray[Rectangle]
    numRectangles* {.importc: "num_rectangles".}: int32

  PContext = ptr TContext
  PSurface = ptr TSurface
  PPattern = ptr TPattern
  PScaledFont = ptr TScaledFont
  PFontFace = ptr TFontFace
  PFontOptions = ptr TFontOptions
  PMatrix = ptr Matrix
  PUserDataKey = ptr UserDataKey
  PGlyph* = ptr TGlyph
  PTextExtents* = ptr TTextExtents
  PFontExtents* = ptr TFontExtents
  PPath* = ptr TPath
  PRectangleList* = ptr TRectangleList

{.push dynlib: LibCairo, importc, cdecl.}
proc cairo_version(): int32
proc cairo_version_string(): cstring
proc cairo_create(target: PSurface): PContext
proc cairo_reference(cr: PContext): PContext
proc cairo_destroy(cr: PContext)
proc cairo_get_reference_count(cr: PContext): int32
proc cairo_get_user_data(cr: PContext, key: UserDataKey): pointer
proc cairo_set_user_data(cr: PContext, key: UserDataKey, user_data: pointer, destroy: DestroyFunc): Status
proc cairo_save(cr: PContext)
proc cairo_restore(cr: PContext)
proc cairo_push_group(cr: PContext)
proc cairo_push_group_with_content(cr: PContext, content: Content)
proc cairo_pop_group(cr: PContext): PPattern
proc cairo_pop_group_to_source(cr: PContext)
# Modify state
proc cairo_set_operator(cr: PContext, op: Operator)
proc cairo_set_source(cr: PContext, source: PPattern)
proc cairo_set_source_rgb(cr: PContext, red, green, blue: float64)
proc cairo_set_source_rgba(cr: PContext, red, green, blue, alpha: float64)
proc cairo_set_source_surface(cr: PContext, surface: PSurface, x, y: float64)
proc cairo_set_tolerance(cr: PContext, tolerance: float64)
proc cairo_set_antialias(cr: PContext, antialias: Antialias)
proc cairo_set_fill_rule(cr: PContext, fill_rule: FillRule)
proc cairo_set_line_width(cr: PContext, width: float64)
proc cairo_set_line_cap(cr: PContext, line_cap: LineCap)
proc cairo_set_line_join(cr: PContext, line_join: LineJoin)
proc cairo_set_dash(cr: PContext, dashes: openarray[float64], offset: float64)
proc cairo_set_miter_limit(cr: PContext, limit: float64)
proc cairo_translate(cr: PContext, tx, ty: float64)
proc cairo_scale(cr: PContext, sx, sy: float64)
proc cairo_rotate(cr: PContext, angle: float64)
proc cairo_transform(cr: PContext, matrix: Matrix)
proc cairo_set_matrix(cr: PContext, matrix: Matrix)
proc cairo_identity_matrix(cr: PContext)
proc cairo_user_to_device(cr: PContext, x, y: var float64)
proc cairo_user_to_device_distance(cr: PContext, dx, dy: var float64)
proc cairo_device_to_user(cr: PContext, x, y: var float64)
proc cairo_device_to_user_distance(cr: PContext, dx, dy: var float64)
# Path creation functions
proc cairo_new_path(cr: PContext)
proc cairo_move_to(cr: PContext, x, y: float64)
proc cairo_new_sub_path(cr: PContext)
proc cairo_line_to(cr: PContext, x, y: float64)
proc cairo_curve_to(cr: PContext, x1, y1, x2, y2, x3, y3: float64)
proc cairo_arc(cr: PContext, xc, yc, radius, angle1, angle2: float64)
proc cairo_arc_negative(cr: PContext, xc, yc, radius, angle1, angle2: float64)
proc cairo_rel_move_to(cr: PContext, dx, dy: float64)
proc cairo_rel_line_to(cr: PContext, dx, dy: float64)
proc cairo_rel_curve_to(cr: PContext, dx1, dy1, dx2, dy2, dx3, dy3: float64)
proc cairo_rectangle(cr: PContext, x, y, width, height: float64)
proc cairo_close_path(cr: PContext)
# Painting functions
proc cairo_paint(cr: PContext)
proc cairo_paint_with_alpha(cr: PContext, alpha: float64)
proc cairo_mask(cr: PContext, pattern: PPattern)
proc cairo_mask_surface(cr: PContext, surface: PSurface, surface_x, surface_y: float64)
proc cairo_stroke(cr: PContext)
proc cairo_stroke_preserve(cr: PContext)
proc cairo_fill(cr: PContext)
proc cairo_fill_preserve(cr: PContext)
proc cairo_copy_page(cr: PContext)
proc cairo_show_page(cr: PContext)
# Insideness testing
proc cairo_in_stroke(cr: PContext, x, y: float64): CairoBool
proc cairo_in_fill(cr: PContext, x, y: float64): CairoBool
# Rectangular extents
proc cairo_stroke_extents(cr: PContext, x1, y1, x2, y2: var float64)
proc cairo_fill_extents(cr: PContext, x1, y1, x2, y2: var float64)
# Clipping
proc cairo_reset_clip(cr: PContext)
proc cairo_clip(cr: PContext)
proc cairo_clip_preserve(cr: PContext)
proc cairo_clip_extents(cr: PContext, x1, y1, x2, y2: var float64)
proc cairo_copy_clip_rectangle_list(cr: PContext): PRectangleList
proc cairo_rectangle_list_destroy(rectangle_list: PRectangleList)
# Font/Text functions
proc cairo_font_options_create(): PFontOptions
proc cairo_font_options_copy(original: PFontOptions): PFontOptions
proc cairo_font_options_destroy(options: PFontOptions)
proc cairo_font_options_status(options: PFontOptions): Status
proc cairo_font_options_merge(options, other: PFontOptions)
proc cairo_font_options_equal(options, other: PFontOptions): CairoBool
proc cairo_font_options_hash(options: PFontOptions): int32
proc cairo_font_options_set_antialias(options: PFontOptions, antialias: Antialias)
proc cairo_font_options_get_antialias(options: PFontOptions): Antialias
proc cairo_font_options_set_subpixel_order(options: PFontOptions, subpixel_order: SubpixelOrder)
proc cairo_font_options_get_subpixel_order(options: PFontOptions): SubpixelOrder
proc cairo_font_options_set_hint_style(options: PFontOptions, hint_style: HintStyle)
proc cairo_font_options_get_hint_style(options: PFontOptions): HintStyle
proc cairo_font_options_set_hint_metrics(options: PFontOptions, hint_metrics: HintMetrics)
proc cairo_font_options_get_hint_metrics(options: PFontOptions): HintMetrics
# This interface is for dealing with text as text, not caring about the
  #   font object inside the the TCairo.
proc cairo_select_font_face(cr: PContext, family: cstring, slant: FontSlant, weight: FontWeight)
proc cairo_set_font_size(cr: PContext, size: float64)
proc cairo_set_font_matrix(cr: PContext, matrix: Matrix)
proc cairo_get_font_matrix(cr: PContext, matrix: Matrix)
proc cairo_set_font_options(cr: PContext, options: PFontOptions)
proc cairo_get_font_options(cr: PContext, options: PFontOptions)
proc cairo_set_font_face(cr: PContext, font_face: PFontFace)
proc cairo_get_font_face(cr: PContext): PFontFace
proc cairo_set_scaled_font(cr: PContext, scaled_font: PScaledFont)
proc cairo_get_scaled_font(cr: PContext): PScaledFont
proc cairo_show_text(cr: PContext, utf8: cstring)
proc cairo_show_glyphs(cr: PContext, glyphs: PGlyph, num_glyphs: int32)
proc cairo_text_path(cr: PContext, utf8: cstring)
proc cairo_glyph_path(cr: PContext, glyphs: PGlyph, num_glyphs: int32)
proc cairo_text_extents(cr: PContext, utf8: cstring, extents: PTextExtents)
proc cairo_glyph_extents(cr: PContext, glyphs: PGlyph, num_glyphs: int32, extents: PTextExtents)
proc cairo_font_extents(cr: PContext, extents: PFontExtents)
# Generic identifier for a font style
proc cairo_font_face_reference(font_face: PFontFace): PFontFace
proc cairo_font_face_destroy(font_face: PFontFace)
proc cairo_font_face_get_reference_count(font_face: PFontFace): int32
proc cairo_font_face_status(font_face: PFontFace): Status
proc cairo_font_face_get_type(font_face: PFontFace): FontType
proc cairo_font_face_get_user_data(font_face: PFontFace, key: UserDataKey): pointer
proc cairo_font_face_set_user_data(font_face: PFontFace, key: UserDataKey, user_data: pointer, destroy: DestroyFunc): Status
# Portable interface to general font features
proc cairo_scaled_font_create(font_face: PFontFace, font_matrix, ctm: Matrix, options: PFontOptions): PScaledFont
proc cairo_scaled_font_reference(scaled_font: PScaledFont): PScaledFont
proc cairo_scaled_font_destroy(scaled_font: PScaledFont)
proc cairo_scaled_font_get_reference_count(scaled_font: PScaledFont): int32
proc cairo_scaled_font_status(scaled_font: PScaledFont): Status
proc cairo_scaled_font_get_type(scaled_font: PScaledFont): FontType
proc cairo_scaled_font_get_user_data(scaled_font: PScaledFont, key: UserDataKey): pointer
proc cairo_scaled_font_set_user_data(scaled_font: PScaledFont, key: UserDataKey, user_data: pointer, destroy: DestroyFunc): Status
proc cairo_scaled_font_extents(scaled_font: PScaledFont, extents: PFontExtents)
proc cairo_scaled_font_text_extents(scaled_font: PScaledFont, utf8: cstring, extents: PTextExtents)
proc cairo_scaled_font_glyph_extents(scaled_font: PScaledFont, glyphs: PGlyph, num_glyphs: int32, extents: PTextExtents)
proc cairo_scaled_font_get_font_face(scaled_font: PScaledFont): PFontFace
proc cairo_scaled_font_get_font_matrix(scaled_font: PScaledFont, font_matrix: var Matrix)
proc cairo_scaled_font_get_ctm(scaled_font: PScaledFont, ctm: var Matrix)
proc cairo_scaled_font_get_font_options(scaled_font: PScaledFont, options: PFontOptions)
# Query functions
proc cairo_get_operator(cr: PContext): Operator
proc cairo_get_source(cr: PContext): PPattern
proc cairo_get_tolerance(cr: PContext): float64
proc cairo_get_antialias(cr: PContext): Antialias
proc cairo_get_current_point(cr: PContext, x, y: var float64)
proc cairo_get_fill_rule(cr: PContext): FillRule
proc cairo_get_line_width(cr: PContext): float64
proc cairo_get_line_cap(cr: PContext): LineCap
proc cairo_get_line_join(cr: PContext): LineJoin
proc cairo_get_miter_limit(cr: PContext): float64
proc cairo_get_dash_count(cr: PContext): int32
proc cairo_get_dash(cr: PContext, dashes: ptr[float64], offset: var float64)
proc cairo_get_matrix(cr: PContext, matrix: var Matrix)
proc cairo_get_target(cr: PContext): PSurface
proc cairo_get_group_target(cr: PContext): PSurface
proc cairo_copy_path(cr: PContext): PPath
proc cairo_copy_path_flat(cr: PContext): PPath
proc cairo_append_path(cr: PContext, path: PPath)
proc cairo_path_destroy(path: PPath)
# Error status queries
proc cairo_status(cr: PContext): Status
proc cairo_status_to_string(status: Status): cstring
# Surface manipulation
proc cairo_surface_create_similar(other: PSurface, content: Content, width, height: int32): PSurface
proc cairo_surface_reference(surface: PSurface): PSurface
proc cairo_surface_finish(surface: PSurface)
proc cairo_surface_destroy(surface: PSurface)
proc cairo_surface_get_reference_count(surface: PSurface): int32
proc cairo_surface_status(surface: PSurface): Status
proc cairo_surface_get_type(surface: PSurface): SurfaceType
proc cairo_surface_get_content(surface: PSurface): Content
proc cairo_surface_write_to_png(surface: PSurface, filename: cstring): Status
proc cairo_surface_write_to_png_stream(surface: PSurface, write_func: WriteFunc, closure: pointer): Status
proc cairo_surface_get_user_data(surface: PSurface, key: UserDataKey): pointer
proc cairo_surface_set_user_data(surface: PSurface, key: UserDataKey, user_data: pointer, destroy: DestroyFunc): Status
proc cairo_surface_get_font_options(surface: PSurface, options: PFontOptions)
proc cairo_surface_flush(surface: PSurface)
proc cairo_surface_mark_dirty(surface: PSurface)
proc cairo_surface_mark_dirty_rectangle(surface: PSurface, x, y, width, height: int32)
proc cairo_surface_set_device_offset(surface: PSurface, x_offset, y_offset: float64)
proc cairo_surface_get_device_offset(surface: PSurface, x_offset, y_offset: var float64)
proc cairo_surface_set_fallback_resolution(surface: PSurface, x_pixels_per_inch, y_pixels_per_inch: float64)
# Image-surface functions
proc cairo_image_surface_create(format: Format, width, height: int32): PSurface
proc cairo_image_surface_create_for_data(data: cstring, format: Format, width, height, stride: int32): PSurface
proc cairo_image_surface_get_data(surface: PSurface): cstring
proc cairo_image_surface_get_format(surface: PSurface): Format
proc cairo_image_surface_get_width(surface: PSurface): int32
proc cairo_image_surface_get_height(surface: PSurface): int32
proc cairo_image_surface_get_stride(surface: PSurface): int32
proc cairo_image_surface_create_from_png(filename: cstring): PSurface
proc cairo_image_surface_create_from_png_stream(read_func: ReadFunc, closure: pointer): PSurface
# Pattern creation functions
proc cairo_pattern_create_rgb(red, green, blue: float64): PPattern
proc cairo_pattern_create_rgba(red, green, blue, alpha: float64): PPattern
proc cairo_pattern_create_for_surface(surface: PSurface): PPattern
proc cairo_pattern_create_linear(x0, y0, x1, y1: float64): PPattern
proc cairo_pattern_create_radial(cx0, cy0, radius0, cx1, cy1, radius1: float64): PPattern
proc cairo_pattern_reference(pattern: PPattern): PPattern
proc cairo_pattern_destroy(pattern: PPattern)
proc cairo_pattern_get_reference_count(pattern: PPattern): int32
proc cairo_pattern_status(pattern: PPattern): Status
proc cairo_pattern_get_user_data(pattern: PPattern, key: UserDataKey): pointer
proc cairo_pattern_set_user_data(pattern: PPattern, key: UserDataKey, user_data: pointer, destroy: DestroyFunc): Status
proc cairo_pattern_get_type(pattern: PPattern): PatternType
proc cairo_pattern_add_color_stop_rgb(pattern: PPattern, offset, red, green, blue: float64)
proc cairo_pattern_add_color_stop_rgba(pattern: PPattern, offset, red, green, blue, alpha: float64)
proc cairo_pattern_set_matrix(pattern: PPattern, matrix: Matrix)
proc cairo_pattern_get_matrix(pattern: PPattern, matrix: var Matrix)
proc cairo_pattern_set_extend(pattern: PPattern, extend: Extend)
proc cairo_pattern_get_extend(pattern: PPattern): Extend
proc cairo_pattern_set_filter(pattern: PPattern, filter: Filter)
proc cairo_pattern_get_filter(pattern: PPattern): Filter
proc cairo_pattern_get_rgba(pattern: PPattern, red, green, blue, alpha: var float64): Status
proc cairo_pattern_get_surface(pattern: PPattern, surface: PSurface): Status
proc cairo_pattern_get_color_stop_rgba(pattern: PPattern, index: int32, offset, red, green, blue, alpha: var float64): Status
proc cairo_pattern_get_color_stop_count(pattern: PPattern, count: var int32): Status
proc cairo_pattern_get_linear_points(pattern: PPattern, x0, y0, x1, y1: var float64): Status
proc cairo_pattern_get_radial_circles(pattern: PPattern, x0, y0, r0, x1, y1, r1: var float64): Status
# Matrix functions
proc cairo_matrix_init(matrix: var Matrix, xx, yx, xy, yy, x0, y0: float64)
proc cairo_matrix_init_identity(matrix: var Matrix)
proc cairo_matrix_init_translate(matrix: var Matrix, tx, ty: float64)
proc cairo_matrix_init_scale(matrix: var Matrix, sx, sy: float64)
proc cairo_matrix_init_rotate(matrix: var Matrix, radians: float64)
proc cairo_matrix_translate(matrix: var Matrix, tx, ty: float64)
proc cairo_matrix_scale(matrix: var Matrix, sx, sy: float64)
proc cairo_matrix_rotate(matrix: var Matrix, radians: float64)
proc cairo_matrix_invert(matrix: var Matrix): Status
proc cairo_matrix_multiply(result: var Matrix, a, b: Matrix)
proc cairo_matrix_transform_distance(matrix: Matrix, dx, dy: var float64)
proc cairo_matrix_transform_point(matrix: Matrix, x, y: var float64)
# PDF functions
proc cairo_pdf_surface_create(filename: cstring, width_in_points, height_in_points: float64): PSurface
proc cairo_pdf_surface_create_for_stream(write_func: WriteFunc, closure: pointer, width_in_points, height_in_points: float64): PSurface
proc cairo_pdf_surface_set_size(surface: PSurface, width_in_points, height_in_points: float64)
# PS functions
proc cairo_ps_surface_create(filename: cstring, width_in_points, height_in_points: float64): PSurface
proc cairo_ps_surface_create_for_stream(write_func: WriteFunc, closure: pointer, width_in_points, height_in_points: float64): PSurface
proc cairo_ps_surface_set_size(surface: PSurface, width_in_points, height_in_points: float64)
proc cairo_ps_surface_dsc_comment(surface: PSurface, comment: cstring)
proc cairo_ps_surface_dsc_begin_setup(surface: PSurface)
proc cairo_ps_surface_dsc_begin_page_setup(surface: PSurface)
# SVG functions
proc cairo_svg_surface_create(filename: cstring, width_in_points, height_in_points: float64): PSurface
proc cairo_svg_surface_create_for_stream(write_func: WriteFunc, closure: pointer, width_in_points, height_in_points: float64): PSurface
proc cairo_svg_surface_restrict_to_version(surface: PSurface, version: SvgVersion)
  #todo: see how translate this
  #procedure cairo_svg_get_versions(TCairoSvgVersion const **versions, # int *num_versions);
proc cairo_svg_version_to_string(version: SvgVersion): cstring
# Functions to be used while debugging (not intended for use in production code)
proc cairo_debug_reset_static_data()
# new since 1.10
proc cairo_surface_create_for_rectangle(target: PSurface, x, y, w, h: float64): PSurface
{.pop.}
