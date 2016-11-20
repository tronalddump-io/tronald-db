CREATE OR REPLACE FUNCTION get_quote_random() RETURNS json AS $$

    SELECT
        get_quote(quote.quote_id)
    FROM
        quote
    ORDER BY
        RANDOM()
    LIMIT
        1;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_quote_random() IS 'Get a random quote.';
