# Teehütte am See – Spec-Sheet für Version 0.1

Stand: 29. September 2026 · Zielversion: 0.1 · Arbeitstitel · Plattform: Windows-PC · Einzelspieler

Dieses Dokument beschreibt den **Zielumfang von Version 0.1**. Der aktuelle Entwicklungsstand (welche Meilensteine umgesetzt und bestätigt sind, was als Nächstes folgt) sowie Arbeitsweise, Technik und Code-Konventionen werden in [CLAUDE.md](CLAUDE.md) gepflegt. Funktionen gelten als Anforderungen, nicht als Beschreibung des vorhandenen Codes. Die Zahlen in Abschnitt 11 sind Arbeitswerte; im Prototyp sind teils kürzere Testwerte eingestellt (siehe CLAUDE.md).

## 1. Zweck und Verbindlichkeit

Dieses Dokument ist die eigenständig verständliche Grundlage für die schrittweise Entwicklung eines ersten Spiels in Godot. Der Entwickler hat etwa ein bis zwei Jahre Programmiererfahrung, aber keine Erfahrung in der Spieleentwicklung. Geplant sind wenige Stunden Entwicklungszeit pro Woche mit offenem Spielraum nach oben. Fertige Grafik-, Modell- und Soundbausteine sollen verwendet und bei Bedarf angepasst werden.

**Version 0.1** bezeichnet eine kleine, abgeschlossene und speicherbare erste Spielversion. Der noch kleinere **erste Prototyp** ist ein Meilenstein auf dem Weg dorthin, kein zusätzlicher vollständiger Spielumfang.

Die Spielvision und ausdrücklich genannten Wünsche sind festgelegt. Konkrete Mengen, Preise, Zeiten, Tasten und technische Details in diesem Dokument sind vorgeschlagene Arbeitswerte. Sie dürfen nach Spieltests angepasst werden. Eine Erweiterung des Funktionsumfangs ist eine bewusste neue Entscheidung.

## 2. Spielidee

Eine menschliche Spielfigur bewirtschaftet einen kleinen Kräutergarten neben einer gemütlichen Teehütte an einem See. Die geernteten Kräuter werden an einer interaktiven Teestation zu Tee verarbeitet und über eine Bestellablage verkauft. Mit den Einnahmen verschönert der Spieler Garten und Hütte.

**Spielgefühl:** „Ich erschaffe mir einen Ort, an dem ich gerne bin.“

**Spielablauf:** Kräuter anbauen → ernten → Tee zubereiten → Bestellung abgeben → Geld erhalten → den Ort verschönern.

Inspiration sind die verständlichen, wiederkehrenden Tätigkeiten von Stardew Valley und Dave the Diver. Deren Gesamtumfang ist ausdrücklich kein Ziel.

## 3. Gestaltungsgrundsätze

- Gemütliche, freundliche Stimmung; Regen und später Gewitter verstärken das Gefühl eines geschützten Rückzugsortes.
- Keine Zeitlimits, verdorbenen Pflanzen, ablaufenden Bestellungen, Schulden oder erzwungene Schlafenszeiten.
- Tätigkeiten sollen durch Animationen, Geräusche und sichtbare Veränderungen befriedigen.
- Fortschritt bedeutet vor allem einen schöneren persönlichen Ort, nicht immer größere Produktionsmengen.
- Kleine Mengen: Eine Bestellung verlangt zunächst genau eine Tasse. Das Zubereitungsritual soll nicht zur Fließbandarbeit werden.
- Erweiterbarkeit durch übersichtliche, getrennte Systeme und konfigurierbare Inhalte; keine universelle Farming-Engine entwickeln.

## 4. Umfang der ersten Version

