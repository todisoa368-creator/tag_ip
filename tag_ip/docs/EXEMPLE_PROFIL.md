# EXEMPLE 1 : Creation du profil "Camion frigorifique Soa Pharma"

## Etape 1 : Identification

| Champ | Valeur |
|-------|--------|
| Nom du profil | Camion frigorifique Soa Pharma |
| Organisation | Soa Pharma Distribution |
| Type de vehicule | Camion (truck) |
| Description | Transport de vaccins et medicaments thermosensibles. Sonde temperature 1-Wire, RS232 pour sonde precise, CAN bus, georeperage. |

### A dire :

> "Je vais creer un profil pour un camion frigorifique de Soa Pharma. Ce camion transporte des vaccins qui doivent rester au froid. Il a besoin de capteurs de temperature et de surveillance de la chaine du froid."

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
- CAN bus : Oui
- 1-Wire : Oui (pour sonde temperature)
- RS232 : Oui (pour sonde precise)
- RS485 : Oui
- Accelerometre : Oui
- IP : IP65
- GPS : Oui

### A dire :

> "Pour ce camion, je choisis le Teltonika FMB640. Il a CAN bus pour lire les donnees du moteur, 1-Wire pour connecter une sonde de temperature, et RS232 pour une sonde carburant precise. C'est le modele ideal pour un vehicule frigorifique."

---

## Etape 3 : Fonctionnalites (ce que vous cochez)

| Fonctionnalite | Cochee ? | Pourquoi ? |
|----------------|----------|------------|
| **fuel_monitoring** | OUI | Suivre le carburant du camion |
| **geofencing** | OUI | Verifier que le camion reste sur l'itineraire |
| **driver_id** | OUI | Savoir qui conduit le camion |
| **buzzer_feature** | OUI | Alerter si temperature mauvaise |
| **green_driving** | OUI | Economie de carburant |
| **crash_detection** | OUI | Securite des vaccins |

### A dire :

> "Je selectionne les fonctionnalites necessaires : fuel_monitoring pour surveiller le carburant, geofencing pour verifier l'itineraire, driver_id pour identifier le conducteur, buzzer_feature pour alerter si la temperature n'est pas bonne, green_driving pour economiser le carburant, et crash_detection pour la securite des vaccins."

---

## Etape 4 : Validation

**Systeme determine automatiquement :**

| Type | Elements requis |
|------|-----------------|
| **Capteurs** | fuel_level_monitor, ignition, driver_identification_monitor, engine |
| **Peripheriques** | DS18B20 Temperature Probe (1-Wire), Omnicomm Fuel Level Sensor (RS232), Buzzer, Lecteur iButton |

### A dire :

> "Le systeme determine automatiquement les capteurs et peripheriques requis. Pour ce camion frigorifique, il faut un capteur de carburant, un contact ignition, un identification conducteur, une sonde de temperature DS18B20 en 1-Wire, et un capteur carburant Omnicomm en RS232. Pour les peripheriques, il faut un buzzer pour les alertes temperature et un lecteur iButton pour les badges conducteur."

---

## Resultat du scoring (contre TOUS les modeles)

| Modele | Marque | Score | Compatible ? |
|--------|--------|-------|-------------|
| **FMB640** | Teltonika | **95/100** | Oui |
| **FMB641** | Teltonika | **95/100** | Oui |
| **FMP100** | Teltonika | **95/100** | Oui |
| FMB920 | Teltonika | 60/100 | Oui |
| CAREU U1 | Systech | 70/100 | Oui |
| Ucan | Systech | 35/100 | Non |
| JT701D | Jointech | 10/100 | Non |

### A dire :

> "Le scoring compare le profil contre tous les modeles du catalogue. Les meilleurs scores sont le FMB640, FMB641 et FMP100 avec 95/100 car ils ont CAN bus, 1-Wire, RS232. Les modeles bas de gamme comme le JT701D sont incompatibles avec 10/100."

---

## Resume pour la demo

1. **Cliquez** "+ Nouveau Profil"
2. **Remplissez** les infos (Etape 1)
3. **Choisissez** Teltonika FMB640 (Etape 2)
4. **Cochez** fuel_monitoring, geofencing, driver_id, buzzer_feature, green_driving, crash_detection (Etape 3)
5. **Validez** (Etape 4)
