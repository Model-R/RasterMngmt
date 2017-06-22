# Rasters management test

Repository created to test a few possibilities for raster management.

## The challange
When working with ENM we must to deal with raster as data input (abiotic data) and output (the main outpu of ENM are raster data).
As those files will be required for several projects and experiments in differents extentions and pixelresolution, would be strategical define the *best* way to manage the rasters used as input and those generated as output.
The idea of this repository is to test a few possibilities for a better raster management. For now we will explore **PostGIS** and **gdal** functions as raster management tools. 
The original raster dataset used in this tests are from Worldclim 10 min. bio variables (`./bio_10m_bil`, with TIFF extension).

### The test management will consider:
a. stacking all raw data;
b. cropping the raster stack for a bounding box of interest (simulating the study area and projection area);
c. cropping the raster stack for a bounding box and resampling the pixel size.
d. mixing in the raster stack raster data with different pixel size, Coordinate Reference System, ...;

### Three possibilities documented here are:
1. **Busness as usual**: Managing all raster files in fisical format with gdal tools (like *.tif).
2. **Virtual Raster Stack**: Managing all raster files as virtual raster stack (*.vrt) with gdal tools keeping only raw (original) data as fisical raster file (*.tif).
3. **PostGIS**: All raster data will be stored and managed in a postGIS repository with SQL language;

# Executive summary

|       Raster  Management      	| Original dataset stack (ODS)  	|    ODS in R   	| Croped dataset 	| Cropped dataset in R 	|
|:-----------------------------:	|:-----------------------------:	|:-------------:	|:--------------:	|:--------------------:	|
| Fisical raster format (*.tif) 	|              71M              	|  232632 bytes 	|      2.0M      	|     232936 bytes     	|
| Virtual raster format (*.vrt) 	|             11K *             	|  244616 bytes 	|       12K      	|     244616 bytes     	|
|            PostGIS            	|              27 M             	| 7787904 bytes 	|      64 K      	|     155544 bytes     	|

# Management Tests

## 1. Business as Usual 
**(Using gdal tools and keeping all raster files in fisical format)**

### a. stacking all raw data;
```
cd Projetos/Marinez/Model-R/modelo-bd/RasterData/bio_10m_bil
Raster_listing=`ls *.tif`
echo $Raster_listing

# Using fisical Raster Stack
gdal_merge.py -o biostack.tif -of "GTiff" -v -separate -pct $Raster_listing

# File size
ls -lh biostack.tif
-rw-rw-r-- 1 felipe felipe 71M Apr  4 08:52 biostack.tif
```

#### Testing the result of fisical raster stack (.tif)