| Bereich | Version 0.1 |
| --- | --- |
| Welt | Eine kleine, handgebaute Karte mit Garten, Seeufer und einer betretbaren Teehütte |
| Figur | Ein vorgegebenes menschliches Modell, keine Charaktererstellung |
| Kamera | 3D, schräg von oben, fester Blickwinkel; folgt der Figur, keine freie Rotation |
| Garten | Drei feste Beete, drei Kräuterarten: Minze, Kamille und Lavendel |
| Rezepte | Drei einfache sortenreine Kräutertees |
| Teestation | Eine feste Nahansicht mit Tasse, Kräuterregal, Sieb, Wasserkocher und optionalem Timer |
| Verkauf | Bestellbrett und Bestellablage; keine sichtbaren Gäste |
| Verschönerung | Fünf kaufbare Dekorationen an vorgegebenen Stellplätzen |
| Zeit und Wetter | Tag/Nacht, freiwilliges Schlafen, Sonne und Regen |
| Speichern | Ein lokaler Spielstand mit Fortsetzen-Funktion |
| Eingabe | Tastatur und Maus |
| Ausgabe | Lokal startbare Windows-Spielversion |

## 5. Steuerung, Kamera und Welt

- WASD bewegt die Figur relativ zur Kamera auf der Bodenebene.
- E interagiert mit dem hervorgehobenen Objekt in Reichweite.
- Linksklick bedient Menüs und Gegenstände der Teestation.
- Escape schließt die aktuelle Ansicht; aus der Welt öffnet es das Pausenmenü.
- Kein Springen, Schwimmen, Klettern oder Kampfsystem.
- See und Kartengrenzen sind nicht begehbar; die Figur kann nicht ins Wasser fallen.
- Bei der Teestation ruht die Figur. Das Verlassen der Nahansicht zerstört keinen Fortschritt.
- Das Dach der Hütte wird beim Betreten ausgeblendet oder der Innenraum separat gezeigt. Eine einfache, gut lesbare Lösung genügt.
- Interaktionen erhalten kurze Hinweise wie „Minze ernten“ oder „Tee zubereiten“.

## 6. Kräutergarten und Inventar

### Pflanzen

Jedes Beet enthält höchstens eine Pflanze. Ablauf: leer → bepflanzt → wachsend → erntereif → leer. Erntereife Pflanzen warten unbegrenzt auf die Ernte.

Für Version 0.1 sind alle drei Kräuter von Beginn an verfügbar. Das Pflanzen an einem leeren Beet kostet nichts und verbraucht kein Saatgut. Das begrenzt den Umfang und verhindert, dass fehlendes Geld den Spielablauf blockiert. Ein Saatguthandel ist eine mögliche spätere Erweiterung.

- Pflanzen wachsen auch ohne Gießen langsam weiter.
- Gießen beschleunigt Wachstum vorübergehend; Regen hält Außenbeete feucht.
- Kein Wasserverbrauch oder Nachfüllen der Gießkanne in dieser Version.
- Ernte fügt Kräuter dem Inventar hinzu. Ein vorgeschlagener Ertrag sind zwei Portionen pro Pflanze.
- Eine Portion ergibt eine Tasse Tee.
- Wachstum läuft während aktiver Spielzeit, auch in der Teestation. Pause stoppt es; geschlossene Anwendungen erzeugen keinen Offline-Fortschritt.

### Inventar

Ein einfaches Inventar zählt Kräuter und fertige Tassen nach Art. Es gibt keine Gewichtsgrenze, keine Haltbarkeit und kein Sortier- oder Stapelrätsel. Für die erste Version genügt eine übersichtliche Liste mit Symbol, Name und Menge.

Die Kräutergläser an der Station zeigen die verfügbaren Mengen. Leere Gläser sind erkennbar und nicht auswählbar. Tassen, Wasser und Sieb sind unbegrenzt wiederverwendbare Ausstattung und müssen nicht gekauft werden.

## 7. Interaktive Teezubereitung

### Darstellung

Beim Interagieren mit der Station erscheint eine feste Nahansicht: Tasse in der Mitte, Kräuter auf einem Regal darum herum, daneben Wasserkocher, Teesieb und Timer. Die Umsetzung darf 2D-Bedienelemente mit einfachen 3D-Animationen verbinden. Physikalische Flüssigkeitssimulation und präzise Greifbewegungen sind nicht erforderlich.

### Ablauf

