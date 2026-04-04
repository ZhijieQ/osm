# osm

[Link](https://download.geofabrik.de/)

## Docker dompose
```bash
# 在 Docker Desktop 设置 -> Resources 中，确保 Memory 调高
# 按 Win + R，输入 %UserProfile% 并回车
# 检查是否有 .wslconfig 文件。如果没有，新建一个（注意文件名以点开头，且没有 .txt 后缀）。
# 使用记事本打开该文件，添加以下内容：
[wsl2]
memory=8GB   # 这里改为你想要的大小，例如 12GB, 16GB
processors=4 # 顺便可以设置 CPU 核心数
# 必须重启： 运行 PowerShell，输入 wsl --shutdown。然后重新启动 Docker Desktop。

# 使用“空白”屏幕保护程序：
# 搜索“更改屏幕保护程序”。
# 选择 “空白” (Blank)。
# 设置为 1 分钟。这样屏幕会显示纯黑，像素点基本不发光（尤其是 OLED 屏）。
# “接通电源后，在以下时间后使设备进入睡眠状态”：设置为 从不（这是关键），另一个也得改从不
# WSL 2 有时会因为 Windows 尝试节省硬盘功耗而出现 IO 错误。
# 输入 “编辑电源计划” 并打开，点击 “更改高级电源设置”，找到 硬盘 -> 在此时间后关闭硬盘：
# 接通电源：设置为 0（0 代表“从不”）。
```


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

docker run --rm `
  -e JAVA_TOOL_OPTIONS="-Xmx12g -XX:+UseParallelGC" `
  -v "${PWD}:/data" `
  ghcr.io/onthegomap/planetiler:latest `
  --osm-path=/data/raw/china-latest.osm.pbf,/data/raw/spain-latest.osm.pbf `
  --output=/data/tiles/combined.pmtiles `
  --threads=$(nproc) `
  --nodemap-type=sparsearray `
  --storage=mmap

net stop winnat
docker-compose up -d
net start winnat

# Nominatim
# 启动 Nominatim 进行导入
# 需要改24gb内存和菜谱
docker run -t `
  -p 8080:8080 `
  -v "${PWD}/raw:/data" `
  --shm-size=2g `
  --name nominatim `
  -e NOMINATIM_PASSWORD=1234 `
  -e PBF_PATH=/data/merged.osm.pbf `
  -e IMPORT_THREADS=10 `
  mediagis/nominatim:5.1

# 使用 Photon 镜像连接到 Nominatim 容器并提取数据
docker run -t `
  --name photon_import `
  --link nominatim:nominatim `
  -v "${PWD}/photon_data:/photon/photon_data" `
  rtuszik/photon-docker:latest `
  java -Xmx8g -jar /photon/photon.jar `
    -nominatim-import `
    -host nominatim `
    -port 5432 `
    -database nominatim `
    -user nominatim `
    -password 1234

# 重新打开nominatin
docker start nominatim

# 启动photon服务
docker run -d `
  --name photon_service `
  -p 2322:2322 `
  -v "${PWD}/photon_data:/photon/photon_data" `
  rtuszik/photon-docker:latest `
  java -Xmx4g -jar /photon/photon.jar -listen-ip 0.0.0.0
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