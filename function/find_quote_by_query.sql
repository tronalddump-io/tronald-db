CREATE OR REPLACE FUNCTION find_quote_by_query(
    query   VARCHAR,
    options JSON DEFAULT '{ "limit": null, "offset": 0 }'
) RETURNS json AS $$

    WITH total AS (
        SELECT count(*) FROM quote WHERE lower(value) LIKE '%' || lower(find_quote_by_query.query) || '%'
    )
    SELECT
        json_build_object(
            'total',  (SELECT * FROM total),
            'result', json_agg(
                get_quote(result.quote_id)
            )
        )
    FROM (
        SELECT
            quote_id
        FROM
            quote
        WHERE
            lower(value) LIKE '%' || lower(find_quote_by_query.query) || '%'
        LIMIT
            CASE
                WHEN (find_quote_by_query.options->>'limit')::text IS NULL
                THEN null
                ELSE (find_quote_by_query.options->>'limit')::integer
        END
        OFFSET
            CASE
                WHEN (find_quote_by_query.options->>'offset')::text IS NULL
                THEN 0
                ELSE (find_quote_by_query.options->>'offset')::integer
        END
    ) AS result;

$$ LANGUAGE sql;

COMMENT ON FUNCTION find_quote_by_query(VARCHAR, JSON) IS 'Find quotes by a given query.';
