# Rasters management test

Repository created to test a few possibilities for raster management.

## The challange
When working with ENM we must to deal with raster as data input (abiotic data) and output (the main outpu of ENM are raster data).
As those files will be required for several projects and experiments in differents extentions and pixelresolution, would be strategical define the *best* way to manage the rasters used as input and those generated as output.
The idea of this repository is to test a few possibilities for a better raster management. For now we will explore **PostGIS** and **gdal** functions as raster management tools. 
The original raster dataset used in this tests are from Worldclim 10 min. bio variables (`./bio_10m_bil`, with TIFF extension).

The management will consider:
a. stacking all raw data;
b. cropping the raster stack for a bounding box of interest (simulating the study area and projection area);
c. cropping the raster stack for a bounding box and resampling the pixel size.
d. mixing in the raster stack raster data with different pixel size, Coordinate Reference System, ...;

Three possibilities documented here are:
1. **Busness as usual**: Managing all raster files in fisical format with gdal tools.
2. **Virtual Raster Stack**: Managing all raster files as virtual raster stack with gdal tools keeping only raw (origin) data as fisical raster file.
3. **PostGIS**: All raster data will be included and managed in a postGIS repository with SQL language;

## Business as Usual 
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
png("./Images/biostackTIFF")
plot(stack("./biostack.tif")) # plotting all bands of .vrt file (i.e.: all bioclimatic raster)
dev.off()
quit()
```
![Fisical Raster Stack](https://github.com/Model-R/modelo-bd/blob/master/Images/biostackTIFF.png?raw=true)

### b. cropping the raster stack for a bounding box of interest (simulating the study area and projection area);

```
gdalwarp biostackCrop.vrt -te -75.0 -40.0 -33.0 -4.5 -overwrite -of "GTiff" biostackCropTIFF.tif -multi
ls -lh biostackCropTIFF.tif
-rw-rw-r-- 1 felipe felipe 2.0M Apr  5 10:46 biostackCropTIFF.tif
```

#### Testing the crop 
```
R
library(raster)
png("./Images/biostackCropTIFF.png")
plot(stack("./biostackCropTIFF.tif")) # plotting all bands of .vrt file (i.e.: all bioclimatic raster)
dev.off()
quit()
```

![Fisical Raster Stack Cropped](https://github.com/Model-R/modelo-bd/blob/master/Images/biostackCropTIFF.png?raw=true)

### c. cropping the raster stack for a bounding box and resampling the pixel size.

```
gdalwarp biostack.vrt -te -75.0 -40.0 -33.0 -4.5 -tr 0.25 0.25 -overwrite -of "GTiff" stackCropResTIFF.tif
```

#### Testing the crop and resampling 
```
R
library(raster)
png("./Images/biostackCropResTIFF.png")
plot(stack("./stackCropResTIFF.tif")) # plotting all bands of .vrt file (i.e.: all bioclimatic raster)
dev.off()
quit()
```

## Gdal alternative raster management
**(Using gdal tools using the Vitrual Raster Stack)**
  
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
gdalbuildvrt biostack.vrt -separate -overwrite $Raster_listing

# File size
ls -lh biostack.vrt
-rw-rw-r-- 1 felipe felipe 11K Apr  4 12:08 biostack.vrt
```

### Testing the result of Virtual Raster Stack

```
R
library(raster)
png("./Images/biostack")
plot(stack("./biostack.vrt")) # plotting all bands of .vrt file (i.e.: all bioclimatic raster)
dev.off()
png("./Images/bio1")
plot(raster("./biostack.vrt")) # plotting only the first band of .vrt file
dev.off()
quit()
```
  
