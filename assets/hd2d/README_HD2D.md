# Teehütte am See – HD-2D-Asset-Paket

Pixel-Sprites in einer 3D-Welt, angelehnt an den HD-2D-Look: schmale Kamera, weiche Tiefenunschärfe, Bloom, Vignette und warmes Licht.
Getestet mit **Godot 4.7.2** (Standard, GDScript).

## 1. Einbauen (2 Minuten)

1. Den Ordner `assets/hd2d/` aus dem ZIP **genau so** in dein Projekt legen: `res://assets/hd2d/`.
   Die Szenen verweisen auf diesen Pfad. Die `.import`-Dateien gehören dazu. Sie sorgen dafür, dass die Pixel verlustfrei importiert werden.
2. Godot öffnen und kurz warten, bis alles importiert ist.
3. `res://assets/hd2d/demo/demo_hd2d.tscn` öffnen und **F6** drücken.
   Steuerung: WASD laufen · E Aktion · 1–4 Tageszeit · F Zeitraffer · R Regen · H Hilfe.
   Lauf in die Hütte: Dach und Vorderwand werden automatisch ausgeblendet.
4. Empfohlen: *Projekteinstellungen → Rendering → Texturen → Canvas Textures → Default Texture Filter = **Nearest***.
   Dann bleiben auch UI-Icons scharf.

> Die Tiefenunschärfe (Tilt-Shift) funktioniert nur mit dem Renderer **Forward+** oder **Mobile**. Im Renderer *Compatibility* fehlt nur dieser Effekt.

## 2. In dein Spiel übernehmen (M1–M4)

| Was | So geht's |
| --- | --- |
| **Spielfigur** | Beim CharacterBody3D die Kapsel-Mesh ausblenden und `scenes/player_sprite.tscn` als Kind einfügen. Die Animation (idle/walk in 4 Richtungen) folgt automatisch `velocity`, dafür ist kein Code nötig. Für Pflanzen, Ernten und Abgeben rufst du `$PlayerSprite/Sprite.play_action()` auf. |
| **Beet** | `scenes/garden_bed.tscn` in deine Beet-Szene einfügen. Im Beet-Skript: `$GardenBed.herb = "mint"` und `$GardenBed.set_from_state(state, progress)`. `state` darf der Name (`"EMPTY"`, `"GROWING"`, `"READY"`) oder der Enum-Wert 0/1/2 sein; `progress` geht von 0.0 bis 1.0. Nach dem Gießen setzt du `wet = true`. |
| **Licht & Stimmung** | `scenes/hd2d_lighting.tscn` in die Hauptszene einfügen und deine alte WorldEnvironment und DirectionalLight3D entfernen. `TimeOfDay.hour` (0–24) steuert Sonne, Farben, Wasser und Laternen; das passt direkt zu M7. `rain_amount` (0–1) dämpft das Licht bei Regen. |
| **Kamera** | `scenes/hd2d_camera.tscn` einfügen und `target` auf deine Figur setzen. Alternativ übernimmst du nur die Werte in deine Kamera: FOV 28, Neigung 33°, Abstand 19 m, `env/hd2d_camera_attributes.tres`. |
| **Hütte** | `scenes/hut.tscn` enthält schon Bett, Teestation, Teppich und Wandbild. Deine Figur muss in der Gruppe `player` sein (`add_to_group("player")`). |
| **Laterne (M4)** | `scenes/lantern.tscn` an den Weg stellen und bis zum Kauf `visible = false` setzen. Sie leuchtet nachts von selbst. |
| **Bestellbrett / Ablage** | `scenes/order_board.tscn`, `scenes/order_tray.tscn`. Dein Area3D für die Interaktion hängst du daneben. |
| **Regen** | `scenes/rain.tscn` als Kind der Figur (etwa 11 m hoch) einfügen. `emitting = true/false`. |
| **HUD** | Icons liegen in `ui/icons/`, Rahmen und Slots in `ui/`. Beim NinePatchRect sind alle Patch-Ränder 8 px. Mit `scale = 3` wird die Darstellung pixelgenau. |

