# Data Initialization & Reference Guide

Ce document regroupe les données de référence prêtes à être insérées dans la base de données pour les modèles mentionnés (Teltonika FMx120, FMx130, FMx640, Systech CAREU U1, CAREU A1, et Wondeproud VT200).

---

## 1. Table `port_types` (Master Catalog)
| id | name | Description |
|---|---|---|
| 1 | Digital Input (DIN) | Entrée numérique (On/Off, contact clé, bouton SOS) |
| 2 | Analog Input (AIN) | Entrée analogique (Mesure de tension variable, jauge) |
| 3 | Digital Output (DOUT) | Sortie numérique (Commande de relais, buzzer, sirène) |
| 4 | 1-Wire | Bus unifilaire pour puces Dallas/Maxim (Température, iButton) |
| 5 | RS232 | Port série standard pour communication point à point |
| 6 | RS485 | Bus série industriel pour chaînage de capteurs |
| 7 | CAN-Bus | Bus réseau véhicule (J1939, J1708, FMS, OBD) |
| 8 | Tachograph (K-Line) | Interface spécifique pour chronotachygraphe |
| 9 | Bluetooth BLE | Connectivité sans fil courte portée pour capteurs autonomes |

---

## 2. Table `features` (Master Catalog)
| id | name | Description |
|---|---|---|
| 1 | Real-time Tracking | Suivi de position en temps réel par intervalle |
| 2 | Eco-driving | Analyse du comportement de conduite (freinage, accélération) |
| 3 | Crash Detection | Détection d'accident via accéléromètre interne |
| 4 | Geofencing | Gestion de zones géographiques embarquées |
| 5 | Fuel Monitoring | Suivi précis de la consommation et des vols de carburant |
| 6 | Driver ID | Identification du conducteur (iButton, RFID, BLE) |
| 7 | Cold Chain Monitoring | Suivi de température et humidité (Chaîne du froid) |
| 8 | Tacho Download | Téléchargement à distance des données légales du chronotachygraphe |
| 9 | Engine Immobilization | Coupure moteur à distance via relais |

---

## 3. Table `tracker_models`
| id | name | brand | voltage_range |
|---|---|---|---|
| 1 | FMC120 (FMx120) | Teltonika | 10-30V DC |
| 2 | FMC130 (FMx130) | Teltonika | 10-30V DC |
| 3 | FMC640 (FMx640) | Teltonika | 10-30V DC |
| 4 | CAREU U1 | Systech | 9-36V DC |
| 5 | CAREU A1 | Systech | 9-30V DC |
| 6 | VT200 | Wondeproud | 9-36V DC |

---

## 4. Table de liaison `model_features`
Mapping des fonctionnalités activables par modèle :

| tracker_id | Model Name | feature_id | Feature Name |
|---|---|---|---|
| 1 | FMC120 | 1, 2, 3, 4, 5, 6, 7, 9 | All except Tacho |
| 2 | FMC130 | 1, 2, 3, 4, 5, 6, 7, 9 | All except Tacho |
| 3 | FMC640 | 1, 2, 3, 4, 5, 6, 7, 8, 9 | Toutes les fonctionnalités |
| 4 | CAREU U1 | 1, 2, 4, 5, 6, 7, 9 | Suivi, Carburant, ID, Sécurité |
| 5 | CAREU A1 | 1, 4, 5, 9 | Suivi de base et coupure |
| 6 | VT200 | 1, 4, 9 | Suivi basique et coupure moteur |

---

## 5. Table `model_ports` (Cartographie Physique des Broches)
Liste exhaustive de l'architecture matérielle des ports par modèle pour votre logique de compatibilité :

### Teltonika FMC120 (ID: 1)
* `tracker_id: 1, port_type_id: 1, pin_label: 'DIN1 (Ignition)'`
* `tracker_id: 1, port_type_id: 1, pin_label: 'DIN2'`
* `tracker_id: 1, port_type_id: 2, pin_label: 'AIN1'`
* `tracker_id: 1, port_type_id: 3, pin_label: 'DOUT1 (Immobilizer)'`
* `tracker_id: 1, port_type_id: 3, pin_label: 'DOUT2'`
* `tracker_id: 1, port_type_id: 4, pin_label: '1-Wire Data'`
* `tracker_id: 1, port_type_id: 9, pin_label: 'Bluetooth BLE Channel'`

