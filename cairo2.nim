import macros

macro toCairoError(body: untyped): untyped =
  template declSubty(a, b) =
    type a* = object of b
  template declEnum(name, none) =
    type name* = enum
      none
  expectKind body, nnkStmtList
  expectKind body[0], nnkTypeSection
  expectLen body[0], 1
  result = newStmtList()
  let statusTy = getAst(declEnum(ident"Status", ident"StatusSuccess"))
  let errBasety = newIdentNode("CairoError")
  result.add getAst(declSubty(errBasety, ident"CatchableError"))
  let enumVals = body[0][0][2]
  for i in 2 ..< enumVals.len: # skip StatusSuccess
    statusTy[0][2].add newIdentNode("Status" & enumVals[i].strVal)
    result.add getAst(declSubty(newIdentNode("Cairo" & enumVals[i].strVal), errBasety))
  result.add statusTy

toCairoError:
  type Status = enum
    Success,
    NoMemory,
    InvalidRestore,
    InvalidPopGroup,
    NoCurrentPoint,
    InvalidMatrix,
    InvalidStatus,
    NullPointer,
    InvalidString,
    InvalidPathData,
    ReadError,
    WriteError,
    SurfaceFinished,
    SurfaceTypeMismatch,
    PatternTypeMismatch,
    InvalidContent,
    InvalidFormat,
    InvalidVisual,
    FileNotFound,
    InvalidDash,
    InvalidDscComment,
    InvalidIndex,
    ClipNotRepresentable,
    TempFileError,
    InvalidStride,
    FontTypeMismatch,
    UserFontImmutable,
    UserFontError,
    NegativeCount,
    InvalidClusters,
    InvalidSlant,
    InvalidWeight,
    InvalidSize,
    UserFontNotImplemented,
    DeviceTypeMismatch,
    DeviceError,
    InvalidMeshConstruction,
    DeviceFinished,
    Jbig2GlobalMissing,
    PngError,
    FreetypeError,
    Win32GdiError,
    TagError

template statusToString(status) =
  $cairo_status_to_string(status)

macro checkStatus(expr, raises: untyped): untyped =
  result = newStmtList()
  let statusVal = genSym(nskTemp)
  result.add newLetStmt(statusVal, expr)
  result.add nnkCaseStmt.newTree(statusVal)
  result[1].add nnkOfBranch.newTree(ident"StatusSuccess",
    nnkDiscardStmt.newTree(newEmptyNode()))
  for n in raises:
    result[1].add nnkOfBranch.newTree(newIdentNode("Status" & n.strVal), nnkRaiseStmt.newTree(
      newCall(bindSym"newException", newIdentNode("Cairo" & n.strVal),
      getAst(statusToString(statusVal)))))
  result[1].add nnkElse.newTree(newCall(bindSym"assert", newLit(false),
    getAst(statusToString(statusVal))))

include "cairo_cheader.nim"

type
  Context* = object
    impl: PContext
  FontOptions* = object
    impl: PFontOptions
  FontFace* = object
    impl: PFontFace
  ScaledFont* = object
    impl: PScaledFont
  Surface* = object
    impl: PSurface
  Pattern* = object
    impl: PPattern

proc `=destroy`(cr: var Context) =
  if cr.impl != nil:
    cairo_destroy(cr.impl)
    cr.impl = nil
proc `=`(cr: var Context; original: Context) =
  if cr.impl != nil: cairo_destroy(cr.impl)
  cr.impl = cairo_reference(original.impl)
proc `=sink`(cr: var Context; original: Context) =
  `=destroy`(cr)
  cr.impl = original.impl

proc `=destroy`(options: var FontOptions) =
  if options.impl != nil:
    cairo_font_options_destroy(options.impl)
    options.impl = nil
proc `=`(options: var FontOptions; original: FontOptions) =
  if options.impl != original.impl:
    `=destroy`(options)
    options.impl = cairo_font_options_copy(original.impl)
proc `=sink`(options: var FontOptions; original: FontOptions) =
  `=destroy`(options)
  options.impl = original.impl

proc `=destroy`(fontFace: var FontFace) =
  if fontFace.impl != nil:
    cairo_font_face_destroy(fontFace.impl)
    fontFace.impl = nil
