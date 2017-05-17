-- Creating a raster table with a parto of biostack raster table:
-- DROP TABLE biocrop
-- first create a raster table
 CREATE TABLE biocrop(rid SERIAL primary key, 
	rast raster, filename text);

	INSERT INTO biocrop(rast, filename)
	VALUES(
		--ST_AddBand(
			-- Return band 1
			(SELECT ST_Band(
				ST_Union( --merging the tiles
					bio.rast),
					 '{1}'::int[]) 
					 as rast FROM public.biostack as bio)--,
			--1, '32BUI'::text, 0, NULL)
			, 'registro 1' );


		

-- Make 2 new rasters: 1 containing band 1 of dummy, second containing band 2 of dummy and then reclassified as a 2BUI
SELECT ST_NumBands(rast1) As numb1, ST_BandPixelType(rast1) As pix1,
 ST_NumBands(rast2) As numb2,  ST_BandPixelType(rast2) As pix2
FROM (
    SELECT ST_Band(rast) As rast1, ST_Reclass(ST_Band(rast,3), '100-200):1, [200-254:2', '2BUI') As rast2
        FROM dummy_rast
        WHERE rid = 2) As foo;

 numb1 | pix1 | numb2 | pix2
-------+------+-------+------
     1 | 8BUI |     1 | 2BUI


-- Return bands 2 and 3. Using array cast syntax
SELECT ST_NumBands(ST_Band(rast, '{2,3}'::int[])) As num_bands
    FROM dummy_rast WHERE rid=2;

num_bands
----------
2

-- Return bands 2 and 3. Use array to define bands
SELECT ST_NumBands(ST_Band(rast, ARRAY[2,3])) As num_bands
    FROM dummy_rast
WHERE rid=2;


--Make a new raster with 2nd band of original and 1st band repeated twice, and another with just the third band
SELECT rast, ST_Band(rast, ARRAY[2,1,1]) As dupe_band,
	ST_Band(rast, 3) As sing_band
FROM samples.than_chunked
WHERE rid=35;