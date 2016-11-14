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