proc `=`(fontFace: var FontFace; original: FontFace) =
  if fontFace.impl != nil: cairo_destroy(fontFace.impl)
  fontFace.impl = cairo_reference(original.impl)
proc `=sink`(fontFace: var FontFace; original: FontFace) =
  `=destroy`(fontFace)
  fontFace.impl = original.impl

proc `=destroy`(scaledFont: var ScaledFont) =
  if scaledFont.impl != nil:
    cairo_scaled_font_destroy(scaledFont.impl)
    scaledFont.impl = nil
proc `=`(scaledFont: var ScaledFont; original: ScaledFont) =
  if scaledFont.impl != nil: cairo_destroy(scaledFont.impl)
  scaledFont.impl = cairo_reference(original.impl)
proc `=sink`(scaledFont: var ScaledFont; original: ScaledFont) =
  `=destroy`(scaledFont)
  scaledFont.impl = original.impl

proc `=destroy`(surface: var Surface) =
  if surface.impl != nil:
    cairo_surface_destroy(surface.impl)
    surface.impl = nil
proc `=`(surface: var Surface; original: Surface) =
  if surface.impl != nil: cairo_surface_destroy(surface.impl)
  surface.impl = cairo_surface_reference(original.impl)
proc `=sink`(surface: var Surface; original: Surface) =
  `=destroy`(surface)
  surface.impl = original.impl

proc `=destroy`(pattern: var Pattern) =
  if pattern.impl != nil:
    cairo_pattern_destroy(pattern.impl)
    pattern.impl = nil
proc `=`(pattern: var Pattern; original: Pattern) =
  if pattern.impl != nil: cairo_surface_destroy(pattern.impl)
  pattern.impl = cairo_surface_reference(original.impl)
proc `=sink`(pattern: var Pattern; original: Pattern) =
  `=destroy`(pattern)
  pattern.impl = original.impl

proc version*(): int32 =
  cairo_version()
proc versionString*(): string =
  $cairo_version_string()
proc create*(target: Surface): Context =
  result = Context(impl: cairo_create(target.impl))
proc getUserData*(cr: Context, key: UserDataKey): pointer =
  cairo_get_user_data(cr.impl, key)
proc setUserData*(cr: Context, key: UserDataKey, userData: pointer, destroy: DestroyFunc) =
  checkStatus cairo_set_user_data(cr.impl, key, userData, destroy), [NoMemory]
proc save*(cr: Context) =
  cairo_save(cr.impl)
proc restore*(cr: Context) =
  cairo_restore(cr.impl)
proc pushGroup*(cr: Context) =
  cairo_push_group(cr.impl)
proc pushGroupWithContent*(cr: Context, content: Content) =
  cairo_push_group_with_content(cr.impl, content)
proc popGroup*(cr: Context): Pattern =
  result = Pattern(impl: cairo_pop_group(cr.impl))
proc popGroupToSource*(cr: Context) =
  cairo_pop_group_to_source(cr.impl)
# Modify state
proc setOperator*(cr: Context, op: Operator) =
  cairo_set_operator(cr.impl, op)
proc setSource*(cr: Context, source: Pattern) =
  cairo_set_source(cr.impl, source.impl)
proc setSourceRgb*(cr: Context, red, green, blue: float64) =
  cairo_set_source_rgb(cr.impl, red, green, blue)
proc setSourceRgba*(cr: Context, red, green, blue, alpha: float64) =
  cairo_set_source_rgba(cr.impl, red, green, blue, alpha)
proc setSource*(cr: Context, surface: Surface, x, y: float64) =
  cairo_set_source_surface(cr.impl, surface.impl, x, y)
proc setTolerance*(cr: Context, tolerance: float64) =
  cairo_set_tolerance(cr.impl, tolerance)
proc setAntialias*(cr: Context, antialias: Antialias) =
  cairo_set_antialias(cr.impl, antialias)
proc setFillRule*(cr: Context, fillRule: FillRule) =
  cairo_set_fill_rule(cr.impl, fillRule)
proc setLineWidth*(cr: Context, width: float64) =
  cairo_set_line_width(cr.impl, width)
proc setLineCap*(cr: Context, lineCap: LineCap) =
  cairo_set_line_cap(cr.impl, lineCap)
proc setLineJoin*(cr: Context, lineJoin: LineJoin) =
  cairo_set_line_join(cr.impl, lineJoin)
