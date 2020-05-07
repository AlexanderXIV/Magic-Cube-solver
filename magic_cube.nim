import os, math, ../utils, ../render3

for i in 0..10:
  echo "\n"

# 0: oben, weiß
# 1: links, grün
# 2: hinten, rot
# 3: rechts, blau
# 4: vorne, orange
# 5: unten, gelb

type
  Cube = array[6, array[9, Color]]

let
  optimal_fps = 60.0

  cube_max = 1.0
  cube_min = cube_max / 2
  module_distance = cube_max / 10

  window = new_window("Cube", resizable=true)

  black = rgb(0, 0, 0)
  red = rgb(1, 0, 0)
  white = rgb(0.95, 0.95, 0.95)
  green = rgb(0, 1, 0)
  blue = rgb(0, 0, 1)
  orange = rgb(1, 0.5, 0)
  yellow = rgb(1, 1, 0)

  face = Mesh()

var
  s = 0.0
  d = module_distance

  cont = new_orbit_camera_controller()
  ren = new_render3(window)
  stats = Stats()
  is_running = true

face.add_quad(Vec3(x: -0.5, y: -0.5, z: 0), Vec3(x: 1), Vec3(y: 1))
face.add_quad(Vec3(x: -0.5, y: -0.5, z: 0), Vec3(y: 1), Vec3(x: 1))

var cube: Cube
for i in 0..<9:
  cube[0][i] = white
  cube[1][i] = green
  cube[2][i] = red
  cube[3][i] = blue
  cube[4][i] = orange
  cube[5][i] = yellow

# proc draw_x(cube: Cube, ren1: var Render3, height: float, angle: float, scale: float) =
#   let
#     rd = degToRad(-angle)
#     x1 = cos(rd) * (s + d)
#     y1 = sin(rd) * (s + d)

#   for item in @[(0.0, 0.0), (x1, y1), (-x1, -y1), (y1, -x1), (-y1, x1), (x1 + y1, y1 - x1), (-x1 - y1, x1 - y1), (y1 - x1, -x1 - y1), (x1 - y1, x1 + y1)]:
#     ren1.add(face, color = cube[0][0], pos = Vec3(x: item[0], y: height, z: item[1]), scale = scale, rot = new_quat(Vec3(y: 1), Deg(angle)) * new_quat(Vec3(x: 1), Deg(90)))

# proc draw_y(cube: Cube, ren1: var Render3, height: float, angle: float, scale: float) =
#   let
#     rd = degToRad(-angle)
#     x1 = cos(rd) * (s + d)
#     y1 = sin(rd) * (s + d)

#   for item in @[(0.0, 0.0), (x1, y1), (-x1, -y1), (y1, -x1), (-y1, x1), (x1 + y1, y1 - x1), (-x1 - y1, x1 - y1), (y1 - x1, -x1 - y1), (x1 - y1, x1 + y1)]:
#     ren1.add(face, color = cube[0][0], pos = Vec3(x: height, y: item[0], z: item[1]), scale = scale, rot = new_quat(Vec3(x: 1), Deg(angle)) * new_quat(Vec3(y: 1), Deg(90)))

# proc draw_z(cube: Cube, ren1: var Render3, height: float, angle: float, scale: float) =
#   let
#     rd = degToRad(-angle)
#     x1 = cos(rd) * (s + d)
#     y1 = sin(rd) * (s + d)

#   for item in @[(0.0, 0.0), (x1, y1), (-x1, -y1), (y1, -x1), (-y1, x1), (x1 + y1, y1 - x1), (-x1 - y1, x1 - y1), (y1 - x1, -x1 - y1), (x1 - y1, x1 + y1)]:
#     ren1.add(face, color = cube[0][0], pos = Vec3(x: item[1], y: item[0], z: height), scale = scale, rot = new_quat(Vec3(z: 1), Deg(angle)) * new_quat(Vec3(z: 1), Deg(90)))

var button_down = false
var change = true
var angle = 0.0

echo "starting"
while is_running:
  let x = window.poll()
  if x[1]: change = true
  for event in x[0]:
    case event.kind:
      of EventQuit:
        is_running = false
        break
      of EventWheel, EventMove:
        if cont.process(event):
          change = true
      of EventButtonDown:
        button_down = true
      of EventButtonUp:
        button_down = false
      else: discard#echo event

  var ready = true
  for item in stats.recent_fps:
    if item == 0.0:
      ready = false
      break;

  if ((button_down and s > cube_min) or (button_down == false and s < cube_max)) and ready:
    change = true
    if button_down and s > cube_min:
      s = s - 1 / stats.average_fps()
    else:
      s = s + 1 / stats.average_fps()
      if s > cube_max: s = cube_max
    d = 1.5 * (cube_max - s) + module_distance

  # ren.add(face, color = red)
  # ren.add(face, color = green, rot = new_quat(Vec3(y: 1), Deg(90)))
  # ren.add(face, color = blue, rot = new_quat(Vec3(x: 1), Deg(90)))

  if change or true:
    cont.update(ren.camera)

    ren.background(grey(1))

    for i1 in 0..<3:
      var z1 = (i1.float - 1) * (s + d)
      for i2 in 0..<3:
        var z2 = (i2.float - 1) * (s + d)

        for val in @[-(s / 2 + d), -s / 2, s / 2, s / 2 + d]:
          ren.add(face, color = black, pos = Vec3(x: z2, y: z1, z: val), scale = s)
          ren.add(face, color = black, pos = Vec3(x: val, y: z2, z: z1), scale = s, rot = new_quat(Vec3(y: 1), Deg(90)))
          ren.add(face, color = black, pos = Vec3(x: z1, y: val, z: z2), scale = s, rot = new_quat(Vec3(x: 1), Deg(90)))

        ren.add(face, color = cube[0][8 - (3 * i2 + i1)], pos = Vec3(x: z1, y: (1.5 * s + d), z: z2), scale = s, rot = new_quat(Vec3(x: 1), Deg(90)))
        ren.add(face, color = cube[1][8 - (3 * i1 + i2)], pos = Vec3(x: (1.5 * s + d), y: z2, z: z1), scale = s, rot = new_quat(Vec3(y: 1), Deg(90)))
        ren.add(face, color = cube[2][8 - (3 * i1 + (2 - i2))], pos = Vec3(x: z2, y: z1, z: -(1.5 * s + d)), scale = s)
        ren.add(face, color = cube[3][8 - (3 * i2 + (2 - i1))], pos = Vec3(x: -(1.5 * s + d), y: z2, z: z1), scale = s, rot = new_quat(Vec3(y: 1), Deg(90)))
        ren.add(face, color = cube[4][3 * i2 + i1], pos = Vec3(x: z2, y: z1, z: (1.5 * s + d)), scale = s)
        ren.add(face, color = cube[5][3 * (2 - i2) + i1], pos = Vec3(x: z1, y: -(1.5 * s + d), z: z2), scale = s, rot = new_quat(Vec3(x: 1), Deg(90)))

    ren.add(Light(kind: LightAmbient,
      ambient: 1
    ))

    ren.render(stats)
    window.swap()

    stdout.write("\rfps: " & $stats.average_fps().int & "\t")

  if change == false:
    sleep(1000 div optimal_fps.int)
  elif change and stats.average_fps() > optimal_fps:
    let fps = stats.average_fps() 
    sleep((1000 * (fps - optimal_fps) / (optimal_fps * fps)).int)
  change = false
