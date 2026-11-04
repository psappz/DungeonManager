# Sunken Temple – Ebenenprüfung und Kartenentwurf

Stand: 2026-11-04. Grundlage ist der vollständige Vanilla-/Classic-Dungeon einschließlich Untergeschoss. Keine Cataclysm-Kürzung und keine Season-of-Discovery-Raidkarte. Eigene schematische Zeichnung; nicht maßstabsgetreu.

## Recherche

Geprüft wurden der [historische BradyGames-Dungeonführer](https://ptgmedia.pearsoncmg.com/imprint_downloads/brady/wow/atalhakkar/atalhakkar_gslr.pdf), insbesondere Seiten 6–9, die [Classic-Bossbeschreibung von Icy Veins](https://www.icy-veins.com/wow-classic/sunken-temple-dungeon-guide) und die auffindbaren Abschnitte des [Wowhead-Classic-Guides](https://www.wowhead.com/classic/guide/temple-of-atalhakkar-sunken-temple-dungeon-strategy-wow-classic). Die vorhandene PDF-Kopie wurde textlich ausgewertet, ihre relevanten Ebenenübersichten visuell betrachtet. Keine Referenzgrafik wurde kopiert oder nachgezeichnet; kein vollständiger Videorundgang wurde ausgewertet.

Der historische Führer klärt die vier Abgänge vom Instanzportal: rechts zum Pit of Refuse, vorne rechts zur Hall of Serpents, vorne links über Loros Podest zur Hall of the Cursed und links zur Drachenebene. Er unterscheidet innere Zugänge für Gasher und Zul’Lor von äußeren Treppen mit Zwischenpodesten für die vier übrigen Wächter. Die genaue Form dieser Treppen wird nicht als gesichert ausgegeben.

Die Classic-Beschreibung bestätigt die sechs Wächter und das Statuenrätsel. Die Aktivierungsfolge ist South, North, Southwest, Southeast, Northwest, Northeast. Die Karte unterscheidet diese Questmarker ausdrücklich von den nummerierten Bossen.

## Dateien

| Blatt | Inhalt |
| --- | --- |
| `dungeonmanager-sunken-temple-uebersicht.svg/.json` | Verbindungsschema mit Instanzportal und vier Abgängen |
| `dungeonmanager-sunken-temple-01.svg/.json` | Hall of Serpents und Pit of Refuse in getrennten Feldern |
| `dungeonmanager-sunken-temple-02.svg/.json` | Hall of the Cursed, sechs Wächterledges und vereinfachte Zugänge |
| `dungeonmanager-sunken-temple-03.svg/.json` | Drachenebene mit seitlichen Begegnungsräumen |

Das Übersichtsblatt ist ausdrücklich ein Verbindungsschema. Seine Knoten sind keine zusätzlichen Dungeonräume. Die Buchstaben A–D stehen dort und an ihrem jeweiligen Ziel auf dem Detailblatt. F kennzeichnet einen gerichteten Sprung zwischen den beiden Feldern von Blatt 01. Der sichere Rückweg wird über den Eingangsknoten beschrieben.

## Besuchsfolge und Markierungen

Für diese vollständige Besuchsroute sind zuerst die optionalen unteren Begegnungen nummeriert, dann die Wächter im Uhrzeigersinn, anschließend die Begegnungen der Drachenebene. Das Avatar-Ereignis steht als optionaler Abschluss am Ende. Die Nummerierung ist keine zwingende Kampf- oder Freischaltungsreihenfolge. Der Spawn of Hakkar ist eine eigene Begegnung und nicht der Avatar of Hakkar.

Die Questmarker enthalten das Statuenrätsel, den unteren Altar und das Idol, Jammal’ans Questbeute, den Essence Font und das Avatar-Ritual. Die vier kleinen unnummerierten Kreise im westlichen Raum stehen für die Ritualfeuer. Außenbereiche und ihre seltenen Gegner sind nicht Teil dieser Instanzblätter.

## Verbleibende Unsicherheiten

- Blatt 02 zeigt die belegten Verbindungen als gestrichelte, vereinfachte Zugänge. Diese Linien sind keine Behauptung gerader Treppen durch Wände. Insbesondere die vier äußeren Treppen und ihre Podeste benötigen für eine positionsgenaue Karte weitere Erfassung.
- Loro liegt am Zwischenpodest des Zugangs; die Fortsetzung zum Ring ist grafisch zusammengefasst. Nicht alle dargestellten Flächen liegen auf gleicher Höhe.
- Konkrete Gangbiegungen, Raummaße, Poolkonturen und lokale Questpositionen sind nicht vermessen. Betroffene Umrisse oder Marker sind gestrichelt.
- Der Abstieg F ist ein belegter Sprung; die konkrete Absprung- und Landestelle ist nur ungefähr dargestellt. Ein Rücksprung wird nicht behauptet.
- Bewegliche Gegner erhalten Suchbereichsmarker statt erfundener fester Spawnkoordinaten.
- Andere Sprünge, insbesondere durch das zentrale Loch der Drachenebene oder von Wächterbalkonen, wurden ohne ausreichend geprüfte Endpunkte ausgelassen.
- Mögliche Abweichungen in WoW Forever sind mit diesen Classic-Referenzen nicht verifiziert.

## Prüfung

Alle SVGs verwenden ausschließlich die vereinbarten Elemente, Farben und Bildzeichen. Schrift 32 px, Bosskreise 60 px Durchmesser, Rahmen 1 px und übrige Linien mindestens 3 px. Die vier Blätter wurden bei 512 × 512 gerendert und visuell geprüft; ein zunächst unterbrochener Zugang und eine Überlappung im Schema wurden korrigiert. JSON-Dateien, 16 eindeutige Bossnummern und fünf Übergangspaare wurden geprüft. Dies bestätigt die technische Konsistenz und Lesbarkeit, keine vollständige geometrische Genauigkeit.