proc setDash*(cr: Context, dashes: openarray[float64], offset: float64) =
  cairo_set_dash(cr.impl, dashes, offset)
proc setMiterLimit*(cr: Context, limit: float64) =
  cairo_set_miter_limit(cr.impl, limit)
proc translate*(cr: Context, tx, ty: float64) =
  cairo_translate(cr.impl, tx, ty)
proc scale*(cr: Context, sx, sy: float64) =
  cairo_scale(cr.impl, sx, sy)
proc rotate*(cr: Context, angle: float64) =
  cairo_rotate(cr.impl, angle)
proc transform*(cr: Context, matrix: Matrix) =
  cairo_transform(cr.impl, matrix)
proc setMatrix*(cr: Context, matrix: Matrix) =
  cairo_set_matrix(cr.impl, matrix)
proc identityMatrix*(cr: Context) =
  cairo_identity_matrix(cr.impl)
proc userToDevice*(cr: Context, x, y: var float64) =
  cairo_user_to_device(cr.impl, x, y)
proc userToDeviceDistance*(cr: Context, dx, dy: var float64) =
  cairo_user_to_device_distance(cr.impl, dx, dy)
proc deviceToUser*(cr: Context, x, y: var float64) =
  cairo_device_to_user(cr.impl, x, y)
proc deviceToUserDistance*(cr: Context, dx, dy: var float64) =
  cairo_device_to_user_distance(cr.impl, dx, dy)
# Path creation functions
proc newPath*(cr: Context) =
  cairo_new_path(cr.impl)
proc moveTo*(cr: Context, x, y: float64) =
  cairo_move_to(cr.impl, x, y)
proc newSubPath*(cr: Context) =
  cairo_new_sub_path(cr.impl)
proc lineTo*(cr: Context, x, y: float64) =
  cairo_line_to(cr.impl, x, y)
proc curveTo*(cr: Context, x1, y1, x2, y2, x3, y3: float64) =
  cairo_curve_to(cr.impl, x1, y1, x2, y2, x3, y3)
proc arc*(cr: Context, xc, yc, radius, angle1, angle2: float64) =
  cairo_arc(cr.impl, xc, yc, radius, angle1, angle2)
proc arcNegative*(cr: Context, xc, yc, radius, angle1, angle2: float64) =
  cairo_arc_negative(cr.impl, xc, yc, radius, angle1, angle2)
proc relMoveTo*(cr: Context, dx, dy: float64) =
  cairo_rel_move_to(cr.impl, dx, dy)
proc relLineTo*(cr: Context, dx, dy: float64) =
  cairo_rel_line_to(cr.impl, dx, dy)
proc relCurveTo*(cr: Context, dx1, dy1, dx2, dy2, dx3, dy3: float64) =
  cairo_rel_curve_to(cr.impl, dx1, dy1, dx2, dy2, dx3, dy3)
proc rectangle*(cr: Context, x, y, width, height: float64) =
  cairo_rectangle(cr.impl, x, y, width, height)
proc closePath*(cr: Context) =
  cairo_close_path(cr.impl)
# Painting functions
proc paint*(cr: Context) =
  cairo_paint(cr.impl)
proc paintWithAlpha*(cr: Context, alpha: float64) =
  cairo_paint_with_alpha(cr.impl, alpha)
proc mask*(cr: Context, pattern: Pattern) =
  cairo_mask(cr.impl, pattern.impl)
proc mask*(cr: Context, surface: Surface, surfaceX, surfaceY: float64) =
  cairo_mask_surface(cr.impl, surface.impl, surfaceX, surfaceY)
proc stroke*(cr: Context) =
  cairo_stroke(cr.impl)
proc strokePreserve*(cr: Context) =
  cairo_stroke_preserve(cr.impl)
proc fill*(cr: Context) =
  cairo_fill(cr.impl)
proc fillPreserve*(cr: Context) =
  cairo_fill_preserve(cr.impl)
proc copyPage*(cr: Context) =
  cairo_copy_page(cr.impl)
proc showPage*(cr: Context) =
  cairo_show_page(cr.impl)
# Insideness testing
proc inStroke*(cr: Context, x, y: float64): bool =
  cairo_in_stroke(cr.impl, x, y) == 1'i32
proc inFill*(cr: Context, x, y: float64): bool =
  cairo_in_fill(cr.impl, x, y) == 1'i32
