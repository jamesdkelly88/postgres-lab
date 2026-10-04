--
-- Name: books; Type: TABLE; Schema: -; Owner: -
--

CREATE TABLE IF NOT EXISTS books (
  id SERIAL,
  title VARCHAR(255),
  attr HSTORE,
  CONSTRAINT books_pkey PRIMARY KEY (id)
);
