-- Creating a raster table wothout tile and with tow bands from biostack
-- DROP TABLE bioex
-- first create a raster table
 CREATE TABLE bioex(rid SERIAL primary key, 
	rast raster, filename text);

-- Inserting band one and two from biostack on bioex
	INSERT INTO bioex(rast)
	VALUES(
		--ST_AddBand(
			-- Return band 1
			(SELECT ST_Band(
				ST_Union( --merging the tiles
					bio.rast),
					 '{1,2}'::int[]) 
					 as rast FROM public.biostack as bio)--,
			--1, '32BUI'::text, 0, NULL)
			);

-- Testing if is possible to crop
(SELECT ST_Band(
		ST_clip( --merging the tiles
					bio.rast, ST_GeometryFromText('POLYGON((75 33,75 4.5,40 4.5,40 33,75 33))', 4326)),
					 '{1,2}'::int[]) 
					 as rast FROM public.bioex as bio)--,

-- Creating a raster table with part of bioex raster table:
-- DROP TABLE biocrop
--  Creating the raster table
 CREATE TABLE biocrop(rid SERIAL primary key, 
	rast raster, filename text);

--Inserting band empty NOT croped 
-- TO DO: Insert it empty
INSERT INTO biocrop(rast, filename)
	VALUES(
(SELECT ST_Band(
		--ST_clip(
			bio.rast,
				'{1}'::int[] )
					 as rast FROM public.bioex as bio)
					 , 'registro 1' );

--Inserting another band empty NOT croped 
-- TO DO: Insert ti empty
UPDATE 
    biocrop
SET 
    rast = ST_AddBand(rast,
		(SELECT ST_Band(
			bio.rast,
				'{2}'::int[] )
					 as rast FROM public.bioex as bio));

--Inserting another band CROPED
UPDATE 
    biocrop
SET 
    rast = ST_AddBand(rast,
		(SELECT ST_Band(
				ST_clip( --merging the tiles
					bio.rast, ST_GeometryFromText('POLYGON((75 33,75 4.5,40 4.5,40 33,75 33))', 4326)),
					 '{2}'::int[]) 
					 as rast FROM public.bioex as bio));

--Inserting another ROW croped 
INSERT INTO biocrop(rast)
	VALUES(
(SELECT ST_Band(
				ST_clip( --merging the tiles
					bio.rast, ST_GeometryFromText('POLYGON((75 33,75 4.5,40 4.5,40 33,75 33))', 4326)),
					 '{2}'::int[]) 
					 as rast FROM public.bioex as bio));



CREATE INDEX ON "public"."biocrop" USING gist (st_convexhull("rast"));
ANALYZE "public"."biocrop";
VACUUM ANALYZE "public"."biocrop";

--Inserting band croped
INSERT INTO biocrop(rast, filename)
	VALUES(
(SELECT ST_Band(
				ST_clip( --merging the tiles
					bio.rast, ST_GeometryFromText('POLYGON((75 33,75 4.5,40 4.5,40 33,75 33))', 4326)),
					 '{2}'::int[]) 
					 as rast FROM public.bioex as bio)
					 , 'band crop' );

-- output meta data of raster -
SELECT  (rmd).width, (rmd).height, (rmd).numbands
FROM (SELECT ST_MetaData(rast) As rmd
    FROM biocrop ) AS foo;

-- Inserting another extent to the same table as another BAND
--ERROR
--NOTICE:  rt_raster_copy_band: Attempting to add a band with different width or height
--NOTICE:  RASTER_copyBand: Could not add band to raster. Returning original raster.
--Query returned successfully: one row affected, 184 msec execution time.

UPDATE 
    biocrop
SET 
    rast = ST_AddBand(rast,
		(SELECT ST_Band(
				ST_clip( --merging the tiles
					bio.rast, ST_GeometryFromText('POLYGON((90 33,90 4.5,60 4.5,60 33,90 33))', 4326)),
					 '{1}'::int[]) 
					 as rast FROM public.bioex as bio)
					 );

-- Adding another band with same area but differente extent
UPDATE 
    biocrop
SET 
    rast = ST_AddBand(rast,
		(SELECT ST_Band(
				ST_clip( --merging the tiles
					bio.rast, ST_GeometryFromText('POLYGON((78 36,78 7.5,43 7.5,43 36,78 36))', 4326)),
					 '{1}'::int[]) 
					 as rast FROM public.bioex as bio)
					 );


SELECT AddRasterConstraints('biocrop'::name, 'rast'::name, 'srid')
-- Make 2 new rasters: 1 containing band 1 of dummy, second containing band 2 of dummy and then reclassified as a 2BUI
SELECT ST_NumBands(rast1) As numb1, ST_BandPixelType(rast1) As pix1,
 ST_NumBands(rast2) As numb2,  ST_BandPixelType(rast2) As pix2
FROM (
    SELECT ST_Band(rast) As rast1, ST_Reclass(ST_Band(rast,3), '100-200):1, [200-254:2', '2BUI') As rast2
        FROM dummy_rast
        WHERE rid = 2) As foo;


-- Return bands 2 and 3. Use array to define bands
SELECT ST_NumBands(ST_Band(rast, ARRAY[2,3])) As num_bands
    FROM dummy_rast
WHERE rid=2;


--Make a new raster with 2nd band of original and 1st band repeated twice, and another with just the third band
SELECT rast, ST_Band(rast, ARRAY[2,1,1]) As dupe_band,
	ST_Band(rast, 3) As sing_band
FROM samples.than_chunked
WHERE rid=35;


--# NEW Traying
-- Traying to work with views
-- Creating a raster table VIEW with part of bioex raster table:
--  Creating the raster table
 CREATE OR REPLACE VIEW biocropview --(rid SERIAL primary key, rast raster, filename text) 
	as SELECT ST_Band(
		ST_clip( 
			ST_Union(--merging the tiles
					bio.rast), ST_GeometryFromText('POLYGON((75 33,75 4.5,40 4.5,40 33,75 33))', 4326)),
					 '{1,2,3}'::int[]) 
					 as rast FROM public.biostack as bio;

CREATE OR REPLACE VIEW biocropview --(rid SERIAL primary key, rast raster, filename text) 
SELECT ST_Band(
		ST_clip( --merging the tiles
					bio.rast, ST_GeometryFromText('POLYGON((75 33,75 4.5,40 4.5,40 33,75 33))', 4326)),
					 '{1,2,3}'::int[]) 
					 as rast FROM public.bioex as bio;

					 SELECT  (rmd).width, (rmd).height, (rmd).numbands
FROM (SELECT ST_MetaData(rast) As rmd
    FROM biocropview ) AS foo;

SELECT srid, scale_x, scale_y, blocksize_x, blocksize_y, num_bands, pixel_types, nodata_values
	FROM raster_columns
	WHERE r_table_name = 'rasterteste';