# Rectangular extents
proc strokeExtents*(cr: Context, x1, y1, x2, y2: var float64) =
  cairo_stroke_extents(cr.impl, x1, y1, x2, y2)
proc fillExtents*(cr: Context, x1, y1, x2, y2: var float64) =
  cairo_fill_extents(cr.impl, x1, y1, x2, y2)
# Clipping
proc resetClip*(cr: Context) =
  cairo_reset_clip(cr.impl)
proc clip*(cr: Context) =
  cairo_clip(cr.impl)
proc clipPreserve*(cr: Context) =
  cairo_clip_preserve(cr.impl)
proc clipExtents*(cr: Context, x1, y1, x2, y2: var float64) =
  cairo_clip_extents(cr.impl, x1, y1, x2, y2)
proc copyClipRectangleList*(cr: Context): RectangleList =
  cairo_copy_clip_rectangle_list(cr.impl)
# Font/Text functions
proc fontOptionsCreate*(): FontOptions =
  result = FontOptions(impl: cairo_font_options_create())
proc merge*(options, other: FontOptions) =
  cairo_font_options_merge(options.impl, other.impl)
proc equal*(options, other: FontOptions): bool =
  cairo_font_options_equal(options.impl, other.impl) == 1'i32
proc hash*(options: FontOptions): int32 =
  cairo_font_options_hash(options.impl)
proc setAntialias*(options: FontOptions, antialias: Antialias) =
  cairo_font_options_set_antialias(options.impl, antialias)
proc getAntialias*(options: FontOptions): Antialias =
  cairo_font_options_get_antialias(options.impl)
proc setSubpixelOrder*(options: FontOptions, subpixelOrder: SubpixelOrder) =
  cairo_font_options_set_subpixel_order(options.impl, subpixelOrder)
proc getSubpixelOrder*(options: FontOptions): SubpixelOrder =
  cairo_font_options_get_subpixel_order(options.impl)
proc setHintStyle*(options: FontOptions, hintStyle: HintStyle) =
  cairo_font_options_set_hint_style(options.impl, hintStyle)
proc getHintStyle*(options: FontOptions): HintStyle =
  cairo_font_options_get_hint_style(options.impl)
proc setHintMetrics*(options: FontOptions, hintMetrics: HintMetrics) =
  cairo_font_options_set_hint_metrics(options.impl, hintMetrics)
proc getHintMetrics*(options: FontOptions): HintMetrics =
  cairo_font_options_get_hint_metrics(options.impl)
# This interface is for dealing with text as text, not caring about the
  #   font object inside the the TCairo.
proc selectFontFace*(cr: Context, family: string, slant: FontSlant, weight: FontWeight) =
  cairo_select_font_face(cr.impl, family, slant, weight)
proc setFontSize*(cr: Context, size: float64) =
  cairo_set_font_size(cr.impl, size)
proc setFontMatrix*(cr: Context, matrix: Matrix) =
  cairo_set_font_matrix(cr.impl, matrix)
proc getFontMatrix*(cr: Context, matrix: Matrix) =
  cairo_get_font_matrix(cr.impl, matrix)
proc setFontOptions*(cr: Context, options: FontOptions) =
  cairo_set_font_options(cr.impl, options.impl)
proc getFontOptions*(cr: Context): FontOptions =
  result = fontOptionsCreate()
  cairo_get_font_options(cr.impl, result.impl)
proc setFontFace*(cr: Context, fontFace: FontFace) =
  cairo_set_font_face(cr.impl, fontFace.impl)
proc getFontFace*(cr: Context): FontFace =
  result = FontFace(impl: cairo_get_font_face(cr.impl))
proc setScaledFont*(cr: Context, scaledFont: ScaledFont) =
  cairo_set_scaled_font(cr.impl, scaledFont.impl)
proc getScaledFont*(cr: Context): ScaledFont =
  result = ScaledFont(impl: cairo_get_scaled_font(cr.impl))
proc showText*(cr: Context, utf8: string) =
  cairo_show_text(cr.impl, utf8)
proc showGlyphs*(cr: Context, glyphs: Glyph, numGlyphs: int32) =
  cairo_show_glyphs(cr.impl, glyphs, numGlyphs)
proc textPath*(cr: Context, utf8: string) =
  cairo_text_path(cr.impl, utf8)
