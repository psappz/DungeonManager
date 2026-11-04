# Blackrock Depths – Recherche und Neuzeichnung

Stand: 2026-11-04. Neue Classic-v2-Karten: eine Übersicht und vier Detailblätter, jeweils SVG und JSON. Die früheren Stilentwürfe bleiben ausschließlich im Legacy-Ordner des Archivs. Die neuen Karten sind schematisch und nicht positionsgenau.

## Quellen und geklärte Verbindungen

Die beiden Wowhead-Classic-Guides für [Detention Block](https://www.wowhead.com/classic/guide/blackrock-depths-detention-block-dungeon-strategy-wow-classic) und [Shadowforge City](https://www.wowhead.com/classic/guide/blackrock-depths-shadowforge-city-dungeon-strategy-wow-classic) wurden textlich ausgewertet. Sie belegen die Hauptfolge von Gefängnis und Arena über die östliche Stadt sowie den weiteren Weg durch Werkstatt, Taverne und inneren Tempelbereich. Der Arena-Ausgang führt zur Garrison; die Galerie erreicht den Domicile-/Schrein-Abzweig. Vom Handwerksbereich führt ein Abstieg zur Black Anvil. Die Innenräume sind neu abstrahiert, nicht aus einer Referenzkarte übernommen.

Die [Beschreibung des Shadowforge Lock](https://warcraft.wiki.gg/wiki/The_Shadowforge_Lock) erklärt die entscheidende Zustandsänderung: Der Mechanismus schließt das untere Highway-Tor und ermöglicht den oberen Übergang zur West Garrison. Die Notiz zur späteren Entfernung der Schlüsselpflicht wurde nicht auf Vanilla übertragen. Die Karte zeigt beide Wege; das JSON beschreibt ihre Abhängigkeit. Ergänzend wurden die [Regionsbeschreibungen](https://warcraft.wiki.gg/wiki/Blackrock_Depths_Regions) abgeglichen.

Die [Molten-Bridge-Beschreibung](https://warcraft.wiki.gg/wiki/Molten_Bridge) bestätigt den Seitenweg Richtung Molten Core und den Core Fragment beim Portal. Die Lava-Abkürzung ist zwar beschrieben, ihre sicheren Zwischenpunkte wurden aber nicht visuell verifiziert und werden nicht als Route gezeichnet. Black Forge und Black Anvil bleiben klar getrennte Orte.

Die [Classic-Beschreibung der Upper City](https://www.icy-veins.com/wow-classic/blackrock-depths-upper-city-dungeon-guide) wurde ergänzend für Garrison-Zugang und Begegnungen geprüft. Ihre ausdrücklich mit Season of Discovery überschriebenen Beutetabellen wurden nicht als Vanilla-Grundlage verwendet. Für die Tavernengeschosse wurden außerdem historische Kommentare zum [Hurley-Zugang](https://www.wowhead.com/wotlk/npc=9537/hurley-blackbreath) und die [Regionsbeschreibung der Taverne](https://wowpedia.fandom.com/wiki/Blackrock_Depths_regions) herangezogen. Die konkrete Treppenform bleibt ungeprüft.

Kein vollständiger Videorundgang wurde ausgewertet. Aktuelle Forever-Seiten, die moderne Karten verwenden, dienen nicht als Nachweis einer Vanilla-Geometrie.

## Aufteilung

| Blatt | Felder |
| --- | --- |
| `dungeonmanager-blackrock-depths-uebersicht.svg/.json` | Verbindungsschema der vier Detailblätter |
| `dungeonmanager-blackrock-depths-01.svg/.json` | Gefängnis und Arenaboden; East Garrison mit Aufstieg zur Galerie |
| `dungeonmanager-blackrock-depths-02.svg/.json` | Östliche Stadt mit Schrein, Vault und Handwerksbereich; darunter Highway und Black Anvil |
| `dungeonmanager-blackrock-depths-03.svg/.json` | West Garrison/Manufactory; unteres und oberes Tavernengeschoss separat |
| `dungeonmanager-blackrock-depths-04.svg/.json` | Innerer Weg mit Summoners’ Tomb; Forge-/Raid-Abzweig; Lyceum und Thronbereich |

Die römischen Ziffern der Übersicht bezeichnen Blätter. In Detailblättern bezeichnen sie lokale Felder. Die Felder sind keine Behauptung durchgehender globaler Stockwerke.

## Markierungen und Ereignisse

23 nummerierte Begegnungspositionen sind dargestellt. Arena und The Seven teilen ihre jeweilige Nummer mit den zugehörigen Varianten bzw. Gruppenmitgliedern; deren Namen stehen im JSON. Moira ist als Begegnungsposition enthalten: Die Rettungsquests verlangen ausdrücklich, sie am Leben zu lassen. Optionale Tavernenkämpfe und die gesamte Route sind keine verbindliche Tötungsreihenfolge.

A, B, C, D, F, G, H, J, K, L und M bilden die Übergangspaare. Die Übersicht wiederholt C, D, F und K. Tore erscheinen als Doppelstriche; die Wirkung des Mechanismus, Ereignisbedingungen und Schlüssel stehen im JSON. Unbeschriftete kleine Rechtecke zeigen den Lock beziehungsweise Anvil/Forge. T bezeichnet ausschließlich das Molten-Core-Instanzportal, keinen später hinzugefügten Transporter.

## Was weiterhin unsicher ist

- Q1–Q3 stehen für den Gefängnisbereich. Die einzelnen Zellpositionen und ihre Reihenfolge sind nicht zuverlässig verifiziert; es wurden keine zusätzlichen Zellen konstruiert.
- Die genaue Faltung der Rampen zwischen Galerie, Domicile, Hall of Crafting und Anvil ist offen. Die Endpunkte der Verbindungen sind belegt; die Gänge sind gestrichelt.
- Dasselbe gilt für die obere Garrison-Querung, lokale Werkstattrampen und die interne Tavernentreppe J.
- Die Positionen von Questobjekten sind überwiegend nur auf Raumebene gesichert. Unsichere lokale Positionen stehen im jeweiligen `uncertain`-Feld; bewegliche oder seltene Gegner erhalten gestrichelte Kreise.
- Der Forge-Abzweig und Lyceum-Zugang sind getrennt dargestellt, ohne genaue Höhen oder einen sicheren Lava-Aufstieg zu behaupten.
- Dark-Keeper-Varianten, Nebenraumdetails und Eskorte-Wegpunkte wurden nicht erfunden. Ihr Fehlen bzw. die variable Auswahl ist im JSON vermerkt.
- Änderungen durch WoW Forever sind mit der Classic-Recherche nicht gesondert bestätigt.

## Prüfung

Alle fünf SVGs wurden bei 512 × 512 gerendert und visuell geprüft. XML-Elementtypen, Bildtexte, Farben, Linienbreiten, Bosskreise, JSON-Dateien und Übergangspaare wurden geprüft. Schriftgröße 32 px, Bosskreise 60 px Durchmesser; Rahmen 1 px und andere Linien mindestens 3 px. Kein Titel, keine Legende und kein erläuternder Text stehen in den Bildern. Es gibt keine Bilder, Filter, Verläufe oder eingebetteten Schriften.

Die Prüfung bestätigt die Dateikonsistenz und Lesbarkeit, keinen vollständig verifizierten oder maßstäblichen Grundriss.
