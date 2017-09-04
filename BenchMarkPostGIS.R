TIMEFORMAT="%R;%U;%S;operacao;armazenamento"

# Teste
{ time for a in {1..3}; do psql -U postgres -d benchmark -c "select * from bioex"; done; } 2>> ~/benchmark_raster.csv

#crop
{ time for a in {1..100}; do psql -U postgres -d benchmark -c "DROP TABLE IF EXISTS bioex; CREATE TABLE bioex as SELECT ST_Band( ST_clip( ST_Union( bio.rast), ST_GeometryFromText('POLYGON((-75 -33,-75 -4.5,-40 -4.5,-40 -33,-75 -33))', 4326)),  '{1,2,3,4,5,6,7,8,9}'::int[]) as rast FROM public.myrasters3 as bio;"; done; } 2>> ./benchmark_raster.csv

# crop + resample
{ time for a in {1..100}; do psql -U postgres -d benchmark -c "DROP TABLE IF EXISTS bioexCropRes; CREATE TABLE bioexCropRes as SELECT ST_Band( st_resample( ST_clip( ST_Union( bio.rast), ST_GeometryFromText('POLYGON((-75 -33,-75 -4.5,-40 -4.5,-40 -33,-75 -33))', 4326)), 0.25, -0.25) , '{1,2,3,4,5,6,7,8,9}'::int[]) as rast FROM public.myrasters3 as bio;"; done; } 2>> ./benchmark_rasterCropRes.csv

#