1. **Kräuter wählen:** Ein verfügbares Kräuterglas anklicken. Eine Portion wird für den aktuellen Tee reserviert und visuell ins Sieb gefüllt. In Version 0.1 ist genau eine Kräuterart pro Tasse möglich.
2. **Sieb einsetzen:** Das Sieb anklicken; es wird in die Tasse gestellt.
3. **Temperatur einstellen:** Eine Temperaturstufe wählen und den Wasserkocher einschalten. Das Rezept zeigt eine Empfehlung.
4. **Wasser erhitzen:** Kurze Animation mit Geräusch und Dampf. Währenddessen kann die Station verlassen werden.
5. **Eingießen:** Nach dem Erhitzen Wasserkocher und Tasse anklicken. Eine kurze Animation füllt die Tasse.
6. **Ziehen lassen:** Die Ziehzeit beginnt automatisch beim Eingießen. Tee färbt sich langsam. Der optionale Timer aktiviert lediglich die Benachrichtigung.
7. **Fertigstellen und abholen:** Nach der Ziehzeit das Sieb entfernen. Die fertige Tasse bleibt an der Station, bis sie aktiv abgeholt wird. Erst die Abholung überträgt genau eine Tasse ins Inventar und gibt die Station für die nächste Zubereitung frei. Im vereinfachten M3-Prototyp genügt dafür eine weitere Interaktion an der Station; die einzelnen Handgriffe folgen in M6.

### Entspannte Regeln und Sonderfälle

- Der Tee wird bei zu langem Ziehen weder bitter noch kalt und verliert keinen Verkaufswert.
- Ein Timer klingelt höchstens einmal sanft. Anschließend bleibt ein sichtbarer Fertighinweis bestehen. Kein Daueralarm.
- Ohne Timer funktioniert die Zubereitung identisch; der fertige Zustand bleibt sichtbar.
- Vor Ablauf der Ziehzeit zeigt ein Klick auf das Sieb den verbleibenden Fortschritt. Es gibt keinen misslungenen Tee.
- Die Temperatur ist in Version 0.1 Teil des Rituals. Jede angebotene Stufe ergibt einen verkaufbaren Tee mit identischem Wert. Die Bedienoberfläche erklärt dies knapp; sie deutet keine verborgene Qualitätswertung an.
- Es gibt nur eine laufende Zubereitung. Eine weitere beginnt erst nach Abschluss oder Zurücksetzen.
- Zurücksetzen gibt die reservierte Kräuterportion zurück. Nach erfolgreichem Abschluss ist sie verbraucht; Zurücksetzen kann dann keine weitere Portion erzeugen.
- Das Verlassen der Ansicht pausiert den Vorgang nicht. Das Pausenmenü dagegen schon.
- Noch nicht abgegebene fertige Tassen bleiben unbegrenzt im Inventar.

## 8. Bestellungen und Verkauf

- Das Bestellbrett bietet je eine Bestellung pro verfügbarer Teesorte; der Spieler wählt eine aktive Bestellung.
- Jede Bestellung verlangt eine Tasse einer genau benannten Sorte und zeigt die Auszahlung vor der Annahme.
- Es gibt keine Frist, Zufriedenheitsanzeige oder Bewertung der Geschwindigkeit.
- Die aktive Bestellung kann kostenlos gewechselt werden. Bereits hergestellter Tee bleibt erhalten.
- An der Ablage wird eine passende Tasse aus dem Inventar gewählt und sichtbar abgestellt.
- Vor der Bestätigung stehen Teesorte und Auszahlung fest. Abbrechen legt die Tasse zurück ins Inventar.
- „Bestellung abgeben“ entfernt genau eine Tasse, zahlt genau einmal aus und schließt die Bestellung ab.
- Eine unpassende oder fehlende Tasse blockiert lediglich die Abgabe; nichts wird verbraucht.
- Neue Bestellungen stehen unmittelbar bereit. Keine Abholzeiten oder simulierten Lieferanten.

## 9. Geld und Verschönerung

Es gibt eine Währung. Einnahmen entstehen ausschließlich durch abgegebene Bestellungen. Die Herstellung hat zunächst keine Geldkosten.

Fünf vorgeschlagene Dekorationen: Laterne am Weg, Bank am See, Teppich in der Hütte, Blumentopf am Eingang und Wandbild. Jede Dekoration hat einen festen Stellplatz und kann einmal gekauft werden. Gekaufte Gegenstände lassen sich dort ein- und ausblenden; sie gehen dabei nicht verloren.

