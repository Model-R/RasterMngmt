TIMEFORMAT="%R;%U;%S;Cropping;PostGIS"

#crop
for a in {1..100}; do psql -U postgres -d benchmark -c "DROP TABLE IF EXISTS bioex;"; { time  psql -U postgres -d benchmark -c "CREATE TABLE bioex as SELECT ST_Band( ST_clip( ST_Union( bio.rast), ST_GeometryFromText('POLYGON((-75 -33,-75 -4.5,-40 -4.5,-40 -33,-75 -33))', 4326)),  '{1,2,3,4,5,6,7,8,9,10,11,12}'::int[]) as rast FROM public.myrasters3 as bio;";} 2>> ./benchmark_rasterCrop.csv; done;

TIMEFORMAT="%R;%U;%S;cropping + resampling;PostGIS"
# crop + resample
for a in {1..100}; do psql -U postgres -d benchmark -c "DROP TABLE IF EXISTS bioexCropRes;"; { time  psql -U postgres -d benchmark -c "CREATE TABLE bioexCropRes as SELECT ST_Band( st_resample( ST_clip( ST_Union( bio.rast), ST_GeometryFromText('POLYGON((-75 -33,-75 -4.5,-40 -4.5,-40 -33,-75 -33))', 4326)), 0.25, -0.25) , '{1,2,3,4,5,6,7,8,9}'::int[]) as rast FROM public.myrasters3 as bio;"; } 2>> ./benchmark_rasterCropRes.csv; done



TIMEFORMAT="%R;%U;%S;operacao;armazenamento"
for a in {1..2}
do
{ time sleep 5; } 2>> teste.txt	
sleep 5				
done
