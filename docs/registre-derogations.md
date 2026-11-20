# Registre des dérogations

| Réf. | Écart au référentiel | Raison | Mesure compensatoire | Test | Revue |
|---|---|---|---|---|---|
| DER-01 | `net.ipv4.ip_forward = 1` (le CIS demande `0`) | Nécessaire au routage des pods K3s. | Pare-feu UFW en liste blanche; NetworkPolicy activée en production. | TP12 : `sysctl -n net.ipv4.ip_forward` doit retourner `1`. | À chaque montée de version de K3s. |

## Portée de la mesure compensatoire

Le chart active la NetworkPolicy en production, mais sa règle d'ingress actuelle autorise tous les flux entrants vers les pods sélectionnés (`ingress: - {}`). Elle ne constitue donc pas, à elle seule, une segmentation restrictive. La liste blanche UFW reste le contrôle de filtrage effectif jusqu'à ce que cette politique soit restreinte.
