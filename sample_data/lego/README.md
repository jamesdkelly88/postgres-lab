# Lego

Provided by [Neon](https://github.com/neondatabase/postgres-sample-dbs/tree/main#lego-database)

## Sample queries

Which theme has the most sets?

```sql
SELECT lt.name AS theme_name, COUNT(ls.set_num) AS number_of_sets
FROM lego_themes lt
JOIN lego_sets ls ON lt.id = ls.theme_id
GROUP BY lt.name
ORDER BY number_of_sets DESC
LIMIT 5;
```

Which parts are in set 6616-1 (Rocket Dragster, 2000)?

```sql
SELECT 
    ip.quantity, 
    c.name AS color, 
    p.name AS part_name, 
    ip.part_num, 
    ip.is_spare
FROM lego_inventory_parts ip
JOIN lego_inventories i ON ip.inventory_id = i.id
JOIN lego_parts p ON ip.part_num = p.part_num
JOIN lego_colors c ON ip.color_id = c.id
WHERE i.set_num = '6616-1';
```

Which set has the most parts?

```sql
SELECT *
FROM lego_sets
ORDER BY num_parts DESC
LIMIT 1;
```