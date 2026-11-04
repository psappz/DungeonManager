# Gnomeregan – Recherche zu Ebenenverbindungen

Stand: 2026-11-04. Ziel: eigene schematische Vanilla-Karte, keine maßstäbliche Rekonstruktion. Vier SVG-Blätter mit jeweils eigener JSON-Legende erstellt: Übersicht und Detailblätter 01–03.

## Ergebnis

Die Hauptverbindungen sind ausreichend dokumentiert, um den Kartenentwurf wieder aufzunehmen. Lokale Treppenformen und Sprungstellen bleiben gesondert zu prüfen. Eine vollständige visuelle Prüfung eines Classic-Laufs ist noch nicht erfolgt.

## Rundgang und Quellenbewertung

- [PhilpseyForce: Classic WoW Guide: Gnomeregan](https://www.youtube.com/watch?v=GhGlT48i_LI), veröffentlicht am 31. Januar 2019, 38:33 Minuten. Das zeitgestempelte Transkript wurde ausgewertet; die Aufzug-Passage zusätzlich im Player aufgerufen. Kartenbesprechung ab 19:14, Rundgang ab 24:30. Das Video erschien vor dem offiziellen Classic-Start und erwähnt Änderungen seit Cataclysm. Es ist deshalb allein kein hinreichender Versionsbeleg.
- [BradyGames: Gnomeregan, Vanilla-era guide](https://ptgmedia.pearsoncmg.com/imprint_downloads/brady/wow/gn/gnlr.pdf), PDF-Seiten 8–14 (gedruckte Seitenzahlen). Zeitgenössische Gegenprüfung der Hauptverbindungen; keine Übernahme der Kartengrafik.
- [Warcraft Wiki: Launch Bay](https://warcraft.wiki.gg/wiki/Launch_Bay): zusätzliche Beschreibung der Abzweige. Die Seite enthält auch spätere Inhalte; nur mit dem alten Guide übereinstimmende Verbindungen übernehmen.
- [Xaryu Clips: I DID GNOMEREGAN ON HARDCORE CLASSIC ft. SAVIX (FULL RUN)](https://www.youtube.com/watch?v=6YOBFZQ5jtU): weiterer gefundener Kandidat für eine visuelle Classic-Gegenprüfung, hier nicht ausgewertet.

## Belegtes Verbindungsgerüst

Die folgenden Verbindungen beschreibt der [BradyGames-Guide](https://ptgmedia.pearsoncmg.com/imprint_downloads/brady/wow/gn/gnlr.pdf):

| Abschnitt | Verbindung | PDF-Seite |
| --- | --- | --- |
| Hall of Gears, oben | Südost: Grubbis-Abstecher; Südwest: Verzweigung zu Clean Zone und Dormitory | 8–9 |
| Clean Zone | Treppenzugang aus der südwestlichen Verzweigung; unterer Ausgang zum unteren Dormitory | 9 |
| Dormitory | Weiterweg zur unteren Hall of Gears; Punchograph B unten | 10 |
| Hall of Gears, unten | Westlicher, zweistufiger Korridor zum oberen Launch Bay | 11 |
| Launch Bay | Brücke zur Bossplattform; südliche Rampe zur tieferen Verzweigung | 11 |
| Launch Bay, unten | Absteigender Gang zu Tinker’s Court; Seitenverbindung zu Engineering Labs | 12 |
| Engineering Labs | Zugänge vom Launch Bay, vom Endboss-Gang und vom Workshop Entrance; Aufzug im Nordosten verbindet beide Ebenen | 13–14 |

Die [Launch-Bay-Beschreibung](https://warcraft.wiki.gg/wiki/Launch_Bay) präzisiert: Nach der südöstlichen Rampe führt der nordwestliche Abzweig zum unteren Launch Bay, der andere Weg zum oberen Engineering-Labs-Bereich. Der Seitenweg vom Gang zu Tinker’s Court erreicht dagegen die unteren Engineering Labs. Dadurch entsteht eine Schleife, keine einfache lineare Bosskette.

## Zeitmarken zur gezielten Nachprüfung

Diese Stellen wurden anhand des [Video-Transkripts](https://www.youtube.com/watch?v=GhGlT48i_LI) lokalisiert; die Zeitfenster sind keine Behauptung einer lückenlosen visuellen Prüfung:

| Zeit | Thema |
| --- | --- |
| 27:18–27:50 | Grubbis-Abstecher und Rückweg |
| 28:25–30:15 | Clean Zone, Kernobee, Dormitory und untere Hall of Gears |
| 30:24–31:36 | Verbindungskorridor, Launch Bay und Electrocutioner-Plattform |
| 31:46–32:39 | Sprungabkürzung und umgangener Normalweg |
| 33:45–35:11 | Punchograph D, Aufzug und Crowd Pummeler |
| 35:31–37:56 | Endboss-Gang, Thermaplugg und Safe |

## Verbleibende Unsicherheiten

- Genaue Treppenführung zwischen den Dormitory-Bereichen und die Form der kleinen Nebenräume. Keine zusätzlichen Zimmer aus dem Gedächtnis ergänzen.
- Exakte Start- und Landepunkte der Sprungabkürzungen. Nur nach eindeutiger Vanilla-/Classic-Bestätigung als gerichtete Übergänge zeichnen.
- Kollisionsgrenzen der Engineering Labs: Eine im Video erwähnte unsichtbare Barriere ist noch kein bestätigtes Vanilla-Detail. Den belegten Aufzug verwenden; keinen frei erfundenen Sprung ergänzen.
- Questmarker auf einem gemeinsamen Grundriss lokalisieren, besonders Kernobee und einzelne Punchograph-Standorte. Die Zuordnung zu einem Raum ersetzt keine geprüfte Position innerhalb des Raums.
- Änderungen durch WoW Forever sind nicht durch diese Vanilla-Recherche abgedeckt.

## Konsequenz für den Entwurf

Umgesetzt sind ein Übersichtsblatt und drei Detailblätter: Eingangsbereich mit Hall of Gears/Clean Zone/Dormitory; Launch Bay und Verbindungskorridore; Engineering Labs und Tinker’s Court. Innerhalb jedes Blatts getrennte Felder für lokale Höhenstufen. Diese Einteilung ist eine Layoutentscheidung, keine Behauptung von drei durchgehenden Dungeonstockwerken.

Übergänge erhalten paarige Buchstaben; der Aufzug bekommt ein Pfeilsymbol und seine Erklärung nur im JSON. Unsichere Geometrie bleibt gestrichelt und wird unter `uncertain` benannt. Die Hauptstruktur muss nicht länger wegen vollständig unbekannter Ebenenverbindungen übersprungen werden.


## Stand des Kartenentwurfs

- `dungeonmanager-gnomeregan-uebersicht.svg/.json`: Verbindungsschema der drei Detailblätter.
- `dungeonmanager-gnomeregan-01.svg/.json`: Hauptzugang, Hall of Gears, Grubbis-Abstecher, Clean Zone und Dormitory.
- `dungeonmanager-gnomeregan-02.svg/.json`: beide lokalen Launch-Bay-Ebenen und Rampenverzweigung.
- `dungeonmanager-gnomeregan-03.svg/.json`: beide Engineering-Labs-Ebenen, Aufzug, Hintereingang und Endbossbereich.

Die SVGs enthalten ausschließlich die erlaubten Markierungen. Questpositionen mit ungesicherter lokaler Platzierung und der seltene Boss sind gestrichelt markiert. Nicht belegte Sprungstellen sind ausgelassen und im JSON genannt. Die Dormitory-Geometrie bleibt bewusst vereinfacht; der Entwurf ist kein vollständig verifizierter Grundriss.

Bossnummern 1–6 folgen einer gewählten vollständigen Besuchsroute; der seltene Dark Iron Ambassador ist optional. Die Nummern sind blattübergreifend eindeutig. Die Übersicht enthält keine Bossmarker, sondern nur Blattverbindungen. E bezeichnet jeweils einen Instanzeingang, J den Aufzug. Englische Namen und Bedeutungen stehen ausschließlich in den Begleitdateien.

Prüfung: XML und JSON gelesen, erlaubte SVG-Elemente und Bildzeichen geprüft, Bosskreise mit 60 px Durchmesser und Schriftgröße 32 px; alle vier Blätter als 512 × 512 gerendert und visuell geprüft. Rahmen sind 1 px, sonstige Linien mindestens 3 px. Übergänge A, B, C, D, F, G, H und J erscheinen jeweils zweimal auf den Detailblättern. Keine maßstäbliche oder koordinatengenaue Aussage.
