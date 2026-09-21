@echo off
cd /d C:\azerothcore
docker exec -i ac-database mysql -uroot -ppassword acore_auth -e "SELECT a.id, a.username, aa.gmlevel FROM account a LEFT JOIN account_access aa ON aa.id = a.id;" > gm.log 2>&1
docker exec -i ac-database mysql -uroot -ppassword acore_auth -e "INSERT INTO account_access (id, gmlevel, RealmID) SELECT id, 3, -1 FROM account ON DUPLICATE KEY UPDATE gmlevel = 3;" >> gm.log 2>&1
docker exec -i ac-database mysql -uroot -ppassword acore_auth -e "SELECT a.id, a.username, aa.gmlevel FROM account a LEFT JOIN account_access aa ON aa.id = a.id;" >> gm.log 2>&1
echo DONE >> gm.log
