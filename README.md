# Rasters management test

Repository created to test a few possibilities for raster management.

When working with ENM we must to deal with raster as data input (abiotic data) and output (the main outpu of ENM are raster data);

The idea is to test **PostGIS** and **gdal** functions as raster management tools. For now we will use Worldclim 10 min bio raster data located in `./bio_10m_bil`.

1. Using gdal tools
With gdal tools, each abiotic raster input from the dataset will be kept in the HD as a fisical file.
As those files will be required for several projects and experiments in differents extention woulb be strategical to use the [**Virtual Raster Stack**](http://www.gdal.org/gdal_vrttut.html), which is a XML with small size, indicating the rasters files that it is composed by, the extent of the study and others information (must take a look about metadata).
By using .vrt format redundancy of raster creating would be avoided as well as file size would be reduced. Also, would bepossible to have only the extent under interest loaded for the model process.
The Virtual Raster Stack uses the strategy of [lazy avaluation](https://en.wikipedia.org/wiki/Lazy_evaluation). The [Lazyevaluation was compared ](http://www.perrygeo.com/lazy-raster-processing-with-gdal-vrts.html). More links [here](http://www.paolocorti.net/2012/03/08/gdal_virtual_formats/)

```
cd Projetos/Marinez/Model-R/modelo-bd/RasterData/bio_10m_bil
Raster_listing=`ls *.tif`
echo $Raster_listing
# Merging all bio raster data to one single virtual raster stack
gdalbuildvrt biostack.vrt -separate -overwrite $Raster_listing

```
### Testing the result of Virtual Raster Stack

```
R
png("./images/biostack")
plot(stack("./biostack.vrt")) # plotting all bands of .vrt file (i.e.: all bioclimatic raster)
dev.off()
png("./images/bio1")
plot(raster("./biostack.vrt")) # plotting only the first band of .vrt file
dev.off()
quit()
```
![Vitual Raster Stack](https://github.com/Model-R/modelo-bd/blob/master/images/biostack.png?raw=true)

![Virtual Raster Stack Bio10](https://github.com/Model-R/modelo-bd/blob/master/images/bio1.png?raw=true)

Also it is possible to create others Virtual Raster Stack from another, changing extention and resolution:
```
gdalbuildvrt biostackCrop.vrt -te -75.0 -40.0 -33.0 -4.5 -overwrite biostack.vrt
```
In the exemple above, the Virtual Raster Stack to a bounding box.

```
R
png("./images/biostackCrop")
plot(stack("./biostackCrop.vrt")) # plotting all bands of .vrt file (i.e.: all bioclimatic raster)
dev.off()
quit()
```

![Virtual Raster Stack Cropped](https://github.com/Model-R/modelo-bd/blob/master/images/biostackCrop.png?raw=true)

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

## Testing the possibility to used in a R function:

```
> library(raster)
> library(gdalUtils)
> stack <- stack("./biostack.vrt")
# Estimating object size of .vrt
> object.size(stack)
244616 bytes
# Estimating object size of .tif files stack
> r <- stack(list.files("./", pattern=".tif$"))
> object.size(r)
451056 bytes

# Loading shapefile to be used to crop
> BA <- shapefile("./shp/BA.shp")

# Boundbox of the shapefile to be used
> c(BA@bbox)
[1] -46.616668 -18.348743 -37.342503  -8.533223
> crop <- BA
# Using gdalbuildvrt R function
> gdalbuildvrt("./biostack.vrt", "./stackCropTest.vrt", te=c(crop@bbox), overwrite=TRUE, verbose = TRUE)
Checking gdal_installation...
Scanning for GDAL installations...
Checking the gdalUtils_gdalPath option...
GDAL version 2.1.0
GDAL command being used: "/usr/bin/gdalbuildvrt" -te -46.6166679288199 -18.3487434400106 -37.342502905043 -8.53322288319805 -overwrite  "./stackCropTest.vrt" "./biostack.vrt"
NULL

# Testing theresult
> stackCropTest <- stack("./stackCropTest.vrt")
> png("./stackCropTest")
> plot(stackCropTest)
> dev.off()
null device 
          1 
> object.size(stackCropTest)
244792 bytes
```
![stackCropTest](https://github.com/Model-R/modelo-bd/blob/master/images/stackCropTest.png?raw=true)

## Testing the same function but changing the resolution

```
> gdalbuildvrt("./biostack.vrt", "./stackCropResTest.vrt", te=c(crop@bbox), tr=c(0.25,0.25), overwrite=TRUE, verbose = TRUE)
Checking gdal_installation...
Scanning for GDAL installations...
Checking the gdalUtils_gdalPath option...
GDAL version 2.1.0
GDAL command being used: "/usr/bin/gdalbuildvrt" -te -46.6166679288199 -18.3487434400106 -37.342502905043 -8.53322288319805 -tr 0.25 0.25 -overwrite  "./stackCropResTest.vrt" "./biostack.vrt"
NULL
> stackCropResTest <- stack("./stackCropResTest.vrt")
> png("./stackCropResTest")
> plot(stackCropResTest)
> dev.off()
null device 
          1 
> object.size(stackCropResTest)
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