proc glyphPath*(cr: Context, glyphs: Glyph, numGlyphs: int32) =
  cairo_glyph_path(cr.impl, glyphs, numGlyphs)
proc textExtents*(cr: Context, utf8: string, extents: TextExtents) =
  cairo_text_extents(cr.impl, utf8, extents)
proc glyphExtents*(cr: Context, glyphs: Glyph, numGlyphs: int32, extents: TextExtents) =
  cairo_glyph_extents(cr.impl, glyphs, numGlyphs, extents)
proc fontExtents*(cr: Context, extents: FontExtents) =
  cairo_font_extents(cr.impl, extents)
# Generic identifier for a font style
proc getType*(fontFace: FontFace): FontType =
  cairo_font_face_get_type(fontFace.impl)
proc getUserData*(fontFace: FontFace, key: UserDataKey): pointer =
  cairo_font_face_get_user_data(fontFace.impl, key)
proc setUserData*(fontFace: FontFace, key: UserDataKey, userData: pointer, destroy: DestroyFunc) =
  checkStatus cairo_font_face_set_user_data(fontFace.impl, key, userData, destroy), [NoMemory]
# Portable interface to general font features
proc scaledFontCreate*(fontFace: FontFace, fontMatrix: Matrix, ctm: Matrix, options: FontOptions): ScaledFont =
  result = ScaledFont(impl: cairo_scaled_font_create(fontFace.impl, fontMatrix, ctm, options.impl))
proc getType*(scaledFont: ScaledFont): FontType =
  cairo_scaled_font_get_type(scaledFont.impl)
proc getUserData*(scaledFont: ScaledFont, key: UserDataKey): pointer =
  cairo_scaled_font_get_user_data(scaledFont.impl, key)
proc setUserData*(scaledFont: ScaledFont, key: UserDataKey, userData: pointer, destroy: DestroyFunc) =
  checkStatus cairo_scaled_font_set_user_data(scaledFont.impl, key, userData, destroy), [NoMemory]
proc extents*(scaledFont: ScaledFont, extents: FontExtents) =
  cairo_scaled_font_extents(scaledFont.impl, extents)
proc textExtents*(scaledFont: ScaledFont, utf8: string, extents: TextExtents) =
  cairo_scaled_font_text_extents(scaledFont.impl, utf8, extents)
proc glyphExtents*(scaledFont: ScaledFont, glyphs: Glyph, numGlyphs: int32, extents: TextExtents) =
  cairo_scaled_font_glyph_extents(scaledFont.impl, glyphs, numGlyphs, extents)
proc getFontFace*(scaledFont: ScaledFont): FontFace =
  result = FontFace(impl: cairo_scaled_font_get_font_face(scaledFont.impl))
proc getFontMatrix*(scaledFont: ScaledFont): Matrix =
  cairo_scaled_font_get_font_matrix(scaledFont.impl, result)
proc getCtm*(scaledFont: ScaledFont): Matrix =
  cairo_scaled_font_get_ctm(scaledFont.impl, result)
proc getFontOptions*(scaledFont: ScaledFont): FontOptions =
  result = fontOptionsCreate()
  cairo_scaled_font_get_font_options(scaledFont.impl, result.impl)
# Query functions
proc getOperator*(cr: Context): Operator =
  cairo_get_operator(cr.impl)
proc getSource*(cr: Context): Pattern =
  result = Pattern(impl: cairo_get_source(cr.impl))
proc getTolerance*(cr: Context): float64 =
  cairo_get_tolerance(cr.impl)
proc getAntialias*(cr: Context): Antialias =
  cairo_get_antialias(cr.impl)
proc getCurrentPoint*(cr: Context, x, y: var float64) =
  cairo_get_current_point(cr.impl, x, y)
proc getFillRule*(cr: Context): FillRule =
  cairo_get_fill_rule(cr.impl)
proc getLineWidth*(cr: Context): float64 =
  cairo_get_line_width(cr.impl)
proc getLineCap*(cr: Context): LineCap =
  cairo_get_line_cap(cr.impl)
proc getLineJoin*(cr: Context): LineJoin =
  cairo_get_line_join(cr.impl)
proc getMiterLimit*(cr: Context): float64 =
  cairo_get_miter_limit(cr.impl)
