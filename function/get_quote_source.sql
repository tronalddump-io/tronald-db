CREATE OR REPLACE FUNCTION get_quote_source(
    quote_source_id SLUGID
) RETURNS json AS $$

    SELECT
        JSON_BUILD_OBJECT (
            'created_at',      created_at,
            'filename',        filename,
            'quote_source_id', quote_source_id,
            'remarks',         remarks,
            'updated_at',      updated_at,
            'url',             url
        ) as quote_source

    FROM
        quote_source
    WHERE
        quote_source_id = get_quote_source.quote_source_id;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_quote_source(SLUGID) IS 'Get a quote source by a given quote source id.';
