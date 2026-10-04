--
-- Name: orders; Type: TABLE; Schema: -; Owner: -
--

CREATE TABLE IF NOT EXISTS orders (
  id SERIAL,
  info XML NOT NULL,
  CONSTRAINT orders_pkey PRIMARY KEY (id)
);