```
R
library(raster)
png("./bio_10m_bil/Images/biostackTIFF.png")
plot(stack("./bio_10m_bil/biostack.tif")) # plotting all bands of .tif file (i.e.: all bioclimatic raster)
dev.off()

# object size in R environment
object.size(stack("./bio_10m_bil/biostack.tif"))
232632 bytes
quit()
```
![Fisical Raster Stack](https://github.com/Model-R/RasterMngmt/blob/master/bio_10m_bil/Images/biostackTIFF.png?raw=true)

### b. cropping the raster stack for a bounding box of interest (simulating the study area and projection area);

```
gdalwarp biostack.tif -te -75.0 -40.0 -33.0 -4.5 -overwrite -of "GTi
ff" biostackCropTIFF.tif -multi
ls -lh biostackCropTIFF.tif
-rw-rw-r-- 1 felipe felipe 2.0M Apr  5 10:46 biostackCropTIFF.tif
```

#### Testing the crop 
```
R
library(raster)
png("./bio_10m_bil/Images/biostackCropTIFF.png")
plot(stack("./bio_10m_bil/biostackCropTIFF.tif")) # plotting all bands of .vrt file (i.e.: all bioclimatic raster)
dev.off()

# object size in R environment
object.size(stack("./bio_10m_bil/biostackCropTIFF.tif"))
232936 bytes
quit()
```

![Fisical Raster Stack Cropped](https://github.com/Model-R/RasterMngmt/blob/master/bio_10m_bil/Images/biostackCropTIFF.png?raw=true)

### c. cropping the raster stack for a bounding box and resampling the pixel size.

```
gdalwarp biostack.tif -te -75.0 -40.0 -33.0 -4.5 -tr 0.25 0.25 -overwrite -of "GTiff" stackCropResTIFF.tif

ls -lh stackCropResTIFF.tif-rw-rw-r-- 1 felipe felipe 887K Apr  5 15:01 stackCropResTIFF.tif
```

#### Testing the crop and resampling 

```
R
library(raster)
png("./bio_10m_bil/Images/biostackCropResTIFF.png")
plot(stack("./bio_10m_bil/stackCropResTIFF.tif"))
dev.off()

object.size(stack("./bio_10m_bil/stackCropResTIFF.tif"))
232936 bytes
quit()
```
![](https://github.com/Model-R/RasterMngmt/blob/master/bio_10m_bil/Images/biostackCropResTIFF.png?raw=true)

## 2. Gdal Virtual Raster Management
**(Using gdal tools but Vitrual Raster Stack instead of *.tif)**
  
The [**Virtual Raster Stack**](http://www.gdal.org/gdal_vrttut.html) is a XML with small size, indicating the origin rasters files (which must be in fisical format) that it is composed by, the extent of the study and others information (must take a look about **metadata**, later).
By using .vrt format redundancy of raster creating is avoided as well as file size would be reduced. Also, would bepossible to have only the extent under interest loaded for the model process, among others raster processing possibilities.
The Virtual Raster Stack uses the strategy of [lazy avaluation](https://en.wikipedia.org/wiki/Lazy_evaluation). The [Lazy evaluation was compared ](http://www.perrygeo.com/lazy-raster-processing-with-gdal-vrts.html). More links [here](http://www.paolocorti.net/2012/03/08/gdal_virtual_formats/)

### a. stacking all raw data;

```
cd Projetos/Marinez/Model-R/modelo-bd/RasterData/bio_10m_bil
Raster_listing=`ls *.tif`
echo $Raster_listing

# Using Virtual Raster Stack:
# Merging all bio raster data to one single virtual raster stack
gdalbuildvrt ./bio_10m_bil/biostack.vrt -separate -overwrite $Raster_listing

# File size
ls -lh ./bio_10m_bil/biostack.vrt
-rw-rw-r-- 1 felipe felipe 11K Apr  4 12:08 biostack.vrt
```

### Testing the result of Virtual Raster Stack

```
R
library(raster)
png("./bio_10m_bil/Images/biostack.png")
plot(stack("./bio_10m_bil/biostack.vrt")) # plotting all bands of .vrt file (i.e.: all bioclimatic raster)
dev.off()

# object size:
object.size(stack("./bio_10m_bil/biostack.vrt"))
244616 bytes

png("./bio_10m_bil/Images/bio1.png")
plot(raster("./bio_10m_bil/biostack.vrt")) # plotting only the first band of .vrt file
dev.off()
quit()
```
  
![Vitual Raster Stack](https://github.com/Model-R/RasterMngmt/blob/master/bio_10m_bil/Images/biostack.png?raw=true)
  
![Virtual Raster Stack Bio10](https://github.com/Model-R/RasterMngmt/blob/master/bio_10m_bil/Images/bio1.png?raw=true)
  
### b. cropping the raster stack for a bounding box of interest (simulating the study area and projection area);

```
gdalbuildvrt biostackCrop.vrt -te -75.0 -40.0 -33.0 -4.5 -overwrite biostack.vrt

ls -lh biostackCrop.vrt
-rw-rw-r-- 1 felipe felipe 12K Apr  4 18:41 biostackCrop.vrt
```

### Testing the crop 

```
R
library(raster)
png("./bio_10m_bil/Images/biostackCrop.png")
plot(stack("./bio_10m_bil/biostackCrop.vrt"))
dev.off()

# object size
object.size(stack("./bio_10m_bil/biostackCrop.vrt"))
244616 bytes

quit()
```

![Virtual Raster Stack Cropped](https://github.com/Model-R/RasterMngmt/blob/master/bio_10m_bil/Images/biostackCrop.png?raw=true)

#### Getting info about Virtual Raster Stack cropped
```
gdalinfo biostackCrop.vrt
Driver: VRT/Virtual Raster
Files: biostackCrop.vrt
       /home/felipe/Projetos/Marinez/ModelR/modelo-bd/RasterData/bio_10m_bil/biostack.vrt
Size is 252, 213
Coordinate System is:
GEOGCS["WGS 84",
    DATUM["WGS_1984",
        SPHEROID["WGS 84",6378137,298.257223563,
            AUTHORITY["EPSG","7030"]],
        AUTHORITY["EPSG","6326"]],
    PRIMEM["Greenwich",0],
    UNIT["degree",0.0174532925199433],
    AUTHORITY["EPSG","4326"]]
Origin = (-75.000000000000000,-4.500000000000000)
Pixel Size = (0.166666666666667,-0.166666666666667)
Corner Coordinates:
Upper Left  ( -75.0000000,  -4.5000000) ( 75d 0' 0.00"W,  4d30' 0.00"S)
Lower Left  ( -75.0000000, -40.0000000) ( 75d 0' 0.00"W, 40d 0' 0.00"S)
Upper Right ( -33.0000000,  -4.5000000) ( 33d 0' 0.00"W,  4d30' 0.00"S)
Lower Right ( -33.0000000, -40.0000000) ( 33d 0' 0.00"W, 40d 0' 0.00"S)
Center      ( -54.0000000, -22.2500000) ( 54d 0' 0.00"W, 22d15' 0.00"S)
Band 1 Block=128x128 Type=Int16, ColorInterp=Undefined
  Min=-17.000 Max=291.000 
  Minimum=-17.000, Maximum=291.000, Mean=235.402, StdDev=48.517
  NoData Value=-9999
  Metadata:
    STATISTICS_MAXIMUM=291
    STATISTICS_MEAN=235.40220714961
    STATISTICS_MINIMUM=-17
    STATISTICS_STDDEV=48.516581297856
Band 2 Block=128x128 Type=Int16, ColorInterp=Undefined
  Min=-113.000 Max=270.000 
  Minimum=-113.000, Maximum=270.000, Mean=178.848, StdDev=72.508
  NoData Value=-9999
  Metadata:
    STATISTICS_MAXIMUM=270
    STATISTICS_MEAN=178.8483627064
    STATISTICS_MINIMUM=-113
    STATISTICS_STDDEV=72.508256895495
Band 3 Block=128x128 Type=Int16, ColorInterp=Undefined
  Min=0.000 Max=5238.000 
  Minimum=0.000, Maximum=5238.000, Mean=1269.451, StdDev=678.212
  NoData Value=-9999
  Metadata:
    STATISTICS_MAXIMUM=5238
    STATISTICS_MEAN=1269.4505754156
    STATISTICS_MINIMUM=0
    STATISTICS_STDDEV=678.21181914662
Band 4 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 5 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 6 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 7 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 8 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 9 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 10 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 11 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 12 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 13 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 14 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 15 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 16 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 17 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 18 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
Band 19 Block=128x128 Type=Int16, ColorInterp=Undefined
  NoData Value=-9999
```

#### Testing the possibility to use in a R function:
**(if considering this approach, the code above could be used to build the function for writting raster)**

```
R
library(raster)
library(gdalUtils)
stack <- stack("./bio_10m_bil/biostack.vrt")

# Loading shapefile to be used to crop
BA <- shapefile("./bio_10m_bil/shp/BA.shp")

# Boundbox of the shapefile to be used
c(BA@bbox)
[1] -46.616668 -18.348743 -37.342503  -8.533223
crop <- BA
# Using gdalbuildvrt R function
gdalbuildvrt("./bio_10m_bil/biostack.vrt", "./bio_10m_bil/stackCropTest.vrt", te=c(crop@bbox), overwrite=TRUE, verbose = TRUE)

# Testing the result
stackCropTest <- stack("./bio_10m_bil/stackCropTest.vrt")
png("./bio_10m_bil/Images/stackCropTest.png")
plot(stackCropTest)
dev.off()
```
![stackCropTest](https://github.com/Model-R/RasterMngmt/blob/master/bio_10m_bil/Images/stackCropTest.png?raw=true)

### c. cropping the raster stack for a bounding box and resampling the pixel size.
```
# No Bash
gdalbuildvrt stackCropResTest.vrt -te -75.0 -40.0 -33.0 -4.5 -tr 0.25 0.25 -overwrite  biostack.tif

```
#### Testing the possibility to use in a R function:
**(if considering this approach, the code above could be used to build the function for writting raster)**
```
R
library(raster)
library(gdalUtils)
gdalbuildvrt("./bio_10m_bil/biostack.vrt", "./bio_10m_bil/stackCropResTest.vrt", te=c(crop@bbox), tr=c(0.25,0.25), overwrite=TRUE, verbose = TRUE)
stackCropResTest <- stack("./bio_10m_bil/stackCropResTest.vrt")
png("./bio_10m_bil/Images/stackCropResTest.png")
plot(stackCropResTest)
dev.off()

object.size(stackCropResTest)
244936 bytes
quit()

ls -lh ./bio_10m_bil/stackCropResTest.vrt
12 -rw-rw-r-- 1 felipe felipe 11516 Apr  4 22:35 ./stackCropResTest.vrt
```

![stackCropResTest](https://github.com/Model-R/RasterMngmt/blob/master/bio_10m_bil/Images/stackCropResTest.png?raw=true)


## 3. PostGIS
This approach is based by [this blog post](https://duncanjg.wordpress.com/2012/10/28/postgis-raster/)
Must consider using [-l OVERVIEW_FACTOR](https://postgis.net/docs/using_raster_dataman.html) when using raster hosted in database for visualzation.
-F

### a. stacking all raw data;

#### Creating a data base to host raster data:
```
sudo su postgres
createdb rastertest
psql rastertest
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
CREATE TABLE myrasters(rid serial primary key, rast raster, filename text);
\q # Exit from rastertest database
```
##### Importing all rasters to rastertest database
See importRasterPG.sh for more info on raster import preparation;
```
./importRasterPG.sh
```
#### Estimating its size 
```
psql rastertest

SELECT pg_size_pretty( pg_database_size( current_database() ) ) As human_size;

 human_size 
------------
 27 MB
(1 row)

```

```{r}
R

library(raster)
library(rgdal)

dsn="PG:dbname='rastertest' host=localhost user='postgres' password='postgres' port=5432 schema='public' table='myrasters' mode=2"

ras <- raster(readGDAL(dsn)) # Get your file as SpatialGridDataFrame

PG:dbname='rastertest' host=localhost user='postgres' password='postgres' port=5432 schema='public' table='myrasters' mode=2 has GDAL driver PostGISRaster 
and has 900 rows and 2160 columns

png("./bio_10m_bil/Images/biostackPostGIS.png")
plot(ras[[1]])
dev.off()

# object size in R environment
object.size(ras)
7787904 bytes
quit()
```

### b. cropping the raster stack for a bounding box of interest (simulating the study area and projection area);

**Shearching about ways of storing those datas and having tested a few possibilities (all that I could realize) I could say that we eill have to save the `cliped` raster data in a different table (or view) for each experiment and/or project. This is because in a raster table, each row are used to store each tile of the raster (if any). So, the only way to store more than one raster layer in the same table is storing it as a different band. And band can only be added to a raster table if having the same pixel size, extent, coordinate reference system, among others. Actually this must apply for every rasterdata according to [gdal data model](http://www.gdal.org/gdal_datamodel.html)**

```
CREATE TABLE clippingtable as
with PolClip as (select ST_GeometryFromText('POLYGON((-75 -33,-75 -4.5,-40 -4.5,-40 -33,-75 -33))', 4326) as geom) 
select st_union(
	st_clip(myrasters.rast, p.geom, TRUE)
	) as rast from myrasters, PolClip as p where myrasters.filename = 'bio1.bil' and ST_Intersects(myrasters.rast, p.geom)


SELECT AddRasterConstraints('public'::name, 'clippingtable'::name, 'rast'::name);
```
Acessing data from R

```
R
library(raster)
library(rgdal)
library(RPostgreSQL)
# loading croped raster
dsn="PG:dbname='rastertest' host=localhost user='postgres' password='postgres' port=5432 schema='public' table='clippingtable' mode=2"
ras <- raster(readGDAL(dsn))
plot(ras)
```
##### To implement as tool, if necessary **(Not ready yet)**
```
extent <- as(extent(c(-75.0, -40.0, -33.0, -4.5 )), 'SpatialPolygons')

coords <- apply(extent@polygons[[1]]@Polygons[[1]]@coords, 1, paste, collapse=" ")

coords <- paste(coords, collapse=",")
geomClip <- sprintf("select ST_GeometryFromText('POLYGON((%s))', 4326)", coords);


# A) Loading raster but selecting a specific layer (bio1)
dsn="PG:dbname='rastertest' host=localhost user='postgres' password='postgres' port=5432 schema='public' table='myrasters' -sql 'SELECT * FROM myrasters where filename = 'bio1.bil'' mode=2"

ras <- raster(readGDAL(dsn))
plot(ras)

```

### c. cropping the raster stack for a bounding box and resampling the pixel size.
**Not tested yet**

```
library(rgdal)
library(raster)
rm(ras)
dsn="PG:dbname='rastertest' host=localhost user='postgres' password='postgres' port=5432 schema='public' table='biocrop' -sql 'SELECT * FROM biocrop where filename = 'registro 1'' mode=1"

dsn="PG:dbname='rastertest' host=localhost user='postgres' password='postgres' port=5432 schema='public' table='biocropview' mode=1"

ras <- stack(readGDAL(dsn)[[c(1,2,3)]])
plot(ras)
plot(ras[[2]])
plot(ras[[1]])

```


# -----
# Random information
## [GDAL2Tiles](http://www.gdal.org/gdal2tiles.html)

**Description:**
This utility generates a directory with small tiles and metadata, following the OSGeo Tile Map Service Specification. Simple web pages with viewers based on Google Maps, OpenLayers and Leaflet are generated as well - so anybody can comfortably explore your maps on-line and you do not need to install or configure any special software (like MapServer) and the map displays very fast in the web browser. You only need to upload the generated directory onto a web server.
GDAL2Tiles also creates the necessary metadata for Google Earth (KML SuperOverlay), in case the supplied map uses EPSG:4326 projection.
World files and embedded georeferencing is used during tile generation, but you can publish a picture without proper georeferencing too.


## [gdal_retile](http://www.gdal.org/gdal_retile.html)

**Description:**
This utility will retile a set of input tile(s). All the input tile(s) must be georeferenced in the same coordinate system and have a matching number of bands. Optionally pyramid levels are generated. It is possible to generate shape file(s) for the tiled output.
If your number of input tiles exhausts the command line buffer, use the general –optfile option

