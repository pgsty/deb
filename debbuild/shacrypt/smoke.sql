\set ON_ERROR_STOP on
CREATE EXTENSION shacrypt;
DO $$ BEGIN
    IF (SELECT extversion FROM pg_extension WHERE extname = 'shacrypt') <> '1.1' THEN
        RAISE EXCEPTION 'expected SQL extension version 1.1';
    END IF;
    -- Known answers from upstream expected/sha256.out and expected/sha512.out.
    IF sha256_crypt('Hello world!', '$5$saltstring') <>
       '$5$saltstring$5B8vYYiY.CVt1RlTTf8KbXBH3hsxY/GNooZaBBGWEc5' THEN
        RAISE EXCEPTION 'SHA256-CRYPT known-answer test failed';
    END IF;
    IF sha512_crypt('Hello world!', '$6$saltstring') <>
       '$6$saltstring$svn8UoSVapNtMuq1ukKS4tPQd8iKwSMHWjl/O817G3uBnIFNjnQJuesI68u4OTLiBFdcbYEdFCoEOfaS35inz1' THEN
        RAISE EXCEPTION 'SHA512-CRYPT known-answer test failed';
    END IF;
END $$;
SELECT 'PASS CREATE EXTENSION shacrypt and both SHA-crypt known answers' AS result;
