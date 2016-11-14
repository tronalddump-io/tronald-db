CREATE OR REPLACE FUNCTION find_tag() RETURNS json AS $$

    (SELECT array_to_json(array_agg(row_to_json(t))) FROM (
        SELECT
            tags->>0 AS "name",
            count(quote_id) AS "count"
        FROM
            quote
        WHERE
            tags IS NOT NULL
        GROUP BY
            tags->>0
        ORDER BY
            count(quote_id) DESC
    ) t);

$$ LANGUAGE sql;

COMMENT ON FUNCTION find_tag() IS 'Find tags with quote count.';
