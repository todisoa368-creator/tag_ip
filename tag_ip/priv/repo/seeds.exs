alias TagIp.Resources.ProfilMontage
alias TagIp.Resources.ModeleTraceur
alias TagIp.Resources.Compatibilite

# Profils de montage
profils = [
  %{
    nom: "Véhicule utilitaire léger",
    type_vehicule: "Utilitaire",
    alimentation: "12V",
    capteurs: ["température", "GPS", "vitesse"],
    description: "Profil pour les véhicules utilitaires légers de livraison"
  },
  %{
    nom: "Camion de transport longue distance",
    type_vehicule: "Poids lourd",
    alimentation: "24V",
    capteurs: ["température", "GPS", "vitesse", "carburant", "pression_pneus"],
    description: "Profil pour les camions de transport longue distance"
  },
  %{
    nom: "Voiture de tourisme",
    type_vehicule: "Tourisme",
    alimentation: "12V",
    capteurs: ["GPS", "vitesse", "carburant"],
    description: "Profil standard pour voitures de tourisme"
  }
]

Enum.each(profils, fn attrs ->
  ProfilMontage.create!(attrs)
end)

# Modèles de traceurs
modeles = [
  %{
    nom: "Traceur GPS Pro X1",
    reference: "GPS-PRO-X1",
    types_vehicule_compatibles: ["Utilitaire", "Tourisme"],
    alimentations_compatibles: ["12V"],
    capteurs_supportes: ["GPS", "vitesse", "température", "carburant"],
    description: "Modèle professionnel pour véhicules légers"
  },
  %{
    nom: "Traceur GPS Heavy Truck",
    reference: "GPS-HEAVY-T1",
    types_vehicule_compatibles: ["Poids lourd"],
    alimentations_compatibles: ["24V"],
    capteurs_supportes: ["GPS", "vitesse", "température", "carburant", "pression_pneus"],
    description: "Modèle renforcé pour poids lourds"
  },
  %{
    nom: "Traceur GPS Eco",
    reference: "GPS-ECO-E1",
    types_vehicule_compatibles: ["Tourisme"],
    alimentations_compatibles: ["12V"],
    capteurs_supportes: ["GPS", "vitesse"],
    description: "Modèle économique pour voitures de tourisme"
  }
]

Enum.each(modeles, fn attrs ->
  ModeleTraceur.create!(attrs)
end)

IO.puts("Données de test créées avec succès!")
