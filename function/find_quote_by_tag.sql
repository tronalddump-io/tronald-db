CREATE OR REPLACE FUNCTION find_quote_by_tag(
    tag     VARCHAR,
    options JSON DEFAULT '{ "limit": null, "offset": 0 }'
) RETURNS json AS $$

    WITH total AS (
        SELECT count(*) FROM quote WHERE tags ? find_quote_by_tag.tag
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
            tags ? find_quote_by_tag.tag
        LIMIT
            CASE
                WHEN (find_quote_by_tag.options->>'limit')::text IS NULL
                THEN null
                ELSE (find_quote_by_tag.options->>'limit')::integer
        END
        OFFSET
            CASE
                WHEN (find_quote_by_tag.options->>'offset')::text IS NULL
                THEN 0
                ELSE (find_quote_by_tag.options->>'offset')::integer
        END
    ) AS result;

$$ LANGUAGE sql;

COMMENT ON FUNCTION find_quote_by_tag(VARCHAR, JSON) IS 'Find quotes by a given tag.';
