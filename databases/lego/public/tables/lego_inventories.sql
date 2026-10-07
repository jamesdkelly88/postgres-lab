--
-- Name: lego_inventories; Type: TABLE; Schema: -; Owner: -
--

CREATE TABLE IF NOT EXISTS lego_inventories (
    id SERIAL,
    version integer NOT NULL,
    set_num varchar(255) NOT NULL,
    CONSTRAINT lego_inventories_pkey PRIMARY KEY (id)
);