**Wichtig:** Die Szenen sind nur Grafik. Kollisionen (StaticBody3D, CollisionShape3D) und Interaktionsbereiche (Area3D) fügst du wie bisher selbst hinzu. So bleibt deine Spiellogik von der Darstellung getrennt.

## 3. Inhalt

**Sprites** (`sprites/`, PNG mit Transparenz)
- `character/player.png`: 32×48 pro Bild, 7 Spalten × 4 Zeilen. Zeilen: unten, links, rechts, oben. Spalten: idle ×2, walk ×4, Aktion.
- `plants/mint|chamomile|lavender.png`: 4 Stufen à 32×32 (gepflanzt, Keimling, wachsend, erntereif).
- `world/`: Eiche (2 Varianten), Birke, Tanne, Büsche (3), Schilf, Steine (2), Grasbüschel (3), Wildblumen (3), Seerosenblätter (2).
- `deco/`: Laterne und Leuchten, Blumentopf, Wandbild, Teppich. Die Bank ist ein 3D-Modell.
- `interact/`: Bestellbrett, Ablage, Hüttenschild.
- `building/`: Fenster, Fensterlicht und Tür.
- `station/`: für die Nahansicht in M6. Dazu gehören Tassen (leer, Wasser und drei Tees, Tasse mit Sieb), Wasserkocher (kalt und heiß), Sieb (leer und drei Kräuter), Gläser (leer und drei Kräuter) sowie eine Sanduhr.
- `fx/`: Glitzern (4 Bilder), Dampf (4 Bilder), Regentropfen, Bodenschatten.

**UI** (`ui/`): Icons 16×16 für drei Kräuter, drei Tees, Münze, Sonne, Mond, Regen, Schlafen und fünf Dekorationen. Dazu kommen Panel (9-Slice), Inventar-Slot und die Taste „E“.

**3D-Teile** (`scenes/`), aus Grundformen mit Pixel-Texturen gebaut: Hütte mit Innenraum, Beet, Steg, Bank, Bett und Teestation.

**Texturen** (`textures/`, kachelbar, meist 64×64 = 2 m): Gras (2), Weg, Sand, Erde trocken/nass, Holzboden, Holzwand, dunkles Holz, Dachschindeln, Stein, Putz und Bettdecke.
Die Materialien in `materials/` projizieren sie „triplanar“. Deshalb brauchen Würfel und Flächen keine UV-Koordinaten, und alle Pixel haben dieselbe Größe.

**Shader** (`shaders/`)
- `terrain_hd2d`: Boden mit pixeligen, unregelmäßigen Übergängen zwischen Gras, Weg und Sand. Unter dem See senkt sich der Boden ab. Gesteuert wird das über eine Maske (R = Weg, G = Sand, B = Wasser, siehe `demo/terrain_mask.png`), die du mit jedem Malprogramm ändern kannst.
- `water_hd2d`: pixelige Wellen, Glitzern und Uferschaum. `materials/water_plain.tres` funktioniert auch ohne Maske.
- `vignette`: dunkle Bildränder.

## 4. Maßstab

| Objekt | pixel_size | Ergebnis |
| --- | --- | --- |
| Figur, Laterne, Bestellbrett | 0.045 | Figur ca. 1,35 m |
| Bäume | 0.05 | 4–5 m |
| Kräuter im Beet | 0.033 | erntereif ca. 0,8 m |
| Texturen | 32 px pro Meter | |

Alle Sprites: *Billboard = Y-Billboard*, *Shaded* an, *Alpha Cut = Discard* (damit sie Schatten werfen), *Texture Filter = Nearest*.

## 5. Herkunft und Lizenz

Alle Grafiken, Szenen, Shader und Skripte wurden am 24.09.2026 mit Claude eigens für „Teehütte am See“ erstellt. Es wurden keine fremden Asset-Pakete verwendet. Du darfst alles frei verwenden, verändern und veröffentlichen.