![Vitual Raster Stack](https://github.com/Model-R/modelo-bd/blob/master/Images/biostack.png?raw=true)
  
![Virtual Raster Stack Bio10](https://github.com/Model-R/modelo-bd/blob/master/Images/bio1.png?raw=true)
  
## b. cropping the raster stack for a bounding box of interest (simulating the study area and projection area);

```
gdalbuildvrt biostackCrop.vrt -te -75.0 -40.0 -33.0 -4.5 -overwrite biostack.vrt
ls -lh biostackCrop.vrt
-rw-rw-r-- 1 felipe felipe 12K Apr  4 18:41 biostackCrop.vrt
```

### Testing the crop 

```
R
library(raster)
png("./images/biostackCrop")
plot(stack("./biostackCrop.vrt")) # plotting all bands of .vrt file (i.e.: all bioclimatic raster)
dev.off()
quit()
```

![Virtual Raster Stack Cropped](https://github.com/Model-R/modelo-bd/blob/master/Images/biostackCrop.png?raw=true)

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

#### Testing the possibility to used in a R function:

```
R
library(raster)
library(gdalUtils)
stack <- stack("./biostack.vrt")

# Estimating object size of .vrt
object.size(stack)
244616 bytes

# Estimating object size of .tif files stack
r <- stack(list.files("./", pattern=".tif$"))

object.size(r)
451056 bytes

# Loading shapefile to be used to crop
BA <- shapefile("./shp/BA.shp")

# Boundbox of the shapefile to be used
c(BA@bbox)
[1] -46.616668 -18.348743 -37.342503  -8.533223
crop <- BA
# Using gdalbuildvrt R function
gdalbuildvrt("./biostack.vrt", "./stackCropTest.vrt", te=c(crop@bbox), overwrite=TRUE, verbose = TRUE)
Checking gdal_installation...
Scanning for GDAL installations...
Checking the gdalUtils_gdalPath option...
GDAL version 2.1.0
GDAL command being used: "/usr/bin/gdalbuildvrt" -te -46.6166679288199 -18.3487434400106 -37.342502905043 -8.53322288319805 -overwrite  "./stackCropTest.vrt" "./biostack.vrt"
NULL

# Testing theresult
stackCropTest <- stack("./stackCropTest.vrt")
png("./stackCropTest")
plot(stackCropTest)
dev.off()

object.size(stackCropTest)
244792 bytes
```
![stackCropTest](https://github.com/Model-R/modelo-bd/blob/master/images/stackCropTest.png?raw=true)

### c. cropping the raster stack for a bounding box and resampling the pixel size.

```
R
library(raster)
library(gdalUtils)
gdalbuildvrt("./biostack.vrt", "./stackCropResTest.vrt", te=c(crop@bbox), tr=c(0.25,0.25), overwrite=TRUE, verbose = TRUE)
stackCropResTest <- stack("./stackCropResTest.vrt")
png("./stackCropResTest")
plot(stackCropResTest)
dev.off()

object.size(stackCropResTest)
244936 bytes
```

![stackCropResTest](https://github.com/Model-R/modelo-bd/blob/master/images/stackCropResTest.png?raw=true)

# [GDAL2Tiles](http://www.gdal.org/gdal2tiles.html)

**Description: **
This utility generates a directory with small tiles and metadata, following the OSGeo Tile Map Service Specification. Simple web pages with viewers based on Google Maps, OpenLayers and Leaflet are generated as well - so anybody can comfortably explore your maps on-line and you do not need to install or configure any special software (like MapServer) and the map displays very fast in the web browser. You only need to upload the generated directory onto a web server.
GDAL2Tiles also creates the necessary metadata for Google Earth (KML SuperOverlay), in case the supplied map uses EPSG:4326 projection.
World files and embedded georeferencing is used during tile generation, but you can publish a picture without proper georeferencing too.


# [gdal_retile](http://www.gdal.org/gdal_retile.html)

**Description:**
This utility will retile a set of input tile(s). All the input tile(s) must be georeferenced in the same coordinate system and have a matching number of bands. Optionally pyramid levels are generated. It is possible to generate shape file(s) for the tiled output.
If your number of input tiles exhausts the command line buffer, use the general –optfile option
