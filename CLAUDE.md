# Teehütte am See (teahut)

Kleines, gemütliches Einzelspieler-Spiel in Godot für Windows-PC. Zielversion: **0.1**.

**Kernschleife:** Kräuter anbauen → ernten → Tee zubereiten → Bestellung abgeben → Geld erhalten → den Ort verschönern.
**Spielgefühl:** „Ich erschaffe mir einen Ort, an dem ich gerne bin.“

Gestaltungsgrundsätze:
- Keine Zeitlimits, verdorbenen Pflanzen, ablaufenden Bestellungen, Schulden oder Strafen.
- Kleine Mengen: eine Bestellung = genau eine Tasse. Das Ritual soll nicht zur Fließbandarbeit werden.
- Pflanzen, Rezepte und Dekorationen über Daten definieren; Logik und Darstellung trennen, soweit sinnvoll.
- Keine Plugin-Plattform, generischen Fabriken oder großen Frameworks. Erst spielbar, dann Inhalt, dann Atmosphäre.

**Vollständige Anforderungen stehen in [specsheet.md](specsheet.md).** Wichtige Abschnitte: 5 Steuerung, 6 Garten/Inventar, 7 Teestation, 8 Bestellungen, 9 Geld/Deko, 10 Zeit/Schlaf/Wetter, 11 Arbeitswerte, 12 Speichern, 14 Meilensteine, 15 Abnahmekriterien, 16 Nicht-Umfang.

## Arbeitsweise

**Der Entwickler programmiert selbst in Godot.** Lernziel ist, das Spiel selbst zu verstehen und zu bauen.

- Claude ändert **keine Spieldateien** (`.gd`, `.tscn`, `.tres`, `project.godot`, Assets). Claude erklärt, schlägt Schritte vor, zeigt Code als Vorschlag im Chat und prüft den Code des Entwicklers. Eigene Änderungen an Spieldateien nur auf ausdrückliche Bitte.
- Projekt-Doku (`CLAUDE.md`, `specsheet.md`) darf Claude pflegen. Commits nur auf Nachfrage.
- Kommunikation auf Deutsch. Der Entwickler hat Programmiererfahrung, ist aber Anfänger in der Spieleentwicklung: Godot-Begriffe beim ersten Auftreten kurz und einfach erklären.
- Kleine, ausführbare Schritte mit sichtbarem Ergebnis und kurzer Prüfanweisung. Bei Code sagen, an welche Szene bzw. welchen Node er gehört.
- Ungetesteten Code und Annahmen ehrlich kennzeichnen. Claude führt das Spiel nicht aus; geprüft wird per Spieltest im Editor durch den Entwickler.
- Als „bestätigt“ gilt nur, was der Entwickler per Spieltest bestätigt hat.
- Umfang nicht beiläufig erweitern. Neue Ideen als spätere Option festhalten.
- Nur nach Entscheidungen fragen, die den nächsten Schritt wesentlich verändern; für Details eine einfache Lösung vorschlagen.
- Nach einem Meilenstein kurz zusammenfassen: was funktioniert, was offen ist, was folgt – und den Abschnitt „Aktueller Stand“ unten aktualisieren.

Git: ein Branch pro (Teil-)Meilenstein, PR nach `main`. Kleine Commits, Nachrichten auf Deutsch mit Präfix, z. B. `M6a: Inventar speichert Mengen in einem Dictionary`.

## Technik

- Godot 4.7 Standard (ohne .NET), Renderer „GL Compatibility“, Jolt Physics. Vor versionsabhängigen Anleitungen die installierte Patch-Version prüfen. Keine Versionswechsel während 0.1.
- GDScript mit Typangaben.
- Kein Build- oder Testbefehl; Prüfung per Spieltest im Editor.

## Ordnerstruktur

| Pfad | Inhalt |
| --- | --- |
| `scenes/` | Spielszenen; Hauptszene `scenes/world.tscn` |
| `scripts/` | Gameplay-Skripte |
| `data/` | Inhalte als Resources (`mint.tres`, `mint_tea.tres`) |
| `data_scripts/` | Resource-Klassen (`HerbData`, `TeaData`) |
| `assets/hd2d/` | HD-2D-Asset-Paket, nur teilweise eingebunden (Beet, Laterne, Ablage, Teestation-Grafik, Spielfigur). Siehe `assets/hd2d/README_HD2D.md`. Vorhandene Assets sind nicht automatisch fertiger Spielinhalt. |

Autoloads: `Inventory` (`scripts/inventory.gd`), `SaveGame` (`scripts/save_game.gd`).

## Architektur-Konventionen

