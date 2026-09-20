-- ZeroCraft: emblems for the two faction guilds that already exist (new ones get them in code)
USE acore_characters;
UPDATE guild SET EmblemStyle = 43, EmblemColor = 15, BorderStyle = 0, BorderColor = 15, BackgroundColor = 5  WHERE name = 'the Horde';
UPDATE guild SET EmblemStyle = 13, EmblemColor = 16, BorderStyle = 0, BorderColor = 16, BackgroundColor = 32 WHERE name = 'the Alliance';
SELECT name, EmblemStyle, EmblemColor, BorderStyle, BorderColor, BackgroundColor FROM guild;