- Ein einfacher Einrichtungskatalog zeigt Vorschau, Preis und Besitzstatus.
- Bei ausreichendem Geld wird der Kauf bestätigt, der Betrag einmal abgezogen und die Dekoration sichtbar platziert.
- Ein Kauf darf das Guthaben nicht unter null senken.
- Die erste Laterne soll nach einer einzigen Bestellung erreichbar sein.
- Weitere Käufe benötigen wenige Bestellungen. Lange Wiederholungen nur zum Geldsammeln sind kein Ziel.
- Der Kauf aller fünf Dekorationen ist das kleine Abschlussziel von Version 0.1. Anschließend kann weitergespielt werden; es gibt keinen erzwungenen Abspann.

## 10. Tageszeit, Schlaf und Wetter

### Tagesablauf

Eine sichtbare Uhr zeigt die Spielzeit. Tag und Nacht wechseln fortlaufend, auch wenn die Figur nicht schläft. Nachts bleibt alles benutzbar und durch warme Beleuchtung gut erkennbar. Kein Ausdauerbalken, keine Müdigkeitsstrafe, kein Umkippen.

Interaktion mit dem Bett bietet freiwillig „Bis zum Morgen schlafen“ an. Dabei springt die Zeit auf das nächste 08:00 Uhr. Pflanzen und laufende Zubereitung werden um die übersprungene Spielzeit vorgerückt. Die Feuchtigkeit läuft dabei regulär ab; für den Zeitsprung ist keine detaillierte Wettersimulation erforderlich.

### Kleiner Schlafbonus

Vorgeschlagene Regel: Wer zwischen 20:00 und 02:00 Uhr schlafen geht, erhält für die nächsten drei neu gestarteten Teezubereitungen den Status „Ausgeruht“. Deren Erhitzungszeit ist um 20 % kürzer. Der Bonus verändert weder Geld noch Qualität und stapelt sich nicht. Er läuft nicht durch bloßes Warten ab. Außerhalb des Fensters funktioniert Schlafen identisch, nur ohne neuen Bonus; ein verbleibender Bonus wird nicht entfernt.

### Wetter

Version 0.1 enthält Sonne und Regen mit einfachen Übergängen. Regen bewässert Beete, verändert Hintergrundgeräusche und verdunkelt die Außenbeleuchtung leicht. Innen bleibt die Atmosphäre warm. Kein Schaden, keine Überflutung und keine Ernteverluste.

Gewitter ist Teil der gewünschten langfristigen Atmosphäre, wird aber auf eine spätere Erweiterung verschoben, sobald der vollständige Spielablauf funktioniert.

## 11. Arbeitswerte für erste Spieltests

Diese Werte sind Vorschläge für das Spielgefühl, keine Aussagen über reale Teezubereitung. Sie werden zentral als Daten hinterlegt.

| Parameter | Startwert |
| --- | --- |
| Startguthaben / Startkräuter | 0 Münzen / 0 Portionen; Pflanzen ist kostenlos |
| Wachstum | 120 Sekunden aktive Echtzeit ohne Gießen |
| Feuchtigkeit | 60 Sekunden; währenddessen doppelte Wachstumsgeschwindigkeit |
| Ertrag | 2 Portionen pro Ernte |
| Temperaturstufen | 80, 90 und 100 °C; zunächst gleiche Spielwirkung |
| Erhitzen / Ziehen | 5 / 15 Sekunden aktive Echtzeit |
| Verkaufspreis | 10 Münzen pro Tasse |
| Dekopreise | Laterne 10, Blumentopf 20, Teppich 30, Bank 40, Wandbild 50 Münzen |
| Tageslänge | 24 Spielstunden entsprechen 24 Minuten aktiver Echtzeit |
| Zeitmessung | Wachstum und Zubereitung verwenden dieselbe Simulationszeit wie die Uhr |

Beim Schlafen entspricht eine übersprungene Spielminute einer Sekunde regulärer Simulationsdauer. Im Pausenmenü laufen weder Uhr, Wetterwechsel, Wachstum noch Zubereitung weiter. Ein erster Test soll besonders klären, ob Wachstum Wartephasen erzeugt und wie oft die Teezubereitung angenehm wiederholt werden kann.

