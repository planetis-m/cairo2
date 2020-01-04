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

proc `=`(cr: var Context, original: Context) {.error.}
proc `=destroy`(cr: var Context) =
  if cr.impl != nil:
    assert cairo_get_reference_count(cr.impl) == 0, "dangling pointers exist!"
    cairo_destroy(cr.impl)
    cr.impl = nil
proc `=sink`(cr: var Context; original: Context) =
  `=destroy`(cr)
  cr.impl = original.impl

proc `=`(options: var FontOptions, original: FontOptions) =
  options.impl = cairo_font_options_copy(original.impl)
proc `=destroy`(options: var FontOptions) =
  if options.impl != nil:
    cairo_font_options_destroy(options)
    options.impl = nil
proc `=sink`(options: var Context; original: Context) =
  `=destroy`(options)
  options.impl = original.impl

proc `=`(font_face: var FontFace, original: FontFace) {.error.}
proc `=destroy`(font_face: var FontFace) =
  if font_face.impl != nil:
    assert cairo_font_face_get_reference_count(font_face.impl) == 0, "dangling pointers exist!"
    cairo_font_face_destroy(font_face.impl)
    font_face.impl = nil
proc `=sink`(font_face: var FontFace; original: FontFace) =
  `=destroy`(font_face)
  font_face.impl = original.impl

proc `=`(scaled_font: var ScaledFont, original: ScaledFont) {.error.}
proc `=destroy`(scaled_font: var ScaledFont) =
  if scaled_font.impl != nil:
    assert cairo_scaled_font_get_reference_count(scaled_font.impl) == 0, "dangling pointers exist!"
    cairo_scaled_font_destroy(scaled_font.impl)
    scaled_font.impl = nil
proc `=sink`(scaled_font: var ScaledFont; original: ScaledFont) =
  `=destroy`(scaled_font)
  scaled_font.impl = original.impl

proc `=`(surface: var Surface, original: Surface) {.error.}
proc `=destroy`(surface: var Surface) =
  if surface.impl != nil:
    assert cairo_surface_get_reference_count(surface.impl) == 0, "dangling pointers exist!"
    cairo_surface_destroy(surface.impl)
    surface.impl = nil
proc `=sink`(surface: var Surface; original: Surface) =
  `=destroy`(surface)
  surface.impl = original.impl

proc `=`(pattern: var Pattern, original: Pattern) {.error.}
proc `=destroy`(pattern: var Pattern) =
  if pattern.impl != nil:
    assert cairo_pattern_get_reference_count(pattern.impl) == 0, "dangling pointers exist!"
    cairo_pattern_destroy(pattern.impl)
    pattern.impl = nil
proc `=sink`(pattern: var Pattern; original: Pattern) =
  `=destroy`(pattern)
  pattern.impl = original.impl

proc checkStatus*(s: Status)

proc version*(): int32 =
  cairo_version()
proc versionString*(): cstring =
  cairo_version_string()
proc create*(target: Surface): Context =
  cairo_create(target.impl)
proc getUserData*(cr: Context, key: UserDataKey): pointer =
  cairo_get_user_data(cr.impl, key)
proc setUserData*(cr: Context, key: UserDataKey, user_data: pointer, destroy: DestroyFunc): Status =
  cairo_set_user_data(cr.impl, key, user_data, destroy)
proc save*(cr: Context) =
  cairo_save(cr.impl)
proc restore*(cr: Context) =
  cairo_restore(cr.impl)
proc pushGroup*(cr: Context) =
  cairo_push_group(cr.impl)
proc pushGroupWithContent*(cr: Context, content: Content) =
  cairo_push_group_with_content(cr.impl, content)
proc popGroup*(cr: Context): Pattern =
  cairo_pop_group(cr.impl)
proc popGroupToSource*(cr: Context) =
  cairo_pop_group_to_source(cr.impl)
# Modify state
proc setOperator*(cr: Context, op: Operator) =
  cairo_set_operator(cr.impl, op)
