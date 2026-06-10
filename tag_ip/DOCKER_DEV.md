# Docker Compose — Développement local

Ce fichier décrit comment lancer l'application en local à l'aide de Docker Compose.

Commandes rapides:

```bash
# Construire et démarrer les services
docker compose up --build

# (optionnel) Lancer en arrière-plan
docker compose up -d --build

# Voir les logs
docker compose logs -f web

# Arrêter et supprimer
docker compose down
```

Notes:
- Le service `web` exécute `mix ecto.create` et `mix ecto.migrate` avant de démarrer le serveur.
- Si vous avez besoin d'un shell dans le conteneur pour des tâches manuelles:

```bash
docker compose run --rm web bash
```

- L'accès web sera disponible sur http://localhost:4000
