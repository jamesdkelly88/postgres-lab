--
-- Name: lego_colors; Type: TABLE; Schema: -; Owner: -
--

CREATE TABLE IF NOT EXISTS lego_colors (
    id SERIAL,
    name varchar(255) NOT NULL,
    rgb varchar(6) NOT NULL,
    is_trans character(1) NOT NULL,
    CONSTRAINT lego_colors_pkey PRIMARY KEY (id)
);