proc setSource*(cr: Context, source: Pattern) =
  cairo_set_source(cr.impl, source)
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
proc setFillRule*(cr: Context, fill_rule: FillRule) =
  cairo_set_fill_rule(cr.impl, fill_rule)
proc setLineWidth*(cr: Context, width: float64) =
  cairo_set_line_width(cr.impl, width)
proc setLineCap*(cr: Context, line_cap: LineCap) =
  cairo_set_line_cap(cr.impl, line_cap)
proc setLineJoin*(cr: Context, line_join: LineJoin) =
  cairo_set_line_join(cr.impl, line_join)
proc setDash*(cr: Context, dashes: openarray[float64], offset: float64) =
  cairo_set_dash(cr: Context, dashes: openarray[float64], offset: float64)
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
  cairo_curve_to(cr: Context, x1, y1, x2, y2, x3, y3: float64)
proc arc*(cr: Context, xc, yc, radius, angle1, angle2: float64) =
  cairo_arc(cr.impl, xc, yc, radius, angle1, angle2)
proc arcNegative*(cr: Context, xc, yc, radius, angle1, angle2: float64) =
  cairo_arc_negative(cr.impl, xc, yc, radius, angle1, angle2)
proc relMoveTo*(cr: Context, dx, dy: float64) =
  cairo_rel_move_to(cr.impl, dx, dy)
proc relLineTo*(cr: Context, dx, dy: float64) =
  cairo_rel_line_to(cr.impl, dx, dy)
proc relCurveTo*(cr: Context, dx1, dy1, dx2, dy2, dx3, dy3: float64) =
  cairo_rel_curve_to(cr: Context, dx1, dy1, dx2, dy2, dx3, dy3: float64)
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
proc mask*(cr: Context, surface: Surface, surface_x, surface_y: float64) =
  cairo_mask_surface(cr.impl, surface.impl, surface_x, surface_y)
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
  cairo_in_stroke(cr.impl, x, y) == 1
proc inFill*(cr: Context, x, y: float64): bool =
  cairo_in_fill(cr.impl, x, y) == 1
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
  cairo_font_options_create()
proc status*(options: FontOptions): Status =
  cairo_font_options_status(options)
proc merge*(options, other: FontOptions) =
  cairo_font_options_merge(options, other)
proc equal*(options, other: FontOptions): bool =
  cairo_font_options_equal(options, other) == 1
proc hash*(options: FontOptions): int32 =
  cairo_font_options_hash(options)
proc setAntialias*(options: FontOptions, antialias: Antialias) =
  cairo_font_options_set_antialias(options, antialias)
proc getAntialias*(options: FontOptions): Antialias =
  cairo_font_options_get_antialias(options)
proc setSubpixelOrder*(options: FontOptions, subpixel_order: SubpixelOrder) =
  cairo_font_options_set_subpixel_order(options, subpixel_order)
proc getSubpixelOrder*(options: FontOptions): SubpixelOrder =
  cairo_font_options_get_subpixel_order(options)
proc setHintStyle*(options: FontOptions, hint_style: HintStyle) =
  cairo_font_options_set_hint_style(options, hint_style)
proc getHintStyle*(options: FontOptions): HintStyle =
  cairo_font_options_get_hint_style(options)
proc setHintMetrics*(options: FontOptions, hint_metrics: HintMetrics) =
  cairo_font_options_set_hint_metrics(options, hint_metrics)
proc getHintMetrics*(options: FontOptions): HintMetrics =
  cairo_font_options_get_hint_metrics(options)
# This interface is for dealing with text as text, not caring about the
  #   font object inside the the TCairo.
proc selectFontFace*(cr: Context, family: cstring, slant: FontSlant, weight: FontWeight) =
  cairo_select_font_face(cr.impl, family, slant, weight)
proc setFontSize*(cr: Context, size: float64) =
  cairo_set_font_size(cr.impl, size)
proc setFontMatrix*(cr: Context, matrix: Matrix) =
  cairo_set_font_matrix(cr.impl, matrix)
proc getFontMatrix*(cr: Context, matrix: Matrix) =
  cairo_get_font_matrix(cr.impl, matrix)
