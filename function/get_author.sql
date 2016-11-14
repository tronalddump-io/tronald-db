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
