import ../utils, ../render3

# 0: oben, weiß
# 1: links, grün
# 2: hinten, rot
# 3: rechts, blau
# 4: vorne, orange
# 5: unten, gelb

type
  Cube = array[6, array[9, Color]]

let
  window = new_window("Cube", resizable=true)

  black = rgb(0, 0, 0)
  red = rgb(1, 0, 0)
  white = rgb(0.95, 0.95, 0.95)
  green = rgb(0, 1, 0)
  blue = rgb(0, 0, 1)
  orange = rgb(1, 0.5, 1)
  yellow = rgb(1, 1, 0)

  body1, body2, body3 = Mesh()

var
  cont = new_orbit_camera_controller()
  ren = new_render3(window)
  stats = Stats()
  is_running = true

body1.add_quad(Vec3(x: 0, y: 0, z: 0), Vec3(x: 1), Vec3(y: 1))
body2.add_quad(Vec3(x: 0, y: 0, z: 0), Vec3(y: 1), Vec3(z: 1))
body3.add_quad(Vec3(x: 0, y: 0, z: 0), Vec3(z: 1), Vec3(x: 1))

var cube: Cube
for i in 0..<9:
  cube[0][i] = white
  cube[1][i] = green
  cube[2][i] = red
  cube[3][i] = blue
  cube[4][i] = orange
  cube[5][i] = yellow

while is_running:
  for event in window.poll():
    case event.kind:
      of EventQuit:
        is_running = false
        break
      of EventWheel, EventMove:
        cont.process(event)
      else: echo event
  
  cont.update(ren.camera)

  ren.background(grey(1))

  for i1 in 0..<3:
    var z = -1.6 + i1.toFloat * 1.1
    for i2 in 0..<3:
      var z2 = -1.6 + i2.toFloat * 1.1
      let values = @[-0.6, -0.5, 0.5, 0.6]
      for val in values:
        for nw in 0..1:
          ren.add(body1, color = black, pos = Vec3(x: z2, y: z + nw.toFloat, z: val), rot=new_quat(Vec3(x: 1), Deg(nw * 180)))
          ren.add(body2, color = black, pos = Vec3(x: val, y: z2, z: z + nw.toFloat), rot=new_quat(Vec3(y: 1), Deg(nw * 180)))
          ren.add(body3, color = black, pos = Vec3(x: z + nw.toFloat, y: val, z: z2), rot=new_quat(Vec3(z: 1), Deg(nw * 180)))

  for i in 0..<6:
    for i1 in 0..<3:
      var z = -1.6 + i1.toFloat * 1.1
      for i2 in 0..<3:
        var z2 = -1.6 + i2.toFloat * 1.1

        var val = 0
        case i:
        of 0: val = 3 * i2 + i1
        of 1: val = 8 - (3 * i1 + i2)
        of 2: val = 8 - (3 * i2 + i1)
        of 3: val = 8 - (3 * i1 + (2 - i2))
        of 4: val = 8 - (3 * i2 + (2 - i1))
        of 5: val = 3 * (2 - i2) + i1
        else: discard

        for nw in 0..1:
          for nx in 0..1:
            case i:
            of 0, 5: ren.add(body1, color = cube[i][val], pos = Vec3(x: z2, y: z + nw.toFloat, z: 1.6 - 3.2 * nx.toFloat), rot=new_quat(Vec3(x: 1), Deg(nw * 180)))
            of 1, 3: ren.add(body2, color = cube[i][val], pos = Vec3(x: 1.6 - 3.2 * nx.toFloat, y: z2, z: z + nw.toFloat), rot=new_quat(Vec3(y: 1), Deg(nw * 180)))
            of 4, 2: ren.add(body3, color = cube[i][val], pos = Vec3(x: z + nw.toFloat, y: 1.6 - 3.2 * nx.toFloat, z: z2), rot=new_quat(Vec3(z: 1), Deg(nw * 180)))
            else: discard

  ren.add(Light(kind: LightAmbient,
    ambient: 1
  ))

  ren.render(stats)
  window.swap()

  echo stats.average_fps()