proc setFontOptions*(cr: Context, options: FontOptions) =
  cairo_set_font_options(cr.impl, options)
proc getFontOptions*(cr: Context, options: FontOptions) =
  cairo_get_font_options(cr.impl, options)
proc setFontFace*(cr: Context, font_face: FontFace) =
  cairo_set_font_face(cr.impl, font_face.impl)
proc getFontFace*(cr: Context): FontFace =
  cairo_get_font_face(cr.impl)
proc setScaledFont*(cr: Context, scaled_font: ScaledFont) =
  cairo_set_scaled_font(cr.impl, scaled_font.impl)
proc getScaledFont*(cr: Context): ScaledFont =
  cairo_get_scaled_font(cr.impl)
proc showText*(cr: Context, utf8: cstring) =
  cairo_show_text(cr.impl, utf8)
proc showGlyphs*(cr: Context, glyphs: Glyph, num_glyphs: int32) =
  cairo_show_glyphs(cr.impl, glyphs, num_glyphs)
proc textPath*(cr: Context, utf8: cstring) =
  cairo_text_path(cr.impl, utf8)
proc glyphPath*(cr: Context, glyphs: Glyph, num_glyphs: int32) =
  cairo_glyph_path(cr.impl, glyphs, num_glyphs)
proc textExtents*(cr: Context, utf8: cstring, extents: TextExtents) =
  cairo_text_extents(cr.impl, utf8, extents)
proc glyphExtents*(cr: Context, glyphs: Glyph, num_glyphs: int32, extents: TextExtents) =
  cairo_glyph_extents(cr.impl, glyphs, num_glyphs, extents)
proc fontExtents*(cr: Context, extents: FontExtents) =
  cairo_font_extents(cr.impl, extents)
# Generic identifier for a font style
proc status*(font_face: FontFace): Status =
  cairo_font_face_status(font_face.impl)
proc getType*(font_face: FontFace): FontType =
  cairo_font_face_get_type(font_face.impl)
proc getUserData*(font_face: FontFace, key: UserDataKey): pointer =
  cairo_font_face_get_user_data(font_face.impl, key)
proc setUserData*(font_face: FontFace, key: UserDataKey, user_data: pointer, destroy: DestroyFunc): Status =
  cairo_font_face_set_user_data(font_face.impl, key, user_data, destroy)
# Portable interface to general font features
proc scaledFontCreate*(font_face: FontFace, font_matrix: Matrix, ctm: Matrix, options: FontOptions): ScaledFont =
  cairo_scaled_font_create(font_face.impl, font_matrix, ctm, options)
proc status*(scaled_font: ScaledFont): Status =
  cairo_scaled_font_status(scaled_font.impl)
proc getType*(scaled_font: ScaledFont): FontType =
  cairo_scaled_font_get_type(scaled_font.impl)
proc getUserData*(scaled_font: ScaledFont, key: UserDataKey): pointer =
  cairo_scaled_font_get_user_data(scaled_font.impl, key)
proc setUserData*(scaled_font: ScaledFont, key: UserDataKey, user_data: pointer, destroy: DestroyFunc): Status =
  cairo_scaled_font_set_user_data(scaled_font.impl, key, user_data, destroy)
proc extents*(scaled_font: ScaledFont, extents: FontExtents) =
  cairo_scaled_font_extents(scaled_font.impl, extents)
proc textExtents*(scaled_font: ScaledFont, utf8: cstring, extents: TextExtents) =
  cairo_scaled_font_text_extents(scaled_font.impl, utf8, extents)
proc glyphExtents*(scaled_font: ScaledFont, glyphs: Glyph, num_glyphs: int32, extents: TextExtents) =
  cairo_scaled_font_glyph_extents(scaled_font.impl, glyphs, num_glyphs, extents)
proc getFontFace*(scaled_font: ScaledFont): FontFace =
  cairo_scaled_font_get_font_face(scaled_font.impl)
proc getFontMatrix*(scaled_font: ScaledFont, font_matrix: Matrix) =
  cairo_scaled_font_get_font_matrix(scaled_font.impl, font_matrix)
