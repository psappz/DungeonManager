# Uldaman – Quellenprüfung und Kartenentwurf

Stand: 2026-11-04. Vanilla-/Classic-Grundlage; eigene schematische Zeichnung, nicht maßstabsgetreu. Vier SVG-Blätter mit jeweils eigener JSON-Legende.

## Quellen und Befund

Der [historische BradyGames-Dungeonführer](https://ptgmedia.pearsoncmg.com/imprint_downloads/brady/wow/uldaman/uldaman_lr.pdf), Seiten 13–18, wurde anhand der vorhandenen lokalen PDF-Kopie gelesen; die Übersicht auf Seite 13 wurde visuell geprüft. Die Karte wurde nicht nachgezeichnet. Die beschriebenen Abzweige belegen das zusammenhängende Höhlennetz, den Hintereingang und die Temple-Hall-Schleife. Die Schlussfolge führt über das Wächterereignis zu Archaedas und danach in die Schatzkammer. Die genaue räumliche Faltung des Abstiegs ist daraus nicht zuverlässig ableitbar.

Der [Classic-Dungeonguide von Icy Veins](https://www.icy-veins.com/wow-classic/uldaman-dungeon-guide) bestätigt die Besuchsfolge mit Bossabstechern. Die drei Zwerge sind ein gemeinsamer Begegnungsmarker; für Allianzgruppen sind sie freundlich. Ironayas Zugang setzt den zusammengesetzten Staff of Prehistoria voraus.

Der [Classic-Questguide](https://www.icy-veins.com/wow-classic/uldaman-quests-guide) und der [Questtext von Find the Gems](https://www.wowhead.com/classic/quest=2201/find-the-gems) klären die Edelsteinzuordnung: Topaz bei den Zwergen, Ruby bei Galgann und Sapphire als Grimlok-Beute. Die Discs folgen auf den Endboss. Objektmarker werden nur auf Raumebene, nicht als präzise Koordinaten gesetzt.

Es wurde kein vollständiger Videorundgang ausgewertet. Neuere Forever-Seiten und eine gefundene Tabletop-Adaption wurden nicht als Versionsnachweis verwendet. Eine gesonderte Prüfung möglicher Forever-Abweichungen steht aus.

## Dateien und Layout

| Blatt | Inhalt |
| --- | --- |
| `dungeonmanager-uldaman-uebersicht.svg` und `.json` | Verbindungsschema der Detailblätter I–III |
| `dungeonmanager-uldaman-01.svg` und `.json` | Haupteingang, frühe Hallen, Dig Two, Map Chamber und Ironaya-Abstecher |
| `dungeonmanager-uldaman-02.svg` und `.json` | Zentrales Höhlennetz mit zweitem Eingang und Bossabzweigen |
| `dungeonmanager-uldaman-03.svg` und `.json` | Getrennte Felder für oberen Wächterraum und unteren Endbereich |

Die Nummerierung verwendet acht Begegnungen. Die drei Lost Dwarves teilen Nummer 1; die individuellen Namen stehen in den JSON-Hinweisen. Die Blattübersicht enthält nur das Verbindungsschema, keine zusätzlichen Bossnummern.

## Übergänge und Unsicherheiten

A verbindet Blatt 01 mit 02, B verbindet 02 mit 03. C verbindet die beiden lokalen Höhenfelder auf Blatt 03. Alle Buchstaben stehen jeweils an beiden Endpunkten der Detailblätter. Die Übersicht wiederholt nur A und B als Blattverbindungen.

- Gestrichelte Gangkanten bedeuten: Anschluss belegt, konkrete Biegung oder Breite nicht gesichert.
- Der Abstieg C ist ausdrücklich keine vermessene Rampe. Seine genaue Form und die Überlagerung der Räume bleiben offen.
- Lokale Stufen im Temple-Hall-Bereich sind vereinfacht; unbelegte Sprungabkürzungen wurden ausgelassen.
- Gestrichelte Questmarkierungen stehen für ungeprüfte Positionen innerhalb des belegten Bereichs.
- Die Karte bildet die wesentlichen besuchbaren Abschnitte ab. Ungeprüfte kleine Nischen und Außenbereiche wurden nicht erfunden.
- Annoras Kammer ist als südöstlicher Seitenast enthalten, ohne unzulässiges Trainersymbol. Die Bedeutung steht im JSON.

## Technische Prüfung

Alle vier SVGs wurden gerendert und bei 512 × 512 visuell geprüft. Erlaubte Elementtypen: `path`, `rect`, `circle`, `text` innerhalb des SVG-Wurzelelements. Keine eingebetteten Bilder, Filter oder Verläufe. Bildtexte sind ausschließlich Bossnummern, E, Übergangsbuchstaben, Q-Marker und römische Feldnummern.

Schrift 32 px, Bosskreise 60 px Durchmesser; Rahmen 1 px, andere Linien mindestens 3 px. JSON-Dateien wurden gelesen, Übergangspaare und Bossnummern geprüft. Diese Prüfung bestätigt Lesbarkeit und Dateikonsistenz, nicht einen vollständig verifizierten Grundriss.
