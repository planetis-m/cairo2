import cairo2, math

let
   surface = imageSurfaceCreate(FormatArgb32, 512, 512)
   ctx = surface.create()

var
   xc = 256.0
   yc = 256.0
   radius = 100.0
   angle1 = 45.0 * Pi / 180.0 # angles are specified in radians
   angle2 = 180.0 * Pi / 180.0

ctx.setLineWidth(10.0)
ctx.arc(xc, yc, radius, angle1, angle2)
ctx.stroke()

# draw helping lines
ctx.setSourceRgba(1.0, 0.2, 0.2, 0.6)
ctx.setLineWidth(6.0)

ctx.arc(xc, yc, 10.0, 0, 2.0 * Pi)
ctx.fill()

ctx.arc(xc, yc, radius, angle1, angle1)
ctx.lineTo(xc, yc)
ctx.arc(xc, yc, radius, angle2, angle2)
ctx.lineTo(xc, yc)
ctx.stroke()

surface.writeToPng("arc.png")
