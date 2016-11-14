CREATE OR REPLACE FUNCTION get_quote(
    quote_id SLUGID
) RETURNS json AS $$

    SELECT
        JSON_BUILD_OBJECT (
            'appeared_at', q.appeared_at,
            'author',      row_to_json(a),
            'created_at',  q.created_at,
            'quote_id',    q.quote_id,
            'tags',        q.tags,
            'source',      row_to_json(qs),
            'updated_at',  q.updated_at,
            'value',       q.value
        ) as quote

    FROM
        quote AS q
    INNER JOIN author       AS a  USING (author_id)
    INNER JOIN quote_source AS qs USING (quote_source_id)
    WHERE
        quote_id = get_quote.quote_id;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_quote(SLUGID) IS 'Get a quote by a given quote id.';
