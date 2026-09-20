-- ZeroCraft: vanilla talent point total (51). Every character's talents are reset (free) at next login.
USE acore_characters;
UPDATE characters SET at_login = at_login | 4;
SELECT COUNT(*) AS characters_to_reset FROM characters;
