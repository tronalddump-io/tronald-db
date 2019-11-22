BEGIN TRANSACTION;

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

CREATE OR REPLACE FUNCTION get_author(
    author_id SLUGID
) RETURNS json AS $$

    SELECT
        JSON_BUILD_OBJECT (
            'author_id',  author_id,
            'bio',        bio,
            'created_at', created_at,
            'name',       name,
            'slug',       slug,
            'updated_at', updated_at
        ) as author
    FROM
        author
    WHERE
        author_id = get_author.author_id;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_author(SLUGID) IS 'Get an author by a given author id.';

CREATE OR REPLACE FUNCTION find_author_by_slug(
    slug VARCHAR
) RETURNS json AS $$

    SELECT
        get_author(author_id)
    FROM
        author
    WHERE
        slug = find_author_by_slug.slug;

$$ LANGUAGE sql;

COMMENT ON FUNCTION find_author_by_slug(VARCHAR) IS 'Find an author by a given slug.';

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

COMMIT TRANSACTION;
