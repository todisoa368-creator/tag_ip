# FICHE DE DEMONSTRATION — SOUTENANCE TAG-MONITOR

**Fitahianjanahary Todisoa Christine — DTS Technologie Informatique**
**Duree cible : 4 minutes**

---

## AVANT DE COMMENCER

> "Je vais maintenant passer au navigateur pour une demonstration en direct. Le parcours sera le suivant : connexion, creation d'un profil via l'assistant en 4 etapes, lancement du calcul de compatibilite, puis visualisation des resultats. Je terminerai par l'export CSV et la deconnexion."

**Prerequis :**
- Application ouverte sur la page de connexion
- Navigateur en plein ecran (pas d'onglet en double)
- Compte de demo deja cree et fonctionnel
- 3 captures d'ecran de secours pretes au cas ou

**Compte de connexion :**

| Champ | Valeur |
|-------|--------|
| URL | `http://localhost:4000/users/log-in` |
| Email | `admin@tag-ip.com` |
| Mot de passe | `password1234` |

---

## DONNEES DE DEMONSTRATION

### Organisations enregistrees

| # | Organisation | Description |
|---|-------------|-------------|
| 1 | **TAG-IP Solutions** | Societe de geolocalisation GPS — 10 000+ vehicules suivis a Madagascar |
| 2 | **JIRAMA** | Jiro sy Rano Malagasy — Entreprise nationale d'electricite et d'eau |
| 3 | **Omo Tsena** | Reseau de transport en commun d'Antananarivo — 300+ minibus |
| 4 | **DHL Madagascar** | DHL Express — Logistique express internationale |
| 5 | **Transports Madagascar** | Societe de transport interurbain — Bus et camions |
| 6 | **Bollore Logistics Madagascar** | Logistique portuaire et terrestre — Conteneurs |
| 7 | **Star Taxi Antananarivo** | Reseau de taxis — 200+ voitures |
| 8 | **Soa Pharma Distribution** | Distribution pharmaceutique — Chaine du froid medicale |
| 9 | **CNA-PS** | Chantiers Navals et Portuaires de Toamasina |
| 10 | **CRAFO** | Centre de Recherche Agronomique — Vehicules terrain |

### Profils de montage par entreprise

| Profil | Organisation | Type vehicule | Besoins techniques |
|--------|-------------|---------------|-------------------|
| Camion de maintenance electrique | JIRAMA | Camion | CAN bus, geofence, accelerometre |
| Chariot eleveur entrepot | JIRAMA | Chariot | 24-48V, 2 entrees |
| Moto intervention rapide | JIRAMA | Moto | Ultra low power, accelerometre |
| Minibus Ligne 105 | Omo Tsena | Bus | CAN bus, identification conducteur, buzzer |
| Bus interurbain | Omo Tsena | Bus | 24-36V, CAN bus, sonde carburant |
| Camion de livraison DHL | DHL Madagascar | Camion | CAN bus, buzzer, geofence, identification |
| Conteneur fret maritime | DHL Madagascar | Cadenas | 3.7-5V, ultra low power, antenne deportee |
| Camion cargo longue distance | Transports Mada | Camion | 12-36V, CAN bus, RS232, geofence |
| Bus Antananarivo — Fianarantsoa | Transports Mada | Bus | 24-36V, CAN bus, buzzer |
| Chariot eleveur portuaire | Bollore Logistics | Chariot | 24-48V, RS485, montage exterieur |
| Camion porte-conteneurs | Bollore Logistics | Camion | CAN bus, buzzer, sonde CAN |
| Taxi urbain Antananarivo | Star Taxi | Voiture | Geofence, accelerometre |
| Taxi aeroport Transfer VIP | Star Taxi | Voiture | Buzzer, geofence |
| Camion refrigere vaccins | Soa Pharma | Camion | 1-Wire, RS232, CAN bus, montage exterieur |
| Utilitaire livraison pharmacies | Soa Pharma | Van | Buzzer, geofence, identification |
| Embarcation patrol portuaire | CNA-PS | Bateau | Montage exterieur, antenne deportee |
| Grue portuaire | CNA-PS | Engin chantier | 24-48V, CAN bus, RS485 |
| 4x4 terrain recherche | CRAFO | Voiture | Geofence, accelerometre, sonde analogique |
| Moto de terrain | CRAFO | Moto | Ultra low power, accelerometre |

### Modeles de traceurs (33 modeles)

| Marque | Modeles | Gamme |
|--------|---------|-------|
| **Teltonika** | FMB003, FMB020, FMB120, FMB125, FMB130, FMB140, FMB204, FMB640, FMB641, FMB920, FMC130, FMC230, FMP100 | Vehicule |
| **Teltonika** | GH5200, TMT250 | Body tracker |
| **Systech** | A1, CAREU U1, U1+, U1 Lite, WR, U1 UW1, Ueco, COBAN 103-B, P1, P2, Ucan, UGO | Economique |
| **WonderProud** | VT10, VT200 | Basique |
| **Jointech** | JT700 solar, JT701, JT701D, JT709A | Cadenas connecte |

### Les 20 criteres du moteur de scoring

| # | Critere | Points | Description |
|---|---------|--------|-------------|
| 1 | Type de vehicule | 8 | Compatibilite avec le type de vehicule |
| 2 | Alimentation / tension | 10 | Plage de tension compatible |
| 3 | CAN bus | 8 | Interface CAN bus |
| 4 | 1-Wire | 5 | Interface 1-Wire |
| 5 | RS232 | 4 | Interface RS232 |
| 6 | RS485 | 4 | Interface RS485 |
| 7 | Bluetooth BLE | 4 | Connectivite Bluetooth |
| 8 | Entrees numeriques | 8 | Nombre d'entrees digitales |
| 9 | Entrees analogiques | 5 | Nombre d'entrees analogiques |
| 10 | Sorties numeriques | 5 | Nombre de sorties digitales |
| 11 | Protection IP | 10 | Indice de protection IP67+ |
| 12 | Ultra low power | 5 | Mode basse consommation |
| 13 | Accelerometre | 5 | Accelerometre 3 axes |
| 14 | Antennes externes | 4 | Connecteurs antennes deportees |
| 15 | Buzzer | 4 | Avertisseur sonore |
| 16 | Geofence | 5 | Georep embarque |
| 17 | Sonde carburant | 5 | Support sonde carburant |
| 18 | Capteurs | 5 | Capteurs requis supportes |
| 19 | Peripheriques | 5 | Ports peripheriques requis |
| 20 | Buffer memoire | 5 | Memoire tampon |

---

## SCRIPT DE DEMONSTRATION

### ETAPE 1 — CONNEXION (20 secondes)

**Action :** Aller sur `/users/log-in`

**Phrase a dire :**
> "Voici la page de connexion. Je saisis mon adresse email et mon mot de passe, puis je clique sur Se connecter."

**Action :** Remplir email `admin@tag-ip.com` + mot de passe `password1234` -> cliquer "Se connecter"

**Phrase a dire :**
> "L'authentification est securisee avec des mots de passe hashees via Argon2, conformement aux recommandations de securite."

---

### ETAPE 2 — TABLEAU DE BORD (20 secondes)

**Action :** Arriver sur le Dashboard

**Phrase a dire :**
> "Le tableau de bord affiche un resume : le nombre de profils de montage, le nombre de modeles de traceurs, et le nombre de compatibilites calculees. On accede rapidement a chaque section via les cartes d'acces rapide."

**Action :** Montrer les 3 cartes de stats et les 4 cartes d'acces rapide

---

### ETAPE 3 — LISTE DES PROFILS (10 secondes)

**Action :** Cliquer "Profils de montage" dans la barre de navigation

**Phrase a dire :**
> "Voici la liste des profils existants. Chaque profil represente un cas concret : un type de vehicule, un modele de traceur, et les fonctionnalites requises."

**Action :** Montrer la table avec les colonnes Nom, Type, Organisation, Specifications

---

### ETAPE 4 — CREATION D'UN PROFIL (1 minute 30)

**Phrase d'annonce :**
> "Je vais creer un nouveau profil via l'assistant en 4 etapes. Par exemple, pour un client comme JIRAMA qui a besoin d'un camion pour la maintenance electrique."

#### Etape 4.1 — Identification (20s)

**Action :** Cliquer "+ Nouveau Profil", remplir le formulaire

**Phrase a dire :**
> "Etape 1 : je donne un nom au profil, je selectionne l'organisation cliente, puis le type de vehicule. Par exemple, un camion de maintenance electrique pour JIRAMA."

**Action :** Nom: "Camion maintenance electrique" -> Organisation: "JIRAMA" -> Type vehicule: "Camion" -> Cliquer "Suivant"

#### Etape 4.2 — Selection du modele (20s)

**Phrase a dire :**
> "Etape 2 : je choisis le fournisseur, puis le modele de traceur. Par exemple, le Teltonika FMB130 qui a les specifications adequates pour un camion. La fiche technique s'affiche automatiquement : plage de tension 12V-36V, CAN bus, 6 entrees numeriques."

**Action :** Fournisseur: "Teltonika" -> Modele: "FMB130" -> Cliquer "Suivant"

#### Etape 4.3 — Fonctionnalites (20s)

**Phrase a dire :**
> "Etape 3 : je selectionne les fonctionnalites requises par le client : georeperage pour suivre le camion, CAN bus pour lire les donnees du vehicule, et accelerometre pour detecter la conduite. Le compteur affiche le nombre de fonctionnalites selectionnees."

**Action :** Cocher: georep, CAN bus, accelerometre -> Cliquer "Suivant"

#### Etape 4.4 — Validation (10s)

**Phrase a dire :**
> "Etape 4 : le recapitulatif s'affiche. Le systeme verifie automatiquement la compatibilite entre le profil et le modele choisi. Si tout est valide, je peux enregistrer."

**Action :** Verifier le recapitulatif -> Cliquer "Enregistrer le profil"

---

### ETAPE 5 — CALCUL DE COMPATIBILITE (30 secondes)

**Phrase d'annonce :**
> "Maintenant, je lance le calcul de compatibilite du profil cree contre tous les modeles de traceurs du catalogue."

**Action :** Cliquer "Calculer" sur la page du profil "Camion maintenance electrique"

**Phrase a dire :**
> "Le moteur evalue 20 criteres : tension, CAN bus, accelerometre, indice IP, entrees-sorties, georeperage... Le calcul prend moins de 50 millisecondes par couple."

**Action :** Attendre le calcul (~1-2 secondes pour 20 modeles)

**Phrase a dire :**
> "Voici les resultats. Le Teltonika FMB130 obtient un score eleve car il a CAN bus, accelerometre, et 6 entrees numeriques. Le code couleur est intuitif : vert pour compatible, orange pour partiel, rouge pour incompatible."

**Action :** Montrer les resultats avec les badges de score colorees - insister sur le FMB130

---

### ETAPE 6 — DETAIL DU RESULTAT (15 secondes)

**Action :** Cliquer sur un resultat de compatibilite

**Phrase a dire :**
> "En cliquant sur un resultat, on voit l'analyse detaillee : chaque critere est evalue individuellement avec une justification. Par exemple, tension compatible, CAN bus supporte, mais accelerometre manquant."

**Action :** Montrer le detail avec les justifications par critere

---

### ETAPE 7 — CALCUL RAPIDE (15 secondes)

**Action :** Aller sur `/compatibilites`

**Phrase a dire :**
> "On peut aussi lancer un calcul rapide sans creer de profil : on selectionne directement un profil existant et un modele de traceur."

**Action :** Selectionner profil + modele -> Cliquer "Lancer le calcul"

**Phrase a dire :**
> "Le resultat s'affiche instantanement et s'ajoute a l'historique."

---

### ETAPE 8 — EXPORT CSV (10 secondes)

**Action :** Aller sur `/profils`, cliquer le bouton "CSV"

**Phrase a dire :**
> "Enfin, on peut exporter la liste des profils au format CSV pour l'integrer dans d'autres outils ou pour archivage."

**Action :** Telecharger le fichier CSV

---

### ETAPE 9 — DECONNEXION (5 secondes)

**Action :** Cliquer "Deconnexion" en haut a droite

**Phrase a dire :**
> "Je termine par la deconnexion. La session est securisee par token."

---

## PHRASE DE CONCLUSION

> "Comme vous l'avez vu, l'application permet de creer un profil en 4 etapes simples, de calculer la compatibilite en quelques secondes, et d'obtenir un diagnostic detaille. Le processus qui prenait 30 a 45 minutes est desormais automatise."

---

## CHRONOMETRAGE

| Etape | Duree | Cumul |
|-------|-------|-------|
| Connexion | 20s | 0:20 |
| Dashboard | 20s | 0:40 |
| Liste profils | 10s | 0:50 |
| Creation profil (4 etapes) | 1m30 | 2:20 |
| Calcul compatibilite | 30s | 2:50 |
| Detail resultat | 15s | 3:05 |
| Calcul rapide | 15s | 3:20 |
| Export CSV | 10s | 3:30 |
| Deconnexion | 5s | 3:35 |
| **TOTAL** | **~3min40** | |

---

## EN CAS DE PROBLEME TECHNIQUE

| Probleme | Solution de secours |
|----------|-------------------|
| Application ne charge pas | Montrer la capture d'ecran du dashboard |
| Calcul trop long | Montrer la capture des resultats |
| Erreur de connexion | Montrer la capture de la page de connexion |
| Navigation cassee | Aller directement via l'URL : `/profils`, `/compatibilites` |

---

## CONSEILS

- Entraînez-vous **3 fois** avec un chronometre avant le jour J
- Parlez **lentement**, regardez le jury, pas l'ecran
- En cas de bug : ne paniquez pas, passez a l'etape suivante
- Si le calcul echoue, montrez la page de resultats pre-calcules