proc getCtm*(scaled_font: ScaledFont, ctm: Matrix) =
  cairo_scaled_font_get_ctm(scaled_font.impl, ctm)
proc getFontOptions*(scaled_font: ScaledFont, options: FontOptions) =
  cairo_scaled_font_get_font_options(scaled_font.impl, options)
# Query functions
proc getOperator*(cr: Context): Operator =
  cairo_get_operator(cr.impl)
proc getSource*(cr: Context): Pattern =
  cairo_get_source(cr.impl)
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
proc getMatrix*(cr: Context, matrix: Matrix) =
  cairo_get_matrix(cr.impl, matrix)
proc getTarget*(cr: Context): Surface =
  cairo_get_target(cr.impl)
proc getGroupTarget*(cr: Context): Surface =
  cairo_get_group_target(cr.impl)
proc copyPath*(cr: Context): Path =
  cairo_copy_path(cr.impl)
proc copyPathFlat*(cr: Context): Path =
  cairo_copy_path_flat(cr.impl)
proc appendPath*(cr: Context, path: Path) =
  cairo_append_path(cr.impl, path)
# Error status queries
proc status*(cr: Context): Status =
  cairo_status(cr.impl)
proc statusToString*(status: Status): string =
  $cairo_status_to_string(status)
# Surface manipulation
proc surfaceCreateSimilar*(other: Surface, content: Content, width, height: int32): Surface =
  cairo_surface_create_similar(other, content, width, height)
proc status*(surface: Surface): Status =
  cairo_surface_status(surface.impl)
proc getType*(surface: Surface): SurfaceType =
  cairo_surface_get_type(surface.impl)
proc getContent*(surface: Surface): Content =
  cairo_surface_get_content(surface.impl)
proc writeToPng*(surface: Surface, filename: string) =
  checkStatus cairo_surface_write_to_png(surface.impl, filename)
proc writeToPng*(surface: Surface, write_func: WriteFunc, closure: pointer) =
  checkStatus cairo_surface_write_to_png_stream(surface.impl, write_func, closure)
proc getUserData*(surface: Surface, key: UserDataKey): pointer =
  cairo_surface_get_user_data(surface.impl, key)
proc setUserData*(surface: Surface, key: UserDataKey, user_data: pointer, destroy: DestroyFunc): Status =
  cairo_surface_set_user_data(surface.impl, key, user_data, destroy)
proc getFontOptions*(surface: Surface, options: FontOptions) =
  cairo_surface_get_font_options(surface.impl, options)
proc flush*(surface: Surface) =
  cairo_surface_flush(surface.impl)
proc markDirty*(surface: Surface) =
  cairo_surface_mark_dirty(surface.impl)
proc markDirtyRectangle*(surface: Surface, x, y, width, height: int32) =
  cairo_surface_mark_dirty_rectangle(surface.impl, x, y, width, height)
proc setDeviceOffset*(surface: Surface, x_offset, y_offset: float64) =
  cairo_surface_set_device_offset(surface.impl, x_offset, y_offset)
proc getDeviceOffset*(surface: Surface, x_offset, y_offset: var float64) =
  cairo_surface_get_device_offset(surface.impl, x_offset, y_offset)
proc setFallbackResolution*(surface: Surface, x_pixels_per_inch, y_pixels_per_inch: float64) =
  cairo_surface_set_fallback_resolution(surface.impl, x_pixels_per_inch, y_pixels_per_inch)
# Image-surface functions
proc imageSurfaceCreate*(format: Format, width, height: int32): Surface =
  cairo_image_surface_create(format, width, height)
proc imageSurfaceCreate*(data: cstring, format: Format, width, height, stride: int32): Surface =
  cairo_image_surface_create_for_data(data: cstring, format: Format, width, height, stride: int32)
proc getData*(surface: Surface): cstring =
  cairo_image_surface_get_data(surface.impl)
proc getFormat*(surface: Surface): Format =
  cairo_image_surface_get_format(surface.impl)
proc getWidth*(surface: Surface): int32 =
  cairo_image_surface_get_width(surface.impl)
