rm(list=ls())
library("microbenchmark")
library(raster)
library(rgdal)

# Preparação para dados postgis

dsn="PG:dbname='benchmark' host=localhost user='postgres' password='postgres' port=5432 schema='public' table='myrasters' mode=2"

dsn2="PG:dbname='benchmark' host=localhost user='postgres' password='postgres' port=5432 schema='public' table='myrasters2' mode=2"

dsn3="PG:dbname='benchmark' host=localhost user='postgres' password='postgres' port=5432 schema='public' table='myrasters3' mode=2"

# reading raster stack
?microbenchmark
readingBenchmark <- microbenchmark(
  stack("../bio_10m_bil/biostack.tif"), 
  stack("../bio_10m_bil/biostack.vrt"), 
  stack(readGDAL(dsn)),
  #stack(readGDAL(dsn2)),
  #stack(readGDAL(dsn3)),
  unit = "s")
library(ggplot2)
p <- autoplot(readingBenchmark)
str(readingBenchmark)
p + scale_x_discrete(labels=c( "*.tif", "*.vrt","PostGIS")) + xlab("Method")
ggsave("BenchMark.png", dpi=300)

# The later procedure havent being estimated
# Crop
cropBenchmark <- microbenchmark(
  stack("../bio_10m_bil/biostackCropTIFF.tif"),
  stack("../bio_10m_bil/biostackCrop.vrt"),
  unit = "s")

#Crop resampling
microbenchmark(
  stack("../bio_10m_bil/stackCropResTIFF.tif"),
  stack("../bio_10m_bil/stackCropResTest.vrt"),
  unit = "s")