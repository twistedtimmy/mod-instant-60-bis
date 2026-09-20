-- ZeroCraft: Builder's Scrolls lose their one "special" (blue, cog) item - decorations only.
USE acore_world;
DELETE FROM zerocraft_bscroll_items WHERE useful = 1;
UPDATE zerocraft_bscroll b SET description = CONCAT('Builds ', (SELECT COUNT(*) FROM zerocraft_bscroll_items i WHERE i.item_entry = b.item_entry), ' decorations right in front of you.');
UPDATE item_template t JOIN zerocraft_bscroll b ON b.item_entry = t.entry SET t.description = b.description;
SELECT COUNT(*) AS special_items_left FROM zerocraft_bscroll_items WHERE useful = 1;
SELECT name, description FROM zerocraft_bscroll LIMIT 3;