proc getDashCount*(cr: Context): int32 =
  cairo_get_dash_count(cr.impl)
proc getDash*(cr: Context, dashes, offset: var float64) =
  cairo_get_dash(cr.impl, dashes, offset)
proc getMatrix*(cr: Context): Matrix =
  cairo_get_matrix(cr.impl, result)
proc getTarget*(cr: Context): Surface =
  result = Surface(impl: cairo_get_target(cr.impl))
proc getGroupTarget*(cr: Context): Surface =
  result = Surface(impl: cairo_get_group_target(cr.impl))
proc copyPath*(cr: Context): Path =
  cairo_copy_path(cr.impl)
proc copyPathFlat*(cr: Context): Path =
  cairo_copy_path_flat(cr.impl)
proc appendPath*(cr: Context, path: Path) =
  cairo_append_path(cr.impl, path)
# Surface manipulation
proc surfaceCreateSimilar*(other: Surface, content: Content, width, height: int32): Surface =
  result = Surface(impl: cairo_surface_create_similar(other, content, width, height))
proc getType*(surface: Surface): SurfaceType =
  cairo_surface_get_type(surface.impl)
proc getContent*(surface: Surface): Content =
  cairo_surface_get_content(surface.impl)
proc writeToPng*(surface: Surface, filename: string) =
  checkStatus cairo_surface_write_to_png(surface.impl, filename), [NoMemory, SurfaceTypeMismatch, WriteError, PngError]
proc writeToPng*(surface: Surface, writeFunc: WriteFunc, closure: pointer) =
  checkStatus cairo_surface_write_to_png_stream(surface.impl, writeFunc, closure), [NoMemory, SurfaceTypeMismatch, PngError]
proc getUserData*(surface: Surface, key: UserDataKey): pointer =
  cairo_surface_get_user_data(surface.impl, key)
proc setUserData*(surface: Surface, key: UserDataKey, userData: pointer, destroy: DestroyFunc) =
  checkStatus cairo_surface_set_user_data(surface.impl, key, userData, destroy), [NoMemory]
proc getFontOptions*(surface: Surface): FontOptions =
  result = fontOptionsCreate()
  cairo_surface_get_font_options(surface.impl, result.impl)
proc flush*(surface: Surface) =
  cairo_surface_flush(surface.impl)
proc markDirty*(surface: Surface) =
  cairo_surface_mark_dirty(surface.impl)
proc markDirtyRectangle*(surface: Surface, x, y, width, height: int32) =
  cairo_surface_mark_dirty_rectangle(surface.impl, x, y, width, height)
proc setDeviceOffset*(surface: Surface, xOffset, yOffset: float64) =
  cairo_surface_set_device_offset(surface.impl, xOffset, yOffset)
proc getDeviceOffset*(surface: Surface, xOffset, yOffset: var float64) =
  cairo_surface_get_device_offset(surface.impl, xOffset, yOffset)
proc setFallbackResolution*(surface: Surface, xPixelsPerInch, yPixelsPerInch: float64) =
  cairo_surface_set_fallback_resolution(surface.impl, xPixelsPerInch, yPixelsPerInch)
# Image-surface functions
proc imageSurfaceCreate*(format: Format, width, height: int32): Surface =
  result = Surface(impl: cairo_image_surface_create(format, width, height))
proc imageSurfaceCreate*(data: string, format: Format, width, height, stride: int32): Surface =
  result = Surface(impl: cairo_image_surface_create_for_data(data, format, width, height, stride))
proc getData*(surface: Surface): string =
  $cairo_image_surface_get_data(surface.impl)
proc getFormat*(surface: Surface): Format =
  cairo_image_surface_get_format(surface.impl)
proc getWidth*(surface: Surface): int32 =
  cairo_image_surface_get_width(surface.impl)
proc getHeight*(surface: Surface): int32 =
  cairo_image_surface_get_height(surface.impl)
proc getStride*(surface: Surface): int32 =
  cairo_image_surface_get_stride(surface.impl)
proc imageSurfaceCreateFromPng*(filename: string): Surface =
  result = Surface(impl: cairo_image_surface_create_from_png(filename))
proc imageSurfaceCreateFromPng*(readFunc: ReadFunc, closure: pointer): Surface =
  result = Surface(impl: cairo_image_surface_create_from_png_stream(readFunc, closure))
