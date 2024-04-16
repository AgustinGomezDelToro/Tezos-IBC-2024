
# Projet Vesting Tezos

Ce projet contient deux contrats intelligents pour une plateforme de vesting sur la blockchain Tezos, en utilisant la norme FA2 pour la tokenisation. Le premier contrat, `token.mligo`, sert de contrat de token standard FA2, tandis que le second, `vesting_contract.mligo`, gère la distribution progressive des tokens aux bénéficiaires en fonction d'un calendrier défini.

## Structure du Projet

Le projet est structuré comme suit :

- `src/`: Dossier contenant les sources LIGO des contrats intelligents et fichiers TEST.
  - `token.mligo`: Le contrat de token FA2 qui gère la création, la destruction et le transfert des tokens.
  - `vesting_contract.mligo`: Le contrat de vesting qui contrôle la distribution des tokens avec une période de blocage et libération conditionnelle.
  - `vesting_contract.test.mligo` et `token.test.mligo` = Test des contrat. 

## Prérequis

Pour développer et déployer ces contrats, vous aurez besoin de :

- [Node.js](https://nodejs.org/)
- [LIGO](https://ligolang.org/docs/intro/installation)
- Un wallet Tezos pour les interactions blockchain (par exemple [Temple Wallet](https://templewallet.com/)).

## Installation

Suivez ces étapes pour installer l'environnement nécessaire au développement des contrats :

```bash
# Installez LIGO
curl https://ligolang.org/bin/linux/ligo > ligo
chmod +x ligo
sudo mv ligo /usr/local/bin

# Installez les dépendances Node.js
npm install

```

# Développement

## Pour compiler les contrats :

ligo compile contract src/token.mligo -o compiled/token.tz
ligo compile contract src/vesting_contract.mligo -o compiled/vesting_contract.tz


## Déploiement
Utilisez les scripts fournis pour déployer les contrats sur la blockchain Tezos. Assurez-vous de mettre à jour le fichier .env avec les informations de votre compte.


```bash
# Fichier .env
RPC_URL= (si vous avez)
PRIVATE_KEY=
ADMIN_ADDRESS=

```


