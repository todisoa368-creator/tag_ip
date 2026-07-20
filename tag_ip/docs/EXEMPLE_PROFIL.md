# EXEMPLE 1 : Creation du profil "Camion frigorifique Soa Pharma"

## Etape 1 : Identification

| Champ | Valeur |
|-------|--------|
| Nom du profil | Camion frigorifique Soa Pharma |
| Organisation | Soa Pharma Distribution |
| Type de vehicule | Camion (truck) |
| Description | Transport de vaccins et medicaments thermosensibles |

### A dire :

> "Je vais creer un profil pour un camion frigorifique de Soa Pharma. Ce camion transporte des vaccins qui doivent rester au froid. Il a besoin de capteurs pour mesurer la temperature et surveiller le carburant."

---

## Etape 2 : Selection du modele

| Champ | Valeur |
|-------|--------|
| Fournisseur | Teltonika |
| Modele | FMB130 |

**Fiche technique affichee :**
- Plage de tension : 9-36V
- Entrees numeriques : 6
- Entrees analogiques : 2
- Sorties numeriques : 2
- CAN bus : Oui
- GPS : Oui
- Bluetooth : Oui

### A dire :

> "Pour ce camion, je choisis le Teltonika FMB130. Il a 6 entrees numeriques pour connecter des capteurs, 2 entrees analogiques pour les jauges, et CAN bus pour lire les donnees du moteur."

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
| **Peripheriques** | Buzzer (alerte temperature), Lecteur iButton (conducteur) |

### A dire :

> "Le systeme determine automatiquement les capteurs et peripheriques requis. Pour ce camion frigorifique, il faut un capteur de carburant, un contact ignition, un identification conducteur, et un capteur moteur. Pour les peripheriques, il faut un buzzer pour les alertes temperature et un lecteur iButton pour les badges conducteur."

---

## Resultat du scoring

```
Modele: Teltonika FMB130
  → Capteurs supportes: [fuel_level_monitor, ignition, driver_identification_monitor, engine] OK
  → Peripheriques supportes: [Buzzer, iButton] OK
  → Score: 95/100 (compatible)
```

### A dire :

> "Le scoring montre que le FMB130 est compatible a 95%. Le modeleur a toutes les fonctionnalites requises pour ce camion frigorifique."

---

## Resume pour la demo

1. **Cliquez** "+ Nouveau Profil"
2. **Remplissez** les infos (Etape 1)
3. **Choisissez** Teltonika FMB130 (Etape 2)
4. **Cochez** fuel_monitoring, geofencing, driver_id, buzzer_feature, green_driving, crash_detection (Etape 3)
5. **Validez** (Etape 4)

Le systeme fait tout le reste automatiquement !
