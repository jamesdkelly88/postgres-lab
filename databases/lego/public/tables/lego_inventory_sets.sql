--
-- Name: lego_inventory_sets; Type: TABLE; Schema: -; Owner: -
--

CREATE TABLE IF NOT EXISTS lego_inventory_sets (
    inventory_id integer NOT NULL,
    set_num varchar(255) NOT NULL,
    quantity integer NOT NULL
);
