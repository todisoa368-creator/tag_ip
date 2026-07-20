# EXEMPLE 2 : Creation du profil "Bus interurbain Transports Madagascar"

## Etape 1 : Identification

| Champ | Valeur |
|-------|--------|
| Nom du profil | Bus interurbain Antananarivo — Fianarantsoa |
| Organisation | Transports Madagascar |
| Type de vehicule | Bus |
| Description | Bus 40 places pour trajet longue distance. Identification conducteur, georeperage, buzzer, CAN bus. |

### A dire :

> "Je vais creer un profil pour un bus interurbain qui fait le trajet Antananarivo — Fianarantsoa. C'est un bus de 40 places qui a besoin d'identification conducteur et de georeperage pour suivre l'itineraire."

---

## Etape 2 : Selection du modele

| Champ | Valeur |
|-------|--------|
| Fournisseur | Teltonika |
| Modele | FMB640 |

**Fiche technique affichee :**
- Plage de tension : 9-36V
- Entrees numeriques : 4
- Entrees analogiques : 2
- Sorties numeriques : 2
- CAN bus : Oui (2 canaux)
- GPS : Oui
- Bluetooth : Oui
- RS232 : Oui

### A dire :

> "Pour ce bus, je choisis le Teltonika FMB640. Il a CAN bus a 2 canaux pour lire les donnees du moteur, et RS232 pour connecter des peripheriques comme un lecteur de badge."

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
| **Peripheriques** | Buzzer (alerte sonore), Lecteur iButton (badge conducteur) |

### A dire :

> "Le systeme determine automatiquement les capteurs et peripheriques requis. Pour ce bus, il faut un capteur de carburant, un contact ignition, un identification conducteur, et des capteurs moteur. Pour les peripheriques, il faut un buzzer pour les alertes et un lecteur iButton pour les badges conducteur."

---

## Resultat du scoring

```
Modele: Teltonika FMB640
  → Capteurs supportes: [fuel_level_monitor, ignition, driver_identification_monitor, engine, engine_speed] OK
  → Peripheriques supportes: [Buzzer, iButton] OK
  → Score: 92/100 (compatible)
```

### A dire :

> "Le scoring montre que le FMB640 est compatible a 92%. Le modeleur a toutes les fonctionnalites requises pour ce bus interurbain."

---

## Resume pour la demo

1. **Cliquez** "+ Nouveau Profil"
2. **Remplissez** les infos (Etape 1)
3. **Choisissez** Teltonika FMB640 (Etape 2)
4. **Cochez** fuel_monitoring, geofencing, driver_id, buzzer_feature, green_driving, crash_detection (Etape 3)
5. **Validez** (Etape 4)

Le systeme fait tout le reste automatiquement !
