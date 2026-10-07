--
-- Name: lego_inventory_parts; Type: TABLE; Schema: -; Owner: -
--

CREATE TABLE IF NOT EXISTS lego_inventory_parts (
    inventory_id integer NOT NULL,
    part_num varchar(255) NOT NULL,
    color_id integer NOT NULL,
    quantity integer NOT NULL,
    is_spare boolean NOT NULL
);