## 12. Speichern, Laden und grundlegende Bedienbarkeit

- Ein lokaler Spielstand; Hauptmenü mit „Neues Spiel“, „Fortsetzen“ und „Beenden“.
- Ein bestehender Spielstand wird bei „Neues Spiel“ erst nach Bestätigung ersetzt.
- Manuelles Speichern im Pausenmenü; automatisches Speichern nach Verkauf, Dekokauf und Schlafen.
- Gespeichert werden Figurposition, Geld, Inventar, Beete mit Wachstums- und Feuchtigkeitszustand, aktive Bestellung, Stationszustand einschließlich reservierter Zutaten und Restzeiten, Uhrzeit, Wetter, Schlafbonus sowie gekaufte und sichtbare Dekorationen.
- Nach Laden geht der Zustand ohne Offline-Fortschritt weiter. Bereits ausgezahlte Bestellungen bleiben abgeschlossen.
- Speichern während kurzer Übergangsanimationen wird bis zu einem stabilen Zustand verzögert. Eine Tasse an der noch unbestätigten Ablage wird zum Speichern ins Inventar zurückgelegt.
- Verständliche Meldungen bei fehlenden Zutaten oder unzureichendem Guthaben; keine stillen Fehlschläge.
- Getrennte Lautstärke für Musik, Umgebung und Effekte; Timer zusätzlich visuell erkennbar.

## 13. Technischer Rahmen und Lernziele

- Engine: Godot 4 Standard ohne .NET. Zu Projektbeginn wurde vom Entwickler „4.7.2“ genannt. Die Projektdatei `project.godot` weist Godot 4.7 mit dem Renderer „GL Compatibility“ und Jolt Physics aus; die Patch-Version im Editor wurde nicht geprüft. Vor versionsabhängigen Anleitungen die tatsächlich installierte Version prüfen. Keine unnötigen Versionswechsel während Version 0.1.
- Sprache: GDScript mit Typangaben; bereits für die Gameplay-Skripte im Einsatz.
- 3D-Welt mit fester Kamera; stationäre Teezubereitung darf als eigene Oberfläche umgesetzt werden.
- Fertige, stilistisch zusammenpassende Low-Poly-Modelle bevorzugen. Für den Prototyp genügen einfache Platzhalter.
- Herkunft und Nutzungsbedingungen verwendeter Assets dokumentieren. Bezahlte Pakete erst nach Budgetentscheidung auswählen.
- Quellcode mit Git verwalten, kleine nachvollziehbare Änderungen erstellen.
- Pflanzen, Rezepte und Dekorationen über Daten definieren. Spiellogik von Darstellung und Eingabe soweit sinnvoll trennen.
- Überschaubare Verantwortlichkeiten: Figur/Interaktion, Beete, Inventar, Teestation, Bestellungen/Geld, Dekoration, Zeit/Wetter und Spielstand.
- Zunächst keine Plugin-Plattform, generischen Fabriken oder umfangreichen Frameworks bauen.

Lernziele sind Godot-Szenen und Nodes, Eingaben und Kollisionen, Signale, Benutzeroberflächen, Zustandsabläufe, Animation/Sound, datengesteuerte Inhalte und zuverlässiges Speichern. Eine feste Leistungskennzahl wird nach dem ersten exportierten Prototyp auf einem dokumentierten Test-PC festgelegt; zunächst sind flüssige Steuerung und stabile Darstellung auf der kleinen Karte das Ziel.

## 14. Entwicklungsreihenfolge

| Meilenstein | Überprüfbares Ergebnis |
| --- | --- |
| M1 – Bewegen und interagieren | Figur läuft auf einer kleinen Fläche und erkennt ein benutzbares Beet. |
| M2 – Erster Anbau | Minze pflanzen, kurz wachsen lassen und als Inventarmenge ernten. |
| M3 – Erste Tasse | Vereinfachte Teestation verarbeitet eine Portion Minze zu genau einer Tasse, die aktiv abgeholt wird. |
| M4 – Erster vollständiger Prototyp | Eine Bestellung abgeben, Geld erhalten und eine sichtbare Laterne kaufen. |
| M5 – Spielstand | Diesen Ablauf speichern, Anwendung schließen und verlustfrei fortsetzen. |
| M6 – Inhalt und Ritual | Drei Kräuter/Rezepte, alle Handgriffe der Teestation, fünf Dekorationen. |
| M7 – Atmosphäre und Tagesablauf | Tag/Nacht, Regen, freiwilliges Schlafen und kleiner Bonus. |
| M8 – Version 0.1 abschließen | Menü, Audioeinstellungen, Sonderfälle prüfen und Windows-Version exportieren. |

