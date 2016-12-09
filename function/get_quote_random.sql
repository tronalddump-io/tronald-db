CREATE OR REPLACE FUNCTION get_quote_random(
    tag VARCHAR DEFAULT NULL
) RETURNS json AS $$

    SELECT
        get_quote(quote.quote_id)
    FROM
        quote
    WHERE
        CASE
            WHEN get_quote_random.tag IS NOT NULL
            THEN tags IS NOT NULL AND tags ?| array[ get_quote_random.tag ]
            ELSE true
        END
    ORDER BY
        RANDOM()
    LIMIT
        1;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_quote_random(VARCHAR) IS 'Get a random quote.';
