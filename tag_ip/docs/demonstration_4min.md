# Démonstration TAG-IP — 4 minutes

---

## 1. Accueil (30s)

Bonjour, je vais vous présenter **TAG-IP**, une application d'évaluation de compatibilité entre traceurs GPS et profils de montage véhicules. Elle résout le problème du choix du bon traceur pour chaque type de véhicule.

---

## 2. Tableau de Bord (30s)

Voici le tableau de bord. On y voit le résumé :
- Le nombre de profils de montage enregistrés
- Le nombre de modèles de traceurs disponibles
- Les dernières compatibilités calculées

Tout est accessible en un coup d'œil.

---

## 3. Création d'un Profil (1 min)

Je crée un profil de montage pour un camion de livraison DHL.

**Données à remplir :**

| Champ | Valeur |
|-------|--------|
| Nom du profil | Camion livraison DHL Antananarivo |
| Type de véhicule | Camion |
| Organisation | DHL Madagascar |
| Tension min | 12 |
| Tension max | 36 |
| Intervalle de reporting | 30 secondes |
| Buzzer | Oui |
| Géofence | Oui |
| Identification conducteur | RFID |
| CAN-Bus requis | Oui |
| RS232 requis | Oui |
| Entrées digitales requis | 2 |
| Sorties requises | 1 |
| Montage extérieur | Oui |
| Accéléromètre requis | Oui |
| Ultra-low power | Non |

**Fonctionnalités à cocher :**
- Fuel Monitoring (suivi carburant)
- Geofencing (géorepérage)
- Driver ID (identification conducteur)
- Alert Button (bouton d'alerte)

**Capteurs à sélectionner :**
- Ignition (démarrage)
- Fuel level monitor (niveau carburant)
- Driver identification (RFID)
- Alert button (bouton d'alerte)

Le formulaire est guidé, chaque critère est clair et structuré.

---

## 4. Calcul de Compatibilité (1 min)

Maintenant, lançons le calcul de compatibilité pour ce profil.

L'algorithme évalue **15 critères** en quelques secondes :

- Compatibilité tension
- Interface CAN-Bus
- Interface RS232
- Entrées digitales
- Capteurs carburant
- Géofence
- Identification conducteur
- Accéléromètre
- Ultra-low power
- Et plus...

**Résultats :**

| Rang | Modèle | Score |
|------|--------|-------|
| 1 | Teltonika FMC650 | 92% |
| 2 | Teltonika FMB920 | 78% |
| 3 | Systech FMC130 | 65% |

Le FMC650 est recommandé car il supporte toutes les exigences : CAN-Bus, RS232, géofence avancée, identification conducteur, et a une mémoire tampon de 256MB.

---

## 5. Fiche Technique (30s)

En cliquant sur un modèle, on voit sa fiche complète :
- Spécifications électriques (tension, consommation)
- Interfaces disponibles (CAN, RS232, Bluetooth)
- Fonctionnalités supportées
- Capteurs compatibles
- Ports matériels

Tout est présent pour décider rapidement.

---

## 6. Conclusion (30s)

TAG-IP réduit le temps de sélection de 80%, élimine les erreurs de compatibilité, et standardise la décision technique. Application opérationnelle et prête au déploiement.

Merci de votre attention.

---

## Données de démonstration complètes

### Profil : Camion livraison DHL Antananarivo

| Champ | Valeur | Section formulaire |
|-------|--------|--------------------|
| Nom du profil | Camion livraison DHL Antananarivo | Informations générales |
| Description | Camion de livraison express pour zone urbaine Antananarivo | Informations générales |
| Type de véhicule | Camion | Véhicules compatibles |
| Organisation | DHL Madagascar | Organisation |
| Tension min | 12 | Alimentation |
| Tension max | 36 | Alimentation |
| Consommation veille | 5 mA | Alimentation |
| Intervalle de reporting | 30 secondes | Paramètres |
| Buzzer | Oui | Matériel |
| Géofence | Oui | Fonctionnalités |
| Identification conducteur | RFID | Fonctionnalités |
| Fuel probe type | CAN | Matériel |

### Interfaces requises

| Interface | Coché | Justification |
|-----------|-------|---------------|
| CAN-Bus | Oui | Sonde carburant CAN |
| 1-Wire | Non | - |
| RS232 | Oui | Communication série |
| RS485 | Non | - |
| Bluetooth BLE | Non | - |

### Entrées/Sorties

| Type | Nombre |
|------|--------|
| Entrées digitales | 2 |
| Entrées analogiques | 1 |
| Sorties | 1 |

### Protection et environnement

| Critère | Valeur |
|---------|--------|
| Indice IP | IP65 |
| Montage extérieur | Oui |
| Antenne déportée | Non |
| Accéléromètre | Oui |
| Ultra-low power | Non |
| Mémoire tampon | 256 MB |

### Fonctionnalités (à cocher)

| Fonctionnalité | Coché |
|----------------|-------|
| Fuel Monitoring | Oui |
| Geofencing | Oui |
| Driver ID | Oui |
| Alert Button | Oui |
| Green Driving | Non |
| Buzzer Feature | Oui |
| Crash Detection | Non |
| Real Time Tracking | Oui |

### Capteurs (à cocher)

| Capteur | Catégorie | Coché |
|---------|-----------|-------|
| Ignition | Énergie | Oui |
| Fuel Level Monitor | Énergie | Oui |
| Driver Identification | Conducteur | Oui |
| Alert Button | Sécurité | Oui |
| Geofence | Environnement | Oui |
| Odometer | État du véhicule | Non |

### Résultat attendu

| Modèle | Score | Détail |
|--------|-------|--------|
| Teltonika FMC650 | 92% | CAN-Bus ✓, RS232 ✓, IP67, 256MB buffer |
| Teltonika FMB920 | 78% | CAN-Bus ✓, 1-Wire ✓, 64MB buffer |
| Systech FMC130 | 65% | CAN-Bus ✓, pas de RS232 |
| Wonderproud WP100 | 45% | Analog only, pas de CAN |
