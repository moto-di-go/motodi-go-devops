# Stack carto open source (coût maîtrisé)

Pile cible MotodiGo, sans Google Maps / Mapbox / HERE :

| Couche | Choix | Rôle |
| --- | --- | --- |
| Rendu mobile | MapLibre (`maplibre_gl`) | Carte vectorielle, zoom fluide, styles |
| Fond de carte | OSM via Protomaps PMTiles (prod) ou OpenFreeMap (dev) | Tuiles vectorielles |
| Autocomplete MVP | Photon auto-hébergé | Search-as-you-type OSM |
| Autocomplete phase 2 | Pelias (seulement si Photon saturé) | Ranking multi-sources |
| Routage | Valhalla auto-hébergé | Itinéraires, alternatives, map matching |
| Benchmark | OSRM (optionnel) | Matrices / perf, pas le moteur produit |
| Lieux métier | Table `urban_places` | Hubs, gares, agences, quartiers |

Pelias n’est **pas** déployé en phase 1. OSRM n’est **pas** le moteur principal.

## Architecture

```
Flutter (MapLibre)
  ├─ style URL ──► OpenFreeMap (dev) ou Cloudflare R2 + Worker (prod PMTiles)
  └─ API Gateway ──► backend-core
                        ├─ PlaceSearchFacade ──► urban_places + Photon
                        └─ RoutingFacade ──────► Valhalla, sinon RouteBuilder local
```

## Plateformes, clés et coûts

Aucune clé n’est obligatoire pour la pile auto-hébergée. Les comptes ci-dessous ne servent que si vous choisissez l’option hébergée.

### 1. MapLibre (moteur carte)

- Docs Flutter : https://maplibre.org/flutter-maplibre-gl/
- Plugin : https://github.com/maplibre/flutter-maplibre-gl/
- Clé : aucune
- Coût logiciel : 0

### 2. OpenStreetMap / Geofabrik (données)

- OSM : https://www.openstreetmap.org/
- Extraite Cameroun : https://download.geofabrik.de/africa/cameroon.html
- PBF direct : https://download.geofabrik.de/africa/cameroon-latest.osm.pbf
- Clé : aucune pour télécharger les extraits
- Coût data : 0
- Ne pas interroger `nominatim.openstreetmap.org` en production.

### 3. Fond de carte — OpenFreeMap (dev, zéro config)

- Site : https://openfreemap.org/
- Style Liberty (MapLibre, sans clé) : `https://tiles.openfreemap.org/styles/liberty`
- Clé : aucune
- Coût : 0
- Usage : valeur par défaut de `MAP_STYLE_URL` en local. Fair-use communautaire, pas un SLA prod.

### 4. Fond de carte — Protomaps PMTiles (prod recommandée)

- Docs : https://docs.protomaps.com/
- Calculateur : https://docs.protomaps.com/deploy/cost
- Hosted API (à éviter en commercial) : https://protomaps.com/api
- Sponsor commercial hosted : https://github.com/sponsors/protomaps

**Auto-hébergé (cible) :**

- Cloudflare R2 : https://www.cloudflare.com/developer-platform/r2/ → créer un bucket, uploader `cameroon.pmtiles`
- Cloudflare Workers : https://workers.cloudflare.com/ → déployer `geo/cloudflare/`
- Wrangler login : https://dash.cloudflare.com/sign-up
- Clé : token Wrangler Cloudflare (compte), **pas** de clé carte dans l’app
- Coût typique : ~5–15 USD/mois au démarrage ; ~11 USD/mois dans l’exemple Protomaps 10M tiles / 1 TB sur Cloudflare

**Hosted Protomaps :** clé sur https://protomaps.com/api — gratuit non commercial uniquement.

### 5. Photon (autocomplete MVP)