proc getHeight*(surface: Surface): int32 =
  cairo_image_surface_get_height(surface.impl)
proc getStride*(surface: Surface): int32 =
  cairo_image_surface_get_stride(surface.impl)
proc imageSurfaceCreateFromPng*(filename: cstring): Surface =
  cairo_image_surface_create_from_png(filename)
proc imageSurfaceCreateFromPng*(read_func: ReadFunc, closure: pointer): Surface =
  cairo_image_surface_create_from_png_stream(read_func, closure)
# Pattern creation functions
proc patternCreateRgb*(red, green, blue: float64): Pattern =
  cairo_pattern_create_rgb(red, green, blue)
proc patternCreateRgba*(red, green, blue, alpha: float64): Pattern =
  cairo_pattern_create_rgba(red, green, blue, alpha)
proc patternCreateForSurface*(surface: Surface): Pattern =
  cairo_pattern_create_for_surface(surface.impl)
proc patternCreateLinear*(x0, y0, x1, y1: float64): Pattern =
  cairo_pattern_create_linear(x0, y0, x1, y1)
proc patternCreateRadial*(cx0, cy0, radius0, cx1, cy1, radius1: float64): Pattern =
  cairo_pattern_create_radial(cx0, cy0, radius0, cx1, cy1, radius1)
proc status*(pattern: Pattern): Status =
  cairo_pattern_status(pattern.impl)
proc getUserData*(pattern: Pattern, key: UserDataKey): pointer =
  cairo_pattern_get_user_data(pattern.impl, key)
proc setUserData*(pattern: Pattern, key: UserDataKey, user_data: pointer, destroy: DestroyFunc): Status =
  cairo_pattern_set_user_data(pattern.impl, key, user_data, destroy)
proc getType*(pattern: Pattern): PatternType =
  cairo_pattern_get_type(pattern.impl)
proc addColorStopRgb*(pattern: Pattern, offset, red, green, blue: float64) =
  cairo_pattern_add_color_stop_rgb(pattern.impl, offset, red, green, blue)
proc addColorStopRgba*(pattern: Pattern, offset, red, green, blue, alpha: float64) =
  cairo_pattern_add_color_stop_rgba(pattern.impl, offset, red, green, blue, alpha)
proc setMatrix*(pattern: Pattern, matrix: Matrix) =
  cairo_pattern_set_matrix(pattern.impl, matrix)
proc getMatrix*(pattern: Pattern, matrix: Matrix) =
  cairo_pattern_get_matrix(pattern.impl, matrix)
proc setExtend*(pattern: Pattern, extend: Extend) =
  cairo_pattern_set_extend(pattern.impl, extend)
proc getExtend*(pattern: Pattern): Extend =
  cairo_pattern_get_extend(pattern.impl)
proc setFilter*(pattern: Pattern, filter: Filter) =
  cairo_pattern_set_filter(pattern.impl, filter)
proc getFilter*(pattern: Pattern): Filter =
  cairo_pattern_get_filter(pattern.impl)
proc getRgba*(pattern: Pattern, red, green, blue, alpha: var float64): Status =
  cairo_pattern_get_rgba(pattern.impl, red, green, blue, alpha)
proc getSurface*(pattern: Pattern, surface: Surface): Status =
  cairo_pattern_get_surface(pattern.impl, surface.impl)
proc getColorStopRgba*(pattern: Pattern, index: int32, offset, red, green, blue, alpha: var float64): Status =
  cairo_pattern_get_color_stop_rgba(index, offset, red, green, blue, alpha)
proc getColorStopCount*(pattern: Pattern, count: var int32): Status =
  cairo_pattern_get_color_stop_count(pattern.impl, count)
proc getLinearPoints*(pattern: Pattern, x0, y0, x1, y1: var float64): Status =
  cairo_pattern_get_linear_points(pattern.impl, x0, y0, x1, y1)
proc getRadialCircles*(pattern: Pattern, x0, y0, r0, x1, y1, r1: var float64): Status =
  cairo_pattern_get_radial_circles(x0, y0, r0, x1, y1, r1)
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
  checkStatus cairo_matrix_invert(matrix)