### Teltonika FMC130 (ID: 2)
* `tracker_id: 2, port_type_id: 1, pin_label: 'DIN1 (Ignition)'`
* `tracker_id: 2, port_type_id: 1, pin_label: 'DIN2 (Negative Input support)'`
* `tracker_id: 2, port_type_id: 1, pin_label: 'DIN3 (Configurable AIN2)'`
* `tracker_id: 2, port_type_id: 2, pin_label: 'AIN1'`
* `tracker_id: 2, port_type_id: 3, pin_label: 'DOUT1'`
* `tracker_id: 2, port_type_id: 3, pin_label: 'DOUT2'`
* `tracker_id: 2, port_type_id: 3, pin_label: 'DOUT3'`
* `tracker_id: 2, port_type_id: 4, pin_label: '1-Wire Data'`
* `tracker_id: 2, port_type_id: 9, pin_label: 'Bluetooth BLE Channel'`

### Teltonika FMC640 (ID: 3)
* `tracker_id: 3, port_type_id: 1, pin_label: 'DIN1'` / `DIN2` / `DIN3` / `DIN4` (4 ports)
* `tracker_id: 3, port_type_id: 2, pin_label: 'AIN1'` / `AIN2` / `AIN3` / `AIN4` (4 ports)
* `tracker_id: 3, port_type_id: 3, pin_label: 'DOUT1'` / `DOUT2` / `DOUT3` / `DOUT4` (4 ports)
* `tracker_id: 3, port_type_id: 4, pin_label: '1-Wire Data'`
* `tracker_id: 3, port_type_id: 5, pin_label: 'RS232 Port'`
* `tracker_id: 3, port_type_id: 6, pin_label: 'RS485 Port'`
* `tracker_id: 3, port_type_id: 7, pin_label: 'CAN1 High/Low (FMS/J1939)'`
* `tracker_id: 3, port_type_id: 7, pin_label: 'CAN2 High/Low (J1708)'`
* `tracker_id: 3, port_type_id: 8, pin_label: 'K-Line (Tachograph)'`

### Systech CAREU U1 (ID: 4)
* `tracker_id: 4, port_type_id: 1, pin_label: 'DIN1 (Ignition)'`
* `tracker_id: 4, port_type_id: 1, pin_label: 'DIN2 (Panic Button)'`
* `tracker_id: 4, port_type_id: 3, pin_label: 'DOUT1 (Relay Control)'`
* `tracker_id: 4, port_type_id: 4, pin_label: '1-Wire Interface'`
* `tracker_id: 4, port_type_id: 5, pin_label: 'RS232 Main'`
* `tracker_id: 4, port_type_id: 5, pin_label: 'RS232 Extension 1'`
* `tracker_id: 4, port_type_id: 5, pin_label: 'RS232 Extension 2'`
* `tracker_id: 4, port_type_id: 6, pin_label: 'RS485 Bus'`
* `tracker_id: 4, port_type_id: 7, pin_label: 'Internal OBDII/CAN Interpreter'`

### Systech CAREU A1 (ID: 5)
* `tracker_id: 5, port_type_id: 1, pin_label: 'DIN1 (Ignition)'`
* `tracker_id: 5, port_type_id: 2, pin_label: 'AIN1 (Fuel Gauge)'`
* `tracker_id: 5, port_type_id: 3, pin_label: 'DOUT1 (Immobilizer)'`

### Wondeproud VT200 (ID: 6)
* `tracker_id: 6, port_type_id: 1, pin_label: 'DIN1 (Ignition)'`
* `tracker_id: 6, port_type_id: 1, pin_label: 'DIN2 (SOS)'`
* `tracker_id: 6, port_type_id: 2, pin_label: 'AIN1'`
* `tracker_id: 6, port_type_id: 3, pin_label: 'DOUT1 (Cut-Off)'`

---

## 6. Table `peripherals` (Exemples de Périphériques catalogués par Port)
| id | port_type_id | Peripheral Name | Technologie requise |
|---|---|---|---|
| 1 | 4 (1-Wire) | DS18B20 Temperature Probe | 1-Wire |
| 2 | 4 (1-Wire) | iButton Driver ID Reader | 1-Wire |
| 3 | 5 (RS232) | Omnicomm Fuel Level Sensor LLS | RS232 |
| 4 | 5 (RS232) | Garmin FMI Navigation Display | RS232 |
| 5 | 5 (RS232) | ADAS Fatigue Camera | RS232 |
| 6 | 6 (RS485) | Industrial RFID Reader | RS485 |
| 7 | 9 (BLE) | Teltonika EYE Sensor (Temp/Hum) | Bluetooth BLE |
| 8 | 9 (BLE) | Wireless Escort Fuel Sensor | Bluetooth BLE |
| 9 | 3 (DOUT) | 12V Automotive Relay | Digital Output |
| 10| 3 (DOUT) | Driver Alarm Buzzer | Digital Output |
| 11| 1 (DIN) | Waterproof SOS Emergency Button | Digital Input |
