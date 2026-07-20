# EXEMPLE 2 : Creation du profil "Bus interurbain Transports Madagascar"

## Etape 1 : Identification

| Champ | Valeur |
|-------|--------|
| Nom du profil | Bus interurbain Antananarivo — Fianarantsoa |
| Organisation | Transports Madagascar |
| Type de vehicule | Bus |
| Description | Bus 40 places pour trajet longue distance. Identification conducteur, georeperage, buzzer, CAN bus. |

### A dire :

> "Je vais creer un profil pour un bus interurbain qui fait le trajet Antananarivo — Fianarantsoa. C'est un bus de 40 places qui a besoin d'identification conducteur et de georeperage pour suivre l'itineraire. Le CAN bus permet de lire les donnees du moteur pour la maintenance."

---

## Etape 2 : Selection du modele

| Champ | Valeur |
|-------|--------|
| Fournisseur | Teltonika |
| Modele | FMB640 |

**Fiche technique affichee :**
- Plage de tension : 10-50V
- Entrees numeriques : 4
- Entrees analogiques : 2
- Sorties numeriques : 4
- CAN bus : Oui (2 canaux)
- 1-Wire : Oui
- RS232 : Oui
- RS485 : Oui
- Accelerometre : Oui
- IP : IP65
- GPS : Oui

### A dire :

> "Pour ce bus, je choisis le Teltonika FMB640. Il a CAN bus a 2 canaux pour lire les donnees du moteur, RS232 pour connecter des peripheriques comme un lecteur de badge, et RS485 pour d'autres capteurs."

---

## Etape 3 : Fonctionnalites (ce que vous cochez)

| Fonctionnalite | Cochee ? | Pourquoi ? |
|----------------|----------|------------|
| **fuel_monitoring** | OUI | Suivre la consommation du bus |
| **geofencing** | OUI | Verifier l'itineraire Antananarivo — Fianarantsoa |
| **driver_id** | OUI | Identifier le conducteur (badge) |
| **buzzer_feature** | OUI | Alerter pour arrets et depassement vitesse |
| **green_driving** | OUI | Economie de carburant et conduite sure |
| **crash_detection** | OUI | Securite des 40 passagers |

### A dire :

> "Je selectionne les fonctionnalites necessaires : fuel_monitoring pour surveiller le carburant, geofencing pour verifier que le bus suit bien l'itineraire, driver_id pour savoir qui conduit, buzzer_feature pour les alertes, green_driving pour encourager une conduite economique, et crash_detection pour la securite des passagers."

---

## Etape 4 : Validation

**Systeme determine automatiquement :**

| Type | Elements requis |
|------|-----------------|
| **Capteurs** | fuel_level_monitor, ignition, driver_identification_monitor, engine, engine_speed |
| **Peripheriques** | Driver Alarm Buzzer (alerte sonore), iButton Driver ID Reader (badge conducteur) |

### A dire :

> "Le systeme determine automatiquement les capteurs et peripheriques requis. Pour ce bus, il faut un capteur de carburant, un contact ignition, un identification conducteur, et des capteurs moteur. Pour les peripheriques, il faut un buzzer pour les alertes de depassement et un lecteur iButton pour les badges conducteur."

---

## Resultat du scoring (contre TOUS les modeles)

| Modele | Marque | Score | Compatible ? |
|--------|--------|-------|-------------|
| **FMB640** | Teltonika | **95/100** | Oui |
| **FMB641** | Teltonika | **95/100** | Oui |
| **FMP100** | Teltonika | **95/100** | Oui |
| FMB920 | Teltonika | 55/100 | Oui |
| CAREU U1 | Systech | 80/100 | Oui |
| Ucan | Systech | 40/100 | Oui |
| JT700 | Jointech | 10/100 | Non |

### A dire :

> "Le scoring compare le profil contre tous les modeles. Les meilleurs sont le FMB640, FMB641 et FMP100 avec 95/100. Meme le CAREU U1 de Systech obtient 80/100 car il a CAN bus et RS232. Les cadenas Jointech sont incompatibles avec seulement 10/100."

---

## Resume pour la demo

1. **Cliquez** "+ Nouveau Profil"
2. **Remplissez** les infos (Etape 1)
3. **Choisissez** Teltonika FMB640 (Etape 2)
4. **Cochez** fuel_monitoring, geofencing, driver_id, buzzer_feature, green_driving, crash_detection (Etape 3)
5. **Validez** (Etape 4)
