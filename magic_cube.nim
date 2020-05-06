import os, ../utils, ../render3

for i in 0..10:
  echo "\n"
# 0: oben, weiß
# 1: links, grün
# 2: hinten, rot
# 3: rechts, blau
# 4: vorne, orange
# 5: unten, gelb

let optimal_fps = 60.0

var
  s = 1.0
  d = 0.1
  sh = s / 2
  sd = 1.5 * s + d

type
  Cube = array[6, array[9, Color]]

let
  window = new_window("Cube", resizable=true)

  black = rgb(0, 0, 0)
  red = rgb(1, 0, 0)
  white = rgb(0.95, 0.95, 0.95)
  green = rgb(0, 1, 0)
  blue = rgb(0, 0, 1)
  orange = rgb(1, 0.5, 0)
  yellow = rgb(1, 1, 0)

var body1, body2, body3 = Mesh()

var
  cont = new_orbit_camera_controller()
  ren = new_render3(window)
  stats = Stats()
  is_running = true

body1.add_quad(Vec3(x: -sh, y: -sh, z: 0), Vec3(x: s), Vec3(y: s))
body2.add_quad(Vec3(x: 0, y: -sh, z: -sh), Vec3(y: s), Vec3(z: s))
body3.add_quad(Vec3(x: -sh, y: 0, z: -sh), Vec3(z: s), Vec3(x: s))

var cube: Cube
for i in 0..<9:
  cube[0][i] = white
  cube[1][i] = green
  cube[2][i] = red
  cube[3][i] = blue
  cube[4][i] = orange
  cube[5][i] = yellow

var button_down = false
var scale = 1.0
var change = true

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
  
  if (button_down and s > 0.5) or (button_down == false and s < 1):
    change = true
    if button_down and s > 0.5:
      scale = scale - 0.01
    else:
      scale = scale + 0.01
    s = scale
    d = 1.6 - scale * 1.5
    sh = s / 2
    sd = 1.5 * s + d

  # ren.add(body1, color = red)
  # ren.add(body1, color = red, rot = new_quat(Vec3(x: 1), Deg(180)))

  # ren.add(body2, color = green, rot = new_quat(Vec3(x: 1), Deg(90)))
  # ren.add(body2, color = green, rot = new_quat(Vec3(y: 1), Deg(90)))

  # ren.add(body3, color = blue)
  # ren.add(body3, color = blue, rot = new_quat(Vec3(z: 1), Deg(180)))

  if change:
    cont.update(ren.camera)

    ren.background(grey(1))

    for i1 in 0..<3:
      var z = i1.float * (s + d) - sd
      for i2 in 0..<3:
        var z2 = i2.float * (s + d) - sd

        for val in @[-(sh + d), -sh, sh, sh + d]:
          for nw in 0..1:
            ren.add(body1, color = black, pos = Vec3(x: z2 + sh, y: z + sh, z: val), rot=new_quat(Vec3(x: 1), Deg(nw * 180)), scale = scale)
            ren.add(body2, color = black, pos = Vec3(x: val, y: z2 + sh, z: z + sh), rot=new_quat(Vec3(y: 1), Deg(nw * 180)), scale = scale)
            ren.add(body3, color = black, pos = Vec3(x: z + sh, y: val, z: z2 + sh), rot=new_quat(Vec3(z: 1), Deg(nw * 180)), scale = scale)

        for i in 0..<6:
          var val = 0
          case i:
          of 0: val = 3 * i2 + i1             # i1 + 3i2
          of 1: val = 8 - (3 * i1 + i2)       # -3i1 + i2 + 8
          of 2: val = 8 - (3 * i2 + i1)       # i1 - 3i2 + 8
          of 3: val = 8 - (3 * i1 + (2 - i2)) # -3i1 + i2 + 6
          of 4: val = 8 - (3 * i2 + (2 - i1)) # i1 - 3i2 + 6
          of 5: val = 3 * (2 - i2) + i1       # i1 - 3i2 + 6
          else: discard

          for nw in 0..1:
            case i:
            of 0: ren.add(body1, color = cube[i][val], pos = Vec3(x: z2 + sh, y: z + sh, z: sd), rot=new_quat(Vec3(x: 1), Deg(nw * 180)), scale = scale)
            of 1: ren.add(body2, color = cube[i][val], pos = Vec3(x: sd, y: z2 + sh, z: z + sh), rot=new_quat(Vec3(y: 1), Deg(nw * 180)), scale = scale)
            of 2: ren.add(body3, color = cube[i][val], pos = Vec3(x: z + sh, y: sd, z: z2 + sh), rot=new_quat(Vec3(z: 1), Deg(nw * 180)), scale = scale)
            of 5: ren.add(body1, color = cube[i][val], pos = Vec3(x: z2 + sh, y: z + sh, z: -sd), rot=new_quat(Vec3(x: 1), Deg(nw * 180)), scale = scale)
            of 3: ren.add(body2, color = cube[i][val], pos = Vec3(x: -sd, y: z2 + sh, z: z + sh), rot=new_quat(Vec3(y: 1), Deg(nw * 180)), scale = scale)
            of 4: ren.add(body3, color = cube[i][val], pos = Vec3(x: z + sh, y: -sd, z: z2 + sh), rot=new_quat(Vec3(z: 1), Deg(nw * 180)), scale = scale)
            else: discard

    ren.add(Light(kind: LightAmbient,
      ambient: 1
    ))

    ren.render(stats)
    window.swap()

    stdout.write("\rfps: " & $stats.average_fps().int & "\t")

  if change == false:
    sleep(10)
  elif change and stats.average_fps() > optimal_fps:
    let fps = stats.average_fps() 
    sleep((1000 * (fps - optimal_fps) / (optimal_fps * fps)).int)
  change = false