- Repo : https://github.com/komoot/photon/
- Image Docker retenue : https://github.com/rtuszik/photon-docker
- Région locale par défaut : `PHOTON_REGION=africa`
- Mirror par défaut : `PHOTON_BASE_URL=https://r2.koalasec.org/public`
- Demo public `https://photon.komoot.io` : **interdit en prod** (throttling, pas de SLA)
- Clé : aucune en auto-hébergé
- Coût logiciel : 0
- Infra régionale : ~20–80 USD/mois (éviter l’import planète ~64 GB RAM / ~95 GB disque)
- Note : les anciens dumps Cameroun par `PHOTON_FILE_URL` ne sont plus un défaut fiable ; pour un jeu plus petit qu’Afrique, il faudra préparer un import personnalisé.

### 6. Pelias (phase 2 seulement)

- Projet : https://pelias.github.io/pelias/
- Docker : https://github.com/pelias/docker
- Clé : aucune en auto-hébergé
- Coût infra régionale : ~50–300 USD/mois
- Secours hébergé Geocode Earth : https://geocode.earth/ — clé requise ; ~100 USD/mois (150k req), 200 USD (400k), 500 USD (2M)

### 7. Valhalla (routage)

- Docs : https://valhalla.github.io/valhalla/
- GitHub : https://github.com/valhalla/valhalla
- Image Docker : https://github.com/gis-ops/docker-valhalla
- Demo FOSSGIS : développement seulement, pas la prod
- Clé : aucune en auto-hébergé
- Coût logiciel : 0
- Infra Cameroun : ~20–100 USD/mois au lancement ; ~80–250 USD/mois avec HA / matching / fraîcheur

### 8. OSRM (benchmark optionnel)

- https://project-osrm.org/
- https://github.com/Project-OSRM/osrm-backend
- Clé : aucune
- Coût : 0 logiciel ; ~5–40 USD/mois petite instance

## Extraite géographique

Phase 1 : **Valhalla sur Cameroun**, **Photon sur Afrique** par défaut pour rester compatible avec l’image Docker maintenue.

| Service | Fichier | Source |
| --- | --- | --- |
| Valhalla | `cameroon-latest.osm.pbf` | Geofabrik |
| Photon | `REGION=africa` | rtuszik/photon-docker mirror |
| PMTiles prod | `cameroon.pmtiles` | build Protomaps depuis le PBF, ou download Protomaps |

Ne pas importer la planète au démarrage.

## Lancer en local

Depuis `motodi-go-devops` :

```bash
# stack applicative
docker compose up --build

# services geo (Photon + Valhalla + tuiles)
docker compose -f docker-compose.yml -f docker-compose.geo.yml up --build
```

Bootstrap des extraits (long, une fois) :

```bash
# Linux/macOS
./geo/scripts/bootstrap-extracts.sh

# Windows PowerShell
./geo/scripts/bootstrap-extracts.ps1
```

Ces scripts téléchargent l’extrait OSM Cameroun pour Valhalla. Photon télécharge lui-même son index selon `PHOTON_REGION`.

Puis dans `.env` devops / backend-core :

```
GEO_STACK_PHOTON_ENABLED=true
GEO_STACK_PHOTON_BASE_URL=http://photon:2322
GEO_STACK_VALHALLA_ENABLED=true
GEO_STACK_VALHALLA_BASE_URL=http://valhalla:8002
```

Mobile `.env` :

```
# Vide = style raster local (Carto Voyager). OpenFreeMap vectoriel peut rester blanc sur Android.
MAP_STYLE_URL=
```

En prod, pointer `MAP_STYLE_URL` vers le Worker Cloudflare qui sert le style PMTiles.

## Budget

| Périmètre | USD / mois |
| --- | --- |
| MVP (OpenFreeMap ou petit R2 + Photon CM + Valhalla CM) | 45–195 |
| Prod raisonnable (PMTiles Cloudflare + HA légère) | 120–350 |

Aucune clé Google / Mapbox / HERE n’est requise.