# Pattern creation functions
proc patternCreateRgb*(red, green, blue: float64): Pattern =
  result = Pattern(impl: cairo_pattern_create_rgb(red, green, blue))
proc patternCreateRgba*(red, green, blue, alpha: float64): Pattern =
  result = Pattern(impl: cairo_pattern_create_rgba(red, green, blue, alpha))
proc patternCreateForSurface*(surface: Surface): Pattern =
  result = Pattern(impl: cairo_pattern_create_for_surface(surface.impl))
proc patternCreateLinear*(x0, y0, x1, y1: float64): Pattern =
  result = Pattern(impl: cairo_pattern_create_linear(x0, y0, x1, y1))
proc patternCreateRadial*(cx0, cy0, radius0, cx1, cy1, radius1: float64): Pattern =
  result = Pattern(impl: cairo_pattern_create_radial(cx0, cy0, radius0, cx1, cy1, radius1))
proc getUserData*(pattern: Pattern, key: UserDataKey): pointer =
  cairo_pattern_get_user_data(pattern.impl, key)
proc setUserData*(pattern: Pattern, key: UserDataKey, userData: pointer, destroy: DestroyFunc) =
  checkStatus cairo_pattern_set_user_data(pattern.impl, key, userData, destroy), [NoMemory]
proc getType*(pattern: Pattern): PatternType =
  cairo_pattern_get_type(pattern.impl)
proc addColorStopRgb*(pattern: Pattern, offset, red, green, blue: float64) =
  cairo_pattern_add_color_stop_rgb(pattern.impl, offset, red, green, blue)
proc addColorStopRgba*(pattern: Pattern, offset, red, green, blue, alpha: float64) =
  cairo_pattern_add_color_stop_rgba(pattern.impl, offset, red, green, blue, alpha)
proc setMatrix*(pattern: Pattern, matrix: Matrix) =
  cairo_pattern_set_matrix(pattern.impl, matrix)
proc getMatrix*(pattern: Pattern): Matrix =
  cairo_pattern_get_matrix(pattern.impl, result)
proc setExtend*(pattern: Pattern, extend: Extend) =
  cairo_pattern_set_extend(pattern.impl, extend)
proc getExtend*(pattern: Pattern): Extend =
  cairo_pattern_get_extend(pattern.impl)
proc setFilter*(pattern: Pattern, filter: Filter) =
  cairo_pattern_set_filter(pattern.impl, filter)
proc getFilter*(pattern: Pattern): Filter =
  cairo_pattern_get_filter(pattern.impl)
proc getRgba*(pattern: Pattern, red, green, blue, alpha: var float64) =
  checkStatus cairo_pattern_get_rgba(pattern.impl, red, green, blue, alpha), [PatternTypeMismatch]
proc getSurface*(pattern: Pattern, surface: Surface) =
  checkStatus cairo_pattern_get_surface(pattern.impl, surface.impl), [PatternTypeMismatch]
proc getColorStopRgba*(pattern: Pattern, index: int32, offset, red, green, blue, alpha: var float64) =
  checkStatus cairo_pattern_get_color_stop_rgba(index, offset, red, green, blue, alpha), [InvalidIndex, PatternTypeMismatch]
proc getColorStopCount*(pattern: Pattern, count: var int32) =
  checkStatus cairo_pattern_get_color_stop_count(pattern.impl, count), [PatternTypeMismatch]
proc getLinearPoints*(pattern: Pattern, x0, y0, x1, y1: var float64) =
  checkStatus cairo_pattern_get_linear_points(pattern.impl, x0, y0, x1, y1), [PatternTypeMismatch]
proc getRadialCircles*(pattern: Pattern, x0, y0, r0, x1, y1, r1: var float64) =
  checkStatus cairo_pattern_get_radial_circles(x0, y0, r0, x1, y1, r1), [PatternTypeMismatch]
# Matrix functions
proc initMatrix*(xx, yx, xy, yy, x0, y0: float64): Matrix =
  cairo_matrix_init(result, xx, yx, xy, yy, x0, y0)
proc initIdentity*(): Matrix =
  cairo_matrix_init_identity(result)
proc initTranslate*(tx, ty: float64): Matrix =
  cairo_matrix_init_translate(result, tx, ty)
proc initScale*(sx, sy: float64): Matrix =
  cairo_matrix_init_scale(result, sx, sy)