Welche Meilensteine umgesetzt und bestätigt sind, steht in [CLAUDE.md](CLAUDE.md) unter „Aktueller Stand“.

Jeder Meilenstein muss spielbar sein, bevor der nächste größere Funktionsblock beginnt. Speichern wird beim Hinzufügen weiterer Systeme jeweils erweitert. Bei M4 wird geprüft, ob sich der Grundablauf angenehm anfühlt; Umfang und Arbeitswerte werden nötigenfalls vereinfacht.

## 15. Abnahmekriterien für Version 0.1

- [ ] Ein neues Spiel kann ohne externe Eingriffe von der ersten Pflanzung bis zum ersten Dekokauf gespielt werden.
- [ ] Alle drei Kräuter wachsen, werden geerntet und ergeben den passenden Tee.
- [ ] Die Teestation lässt sich in jedem stabilen Zustand verlassen und anschließend fortsetzen.
- [ ] Fertiger Tee wartet an der Station auf aktive Abholung; diese überträgt genau eine Tasse und gibt die Station frei. Mehrfaches Interagieren erzeugt keine zusätzlichen Tassen.
- [ ] Timer ignorieren, nachts wach bleiben und reife Pflanzen stehen lassen verursacht keine Nachteile.
- [ ] Ohne Gießen und ohne Schlafbonus bleibt der gesamte Fortschritt möglich.
- [ ] Wechseln einer Bestellung und Zurücksetzen der Station erzeugt weder Ressourcenverlust noch zusätzliche Ressourcen.
- [ ] Eine abgegebene Tasse zahlt genau einmal aus; mehrfaches schnelles Klicken erzeugt kein zusätzliches Geld.
- [ ] Alle fünf Dekorationen sind kaufbar, sichtbar und nach Laden weiterhin vorhanden.
- [ ] Speichern/Laden während Pflanzenwachstum und Teezubereitung erhält Mengen und Fortschritt korrekt.
- [ ] Regen bewässert, Pause hält die Simulation an, Schlafen rückt sie nachvollziehbar vor.
- [ ] Auch nach dem Kauf aller Dekorationen bleibt das Spiel spielbar.
- [ ] Ein Windows-Export lässt sich außerhalb des Godot-Editors starten, bedienen, speichern und erneut laden.

Manuelle Spieltests reichen für Darstellung und Atmosphäre. Gezielte automatisierte Tests sind besonders bei Ressourcenverbrauch, einmaliger Auszahlung und Spielstandwiederherstellung sinnvoll.

## 16. Nicht Teil von Version 0.1

Sichtbare Gäste, Wegfindung, Tischbedienung, Beziehungen, Dialogsysteme, Multiplayer, Kämpfe, Tiere, Angeln, Schwimmen, offene Welt, Jahreszeiten, Gewitter, freie Gebäudeplatzierung, Geländeverformung, Saatguthandel, beliebige Teemischungen, Qualitätsbewertungen, physikalische Flüssigkeiten, Controller-/Mobilunterstützung, Cloud-Speicherung und öffentliche Veröffentlichung.

Spätere Erweiterungen sollen vorzugsweise einzeln erfolgen: freies Dekorieren, neue Mischungen, einzelne Gäste, größere Terrasse oder Gewitter. Vor jeder Erweiterung wird geprüft, ob sie den gemütlichen Kern stärkt und in den verfügbaren Zeitrahmen passt.

## 17. Arbeitsweise

Wie die Entwicklung begleitet wird (kleine Schritte, Erklärungen, der Entwickler programmiert selbst), ist in [CLAUDE.md](CLAUDE.md) unter „Arbeitsweise“ festgehalten.