- **Inventar:** Mengen in `items: Dictionary[String, int]`, Schlüssel ist die `id` der Resource. API: `get_count`, `add_item`, `try_take_item`, `add_money`, `try_spend_money`. Signale `item_changed(id, amount)` und `money_changed(amount)`. Mengen ≤ 0 werden abgewiesen.
- **Inhalte als Daten:** `HerbData` (id, display_name, growth_duration, harvest_amount) und `TeaData` (id, display_name, herb, herb_amount, brew_duration, price) werden per `@export` an Beet, Teestation und Ablage zugewiesen. Neue Sorte = neue `.tres` in `data/` und im HUD (`world.tscn` → `HUD`, Listen `herbs`/`teas`) eintragen.
- **Interaktionsobjekte:** `Area3D` mit `InteractionLabel` (Label3D), `player_in_range` über `body_entered/exited`, Aktion `interact` (E). Zustände als `enum` (`EMPTY/GROWING/READY`, `IDLE/BREWING/READY`).
- **Spielstand:** `user://savegame.json`, sicheres Schreiben über `.tmp`, vorheriger Stand als `.bak` (Fallback beim Laden). Nodes mit Zustand gehören zur Gruppe `persist` und liefern `get_save_data()` / `load_save_data(data)`. Der Schlüssel ist der Node-Pfad ab der Weltszene (z. B. `HerbPlot`) → Nodes in `world.tscn` nicht umbenennen, ohne an alte Spielstände zu denken. Zustände als Enum-Namen speichern, Werte beim Laden begrenzen (`clampf`). `SAVE_VERSION` wird noch nicht ausgewertet.
- **Autosave:** nach Verkauf, nach Laternenkauf, beim Schließen des Fensters. Kein Offline-Fortschritt.
- **Pause:** Pausenmenü (Escape) hält die Simulation an.
- Beim Verschieben von Skripten die zugehörige `.uid`-Datei mitnehmen (am besten im Godot-Dateisystem-Dock verschieben).

## Aktueller Stand

Stand: 29.09.2026 · Branch `M6a` (PR nach `main` offen)

| Meilenstein | Ergebnis | Stand |
| --- | --- | --- |
| M1 – Bewegen und interagieren | Figur läuft, Kamera folgt, Beet zeigt Hinweise | bestätigt |
| M2 – Erster Anbau | Minze pflanzen, wachsen lassen, ernten; HD-2D-Beetgrafik | bestätigt |
| M3 – Erste Tasse | Vereinfachte Teestation; fertiger Tee wird **aktiv abgeholt** (nicht automatisch ins Inventar) | bestätigt |
| M4 – Erster Prototyp | Ablage nimmt Minztee an (+10 Münzen); Laterne für 10 Münzen kaufbar | bestätigt |
| M5 – Spielstand | Speichern/Laden, Autosave, `.bak`-Fallback, Pausenmenü | bestätigt (28.09.) |
| M6 – Inhalt und Ritual | 3 Kräuter/Rezepte, Handgriffe der Teestation, 5 Dekorationen | **in Arbeit** (M6a fertig, M6b als Nächstes) |
| M7 – Atmosphäre | Tag/Nacht, Regen, Gießen/Feuchtigkeit, Schlafen, Schlafbonus | offen |
| M8 – Abschluss 0.1 | Hauptmenü, Audioeinstellungen, Sonderfälle, Windows-Export | offen |

**M6-Aufteilung** (Vorschlag, jeder Schritt spielbar und speicherbar):
1. M6a – Inventar verallgemeinern (abgeschlossen)
2. **M6b** – Kamille und Lavendel: Kräuterart am leeren Beet wählen; Station macht passenden Tee
3. M6c – Bestellbrett: je eine Bestellung pro Sorte, aktive Bestellung wählen, Ablage prüft Sorte (Spec 8)
4. M6d – Einrichtungskatalog: fünf Dekorationen, Laterne wird die erste (Spec 9)
5. M6e – Nahansicht der Teestation mit Handgriffen (Spec 7)

**M6a – abgeschlossen (29.09.2026):** Inventar als Dictionary mit `add_item`/`try_take_item`; Dateien in `scenes/`/`scripts/`; `HerbData`/`TeaData` mit `mint.tres`/`mint_tea.tres` für Beet, Station und Ablage; HUD erzeugt seine Zeilen aus den Listen `herbs`/`teas`, Speicherhinweis sitzt unten links. Minze-Ablauf, HUD und alte Spielstände per Spieltest bestätigt.

**Nächster Schritt: M6b – Kamille und Lavendel.**

**Bewusst vereinfacht, kommt später:** Hauptmenü (M8; bis dahin lädt die Welt automatisch). Spielstand wächst mit jedem System (aktive Bestellung, reservierte Zutaten, Feuchtigkeit, Uhrzeit, Wetter, Schlafbonus, Deko-Sichtbarkeit).

**Aktuelle Testwerte** (Standardwerte in den Resources/Skripten, kürzer als die Arbeitswerte in Spec 11): Wachstum 5 s, Zubereitung 5 s, Ertrag 2, Verkaufspreis 10, Laterne 10 Münzen.
