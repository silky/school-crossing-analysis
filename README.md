# School crossing analysis

## About

This repo is all the code and tooling related to a talk about using
[b6](https://github.com/diagonalworks/diagonal-b6) for urban data analysis. It
contains an example of performing this analysis for crossings near schools in
Edinburgh.

## Setup

In order to run this repo, you need to open data from OpenStreetMap. The
following steps outline getting that data and processing it with b6 for
further analysis.

### Nix

The repo makes use of Nix to provide all appropriate binaries (i.e. b6
programs) and other utils.

Unless you already have it installed; you will need to [install
Nix](https://nixos.org/download/) and [enable the "flakes" experimental
feature](https://github.com/mschwaig/howto-install-nix-with-flake-support?tab=readme-ov-file).
You then need to enter the "dev shell" by running `nix develop` (or use
[direnv](https://direnv.net/) which will then have you enter the shell
automatically on entering the folder.)

### 1. Work in the `data` directory

```sh
cd data
```

### 2. Download data for Scotland

```sh
docker run \
  --rm \
  -it \
  -v \
  $PWD:/download openmaptiles/openmaptiles-tools \
  download-osm \
  url \
  http://download.geofabrik.de/europe/united-kingdom/scotland-250901.osm.pbf -- \
  -d /download
```

### 3. Filter down to Edinburgh

```sh
wget https://raw.githubusercontent.com/JamesChevalier/cities/refs/heads/master/united_kingdom/scotland/city-of-edinburgh_scotland.poly

osmium extract \
         --polygon city-of-edinburgh_scotland.poly \
         -F pbf \
         scotland-250901.osm.pbf \
         -o edinburgh.osm.pbf
```

### 4. Use b6 to compute indexes and connect things

```sh
b6-ingest-osm --input edinburgh.osm.pbf --output edinburgh.index
b6-connect --input edinburgh.index --output edinburgh.connected.index
```

## Running

Having performed all the above steps, you can just run the backend and UI any
time you wish:

```sh
run-b6 -world data/edinburgh.connected.index
```

This will serve the HTTP endpoint on: <http://localhost:8001/> and the gRPC
endpoint (i.e. the one Python talks to) on `localhost:8002`.
