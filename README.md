# osm

[Link](https://download.geofabrik.de/)

## Style
- https://shortbread-tiles.org/
- https://github.com/maputnik/osm-liberty/tree/gh-pages
- https://github.com/openmaptiles/positron-gl-style/tree/master?tab=readme-ov-file
- https://github.com/jake-low/sourdough

```bash
cd map_data

docker run --rm -v "${PWD}:/data" iboates/osmium `
    merge /data/raw/china-latest.osm.pbf /data/raw/spain-latest.osm.pbf -o /data/raw/merged.osm.pbf

docker run --rm `
  -e JAVA_TOOL_OPTIONS="-Xmx12g -XX:+UseParallelGC" `
  -v "${PWD}:/data" `
  ghcr.io/onthegomap/planetiler:latest `
  --osm-path=/data/raw/merged.osm.pbf `
  --output=/data/tiles/combined.pmtiles `
  --threads=$(nproc) `
  --nodemap-type=sparsearray `
  --storage=mmap


net stop winnat
docker-compose up -d
net start winnat
```

## Another form
```bash
docker run --rm `
  -e JAVA_TOOL_OPTIONS="-Xmx8g" `
  -v "${PWD}:/data" `
  ghcr.io/onthegomap/planetiler:latest `
  --osm-path=/data/raw/spain-latest.osm.pbf `
  --output=/data/tiles/spain.pmtiles `
  --download


docker run --rm `
  -e JAVA_TOOL_OPTIONS="-Xmx8g" `
  -v "${PWD}:/data" `
  ghcr.io/onthegomap/planetiler:latest `
  --osm-path=/data/raw/china-latest.osm.pbf `
  --output=/data/tiles/china.pmtiles `
  --download


docker run -it --rm `
  -v "${PWD}:/data" `
  tippecanoe:latest `
  tile-join -o /data/tiles/combined.pmtiles /data/tiles/china.pmtiles /data/tiles/spain.pmtiles

docker run --rm -v "${PWD}:/data" protomaps/go-pmtiles `
    merge /data/tiles//china.pmtiles /data/tiles//spain.pmtiles /data/tiles//combined.pmtiles
```