proc initRotate*(radians: float64): Matrix =
  cairo_matrix_init_rotate(result, radians)
proc translate*(matrix: var Matrix, tx, ty: float64) =
  cairo_matrix_translate(matrix, tx, ty)
proc scale*(matrix: var Matrix, sx, sy: float64) =
  cairo_matrix_scale(matrix, sx, sy)
proc rotate*(matrix: var Matrix, radians: float64) =
  cairo_matrix_rotate(matrix, radians)
proc invert*(matrix: var Matrix) =
  checkStatus cairo_matrix_invert(matrix), [InvalidMatrix]
proc multiply*(a, b: Matrix): Matrix =
  cairo_matrix_multiply(result, a, b)
proc transformDistance*(matrix: Matrix, dx, dy: var float64) =
  cairo_matrix_transform_distance(matrix, dx, dy)
proc transformPoint*(matrix: Matrix, x, y: var float64) =
  cairo_matrix_transform_point(matrix, x, y)
# PDF functions
proc pdfSurfaceCreate*(filename: string, widthInPoints, heightInPoints: float64): Surface =
  result = Surface(impl: cairo_pdf_surface_create(filename, widthInPoints, heightInPoints))
proc pdfSurfaceCreateForStream*(writeFunc: WriteFunc, closure: pointer, widthInPoints, heightInPoints: float64): Surface =
  result = Surface(impl: cairo_pdf_surface_create_for_stream(writeFunc, closure, widthInPoints, heightInPoints))
proc pdfSurfaceSetSize*(surface: Surface, widthInPoints, heightInPoints: float64) =
  cairo_pdf_surface_set_size(surface.impl, widthInPoints, heightInPoints)
# PS functions
proc psSurfaceCreate*(filename: string, widthInPoints, heightInPoints: float64): Surface =
  result = Surface(impl: cairo_ps_surface_create(filename, widthInPoints, heightInPoints))
proc psSurfaceCreateForStream*(writeFunc: WriteFunc, closure: pointer, widthInPoints, heightInPoints: float64): Surface =
  result = Surface(impl: cairo_ps_surface_create_for_stream(writeFunc, closure, widthInPoints, heightInPoints))
proc psSurfaceSetSize*(surface: Surface, widthInPoints, heightInPoints: float64) =
  cairo_ps_surface_set_size(surface.impl, widthInPoints, heightInPoints)
proc psSurfaceDscComment*(surface: Surface, comment: string) =
  cairo_ps_surface_dsc_comment(surface.impl, comment)
proc psSurfaceDscBeginSetup*(surface: Surface) =
  cairo_ps_surface_dsc_begin_setup(surface.impl)
proc psSurfaceDscBeginPageSetup*(surface: Surface) =
  cairo_ps_surface_dsc_begin_page_setup(surface.impl)
# SVG functions
proc svgSurfaceCreate*(filename: string, widthInPoints, heightInPoints: float64): Surface =
  result = Surface(impl: cairo_svg_surface_create(filename, widthInPoints, heightInPoints))
proc svgSurfaceCreateForStream*(writeFunc: WriteFunc, closure: pointer, widthInPoints, heightInPoints: float64): Surface =
  result = Surface(impl: cairo_svg_surface_create_for_stream(writeFunc, closure, widthInPoints, heightInPoints))
proc svgSurfaceRestrictToVersion*(surface: Surface, version: SvgVersion) =
  cairo_svg_surface_restrict_to_version(surface.impl, version)
  #todo: see how translate this
  #procedure cairo_svg_get_versions(TCairoSvgVersion const **versions, # int *num_versions);
proc svgVersionToString*(version: SvgVersion): string =
  $cairo_svg_version_to_string(version)
# Functions to be used while debugging (not intended for use in production code)
proc debugResetStaticData*() =
  cairo_debug_reset_static_data()
# new since 1.10
proc surfaceCreateForRectangle*(target: Surface, x, y, w, h: float64): Surface =
  result = Surface(impl: cairo_surface_create_for_rectangle(target.impl, x, y, w, h))

proc version*(major, minor, micro: var int32) =
  var version: int32
  version = version()
  major = version div 10000'i32
  minor = (version mod (major * 10000'i32)) div 100'i32
  micro = (version mod ((major * 10000'i32) + (minor * 100'i32)))
