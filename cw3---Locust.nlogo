;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;variables;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals[
  ; initial_pop
  ; n-patches
  ; maximum_energy_grass
  ; initial_energy_locust
  ; cost_move_locust
  ; num_gregarious
  ; step_gregarious          ; step_solitary is 1
  ; growback_speed
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

turtles-own[
  ; 0.1.1 the amount of energy each turtle has
  energy_locust

  ; 0.1.2 the cost of enery to move
  energy_locust_move

  ; 0.1.3 the sum of locusts on the total 9 patches
  n_locust_turtle
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

patches-own[
  ; 0.2.1 the maximum amount of energy on this patch
  max_energy_grass

  ; 0.2.2 the current amount of energy on this patch
  cur_energy_grass

  ; 0.2.3 how many locusts on the 9 patches
  n_locust_patch
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;set up;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to setup
  clear-all

  ; set up things about turtles
  setup-turtles

  ; set up things about patches
  setup-patches

  reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;turtle set up;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-turtles
  ; create turtles
  ; initial_pop means initial population
  crt initial_pop
  [
    ; set shape of turtles at the beginning
    set shape "bug"

    ; set their size
    set size 1

    ; ask them to locate randomly in the center of patch
    setxy random-pxcor random-pycor                      ; "move-to one-of patches" is equivalent

    ; 0.1.1 allocate them with initial energy
    set energy_locust initial_energy_locust
    ; 0.1.2 allocate them with cost of moving
    set energy_locust_move move_energy

    ; 1.3 update "n_locust_turtle"
    link_n_locust

    ; 1.4 update color of turtles
    gregarious_color

  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;patch set up;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-patches

  let percent-patches n-patches / 100 * (count patches)
  ask n-of percent-patches patches
  [
    ; 0.2.1 maximum energy is distributed randomly between 1 and 5
    set max_energy_grass (random maximum_energy_grass) + 1
    ; 0.2.2 initial energy is equal to its maximum
    set cur_energy_grass max_energy_grass

    ; 2.1 update color of patches
    ; color patches based on the energy they have
    ; the lowest is 1, then lime(65) + 4.9 - 1 = 69.9 = white
    ; the hightest is 5, then lime(65) + 4.9 - 5 = 65 = lime
    patch_color
  ]

  ask patches[
    ; 2.1 update color of patches
    patch_color
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;to go functions;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to go
  ; most of them are died, the simulation could stop
  if count turtles <= (initial_pop) * 0.01  [
    stop
  ]

  ; turtles
  ask turtles [
    ;1.1 how turtle moves about energy
    move_locust

    ;1.2 condition of death
    die_locust

    ;1.3 update "n_locust_turtle"
    link_n_locust

    ;1.4 update color of turtles
    gregarious_color

    ;1.5 how turtle moves about step
    move_locust_turtle

    ;1.6 breed
    breed_turtle
  ]

  ; patches
  ask patches [
    ; 2.1 update color of patches
    patch_color

    ; 2.2 ask grass to growback
    growback_patch
  ]
  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;turtle functions;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.1
to move_locust

  ; each move would cost energy and earn energy from grass
  set energy_locust (energy_locust - energy_locust_move + cur_energy_grass)

  ; update energy of grass
  set cur_energy_grass 0 ;

  ; functions about their moving steps
  move_locust_turtle
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.2
; if the energy of locust is 0, it will die
to die_locust
  if energy_locust <= 0 [
    die
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.3
to link_n_locust
  let this-turtle self
    ask patches with [member? this-turtle turtles-here][
    ; 0.2.3
      set n_locust_patch sum list(sum [count turtles-here] of neighbors)([count turtles-here] of self)
    ]
  ; 0.1.3
  set n_locust_turtle [n_locust_patch] of patch-here
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.4
to gregarious_color
    ; they tend to be far to each other
    ; then they become solitary
    ifelse n_locust_turtle < num_gregarious
    [
      ; set the color
      set color green
    ]
    ;otherwise, they are close and become gregarious
    [
      ; set the color and cost of move
      set color yellow
    ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.5
to move_locust_turtle
  ; they become gregarious
  ifelse n_locust_turtle >= num_gregarious[
    ;uphill cur_energy_grass
    ;move-to max-one-of neighbors [count turtles-here]]
    ;create-link-to turtles at neighbors [tie]
    set heading random 360
    fd step_gregarious
    move-to patch-here
  ]
  [
    ; each locust would change direction to move
    ; they don't follow just on direction
    set heading random 360
    ;otherwise, they are solitary,
    ;they just move 1 step
    fd 1
    ;move them to the center for better visualisation
    move-to patch-here
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1.6
to breed_turtle

  ; they have enough energy to have babies
  if energy_locust >= initial_energy_locust * 5 [

    ; they are gregarious
    ifelse  n_locust_turtle >= num_gregarious[
      set energy_locust (energy_locust - energy_locust_move * 2)
      hatch 5 [
        set energy_locust initial_energy_locust
      ]
    ]
    [
      ; they are solitary
      set energy_locust (energy_locust - energy_locust_move * 2)
      hatch 1 [
        set energy_locust initial_energy_locust
      ]
    ]

  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;patch functions;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 2.1
to patch_color
  ;notes see above
  set pcolor (lime + 4.9 - cur_energy_grass)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 2.2
; the growback speed of grass
; if there is no lost in energy, grass no need to growback
; if there is, it grows constantly back to its maximum.
to growback_patch
  set cur_energy_grass min (list max_energy_grass (cur_energy_grass + growback_speed))
end





@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
11
16
66
49
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
72
17
127
50
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
133
17
188
50
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
15
100
173
133
n-patches
n-patches
0
100
100.0
10
1
NIL
HORIZONTAL

SLIDER
14
158
193
191
maximum_energy_grass
maximum_energy_grass
1
5
5.0
1
1
NIL
HORIZONTAL

TEXTBOX
22
338
100
356
Initial energy:
9
0.0
1

SLIDER
16
417
188
450
num_gregarious
num_gregarious
5
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
14
216
186
249
growback_speed
growback_speed
0
0.5
0.5
0.1
1
NIL
HORIZONTAL

CHOOSER
17
351
169
396
initial_energy_locust
initial_energy_locust
3 4
1

CHOOSER
16
470
108
515
move_energy
move_energy
1 2
1

CHOOSER
123
470
231
515
step_gregarious
step_gregarious
2 3
1

TEXTBOX
242
473
325
505
solitary ones just forward 1 step each move\n
9
0.0
1

TEXTBOX
9
65
159
83
For grass:
12
0.0
1

TEXTBOX
14
84
189
102
Density (%) of resources distribution:
9
0.0
1

TEXTBOX
16
141
198
163
Maximum energy (allocated randomly):
9
0.0
1

TEXTBOX
14
201
164
219
Growback spped (constantly):\t
9
0.0
1

TEXTBOX
10
264
160
282
For locusts:
12
0.0
1

TEXTBOX
21
282
171
300
Initial population:
9
0.0
1

TEXTBOX
22
404
172
422
Condition to be gregarious:\n
9
0.0
1

TEXTBOX
21
456
91
474
Cost of move:
9
0.0
1

TEXTBOX
124
456
274
474
Gregarious type forward step:
9
0.0
1

PLOT
656
14
911
169
The number of locusts
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"soli" 1.0 0 -10899396 true "" "plotxy ticks (count turtles with [color = green])\n"
"greg" 1.0 0 -1184463 true "" "plotxy ticks (count turtles with [color = yellow])"
"all" 1.0 0 -8630108 true "" "plotxy ticks (count turtles)"

PLOT
657
187
910
337
Average energy of locusts
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"soli" 1.0 0 -10899396 true "" "plotxy ticks mean [energy_locust] of turtles with [color = green]"
"greg" 1.0 0 -1184463 true "" "plotxy ticks mean [energy_locust] of turtles with [color = yellow]"
"all" 1.0 0 -8630108 true "" "plotxy ticks mean [energy_locust] of turtles"

PLOT
924
14
1171
169
Energy distribution of locusts
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"soli" 1.0 1 -10899396 true "" "set-histogram-num-bars 10\nset-plot-x-range 0  (max [energy_locust] of turtles  with [color = green])\nset-plot-pen-interval (max [energy_locust] of turtles  with [color = green]) / 10\nhistogram [energy_locust] of turtles with [color = green]"
"greg" 1.0 1 -1184463 true "" "set-histogram-num-bars 10\nset-plot-x-range 0  (max [energy_locust] of turtles  with [color = yellow])\nset-plot-pen-interval (max [energy_locust] of turtles  with [color = yellow]) / 10\nhistogram [energy_locust] of turtles with [color = yellow]"
"all" 1.0 1 -8630108 true "" "set-histogram-num-bars 10\nset-plot-x-range 0  (max [energy_locust] of turtles)\nset-plot-pen-interval (max [energy_locust] of turtles) / 10\nhistogram [energy_locust] of turtles"

PLOT
924
187
1174
338
Total energy of resources
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"grass" 1.0 0 -13791810 true "" "plotxy ticks (sum [cur_energy_grass] of patches)"

MONITOR
659
385
773
430
survived locusts
count turtles
17
1
11

CHOOSER
19
293
157
338
initial_pop
initial_pop
500 1000
1

MONITOR
794
362
854
407
no. greg
count turtles with [color = yellow]
17
1
11

MONITOR
795
415
853
460
no. soli
count turtles with [color = green]
17
1
11

MONITOR
945
384
1039
429
grass energy
sum [cur_energy_grass] of patches
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="1.F is low, L is weak" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count turtles</metric>
    <metric>count turtles with [color = green]</metric>
    <metric>count turtles with [color = yellow]</metric>
    <metric>mean [energy_locust] of turtles</metric>
    <metric>mean [energy_locust] of turtles with [color = green]</metric>
    <metric>mean [energy_locust] of turtles with [color = yellow]</metric>
    <metric>sum [cur_energy_grass] of patches</metric>
    <enumeratedValueSet variable="n-patches">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum_energy_grass">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growback_speed">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_gregarious">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_pop">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_energy_locust">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="move_energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="step_gregarious">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="2.F is low, L is strong" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count turtles</metric>
    <metric>count turtles with [color = green]</metric>
    <metric>count turtles with [color = yellow]</metric>
    <metric>mean [energy_locust] of turtles</metric>
    <metric>mean [energy_locust] of turtles with [color = green]</metric>
    <metric>mean [energy_locust] of turtles with [color = yellow]</metric>
    <metric>sum [cur_energy_grass] of patches</metric>
    <enumeratedValueSet variable="n-patches">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum_energy_grass">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growback_speed">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_gregarious">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_pop">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_energy_locust">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="move_energy">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="step_gregarious">
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="3.F is high, L is weak" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count turtles</metric>
    <metric>count turtles with [color = green]</metric>
    <metric>count turtles with [color = yellow]</metric>
    <metric>mean [energy_locust] of turtles</metric>
    <metric>mean [energy_locust] of turtles with [color = green]</metric>
    <metric>mean [energy_locust] of turtles with [color = yellow]</metric>
    <metric>sum [cur_energy_grass] of patches</metric>
    <enumeratedValueSet variable="n-patches">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum_energy_grass">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growback_speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_gregarious">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_pop">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_energy_locust">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="move_energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="step_gregarious">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="4.F is high, L is strong" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count turtles</metric>
    <metric>count turtles with [color = green]</metric>
    <metric>count turtles with [color = yellow]</metric>
    <metric>mean [energy_locust] of turtles</metric>
    <metric>mean [energy_locust] of turtles with [color = green]</metric>
    <metric>mean [energy_locust] of turtles with [color = yellow]</metric>
    <metric>sum [cur_energy_grass] of patches</metric>
    <enumeratedValueSet variable="n-patches">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum_energy_grass">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growback_speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_gregarious">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_pop">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_energy_locust">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="move_energy">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="step_gregarious">
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
