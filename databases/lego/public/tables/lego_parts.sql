--
-- Name: lego_parts; Type: TABLE; Schema: -; Owner: -
--

CREATE TABLE IF NOT EXISTS lego_parts (
    part_num varchar(255),
    name text NOT NULL,
    part_cat_id integer NOT NULL,
    CONSTRAINT lego_parts_pkey PRIMARY KEY (part_num)
);
