--
-- Name: lego_part_categories; Type: TABLE; Schema: -; Owner: -
--

CREATE TABLE IF NOT EXISTS lego_part_categories (
    id SERIAL,
    name varchar(255) NOT NULL,
    CONSTRAINT lego_part_categories_pkey PRIMARY KEY (id)
);
