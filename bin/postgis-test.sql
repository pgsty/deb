-- Run in a disposable database after installing the freshly built RPMs.
\set ON_ERROR_STOP on
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;
CREATE EXTENSION postgis_sfcgal;
CREATE EXTENSION postgis_topology;
CREATE EXTENSION address_standardizer;
CREATE EXTENSION address_standardizer_data_us;
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION postgis_tiger_geocoder;

SET postgis.gdal_enabled_drivers = 'GTiff';
DO $$
DECLARE
    projected geometry;
    sample raster;
    roundtrip raster;
BEGIN
    IF ST_Area(ST_Union(ST_MakeEnvelope(0, 0, 2, 2),
                        ST_MakeEnvelope(1, 1, 3, 3))) <> 7 THEN
        RAISE EXCEPTION 'GEOS overlay failed';
    END IF;

    projected := ST_Transform(ST_SetSRID(ST_MakePoint(1, 1), 4326), 3857);
    IF abs(ST_X(projected) - 111319.490793274) > 0.000001 OR
       abs(ST_Y(projected) - 111325.142866385) > 0.000001 THEN
        RAISE EXCEPTION 'PROJ coordinate transformation failed';
    END IF;

    IF CG_3DArea('POLYGON Z ((0 0 0,1 0 0,1 1 0,0 1 0,0 0 0))') <> 1 THEN
        RAISE EXCEPTION 'SFCGAL 3D area failed';
    END IF;

    sample := ST_AddBand(ST_MakeEmptyRaster(2, 2, 0, 0, 1, -1, 0, 0, 4326),
                         '8BUI'::text, 7, 0);
    roundtrip := ST_FromGDALRaster(ST_AsGDALRaster(sample, 'GTiff'));
    IF ST_SRID(roundtrip) <> 4326 OR
       ST_Width(roundtrip) <> 2 OR ST_Height(roundtrip) <> 2 OR
       ST_Value(roundtrip, 1, 1, 1) <> 7 THEN
        RAISE EXCEPTION 'GDAL GeoTIFF round trip failed';
    END IF;

    PERFORM topology.CreateTopology('postgis_pilot_topology', 4326);
    PERFORM topology.DropTopology('postgis_pilot_topology');
END
$$;

SELECT extname, extversion FROM pg_extension ORDER BY extname;
SELECT postgis_full_version();
SELECT 'PostGIS GIS stack smoke tests passed' AS result;
