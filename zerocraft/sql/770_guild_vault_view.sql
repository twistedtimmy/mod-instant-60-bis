-- ZeroCraft: every guild member can see the guild vault and put things in (existing guilds; new tabs/guilds get it by default)
UPDATE acore_characters.guild_bank_right SET gbright = gbright | 3 WHERE rid <> 0;
SELECT COUNT(*) AS rank_tabs_opened FROM acore_characters.guild_bank_right WHERE rid <> 0 AND (gbright & 1) = 1;
