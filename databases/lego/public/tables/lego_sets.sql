--
-- Name: lego_sets; Type: TABLE; Schema: -; Owner: -
--

CREATE TABLE IF NOT EXISTS lego_sets (
    set_num varchar(255),
    name varchar(255) NOT NULL,
    year integer,
    theme_id integer,
    num_parts integer,
    CONSTRAINT lego_sets_pkey PRIMARY KEY (set_num)
);
