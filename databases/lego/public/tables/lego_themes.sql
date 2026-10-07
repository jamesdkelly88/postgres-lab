--
-- Name: lego_themes; Type: TABLE; Schema: -; Owner: -
--

CREATE TABLE IF NOT EXISTS lego_themes (
    id SERIAL,
    name varchar(255) NOT NULL,
    parent_id integer,
    CONSTRAINT lego_themes_pkey PRIMARY KEY (id)
);