proc multiply*(a, b: Matrix): Matrix =
  cairo_matrix_multiply(result, a, b)
proc transformDistance*(matrix: Matrix, dx, dy: var float64) =
  cairo_matrix_transform_distance(matrix, dx, dy)
proc transformPoint*(matrix: Matrix, x, y: var float64) =
  cairo_matrix_transform_point(matrix, x, y)
# PDF functions
proc pdfSurfaceCreate*(filename: cstring, width_in_points, height_in_points: float64): Surface =
  cairo_pdf_surface_create(filename, width_in_points, height_in_points)
proc pdfSurfaceCreateForStream*(write_func: WriteFunc, closure: pointer, width_in_points, height_in_points: float64): Surface =
  cairo_pdf_surface_create_for_stream(write_func, closure, width_in_points, height_in_points)
proc pdfSurfaceSetSize*(surface: Surface, width_in_points, height_in_points: float64) =
  cairo_pdf_surface_set_size(surface.impl, width_in_points, height_in_points)
# PS functions
proc psSurfaceCreate*(filename: cstring, width_in_points, height_in_points: float64): Surface =
  cairo_ps_surface_create(filename, width_in_points, height_in_points)
proc psSurfaceCreateForStream*(write_func: WriteFunc, closure: pointer, width_in_points, height_in_points: float64): Surface =
  cairo_ps_surface_create_for_stream(write_func, closure, width_in_points, height_in_points)
proc psSurfaceSetSize*(surface: Surface, width_in_points, height_in_points: float64) =
  cairo_ps_surface_set_size(surface.impl, width_in_points, height_in_points)
proc psSurfaceDscComment*(surface: Surface, comment: cstring) =
  cairo_ps_surface_dsc_comment(surface.impl, comment)
proc psSurfaceDscBeginSetup*(surface: Surface) =
  cairo_ps_surface_dsc_begin_setup(surface.impl)
proc psSurfaceDscBeginPageSetup*(surface: Surface) =
  cairo_ps_surface_dsc_begin_page_setup(surface.impl)
# SVG functions
proc svgSurfaceCreate*(filename: cstring, width_in_points, height_in_points: float64): Surface =
  cairo_svg_surface_create(filename, width_in_points, height_in_points)
proc svgSurfaceCreateForStream*(write_func: WriteFunc, closure: pointer, width_in_points, height_in_points: float64): Surface =
  cairo_svg_surface_create_for_stream(write_func, closure, width_in_points, height_in_points)
proc svgSurfaceRestrictToVersion*(surface: Surface, version: SvgVersion) =
  cairo_svg_surface_restrict_to_version(surface.impl, version)
  #todo: see how translate this
  #procedure cairo_svg_get_versions(TCairoSvgVersion const **versions, # int *num_versions);
proc svgVersionToString*(version: SvgVersion): cstring =
  cairo_svg_version_to_string(version)
# Functions to be used while debugging (not intended for use in production code)
proc debugResetStaticData*() =
  cairo_debug_reset_static_data()
# new since 1.10
proc surfaceCreateForRectangle*(target: Surface, x,y,w,h: float64): Surface =
  cairo_surface_create_for_rectangle(target.impl, x, y, w, h)

proc version*(major, minor, micro: var int32) =
  var version: int32
  version = version()
  major = version div 10000'i32
  minor = (version mod (major * 10000'i32)) div 100'i32
  micro = (version mod ((major * 10000'i32) + (minor * 100'i32)))

proc checkStatus*(s: Status) {.noinline.} =
  ## if ``s != StatusSuccess`` the error is turned into an appropirate Nim
  ## exception and raised.
  case s
  of StatusSuccess: discard
  of StatusNoMemory:
    raise newException(OutOfMemError, statusToString(s))
  of StatusReadError, StatusWriteError, StatusFileNotFound,
     StatusTempFileError:
    raise newException(IOError, statusToString(s))
  else:
    raise newException(AssertionError, statusToString(s))