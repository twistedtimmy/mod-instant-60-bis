#include "ScriptMgr.h"
#include "PassiveAI.h"
#include "CreatureScript.h"
#include "GameTime.h"
#include "Mail.h"
#include "LootMgr.h"
#include "GuildPackets.h"
#include "ScriptedGossip.h"
#include "Pet.h"
#include "GuildMgr.h"
#include "MapMgr.h"
#include "LFGMgr.h"
#include "DBCStores.h"
#include "CombatAI.h"
#include <unordered_set>
#include <map>
#include <set>
#include "GameObject.h"
#include "Log.h"
#include "ByteBuffer.h"
#include "UpdateFields.h"
#include "CommandScript.h"
#include "ChatCommand.h"
#include "RBAC.h"
#include "MotionMaster.h"
#include "Timer.h"
#include "UnitScript.h"
#include "ServerScript.h"
#include "WorldPacket.h"
#include "Opcodes.h"
#include "PlayerScript.h"
#include "GuildScript.h"
#include "WorldScript.h"
#include "AllCreatureScript.h"
#include "AllGameObjectScript.h"
#include "WaypointMgr.h"
#include "ItemScript.h"
#include "Player.h"
#include "Item.h"
#include "Bag.h"
#include "SpellMgr.h"
#include "SpellInfo.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "SpellAuraDefines.h"
#include "SharedDefines.h"
#include "WorldSession.h"
#include "Common.h"
#include "DBCStores.h"
#include "ReputationMgr.h"
#include "Guild.h"
#include "Chat.h"
#include "Creature.h"
#include "DatabaseEnv.h"
#include "Map.h"
#include "ObjectAccessor.h"
#include "ObjectMgr.h"
#include <unordered_map>
#include <vector>
#include <cstdio>
#include <cctype>
#include <cmath>
#include <algorithm>
#include <utility>

// Every character spawns with its BiS kit already sitting in playercreateinfo_item,
// but Blizzard's client hardcodes level-1 starter items (robe/pants/boots/weapon)
// into the equip slots before those rows are ever applied, so the BiS items land
// unequipped in the backpack instead. This hook runs the server's own auto-equip
// logic (the same one used when a player double-clicks an item) over every item
// still sitting in the backpack right after creation, so anything epic+ takes over
// its equip slot immediately - no client addon, no login required.
//
// It also fills every action bar the client always shows regardless of stance or
// form - the main bar (slots 0-10, slot 11 is reserved for the single mount button
// already set via playercreateinfo_action) plus the four fixed multi-bars, with
// every spell the character actually knows, skipping passives and skipping mount
// spells (there can be 200+ of those; one is plenty for a button). Slots 12-23 are
// the stance/shapeshift bonus page that only renders while in that specific
// stance, so it's deliberately left alone. The four multi-bar ranges below were
// confirmed against the live client (reading each bar's real action slot via
// button:GetAttribute("action")), not guessed: RightActionBar=24-35,
// LeftActionBar=36-47, BottomRightActionBar=48-59, BottomLeftActionBar=60-71.
// ZeroCraft: every character knows every profession at Grand Master (450)
// with every recipe. Uses the same logic as the ".learn all recipes" GM
// command. Runs on login only when something is below 450, so it catches
// existing characters once and then stays out of the way.
static void MaxAllProfessions(Player* player)
{
    static const uint32 professionSkills[] = {
        171, 164, 333, 202, 182, 773, 755, 165, 186, 393, 197,   // primary professions
        185, 129, 356                                            // cooking, first aid, fishing
    };

    bool needsWork = false;
    for (uint32 skill : professionSkills)
        if (player->GetSkillValue(skill) < 450)
            needsWork = true;
    if (!needsWork)
        return;

    uint32 classmask = player->getClassMask();
    for (uint32 skill : professionSkills)
    {
        for (uint32 rankSpell : sSpellMgr->GetSkillRankSpells(skill))
            player->learnSpell(rankSpell);

        for (SkillLineAbilityEntry const* skillLine : GetSkillLineAbilitiesBySkillLine(skill))
        {
            if (skillLine->SupercededBySpell || skillLine->RaceMask != 0)
                continue;
            if (skillLine->ClassMask && (skillLine->ClassMask & classmask) == 0)
                continue;
            SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(skillLine->Spell);
            if (!spellInfo || !SpellMgr::IsSpellValid(spellInfo))
                continue;
            player->learnSpell(skillLine->Spell);
        }

        uint16 maxLevel = player->GetPureMaxSkillValue(skill);
        if (maxLevel)
            player->SetSkill(skill, player->GetSkillStep(skill), maxLevel, maxLevel);
    }
}

// ============================================================================
// ZeroCraft "you already won vanilla": exalted everywhere, titles, class
// mounts, every companion pet, no flying mounts. All of it is safe to run on
// every login (it only fills in what's missing), so older characters catch up.
// ============================================================================
// ============================================================================
// ZeroCraft Rebels: a third side. One new character in three (any race) is a
// Rebel: starts on Theramore Isle, hearthstone set to Theramore, guild <the Rebels>, and
// summons only neutral troops and villains. Remembered per character in
// acore_characters.zerocraft_rebels.
// ============================================================================
namespace ZeroCraftRebels
{
    // Two extra sides, remembered per character:
    //   Rebels  - acore_characters.zerocraft_rebels  - Theramore Isle, <the Rebels>
    //   Pirates - acore_characters.zerocraft_pirates - Menethil Harbor, <the Pirates>
    static std::unordered_set<uint32>& Load(char const* table, std::unordered_set<uint32>& s, bool& loaded)
    {
        if (!loaded)
        {
            loaded = true;
            if (QueryResult r = CharacterDatabase.Query(Acore::StringFormat("SELECT guid FROM {}", table)))
                do { s.insert((*r)[0].Get<uint32>()); } while (r->NextRow());
        }
        return s;
    }
    static std::unordered_set<uint32>& RebelSet()  { static std::unordered_set<uint32> s; static bool l = false; return Load("zerocraft_rebels", s, l); }
    static std::unordered_set<uint32>& PirateSet() { static std::unordered_set<uint32> s; static bool l = false; return Load("zerocraft_pirates", s, l); }

    static bool Is(Player const* p)       { return p && RebelSet().count(p->GetGUID().GetCounter()); }
    static bool IsPirate(Player const* p) { return p && PirateSet().count(p->GetGUID().GetCounter()); }
    static bool IsOutlaw(Player const* p) { return Is(p) || IsPirate(p); } // Rebels or Pirates

    static void Make(Player* p)
    {
        RebelSet().insert(p->GetGUID().GetCounter());
        CharacterDatabase.DirectExecute(Acore::StringFormat("REPLACE INTO zerocraft_rebels (guid) VALUES ({})", p->GetGUID().GetCounter()));
    }
    static void MakePirate(Player* p)
    {
        PirateSet().insert(p->GetGUID().GetCounter());
        CharacterDatabase.DirectExecute(Acore::StringFormat("REPLACE INTO zerocraft_pirates (guid) VALUES ({})", p->GetGUID().GetCounter()));
    }

    // Only two sides now: the Rebels (Theramore) and the Pirates (Menethil). New and
    // converted characters join whichever side is smaller, so they stay even.
    static void Assign(Player* p)
    {
        if (IsOutlaw(p))
            return;
        size_t r = RebelSet().size(), pi = PirateSet().size();
        if (r < pi || (r == pi && urand(0, 1)))
            Make(p);
        else
            MakePirate(p);
    }

    static WorldLocation Home() { return WorldLocation(1, -3711.95f, -4404.3f, 21.3729f, 4.03694f); } // Theramore Isle, in town (not the docks, where the ship moors)
    static const uint32 HOME_ZONE = 15; // Dustwallow Marsh
    static WorldLocation PirateHome() { return WorldLocation(0, -3769.32f, -744.26f, 8.01027f, 1.95752f); } // Menethil Harbor
    static const uint32 PIRATE_ZONE = 11; // Wetlands
}

namespace ZeroCraftVeteran
{
    static void Exalted(Player* player)
    {
        static const uint32 neutral[]  = { 529, 576, 609, 59, 749, 270, 910, 21, 577, 369, 470, 349, 809, 909 };
        static const uint32 alliance[] = { 72, 47, 69, 54, 930, 890, 730, 509, 589 };
        static const uint32 horde[]    = { 76, 81, 68, 530, 911, 889, 729, 510 };
        auto give = [player](uint32 id)
        {
            FactionEntry const* f = sFactionStore.LookupEntry(id);
            if (f && f->reputationListID >= 0 && player->GetReputationMgr().GetReputation(f) < 42000)
                player->GetReputationMgr().SetReputation(f, 42999.0f);
        };
        for (uint32 id : neutral) give(id);
        if (player->GetTeamId(true) == TEAM_HORDE) { for (uint32 id : horde) give(id); }
        else { for (uint32 id : alliance) give(id); }
    }

    static void Titles(Player* player)
    {
        bool horde = player->GetTeamId(true) == TEAM_HORDE;
        std::vector<std::string> want = { "Scarab Lord" };
        if (horde) { want.push_back("High Warlord"); want.push_back("Conqueror"); }
        else       { want.push_back("Grand Marshal"); want.push_back("Justicar"); }
        want.push_back("Ambassador");
        CharTitlesEntry const* rankTitle = nullptr;
        for (uint32 i = 0; i < sCharTitlesStore.GetNumRows(); ++i)
        {
            CharTitlesEntry const* t = sCharTitlesStore.LookupEntry(i);
            if (!t || !t->nameMale[0])
                continue;
            std::string name = t->nameMale[0];
            for (std::string const& w : want)
                if (name.find(w) != std::string::npos)
                {
                    if (!player->HasTitle(t))
                        player->SetTitle(t);
                    if (w == "High Warlord" || w == "Grand Marshal")
                        rankTitle = t;
                }
        }
        // wear the PvP rank title until the player picks another one
        if (rankTitle && player->GetUInt32Value(PLAYER_CHOSEN_TITLE) == 0)
            player->SetUInt32Value(PLAYER_CHOSEN_TITLE, rankTitle->bit_index);
    }

    // epic class mounts from the old class quests: { normal, epic }
    static std::pair<uint32, uint32> ClassMounts(Player* player)
    {
        if (player->getClass() == CLASS_WARLOCK)
            return { 5784, 23161 };                        // Felsteed, Dreadsteed
        if (player->getClass() == CLASS_PALADIN)
            return player->getRace() == RACE_BLOODELF
                ? std::make_pair(34769u, 34767u)           // Thalassian Warhorse / Charger
                : std::make_pair(13819u, 23214u);          // Warhorse, Charger
        return { 0, 0 };
    }

    static const uint32 MAGIC_ROOSTER = 65917;

    // Everyone rides the Magic Rooster - and nothing else. It sits in button 69
    // (bottom-left bar), the other old mount buttons are cleared.
    static void Mounts(Player* player)
    {
        // ZeroCraft: ground mounts are now dungeon drops, so every character is wiped
        // down to the Magic Rooster exactly once - mounts earned afterwards are kept.
        uint32 lowGuid = player->GetGUID().GetCounter();
        bool alreadyReset = bool(CharacterDatabase.Query(Acore::StringFormat("SELECT 1 FROM zerocraft_mounts_reset WHERE guid = {}", lowGuid)));
        if (alreadyReset)
            return;
        CharacterDatabase.DirectExecute(Acore::StringFormat("INSERT IGNORE INTO zerocraft_mounts_reset (guid) VALUES ({})", lowGuid));
        std::vector<uint32> drop;
        for (auto const& itr : player->GetSpellMap())
            if (itr.second->State != PLAYERSPELL_REMOVED)
                if (SpellInfo const* info = sSpellMgr->GetSpellInfo(itr.first))
                    if (info->HasAura(SPELL_AURA_MOUNTED))
                        drop.push_back(itr.first);
        for (uint32 id : drop)
            player->removeSpell(id, SPEC_MASK_ALL, false);   // the Magic Rooster too
        // plus one ordinary (60%) mount of their own race; every other mount comes from boss drops
        uint32 raceMount = 0;
        switch (player->getRace())
        {
            case RACE_HUMAN:         raceMount = 458;   break;   // Brown Horse
            case RACE_ORC:           raceMount = 580;   break;   // Timber Wolf
            case RACE_DWARF:         raceMount = 6777;  break;   // Gray Ram
            case RACE_NIGHTELF:      raceMount = 10793; break;   // Striped Nightsaber
            case RACE_UNDEAD_PLAYER: raceMount = 17462; break;   // Red Skeletal Horse
            case RACE_TAUREN:        raceMount = 18990; break;   // Brown Kodo
            case RACE_GNOME:         raceMount = 10873; break;   // Red Mechanostrider
            case RACE_TROLL:         raceMount = 8395;  break;   // Emerald Raptor
            case RACE_BLOODELF:      raceMount = 34795; break;   // Red Hawkstrider
            case RACE_DRAENEI:       raceMount = 34406; break;   // Brown Elekk
            default: break;
        }
        if (raceMount && sSpellMgr->GetSpellInfo(raceMount) && !player->HasSpell(raceMount))
            player->learnSpell(raceMount, false);

        for (uint8 slot : { 67, 68, 69, 70, 71 })
            if (ActionButton const* b = player->GetActionButton(slot))
                if (b->GetType() == ACTION_BUTTON_SPELL)
                    player->removeActionButton(slot);
        if (raceMount && player->HasSpell(raceMount))
            player->addActionButton(69, raceMount, ACTION_BUTTON_SPELL);   // where the Rooster used to be
    }

    static void CompanionPets(Player* player)
    {
        static std::vector<uint32> pets;
        static bool loaded = false;
        if (!loaded)
        {
            loaded = true;
            for (auto const& kv : *sObjectMgr->GetItemTemplateStore())
            {
                ItemTemplate const& it = kv.second;
                if (it.Class == ITEM_CLASS_MISC && it.SubClass == ITEM_SUBCLASS_JUNK_PET &&
                    it.Spells[0].SpellId == 55884 && it.Spells[1].SpellId > 0 &&
                    sSpellMgr->GetSpellInfo(it.Spells[1].SpellId))
                    pets.push_back(uint32(it.Spells[1].SpellId));
            }
        }
        // ZeroCraft: no companion pets at all - unlearn any the character has
        for (uint32 id : pets)
            if (player->HasSpell(id))
                player->removeSpell(id, SPEC_MASK_ALL, false);
    }

    static void All(Player* player)
    {
        Exalted(player);
        Titles(player);
        Mounts(player);
        // brand-new characters only: companion pets are now earned from raid bosses and must stay learned
        if (player->GetTotalPlayedTime() < 600)
            CompanionPets(player);
    }
}

// ZeroCraft guild tabards: guilds get an emblem the moment they're founded,
// and every guild member wears a Guild Tabard.
namespace ZeroCraftTabard
{
    static const uint32 GUILD_TABARD = 5976;

    static void SetEmblem(Guild* guild, Player* leader, int32 style, int32 color, int32 borderStyle, int32 borderColor, int32 background)
    {
        if (!guild || !leader || !leader->GetSession())
            return;
        WorldPacket raw(MSG_SAVE_GUILD_EMBLEM);
        WorldPackets::Guild::SaveGuildEmblem pkt(std::move(raw));
        pkt.EStyle = style; pkt.EColor = color; pkt.BStyle = borderStyle; pkt.BColor = borderColor; pkt.Bg = background;
        EmblemInfo info;
        info.ReadPacket(pkt);
        leader->ModifyMoney(10 * GOLD);  // the emblem is on the house (setting it costs 10g)
        guild->HandleSetEmblem(leader->GetSession(), info);
    }

    static void RandomEmblem(Guild* guild, Player* leader)
    {
        SetEmblem(guild, leader, urand(0, 169), urand(0, 16), urand(0, 5), urand(0, 16), urand(0, 50));
    }

    static const uint32 HORDE_TABARD    = 15197; // Scout's Tabard - the classic Horde tabard
    static const uint32 ALLIANCE_TABARD = 15196; // Private's Tabard - the classic Alliance tabard

    // <the Horde> and <the Alliance> wear the official faction tabards;
    // every other guild wears a Guild Tabard with its own emblem.
    static uint32 TabardFor(Player* player)
    {
        Guild* g = sGuildMgr->GetGuildById(player->GetGuildId());
        if (g && g->GetName() == "the Horde")    return HORDE_TABARD;
        if (g && g->GetName() == "the Alliance") return ALLIANCE_TABARD;
        return GUILD_TABARD;
    }

    // The tabard is always worn: equipped on spawn, and put back on at every
    // login if it ended up in the bags (or the player changed guilds).
    static void Wear(Player* player)
    {
        if (!player->GetGuildId())
            return;
        uint32 want = TabardFor(player);
        uint16 const slotPos = (INVENTORY_SLOT_BAG_0 << 8) | EQUIPMENT_SLOT_TABARD;
        Item* worn = player->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_TABARD);
        if (!(worn && worn->GetEntry() == want))
        {
            if (Item* bagged = player->GetItemByEntry(want))
                player->SwapItem(bagged->GetPos(), slotPos);
            else
            {
                if (worn)
                {
                    ItemPosCountVec dest;
                    if (player->CanStoreItem(NULL_BAG, NULL_SLOT, dest, worn, false) != EQUIP_ERR_OK)
                        return;
                    player->RemoveItem(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_TABARD, true);
                    player->StoreItem(dest, worn, true);
                }
                player->EquipNewItem(slotPos, want, true);
            }
        }
        // throw away the tabards of guilds you're no longer in
        for (uint32 other : { GUILD_TABARD, HORDE_TABARD, ALLIANCE_TABARD })
            if (other != want)
                player->DestroyItemCount(other, 255, true, false);
    }
}

// ============================================================================
// Best-in-slot enchants (Naxxramas-era) on head, shoulders, legs and weapons,
// by role: melee, hunter, caster or healer. Put on at every login wherever a
// slot has no permanent enchant yet, so new gear gets them too.
// ============================================================================
namespace ZeroCraftEnchants
{
    enum Role { MELEE, HUNTER, CASTER, HEALER };

    // does this weapon carry spell power / healing stats?
    static bool IsSpellWeapon(Item* item)
    {
        if (!item)
            return false;
        ItemTemplate const* proto = item->GetTemplate();
        for (uint32 i = 0; i < proto->StatsCount; ++i)
            switch (proto->ItemStat[i].ItemStatType)
            {
                case ITEM_MOD_SPELL_POWER:
                case ITEM_MOD_SPELL_HEALING_DONE:
                case ITEM_MOD_SPELL_DAMAGE_DONE:
                case ITEM_MOD_MANA_REGENERATION:
                case ITEM_MOD_INTELLECT:
                case ITEM_MOD_SPIRIT:
                    return true;
                default:
                    break;
            }
        return false;
    }

    static Role RoleOf(Player* p)
    {
        switch (p->getClass())
        {
            case CLASS_HUNTER:  return HUNTER;
            case CLASS_MAGE:
            case CLASS_WARLOCK: return CASTER;
            case CLASS_PRIEST:  return HEALER;
            case CLASS_PALADIN:
            case CLASS_DRUID:
            case CLASS_SHAMAN:
                // hybrids: a healing weapon means healer, a damage weapon means melee
                return IsSpellWeapon(p->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_MAINHAND)) ? HEALER : MELEE;
            default:            return MELEE;
        }
    }

    // Enchant an item on a character that isn't in the world yet (character creation).
    // Item::SetEnchantment would crash there: it messages the owner, who can't be found yet.
    static void SetOffline(Player* player, Item* item, uint32 enchantId)
    {
        item->SetUInt32Value(ITEM_FIELD_ENCHANTMENT_1_1 + PERM_ENCHANTMENT_SLOT * MAX_ENCHANTMENT_OFFSET + ENCHANTMENT_ID_OFFSET, enchantId);
        item->SetState(ITEM_CHANGED, player);
    }

    // puts items straight into the personal bank; whatever doesn't fit arrives by mail
    static void ToBank(Player* player, uint32 entry, uint32 count)
    {
        ItemTemplate const* proto = sObjectMgr->GetItemTemplate(entry);
        if (!proto || !count)
            return;
        std::vector<Item*> mail;
        while (count)
        {
            uint32 n = std::min<uint32>(count, std::max<uint32>(1, proto->GetMaxStackSize()));
            count -= n;
            Item* item = Item::CreateItem(entry, n, player);
            if (!item)
                break;
            ItemPosCountVec dest;
            if (player->CanBankItem(NULL_BAG, NULL_SLOT, dest, item, false) == EQUIP_ERR_OK)
                player->BankItem(dest, item, true);
            else
                mail.push_back(item);
        }
        if (mail.empty())
            return;
        CharacterDatabaseTransaction trans = CharacterDatabase.BeginTransaction();
        for (size_t i = 0; i < mail.size();)
        {
            MailDraft draft("Spare enchants", "Your bank was full, so the rest of your spare enchants came by post.");
            for (uint32 m = 0; m < MAX_MAIL_ITEMS && i < mail.size(); ++m, ++i)
            {
                mail[i]->SaveToDB(trans);
                draft.AddItem(mail[i]);
            }
            draft.SendMailTo(trans, MailReceiver(player), MailSender(MAIL_NORMAL, 0, MAIL_STATIONERY_GM));
        }
        CharacterDatabase.CommitTransaction(trans);
    }

    // spare enchant scrolls for off-hands and new weapons, given once on a character's first login
    static void GiveSpares(Player* player)
    {
        std::vector<std::pair<uint32, uint32>> kit;   // item, count
        switch (RoleOf(player))
        {
            case CASTER: kit = { { 38877, 6 } }; break;                               // Spellpower
            case HEALER: kit = { { 38878, 6 } }; break;                               // Healing Power
            case HUNTER: kit = { { 38873, 4 }, { 38896, 4 }, { 18283, 2 } }; break;   // Crusader, 2H Agility, Accurascope
            default:     kit = { { 38873, 6 } }; break;                               // Crusader
        }
        if (player->getClass() == CLASS_PALADIN || player->getClass() == CLASS_DRUID || player->getClass() == CLASS_SHAMAN)
            kit = { { 38873, 4 }, { 38878, 4 } };                                     // hybrids get both
        bool caster = RoleOf(player) == CASTER || RoleOf(player) == HEALER;
        kit.push_back({ caster ? 18330u : 18329u, 2 });                                // Arcanum of Focus / Rapidity
        kit.push_back({ RoleOf(player) == CASTER ? 23545u : RoleOf(player) == HEALER ? 23547u : 23548u, 1 }); // Scourge shoulder
        for (auto const& k : kit)
            ToBank(player, k.first, k.second);
    }


    static uint32 EnchantFor(Role role, uint8 slot, Item* item)
    {
        ItemTemplate const* proto = item->GetTemplate();
        switch (slot)
        {
            case EQUIPMENT_SLOT_HEAD:
            case EQUIPMENT_SLOT_LEGS:
                return (role == CASTER || role == HEALER) ? 2544 /*Arcanum of Focus*/ : 2543 /*Arcanum of Rapidity*/;
            case EQUIPMENT_SLOT_SHOULDERS:
                return role == CASTER ? 2721 /*Power of the Scourge*/
                     : role == HEALER ? 2715 /*Resilience of the Scourge*/
                     : 2717 /*Might of the Scourge*/;
            case EQUIPMENT_SLOT_MAINHAND:
            case EQUIPMENT_SLOT_OFFHAND:
                if (proto->Class != ITEM_CLASS_WEAPON)
                    return 0;                                    // shields, held-in-off-hand
                if (role == CASTER) return 2504;                  // Spellpower
                if (role == HEALER) return 2505;                  // Healing Power
                if (role == HUNTER && proto->InventoryType == INVTYPE_2HWEAPON) return 2646; // 2H Agility
                return 1900;                                      // Crusader
            case EQUIPMENT_SLOT_RANGED:
                if (proto->SubClass == ITEM_SUBCLASS_WEAPON_BOW || proto->SubClass == ITEM_SUBCLASS_WEAPON_GUN ||
                    proto->SubClass == ITEM_SUBCLASS_WEAPON_CROSSBOW)
                    return 2523;                                  // Biznicks 247x128 Accurascope
                return 0;
            default:
                return 0;
        }
    }

    static void Apply(Player* player)
    {
        Role role = RoleOf(player);
        for (uint8 slot : { EQUIPMENT_SLOT_HEAD, EQUIPMENT_SLOT_SHOULDERS, EQUIPMENT_SLOT_LEGS,
                            EQUIPMENT_SLOT_MAINHAND, EQUIPMENT_SLOT_OFFHAND, EQUIPMENT_SLOT_RANGED })
        {
            Item* item = player->GetItemByPos(INVENTORY_SLOT_BAG_0, slot);
            if (!item || item->GetEnchantmentId(PERM_ENCHANTMENT_SLOT))
                continue;
            uint32 ench = EnchantFor(role, slot, item);
            if (!ench || !sSpellItemEnchantmentStore.LookupEntry(ench))
                continue;
            player->ApplyEnchantment(item, PERM_ENCHANTMENT_SLOT, false);
            item->SetEnchantment(PERM_ENCHANTMENT_SLOT, ench, 0, 0);
            player->ApplyEnchantment(item, PERM_ENCHANTMENT_SLOT, true);
        }
    }
}

// ============================================================================
// Class spells that normally come from quests (stances, forms, demons, pet
// skills, shaman totem tools), every talent/trainer ability at its highest
// rank for your level, and action bars kept in sync - including the stance /
// form bars (warrior stances, druid forms, rogue stealth, shadowform), which
// use their own row of buttons.
// ============================================================================
namespace ZeroCraftBars
{
    // anything from a profession (primary or secondary): crafting windows,
    // Find Herbs/Minerals, Smelting, Disenchant, Prospecting, Fishing, Cooking...
    static bool IsProfessionSpell(uint32 spellId)
    {
        auto bounds = sSpellMgr->GetSkillLineAbilityMapBounds(spellId);
        for (auto itr = bounds.first; itr != bounds.second; ++itr)
            if (SkillLineEntry const* sl = sSkillLineStore.LookupEntry(itr->second->SkillLine))
                if (sl->categoryId == SKILL_CATEGORY_PROFESSION || sl->categoryId == SKILL_CATEGORY_SECONDARY)
                    return true;
        return false;
    }

    static bool IsBarSpell(Player* player, uint32 spellId)
    {
        if (IsProfessionSpell(spellId))
            return false;
        static const uint32 utility[] = { 750, 8737, 9078, 196, 197, 198, 199, 201, 202, 1180, 227, 15590,
                                          264, 5011, 266, 2567, 5009, 674, 33388, 33391, 34090, 34091, 54197, 7267,
                                          7355 /* Stuck */, 8690 /* Hearthstone */ };
        for (uint32 id : utility)
            if (id == spellId)
                return false;
        SpellInfo const* info = sSpellMgr->GetSpellInfo(spellId);
        if (!info || info->IsPassive() || info->HasAura(SPELL_AURA_MOUNTED))
            return false;
        if (info->HasEffect(SPELL_EFFECT_OPEN_LOCK) || info->HasEffect(SPELL_EFFECT_SKIN_PLAYER_CORPSE) ||
            info->HasEffect(SPELL_EFFECT_ATTACK) || info->HasEffect(SPELL_EFFECT_DUEL) ||
            info->HasEffect(SPELL_EFFECT_TALENT_SPEC_SELECT))
            return false;
        for (int32 reagent : info->Reagent)
            if (reagent > 0)
                return false;
        // companion pets are not wanted on bars (they live in the pet tab)
        if (info->HasEffect(SPELL_EFFECT_SUMMON) && info->Effects[0].MiscValueB == 3221)
            return false;
        (void)player;
        return true;
    }

    static void QuestSpells(Player* player)
    {
        std::vector<uint32> spells;
        std::vector<uint32> items;
        switch (player->getClass())
        {
            case CLASS_WARRIOR: spells = { 71, 2458, 355, 20252 }; break;              // Defensive/Berserker Stance, Taunt, Intercept
            case CLASS_DRUID:   spells = { 5487, 9634, 1066, 768, 783 }; break;         // Bear, Dire Bear, Aquatic, Cat, Travel Form
            case CLASS_WARLOCK: spells = { 688, 697, 712, 691, 1122, 18540 }; break;    // Imp, Voidwalker, Succubus, Felhunter, Inferno, Ritual of Doom
            case CLASS_HUNTER:  spells = { 1515, 883, 2641, 982, 6991, 1462 }; break;   // Tame/Call/Dismiss/Revive/Feed Pet, Beast Lore
            case CLASS_PALADIN: spells = { 7328 }; break;                               // Redemption
            case CLASS_SHAMAN:  items = { 5175, 5176, 5177, 5178 }; break;              // Earth/Fire/Water/Air totems
            default: break;
        }
        for (uint32 id : spells)
            if (sSpellMgr->GetSpellInfo(id) && !player->HasSpell(id))
                player->learnSpell(id, false);
        for (uint32 id : items)
            if (!player->HasItemCount(id, 1, true))
                player->AddItem(id, 1);
    }

    // every known spell at the highest rank the character's level allows
    static void UpgradeRanks(Player* player)
    {
        std::vector<uint32> learn;
        for (auto const& kv : player->GetSpellMap())
        {
            if (kv.second->State == PLAYERSPELL_REMOVED || !kv.second->Active)
                continue;
            uint32 id = kv.first;
            while (uint32 next = sSpellMgr->GetNextSpellInChain(id))
            {
                SpellInfo const* ni = sSpellMgr->GetSpellInfo(next);
                // talent ranks are bought with points, never handed out here
                if (!ni || GetTalentSpellPos(next) || ni->SpellLevel > player->GetLevel() || ni->SpellLevel == 0)
                    break;
                id = next;
            }
            if (id != kv.first && !player->HasSpell(id))
                learn.push_back(id);
        }
        for (uint32 id : learn)
            player->learnSpell(id, false);
    }

    static const uint8 kFill[] = { 0,1,2,3,4,5,6,7,8,9,10,11, 24,25,26,27,28,29,30,31,32,33,34,35,
                                   36,37,38,39,40,41,42,43,44,45,46,47, 48,49,50,51,52,53,54,55,56,57,58,59,
                                   60,61,62,63,64,65,66 };

    static void Sync(Player* player, bool send = true)
    {
        // 1) drop buttons for spells the character no longer knows
        for (uint8 slot = 0; slot < 120; ++slot)
            if (ActionButton const* b = player->GetActionButton(slot))
                if (b->GetType() == ACTION_BUTTON_SPELL && !player->HasSpell(b->GetAction()))
                    player->removeActionButton(slot);

        // 2) spells that aren't on any bar yet go into the first free slots
        std::set<uint32> onBar;
        for (uint8 slot = 0; slot < 120; ++slot)
            if (ActionButton const* b = player->GetActionButton(slot))
                if (b->GetType() == ACTION_BUTTON_SPELL)
                    onBar.insert(b->GetAction());
        std::vector<std::pair<uint32, uint32>> todo;
        for (auto const& kv : player->GetSpellMap())
        {
            if (kv.second->State == PLAYERSPELL_REMOVED || !kv.second->Active || onBar.count(kv.first))
                continue;
            if (!IsBarSpell(player, kv.first))
                continue;
            // skip a rank if a higher rank of the same spell is already placed
            uint32 first = sSpellMgr->GetFirstSpellInChain(kv.first);
            bool placed = false;
            for (uint32 o : onBar)
                if (sSpellMgr->GetFirstSpellInChain(o) == first) { placed = true; break; }
            if (placed)
                continue;
            SpellInfo const* info = sSpellMgr->GetSpellInfo(kv.first);
            todo.emplace_back(kv.first, info ? info->GetRecoveryTime() : 0);
        }
        std::sort(todo.begin(), todo.end(), [](auto const& a, auto const& b) { return a.second < b.second; });
        size_t t = 0;
        for (uint8 slot : kFill)
        {
            if (t >= todo.size())
                break;
            if (!player->GetActionButton(slot))
                player->addActionButton(slot, todo[t++].first, ACTION_BUTTON_SPELL);
        }

        // 3) stance / form bars mirror the main bar where they're empty
        std::vector<uint8> pages;
        switch (player->getClass())
        {
            case CLASS_WARRIOR: pages = { 72, 84, 96 }; break;        // battle, defensive, berserker
            case CLASS_DRUID:   pages = { 72, 96, 108 }; break;       // cat, bear, moonkin/tree
            case CLASS_ROGUE:   pages = { 72 }; break;                // stealth
            case CLASS_PRIEST:  pages = { 72 }; break;                // shadowform
            default: break;
        }
        for (uint8 base : pages)
            for (uint8 i = 0; i < 12; ++i)
                if (!player->GetActionButton(base + i))
                    if (ActionButton const* b = player->GetActionButton(i))
                        player->addActionButton(base + i, b->GetAction(), b->GetType());

        if (send)
            player->SendActionButtons(1);
    }

    // one time per character: take profession buttons off the bars
    static void CleanProfessions(Player* player)
    {
        uint32 guid = player->GetGUID().GetCounter();
        // new characters (first hour) always get a clean bar; older ones once
        if (player->GetTotalPlayedTime() >= 3600 &&
            CharacterDatabase.Query(Acore::StringFormat("SELECT 1 FROM zerocraft_bars_cleaned WHERE guid = {}", guid)))
            return;
        for (uint8 slot = 0; slot < 120; ++slot)
            if (ActionButton const* b = player->GetActionButton(slot))
                if (b->GetType() == ACTION_BUTTON_SPELL && (IsProfessionSpell(b->GetAction()) || b->GetAction() == 7355))
                    player->removeActionButton(slot);
        CharacterDatabase.DirectExecute(Acore::StringFormat("INSERT IGNORE INTO zerocraft_bars_cleaned (guid) VALUES ({})", guid));
    }

    static void All(Player* player, bool send = true)
    {
        if (send)
            CleanProfessions(player);
        QuestSpells(player);
        UpgradeRanks(player);
        Sync(player, send);
    }
}

class ModInstant60BisPlayerScript : public PlayerScript
{
public:
    ModInstant60BisPlayerScript() : PlayerScript("ModInstant60BisPlayerScript") { }

    // ZeroCraft: any weapon (or head / shoulder / leg piece) you put on gets its best-in-slot enchant
    // straight away, if it doesn't already have one - Warglaives, Frostmourne, Sulfuras, anything.
    // ZeroCraft: the single NPC scrolls (all but the Flight Master) are retired - NPC Books replaced them
    static void RemoveRetiredScrolls(Player* player)
    {
        for (uint32 id : { 823u, 842u, 951u, 1078u, 3513u, 25747u, 25748u, 1267u, 6213u, 17163u })
            if (uint32 n = player->GetItemCount(id, true))
                player->DestroyItemCount(id, n, true, false);
        CharacterDatabase.DirectExecute(Acore::StringFormat(
            "DELETE FROM zerocraft_packed WHERE player_guid = {} AND scroll_entry <> 3504", player->GetGUID().GetCounter()));
    }

    void OnPlayerEquip(Player* player, Item* /*it*/, uint8 bag, uint8 slot, bool /*update*/) override
    {
        if (!player->IsInWorld() || bag != INVENTORY_SLOT_BAG_0)
            return;
        switch (slot)
        {
            case EQUIPMENT_SLOT_HEAD: case EQUIPMENT_SLOT_SHOULDERS: case EQUIPMENT_SLOT_LEGS:
            case EQUIPMENT_SLOT_MAINHAND: case EQUIPMENT_SLOT_OFFHAND: case EQUIPMENT_SLOT_RANGED:
                ZeroCraftEnchants::Apply(player);
                break;
            default:
                break;
        }
    }

    void OnPlayerCreate(Player* player) override
    {
        // a new character may reuse a deleted one's number: start its one-time mount wipe fresh
        CharacterDatabase.DirectExecute(Acore::StringFormat("DELETE FROM zerocraft_mounts_reset WHERE guid = {}", player->GetGUID().GetCounter()));
        for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
        {
            Item* item = player->GetItemByPos(INVENTORY_SLOT_BAG_0, slot);
            if (!item)
                continue;

            ItemTemplate const* proto = item->GetTemplate();
            if (!proto || proto->Quality < ITEM_QUALITY_EPIC)
                continue;

            uint8 equipSlot = player->FindEquipSlot(proto, NULL_SLOT, true);
            if (equipSlot == NULL_SLOT)
                continue;

            // Don't fight over a slot that already holds an epic+ item from an
            // earlier iteration this pass (e.g. two competing weapon options) -
            // first one found wins, rather than flip-flopping between them.
            if (Item* current = player->GetItemByPos(INVENTORY_SLOT_BAG_0, equipSlot))
            {
                ItemTemplate const* currentProto = current->GetTemplate();
                if (currentProto && currentProto->Quality >= ITEM_QUALITY_EPIC)
                    continue;
            }

            uint16 dest = ((INVENTORY_SLOT_BAG_0 << 8) | equipSlot);
            if (dest == item->GetPos())
                continue;

            player->SwapItem(item->GetPos(), dest);
        }

        static const uint8 fillableSlots[] = {
            0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
            24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
            36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
            48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
            60, 61, 62, 63, 64, 65, 66
        };

        for (uint8 slot : fillableSlots)
            player->removeActionButton(slot);

        // These are the universal weapon/armor proficiency and riding-skill spells
        // granted to every class - they exist only to unlock permission to use gear
        // or ride mounts, Blizzard never gave them a real icon (they render as a
        // generic gear/cog placeholder), and they were never meant to sit on an
        // action bar. Excluded outright rather than merely deprioritized.
        static const uint32 utilitySpells[] = {
            750, 8737, 9078,                                            // armor
            196, 197, 198, 199, 201, 202, 1180, 227, 15590,             // melee weapons
            264, 5011, 266, 2567, 5009, 674,                            // ranged/dual wield
            33388, 33391, 34090, 34091, 54197                          // riding
        };
        auto isUtilitySpell = [](uint32 spellId)
        {
            for (uint32 id : utilitySpells)
                if (id == spellId)
                    return true;
            return false;
        };

        std::vector<std::pair<uint32, uint32>> spellsToPlace; // spellId, cooldownMs
        for (auto const& itr : player->GetSpellMap())
        {
            if (!itr.second->Active)
                continue;

            SpellInfo const* info = sSpellMgr->GetSpellInfo(itr.first);
            if (!info || info->IsPassive())
                continue;

            if (info->HasAura(SPELL_AURA_MOUNTED))
                continue;

            if (isUtilitySpell(itr.first))
                continue;

            // System/interaction spells every character has regardless of class
            // (Attack, Duel, Remove Insignia, lockpicking Opening/Closing) - these
            // were never given a real player-facing icon (the "yellow cog"
            // placeholder) because they're triggered contextually, not meant to be
            // cast from a bar. Identified by mechanical effect, not by ID, since
            // AlwaysMaxSkillForLevel can grant several ID variants of these
            // (different lockpicking skill thresholds, etc).
            if (info->HasEffect(SPELL_EFFECT_OPEN_LOCK) ||
                info->HasEffect(SPELL_EFFECT_SKIN_PLAYER_CORPSE) ||
                info->HasEffect(SPELL_EFFECT_ATTACK) ||
                info->HasEffect(SPELL_EFFECT_DUEL) ||
                info->HasEffect(SPELL_EFFECT_TALENT_SPEC_SELECT)) // Activate Primary/Secondary Spec
                continue;

            if (itr.first == 7267) // Grovel - real spell, but not useful on an auto-filled bar
                continue;

            if (ZeroCraftBars::IsProfessionSpell(itr.first) || itr.first == 7355) // professions and Stuck stay in the spellbook
                continue;

            // Skip anything that consumes a reagent - not something you want an
            // action bar auto-filled with, since running out silently breaks it.
            bool needsReagent = false;
            for (int32 reagent : info->Reagent)
            {
                if (reagent > 0)
                {
                    needsReagent = true;
                    break;
                }
            }
            if (needsReagent)
                continue;

            spellsToPlace.emplace_back(itr.first, info->GetRecoveryTime());
        }

        // Short/no-cooldown spells (the spam-every-fight rotation abilities) fill
        // the main bar first; long-cooldown and situational spells spill into the
        // overflow bars.
        std::sort(spellsToPlace.begin(), spellsToPlace.end(),
            [](std::pair<uint32, uint32> const& a, std::pair<uint32, uint32> const& b)
            {
                return a.second < b.second;
            });

        size_t maxSlots = sizeof(fillableSlots) / sizeof(fillableSlots[0]);
        for (size_t i = 0; i < spellsToPlace.size() && i < maxSlots; ++i)
            player->addActionButton(fillableSlots[i], spellsToPlace[i].first, ACTION_BUTTON_SPELL);

        // Belt-and-suspenders: make sure the mount button on the main bar survives
        // regardless of anything above.
        // Mount row: last 5 buttons of the bottom-left bar - 3 ground, 2 flying
        // ZeroCraft: the Magic Rooster is everyone's only mount (button 69)
        for (uint8 slot : { 67, 68, 70, 71 })
            player->removeActionButton(slot);
        player->removeActionButton(69);   // the race mount goes here on first login

        // ZeroCraft: four 30-slot Jaina's Dimensional Pockets (item 14156, re-made) and 5,000 gold.
        // Anything else in a bag slot (the hunter's quiver) goes - ammo is infinite - and its arrows are put back afterwards.
        std::vector<std::pair<uint32, uint32>> keep;
        for (uint8 bag = INVENTORY_SLOT_BAG_START; bag < INVENTORY_SLOT_BAG_END; ++bag)
            if (Item* old = player->GetItemByPos(INVENTORY_SLOT_BAG_0, bag))
                if (old->GetEntry() != 14156)
                {
                    if (Bag* b = old->ToBag())
                        for (uint32 i = 0; i < b->GetBagSize(); ++i)
                            if (Item* in = b->GetItemByPos(uint8(i)))
                                keep.push_back({ in->GetEntry(), in->GetCount() });
                    player->DestroyItem(INVENTORY_SLOT_BAG_0, bag, true);
                }
        for (uint8 bag = INVENTORY_SLOT_BAG_START; bag < INVENTORY_SLOT_BAG_END; ++bag)
            if (!player->GetItemByPos(INVENTORY_SLOT_BAG_0, bag))
                player->EquipNewItem((INVENTORY_SLOT_BAG_0 << 8) | bag, 14156, true);
        for (auto const& k : keep)
            player->AddItem(k.first, k.second);

        // ZeroCraft: a clean start. Grey starter gear goes; the bags keep only weapons, the Hearthstone
        // and the Flight Master scrolls (the rest of the starter kit is added at first login).
        auto keepInBag = [](Item* it)
        {
            ItemTemplate const* t = it->GetTemplate();
            if (t->Quality == ITEM_QUALITY_POOR)
                return false;
            return t->Class == ITEM_CLASS_WEAPON || t->ItemId == 6948 || t->ItemId == 3504;
        };
        for (uint8 slot = EQUIPMENT_SLOT_START; slot < EQUIPMENT_SLOT_END; ++slot)
            if (Item* it = player->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
                if (it->GetTemplate()->Quality == ITEM_QUALITY_POOR)
                    player->DestroyItem(INVENTORY_SLOT_BAG_0, slot, true);
        for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
            if (Item* it = player->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
                if (!keepInBag(it))
                    player->DestroyItem(INVENTORY_SLOT_BAG_0, slot, true);
        for (uint8 bag = INVENTORY_SLOT_BAG_START; bag < INVENTORY_SLOT_BAG_END; ++bag)
            if (Bag* b = player->GetBagByPos(bag))
                for (uint32 i = 0; i < b->GetBagSize(); ++i)
                    if (Item* it = b->GetItemByPos(uint8(i)))
                        if (!keepInBag(it))
                            player->DestroyItem(bag, uint8(i), true);

        // ZeroCraft: everyone keeps the Naxxramas best-in-slot weapons they start with, enchanted
        // with Crusader. The legendaries (Frostmourne, Sulfuras, Warglaives, Doomhammer...) now drop in raids.
        for (uint8 slot : { EQUIPMENT_SLOT_MAINHAND, EQUIPMENT_SLOT_OFFHAND })
            if (Item* w = player->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
                if (w->GetTemplate()->Class == ITEM_CLASS_WEAPON)
                    ZeroCraftEnchants::SetOffline(player, w, 1900 /*Crusader*/);
        player->ModifyMoney(5000 * GOLD);

        ZeroCraftBars::All(player, false);

        // Suppress every "new player" tutorial hint popup (bags, action bar, quest
        // log, etc.) by marking all 256 tutorial flag bits as already-seen. These
        // are stored per account, not per character, so this silences them for
        // every character on the account, not just this one.
        if (WorldSession* session = player->GetSession())
        {
            for (uint8 i = 0; i < MAX_ACCOUNT_TUTORIAL_VALUES; ++i)
                session->SetTutorialInt(i, 0xFFFFFFFF);
        }

        // OnPlayerCreate fires after the character has already been saved once and
        // the Player object is about to be destroyed with no further save - every
        // change made above only ever existed in memory and would otherwise be
        // silently lost. This is the save that actually makes it stick.
        // ZeroCraft: everyone is a Rebel (Theramore Keep) or a Pirate (Menethil Harbor)
        ZeroCraftRebels::Assign(player);
        // start right at home (no stop in Stormwind or Orgrimmar first)
        {
            bool rebel = ZeroCraftRebels::Is(player);
            WorldLocation home = rebel ? ZeroCraftRebels::Home() : ZeroCraftRebels::PirateHome();
            player->WorldRelocate(home);
            player->SetHomebind(home, rebel ? ZeroCraftRebels::HOME_ZONE : ZeroCraftRebels::PIRATE_ZONE);
        }

        player->SaveToDB(false, false);
    }

    // ZeroCraft first login: hearthstone set to your starting capital, you join
    // your faction's guild (<the Horde> / <the Alliance>; the first player in
    // becomes its leader), and hunters start with a tamed pet.
    // Nobody is ever guildless: at every login, a player without a guild goes
    // back into <the Horde> or <the Alliance> (the first one in leads it).
    static void JoinFactionGuild(Player* player)
    {
        if (player->GetGuildId())
            return;
        bool rebel = ZeroCraftRebels::Is(player);
        bool pirate = ZeroCraftRebels::IsPirate(player);
        std::string name = rebel ? "the Rebels" : pirate ? "the Pirates" : (player->GetTeamId(true) == TEAM_HORDE ? "the Horde" : "the Alliance");
        if (Guild* existing = sGuildMgr->GetGuildByName(name))
            existing->AddMember(player->GetGUID());
        else
        {
            Guild* created = new Guild;
            if (created->Create(player, name))
            {
                sGuildMgr->AddGuild(created);
                if (rebel)
                    ZeroCraftTabard::SetEmblem(created, player, 92, 14, 0, 14, 44);  // white skull and crossbones on black-brown
                else if (pirate)
                    ZeroCraftTabard::SetEmblem(created, player, 91, 14, 0, 14, 29);  // white skull on deep sea teal
                else if (player->GetTeamId(true) == TEAM_HORDE)
                    ZeroCraftTabard::SetEmblem(created, player, 43, 15, 0, 15, 5);   // black horned head on dark red
                else
                    ZeroCraftTabard::SetEmblem(created, player, 13, 16, 0, 16, 32);  // gold lion on dark blue
            }
            else
                delete created;
        }
    }

    // Hand an item to a character exactly once, ever - new AND existing characters.
    // Goes in the bags, or by mail if the bags are full.
    static void GrantOnce(Player* player, uint32 item)
    {
        static bool tableReady = false;
        if (!tableReady)
        {
            CharacterDatabase.DirectExecute("CREATE TABLE IF NOT EXISTS zerocraft_granted (guid INT UNSIGNED NOT NULL, item INT UNSIGNED NOT NULL, PRIMARY KEY (guid, item))");
            tableReady = true;
        }
        uint32 low = player->GetGUID().GetCounter();
        if (CharacterDatabase.Query(Acore::StringFormat("SELECT 1 FROM zerocraft_granted WHERE guid = {} AND item = {}", low, item)))
            return;
        CharacterDatabase.DirectExecute(Acore::StringFormat("INSERT IGNORE INTO zerocraft_granted (guid, item) VALUES ({}, {})", low, item));
        if (player->HasItemCount(item, 1, true))
            return;
        if (player->AddItem(item, 1))
            return;
        if (Item* it = Item::CreateItem(item, 1, player))
        {
            CharacterDatabaseTransaction trans = CharacterDatabase.BeginTransaction();
            it->SaveToDB(trans);
            MailDraft draft("A gift", "Your bags were full, so this came by post.");
            draft.AddItem(it);
            draft.SendMailTo(trans, MailReceiver(player), MailSender(MAIL_NORMAL, 0, MAIL_STATIONERY_GM));
            CharacterDatabase.CommitTransaction(trans);
        }
    }

    void OnPlayerFirstLogin(Player* player) override
    {
        if (ZeroCraftRebels::Is(player))
        {
            player->SetHomebind(ZeroCraftRebels::Home(), ZeroCraftRebels::HOME_ZONE);
            WorldLocation r = ZeroCraftRebels::Home();
            ObjectGuid guid = player->GetGUID();
            player->m_Events.AddEventAtOffset([player, guid, r]()
            {
                if (player->IsInWorld() && player->GetGUID() == guid)
                {
                    player->TeleportTo(r);
                    static std::unordered_set<ObjectGuid::LowType> told;
                    if (told.insert(player->GetGUID().GetCounter()).second)
                        ChatHandler(player->GetSession()).SendSysMessage("You are a Rebel. Theramore is your home. The Pirates are your sworn enemies.");
                }
            }, Milliseconds(1000));
        }
        else if (ZeroCraftRebels::IsPirate(player))
        {
            player->SetHomebind(ZeroCraftRebels::PirateHome(), ZeroCraftRebels::PIRATE_ZONE);
            WorldLocation r = ZeroCraftRebels::PirateHome();
            ObjectGuid guid = player->GetGUID();
            player->m_Events.AddEventAtOffset([player, guid, r]()
            {
                if (player->IsInWorld() && player->GetGUID() == guid)
                {
                    player->TeleportTo(r);
                    static std::unordered_set<ObjectGuid::LowType> told;
                    if (told.insert(player->GetGUID().GetCounter()).second)
                        ChatHandler(player->GetSession()).SendSysMessage("You are a Pirate. Menethil Harbor is your home. The Rebels are your sworn enemies.");
                }
            }, Milliseconds(1000));
        }
        else
        {
            bool horde = player->GetTeamId(true) == TEAM_HORDE;
            if (horde)
                player->SetHomebind(WorldLocation(1, 1629.36f, -4373.39f, 31.2564f, 3.54839f), 1637);   // Orgrimmar
            else
                player->SetHomebind(WorldLocation(0, -8833.38f, 628.628f, 94.0066f, 1.06535f), 1519);   // Stormwind
            std::string msg = horde
                ? "You are Horde. Orgrimmar is your home. The Alliance, The Rebels, and The Pirates are your Sworn enemies."
                : "You are Alliance. Stormwind is your home. The Horde, The Rebels, and The Pirates are your Sworn enemies.";
            ObjectGuid guid = player->GetGUID();
            player->m_Events.AddEventAtOffset([player, guid, msg]()
            {
                if (player->IsInWorld() && player->GetGUID() == guid)
                    ChatHandler(player->GetSession()).SendSysMessage(msg);
            }, Milliseconds(1500));
        }

        JoinFactionGuild(player);
        ZeroCraftEnchants::GiveSpares(player);
        // starter kit (kept small): 1 Builder's Scroll, 7 Guard scrolls, the Titan's Grip scrolls
        // and the legendary weapons (Flight Master scroll, banners, Recall Orders and Hearthstone come elsewhere)
        // five different random pieces from the cool furniture pool (the ones bosses mostly drop)
        if (QueryResult r = WorldDatabase.Query("SELECT Item FROM reference_loot_template WHERE Entry = 911110 ORDER BY RAND() LIMIT 5"))
            do { player->AddItem((*r)[0].Get<uint32>(), 1); } while (r->NextRow());
        player->AddItem(823, 7);   // 7 deployable Guards
        player->AddItem(60408, 5);   // 5 Training Dummies
        player->AddItem(36942, 1);   // two Frostmournes...
        player->AddItem(36942, 1);
        player->AddItem(60401, 1);   // ...and the Scroll of Titan's Grip: Swords to wield both
        player->AddItem(60410, 1);   // Tinker's Duplicatron-9000 (never used up)
        // the guild didn't exist yet during OnPlayerLogin on the very first login
        ObjectGuid tguid = player->GetGUID();
        player->m_Events.AddEventAtOffset([player, tguid]()
        {
            if (player->IsInWorld() && player->GetGUID() == tguid)
                ZeroCraftTabard::Wear(player);
        }, Milliseconds(500));

        if (player->getClass() == CLASS_HUNTER && !player->IsExistPet())
            player->CreatePet(7431u, 13481u); // Frostsaber, via Tame Beast
    }

    // Factions are gone: no Alliance/Horde hostility anywhere except (implicitly)
    // wherever the world itself still enforces it. Force every race's faction to
    // FRIENDLY via the same mechanism SPELL_AURA_FORCE_REACTION uses, looked up
    // live from the real ChrRaces data the server itself uses (sChrRacesStore),
    // not a hardcoded ID list. This is in-memory only (never persisted to DB), so
    // it has to be re-applied on every login, not just at creation.
    void OnPlayerLogin(Player* player) override
    {
        GrantOnce(player, 65000);   // NPC: Potion Master (for testing)
        GrantOnce(player, 65001);   // NPC: Gadgeteer (for testing)
        GrantOnce(player, 65002);   // NPC: Enchanter (for testing)
        GrantOnce(player, 65003);   // NPC: Curiosities Merchant (for testing)
        GrantOnce(player, 60419);   // Destructor's Rod
        if (!player->HasItemCount(60410, 1, true))   // everyone always carries a Duplicatron (it never wears out)
            player->AddItem(60410, 1);
        // After logging in the game could lose track of the weapon in your hands and swing bare fists
        // until you mounted and dismounted. Do the same refresh for you: draw, then put away.
        {
            ObjectGuid wg = player->GetGUID();
            player->m_Events.AddEventAtOffset([player, wg]()
            {
                if (!player->IsInWorld() || player->GetGUID() != wg || player->IsInCombat())
                    return;
                for (uint8 slot : { EQUIPMENT_SLOT_MAINHAND, EQUIPMENT_SLOT_OFFHAND, EQUIPMENT_SLOT_RANGED })
                    if (Item* it = player->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
                        player->SetVisibleItemSlot(slot, it);
                player->SetSheath(SHEATH_STATE_MELEE);
                player->m_Events.AddEventAtOffset([player, wg]()
                {
                    if (player->IsInWorld() && player->GetGUID() == wg && !player->IsInCombat())
                        player->SetSheath(SHEATH_STATE_UNARMED);
                }, Milliseconds(400));
            }, Seconds(3));
        }
        // First 10 minutes of a character's life: the ZeroCraft addon hides
        // chat spam (reputation, achievements, learned/unlearned, items, channels).
        uint32 played = player->GetTotalPlayedTime();
        if (played < 600)
            ChatHandler(player->GetSession()).SendSysMessage(Acore::StringFormat("ZCQUIET:{}", 600 - played));

        MaxAllProfessions(player);

        ZeroCraftVeteran::All(player);
        ZeroCraftEnchants::Apply(player);
        {
            ObjectGuid bg = player->GetGUID();
            player->m_Events.AddEventAtOffset([player, bg]()
            {
                if (player->IsInWorld() && player->GetGUID() == bg)
                    ZeroCraftBars::All(player);
            }, Milliseconds(2000));
            player->m_Events.AddEventAtOffset([player, bg]()
            {
                if (player->IsInWorld() && player->GetGUID() == bg)
                    ZeroCraftBars::All(player);
            }, Milliseconds(8000));
        }
        // Horde and Alliance are gone: old characters become Rebels or Pirates and move home
        if (!ZeroCraftRebels::IsOutlaw(player))
        {
            ZeroCraftRebels::Assign(player);
            if (Guild* g = player->GetGuildId() ? sGuildMgr->GetGuildById(player->GetGuildId()) : nullptr)
                if (g->GetName() == "the Horde" || g->GetName() == "the Alliance")
                    g->DeleteMember(player->GetGUID(), false, false, true);
            bool rebel = ZeroCraftRebels::Is(player);
            WorldLocation home = rebel ? ZeroCraftRebels::Home() : ZeroCraftRebels::PirateHome();
            player->SetHomebind(home, rebel ? ZeroCraftRebels::HOME_ZONE : ZeroCraftRebels::PIRATE_ZONE);
            ObjectGuid cg = player->GetGUID();
            player->m_Events.AddEventAtOffset([player, cg, home, rebel]()
            {
                if (!player->IsInWorld() || player->GetGUID() != cg)
                    return;
                player->TeleportTo(home);
                ChatHandler(player->GetSession()).SendSysMessage(rebel
                    ? "The Horde and the Alliance are no more. You are a Rebel now - Theramore is your home."
                    : "The Horde and the Alliance are no more. You are a Pirate now - Menethil Harbor is your home.");
            }, Milliseconds(1500));
        }
        JoinFactionGuild(player);
        ZeroCraftTabard::Wear(player);

        // ZeroCraft: the whole world map starts explored (same as ".cheat explore 1")
        for (uint16 i = 0; i < PLAYER_EXPLORED_ZONES_SIZE; ++i)
            if (player->GetUInt32Value(PLAYER_EXPLORED_ZONES_1 + i) != 0xFFFFFFFF)
                player->SetFlag(PLAYER_EXPLORED_ZONES_1 + i, 0xFFFFFFFF);

        // (Players are no longer forced friendly to every race: the realm is
        //  free-for-all PvP, and only your guild is on your side - see
        //  ZeroCraftGuildWar below.)
    }
};

// ============================================================================
// ZeroCraft deployable NPCs
// ----------------------------------------------------------------------------
// A "deploy" item spawns a random removed guard or vendor at the player's feet
// as a permanent spawn. Each owner (their guild if they're in one, otherwise
// just themselves) is assigned one faction "slot" from a small pool of client-
// known faction templates that are hostile to all players by default and used
// by no creature in the game. The owner (and guildmates) get a forced FRIENDLY
// reaction to that faction, so the NPC is green/usable for them and red/hostile
// to everyone else - both on the server and in every player's client.
// ============================================================================
// Extra deploy scrolls (Musician, Dancer, Stable Master...): which NPCs each
// scroll can bring out, and an idle animation to keep them playing (dance...).
namespace ZeroCraftPool
{
    struct Entry { uint32 item; uint32 npc; uint32 emote; };
    static std::vector<Entry> const& All()
    {
        static std::vector<Entry> v;
        static bool loaded = false;
        if (!loaded)
        {
            loaded = true;
            if (QueryResult r = WorldDatabase.Query("SELECT item_entry, npc_entry, emote FROM zerocraft_deploy_pool"))
                do { v.push_back({ (*r)[0].Get<uint32>(), (*r)[1].Get<uint32>(), (*r)[2].Get<uint32>() }); } while (r->NextRow());
        }
        return v;
    }
    static uint32 Pick(uint32 item)
    {
        std::vector<uint32> c;
        for (auto const& e : All()) if (e.item == item) c.push_back(e.npc);
        return c.empty() ? 0 : c[urand(0, c.size() - 1)];
    }
    static Entry const* Of(uint32 npc)
    {
        for (auto const& e : All()) if (e.npc == npc) return &e;
        return nullptr;
    }
}

namespace ZeroCraftDeploy
{
    // set by ZeroCraftHome: may this player build / deploy here? (Summoning Stone privilege)
    static bool (*BuildCheck)(Player*, float, float, float, std::string&) = nullptr;
    static bool (*AutoRoam)(Player*, Creature*) = nullptr;   // set by the NPC edit menu: new NPCs start roaming
    static void (*AutoScale)(Creature*, float) = nullptr;    // set by the NPC edit menu: remembered size
    static float nextHealth = 1.0f;   // a packed NPC comes back with the health it left with
    static const uint32 STONE_GUARD = 911130;   // the attackable heart of a Summoning Stone
    static void (*StoneFallen)(Creature*, Unit*) = nullptr;
    static const uint32 ITEM_DEPLOY_GUARD  = 823;
    static const uint32 ITEM_DEPLOY_VENDOR = 842;
    static const uint32 ITEM_DEPLOY_HERO   = 951;
    static const uint32 ITEM_DEPLOY_AUCTIONEER = 1078;
    static const uint32 ITEM_DEPLOY_FLIGHT     = 3504;
    static const uint32 ITEM_DEPLOY_BANKER     = 3513;
    static const uint32 ITEM_DEPLOY_INNKEEPER  = 25747;
    static const uint32 ITEM_DEPLOY_REPAIR     = 25748;
    static const uint32 SPELL_DEPLOY_CAST  = 5504;   // Conjure Water (Rank 1): cast bar, animation and sound
    static const int32  DEPLOY_CAST_MS     = 1500;   // guards & vendors
    static const uint32 SPELL_DEPLOY_CAST_HERO = 5505; // Conjure Water (Rank 2), used for heroes
    static const int32  DEPLOY_CAST_HERO_MS    = 5000;

    // Red error text in the middle of the screen (via the ZeroCraft addon;
    // players without it see the message in chat).
    static void RedError(Player* player, std::string const& msg)
    {
        ChatHandler(player->GetSession()).SendSysMessage("ZCERR:" + msg);
    }

    // Nearest built-in flight point to a spot on this map, within maxDist.
    static TaxiNodesEntry const* NearestTaxiNode(uint32 mapId, float x, float y, float z, float maxDist = 150.0f)
    {
        TaxiNodesEntry const* best = nullptr;
        float bestD = maxDist * maxDist;
        for (uint32 i = 0; i < sTaxiNodesStore.GetNumRows(); ++i)
        {
            TaxiNodesEntry const* n = sTaxiNodesStore.LookupEntry(i);
            if (!n || n->map_id != mapId)
                continue;
            float dx = n->x - x, dy = n->y - y, dz = n->z - z;
            float d = dx * dx + dy * dy + dz * dz;
            if (d < bestD) { bestD = d; best = n; }
        }
        return best;
    }

    struct PendingDeploy
    {
        uint32 itemEntry;
        Position pos;
        ObjectGuid itemGuid;
    };
    static std::unordered_map<ObjectGuid::LowType, PendingDeploy> pending; // player guid -> deploy waiting on the cast

    // owner key: guild id if > 0, otherwise -(player guid)
    static std::unordered_map<int64, uint32> ownerSlot;               // owner key -> faction template
    static std::unordered_map<ObjectGuid::LowType, uint32> spawnFaction; // creature spawn id -> faction template

    static int64 OwnerKey(Player* player)
    {
        if (uint32 guildId = player->GetGuildId())
            return int64(guildId);
        return -int64(player->GetGUID().GetCounter());
    }

    // One Banker per guild (or per player, if not in a guild).
    static bool HasBanker(Player* player)
    {
        std::string where = player->GetGuildId()
            ? Acore::StringFormat("d.owner_guild = {}", player->GetGuildId())
            : Acore::StringFormat("d.owner_guild = 0 AND d.owner_player = {}", player->GetGUID().GetCounter());
        return bool(WorldDatabase.Query(Acore::StringFormat(
            "SELECT 1 FROM zerocraft_deployables d JOIN creature_template ct ON ct.entry = d.entry "
            "WHERE (ct.npcflag & 0x20000) <> 0 AND {} LIMIT 1", where)));
    }

    static uint32 FactionOf(uint32 factionTemplate)
    {
        if (FactionTemplateEntry const* ft = sFactionTemplateStore.LookupEntry(factionTemplate))
            return ft->faction;
        return 0;
    }

    static void Load()
    {
        ownerSlot.clear();
        spawnFaction.clear();
        if (QueryResult r = WorldDatabase.Query("SELECT faction_template, owner_key FROM zerocraft_faction_slots WHERE owner_key IS NOT NULL"))
            do { ownerSlot[(*r)[1].Get<int64>()] = (*r)[0].Get<uint32>(); } while (r->NextRow());
        if (QueryResult r = WorldDatabase.Query("SELECT spawn_id, faction_template FROM zerocraft_deployables"))
            do { spawnFaction[(*r)[0].Get<uint32>()] = (*r)[1].Get<uint32>(); } while (r->NextRow());
    }

    static uint32 GetOrClaimSlot(int64 key)
    {
        auto itr = ownerSlot.find(key);
        if (itr != ownerSlot.end())
            return itr->second;

        QueryResult r = WorldDatabase.Query("SELECT faction_template FROM zerocraft_faction_slots WHERE owner_key IS NULL ORDER BY faction_template LIMIT 1");
        if (!r)
        {
            // No recycled tag free: mint a brand-new owner tag (unlimited).
            uint32 tag = 100000;
            if (QueryResult m = WorldDatabase.Query("SELECT MAX(faction_template) FROM zerocraft_faction_slots"))
                if (!(*m)[0].IsNull())
                    tag = std::max<uint32>(tag, (*m)[0].Get<uint32>() + 1);
            WorldDatabase.DirectExecute(Acore::StringFormat("INSERT INTO zerocraft_faction_slots (faction_template, owner_key) VALUES ({}, {})", tag, key));
            ownerSlot[key] = tag;
            return tag;
        }
        uint32 tpl = (*r)[0].Get<uint32>();
        WorldDatabase.DirectExecute(Acore::StringFormat("UPDATE zerocraft_faction_slots SET owner_key = {} WHERE faction_template = {}", key, tpl));
        ownerSlot[key] = tpl;
        return tpl;
    }

    // Everything deployed uses ONE real faction (hostile to all). Owners and
    // guildmates are shown a friendly faction instead, per viewer, by patching
    // the faction field in the update packet sent to them (see ZeroCraftDeployView).
    static const uint32 ZC_FACTION = 1234;
    static const uint32 ZC_FRIENDLY_VIEW = 35;

    static int64 TagOfCreature(Creature const* c)
    {
        if (!c) return 0;
        auto it = spawnFaction.find(c->GetSpawnId());
        return it == spawnFaction.end() ? 0 : int64(it->second);
    }

    static bool PlayerOwnsTag(Player const* p, int64 tag)
    {
        if (!p || !tag) return false;
        auto mine = ownerSlot.find(-int64(p->GetGUID().GetCounter()));
        if (mine != ownerSlot.end() && int64(mine->second) == tag) return true;
        if (p->GetGuildId())
        {
            auto g = ownerSlot.find(int64(p->GetGuildId()));
            if (g != ownerSlot.end() && int64(g->second) == tag) return true;
        }
        return false;
    }

    // Re-send the faction field of every NPC with this tag in the player's map.
    static void RefreshTag(Player* player, int64 tag)
    {
        if (!player || !tag || !player->IsInWorld()) return;
        auto& store = player->GetMap()->GetCreatureBySpawnIdStore();
        for (auto const& pair : spawnFaction)
        {
            if (int64(pair.second) != tag) continue;
            auto range = store.equal_range(pair.first);
            for (auto c = range.first; c != range.second; ++c)
                if (c->second && c->second->IsInWorld())
                    c->second->ForceValuesUpdateAtIndex(UNIT_FIELD_FACTIONTEMPLATE);
        }
    }

    static void ApplyReactions(Player* player, bool /*send*/ = true)
    {
        if (!player) return;
        auto mine = ownerSlot.find(-int64(player->GetGUID().GetCounter()));
        if (mine != ownerSlot.end()) RefreshTag(player, mine->second);
        if (player->GetGuildId())
        {
            auto g = ownerSlot.find(int64(player->GetGuildId()));
            if (g != ownerSlot.end()) RefreshTag(player, g->second);
        }
    }

    static std::string GuildNameOf(Player* player)
    {
        Guild* g = player->GetGuildId() ? sGuildMgr->GetGuildById(player->GetGuildId()) : nullptr;
        std::string n = g ? g->GetName() : "";
        WorldDatabase.EscapeString(n);
        return n;
    }

    static void RemoveGuildReaction(Player* player, uint32 guildId)
    {
        auto g = ownerSlot.find(int64(guildId));
        if (g != ownerSlot.end()) RefreshTag(player, g->second);
    }

    // Which side an NPC belongs to, from its faction: TEAM_ALLIANCE, TEAM_HORDE,
    // or TEAM_NEUTRAL for everyone else (villains, dungeon elites, Scarlets...).
    static TeamId TeamOfEntry(uint32 entry)
    {
        CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(entry);
        FactionTemplateEntry const* ft = ct ? sFactionTemplateStore.LookupEntry(ct->faction) : nullptr;
        if (!ft)
            return TEAM_NEUTRAL;
        bool a = (ft->ourMask | ft->friendlyMask) & FACTION_MASK_ALLIANCE;
        bool h = (ft->ourMask | ft->friendlyMask) & FACTION_MASK_HORDE;
        if (a && !h) return TEAM_ALLIANCE;
        if (h && !a) return TEAM_HORDE;
        return TEAM_NEUTRAL;
    }

    // Random entry from a pool query, keeping only your side's NPCs plus
    // neutral ones. Pools are read once and cached.
    static uint32 PickForSide(Player* player, std::string const& sql)
    {
        static std::unordered_map<std::string, std::vector<uint32>> cache;
        auto itr = cache.find(sql);
        if (itr == cache.end())
        {
            std::vector<uint32> all;
            if (QueryResult r = WorldDatabase.Query(sql))
                do { all.push_back((*r)[0].Get<uint32>()); } while (r->NextRow());
            itr = cache.emplace(sql, std::move(all)).first;
        }
        // Rebels and Pirates answer only to neutral troops and villains
        TeamId mine = ZeroCraftRebels::IsOutlaw(player) ? TEAM_NEUTRAL : player->GetTeamId(true);
        std::vector<uint32> ok;
        for (uint32 e : itr->second)
        {
            TeamId t = TeamOfEntry(e);
            if (t == TEAM_NEUTRAL || t == mine)
                ok.push_back(e);
        }
        return ok.empty() ? 0 : ok[urand(0, ok.size() - 1)];
    }

    static uint32 PickRandomEntry(Player* player, uint32 itemEntry)
    {
        if (uint32 e = ZeroCraftPool::Pick(itemEntry))
            return e;
        // Heroes and guards come from your own side (Horde or Alliance);
        // villains and other neutral NPCs can come to anyone.
        if (itemEntry == ITEM_DEPLOY_HERO)
            return PickForSide(player, "SELECT entry FROM zerocraft_hero_pool");
        // Service NPC items: pick a removed NPC that offers that service.
        uint32 serviceFlag = 0;
        switch (itemEntry)
        {
            case ITEM_DEPLOY_AUCTIONEER: serviceFlag = 0x200000; break; // UNIT_NPC_FLAG_AUCTIONEER
            case ITEM_DEPLOY_FLIGHT:     serviceFlag = 0x2000;   break; // UNIT_NPC_FLAG_FLIGHTMASTER
            case ITEM_DEPLOY_BANKER:     serviceFlag = 0x20000;  break; // UNIT_NPC_FLAG_BANKER
            case ITEM_DEPLOY_INNKEEPER:  serviceFlag = 0x10000;  break; // UNIT_NPC_FLAG_INNKEEPER
            case ITEM_DEPLOY_REPAIR:     serviceFlag = 0x1000;   break; // UNIT_NPC_FLAG_REPAIR
            default: break;
        }
        if (serviceFlag)
        {
            if (QueryResult r = WorldDatabase.Query(Acore::StringFormat(
                "SELECT DISTINCT r.id FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id WHERE (ct.npcflag & {}) <> 0 AND ct.`rank` <> 3 AND ct.entry NOT IN (4949,10181,2425,3057,2784,7999,4968,29611,16802,17468,10182,1748,25237,7937,3516,10540) ORDER BY RAND() LIMIT 1", serviceFlag)))
                return (*r)[0].Get<uint32>();
            return 0;
        }

        if (itemEntry == ITEM_DEPLOY_GUARD)
        {
            // 10% city guard, 50% faction soldier, 40% dungeon elite
            uint32 roll = urand(1, 100);
            char const* kind = roll <= 10 ? "guard" : (roll <= 60 ? "faction" : "dungeon");
            if (uint32 e = PickForSide(player, Acore::StringFormat("SELECT entry FROM zerocraft_guard_pool WHERE kind = '{}'", kind)))
                return e;
            return PickForSide(player, "SELECT entry FROM zerocraft_guard_pool");
        }
        bool guard = itemEntry == ITEM_DEPLOY_GUARD;
        std::string sql = guard
            ? "SELECT DISTINCT r.id FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id WHERE (ct.flags_extra & 0x8000) <> 0 AND ct.minlevel >= 50 AND ct.`rank` <> 3 AND ct.entry NOT IN (4949,10181,2425,3057,2784,7999,4968,29611,16802,17468,10182,1748,25237,7937,3516,10540) ORDER BY RAND() LIMIT 1"
            : "SELECT DISTINCT r.id FROM zerocraft_removed_creatures r JOIN creature_template ct ON ct.entry = r.id WHERE (ct.npcflag & 128) <> 0 AND ct.`rank` <> 3 AND ct.entry NOT IN (4949,10181,2425,3057,2784,7999,4968,29611,16802,17468,10182,1748,25237,7937,3516,10540) ORDER BY RAND() LIMIT 1";
        if (QueryResult r = WorldDatabase.Query(sql))
            return (*r)[0].Get<uint32>();
        return 0;
    }

    static bool Deploy(Player* player, uint32 itemEntry, Position const& pos, uint32 forcedEntry = 0)
    {
        ChatHandler chat(player->GetSession());

        if (player->GetTransport() || player->GetMap()->Instanceable())
        {
            chat.SendSysMessage("You can only deploy NPCs in the open world.");
            return false;
        }

        if (itemEntry == ITEM_DEPLOY_BANKER && HasBanker(player))
        {
            RedError(player, player->GetGuildId() ? "Your guild already has a Banker." : "You already have a Banker.");
            return false;
        }

        if (BuildCheck)
        {
            std::string err;
            if (!BuildCheck(player, pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ(), err))
            {
                RedError(player, err);
                return false;
            }
            if (itemEntry == ITEM_DEPLOY_FLIGHT)
                if (TaxiNodesEntry const* node = NearestTaxiNode(player->GetMapId(), pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ()))
                    if (!BuildCheck(player, node->x, node->y, node->z, err))
                    {
                        RedError(player, err + " (the flight point itself is inside their claim)");
                        return false;
                    }
        }

        int64 key = OwnerKey(player);
        uint32 tpl = GetOrClaimSlot(key);
        if (!tpl)
        {
            chat.SendSysMessage("No free deployment slots left on this server.");
            return false;
        }

        uint32 entry = forcedEntry ? forcedEntry : PickRandomEntry(player, itemEntry);
        if (!entry || !sObjectMgr->GetCreatureTemplate(entry))
        {
            chat.SendSysMessage("Could not find an NPC to deploy.");
            return false;
        }

        Map* map = player->GetMap();
        // every NPC arrives facing the player who called it
        float faceO = pos.GetAngle(player->GetPositionX(), player->GetPositionY());
        Creature* creature = new Creature();
        if (!creature->Create(map->GenerateLowGuid<HighGuid::Unit>(), map, player->GetPhaseMaskForSpawn(), entry, 0,
                              pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ(), faceO))
        {
            delete creature;
            return false;
        }
        creature->SaveToDB(map->GetId(), (1 << map->GetSpawnMode()), player->GetPhaseMaskForSpawn());
        ObjectGuid::LowType spawnId = creature->GetSpawnId();
        creature->CleanupsBeforeDelete();
        delete creature;

        // register before the creature enters the world so OnCreatureAddWorld picks it up
        spawnFaction[spawnId] = tpl;
        WorldDatabase.DirectExecute(Acore::StringFormat(
            "REPLACE INTO zerocraft_deployables (spawn_id, entry, owner_player, owner_guild, faction_template, owner_guild_name) VALUES ({}, {}, {}, {}, {}, '{}')",
            spawnId, entry, player->GetGUID().GetCounter(), player->GetGuildId(), tpl, GuildNameOf(player)));

        creature = new Creature();
        if (!creature->LoadCreatureFromDB(spawnId, map, true, true))
        {
            delete creature;
            return false;
        }
        sObjectMgr->AddCreatureToGrid(spawnId, sObjectMgr->GetCreatureData(spawnId));
        creature->SetFaction(ZC_FACTION);
        if (nextHealth > 0.0f && nextHealth < 1.0f)
            creature->SetHealth(std::max<uint32>(1, uint32(float(creature->GetMaxHealth()) * nextHealth)));

        // Flight masters walk to the real flight point and take their post there.
        if (itemEntry == ITEM_DEPLOY_FLIGHT)
            if (TaxiNodesEntry const* node = NearestTaxiNode(map->GetId(), pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ()))
            {
                float x = node->x, y = node->y, z = node->z;
                float o = creature->GetAngle(x, y);
                bool exact = false;
                // Use the original flight master's exact spot and facing if we know it
                std::string q = Acore::StringFormat(
                    "SELECT position_x, position_y, position_z, orientation FROM ("
                    " SELECT c.id, c.map, c.position_x, c.position_y, c.position_z, c.orientation FROM creature c"
                    " UNION ALL SELECT r.id, r.map, r.position_x, r.position_y, r.position_z, r.orientation FROM zerocraft_removed_creatures r) s"
                    " JOIN creature_template ct ON ct.entry = s.id"
                    " WHERE (ct.npcflag & 0x2000) <> 0 AND s.map = {}"
                    " AND POW(s.position_x - {}, 2) + POW(s.position_y - {}, 2) < 3600"
                    " ORDER BY POW(s.position_x - {}, 2) + POW(s.position_y - {}, 2) LIMIT 1",
                    map->GetId(), node->x, node->y, node->x, node->y);
                if (QueryResult r = WorldDatabase.Query(q))
                {
                    x = (*r)[0].Get<float>(); y = (*r)[1].Get<float>(); z = (*r)[2].Get<float>(); o = (*r)[3].Get<float>();
                    exact = true;
                }
                if (!exact)
                    creature->UpdateGroundPositionZ(x, y, z);
                creature->SetHomePosition(x, y, z, o);
                CreatureData& data = sObjectMgr->NewOrExistCreatureData(spawnId);
                data.posX = x; data.posY = y; data.posZ = z; data.orientation = o;
                WorldDatabase.Execute(Acore::StringFormat(
                    "UPDATE creature SET position_x = {}, position_y = {}, position_z = {}, orientation = {} WHERE guid = {}",
                    x, y, z, o, spawnId));
                creature->GetMotionMaster()->MovePoint(0, x, y, z);
                // once there, turn to face the way the original flight master faced
                uint32 travelMs = uint32(creature->GetExactDist(x, y, z) / std::max(creature->GetSpeed(MOVE_WALK), 1.0f) * 1000.0f) + 1500;
                creature->m_Events.AddEventAtOffset([creature, o]() { if (creature->IsAlive()) creature->SetFacingTo(o); }, Milliseconds(travelMs));
            }

        // owner + any online guildmates become friendly to this slot's faction
        for (auto const& pair : ObjectAccessor::GetPlayers())
        {
            Player* p = pair.second;
            if (!p || !p->IsInWorld())
                continue;
            if (p == player || (key > 0 && int64(p->GetGuildId()) == key))
                ApplyReactions(p);
        }

        chat.PSendSysMessage(Acore::StringFormat("Deployed {} - loyal to {}.", creature->GetName(),
            key > 0 ? "your guild" : "you"));

        // Bankers, Flight Masters and Auctioneers arrive huge, so you can spot them from across town
        if (AutoScale && (creature->IsTaxi() || creature->HasNpcFlag(UNIT_NPC_FLAG_BANKER) || creature->HasNpcFlag(UNIT_NPC_FLAG_AUCTIONEER)))
            AutoScale(creature, 3.0f);

        // every new NPC sets off to roam your land (a stroll), except those who hold a post:
        // Flight Masters, Bankers, Standard-Bearers and Training Dummies
        if (AutoRoam && entry != 911140 && entry != 31144 && !(entry >= 911150 && entry <= 911170) && itemEntry != ITEM_DEPLOY_FLIGHT)
        {
            ObjectGuid pg = player->GetGUID();
            creature->m_Events.AddEventAtOffset([creature, pg]()
            {
                Player* owner = ObjectAccessor::FindPlayer(pg);
                if (owner && creature->IsInWorld() && creature->IsAlive() && owner->GetMap() == creature->GetMap())
                    AutoRoam(owner, creature);
            }, Milliseconds(1500));
        }
        return true;
    }
}

// ============================================================================
// NPC upkeep: deployed NPCs are paid from their guild's bank every hour.
//   Hero 5g, Flight Master / Banker 2g, other service NPCs 1g, guards 50s.
// If the bank can't pay, every one of that guild's NPCs decays: it loses 25%
// of its health per hour (smoothly, every minute) and dies for good at 0.
// As soon as the bank can pay again, the decay is cleared.
// ============================================================================
namespace ZeroCraftUpkeep
{
    static std::unordered_map<ObjectGuid::LowType, float> decay;   // spawnId -> 0..1 of health lost

    static uint32 CostOf(uint32 entry)
    {
        if (entry == 911140)
            return 0;   // Guild Standard-Bearers serve for free
        static std::unordered_set<uint32> heroes;
        static bool loaded = false;
        if (!loaded)
        {
            loaded = true;
            if (QueryResult r = WorldDatabase.Query("SELECT entry FROM zerocraft_hero_pool"))
                do { heroes.insert((*r)[0].Get<uint32>()); } while (r->NextRow());
        }
        if (heroes.count(entry))
            return 5 * GOLD;
        CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(entry);
        uint32 flags = ct ? ct->npcflag : 0;
        if (flags & (UNIT_NPC_FLAG_FLIGHTMASTER | UNIT_NPC_FLAG_BANKER))
            return 2 * GOLD;
        if (flags & (UNIT_NPC_FLAG_VENDOR | UNIT_NPC_FLAG_AUCTIONEER | UNIT_NPC_FLAG_INNKEEPER | UNIT_NPC_FLAG_REPAIR | UNIT_NPC_FLAG_STABLEMASTER))
            return 1 * GOLD;
        return 50 * SILVER;
    }

    // message every online member of a guild (red text for bad news)
    static void TellGuild(uint32 guildId, std::string const& msg, bool red = false)
    {
        for (auto const& pair : ObjectAccessor::GetPlayers())
            if (Player* p = pair.second)
                if (p->IsInWorld() && p->GetGuildId() == guildId)
                {
                    if (red)
                        ZeroCraftDeploy::RedError(p, msg);
                    else
                        ChatHandler(p->GetSession()).SendSysMessage(msg);
                }
    }

    static float DecayOf(ObjectGuid::LowType spawnId)
    {
        auto itr = decay.find(spawnId);
        return itr == decay.end() ? 0.0f : itr->second;
    }
}

class ZeroCraftDeployItem : public ItemScript
{
public:
    ZeroCraftDeployItem() : ItemScript("item_zerocraft_deploy") { }

    // The item's spell is Flamestrike, used only for its ground-targeting circle.
    // We intercept the use, remember where the circle was dropped, and start the
    // 5 second "Conjure Water" cast. The NPC appears when that cast completes.
    bool OnUse(Player* player, Item* item, SpellCastTargets const& targets) override
    {
        ChatHandler chat(player->GetSession());
        if (!targets.HasDst())
        {
            chat.SendSysMessage("Pick a spot on the ground to deploy.");
            return true;
        }
        WorldLocation const* dst = targets.GetDstPos();
        if (!dst || player->GetExactDist(dst->GetPositionX(), dst->GetPositionY(), dst->GetPositionZ()) > 45.0f)
        {
            chat.SendSysMessage("That spot is too far away.");
            return true;
        }

        if (item->GetEntry() == ZeroCraftDeploy::ITEM_DEPLOY_BANKER && ZeroCraftDeploy::HasBanker(player))
        {
            ZeroCraftDeploy::RedError(player, player->GetGuildId() ? "Your guild already has a Banker." : "You already have a Banker.");
            return true;
        }

        if (ZeroCraftDeploy::BuildCheck)
        {
            std::string err;
            if (!ZeroCraftDeploy::BuildCheck(player, dst->GetPositionX(), dst->GetPositionY(), dst->GetPositionZ(), err))
            {
                ZeroCraftDeploy::RedError(player, err);
                return true;   // no cast, scroll kept
            }
        }

        if (item->GetEntry() == ZeroCraftDeploy::ITEM_DEPLOY_FLIGHT)
        {
            TaxiNodesEntry const* node = ZeroCraftDeploy::NearestTaxiNode(player->GetMapId(), dst->GetPositionX(), dst->GetPositionY(), dst->GetPositionZ());
            if (!node)
            {
                ZeroCraftDeploy::RedError(player, "Place closer to an in-game flight master location.");
                return true;
            }
            // One Flight Master per flight point, whoever owns it
            if (QueryResult r = WorldDatabase.Query(Acore::StringFormat(
                "SELECT c.map, c.position_x, c.position_y, c.position_z, d.owner_guild, d.owner_player FROM zerocraft_deployables d "
                "JOIN creature c ON c.guid = d.spawn_id JOIN creature_template ct ON ct.entry = d.entry "
                "WHERE (ct.npcflag & 0x2000) <> 0 AND c.map = {}", player->GetMapId())))
            {
                do
                {
                    Field* f = r->Fetch();
                    TaxiNodesEntry const* held = ZeroCraftDeploy::NearestTaxiNode(f[0].Get<uint32>(), f[1].Get<float>(), f[2].Get<float>(), f[3].Get<float>());
                    if (held && held->ID == node->ID)
                    {
                        bool ours = (player->GetGuildId() && f[4].Get<uint32>() == player->GetGuildId()) ||
                                    (!f[4].Get<uint32>() && f[5].Get<uint32>() == player->GetGUID().GetCounter());
                        ZeroCraftDeploy::RedError(player, ours
                            ? "Your guild already has a Flight Master at this flight point."
                            : "Another guild holds this flight point. Kill their Flight Master to take it.");
                        return true;
                    }
                } while (r->NextRow());
            }
        }

        ZeroCraftDeploy::PendingDeploy pd;
        pd.itemEntry = item->GetEntry();
        pd.pos.Relocate(dst->GetPositionX(), dst->GetPositionY(), dst->GetPositionZ(), player->GetOrientation());
        pd.itemGuid = item->GetGUID();
        ZeroCraftDeploy::pending[player->GetGUID().GetCounter()] = pd;

        player->CastSpell(player, pd.itemEntry == ZeroCraftDeploy::ITEM_DEPLOY_HERO ? ZeroCraftDeploy::SPELL_DEPLOY_CAST_HERO : ZeroCraftDeploy::SPELL_DEPLOY_CAST, TRIGGERED_NONE, item);
        return true; // never cast the Flamestrike itself
    }
};

class spell_zerocraft_deploy_conjure : public SpellScript
{
    PrepareSpellScript(spell_zerocraft_deploy_conjure);

    void HandleCreate(SpellEffIndex effIndex)
    {
        Player* player = GetCaster() ? GetCaster()->ToPlayer() : nullptr;
        Item* castItem = GetCastItem();
        if (!player || !castItem)
            return; // a real mage conjuring water - leave it alone

        auto itr = ZeroCraftDeploy::pending.find(player->GetGUID().GetCounter());
        if (itr == ZeroCraftDeploy::pending.end() || itr->second.itemGuid != castItem->GetGUID())
            return;

        PreventHitDefaultEffect(effIndex); // no water
        ZeroCraftDeploy::PendingDeploy pd = itr->second;
        ZeroCraftDeploy::pending.erase(itr);

        // finish outside the spell so the item can be safely destroyed
        player->m_Events.AddEventAtOffset([player, pd]()
        {
            Item* item = player->GetItemByGuid(pd.itemGuid);
            if (!item)
                return;
            // scrolls you packed an NPC into bring that exact NPC back (oldest first)
            uint32 packed = 0, packedId = 0;
            if (QueryResult r = CharacterDatabase.Query(Acore::StringFormat(
                "SELECT id, entry, health FROM zerocraft_packed WHERE player_guid = {} AND scroll_entry = {} ORDER BY id LIMIT 1",
                player->GetGUID().GetCounter(), pd.itemEntry)))
            {
                packedId = (*r)[0].Get<uint32>();
                packed = (*r)[1].Get<uint32>();
                ZeroCraftDeploy::nextHealth = (*r)[2].Get<float>();
            }
            bool ok = ZeroCraftDeploy::Deploy(player, pd.itemEntry, pd.pos, packed);
            ZeroCraftDeploy::nextHealth = 1.0f;
            if (ok)
            {
                if (packedId)
                    CharacterDatabase.DirectExecute(Acore::StringFormat("DELETE FROM zerocraft_packed WHERE id = {}", packedId));
                player->DestroyItemCount(item->GetEntry(), 1, true);
            }
        }, Milliseconds(1));
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_zerocraft_deploy_conjure::HandleCreate, EFFECT_0, SPELL_EFFECT_CREATE_ITEM);
    }
};

class ZeroCraftDeployCreatures : public AllCreatureScript
{
public:
    ZeroCraftDeployCreatures() : AllCreatureScript("ZeroCraftDeployCreatures") { }

    void OnCreatureAddWorld(Creature* creature) override { Fix(creature); }

    // factions can get reset from the template (respawn, evade) - keep them pinned
    void OnAllCreatureUpdate(Creature* creature, uint32 /*diff*/) override { Fix(creature); }

private:
    static void Fix(Creature* creature)
    {
        ObjectGuid::LowType spawnId = creature->GetSpawnId();
        if (!spawnId)
            return;
        auto itr = ZeroCraftDeploy::spawnFaction.find(spawnId);
        if (itr == ZeroCraftDeploy::spawnFaction.end())
            return;
        if (creature->GetFaction() != ZeroCraftDeploy::ZC_FACTION)
            creature->SetFaction(ZeroCraftDeploy::ZC_FACTION);
        if (creature->GetReactState() != REACT_AGGRESSIVE)
            creature->SetReactState(REACT_AGGRESSIVE);
        // Some bosses start "sealed" (Prince Taldaram's sphere, the Blood Princes)
        // with flags that make them unclickable/untouchable - strip them.
        uint32 const blocked = UNIT_FLAG_NOT_SELECTABLE | UNIT_FLAG_NON_ATTACKABLE | UNIT_FLAG_NOT_ATTACKABLE_1 |
                               UNIT_FLAG_IMMUNE_TO_PC | UNIT_FLAG_IMMUNE_TO_NPC | UNIT_FLAG_PACIFIED;
        if (creature->GetUnitFlags() & blocked)
            creature->RemoveUnitFlag(UnitFlags(blocked));

        // entertainers keep playing / dancing
        if (ZeroCraftPool::Entry const* pe = ZeroCraftPool::Of(creature->GetEntry()))
            if (pe->emote && !creature->IsInCombat() && creature->GetUInt32Value(UNIT_NPC_EMOTESTATE) != pe->emote)
                creature->SetUInt32Value(UNIT_NPC_EMOTESTATE, pe->emote);

        // Upkeep decay: health can't regenerate past what the decay has taken
        float d = ZeroCraftUpkeep::DecayOf(spawnId);
        if (d > 0.0f && creature->IsAlive())
        {
            if (d >= 1.0f)
            {
                creature->KillSelf();
                return;
            }
            uint32 cap = std::max<uint32>(1, uint32(float(creature->GetMaxHealth()) * (1.0f - d)));
            if (creature->GetHealth() > cap)
                creature->SetHealth(cap);
        }
    }
};

class ZeroCraftDeployWorld : public WorldScript
{
public:
    ZeroCraftDeployWorld() : WorldScript("ZeroCraftDeployWorld") { }
    void OnStartup() override
    {
        ZeroCraftDeploy::Load();

        // Flight points belong to guilds now, not factions: every Azeroth/Outland
        // flight point gets both a Horde and an Alliance mount so anyone can use it
        // (the client gets the same change from Data\patch-Z.MPQ).
        for (uint32 i = 0; i < sTaxiNodesStore.GetNumRows(); ++i)
            if (TaxiNodesEntry const* n = sTaxiNodesStore.LookupEntry(i))
            {
                if ((n->MountCreatureID[0] == 0) == (n->MountCreatureID[1] == 0))
                    continue;
                if (n->map_id != 0 && n->map_id != 1 && n->map_id != 530)
                    continue;
                auto* e = const_cast<TaxiNodesEntry*>(n);
                if (!e->MountCreatureID[0]) e->MountCreatureID[0] = 2224;  // wyvern
                if (!e->MountCreatureID[1]) e->MountCreatureID[1] = 541;   // gryphon
                uint8 field = uint8((e->ID - 1) / 32);
                uint32 bit = 1u << ((e->ID - 1) % 32);
                if (field < TaxiMaskSize)
                {
                    sHordeTaxiNodesMask[field] |= bit;
                    sAllianceTaxiNodesMask[field] |= bit;
                }
            }

        // Stretch the deploy cast to 5 seconds (only affects Conjure Water Rank 1).
        auto setCast = [](uint32 spellId, int32 ms)
        {
            SpellInfo* info = const_cast<SpellInfo*>(sSpellMgr->GetSpellInfo(spellId));
            if (!info)
                return;
            SpellCastTimesEntry const* best = nullptr;
            for (uint32 i = 0; i < sSpellCastTimesStore.GetNumRows(); ++i)
                if (SpellCastTimesEntry const* e = sSpellCastTimesStore.LookupEntry(i))
                    if (e->CastTime > 0 && e->CastTime <= ms && (!best || e->CastTime > best->CastTime))
                        best = e;
            if (best)
                info->CastTimeEntry = best;
        };
        setCast(ZeroCraftDeploy::SPELL_DEPLOY_CAST, ZeroCraftDeploy::DEPLOY_CAST_MS);
        setCast(ZeroCraftDeploy::SPELL_DEPLOY_CAST_HERO, ZeroCraftDeploy::DEPLOY_CAST_HERO_MS);
    }
};

class ZeroCraftDeployPlayer : public PlayerScript
{
public:
    ZeroCraftDeployPlayer() : PlayerScript("ZeroCraftDeployPlayer") { }
    void OnPlayerLogin(Player* player) override { ZeroCraftDeploy::ApplyReactions(player); }

};

class ZeroCraftDeployGuild : public GuildScript
{
public:
    ZeroCraftDeployGuild() : GuildScript("ZeroCraftDeployGuild") { }

    void OnAddMember(Guild* guild, Player* player, uint8& /*rank*/) override
    {
        if (player)
            ZeroCraftDeploy::ApplyReactions(player);
        if (player && guild)
            RefreshSoon(player, guild->GetId());
    }

    void OnRemoveMember(Guild* guild, Player* player, bool /*isDisbanding*/, bool /*isKicked*/) override
    {
        if (player && guild)
            ZeroCraftDeploy::RemoveGuildReaction(player, guild->GetId());
        if (player && guild)
            RefreshSoon(player, guild->GetId());
    }

    // Friend/foe colours are worked out per viewer when a player's data is
    // sent, so after a guild change re-send it for this player and for everyone
    // in the guild (a moment later, once the change has actually happened).
    static void Refresh(Player* p)
    {
        p->ForceValuesUpdateAtIndex(UNIT_FIELD_BYTES_2);
        p->ForceValuesUpdateAtIndex(UNIT_FIELD_FACTIONTEMPLATE);
        if (Pet* pet = p->GetPet())
        {
            pet->ForceValuesUpdateAtIndex(UNIT_FIELD_BYTES_2);
            pet->ForceValuesUpdateAtIndex(UNIT_FIELD_FACTIONTEMPLATE);
        }
    }
    static void RefreshSoon(Player* player, uint32 guildId)
    {
        ObjectGuid guid = player->GetGUID();
        player->m_Events.AddEventAtOffset([player, guid, guildId]()
        {
            if (player->IsInWorld() && player->GetGUID() == guid)
                Refresh(player);
            for (auto const& pair : ObjectAccessor::GetPlayers())
                if (Player* p = pair.second)
                    if (p->IsInWorld() && p->GetGuildId() == guildId)
                        Refresh(p);
        }, Milliseconds(300));
    }
};

// ============================================================================
// ZeroCraft quality of life
//  - Clicking a talent fills it straight to max rank (as many ranks as the
//    player's free points allow).
//  - No achievement popup/sound during a character's first 5 minutes played
//    (the achievements are still earned, just silently).
// ============================================================================
namespace ZeroCraftQoL { static bool inTalent = false; }

class ZeroCraftQoLPlayer : public PlayerScript
{
public:
    ZeroCraftQoLPlayer() : PlayerScript("ZeroCraftQoLPlayer") { }

    // (one click = one talent point - the old "fill to max rank" is gone)
    bool OnPlayerCanLearnTalent(Player* /*player*/, TalentEntry const* /*talent*/, uint32 /*rank*/) override
    {
        return true;
    }
};

class ZeroCraftQoLServer : public ServerScript
{
public:
    ZeroCraftQoLServer() : ServerScript("ZeroCraftQoLServer") { }

    bool CanPacketSend(WorldSession* session, WorldPacket const& packet) override
    {
        if (!session)
            return true;
        // the "X has earned the achievement [..]!" chat lines (nearby + guild)
        // for someone in their first 5 minutes played: nobody sees them
        if (packet.GetOpcode() == SMSG_MESSAGECHAT && packet.size() >= 13)
        {
            uint8 type = packet.read<uint8>(0);
            if (type == CHAT_MSG_ACHIEVEMENT || type == CHAT_MSG_GUILD_ACHIEVEMENT)
            {
                ObjectGuid who(packet.read<uint64>(5));
                if (Player* earner = ObjectAccessor::FindConnectedPlayer(who))
                    if (earner->GetTotalPlayedTime() < 300)
                        return false;
            }
            return true;
        }
        if (packet.GetOpcode() != SMSG_ACHIEVEMENT_EARNED)
            return true;
        Player* player = session->GetPlayer();
        if (player && player->GetTotalPlayedTime() < 600)
            return false;
        return true;
    }
};

namespace ZeroCraftTaxi
{
    static std::unordered_map<ObjectGuid::LowType, uint32> fmNode; // deployed FM spawn -> taxi node

    static uint32 NearestNode(Creature const* c, float maxDist = 150.0f)
    {
        uint32 best = 0;
        float bestD = maxDist;
        for (uint32 i = 0; i < sTaxiNodesStore.GetNumRows(); ++i)
        {
            TaxiNodesEntry const* n = sTaxiNodesStore.LookupEntry(i);
            if (!n || n->map_id != c->GetMapId())
                continue;
            float d = c->GetExactDist(n->x, n->y, n->z);
            if (d < bestD)
            {
                bestD = d;
                best = n->ID;
            }
        }
        return best;
    }

    static void Register(Creature* c)
    {
        if (!c->GetSpawnId() || !c->IsTaxi() || !ZeroCraftDeploy::spawnFaction.count(c->GetSpawnId()))
            return;
        if (fmNode.count(c->GetSpawnId()))
            return;
        if (uint32 node = NearestNode(c))
            fmNode[c->GetSpawnId()] = node;
    }

    // your guild's real flight points (the only places you can fly TO)
    static std::unordered_map<ObjectGuid::LowType, std::set<uint32>> guildNodes;

    static void Apply(Player* player)
    {
        TaxiMask mask;
        mask.fill(0);
        auto setBit = [&mask](uint32 node)
        {
            uint8 field = uint8((node - 1) / 32);
            if (node && field < TaxiMaskSize)
                mask[field] |= 1u << ((node - 1) % 32);
        };

        std::set<uint32>& mine = guildNodes[player->GetGUID().GetCounter()];
        mine.clear();
        for (auto const& fm : fmNode)
        {
            auto it = ZeroCraftDeploy::spawnFaction.find(fm.first);
            if (it == ZeroCraftDeploy::spawnFaction.end() || !ZeroCraftDeploy::PlayerOwnsTag(player, it->second))
                continue;
            mine.insert(fm.second);
            // also the node the core will pick for this player's faction at that spot
            if (CreatureData const* data = sObjectMgr->GetCreatureData(fm.first))
                if (uint32 n = sObjectMgr->GetNearestTaxiNode(data->posX, data->posY, data->posZ, data->mapid, player->GetTeamId(true)))
                    mine.insert(n);
        }
        for (uint32 node : mine)
            setBit(node);

        // Invisible stopovers: every other flight point in Azeroth is known too,
        // so a route can pass through (e.g. Crossroads -> Ratchet -> Theramore)
        // without your guild holding it. The ZeroCraft addon hides them on the
        // flight map and the server refuses them as a destination.
        if (!mine.empty())
            for (uint32 i = 0; i < sTaxiNodesStore.GetNumRows(); ++i)
                if (TaxiNodesEntry const* n = sTaxiNodesStore.LookupEntry(i))
                    if ((n->map_id == 0 || n->map_id == 1 || n->map_id == 530) && (n->MountCreatureID[0] || n->MountCreatureID[1]))
                        setBit(n->ID);

        std::string str;
        for (uint32 v : mask)
            str += std::to_string(v) + " ";
        player->m_taxi.LoadTaxiMask(str);
    }

    // "ZCTAXI:name;name;..." - tells the addon which points to show
    static void SendVisible(Player* player)
    {
        std::string msg = "ZCTAXI:";
        for (uint32 node : guildNodes[player->GetGUID().GetCounter()])
            if (TaxiNodesEntry const* n = sTaxiNodesStore.LookupEntry(node))
                msg += std::string(n->name[0]) + ";";
        ChatHandler(player->GetSession()).SendSysMessage(msg);
    }

    static bool CanFlyTo(Player* player, uint32 node)
    {
        auto itr = guildNodes.find(player->GetGUID().GetCounter());
        return itr != guildNodes.end() && itr->second.count(node);
    }
}



// Deployed NPCs die permanently: the spawn is erased the moment it dies, and
// the corpse is removed from the world after 60 seconds. Nothing respawns.
// ============================================================================
// Bank heist: kill a guild's Banker and its corpse holds that guild's whole
// guild bank - all the gold, and the items (the first 18 stacks in the loot
// window; anything more is mailed to the killer). The guild bank is emptied.
// ============================================================================
// ============================================================================
// Guild Vault: every deployed Banker has a real Guild Vault chest standing
// beside it. Click it for the normal guild bank window (tabs, items, gold).
// Only the Banker's own guild can open it; it vanishes when the Banker dies.
// ============================================================================
namespace ZeroCraftVault
{
    static const uint32 VAULT_ENTRY = 187290;
    static const uint32 MARKER_ENTRY = 911100;
    static std::unordered_map<ObjectGuid, uint32> markerGuild;               // marker -> guild
    static std::unordered_map<ObjectGuid::LowType, ObjectGuid> bankerMarker; // banker spawn -> marker
    static float MarkerHeight(Creature* banker) { return banker->GetCollisionHeight() + 0.2f; }
    static std::unordered_map<ObjectGuid, uint32> vaultGuild;             // vault -> guild
    static std::unordered_map<ObjectGuid::LowType, ObjectGuid> bankerVault; // banker spawn -> vault

    static void Place(Creature* banker)
    {
        uint32 guildId = 0;
        if (QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT owner_guild FROM zerocraft_deployables WHERE spawn_id = {}", banker->GetSpawnId())))
            guildId = (*r)[0].Get<uint32>();
        if (!guildId)
            return;
        if (auto itr = bankerMarker.find(banker->GetSpawnId()); itr != bankerMarker.end())
            if (ObjectAccessor::GetCreature(*banker, itr->second))
                return;
        // no vault chest any more - just a blue "!" hovering over the Banker
        if (Creature* mk = banker->SummonCreature(MARKER_ENTRY, banker->GetPositionX(), banker->GetPositionY(),
                                                  banker->GetPositionZ() + MarkerHeight(banker), banker->GetOrientation(), TEMPSUMMON_MANUAL_DESPAWN))
        {
            mk->SetDisableGravity(true);
            markerGuild[mk->GetGUID()] = guildId;
            bankerMarker[banker->GetSpawnId()] = mk->GetGUID();
        }
    }

    // keep the "!" above the Banker's head if the Banker is moved
    static void Follow(Creature* banker)
    {
        auto itr = bankerMarker.find(banker->GetSpawnId());
        if (itr == bankerMarker.end())
            return;
        Creature* mk = ObjectAccessor::GetCreature(*banker, itr->second);
        if (!mk || !mk->IsInWorld() || mk->GetMap() != banker->GetMap())
            return;
        float z = banker->GetPositionZ() + MarkerHeight(banker);
        if (mk->GetExactDist2d(banker) > 0.5f || std::fabs(mk->GetPositionZ() - z) > 0.5f)
            mk->NearTeleportTo(banker->GetPositionX(), banker->GetPositionY(), z, banker->GetOrientation());
    }

    static void Remove(Creature* banker)
    {
        auto itr = bankerVault.find(banker->GetSpawnId());
        if (itr != bankerVault.end())
        {
            if (GameObject* go = ObjectAccessor::GetGameObject(*banker, itr->second))
                go->DespawnOrUnsummon();
            vaultGuild.erase(itr->second);
            bankerVault.erase(itr);
        }
        auto m = bankerMarker.find(banker->GetSpawnId());
        if (m != bankerMarker.end())
        {
            if (Creature* mk = ObjectAccessor::GetCreature(*banker, m->second))
                mk->DespawnOrUnsummon();
            markerGuild.erase(m->second);
            bankerMarker.erase(m);
        }
    }
}

struct ZcGuildPeek : public Guild
{
    static auto& Tabs(Guild* g) { return static_cast<ZcGuildPeek*>(g)->m_bankTabs; }
};

namespace ZeroCraftBankHeist
{
    static void Loot(Creature* banker, Unit* killer, bool mailAll = false)
    {
        uint32 guildId = 0;
        if (QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT owner_guild FROM zerocraft_deployables WHERE spawn_id = {}", banker->GetSpawnId())))
            guildId = (*r)[0].Get<uint32>();
        Guild* guild = guildId ? sGuildMgr->GetGuildById(guildId) : nullptr;
        if (!guild)
            return;
        Player* looter = killer ? killer->GetCharmerOrOwnerPlayerOrPlayerItself() : nullptr;

        // empty the guild bank
        std::vector<std::pair<uint32, uint32>> stacks;   // entry, count
        CharacterDatabaseTransaction trans = CharacterDatabase.BeginTransaction();
        for (auto& tab : ZcGuildPeek::Tabs(guild))
            for (uint8 slot = 0; slot < GUILD_BANK_MAX_SLOTS; ++slot)
                if (Item* item = tab.GetItem(slot))
                {
                    stacks.emplace_back(item->GetEntry(), item->GetCount());
                    tab.SetItem(trans, slot, nullptr);
                    item->DeleteFromDB(trans);
                    delete item;
                }
        uint64 money = guild->GetTotalBankMoney();
        if (money)
            (void)guild->ModifyBankMoney(trans, money, false);
        CharacterDatabase.CommitTransaction(trans);

        // fill the corpse
        ::Loot& loot = banker->loot;
        if (looter)
            loot.lootOwnerGUID = looter->GetGUID();
        if (!mailAll)
            loot.gold += uint32(std::min<uint64>(money, 0xFFFFFFFFull));
        std::vector<std::pair<uint32, uint32>> overflow;
        if (mailAll && looter && money)
        {
            CharacterDatabaseTransaction gtrans = CharacterDatabase.BeginTransaction();
            MailDraft gd("The hoard of the Summoning Stone", Acore::StringFormat("Every coin from <{}>'s guild bank.", guild->GetName()));
            gd.AddMoney(uint32(std::min<uint64>(money, 0x7FFFFFFFull)));
            gd.SendMailTo(gtrans, MailReceiver(looter), MailSender(MAIL_CREATURE, banker->GetEntry()));
            CharacterDatabase.CommitTransaction(gtrans);
        }
        for (auto const& st : stacks)
        {
            uint32 count = std::min<uint32>(st.second, 255);
            if (!mailAll && loot.items.size() < MAX_NR_LOOT_ITEMS)
                loot.AddItem(LootStoreItem(st.first, 0, 100.0f, false, LOOT_MODE_DEFAULT, 0, count, uint8(count)));
            else
                overflow.push_back(st);
        }
        if (!loot.empty())
            banker->SetDynamicFlag(UNIT_DYNFLAG_LOOTABLE);

        // whatever doesn't fit in the loot window goes to the killer's mailbox
        if (looter && !overflow.empty())
        {
            CharacterDatabaseTransaction mtrans = CharacterDatabase.BeginTransaction();
            size_t i = 0;
            while (i < overflow.size())
            {
                MailDraft draft("The rest of the vault", Acore::StringFormat("Everything else from <{}>'s bank.", guild->GetName()));
                for (uint32 n = 0; n < MAX_MAIL_ITEMS && i < overflow.size(); ++i)
                    if (Item* item = Item::CreateItem(overflow[i].first, overflow[i].second, looter))
                    {
                        item->SaveToDB(mtrans);
                        draft.AddItem(item);
                        ++n;
                    }
                draft.SendMailTo(mtrans, MailReceiver(looter), MailSender(MAIL_CREATURE, banker->GetEntry()));
            }
            CharacterDatabase.CommitTransaction(mtrans);
        }

        if (looter && mailAll)
            ChatHandler(looter->GetSession()).PSendSysMessage(Acore::StringFormat(
                "You shattered <{}>'s Summoning Stone! Their whole guild bank is on its way to your mailbox.", guild->GetName()));
        else if (looter)
            ChatHandler(looter->GetSession()).PSendSysMessage(Acore::StringFormat(
                "You broke into <{}>'s bank vault! Loot the Banker{}.", guild->GetName(),
                overflow.empty() ? "" : " - the rest is in your mailbox"));
        ZeroCraftUpkeep::TellGuild(guildId, Acore::StringFormat("Our Banker was killed and the guild bank was looted{}!",
            looter ? " by " + looter->GetName() : ""), true);
    }
}

// ============================================================================
// NPCs belong to the guild by NAME: if every member of a guild is deleted, the
// guild disbands, but its NPCs wait. The next guild with that same name (for
// example the new <the Rebels> a fresh character joins) takes them over, and
// they're friendly to it again - with its upkeep record and Guild Vaults.
// ============================================================================
namespace ZeroCraftAdopt
{
    static void Adopt(Guild* guild)
    {
        if (!guild)
            return;
        uint32 newId = guild->GetId();
        std::string name = guild->GetName();
        WorldDatabase.EscapeString(name);
        QueryResult r = WorldDatabase.Query(Acore::StringFormat(
            "SELECT DISTINCT owner_guild, IF(owner_guild = 0, owner_player, 0) FROM zerocraft_deployables WHERE owner_guild_name = '{}' AND owner_guild <> {}", name, newId));
        if (!r)
            return;
        do
        {
            uint32 oldId = (*r)[0].Get<uint32>();
            uint32 oldPlayer = (*r)[1].Get<uint32>();
            if (oldId && sGuildMgr->GetGuildById(oldId))
                continue; // that guild still exists - it keeps its own NPCs
            // NPCs placed before guilds existed were keyed to their player
            int64 oldKey = oldId ? int64(oldId) : -int64(oldPlayer);

            auto& slots = ZeroCraftDeploy::ownerSlot;
            auto oldSlot = slots.find(oldKey);
            auto newSlot = slots.find(int64(newId));
            if (oldSlot != slots.end() && newSlot == slots.end())
            {
                // hand the old guild's owner tag to the new guild as it is
                uint32 tag = oldSlot->second;
                slots.erase(oldSlot);
                slots[int64(newId)] = tag;
                WorldDatabase.DirectExecute(Acore::StringFormat("UPDATE zerocraft_faction_slots SET owner_key = {} WHERE faction_template = {}", int64(newId), tag));
            }
            else if (oldSlot != slots.end())
            {
                // new guild already has a tag: re-tag the old NPCs to it
                uint32 oldTag = oldSlot->second, tag = newSlot->second;
                for (auto& sf : ZeroCraftDeploy::spawnFaction)
                    if (sf.second == oldTag)
                        sf.second = tag;
                WorldDatabase.DirectExecute(Acore::StringFormat("UPDATE zerocraft_deployables SET faction_template = {} WHERE faction_template = {}", tag, oldTag));
                WorldDatabase.DirectExecute(Acore::StringFormat("UPDATE zerocraft_faction_slots SET owner_key = NULL WHERE faction_template = {}", oldTag));
                slots.erase(oldSlot);
            }
            if (oldId)
                WorldDatabase.DirectExecute(Acore::StringFormat("UPDATE zerocraft_deployables SET owner_guild = {} WHERE owner_guild = {}", newId, oldId));
            else
                WorldDatabase.DirectExecute(Acore::StringFormat("UPDATE zerocraft_deployables SET owner_guild = {} WHERE owner_guild = 0 AND owner_player = {}", newId, oldPlayer));
            WorldDatabase.DirectExecute(Acore::StringFormat("UPDATE IGNORE zerocraft_upkeep SET guild_id = {} WHERE guild_id = {}", newId, oldId));
            for (auto& v : ZeroCraftVault::vaultGuild)
                if (v.second == oldId)
                    v.second = newId;
            for (auto& v : ZeroCraftVault::markerGuild)
                if (v.second == oldId)
                    v.second = newId;
        } while (r->NextRow());

        // everyone online in the guild sees their NPCs as friendly again
        for (auto const& pair : ObjectAccessor::GetPlayers())
            if (Player* p = pair.second)
                if (p->IsInWorld() && p->GetGuildId() == newId)
                    ZeroCraftDeploy::ApplyReactions(p);
    }
}

class ZeroCraftAdoptGuild : public GuildScript
{
public:
    ZeroCraftAdoptGuild() : GuildScript("ZeroCraftAdoptGuild") { }
    void OnCreate(Guild* guild, Player* /*leader*/, std::string const& /*name*/) override
    {
        ZeroCraftAdopt::Adopt(guild);
    }
};

class ZeroCraftAdoptLogin : public PlayerScript
{
public:
    ZeroCraftAdoptLogin() : PlayerScript("ZeroCraftAdoptLogin") { }
    void OnPlayerLogin(Player* player) override
    {
        ObjectGuid guid = player->GetGUID();
        player->m_Events.AddEventAtOffset([player, guid]()
        {
            if (player->IsInWorld() && player->GetGUID() == guid && player->GetGuildId())
                ZeroCraftAdopt::Adopt(sGuildMgr->GetGuildById(player->GetGuildId()));
        }, Milliseconds(1000));
    }
};

// ============================================================================
// ZeroCraft Guild War: every flight point is a territory, held by whichever
// guild has a Flight Master standing there. The ZeroCraft addon draws the map
// (green = yours, red = enemy, grey = free) from "ZCTERR:" lines. Guilds get
// raid warnings when their NPCs are attacked, everyone hears when a flight point
// falls, and each flight point pays its guild 5 gold an hour.
// ============================================================================
namespace ZeroCraftWar
{
    static std::string lastKey;
    static std::unordered_map<ObjectGuid::LowType, uint32> lastWarn;
    static const uint32 INCOME_PER_POINT = 5 * GOLD;

    static std::string CleanName(char const* raw)
    {
        std::string s = raw ? raw : "";
        size_t c = s.find(',');
        if (c != std::string::npos)
            s = s.substr(0, c);
        return s;
    }

    static std::string PlaceName(WorldObject const* o)
    {
        {
            uint32 zone = 0, area = 0;
            o->GetZoneAndAreaId(zone, area);
            AreaTableEntry const* z = sAreaTableStore.LookupEntry(zone);
            AreaTableEntry const* a = area != zone ? sAreaTableStore.LookupEntry(area) : nullptr;
            if (a && z)
                return std::string(a->area_name[0]) + ", " + z->area_name[0];
            if (z)
                return z->area_name[0];
        }
        if (TaxiNodesEntry const* n = ZeroCraftDeploy::NearestTaxiNode(o->GetMapId(), o->GetPositionX(), o->GetPositionY(), o->GetPositionZ(), 150.0f))
            return CleanName(n->name[0]);
        if (AreaTableEntry const* a = sAreaTableStore.LookupEntry(o->GetZoneId()))
            return a->area_name[0];
        return "the wilds";
    }

    // node id -> owning guild, straight from the database so unloaded parts of the world count too
    static bool IsWarNode(TaxiNodesEntry const* n);
    static TaxiNodesEntry const* NearestWarNode(uint32 mapId, float x, float y, float z, float maxDist = 150.0f)
    {
        TaxiNodesEntry const* best = nullptr;
        float bestD = maxDist * maxDist;
        for (uint32 i = 0; i < sTaxiNodesStore.GetNumRows(); ++i)
        {
            TaxiNodesEntry const* n = sTaxiNodesStore.LookupEntry(i);
            if (!n || n->map_id != mapId || !IsWarNode(n))
                continue;
            float dx = n->x - x, dy = n->y - y, dz = n->z - z;
            float d = dx * dx + dy * dy + dz * dz;
            if (d < bestD) { bestD = d; best = n; }
        }
        return best;
    }

    static std::map<uint32, std::string> Territories()
    {
        std::map<uint32, std::string> t;
        if (QueryResult r = WorldDatabase.Query(
            "SELECT c.map, c.position_x, c.position_y, c.position_z, d.owner_guild_name, d.owner_guild FROM zerocraft_deployables d "
            "JOIN creature c ON c.guid = d.spawn_id JOIN creature_template ct ON ct.entry = d.entry WHERE (ct.npcflag & 0x2000) <> 0"))
        {
            do
            {
                Field* f = r->Fetch();
                TaxiNodesEntry const* n = NearestWarNode(f[0].Get<uint32>(), f[1].Get<float>(), f[2].Get<float>(), f[3].Get<float>());
                if (!n)
                    continue;
                std::string g = f[4].Get<std::string>();
                if (g.empty())
                    if (Guild* guild = sGuildMgr->GetGuildById(f[5].Get<uint32>()))
                        g = guild->GetName();
                if (!g.empty())
                    t[n->ID] = g;
            } while (r->NextRow());
        }
        return t;
    }


    // ---------------------------------------------------------------- zones
    // A guild that holds EVERY flight point in a zone controls that zone: it is announced to the
    // server, painted on the world map, shown when you walk in, and pays a bonus every hour.
    static const uint32 ZONE_BONUS = 20 * GOLD;
    static std::map<uint32, std::string> lastZoneOwner;   // zone id -> guild (last refresh)
    static bool zoneInit = false;
    static std::unordered_map<uint64, uint32> lastIntruder;   // (player << 32 | zone) -> time

    static bool IsWarNode(TaxiNodesEntry const* n)
    {
        if (!n || !(n->MountCreatureID[0] || n->MountCreatureID[1]))
            return false;
        std::string name = CleanName(n->name[0]);
        if (name.empty())
            return false;
        for (char const* bad : { "Quest", "Programmer", "Transport", "TEST", "Test", " - ", "->", "Development", "Generic", "Filming", "Prologue" })
            if (name.find(bad) != std::string::npos)
                return false;
        if (n->map_id == 0 || n->map_id == 1)
            return true;
        return n->map_id == 530 && (name == "Silvermoon City" || name == "Tranquillien" || name == "Blood Watch" || name == "The Exodar");
    }

    // node id -> zone id, worked out once
    static std::map<uint32, uint32> const& NodeZones()
    {
        static std::map<uint32, uint32> z;
        static bool done = false;
        if (!done)
        {
            done = true;
            for (uint32 i = 0; i < sTaxiNodesStore.GetNumRows(); ++i)
                if (TaxiNodesEntry const* n = sTaxiNodesStore.LookupEntry(i))
                    if (IsWarNode(n))
                        if (uint32 zone = sMapMgr->GetZoneId(PHASEMASK_NORMAL, n->map_id, n->x, n->y, n->z))
                            z[n->ID] = zone;
        }
        return z;
    }

    static std::string ZoneName(uint32 zone)
    {
        if (AreaTableEntry const* a = sAreaTableStore.LookupEntry(zone))
            return a->area_name[0];
        return "";
    }

    struct ZoneState { uint32 total = 0; std::map<std::string, uint32> held; std::string owner; };
    static std::map<uint32, ZoneState> Zones(std::map<uint32, std::string> const& t)
    {
        std::map<uint32, ZoneState> zs;
        for (auto const& nz : NodeZones())
        {
            ZoneState& z = zs[nz.second];
            ++z.total;
            auto it = t.find(nz.first);
            if (it != t.end())
                ++z.held[it->second];
        }
        for (auto& kv : zs)
            for (auto const& h : kv.second.held)
                if (h.second == kv.second.total)
                    kv.second.owner = h.first;
        return zs;
    }

    static std::string ZoneOwner(uint32 zone)
    {
        auto it = lastZoneOwner.find(zone);
        return it == lastZoneOwner.end() ? std::string() : it->second;
    }

    static std::vector<std::string> Lines(std::map<uint32, std::string> const& t)
    {
        std::vector<std::string> out = { "ZCTERR:!" };
        std::string cur;
        for (auto const& kv : t)
        {
            std::string part = std::to_string(kv.first) + "=" + kv.second + ";";
            if (cur.size() + part.size() > 200)
            {
                out.push_back("ZCTERR:" + cur);
                cur.clear();
            }
            cur += part;
        }
        if (!cur.empty())
            out.push_back("ZCTERR:" + cur);
        out.push_back("ZCTERR:.");
        // zones: "ZCZONE:name=owner|top guild|held|total;"
        out.push_back("ZCZONE:!");
        cur.clear();
        for (auto const& kv : Zones(t))
        {
            std::string top; uint32 best = 0;
            for (auto const& h : kv.second.held)
                if (h.second > best) { best = h.second; top = h.first; }
            std::string part = ZoneName(kv.first) + "=" + kv.second.owner + "|" + top + "|" + std::to_string(best) + "|" +
                               std::to_string(kv.second.total) + "|" + std::to_string(kv.second.held.size()) + ";";
            if (cur.size() + part.size() > 200)
            {
                out.push_back("ZCZONE:" + cur);
                cur.clear();
            }
            cur += part;
        }
        if (!cur.empty())
            out.push_back("ZCZONE:" + cur);
        out.push_back("ZCZONE:.");
        return out;
    }

    static void SendLines(Player* p, std::vector<std::string> const& lines)
    {
        if (!p || !p->IsInWorld() || !p->GetSession())
            return;
        ChatHandler ch(p->GetSession());
        for (auto const& l : lines)
            ch.SendSysMessage(l);
    }

    static void SendNow(Player* p) { SendLines(p, Lines(Territories())); }

    static void WarnAll(std::string const& msg);

    // re-sends the territory map to everyone, but only when it changed
    static void Refresh()
    {
        auto t = Territories();
        std::string key;
        for (auto const& kv : t)
            key += std::to_string(kv.first) + "=" + kv.second + ";";
        if (key == lastKey)
            return;
        lastKey = key;
        {
            std::map<uint32, std::string> owners;
            for (auto const& kv : Zones(t))
                if (!kv.second.owner.empty())
                    owners[kv.first] = kv.second.owner;
            if (zoneInit)
            {
                for (auto const& kv : owners)
                    if (ZoneOwner(kv.first) != kv.second)
                        WarnAll(Acore::StringFormat("<{}> now controls every flight point in {}! {} is their territory.", kv.second, ZoneName(kv.first), ZoneName(kv.first)));
                for (auto const& kv : lastZoneOwner)
                    if (!owners.count(kv.first))
                        WarnAll(Acore::StringFormat("<{}> has lost control of {}.", kv.second, ZoneName(kv.first)));
            }
            lastZoneOwner = owners;
            zoneInit = true;
        }
        auto lines = Lines(t);
        for (auto const& pair : ObjectAccessor::GetPlayers())
            SendLines(pair.second, lines);
    }

    static void Warn(Player* p, std::string const& msg)
    {
        if (!p || !p->IsInWorld() || !p->GetSession())
            return;
        WorldPacket data;
        ChatHandler::BuildChatPacket(data, CHAT_MSG_RAID_WARNING, LANG_UNIVERSAL, static_cast<WorldObject const*>(nullptr), static_cast<WorldObject const*>(nullptr), msg);
        p->SendDirectMessage(&data);
    }

    static void WarnGuild(uint32 guildId, uint32 ownerPlayer, std::string const& msg)
    {
        for (auto const& pair : ObjectAccessor::GetPlayers())
            if (Player* p = pair.second)
                if ((guildId && p->GetGuildId() == guildId) || (!guildId && p->GetGUID().GetCounter() == ownerPlayer))
                    Warn(p, msg);
    }

    static void WarnAll(std::string const& msg)
    {
        for (auto const& pair : ObjectAccessor::GetPlayers())
            Warn(pair.second, msg);
    }

    static bool OwnerOf(ObjectGuid::LowType spawnId, uint32& guildId, uint32& ownerPlayer, std::string& guildName)
    {
        QueryResult r = WorldDatabase.Query(Acore::StringFormat(
            "SELECT owner_guild, owner_player, owner_guild_name FROM zerocraft_deployables WHERE spawn_id = {}", spawnId));
        if (!r)
            return false;
        guildId = (*r)[0].Get<uint32>();
        ownerPlayer = (*r)[1].Get<uint32>();
        guildName = (*r)[2].Get<std::string>();
        return true;
    }

    static std::string Who(Player* p)
    {
        if (Guild* g = sGuildMgr->GetGuildById(p->GetGuildId()))
            return "<" + g->GetName() + "> " + p->GetName();
        return p->GetName();
    }

    // a player hits one of a guild's NPCs: that guild gets a raid warning (once a minute per NPC)
    // tells the addon where it happened: "ZCALERT:kind|map|x|y|what|by"
    static void Alert(uint32 guildId, uint32 ownerPlayer, char const* kind, Creature* c, std::string const& by)
    {
        std::string line = Acore::StringFormat("ZCALERT:{}|{}|{:.1f}|{:.1f}|{}|{}", kind, c->GetMapId(), c->GetPositionX(), c->GetPositionY(), c->GetName(), by);
        for (auto const& pair : ObjectAccessor::GetPlayers())
            if (Player* p = pair.second)
                if (p->IsInWorld() && ((guildId && p->GetGuildId() == guildId) || (!guildId && p->GetGUID().GetCounter() == ownerPlayer)))
                    ChatHandler(p->GetSession()).SendSysMessage(line);
    }

    static std::string WhoUnit(Unit* u)
    {
        if (!u)
            return "";
        if (Player* p = u->GetCharmerOrOwnerPlayerOrPlayerItself())
            return Who(p);
        return std::string(u->GetName());
    }

    static void UnderAttack(Creature* victim, Unit* attacker)
    {
        Player* ap = attacker ? attacker->GetCharmerOrOwnerPlayerOrPlayerItself() : nullptr;
        if (!attacker || !victim->GetSpawnId())
            return;
        uint32 now = getMSTime();
        uint32& last = lastWarn[victim->GetSpawnId()];
        if (last && getMSTimeDiff(last, now) < 60 * IN_MILLISECONDS)
            return;
        uint32 guildId = 0, ownerPlayer = 0;
        std::string guildName;
        if (!OwnerOf(victim->GetSpawnId(), guildId, ownerPlayer, guildName))
            return;
        if (ap && ((guildId && ap->GetGuildId() == guildId) || (!guildId && ap->GetGUID().GetCounter() == ownerPlayer)))
            return;
        last = now;
        WarnGuild(guildId, ownerPlayer, Acore::StringFormat("{} is under attack! Your {} is fighting {}.",
            PlaceName(victim), victim->GetName(), WhoUnit(attacker)));
        Alert(guildId, ownerPlayer, "attack", victim, WhoUnit(attacker));
    }

    // one of a guild's NPCs dies
    static void Fallen(Creature* c, Unit* killer)
    {
        uint32 guildId = 0, ownerPlayer = 0;
        std::string guildName;
        if (!OwnerOf(c->GetSpawnId(), guildId, ownerPlayer, guildName))
            return;
        Player* kp = killer ? killer->GetCharmerOrOwnerPlayerOrPlayerItself() : nullptr;
        std::string place = PlaceName(c);
        std::string owner = guildName.empty() ? std::string("A lone commander") : "<" + guildName + ">";
        if (c->IsTaxi())
        {
            if (kp)
                WarnAll(Acore::StringFormat("{} has broken {}'s hold on {}! The flight point is up for grabs.", Who(kp), owner, place));
            else
                WarnAll(Acore::StringFormat("{} has lost {}. The flight point is up for grabs.", owner, place));
        }
        else
            WarnGuild(guildId, ownerPlayer, Acore::StringFormat("Your {} at {} has fallen{}!", c->GetName(), place,
                killer && killer != c ? " to " + WhoUnit(killer) : std::string(" - upkeep went unpaid")));
        Alert(guildId, ownerPlayer, "fallen", c, killer && killer != c ? WhoUnit(killer) : std::string("upkeep"));
        lastWarn.erase(c->GetSpawnId());
    }

    // hourly: every flight point pays its guild
    static void PayIncome(Guild* guild, uint32 flightPoints)
    {
        if (!guild || !flightPoints)
            return;
        uint32 zones = 0;
        for (auto const& kv : lastZoneOwner)
            if (kv.second == guild->GetName())
                ++zones;
        if (zones)
        {
            CharacterDatabaseTransaction t2 = CharacterDatabase.BeginTransaction();
            (void)guild->ModifyBankMoney(t2, uint64(zones) * ZONE_BONUS, true);
            CharacterDatabase.CommitTransaction(t2);
            ZeroCraftUpkeep::TellGuild(guild->GetId(), Acore::StringFormat(
                "Conquest tribute: {} gold from the {} zone{} your guild controls.", zones * (ZONE_BONUS / GOLD), zones, zones == 1 ? "" : "s"));
        }
        CharacterDatabaseTransaction trans = CharacterDatabase.BeginTransaction();
        (void)guild->ModifyBankMoney(trans, uint64(flightPoints) * INCOME_PER_POINT, true);
        CharacterDatabase.CommitTransaction(trans);
        ZeroCraftUpkeep::TellGuild(guild->GetId(), Acore::StringFormat(
            "Territory income: {} gold into the guild bank from the {} flight point{} your guild holds.",
            flightPoints * (INCOME_PER_POINT / GOLD), flightPoints, flightPoints == 1 ? "" : "s"));
    }
}

class ZeroCraftWarWorld : public WorldScript
{
public:
    ZeroCraftWarWorld() : WorldScript("ZeroCraftWarWorld") { }
    void OnUpdate(uint32 diff) override
    {
        timer += diff;
        if (timer < 5 * IN_MILLISECONDS)
            return;
        timer = 0;
        ZeroCraftWar::Refresh();
    }
private:
    uint32 timer = 0;
};

class ZeroCraftWarLogin : public PlayerScript
{
public:
    ZeroCraftWarLogin() : PlayerScript("ZeroCraftWarLogin") { }

    // walking into a zone another guild controls: its members hear about it (once per 5 minutes per intruder)
    void OnPlayerUpdateZone(Player* player, uint32 newZone, uint32 /*newArea*/) override
    {
        std::string owner = ZeroCraftWar::ZoneOwner(newZone);
        if (owner.empty())
            return;
        Guild* mine = sGuildMgr->GetGuildById(player->GetGuildId());
        if (mine && mine->GetName() == owner)
            return;
        uint64 key = (uint64(player->GetGUID().GetCounter()) << 32) | newZone;
        uint32 now = getMSTime();
        uint32& last = ZeroCraftWar::lastIntruder[key];
        if (last && getMSTimeDiff(last, now) < 5 * MINUTE * IN_MILLISECONDS)
            return;
        last = now;
        if (Guild* g = sGuildMgr->GetGuildByName(owner))
            ZeroCraftUpkeep::TellGuild(g->GetId(), Acore::StringFormat("Intruder: {} has entered your territory, {}.",
                ZeroCraftWar::Who(player), ZeroCraftWar::ZoneName(newZone)), true);
    }
    void OnPlayerLogin(Player* player) override
    {
        ObjectGuid g = player->GetGUID();
        player->m_Events.AddEventAtOffset([player, g]()
        {
            if (player->IsInWorld() && player->GetGUID() == g)
                ZeroCraftWar::SendNow(player);
        }, Seconds(4));
    }
};

class ZeroCraftDeployDeath : public UnitScript
{
public:
    ZeroCraftDeployDeath() : UnitScript("ZeroCraftDeployDeath") { }

    void OnUnitDeath(Unit* unit, Unit* killer) override
    {
        Creature* creature = unit ? unit->ToCreature() : nullptr;
        if (!creature)
            return;
        ObjectGuid::LowType spawnId = creature->GetSpawnId();
        if (!spawnId)
            return;
        if (!ZeroCraftDeploy::spawnFaction.count(spawnId))
        {
            // ZeroCraft: the old world is empty, so anything spawned out there was built by a player
            // (cows, critters, training dummies...). Those die for good too.
            if ((creature->GetMapId() == 0 || creature->GetMapId() == 1) && !creature->GetMap()->Instanceable())
            {
                WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM zerocraft_placed WHERE kind = 1 AND spawn_id = {}", spawnId));
                creature->SetRespawnDelay(0x7FFFFFFF);
                creature->DeleteFromDB();
                creature->m_Events.AddEventAtOffset([creature]()
                {
                    if (creature->IsInWorld())
                        creature->AddObjectToRemoveList();
                }, Seconds(60));
            }
            return;
        }

        ZeroCraftWar::Fallen(creature, killer);
        bool banker = creature->HasNpcFlag(UNIT_NPC_FLAG_BANKER);
        if (creature->GetEntry() == ZeroCraftDeploy::STONE_GUARD)
        {
            ZeroCraftBankHeist::Loot(creature, killer, true);
            if (ZeroCraftDeploy::StoneFallen)
                ZeroCraftDeploy::StoneFallen(creature, killer);
        }
        ZeroCraftVault::Remove(creature); // its "!" marker (Bankers and Flight Masters)
        if (banker)
            ZeroCraftBankHeist::Loot(creature, killer);

        ZeroCraftDeploy::spawnFaction.erase(spawnId);
        ZeroCraftTaxi::fmNode.erase(spawnId);
        ZeroCraftUpkeep::decay.erase(spawnId);
        WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM zerocraft_deployables WHERE spawn_id = {}", spawnId));

        creature->SetRespawnDelay(0x7FFFFFFF);
        creature->DeleteFromDB();   // spawn data + respawn timer gone: it can never come back

        // a looted bank vault stays around 10 minutes so the killers can empty it
        creature->m_Events.AddEventAtOffset([creature]()
        {
            if (creature->IsInWorld())
                creature->AddObjectToRemoveList();
        }, banker ? Seconds(600) : Seconds(60));
    }
};

// Deployed NPCs defend their owner (and their owner's guildmates) like a
// hunter pet on Defensive: anything that damages one of them within 15 yards (city-guard range)
// gets attacked by every nearby loyal NPC that isn't already fighting.
class ZeroCraftDeployDefend : public UnitScript
{
public:
    ZeroCraftDeployDefend() : UnitScript("ZeroCraftDeployDefend") { }

    void OnDamage(Unit* attacker, Unit* victim, uint32& /*damage*/) override
    {
        if (!attacker || !victim || attacker == victim || ZeroCraftDeploy::spawnFaction.empty())
            return;

        // Case 1: a deployed NPC is hurt -> its whole squad attacks the attacker.
        if (Creature* vc = victim->ToCreature())
        {
            auto it = ZeroCraftDeploy::spawnFaction.find(vc->GetSpawnId());
            if (it != ZeroCraftDeploy::spawnFaction.end() && attacker->IsAlive())
            {
                Rally(victim, it->second, 0, attacker);
                ZeroCraftWar::UnderAttack(vc, attacker);
            }
        }

        // Case 2: a deployed NPC hits something -> its squad joins that fight.
        if (Creature* ac = attacker->ToCreature())
        {
            auto it = ZeroCraftDeploy::spawnFaction.find(ac->GetSpawnId());
            if (it != ZeroCraftDeploy::spawnFaction.end() && victim->IsAlive())
                Rally(attacker, it->second, 0, victim);
        }

        // Case 3: the owner (or a guildmate) is hurt -> defend them.
        Player* owner = victim->ToPlayer();
        if (!owner || !attacker->IsAlive())
            return;
        if (Creature* ac = attacker->ToCreature())
            if (ZeroCraftDeploy::spawnFaction.count(ac->GetSpawnId()))
                return;
        uint32 slots[2] = { 0, 0 };
        auto it = ZeroCraftDeploy::ownerSlot.find(-int64(owner->GetGUID().GetCounter()));
        if (it != ZeroCraftDeploy::ownerSlot.end()) slots[0] = it->second;
        if (owner->GetGuildId())
        {
            auto g = ZeroCraftDeploy::ownerSlot.find(int64(owner->GetGuildId()));
            if (g != ZeroCraftDeploy::ownerSlot.end()) slots[1] = g->second;
        }
        if (slots[0] || slots[1])
            Rally(owner, slots[0], slots[1], attacker);
    }

    // Every idle loyal NPC of these slots within 40 yards of `center` attacks `enemy`.
    void Rally(Unit* center, uint32 slotA, uint32 slotB, Unit* enemy)
    {
        uint64 key = (uint64(center->GetGUID().GetCounter()) << 32) | enemy->GetGUID().GetCounter();
        uint32 now = getMSTime();
        uint32& last = lastRally[key];
        if (last && now - last < 1000)
            return;
        last = now;
        if (lastRally.size() > 5000)
            lastRally.clear();

        auto& store = center->GetMap()->GetCreatureBySpawnIdStore();
        for (auto const& pair : ZeroCraftDeploy::spawnFaction)
        {
            if (pair.second != slotA && (!slotB || pair.second != slotB))
                continue;
            if (enemy->GetFaction() == pair.second)
                continue;
            auto range = store.equal_range(pair.first);
            for (auto c = range.first; c != range.second; ++c)
            {
                Creature* npc = c->second;
                if (!npc || npc == enemy || !npc->IsInWorld() || !npc->IsAlive() || npc->GetVictim())
                    continue;
                if (npc->GetDistance(center) > 15.0f)   // like city guards: only those close by come to help
                    continue;
                if (npc->AI())
                    npc->AI()->AttackStart(enemy);
            }
        }
    }

private:
    std::unordered_map<uint64, uint32> lastRally;
};

// Deployed NPCs are hostile to literally everything except their owner and
// the owner's guild: players, monsters, neutral wildlife, critters, and other
// guilds' deployed NPCs. (Owner/guild friendliness comes from the forced
// reactions, which the core checks before this hook.)
class ZeroCraftDeployReaction : public UnitScript
{
public:
    ZeroCraftDeployReaction() : UnitScript("ZeroCraftDeployReaction") { }

    bool IfNormalReaction(Unit const* unit, Unit const* target, ReputationRank& repRank) override
    {
        if (!unit || !target)
            return true;
        // training dummies are for players only: guild NPCs ignore them
        auto dummy = [](Unit const* u) { if (Creature const* c = u->ToCreature()) { uint32 e = c->GetEntry(); return e == 31144 || e == 31146 || e == 32666 || e == 32667 || e == 31143; } return false; };
        if ((dummy(unit) && !target->GetAffectingPlayer()) || (dummy(target) && !unit->GetAffectingPlayer()))
        {
            repRank = REP_NEUTRAL;
            return false;
        }
        int64 ut = unit->IsCreature() ? ZeroCraftDeploy::TagOfCreature(unit->ToCreature()) : 0;
        int64 tt = target->IsCreature() ? ZeroCraftDeploy::TagOfCreature(target->ToCreature()) : 0;
        if (!ut && !tt)
            return true;                          // not our business - normal rules
        if (ut && tt)
        {
            repRank = ut == tt ? REP_FRIENDLY : REP_HOSTILE;
            return false;
        }
        int64 tag = ut ? ut : tt;
        Unit const* other = ut ? target : unit;
        Player const* p = other->GetAffectingPlayer(); // players, their pets and summons
        repRank = ZeroCraftDeploy::PlayerOwnsTag(p, tag) ? REP_FRIENDLY : REP_HOSTILE;
        return false;
    }
};

// ============================================================================
// ZeroCraft orders for deployed NPCs (available to every player):
//   .order follow  - your targeted NPC (or, with no/foreign target, all of your
//                    NPCs within 40 yards) starts following you
//   .order stay    - they stop where they are; that spot becomes their new
//                    permanent post (survives restarts)
// ============================================================================
using namespace Acore::ChatCommands;

class ZeroCraftOrders
{
public:
    static bool Owns(Player* player, Creature* c)
    {
        if (!c || !c->IsAlive())
            return false;
        auto it = ZeroCraftDeploy::spawnFaction.find(c->GetSpawnId());
        if (it == ZeroCraftDeploy::spawnFaction.end())
            return false;
        auto mine = ZeroCraftDeploy::ownerSlot.find(-int64(player->GetGUID().GetCounter()));
        if (mine != ZeroCraftDeploy::ownerSlot.end() && mine->second == it->second)
            return true;
        if (player->GetGuildId())
        {
            auto g = ZeroCraftDeploy::ownerSlot.find(int64(player->GetGuildId()));
            if (g != ZeroCraftDeploy::ownerSlot.end() && g->second == it->second)
                return true;
        }
        return false;
    }

    static std::vector<Creature*> Targets(ChatHandler* handler)
    {
        Player* player = handler->GetSession()->GetPlayer();
        std::vector<Creature*> out;
        Creature* sel = handler->getSelectedCreature();
        if (sel && Owns(player, sel))
        {
            out.push_back(sel);
            return out;
        }
        auto& store = player->GetMap()->GetCreatureBySpawnIdStore();
        for (auto const& pair : ZeroCraftDeploy::spawnFaction)
        {
            auto range = store.equal_range(pair.first);
            for (auto c = range.first; c != range.second; ++c)
                if (c->second && c->second->IsInWorld() && Owns(player, c->second) && c->second->GetDistance(player) <= 40.0f)
                    out.push_back(c->second);
        }
        return out;
    }

    static bool HandleFollow(ChatHandler* handler)
    {
        Player* player = handler->GetSession()->GetPlayer();
        auto list = Targets(handler);
        if (list.empty())
        {
            handler->SendSysMessage("None of your deployed NPCs are nearby.");
            return true;
        }
        float angle = 0.0f;
        for (Creature* c : list)
        {
            c->GetMotionMaster()->Clear();
            c->GetMotionMaster()->MoveFollow(player, 3.0f, M_PI / 2 + angle);
            angle += 0.6f;
        }
        handler->PSendSysMessage(Acore::StringFormat("{} NPC(s) now following you. Type .order stay to post them.", list.size()));
        return true;
    }

    static bool HandleStay(ChatHandler* handler)
    {
        auto list = Targets(handler);
        if (list.empty())
        {
            handler->SendSysMessage("None of your deployed NPCs are nearby.");
            return true;
        }
        for (Creature* c : list)
        {
            c->GetMotionMaster()->Clear();
            c->StopMoving();
            c->GetMotionMaster()->MoveIdle();
            c->SetHomePosition(c->GetPositionX(), c->GetPositionY(), c->GetPositionZ(), c->GetOrientation());

            CreatureData& data = sObjectMgr->NewOrExistCreatureData(c->GetSpawnId());
            data.posX = c->GetPositionX();
            data.posY = c->GetPositionY();
            data.posZ = c->GetPositionZ();
            data.orientation = c->GetOrientation();
            data.wander_distance = 0.0f;
            data.movementType = 0;
            WorldDatabase.DirectExecute(Acore::StringFormat(
                "UPDATE creature SET position_x = {}, position_y = {}, position_z = {}, orientation = {}, wander_distance = 0, MovementType = 0 WHERE guid = {}",
                c->GetPositionX(), c->GetPositionY(), c->GetPositionZ(), c->GetOrientation(), c->GetSpawnId()));
        }
        handler->PSendSysMessage(Acore::StringFormat("{} NPC(s) posted here.", list.size()));
        return true;
    }
};

// Command spell: point-and-click movement for deployed NPCs.
// Borrows "Meteor" (24340) purely for its instant, no-cooldown, no-GCD ground
// circle. The cast is always cancelled silently in CheckCast, so nothing ever
// fires, no cooldown starts, and it can be spammed.
namespace ZeroCraftCommand
{
    static const uint32 SPELL_COMMAND = 24340;
    static std::unordered_map<ObjectGuid::LowType, ObjectGuid> lastClicked;   // player -> last own NPC they talked to
    static void (*StopPatrol)(Creature*) = nullptr;                           // set by the NPC edit menu

    static void MoveTo(Player* player, WorldLocation const& dst, bool requireTarget)
    {
        ChatHandler chat(player->GetSession());
        // (the client never sends a map id with a ground target, so only check distance)
        // no distance limit

        std::vector<Creature*> list;
        if (requireTarget)
        {
            // Red banner: only the targeted NPC moves; no target = nobody moves.
            Creature* sel = ObjectAccessor::GetCreature(*player, player->GetTarget());
            if (!sel || !ZeroCraftOrders::Owns(player, sel))
            {
                // the target can get lost while clicking the ground: use the NPC you last talked to
                auto lc = lastClicked.find(player->GetGUID().GetCounter());
                Creature* last = lc != lastClicked.end() ? ObjectAccessor::GetCreature(*player, lc->second) : nullptr;
                if (!sel && last && ZeroCraftOrders::Owns(player, last))
                    sel = last;
                else
                {
                    ZeroCraftDeploy::RedError(player, sel ? sel->GetName() + " isn't one of your NPCs." : std::string("Target one of your NPCs first."));
                    return;
                }
            }
            list.push_back(sel);
        }
        else
        {
            // Blue banner: every owned NPC on this map moves, target ignored.
            auto& store = player->GetMap()->GetCreatureBySpawnIdStore();
            for (auto const& pair : ZeroCraftDeploy::spawnFaction)
            {
                auto range = store.equal_range(pair.first);
                for (auto c = range.first; c != range.second; ++c)
                    if (c->second && c->second->IsInWorld() && ZeroCraftOrders::Owns(player, c->second))
                        list.push_back(c->second);
            }
        }
        if (list.empty())
        {
            chat.SendSysMessage("You have no deployed NPCs in this zone.");
            return;
        }

        // Destination marker (like Click-to-Move's ground marker): a small
        // banner planted at the spot for 4 seconds. Replaces the previous one.
        {
            static std::unordered_map<ObjectGuid::LowType, ObjectGuid> lastMarker;
            ObjectGuid& prev = lastMarker[player->GetGUID().GetCounter()];
            if (GameObject* old = ObjectAccessor::GetGameObject(*player, prev))
                old->DespawnOrUnsummon();
            float mz = dst.GetPositionZ();
            player->UpdateGroundPositionZ(dst.GetPositionX(), dst.GetPositionY(), mz);
            if (GameObject* marker = player->SummonGameObject(188020, dst.GetPositionX(), dst.GetPositionY(), mz, player->GetOrientation(), 0, 0, 0, 0, 4))
                prev = marker->GetGUID();
        }

        float spread = list.size() > 1 ? 2.5f : 0.0f;
        for (size_t i = 0; i < list.size(); ++i)
        {
            Creature* c = list[i];
            float a = float(i) * 2.0f * float(M_PI) / float(list.size());
            float x = dst.GetPositionX() + spread * std::cos(a);
            float y = dst.GetPositionY() + spread * std::sin(a);
            float z = dst.GetPositionZ();
            c->UpdateGroundPositionZ(x, y, z);
            float o = c->GetAngle(x, y);

            c->SetHomePosition(x, y, z, o);
            CreatureData& data = sObjectMgr->NewOrExistCreatureData(c->GetSpawnId());
            data.posX = x; data.posY = y; data.posZ = z; data.orientation = o;
            data.wander_distance = 0.0f; data.movementType = 0;
            WorldDatabase.Execute(Acore::StringFormat(
                "UPDATE creature SET position_x = {}, position_y = {}, position_z = {}, orientation = {}, wander_distance = 0, MovementType = 0 WHERE guid = {}",
                x, y, z, o, c->GetSpawnId()));

            if (StopPatrol)
                StopPatrol(c);   // a new order beats the old patrol
            c->GetMotionMaster()->Clear();
            c->GetMotionMaster()->MovePoint(0, x, y, z);
        }
    }
}

// ============================================================================
// No ammo needed: InfiniteAmmo.Enabled = 1 in worldserver.conf stops ammo from
// being used up. Anyone with a bow, crossbow or gun also always carries one
// never-ending stack of the right ammo (Thorium) and has it slotted.
// ============================================================================
class ZeroCraftAmmo : public PlayerScript
{
public:
    ZeroCraftAmmo() : PlayerScript("ZeroCraftAmmo") { }

    static constexpr uint32 ARROW  = 18042; // Thorium Headed Arrow
    static constexpr uint32 BULLET = 15997; // Thorium Shells

    // Ammo is never used up (InfiniteAmmo), but the game still wants one arrow or bullet in the
    // ammo slot before a bow or gun will fire. Anyone with one always carries a single never-ending
    // arrow/bullet, slotted automatically. (The starter Worn Greatsword is cleared out.)
    static void Supply(Player* player)
    {
        static std::unordered_set<uint32> junk;
        static bool loaded = false;
        if (!loaded)
        {
            loaded = true;
            if (QueryResult r = WorldDatabase.Query("SELECT entry FROM item_template WHERE name = 'Worn Greatsword' OR entry = 60416"))
                do { junk.insert((*r)[0].Get<uint32>()); } while (r->NextRow());
        }
        for (uint32 id : junk)
            if (uint32 n = player->GetItemCount(id, true))
                player->DestroyItemCount(id, n, true, false);

        Item* ranged = player->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_RANGED);
        if (!ranged)
            return;
        uint32 ammo = 0;
        switch (ranged->GetTemplate()->SubClass)
        {
            case ITEM_SUBCLASS_WEAPON_BOW:
            case ITEM_SUBCLASS_WEAPON_CROSSBOW: ammo = ARROW;  break;
            case ITEM_SUBCLASS_WEAPON_GUN:      ammo = BULLET; break;
            default: return;   // wands and thrown weapons need no ammo
        }
        if (!player->HasItemCount(ammo, 1, false))
            player->AddItem(ammo, 1);
        if (player->GetUInt32Value(PLAYER_AMMO_ID) != ammo && player->HasItemCount(ammo, 1, false))
            player->SetAmmo(ammo);
    }

    void OnPlayerLogin(Player* player) override { Supply(player); }

    void OnPlayerEquip(Player* player, Item* /*it*/, uint8 bag, uint8 slot, bool /*update*/) override
    {
        if (bag != INVENTORY_SLOT_BAG_0 || slot != EQUIPMENT_SLOT_RANGED)
            return;
        ObjectGuid guid = player->GetGUID();
        player->m_Events.AddEventAtOffset([player, guid]()
        {
            if (player->IsInWorld() && player->GetGUID() == guid)
                Supply(player);
        }, Milliseconds(100));
    }
};

// ============================================================================
// Dungeon Finder: everyone is 60 and every dungeon is squished to 60, so every
// dungeon (and every "Random ..." option) is open to a level 60 player.
// ============================================================================
class ZeroCraftLFG : public WorldScript
{
public:
    ZeroCraftLFG() : WorldScript("ZeroCraftLFG") { }
    void OnStartup() override
    {
        // widen the level range on the Dungeon Finder data itself, then have
        // the Dungeon Finder reload from it
        uint32 n = 0;
        for (uint32 i = 0; i < sLFGDungeonStore.GetNumRows(); ++i)
            if (LFGDungeonEntry const* e = sLFGDungeonStore.LookupEntry(i))
            {
                auto* ee = const_cast<LFGDungeonEntry*>(e);
                ee->MinLevel = 1;
                ee->MaxLevel = DEFAULT_MAX_LEVEL;
                ++n;
            }
        // Only two queues: "Random Dungeon" (the Lich King random, 261) pulls from
        // every normal dungeon of every expansion, "Random Heroic" (262) from every heroic.
        LFGDungeonEntry const* rn = sLFGDungeonStore.LookupEntry(261);
        LFGDungeonEntry const* rh = sLFGDungeonStore.LookupEntry(262);
        if (rn && rh)
            for (uint32 i = 0; i < sLFGDungeonStore.GetNumRows(); ++i)
                if (LFGDungeonEntry const* e = sLFGDungeonStore.LookupEntry(i))
                {
                    if (e->TypeID == lfg::LFG_TYPE_RANDOM || e->TypeID == lfg::LFG_TYPE_RAID || (e->Flags & 0x4)) // 0x4 = holiday
                        continue;
                    MapEntry const* m = sMapStore.LookupEntry(e->MapID);
                    if (!m || m->IsRaid())
                        continue;
                    const_cast<LFGDungeonEntry*>(e)->GroupID = e->Difficulty ? rh->GroupID : rn->GroupID;
                }
        // reload=false on purpose: reload=true wipes the random-dungeon pools and never rebuilds them
        sLFGMgr->LoadLFGDungeons(false);
        LOG_INFO("module", "ZeroCraft: opened {} Dungeon Finder entries to every level", n);
    }
};

// ============================================================================
// World borders: Outland and Northrend are closed. On the Outland map (530)
// only the blood elf and draenei zones stay open. Dungeons and raids are
// separate maps, so the Dungeon Finder still sends you into TBC/Wrath dungeons.
// GMs (.gm on) are not blocked.
// ============================================================================
namespace ZeroCraftBorders
{
    static bool ZoneAllowed(uint32 mapId, uint32 zoneId)
    {
        if (mapId == 571) // Northrend
            return false;
        if (mapId != 530)  // everything else (Azeroth, dungeons, raids, battlegrounds)
            return true;
        switch (zoneId)
        {
            case 3430: // Eversong Woods
            case 3433: // Ghostlands
            case 3487: // Silvermoon City
            case 3524: // Azuremyst Isle
            case 3525: // Bloodmyst Isle
            case 3557: // The Exodar
                return true;
            default:
                return false;
        }
    }

    static WorldLocation Capital(Player* player)
    {
        if (player->GetTeamId(true) == TEAM_HORDE)
            return WorldLocation(1, 1629.36f, -4373.39f, 31.2564f, 3.54839f);   // Orgrimmar
        return WorldLocation(0, -8833.38f, 628.628f, 94.0066f, 1.06535f);       // Stormwind
    }

    static uint32 CapitalZone(Player* player) { return player->GetTeamId(true) == TEAM_HORDE ? 1637 : 1519; }

    static void SendHome(Player* player)
    {
        ZeroCraftDeploy::RedError(player, "Outland and Northrend are closed.");
        WorldLocation home = Capital(player);
        ObjectGuid guid = player->GetGUID();
        player->m_Events.AddEventAtOffset([player, guid, home]()
        {
            if (player->IsInWorld() && player->GetGUID() == guid)
                player->TeleportTo(home);
        }, Milliseconds(500));
    }
}

class ZeroCraftBordersPlayer : public PlayerScript
{
public:
    ZeroCraftBordersPlayer() : PlayerScript("ZeroCraftBordersPlayer") { }

    // block portals, hearthstones, summons and the Dark Portal before they happen
    bool OnPlayerBeforeTeleport(Player* player, uint32 mapid, float x, float y, float z, float /*o*/, uint32 /*options*/, Unit* /*target*/) override
    {
        if (!player || player->IsGameMaster() || (mapid != 530 && mapid != 571))
            return true;
        if (ZeroCraftBorders::ZoneAllowed(mapid, sMapMgr->GetZoneId(player->GetPhaseMask(), mapid, x, y, z)))
            return true;
        // walking out of a TBC/Wrath dungeon's exit portal: go to your capital instead
        if (player->GetMap() && player->GetMap()->Instanceable())
        {
            ZeroCraftBorders::SendHome(player);
            return false;
        }
        ZeroCraftDeploy::RedError(player, "Outland and Northrend are closed.");
        return false;
    }

    // anything that slips through (boats, zeppelins, logging in out there)
    void OnPlayerUpdateZone(Player* player, uint32 newZone, uint32 /*newArea*/) override
    {
        if (!player || player->IsGameMaster())
            return;
        if (!ZeroCraftBorders::ZoneAllowed(player->GetMapId(), newZone))
            ZeroCraftBorders::SendHome(player);
    }

    // a hearthstone set out there points home to your capital instead
    void OnPlayerLogin(Player* player) override
    {
        uint32 zone = sMapMgr->GetZoneId(player->GetPhaseMask(), player->m_homebindMapId,
                                         player->m_homebindX, player->m_homebindY, player->m_homebindZ);
        if (!ZeroCraftBorders::ZoneAllowed(player->m_homebindMapId, zone))
            player->SetHomebind(ZeroCraftBorders::Capital(player), ZeroCraftBorders::CapitalZone(player));
    }
};

// ============================================================================
// Founder's Charter: every player carries one. Use it, type a name, and you
// found a new guild (leaving your current one). Guild leaders of a guild with
// other members have to hand over leadership first.
// ============================================================================
namespace ZeroCraftCharter
{
    static uint32 ItemEntry()
    {
        static uint32 entry = 0;
        static bool looked = false;
        if (!looked)
        {
            looked = true;
            uint32 sid = sObjectMgr->GetScriptId("item_zerocraft_guild_charter");
            for (auto const& kv : *sObjectMgr->GetItemTemplateStore())
                if (kv.second.ScriptId == sid) { entry = kv.first; break; }
        }
        return entry;
    }
}

class ZeroCraftCharterItem : public ItemScript
{
public:
    ZeroCraftCharterItem() : ItemScript("item_zerocraft_guild_charter") { }

    bool OnUse(Player* player, Item* item, SpellCastTargets const& /*targets*/) override
    {
        ClearGossipMenuFor(player);
        AddGossipItemFor(player, GOSSIP_ICON_TABARD, "Found a new guild", GOSSIP_SENDER_MAIN, 1,
            "Type your new guild's name.\nYou will leave your current guild.", 0, true);
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
        return true; // never consumed, never casts
    }

    void OnGossipSelectCode(Player* player, Item* /*item*/, uint32 /*sender*/, uint32 /*action*/, char const* code) override
    {
        CloseGossipMenuFor(player);
        std::string name = code ? code : "";
        while (!name.empty() && name.back() == ' ') name.pop_back();
        while (!name.empty() && name.front() == ' ') name.erase(0, 1);

        if (name.empty() || name.size() > 24 || !ObjectMgr::IsValidCharterName(name))
        {
            ZeroCraftDeploy::RedError(player, "That guild name isn't allowed (letters and spaces, up to 24).");
            return;
        }
        if (sGuildMgr->GetGuildByName(name))
        {
            ZeroCraftDeploy::RedError(player, "A guild with that name already exists.");
            return;
        }

        if (uint32 oldId = player->GetGuildId())
            if (Guild* old = sGuildMgr->GetGuildById(oldId))
            {
                if (old->GetLeaderGUID() == player->GetGUID())
                {
                    if (old->GetMemberCount() > 1)
                    {
                        ZeroCraftDeploy::RedError(player, "Hand guild leadership to someone else first.");
                        return;
                    }
                    old->Disband();
                }
                else
                    old->DeleteMember(player->GetGUID(), false, false);
            }

        Guild* guild = new Guild;
        if (!guild->Create(player, name))
        {
            delete guild;
            ZeroCraftDeploy::RedError(player, "Could not found the guild.");
            return;
        }
        sGuildMgr->AddGuild(guild);
        ZeroCraftTabard::RandomEmblem(guild, player);
        ZeroCraftTabard::Wear(player);
        ChatHandler(player->GetSession()).PSendSysMessage(Acore::StringFormat("You founded <{}>. Guildmates are your allies - everyone else is fair game.", name));
    }
};

class ZeroCraftCharterGiver : public PlayerScript
{
public:
    ZeroCraftCharterGiver() : PlayerScript("ZeroCraftCharterGiver") { }
    // ZeroCraft: the Founder's Charter is no longer handed out - it drops from dungeon and raid bosses.
    void OnPlayerLogin(Player* /*player*/) override { }
};

// ============================================================================
// No Death Knights - for everyone, GM accounts included (the server's own
// CharacterCreating.Disabled.ClassMask setting skips GM accounts).
// ============================================================================
class ZeroCraftNoDeathKnights : public ServerScript
{
public:
    ZeroCraftNoDeathKnights() : ServerScript("ZeroCraftNoDeathKnights") { }

    bool CanPacketReceive(WorldSession* session, WorldPacket const& packet) override
    {
        if (!session || packet.GetOpcode() != CMSG_CHAR_CREATE)
            return true;
        size_t pos = 0;
        while (pos < packet.size() && packet.contents()[pos] != 0) ++pos;  // name
        if (pos + 2 >= packet.size())
            return true;
        uint8 cls = packet.contents()[pos + 2];                             // skip '\0' and race
        if (cls != CLASS_DEATH_KNIGHT)
            return true;
        WorldPacket data(SMSG_CHAR_CREATE, 1);
        data << uint8(CHAR_CREATE_UNIQUE_CLASS_LIMIT); // closest built-in text about Death Knights
        session->SendPacket(&data);
        return false;
    }
};

// Upkeep clock: every minute, charge guilds whose hour is up and let unpaid
// guilds' NPCs decay a little more.
class ZeroCraftUpkeepWorld : public WorldScript
{
public:
    ZeroCraftUpkeepWorld() : WorldScript("ZeroCraftUpkeepWorld") { }

    void OnStartup() override
    {
        if (QueryResult r = WorldDatabase.Query("SELECT spawn_id, decay FROM zerocraft_deployables WHERE decay > 0"))
            do { ZeroCraftUpkeep::decay[(*r)[0].Get<uint32>()] = (*r)[1].Get<float>(); } while (r->NextRow());
    }

    void OnUpdate(uint32 diff) override
    {
        timer += diff;
        if (timer < 60 * IN_MILLISECONDS)
            return;
        timer = 0;
        Tick();
    }

private:
    uint32 timer = 0;

    struct Npc { uint32 spawnId; uint32 entry; uint32 map; };

    static void Tick()
    {
        std::unordered_map<uint32, std::vector<Npc>> byGuild;
        if (QueryResult r = WorldDatabase.Query("SELECT d.spawn_id, d.owner_guild, d.entry, c.map FROM zerocraft_deployables d JOIN creature c ON c.guid = d.spawn_id WHERE d.owner_guild > 0 AND d.entry <> 911130"))
            do
            {
                Field* f = r->Fetch();
                byGuild[f[1].Get<uint32>()].push_back({ f[0].Get<uint32>(), f[2].Get<uint32>(), f[3].Get<uint32>() });
            } while (r->NextRow());

        time_t now = GameTime::GetGameTime().count();
        for (auto& kv : byGuild)
        {
            uint32 guildId = kv.first;
            Guild* guild = sGuildMgr->GetGuildById(guildId);
            uint32 cost = 0;
            for (Npc const& n : kv.second)
                cost += ZeroCraftUpkeep::CostOf(n.entry);

            time_t lastPaid = now; bool unpaid = false; bool known = false;
            if (QueryResult u = WorldDatabase.Query(Acore::StringFormat("SELECT last_paid, unpaid FROM zerocraft_upkeep WHERE guild_id = {}", guildId)))
            {
                known = true;
                lastPaid = time_t((*u)[0].Get<uint32>());
                unpaid = (*u)[1].Get<uint8>() != 0;
            }
            if (!known)
            {
                WorldDatabase.DirectExecute(Acore::StringFormat("REPLACE INTO zerocraft_upkeep (guild_id, last_paid, unpaid) VALUES ({}, {}, 0)", guildId, uint32(now)));
                continue; // first hour is free
            }

            bool due = unpaid || now - lastPaid >= 3600;
            if (due && guild && !unpaid)
            {
                uint32 points = 0;
                for (Npc const& n : kv.second)
                    if (CreatureTemplate const* ct = sObjectMgr->GetCreatureTemplate(n.entry))
                        if (ct->npcflag & UNIT_NPC_FLAG_FLIGHTMASTER)
                            ++points;
                ZeroCraftWar::PayIncome(guild, points);
            }
            if (due && guild)
            {
                if (guild->GetTotalBankMoney() >= cost)
                {
                    CharacterDatabaseTransaction trans = CharacterDatabase.BeginTransaction();
                    (void)guild->ModifyBankMoney(trans, cost, false);
                    CharacterDatabase.CommitTransaction(trans);
                    WorldDatabase.DirectExecute(Acore::StringFormat("REPLACE INTO zerocraft_upkeep (guild_id, last_paid, unpaid) VALUES ({}, {}, 0)", guildId, uint32(now)));
                    WorldDatabase.DirectExecute(Acore::StringFormat("UPDATE zerocraft_deployables SET decay = 0 WHERE owner_guild = {}", guildId));
                    for (Npc const& n : kv.second)
                        ZeroCraftUpkeep::decay.erase(n.spawnId);
                    ZeroCraftUpkeep::TellGuild(guildId, Acore::StringFormat("NPC upkeep paid from the guild bank: {}g {}s for {} NPCs.",
                        cost / GOLD, (cost % GOLD) / SILVER, kv.second.size()));
                    unpaid = false;
                }
                else
                {
                    if (!unpaid)
                        ZeroCraftUpkeep::TellGuild(guildId, Acore::StringFormat("The guild bank can't pay NPC upkeep ({}g {}s per hour). Our NPCs are decaying - deposit gold to stop it!",
                            cost / GOLD, (cost % GOLD) / SILVER), true);
                    WorldDatabase.DirectExecute(Acore::StringFormat("REPLACE INTO zerocraft_upkeep (guild_id, last_paid, unpaid) VALUES ({}, {}, 1)", guildId, uint32(now)));
                    unpaid = true;
                }
            }

            // ZeroCraft: the guild is gone (disbanded, or every member deleted) and nobody re-founded it:
            // there is no bank to pay from, so its NPCs decay like any unpaid army.
            if (!guild)
                unpaid = true;

            if (!unpaid)
                continue;

            // decay: 25% of health per hour, a sixtieth of that each minute
            for (Npc const& n : kv.second)
            {
                float& d = ZeroCraftUpkeep::decay[n.spawnId];
                d = std::min(1.0f, d + 0.25f / 60.0f);
                WorldDatabase.DirectExecute(Acore::StringFormat("UPDATE zerocraft_deployables SET decay = {} WHERE spawn_id = {}", d, n.spawnId));
                if (d < 1.0f)
                    continue;
                // fully decayed and nobody nearby to see it (grid not loaded): gone for good
                Map* map = sMapMgr->FindBaseMap(n.map);
                bool loaded = false;
                if (map)
                {
                    auto range = map->GetCreatureBySpawnIdStore().equal_range(n.spawnId);
                    loaded = range.first != range.second;
                }
                if (!loaded)
                {
                    if (CreatureData const* data = sObjectMgr->GetCreatureData(n.spawnId))
                        sObjectMgr->RemoveCreatureFromGrid(n.spawnId, data);
                    sObjectMgr->DeleteCreatureData(n.spawnId);
                    ZeroCraftDeploy::spawnFaction.erase(n.spawnId);
                    ZeroCraftTaxi::fmNode.erase(n.spawnId);
                    ZeroCraftUpkeep::decay.erase(n.spawnId);
                    WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM creature WHERE guid = {}", n.spawnId));
                    WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM zerocraft_deployables WHERE spawn_id = {}", n.spawnId));
                }
            }
        }
    }
};

// At login: how much your guild's NPCs cost per hour, and what's in the bank.
class ZeroCraftUpkeepLogin : public PlayerScript
{
public:
    ZeroCraftUpkeepLogin() : PlayerScript("ZeroCraftUpkeepLogin") { }
    void OnPlayerLogin(Player* player) override
    {
        uint32 guildId = player->GetGuildId();
        Guild* guild = guildId ? sGuildMgr->GetGuildById(guildId) : nullptr;
        if (!guild)
            return;
        uint32 cost = 0, count = 0;
        if (QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT entry FROM zerocraft_deployables WHERE owner_guild = {}", guildId)))
            do { cost += ZeroCraftUpkeep::CostOf((*r)[0].Get<uint32>()); ++count; } while (r->NextRow());
        uint64 bank = guild->GetTotalBankMoney();
        std::string msg = Acore::StringFormat("NPC upkeep for <{}>: {}g {}s per hour for {} NPCs. Guild bank: {}g{}.",
            guild->GetName(), cost / GOLD, (cost % GOLD) / SILVER, count, bank / GOLD,
            (cost && bank < cost) ? " - NOT ENOUGH, your NPCs are decaying!" : (cost ? Acore::StringFormat(" (about {} hours)", bank / cost) : std::string()));
        ChatHandler(player->GetSession()).SendSysMessage(msg);
    }
};

// Deployed Bankers are your guild's treasury: talk to one to open your own
// bank, deposit gold into the guild bank (which pays NPC upkeep), or check
// the balance.
static const uint32 ZeroCraftNpcEdit_SENDER = 9110;

class ZeroCraftBankerGossip : public AllCreatureScript
{
public:
    ZeroCraftBankerGossip() : AllCreatureScript("ZeroCraftBankerGossip") { }

    static bool MyBanker(Player* player, Creature* c)
    {
        return c && c->GetSpawnId() && c->HasNpcFlag(UNIT_NPC_FLAG_BANKER) &&
               ZeroCraftDeploy::spawnFaction.count(c->GetSpawnId()) && ZeroCraftOrders::Owns(player, c);
    }

    static uint32 UpkeepOf(uint32 guildId)
    {
        uint32 cost = 0;
        if (QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT entry FROM zerocraft_deployables WHERE owner_guild = {}", guildId)))
            do { cost += ZeroCraftUpkeep::CostOf((*r)[0].Get<uint32>()); } while (r->NextRow());
        return cost;
    }

    // put the vault beside every deployed Banker (also after restarts and moves)
    // Bankers and Flight Masters get a blue "!" over their heads
    static bool Marked(Creature* c)
    {
        return c && c->GetSpawnId() && ZeroCraftDeploy::spawnFaction.count(c->GetSpawnId()) &&
               (c->HasNpcFlag(UNIT_NPC_FLAG_BANKER) || c->HasNpcFlag(UNIT_NPC_FLAG_FLIGHTMASTER));
    }

    void OnCreatureAddWorld(Creature* c) override
    {
        if (!Marked(c))
            return;
        ObjectGuid guid = c->GetGUID();
        c->m_Events.AddEventAtOffset([c, guid]()
        {
            if (c->IsInWorld() && c->IsAlive() && c->GetGUID() == guid)
                ZeroCraftVault::Place(c);
        }, Milliseconds(2000));
    }

    // Deployed Bankers talk (gossip) instead of opening the bank straight away,
    // and keep their blue "!" over their head
    void OnAllCreatureUpdate(Creature* c, uint32 /*diff*/) override
    {
        if (!Marked(c))
            return;
        if (c->HasNpcFlag(UNIT_NPC_FLAG_BANKER) && !c->HasNpcFlag(UNIT_NPC_FLAG_GOSSIP))
            c->SetNpcFlag(UNIT_NPC_FLAG_GOSSIP);
        ZeroCraftVault::Follow(c);
    }

    // The NPC is leaving the world (its area unloads, a restart...): just forget
    // its marker. Touching the marker here can crash, because it may be getting
    // unloaded at the same moment; it's a temporary summon and goes with the area.
    void OnCreatureRemoveWorld(Creature* c) override
    {
        if (!c || !c->GetSpawnId())
            return;
        auto m = ZeroCraftVault::bankerMarker.find(c->GetSpawnId());
        if (m != ZeroCraftVault::bankerMarker.end())
        {
            ZeroCraftVault::markerGuild.erase(m->second);
            ZeroCraftVault::bankerMarker.erase(m);
        }
    }

    static const uint32 TEXT_GREET   = 911200;
    static const uint32 TEXT_COFFERS = 911201;
    static const uint32 TEXT_ARMY    = 911202;
    static const uint32 TEXT_THANKS  = 911203;
    static const uint32 TEXT_BROKE   = 911204;

    enum Actions { A_BANK = 1, A_COFFERS, A_ARMY, A_DEP100, A_DEP500, A_DEP1000, A_DEPANY, A_BACK, A_BYE, A_VAULT };

    static void Main(Player* player, Creature* c)
    {
        ClearGossipMenuFor(player);
        Guild* g = sGuildMgr->GetGuildById(player->GetGuildId());
        uint32 cost = g ? UpkeepOf(g->GetId()) : 0;
        bool broke = g && cost && g->GetTotalBankMoney() < cost;
        (void)broke;
        AddGossipItemFor(player, GOSSIP_ICON_INTERACT_1, "Open my personal bank.", GOSSIP_SENDER_MAIN, A_BANK);
        AddGossipItemFor(player, GOSSIP_ICON_INTERACT_1, "Open my Guild Vault.", GOSSIP_SENDER_MAIN, A_VAULT);
        AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Move, turn or place him", ZeroCraftNpcEdit_SENDER, 6 /*A_MAIN*/);
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, c->GetGUID());
    }

    static void Deposit(Player* player, Creature* c, uint32 gold)
    {
        Guild* g = sGuildMgr->GetGuildById(player->GetGuildId());
        if (!g || !gold)
            return;
        uint64 copper = uint64(gold) * GOLD;
        if (copper > 0x7FFFFFFF || !player->HasEnoughMoney(uint32(copper)))
        {
            ZeroCraftDeploy::RedError(player, "You don't have that much gold.");
            c->Say("Your purse is lighter than your promises, friend.", LANG_UNIVERSAL, player);
            return;
        }
        g->HandleMemberDepositMoney(player->GetSession(), uint32(copper));
        uint32 cost = UpkeepOf(g->GetId());
        uint64 hours = cost ? g->GetTotalBankMoney() / cost : 0;
        c->Say(cost
            ? Acore::StringFormat("{} gold, counted and locked away. That keeps <{}> paid for about {} more hours, {}.", gold, g->GetName(), hours, player->GetName())
            : Acore::StringFormat("{} gold, counted and locked away. The coffers of <{}> thank you, {}.", gold, g->GetName(), player->GetName()),
            LANG_UNIVERSAL, player);
        ClearGossipMenuFor(player);
        AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Back.", GOSSIP_SENDER_MAIN, A_BACK);
        SendGossipMenuFor(player, TEXT_THANKS, c->GetGUID());
    }

    bool CanCreatureGossipHello(Player* player, Creature* c) override
    {
        if (!MyBanker(player, c))
            return false;
        Main(player, c);
        return true;
    }

    bool CanCreatureGossipSelect(Player* player, Creature* c, uint32 sender, uint32 action) override
    {
        if (!MyBanker(player, c) || sender == ZeroCraftNpcEdit_SENDER)
            return false;
        Guild* g = sGuildMgr->GetGuildById(player->GetGuildId());
        switch (action)
        {
            case A_BANK:
                CloseGossipMenuFor(player);
                player->GetSession()->SendShowBank(c->GetGUID());
                break;
            case A_VAULT:
            {
                // The game only opens the guild bank window from a vault chest, so
                // the Banker sets his strongbox down at your feet for 2 minutes.
                CloseGossipMenuFor(player);
                if (!g)
                    break;
                float o = player->GetOrientation();
                float x = player->GetPositionX() + 1.5f * std::cos(o);
                float y = player->GetPositionY() + 1.5f * std::sin(o);
                float z = player->GetPositionZ();
                player->UpdateGroundPositionZ(x, y, z);
                if (GameObject* go = c->SummonGameObject(ZeroCraftVault::VAULT_ENTRY, x, y, z, o + float(M_PI), 0, 0, 0, 0, 120))
                {
                    ZeroCraftVault::vaultGuild[go->GetGUID()] = g->GetId();
                    c->Say("Here's the strongbox - right at your feet. Click it. I'll take it back in two minutes.", LANG_UNIVERSAL, player);
                }
                break;
            }
            case A_COFFERS:
            {
                ClearGossipMenuFor(player);
                uint32 cost = g ? UpkeepOf(g->GetId()) : 0;
                uint64 bank = g ? g->GetTotalBankMoney() : 0;
                uint32 npcs = 0;
                if (g)
                    if (QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT COUNT(*) FROM zerocraft_deployables WHERE owner_guild = {}", g->GetId())))
                        npcs = uint32((*r)[0].Get<uint64>());
                AddGossipItemFor(player, GOSSIP_ICON_MONEY_BAG, Acore::StringFormat("In the coffers: {} gold", bank / GOLD), GOSSIP_SENDER_MAIN, A_COFFERS);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, Acore::StringFormat("On the payroll: {} soldiers and servants", npcs), GOSSIP_SENDER_MAIN, A_COFFERS);
                AddGossipItemFor(player, GOSSIP_ICON_TRAINER, Acore::StringFormat("Wages: {}g {}s every hour", cost / GOLD, (cost % GOLD) / SILVER), GOSSIP_SENDER_MAIN, A_COFFERS);
                AddGossipItemFor(player, GOSSIP_ICON_TAXI, cost ? Acore::StringFormat("That lasts about {} hours", bank / cost) : std::string("Nobody to pay yet"), GOSSIP_SENDER_MAIN, A_COFFERS);
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Back.", GOSSIP_SENDER_MAIN, A_BACK);
                SendGossipMenuFor(player, TEXT_COFFERS, c->GetGUID());
                break;
            }
            case A_ARMY:
                ClearGossipMenuFor(player);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "Heroes and villains: 5 gold an hour each", GOSSIP_SENDER_MAIN, A_ARMY);
                AddGossipItemFor(player, GOSSIP_ICON_TAXI, "Flight Masters and Bankers: 2 gold an hour", GOSSIP_SENDER_MAIN, A_ARMY);
                AddGossipItemFor(player, GOSSIP_ICON_VENDOR, "Vendors, innkeepers, auctioneers, smiths: 1 gold", GOSSIP_SENDER_MAIN, A_ARMY);
                AddGossipItemFor(player, GOSSIP_ICON_TRAINER, "Guards: 50 silver an hour", GOSSIP_SENDER_MAIN, A_ARMY);
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Back.", GOSSIP_SENDER_MAIN, A_BACK);
                SendGossipMenuFor(player, TEXT_ARMY, c->GetGUID());
                break;
            case A_DEP100:  Deposit(player, c, 100);  break;
            case A_DEP500:  Deposit(player, c, 500);  break;
            case A_DEP1000: Deposit(player, c, 1000); break;
            case A_BACK:    Main(player, c); break;
            default:
                c->Say("Mind the coin, and the coin minds you.", LANG_UNIVERSAL, player);
                CloseGossipMenuFor(player);
                break;
        }
        return true;
    }

    bool CanCreatureGossipSelectCode(Player* player, Creature* c, uint32 /*sender*/, uint32 action, char const* code) override
    {
        if (!MyBanker(player, c) || action != A_DEPANY)
            return false;
        uint32 gold = code ? uint32(std::strtoul(code, nullptr, 10)) : 0;
        if (!gold)
        {
            ZeroCraftDeploy::RedError(player, "Type how many gold to deposit, e.g. 250.");
            CloseGossipMenuFor(player);
            return true;
        }
        Deposit(player, c, gold);
        return true;
    }
};

// New characters earn no achievements (their "already won" exalted reps and
// titles would otherwise unlock a flood of them at once).
class ZeroCraftNoStartAchievements : public PlayerScript
{
public:
    ZeroCraftNoStartAchievements() : PlayerScript("ZeroCraftNoStartAchievements") { }
    bool OnPlayerBeforeAchievementComplete(Player* player, AchievementEntry const* /*achievement*/) override
    {
        return !player || player->GetTotalPlayedTime() >= 600;
    }
};

// ============================================================================
// Recall Orders: target one of your deployed NPCs and use it - the NPC packs
// up into its scroll (Hero, Guard, Banker...). Deploying that kind of scroll
// again brings back the very same NPC. Can't be used on an NPC in combat.
// ============================================================================
class ZeroCraftRecallItem : public ItemScript
{
public:
    ZeroCraftRecallItem() : ItemScript("item_zerocraft_recall") { }

    static uint32 ScrollFor(Creature* c)
    {
        if (ZeroCraftPool::Entry const* pe = ZeroCraftPool::Of(c->GetEntry()))
            return pe->item;
        static std::unordered_set<uint32> heroes;
        static bool loaded = false;
        if (!loaded)
        {
            loaded = true;
            if (QueryResult r = WorldDatabase.Query("SELECT entry FROM zerocraft_hero_pool"))
                do { heroes.insert((*r)[0].Get<uint32>()); } while (r->NextRow());
        }
        if (heroes.count(c->GetEntry()))                       return ZeroCraftDeploy::ITEM_DEPLOY_HERO;
        if (c->HasNpcFlag(UNIT_NPC_FLAG_FLIGHTMASTER))          return ZeroCraftDeploy::ITEM_DEPLOY_FLIGHT;
        if (c->HasNpcFlag(UNIT_NPC_FLAG_BANKER))                return ZeroCraftDeploy::ITEM_DEPLOY_BANKER;
        if (c->HasNpcFlag(UNIT_NPC_FLAG_AUCTIONEER))            return ZeroCraftDeploy::ITEM_DEPLOY_AUCTIONEER;
        if (c->HasNpcFlag(UNIT_NPC_FLAG_INNKEEPER))             return ZeroCraftDeploy::ITEM_DEPLOY_INNKEEPER;
        if (c->HasNpcFlag(UNIT_NPC_FLAG_REPAIR))                return ZeroCraftDeploy::ITEM_DEPLOY_REPAIR;
        if (c->HasNpcFlag(UNIT_NPC_FLAG_VENDOR_MASK))           return ZeroCraftDeploy::ITEM_DEPLOY_VENDOR;
        return ZeroCraftDeploy::ITEM_DEPLOY_GUARD;
    }

    bool OnUse(Player* player, Item* /*item*/, SpellCastTargets const& /*targets*/) override
    {
        Creature* c = ObjectAccessor::GetCreature(*player, player->GetTarget());
        // your own Training Dummy: packs back into its item (then place it somewhere else)
        if (c && c->GetEntry() == 31144 && c->GetSpawnId())
        {
            QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT owner_guild, owner_player FROM zerocraft_placed WHERE kind = 1 AND spawn_id = {}", c->GetSpawnId()));
            bool mine = r && (((*r)[0].Get<uint32>() && (*r)[0].Get<uint32>() == player->GetGuildId()) || (*r)[1].Get<uint32>() == player->GetGUID().GetCounter());
            if (!mine)
            {
                ZeroCraftDeploy::RedError(player, "That Training Dummy isn't yours.");
                return true;
            }
            if (player->GetDistance(c) > 30.0f)
            {
                ZeroCraftDeploy::RedError(player, "Get closer to the Training Dummy.");
                return true;
            }
            ObjectGuid::LowType id = c->GetSpawnId();
            c->CombatStop(true);
            c->AddObjectToRemoveList();
            if (CreatureData const* d = sObjectMgr->GetCreatureData(id))
                sObjectMgr->RemoveCreatureFromGrid(id, d);
            sObjectMgr->DeleteCreatureData(id);
            WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM creature WHERE guid = {}", id));
            WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM zerocraft_placed WHERE kind = 1 AND spawn_id = {}", id));
            player->AddItem(60408, 1);
            ChatHandler(player->GetSession()).SendSysMessage("Training Dummy packed up. Use it again to set it up somewhere else.");
            return true;
        }
        if (!c || !c->GetSpawnId() || !ZeroCraftDeploy::spawnFaction.count(c->GetSpawnId()) || !ZeroCraftOrders::Owns(player, c))
        {
            ZeroCraftDeploy::RedError(player, "Target one of your NPCs first.");
            return true;
        }
        if (c->GetEntry() == ZeroCraftDeploy::STONE_GUARD)
        {
            ZeroCraftDeploy::RedError(player, "Pick up the Summoning Stone itself instead.");
            return true;
        }
        if (!c->IsAlive() || c->IsInCombat())
        {
            ZeroCraftDeploy::RedError(player, "That NPC can't pack up while fighting.");
            return true;
        }
        if (player->GetDistance(c) > 30.0f)
        {
            ZeroCraftDeploy::RedError(player, "Get closer to that NPC.");
            return true;
        }

        Pack(player, c);
        return true;
    }

    // packs one of your NPCs back into its scroll - it keeps the health it had
    static bool Pack(Player* player, Creature* c, bool toScroll = true)
    {
        uint32 scroll = ScrollFor(c);
        ItemPosCountVec dest;
        if (toScroll && player->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, scroll, 1) != EQUIP_ERR_OK)
        {
            ZeroCraftDeploy::RedError(player, "Your bags are full.");
            return false;
        }
        float hp = c->GetMaxHealth() ? float(c->GetHealth()) / float(c->GetMaxHealth()) : 1.0f;

        ObjectGuid::LowType spawnId = c->GetSpawnId();
        std::string name = c->GetName();
        uint32 entry = c->GetEntry();

        // gone from the world, the same way a death removes it (minus the loot)
        ZeroCraftVault::Remove(c);
        ZeroCraftDeploy::spawnFaction.erase(spawnId);
        ZeroCraftTaxi::fmNode.erase(spawnId);
        ZeroCraftUpkeep::decay.erase(spawnId);
        WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM zerocraft_deployables WHERE spawn_id = {}", spawnId));
        c->SetRespawnDelay(0x7FFFFFFF);
        c->DeleteFromDB();
        c->AddObjectToRemoveList();

        if (toScroll)
        {
            player->StoreNewItem(dest, scroll, true);
            CharacterDatabase.DirectExecute(Acore::StringFormat(
                "INSERT INTO zerocraft_packed (player_guid, scroll_entry, entry, health) VALUES ({}, {}, {}, {})",
                player->GetGUID().GetCounter(), scroll, entry, hp));
            ChatHandler(player->GetSession()).PSendSysMessage(Acore::StringFormat(
                "{} packed up into a scroll ({}% health). Deploy that scroll again to bring {} back.", name, int32(hp * 100.0f + 0.5f), name));
        }
        else
            ChatHandler(player->GetSession()).PSendSysMessage(Acore::StringFormat("{} is gone for good.", name));
        ZeroCraftTaxi::Apply(player);
        return true;
    }
};

class ZeroCraftRecallGiver : public PlayerScript
{
public:
    ZeroCraftRecallGiver() : PlayerScript("ZeroCraftRecallGiver") { }
    void OnPlayerLogin(Player* player) override
    {
        static uint32 entry = 0;
        static bool looked = false;
        if (!looked)
        {
            looked = true;
            uint32 sid = sObjectMgr->GetScriptId("item_zerocraft_recall");
            for (auto const& kv : *sObjectMgr->GetItemTemplateStore())
                if (kv.second.ScriptId == sid) { entry = kv.first; break; }
        }
        if (entry && !player->HasItemCount(entry, 1, true))
            player->AddItem(entry, 1);
    }
};

// The "!" over a Guild Vault: blue for the guild that owns it, nothing for anyone else.
class npc_zerocraft_vault_marker : public CreatureScript
{
public:
    npc_zerocraft_vault_marker() : CreatureScript("npc_zerocraft_vault_marker") { }
    uint32 GetDialogStatus(Player* player, Creature* creature) override
    {
        auto itr = ZeroCraftVault::markerGuild.find(creature->GetGUID());
        if (itr != ZeroCraftVault::markerGuild.end() && player->GetGuildId() == itr->second)
            return DIALOG_STATUS_AVAILABLE_REP;
        return DIALOG_STATUS_NONE;
    }
    bool OnGossipHello(Player* /*player*/, Creature* /*creature*/) override { return true; }
};

// ============================================================================
// Free talents: right-click takes a point back, builds apply in one click,
// nothing ever costs anything. The ZeroCraft addon talks to this over a
// hidden addon message "ZCT<tab>del:<talentId>" / "build:<n>" / "reset".
// ============================================================================
namespace ZeroCraftTalents
{
    // 51-point vanilla-style builds: the WoWSims WotLK presets cut down to 51 points
    // with a vanilla split (about 31 in the main tree, up to 20 in the others).
    // Order per class must match the ZeroCraft addon's build menu.
    static std::vector<std::string> const& Builds(uint8 cls)
    {
        static std::map<uint8, std::vector<std::string>> b = {
            { CLASS_WARRIOR, { "3022032023335100102012-305-2033", "32002301233-3050530005203100401", "2500030023-302-053351225000012101" } },
            { CLASS_PALADIN, { "503501510200130401-50023131203", "-050051352001323111-511302012003", "050501-05-052320512033303021", "03-453201002-052220512033302001" } },
            { CLASS_HUNTER, { "512002015051122421-025305101", "502-0253351010300132311-5000032", "-005305101-50000325000333305301" } },
            { CLASS_ROGUE, { "0053031043521003001-005005003-502", "00532010414-02520510000350151001", "00532010414-02520510500350101001", "30532010114--50220120303211213201" } },
            { CLASS_PRIEST, { "05032031303005123011-2351010303", "05032031103-2340510320021523", "05032031--3250230512230103221", "05032031303--3250230012230101231" } },
            { CLASS_SHAMAN, { "0533001523213351-005050031", "053030152-305050031050013310011", "-3020503-500053313352105011", "-30205033-050053313340105011" } },
            { CLASS_MAGE, { "2300051331003301503201-03-023303001", "23000503110003-00550300123033310301", "23000503110003--053303031023310003012" } },
            { CLASS_WARLOCK, { "2350002030023510252--550000051", "-2032033010350125301-550000052", "-03310030003-0520320521033105132" } },
            { CLASS_DRUID, { "510222311533130321--205003012", "-5432021323220100401-203503012", "05320031103--230023312131502311", "05320001--23002331233150253101" } },
        };
        static std::vector<std::string> none;
        auto itr = b.find(cls);
        return itr == b.end() ? none : itr->second;
    }

    using Ranks = std::map<uint32, uint32>; // talentId -> ranks learned

    static std::vector<TalentTabEntry const*> Tabs(Player* player)
    {
        std::vector<TalentTabEntry const*> tabs;
        for (uint32 i = 0; i < sTalentTabStore.GetNumRows(); ++i)
            if (TalentTabEntry const* t = sTalentTabStore.LookupEntry(i))
                if (t->ClassMask & player->getClassMask())
                    tabs.push_back(t);
        std::sort(tabs.begin(), tabs.end(), [](TalentTabEntry const* a, TalentTabEntry const* b) { return a->tabpage < b->tabpage; });
        return tabs;
    }

    static std::vector<TalentEntry const*> TalentsOf(uint32 tabId)
    {
        std::vector<TalentEntry const*> v;
        for (uint32 i = 0; i < sTalentStore.GetNumRows(); ++i)
            if (TalentEntry const* t = sTalentStore.LookupEntry(i))
                if (t->TalentTab == tabId)
                    v.push_back(t);
        std::sort(v.begin(), v.end(), [](TalentEntry const* a, TalentEntry const* b)
            { return a->Row != b->Row ? a->Row < b->Row : a->Col < b->Col; });
        return v;
    }

    static uint32 MaxRank(TalentEntry const* t)
    {
        uint32 m = 0;
        for (uint8 r = 0; r < MAX_TALENT_RANK; ++r)
            if (t->RankID[r]) m = r + 1;
        return m;
    }

    static Ranks Current(Player* player)
    {
        Ranks cur;
        for (auto const& kv : player->GetTalentMap())
        {
            if (kv.second->State == PLAYERSPELL_REMOVED || !kv.second->IsInSpec(player->GetActiveSpec()))
                continue;
            if (TalentSpellPos const* pos = GetTalentSpellPos(kv.first))
                cur[pos->talent_id] = std::max<uint32>(cur[pos->talent_id], pos->rank + 1);
        }
        return cur;
    }

    // every learned talent still has its tier points and prerequisites?
    static bool Valid(Ranks const& r)
    {
        std::map<uint32, std::map<uint32, uint32>> perTabRow; // tab -> row -> points
        for (auto const& kv : r)
            if (TalentEntry const* t = sTalentStore.LookupEntry(kv.first))
                perTabRow[t->TalentTab][t->Row] += kv.second;
        for (auto const& kv : r)
        {
            if (!kv.second) continue;
            TalentEntry const* t = sTalentStore.LookupEntry(kv.first);
            if (!t) continue;
            uint32 below = 0;
            for (auto const& row : perTabRow[t->TalentTab])
                if (row.first < t->Row) below += row.second;
            if (below < t->Row * MAX_TALENT_RANK)
                return false;
            if (t->DependsOn)
            {
                auto dep = r.find(t->DependsOn);
                if (dep == r.end() || dep->second < t->DependsOnRank + 1)
                    return false;
            }
        }
        return true;
    }

    // wipe the active spec's talents (free) and learn exactly `want`
    static void Rebuild(Player* player, Ranks const& want)
    {
        bool hadPet = false;
        if (Pet* pet = player->GetPet())
            if (pet->getPetType() == HUNTER_PET)
            {
                player->RemovePet(pet, PET_SAVE_AS_CURRENT);
                hadPet = true;
            }

        player->resetTalents(true);

        std::vector<std::pair<TalentEntry const*, uint32>> order;
        for (auto const& kv : want)
            if (kv.second)
                if (TalentEntry const* t = sTalentStore.LookupEntry(kv.first))
                    order.push_back({ t, std::min(kv.second, MaxRank(t)) });
        std::sort(order.begin(), order.end(), [](auto const& a, auto const& b)
            { return a.first->Row != b.first->Row ? a.first->Row < b.first->Row : a.first->Col < b.first->Col; });

        for (int pass = 0; pass < 4; ++pass)
            for (auto const& o : order)
                if (player->GetFreeTalentPoints())
                    player->LearnTalent(o.first->TalentID, o.second - 1);

        player->SendTalentsInfoData(false);
        ZeroCraftBars::All(player);
        if (hadPet)
            player->CastSpell(player, 883, true); // Call Pet
    }

    static void RemoveOne(Player* player, uint32 talentId)
    {
        Ranks cur = Current(player);
        auto itr = cur.find(talentId);
        if (itr == cur.end() || !itr->second)
            return;
        Ranks next = cur;
        next[talentId] -= 1;
        if (!next[talentId])
            next.erase(talentId);
        if (!Valid(next))
        {
            ZeroCraftDeploy::RedError(player, "Other talents need this one - remove those first.");
            return;
        }
        Rebuild(player, next);
    }

    static bool ApplyBuild(Player* player, uint32 index)
    {
        auto const& builds = Builds(player->getClass());
        if (index >= builds.size())
            return false;
        std::string const& str = builds[index];
        auto tabs = Tabs(player);
        Ranks want;
        size_t tab = 0, pos = 0;
        std::vector<TalentEntry const*> talents = tabs.empty() ? std::vector<TalentEntry const*>() : TalentsOf(tabs[0]->TalentTabID);
        for (char ch : str)
        {
            if (ch == '-')
            {
                ++tab; pos = 0;
                talents = tab < tabs.size() ? TalentsOf(tabs[tab]->TalentTabID) : std::vector<TalentEntry const*>();
                continue;
            }
            if (ch < '0' || ch > '9' || pos >= talents.size())
            {
                ++pos;
                continue;
            }
            if (ch != '0')
                want[talents[pos]->TalentID] = uint32(ch - '0');
            ++pos;
        }
        Rebuild(player, want);
        return true;
    }
}

// The addon's "ZCT" message is caught as it arrives (before the chat code,
// which turns addon messages from a GM in .gm mode into ordinary chat).
namespace ZeroCraftHome { static void StoneOptions(Player* p); static void StopDuplicating(Player* p); static bool IsDuplicating(Player* p); }

class ZeroCraftTalentChat : public ServerScript
{
public:
    ZeroCraftTalentChat() : ServerScript("ZeroCraftTalentChat") { }

    bool CanPacketReceive(WorldSession* session, WorldPacket const& packet) override
    {
        if (packet.GetOpcode() != CMSG_MESSAGECHAT || !session || !session->GetPlayer())
            return true;
        WorldPacket p(packet);
        p.rpos(0);
        uint32 type = 0, lang = 0;
        std::string to, msg;
        try
        {
            p >> type >> lang;
            if (type != CHAT_MSG_WHISPER || lang != uint32(LANG_ADDON))
                return true;
            p >> to >> msg;
        }
        catch (...) { return true; }
        if (msg.compare(0, 9, "ZCDUPEND\t") == 0)
        {
            if (ZeroCraftHome::IsDuplicating(session->GetPlayer()))
            {
                ZeroCraftHome::StopDuplicating(session->GetPlayer());
                ChatHandler(session).SendSysMessage("Done duplicating.");
            }
            return false;
        }
        if (msg.compare(0, 8, "ZCSTONE\t") == 0)
        {
            ZeroCraftHome::StoneOptions(session->GetPlayer());
            return false;
        }
        if (msg.compare(0, 4, "ZCT\t") != 0)
            return true;

        Player* player = session->GetPlayer();
        std::string cmd = msg.substr(4);
        if (player->IsInCombat())
            ZeroCraftDeploy::RedError(player, "You can't change talents in combat.");
        else if (cmd.compare(0, 4, "del:") == 0)
            ZeroCraftTalents::RemoveOne(player, uint32(std::strtoul(cmd.c_str() + 4, nullptr, 10)));
        else if (cmd.compare(0, 6, "build:") == 0)
            ZeroCraftTalents::ApplyBuild(player, uint32(std::strtoul(cmd.c_str() + 6, nullptr, 10)));
        else if (cmd == "reset")
            ZeroCraftTalents::Rebuild(player, ZeroCraftTalents::Ranks());
        return false; // swallowed - never shows up as chat
    }
};

// ============================================================================
// Builder's Kit: click a spot on the ground, then pick what to build there -
// useful things (mailbox, anvil, forge, cooking fire, meeting stone, training
// dummy, spirit healer) or decorations (tents, fires, barrels, wagons...).
// Never used up. Each guild can have up to 60 placed things; you can take back
// the nearest one your guild placed from the same menu.
// ============================================================================
// ============================================================================
// ZeroCraft Home Building (ComfyCraft style).
// Every placed object is a clickable copy of the real one (entry + 2,000,000):
// hover shows the cog, click opens a menu to move, turn, resize or pick it up.
// Summoning Stones claim the ground around them for a guild (building
// privilege, a la Rust): nobody else may build within 250 yards or in the same named place, only one
// stone per area, and talking to one summons guildmates or opens the bank.
// ============================================================================
namespace ZeroCraftHome
{
    static const uint32 CLONE = 2000000;
    static const float PRIV_RANGE = 250.0f;   // about the size of Theramore Isle
    static const float STONE_GAP = 500.0f;    // claims never overlap

    struct Furn { uint32 item; uint32 go; bool stone; std::string name; uint32 src = 0; uint32 srcType = 0; };
    static ObjectGuid bypass;   // the object being really used right now (skips our menu)
    static std::unordered_map<ObjectGuid::LowType, ObjectGuid::LowType> selected;   // player -> object picked for "Place"
    static const uint32 ROD = 60407;
    static const bool StoneDirect = false;  // the client won't keep a bank window open without a clicked chest
    static std::unordered_map<ObjectGuid::LowType, ObjectGuid> lastStone;   // player -> stone whose bank they opened
    static void (*ClearNpcSelection)(Player*) = nullptr;
    static std::unordered_set<ObjectGuid::LowType> duplicating;   // players whose next Rod click places a copy
    static const uint32 DUPLICATRON = 60410;
    struct DupT { uint32 entry; float scale; float o; };
    static std::unordered_map<ObjectGuid::LowType, DupT> dupTemplate;   // player -> what they're stamping
    static void StopDuplicating(Player* p)
    {
        duplicating.erase(p->GetGUID().GetCounter());
        dupTemplate.erase(p->GetGUID().GetCounter());
        selected.erase(p->GetGUID().GetCounter());
    }
    static bool IsDuplicating(Player* p) { return duplicating.count(p->GetGUID().GetCounter()) > 0; }
    static std::unordered_map<ObjectGuid, ObjectGuid> focusTwin;  // crafting station -> its hidden spell-focus twin
    static std::unordered_map<uint32, Furn> byItem, byGo;
    static std::unordered_map<ObjectGuid::LowType, float> scales;
    static bool loaded = false;

    static void Load()
    {
        if (loaded)
            return;
        loaded = true;
        if (QueryResult r = WorldDatabase.Query("SELECT f.item_entry, f.go_entry, f.stone, f.name, f.src_entry, t.type FROM zerocraft_furniture f JOIN gameobject_template t ON t.entry = f.src_entry"))
            do
            {
                Field* f = r->Fetch();
                Furn fu{ f[0].Get<uint32>(), f[1].Get<uint32>(), f[2].Get<uint8>() != 0, f[3].Get<std::string>(), f[4].Get<uint32>(), f[5].Get<uint32>() };
                byItem[fu.item] = fu;
                byGo[fu.go] = fu;
            } while (r->NextRow());
        if (QueryResult r = WorldDatabase.Query("SELECT spawn_id, scale FROM zerocraft_placed WHERE kind = 0 AND scale <> 1"))
            do { scales[(*r)[0].Get<uint32>()] = (*r)[1].Get<float>(); } while (r->NextRow());
    }

    static Furn const* OfGo(uint32 entry) { Load(); auto it = byGo.find(entry); return it == byGo.end() ? nullptr : &it->second; }
    // objects that do something when clicked (chairs, mailboxes, portals, books, meeting stones...)
    static bool Usable(Furn const* fu)
    {
        switch (fu->srcType)
        {
            case GAMEOBJECT_TYPE_DOOR: case GAMEOBJECT_TYPE_BUTTON: case GAMEOBJECT_TYPE_QUESTGIVER: case GAMEOBJECT_TYPE_CHAIR:
            case GAMEOBJECT_TYPE_TEXT: case GAMEOBJECT_TYPE_CAMERA: case GAMEOBJECT_TYPE_MAILBOX: case GAMEOBJECT_TYPE_SPELLCASTER:
            case GAMEOBJECT_TYPE_BARBER_CHAIR:
                return true;
            case GAMEOBJECT_TYPE_GOOBER:
                return sObjectMgr->GetGameObjectTemplate(fu->src) && sObjectMgr->GetGameObjectTemplate(fu->src)->goober.spellId;
            default:
                return false;
        }
    }
    static void ReallyUse(Player* p, GameObject* go)
    {
        CloseGossipMenuFor(p);
        if (go->GetGoType() == GAMEOBJECT_TYPE_MAILBOX)
        {
            p->GetSession()->SendShowMailBox(go->GetGUID());
            return;
        }
        bypass = go->GetGUID();
        go->Use(p);
        bypass = ObjectGuid::Empty;
    }

    static Furn const* OfItem(uint32 entry) { Load(); auto it = byItem.find(entry); return it == byItem.end() ? nullptr : &it->second; }

    static bool Mine(Player const* p, uint32 guild, uint32 owner)
    {
        return guild ? p->GetGuildId() == guild : p->GetGUID().GetCounter() == owner;
    }

    // Built things follow their guild by NAME (like deployed NPCs): if the guild was
    // disbanded and re-founded, or every character in it was deleted, the new guild
    // of that name takes them over. Things whose guild AND builder are both gone
    // belong to the first player who touches them (claimer may be null).
    static void Resolve(ObjectGuid::LowType spawnId, uint32& guild, uint32& owner, Player* claimer)
    {
        QueryResult r = WorldDatabase.Query(Acore::StringFormat(
            "SELECT owner_guild, owner_player, owner_guild_name FROM zerocraft_placed WHERE kind = 0 AND spawn_id = {}", spawnId));
        if (!r)
            return;
        guild = (*r)[0].Get<uint32>();
        owner = (*r)[1].Get<uint32>();
        std::string gname = (*r)[2].Get<std::string>();
        if (guild && sGuildMgr->GetGuildById(guild))
            return;
        if (!gname.empty())
            if (Guild* g = sGuildMgr->GetGuildByName(gname))
            {
                guild = g->GetId();
                std::string esc = gname;
                WorldDatabase.EscapeString(esc);
                WorldDatabase.DirectExecute(Acore::StringFormat("UPDATE zerocraft_placed SET owner_guild = {} WHERE owner_guild_name = '{}'", guild, esc));
                return;
            }
        bool ownerAlive = owner && CharacterDatabase.Query(Acore::StringFormat("SELECT 1 FROM characters WHERE guid = {}", owner));
        if (ownerAlive)
        {
            guild = 0;   // guild is gone, the builder still owns it
            return;
        }
        if (!claimer)
        {
            guild = 0; owner = 0;
            return;
        }
        guild = claimer->GetGuildId();
        owner = claimer->GetGUID().GetCounter();
        std::string cname = guild ? sGuildMgr->GetGuildById(guild)->GetName() : std::string("");
        WorldDatabase.EscapeString(cname);
        WorldDatabase.DirectExecute(Acore::StringFormat(
            "UPDATE zerocraft_placed SET owner_guild = {}, owner_player = {}, owner_guild_name = '{}' WHERE kind = 0 AND spawn_id = {}",
            guild, owner, cname, spawnId));
        ChatHandler(claimer->GetSession()).SendSysMessage("Nobody owned this any more - it's yours now.");
    }

    struct Stone { uint32 spawn; float x, y, z; uint32 guild, owner; };
    static std::vector<Stone> StonesOn(uint32 mapId)
    {
        std::vector<Stone> v;
        if (QueryResult r = WorldDatabase.Query(Acore::StringFormat(
            "SELECT g.guid, g.position_x, g.position_y, g.position_z, p.owner_guild, p.owner_player FROM zerocraft_placed p "
            "JOIN gameobject g ON g.guid = p.spawn_id JOIN zerocraft_furniture f ON f.go_entry = g.id "
            "WHERE p.kind = 0 AND f.stone = 1 AND g.map = {}", mapId)))
            do
            {
                Field* f = r->Fetch();
                uint32 g = f[4].Get<uint32>(), o = f[5].Get<uint32>();
                if (!g || !sGuildMgr->GetGuildById(g))
                    Resolve(f[0].Get<uint32>(), g, o, nullptr);
                if (!g && !o)
                    continue;   // abandoned stone: claims nothing until someone takes it
                v.push_back({ f[0].Get<uint32>(), f[1].Get<float>(), f[2].Get<float>(), f[3].Get<float>(), g, o });
            } while (r->NextRow());
        return v;
    }

    static std::string OwnerName(uint32 guild)
    {
        if (Guild* g = sGuildMgr->GetGuildById(guild))
            return "<" + g->GetName() + ">";
        return "someone";
    }

    // may this player build here?
    // the named place (Theramore Isle, Booty Bay...) a spot belongs to; 0 in open wilderness
    static uint32 PlaceOf(Map* map, float x, float y, float z)
    {
        uint32 zone = 0, area = 0;
        map->GetZoneAndAreaId(PHASEMASK_NORMAL, zone, area, x, y, z);
        return area != zone ? area : 0;
    }

    static bool CanBuildAt(Player* p, float x, float y, float z, bool stone, std::string& err, ObjectGuid::LowType ignoreSpawn = 0)
    {
        uint32 here = PlaceOf(p->GetMap(), x, y, z);
        for (Stone const& s : StonesOn(p->GetMapId()))
        {
            if (s.spawn == ignoreSpawn)
                continue;
            float d = std::sqrt((s.x - x) * (s.x - x) + (s.y - y) * (s.y - y));
            bool samePlace = here && PlaceOf(p->GetMap(), s.x, s.y, s.z) == here;
            if (samePlace)
                d = 0.0f;   // a stone claims the whole named place it stands in
            if (stone && d < STONE_GAP)
            {
                err = Mine(p, s.guild, s.owner) ? "Your guild already has a Summoning Stone in this area."
                                                : OwnerName(s.guild) + " already has a Summoning Stone in this area.";
                return false;
            }
            if (!stone && d < PRIV_RANGE && !Mine(p, s.guild, s.owner))
            {
                err = OwnerName(s.guild) + " has building privilege here.";
                return false;
            }
        }
        return true;
    }

    static bool DeployCheck(Player* p, float x, float y, float z, std::string& err) { return CanBuildAt(p, x, y, z, false, err); }
    static struct HookInit { HookInit() { ZeroCraftDeploy::BuildCheck = &DeployCheck; } } hookInit;

    // which stone (if any) claims this spot - cached for a few seconds, it's asked for every spawn
    static bool ClaimAt(Map* map, float x, float y, float z, Stone& out)
    {
        static std::unordered_map<uint32, std::pair<uint32, std::vector<Stone>>> cache;   // map -> (time, stones)
        auto& c = cache[map->GetId()];
        uint32 now = getMSTime();
        if (!c.first || getMSTimeDiff(c.first, now) > 10 * IN_MILLISECONDS)
            c = { now ? now : 1, StonesOn(map->GetId()) };
        uint32 here = 0;
        bool placeKnown = false;
        for (Stone const& s : c.second)
        {
            float d = std::sqrt((s.x - x) * (s.x - x) + (s.y - y) * (s.y - y));
            if (d > STONE_GAP)
                continue;
            if (d > PRIV_RANGE)
            {
                if (!placeKnown) { here = PlaceOf(map, x, y, z); placeKnown = true; }
                if (!here || PlaceOf(map, s.x, s.y, s.z) != here)
                    continue;
            }
            out = s;
            return true;
        }
        return false;
    }

    // may this player move / pick up this placed object?
    static bool CanEdit(Player* p, GameObject* go)
    {
        uint32 og = 0, oo = 0;
        Resolve(go->GetSpawnId(), og, oo, p);
        if (!og && !oo)
            return false;
        if (Mine(p, og, oo))
            return true;
        Furn const* fu = OfGo(go->GetEntry());
        if (fu && fu->stone)
            return false;
        for (Stone const& s : StonesOn(p->GetMapId()))
            if (go->GetExactDist(s.x, s.y, s.z) < PRIV_RANGE && Mine(p, s.guild, s.owner))
                return true;
        return false;
    }

    static GameObject* Find(Map* map, ObjectGuid::LowType spawnId)
    {
        auto range = map->GetGameObjectBySpawnIdStore().equal_range(spawnId);
        return range.first == range.second ? nullptr : range.first->second;
    }

    static ObjectGuid::LowType Spawn(Map* map, uint32 phase, uint32 entry, Position const& pos, float scale, uint32 guild, uint32 owner)
    {
        if (!sObjectMgr->GetGameObjectTemplate(entry))
            return 0;
        GameObject* go = new GameObject();
        G3D::Quat rot = G3D::Quat::fromAxisAngleRotation(G3D::Vector3::unitZ(), pos.GetOrientation());
        if (!go->Create(map->GenerateLowGuid<HighGuid::GameObject>(), entry, map, phase,
                        pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ(), pos.GetOrientation(), rot, 0, GO_STATE_READY))
        {
            delete go;
            return 0;
        }
        go->SaveToDB(map->GetId(), (1 << map->GetSpawnMode()), phase);
        ObjectGuid::LowType id = go->GetSpawnId();
        delete go;
        if (scale != 1.0f)
            scales[id] = scale;
        WorldDatabase.DirectExecute(Acore::StringFormat(
            "INSERT INTO zerocraft_placed (kind, spawn_id, owner_guild, owner_player, scale, owner_guild_name) "
            "VALUES (0, {}, {}, {}, {}, COALESCE((SELECT name FROM acore_characters.guild WHERE guildid = {}), ''))", id, guild, owner, scale, guild));
        go = new GameObject();
        if (!go->LoadGameObjectFromDB(id, map, true))
        {
            delete go;
            return 0;
        }
        sObjectMgr->AddGameobjectToGrid(id, sObjectMgr->GetGameObjectData(id));
        return id;
    }

    // ---------------------------------------------------------------- stone guardians
    static ObjectGuid::LowType GuardOf(ObjectGuid::LowType stone)
    {
        if (QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT guard_spawn FROM zerocraft_stoneguard WHERE stone_spawn = {}", stone)))
            return (*r)[0].Get<uint32>();
        return 0;
    }
    static ObjectGuid::LowType StoneOf(ObjectGuid::LowType guard)
    {
        if (QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT stone_spawn FROM zerocraft_stoneguard WHERE guard_spawn = {}", guard)))
            return (*r)[0].Get<uint32>();
        return 0;
    }

    static void RemoveGuardian(Map* map, ObjectGuid::LowType stone)
    {
        ObjectGuid::LowType g = GuardOf(stone);
        WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM zerocraft_stoneguard WHERE stone_spawn = {}", stone));
        if (!g)
            return;
        ZeroCraftDeploy::spawnFaction.erase(g);
        WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM zerocraft_deployables WHERE spawn_id = {}", g));
        auto range = map->GetCreatureBySpawnIdStore().equal_range(g);
        std::vector<Creature*> cs;
        for (auto it = range.first; it != range.second; ++it) cs.push_back(it->second);
        for (Creature* c : cs)
        {
            c->SetRespawnDelay(0x7FFFFFFF);
            c->DeleteFromDB();
            c->AddObjectToRemoveList();
        }
        if (cs.empty())
        {
            if (CreatureData const* d = sObjectMgr->GetCreatureData(g))
                sObjectMgr->RemoveCreatureFromGrid(g, d);
            sObjectMgr->DeleteCreatureData(g);
            WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM creature WHERE guid = {}", g));
        }
    }

    // every Summoning Stone has an attackable heart: friendly to its guild, hostile to everyone else
    static void EnsureGuardian(GameObject* go)
    {
        Furn const* fu = OfGo(go->GetEntry());
        if (!fu || !fu->stone || !go->GetSpawnId())
            return;
        ObjectGuid::LowType g = GuardOf(go->GetSpawnId());
        if (g && sObjectMgr->GetCreatureData(g))
            return;
        uint32 guild = 0, owner = 0;
        Resolve(go->GetSpawnId(), guild, owner, nullptr);
        if (!guild && !owner)
            return;
        int64 key = guild ? int64(guild) : -int64(owner);
        uint32 tpl = ZeroCraftDeploy::GetOrClaimSlot(key);
        if (!tpl)
            return;
        Map* map = go->GetMap();
        Creature* c = new Creature();
        if (!c->Create(map->GenerateLowGuid<HighGuid::Unit>(), map, go->GetPhaseMask(), ZeroCraftDeploy::STONE_GUARD, 0,
                       go->GetPositionX(), go->GetPositionY(), go->GetPositionZ(), go->GetOrientation()))
        {
            delete c;
            return;
        }
        c->SaveToDB(map->GetId(), (1 << map->GetSpawnMode()), go->GetPhaseMask());
        ObjectGuid::LowType id = c->GetSpawnId();
        c->CleanupsBeforeDelete();
        delete c;
        std::string gname;
        if (Guild* gg = sGuildMgr->GetGuildById(guild))
            gname = gg->GetName();
        WorldDatabase.EscapeString(gname);
        ZeroCraftDeploy::spawnFaction[id] = tpl;
        WorldDatabase.DirectExecute(Acore::StringFormat(
            "REPLACE INTO zerocraft_deployables (spawn_id, entry, owner_player, owner_guild, faction_template, owner_guild_name) VALUES ({}, {}, {}, {}, {}, '{}')",
            id, ZeroCraftDeploy::STONE_GUARD, owner, guild, tpl, gname));
        WorldDatabase.DirectExecute(Acore::StringFormat("REPLACE INTO zerocraft_stoneguard (stone_spawn, guard_spawn) VALUES ({}, {})", go->GetSpawnId(), id));
        c = new Creature();
        if (!c->LoadCreatureFromDB(id, map, true, true))
        {
            delete c;
            return;
        }
        sObjectMgr->AddCreatureToGrid(id, sObjectMgr->GetCreatureData(id));
        c->SetFaction(ZeroCraftDeploy::ZC_FACTION);
        for (auto const& pair : ObjectAccessor::GetPlayers())
            if (Player* p = pair.second)
                if (p->IsInWorld() && ((guild && p->GetGuildId() == guild) || (!guild && p->GetGUID().GetCounter() == owner)))
                    ZeroCraftDeploy::ApplyReactions(p);
    }

    static void OnStoneFallen(Creature* guard, Unit* killer)
    {
        ObjectGuid::LowType stone = StoneOf(guard->GetSpawnId());
        WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM zerocraft_stoneguard WHERE guard_spawn = {}", guard->GetSpawnId()));
        if (!stone)
            return;
        std::string place = ZeroCraftWar::PlaceName(guard);
        uint32 og = 0, oo = 0;
        Resolve(stone, og, oo, nullptr);
        std::string owner = og ? OwnerName(og) : std::string("A lone adventurer");
        Player* kp = killer ? killer->GetCharmerOrOwnerPlayerOrPlayerItself() : nullptr;
        ZeroCraftWar::WarnAll(kp
            ? Acore::StringFormat("{} has shattered {}'s Summoning Stone at {} and plundered their guild bank!", ZeroCraftWar::Who(kp), owner, place)
            : Acore::StringFormat("{}'s Summoning Stone at {} has been destroyed.", owner, place));
        Map* map = guard->GetMap();
        auto range = map->GetGameObjectBySpawnIdStore().equal_range(stone);
        std::vector<GameObject*> gos;
        for (auto it = range.first; it != range.second; ++it) gos.push_back(it->second);
        for (GameObject* go : gos) { go->SetRespawnTime(0); go->Delete(); }
        if (GameObjectData const* d = sObjectMgr->GetGameObjectData(stone))
            sObjectMgr->RemoveGameobjectFromGrid(stone, d);
        sObjectMgr->DeleteGOData(stone);
        WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM gameobject WHERE guid = {}", stone));
        WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM zerocraft_placed WHERE kind = 0 AND spawn_id = {}", stone));
    }
    static struct StoneInit { StoneInit() { ZeroCraftDeploy::StoneFallen = &OnStoneFallen; } } stoneInit;

    static void Despawn(Map* map, ObjectGuid::LowType id)
    {
        if (GuardOf(id))
            RemoveGuardian(map, id);
        auto range = map->GetGameObjectBySpawnIdStore().equal_range(id);
        std::vector<GameObject*> gos;
        for (auto it = range.first; it != range.second; ++it) gos.push_back(it->second);
        for (GameObject* go : gos) { go->SetRespawnTime(0); go->Delete(); }
        if (GameObjectData const* d = sObjectMgr->GetGameObjectData(id))
            sObjectMgr->RemoveGameobjectFromGrid(id, d);
        sObjectMgr->DeleteGOData(id);
        WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM gameobject WHERE guid = {}", id));
        WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM zerocraft_placed WHERE kind = 0 AND spawn_id = {}", id));
        scales.erase(id);
    }

    enum Act
    {
        // main menu
        A_MOVE = 1, A_TURN, A_RESIZE, A_PICKUP, A_DONE, A_USE, A_PLACE, A_UNSELECT, A_PICKUP10, A_PICKUP30, A_DELETE, A_DELETE_YES, A_DUPLICATE,
        // move menu
        A_MSTEP = 100, A_FWD, A_BACK, A_LEFT, A_RIGHT, A_UP, A_DOWN, A_HERE, A_MFACE,
        // turn menu
        A_TSTEP = 200, A_TURNL, A_TURNR, A_TURNL90, A_TURNR90, A_FACE, A_FACEAWAY,
        // resize menu
        A_SSTEP = 300, A_BIG, A_SMALL, A_RESET,
        // back to the main menu
        A_MAIN = 400,
        // stone services
        A_EDIT = 500, A_VAULT, A_DEP100, A_DEP500, A_DEP1000, A_SUMMONLIST, A_DEPANY, A_HOME, A_NEARBY, A_SUMMON = 1000
    };
    enum Text { T_MAIN = 911210, T_MOVE, T_TURN, T_RESIZE, T_STONE, T_SUMMON };
    static const uint32 A_PICK = 2000000000u;
    static void (*EditNearby)(Player*) = nullptr;   // the Builder's Rod list, set further down
    static std::unordered_map<ObjectGuid::LowType, std::vector<ObjectGuid>> pickList;   // player -> objects offered to edit

    // each player's chosen step sizes
    static const float MOVE_STEPS[] = { 0.1f, 0.25f, 0.5f, 1.0f, 2.0f, 5.0f };
    static const float TURN_STEPS[] = { 1.0f, 5.0f, 15.0f, 45.0f };
    static const float SIZE_STEPS[] = { 5.0f, 10.0f, 25.0f, 50.0f };
    struct Steps { uint8 move = 3, turn = 2, size = 1; };
    static std::unordered_map<ObjectGuid::LowType, Steps> steps;

    static std::string Num(float v)
    {
        std::string s = Acore::StringFormat("{:.2f}", v);
        while (!s.empty() && s.back() == '0') s.pop_back();
        if (!s.empty() && s.back() == '.') s.pop_back();
        return s;
    }

    static void MainMenu(Player* p, GameObject* go)
    {
        ClearGossipMenuFor(p);
        if (Furn const* fu = OfGo(go->GetEntry()))
        {
            if (fu->srcType == GAMEOBJECT_TYPE_MAILBOX)
                AddGossipItemFor(p, GOSSIP_ICON_INTERACT_1, "Check the mail", GOSSIP_SENDER_MAIN, A_USE);
            else if (Usable(fu))
                AddGossipItemFor(p, GOSSIP_ICON_INTERACT_1, "Use it", GOSSIP_SENDER_MAIN, A_USE);
            else if (fu->srcType == GAMEOBJECT_TYPE_SPELL_FOCUS)
                AddGossipItemFor(p, GOSSIP_ICON_INTERACT_1, "Use it (works for crafting - stand near it)", GOSSIP_SENDER_MAIN, A_USE);
        }
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Move it", GOSSIP_SENDER_MAIN, A_MOVE);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Place it (use the Builder's Rod and click the ground)", GOSSIP_SENDER_MAIN, A_PLACE);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, p->HasItemCount(DUPLICATRON, 1)
            ? "Duplicate it (uses your Tinker's Duplicatron-9000)"
            : "|cff808080Duplicate it (requires a Tinker's Duplicatron-9000)|r", GOSSIP_SENDER_MAIN, A_DUPLICATE);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Turn it", GOSSIP_SENDER_MAIN, A_TURN);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Resize it", GOSSIP_SENDER_MAIN, A_RESIZE);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, " ", GOSSIP_SENDER_MAIN, A_MAIN);
        {
            auto sel = selected.find(p->GetGUID().GetCounter());
            if (sel != selected.end() && sel->second == go->GetSpawnId())
                AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Selected -- click to clear", GOSSIP_SENDER_MAIN, A_UNSELECT);
        }
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Pick up", GOSSIP_SENDER_MAIN, A_PICKUP);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Pick up everything within 10 yards", GOSSIP_SENDER_MAIN, A_PICKUP10);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Pick up everything within 30 yards", GOSSIP_SENDER_MAIN, A_PICKUP30);
        AddGossipItemFor(p, GOSSIP_ICON_BATTLE, "|cffcc0000Delete it (gone for good)|r", GOSSIP_SENDER_MAIN, A_DELETE_YES);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, " ", GOSSIP_SENDER_MAIN, A_MAIN);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Done\nExit edit mode", GOSSIP_SENDER_MAIN, A_DONE);
        SendGossipMenuFor(p, T_MAIN, go->GetGUID());
    }

    static void MoveMenu(Player* p, GameObject* go)
    {
        Steps& st = steps[p->GetGUID().GetCounter()];
        ClearGossipMenuFor(p);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Back", GOSSIP_SENDER_MAIN, A_MAIN);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Step: " + Num(MOVE_STEPS[st.move]) + " yards (click to change)", GOSSIP_SENDER_MAIN, A_MSTEP);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Away", GOSSIP_SENDER_MAIN, A_FWD);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Towards", GOSSIP_SENDER_MAIN, A_BACK);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Left", GOSSIP_SENDER_MAIN, A_LEFT);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Right", GOSSIP_SENDER_MAIN, A_RIGHT);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Up", GOSSIP_SENDER_MAIN, A_UP);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Down", GOSSIP_SENDER_MAIN, A_DOWN);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Bring it to me", GOSSIP_SENDER_MAIN, A_HERE);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Face Player", GOSSIP_SENDER_MAIN, A_MFACE);
        SendGossipMenuFor(p, T_MOVE, go->GetGUID());
    }

    static void TurnMenu(Player* p, GameObject* go)
    {
        Steps& st = steps[p->GetGUID().GetCounter()];
        ClearGossipMenuFor(p);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Back", GOSSIP_SENDER_MAIN, A_MAIN);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Step: " + Num(TURN_STEPS[st.turn]) + " degrees (click to change)", GOSSIP_SENDER_MAIN, A_TSTEP);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Left", GOSSIP_SENDER_MAIN, A_TURNL);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Right", GOSSIP_SENDER_MAIN, A_TURNR);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Left 90", GOSSIP_SENDER_MAIN, A_TURNL90);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Right 90", GOSSIP_SENDER_MAIN, A_TURNR90);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Face Player", GOSSIP_SENDER_MAIN, A_FACE);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Face Away from Player", GOSSIP_SENDER_MAIN, A_FACEAWAY);
        SendGossipMenuFor(p, T_TURN, go->GetGUID());
    }

    static void ResizeMenu(Player* p, GameObject* go)
    {
        ClearGossipMenuFor(p);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Bigger", GOSSIP_SENDER_MAIN, A_BIG);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Smaller", GOSSIP_SENDER_MAIN, A_SMALL);
        SendGossipMenuFor(p, T_RESIZE, go->GetGUID());
    }

    static void EditMenu(Player* p, GameObject* go) { MainMenu(p, go); }

    static void StoneMenu(Player* p, GameObject* go)
    {
        ClearGossipMenuFor(p);
        AddGossipItemFor(p, GOSSIP_ICON_MONEY_BAG, "Open the Guild Vault", GOSSIP_SENDER_MAIN, A_VAULT);
        AddGossipItemFor(p, GOSSIP_ICON_TAXI, "Summon a guildmate", GOSSIP_SENDER_MAIN, A_SUMMONLIST);
        AddGossipItemFor(p, GOSSIP_ICON_INTERACT_1, "Make this stone my home (Hearthstone comes here)", GOSSIP_SENDER_MAIN, A_HOME);
        AddGossipItemFor(p, GOSSIP_ICON_INTERACT_2, "Move, turn or pick up this stone", GOSSIP_SENDER_MAIN, A_EDIT);
        AddGossipItemFor(p, GOSSIP_ICON_INTERACT_2, "Delete something we built nearby", GOSSIP_SENDER_MAIN, A_NEARBY);
        AddGossipItemFor(p, GOSSIP_ICON_MONEY_BAG, "Store gold", GOSSIP_SENDER_MAIN, A_DEPANY, "How much gold do you want to store?", 0, true);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Done", GOSSIP_SENDER_MAIN, A_DONE);
        SendGossipMenuFor(p, T_STONE, go->GetGUID());
    }

    static std::vector<Player*> Guildmates(Player* p)
    {
        std::vector<Player*> v;
        if (!p->GetGuildId())
            return v;
        for (auto const& pair : ObjectAccessor::GetPlayers())
            if (Player* o = pair.second)
                if (o != p && o->IsInWorld() && o->GetGuildId() == p->GetGuildId() && v.size() < 25)
                    v.push_back(o);
        return v;
    }

    static void Hello(Player* p, GameObject* go)
    {
        Furn const* fu = OfGo(go->GetEntry());
        if (!fu)
            return;
        if (fu->stone)
        {
            uint32 og = 0, oo = 0;
            Resolve(go->GetSpawnId(), og, oo, p);
            if (!Mine(p, og, oo))
            {
                std::string who = og ? OwnerName(og) : std::string("another adventurer");
                if (!og && oo)
                    if (QueryResult n = CharacterDatabase.Query(Acore::StringFormat("SELECT name FROM characters WHERE guid = {}", oo)))
                        who = (*n)[0].Get<std::string>();
                ZeroCraftDeploy::RedError(p, "This Summoning Stone belongs to " + who + ".");
                CloseGossipMenuFor(p);
                return;
            }
            StoneMenu(p, go);
            return;
        }
        if (!CanEdit(p, go))
        {
            if (Usable(fu))
                return ReallyUse(p, go);
            if (fu->srcType == GAMEOBJECT_TYPE_SPELL_FOCUS)
            {
                ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} works for crafting - just stand near it.", fu->name));
                return CloseGossipMenuFor(p);
            }
            ZeroCraftDeploy::RedError(p, "You don't have building privilege here.");
            CloseGossipMenuFor(p);
            return;
        }
        EditMenu(p, go);
    }

    // the Builder's Rod: move the selected object to the clicked spot
    static void PlaceSelected(Player* p, WorldLocation const& dst)
    {
        // Duplicatron stamp mode: every click places another copy, until Esc
        auto dup = dupTemplate.find(p->GetGUID().GetCounter());
        if (duplicating.count(p->GetGUID().GetCounter()) && dup != dupTemplate.end())
        {
            if (!p->HasItemCount(DUPLICATRON, 1))
            {
                StopDuplicating(p);
                ZeroCraftDeploy::RedError(p, "Your Tinker's Duplicatron-9000 has gone missing. Typical.");
                return;
            }
            Furn const* dfu = OfGo(dup->second.entry);
            if (!dfu)
                return StopDuplicating(p);
            if (p->GetExactDist(dst.GetPositionX(), dst.GetPositionY(), dst.GetPositionZ()) > 60.0f)
            {
                ZeroCraftDeploy::RedError(p, "That's too far away.");
                ChatHandler(p->GetSession()).SendSysMessage("ZCROD:start");
                return;
            }
            std::string derr;
            if (!CanBuildAt(p, dst.GetPositionX(), dst.GetPositionY(), dst.GetPositionZ(), dfu->stone, derr))
            {
                ZeroCraftDeploy::RedError(p, derr);
                ChatHandler(p->GetSession()).SendSysMessage("ZCROD:start");
                return;
            }
            Position dpos;
            dpos.Relocate(dst.GetPositionX(), dst.GetPositionY(), dst.GetPositionZ(), dup->second.o);
            if (Spawn(p->GetMap(), p->GetPhaseMaskForSpawn(), dup->second.entry, dpos, dup->second.scale, p->GetGuildId(), p->GetGUID().GetCounter()))
                ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat(
                    "*BZZT-PING!* Another {}. Keep clicking to stamp more - press Esc to stop.", dfu->name));
            ChatHandler(p->GetSession()).SendSysMessage("ZCROD:start");   // straight back to the green circle
            return;
        }
        auto sel = selected.find(p->GetGUID().GetCounter());
        GameObject* go = sel != selected.end() ? Find(p->GetMap(), sel->second) : nullptr;
        if (!go)
        {
            selected.erase(p->GetGUID().GetCounter());
            duplicating.erase(p->GetGUID().GetCounter());
            ZeroCraftDeploy::RedError(p, "Click something you built and choose \"Place it\" first.");
            return;
        }
        Furn const* fu = OfGo(go->GetEntry());
        if (!fu || !CanEdit(p, go))
        {
            ZeroCraftDeploy::RedError(p, "You don't have building privilege for that.");
            return;
        }
        if (go->GetExactDist(dst.GetPositionX(), dst.GetPositionY(), dst.GetPositionZ()) > 60.0f)
        {
            ZeroCraftDeploy::RedError(p, "That's too far from where it stands now.");
            return;
        }
        std::string err;
        if (!CanBuildAt(p, dst.GetPositionX(), dst.GetPositionY(), dst.GetPositionZ(), fu->stone, err, go->GetSpawnId()))
        {
            ZeroCraftDeploy::RedError(p, err);
            return;
        }
        uint32 og = 0, oo = 0;
        Resolve(go->GetSpawnId(), og, oo, p);
        Position pos;
        pos.Relocate(dst.GetPositionX(), dst.GetPositionY(), dst.GetPositionZ(), go->GetOrientation());
        float scale = go->GetObjectScale();
        uint32 phase = go->GetPhaseMask(), entry = go->GetEntry();
        Map* map = go->GetMap();
        Despawn(map, go->GetSpawnId());
        ObjectGuid::LowType nid = Spawn(map, phase, entry, pos, scale, og, oo);
        if (nid)
            sel->second = nid;   // stays selected: keep clicking to fine-tune
        ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} placed.", fu->name));
    }

    // "Stone Options" button on the guild bank window (addon message)
    static void StoneOptions(Player* p)
    {
        auto it = lastStone.find(p->GetGUID().GetCounter());
        GameObject* go = nullptr;
        if (it != lastStone.end())
            for (auto const& kv : focusTwin)
                if (kv.second == it->second)
                    go = p->GetMap()->GetGameObject(kv.first);
        if (!go && it != lastStone.end())
            go = p->GetMap()->GetGameObject(it->second);
        if (!go || !p->IsWithinDistInMap(go, 10.0f))
        {
            ZeroCraftDeploy::RedError(p, "Stand next to your Summoning Stone.");
            return;
        }
        StoneMenu(p, go);
    }

    static void Select(Player* p, GameObject* go, uint32 action)
    {
        // a pick from the "what do you want to edit?" list (Builder's Rod with nothing selected)
        if (action >= A_PICK)
        {
            auto pl = pickList.find(p->GetGUID().GetCounter());
            uint32 i = action - A_PICK;
            GameObject* target = (pl != pickList.end() && i < pl->second.size()) ? p->GetMap()->GetGameObject(pl->second[i]) : nullptr;
            if (!target)
                return CloseGossipMenuFor(p);
            // the list deletes: faraway things can't hold a menu open (the game closes it out of range)
            Furn const* tf = OfGo(target->GetEntry());
            if (!tf || tf->stone || !CanEdit(p, target))
            {
                ZeroCraftDeploy::RedError(p, tf && tf->stone ? "Pick up a Summoning Stone from its own menu." : "You don't have building privilege for that.");
                return CloseGossipMenuFor(p);
            }
            std::string tname = tf->name;
            Despawn(target->GetMap(), target->GetSpawnId());
            ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} destroyed.", tname));
            if (EditNearby)
                EditNearby(p);   // list again, for the next one
            return;
        }
        Furn const* fu = OfGo(go->GetEntry());
        if (!fu)
            return CloseGossipMenuFor(p);
        Guild* guild = sGuildMgr->GetGuildById(p->GetGuildId());

        // ---- stone services
        if (fu->stone && (action >= A_EDIT))
        {
            switch (action)
            {
                case A_EDIT: return MainMenu(p, go);
                case A_VAULT:
                {
                    CloseGossipMenuFor(p);
                    if (!guild) { ZeroCraftDeploy::RedError(p, "You need a guild for a guild bank."); return; }
                    auto tw = focusTwin.find(go->GetGUID());
                    if (tw != focusTwin.end() && StoneDirect)
                    {
                        // open the bank window straight from the stone (the addon keeps the window open)
                        lastStone[p->GetGUID().GetCounter()] = tw->second;
                        if (ZcGuildPeek::Tabs(guild).empty())
                        {
                            p->ModifyMoney(100 * GOLD);
                            guild->HandleBuyBankTab(p->GetSession(), 0);
                            if (ZcGuildPeek::Tabs(guild).empty())
                                p->ModifyMoney(-int32(100 * GOLD));
                        }
                        ChatHandler(p->GetSession()).SendSysMessage("ZCVAULT:open");
                        guild->SendBankTabsInfo(p->GetSession(), true);
                        return;
                    }
                    // a few yards from the stone, on the side you're standing on, facing you
                    // in front of you, a few yards out, on the side away from the stone
                    float a = p->GetOrientation();
                    float toStone = p->GetAngle(go);
                    if (std::fabs(Position::NormalizeOrientation(a - toStone)) < 1.0f || std::fabs(Position::NormalizeOrientation(a - toStone)) > 5.28f)
                        a = toStone + float(M_PI) / 2;   // facing the stone: put it off to the side instead
                    float x = p->GetPositionX() + 4.0f * std::cos(a), y = p->GetPositionY() + 4.0f * std::sin(a), z = p->GetPositionZ();
                    p->UpdateGroundPositionZ(x, y, z);
                    float o = std::atan2(p->GetPositionY() - y, p->GetPositionX() - x);
                    if (GameObject* v = p->SummonGameObject(ZeroCraftVault::VAULT_ENTRY, x, y, z, o, 0, 0, 0, 0, 120))
                    {
                        v->SetObjectScale(5.0f);
                        ZeroCraftVault::vaultGuild[v->GetGUID()] = guild->GetId();
                    }
                    ChatHandler(p->GetSession()).SendSysMessage("The stone raises your guild's strongbox in front of you. Click it to open the Guild Vault - it sinks back in two minutes.");
                    return;
                }
                case A_DEP100: case A_DEP500: case A_DEP1000:
                {
                    uint32 gold = action == A_DEP100 ? 100 : action == A_DEP500 ? 500 : 1000;
                    if (!guild) { ZeroCraftDeploy::RedError(p, "You need a guild for a guild bank."); return StoneMenu(p, go); }
                    if (!p->HasEnoughMoney(gold * GOLD)) { ZeroCraftDeploy::RedError(p, "You don't have that much gold."); return StoneMenu(p, go); }
                    guild->HandleMemberDepositMoney(p->GetSession(), gold * GOLD);
                    ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} gold stored in the guild bank.", gold));
                    return StoneMenu(p, go);
                }
                case A_NEARBY:
                    if (EditNearby)
                        EditNearby(p);
                    return;
                case A_HOME:
                {
                    // exactly what an innkeeper does: the Bind spell (home = where you stand, glow + sound)
                    p->CastSpell(p, 3286, true);
                    std::string place = "This place";
                    if (AreaTableEntry const* a = sAreaTableStore.LookupEntry(p->GetZoneId()))
                        place = a->area_name[0];
                    ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("|cffffff00{} is now your home.|r", place));
                    p->SaveToDB(false, false);
                    return StoneMenu(p, go);
                }
                case A_SUMMONLIST:
                {
                    ClearGossipMenuFor(p);
                    AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Back", GOSSIP_SENDER_MAIN, A_EDIT + 98);
                    auto mates = Guildmates(p);
                    for (uint32 i = 0; i < mates.size(); ++i)
                        AddGossipItemFor(p, GOSSIP_ICON_TAXI, mates[i]->GetName(), GOSSIP_SENDER_MAIN, A_SUMMON + mates[i]->GetGUID().GetCounter());
                    if (mates.empty())
                        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "No guildmates are online.", GOSSIP_SENDER_MAIN, A_EDIT + 98);
                    SendGossipMenuFor(p, T_SUMMON, go->GetGUID());
                    return;
                }
                default:
                    if (action >= A_SUMMON)
                    {
                        Player* t = ObjectAccessor::FindPlayerByLowGUID(ObjectGuid::LowType(action - A_SUMMON));
                        std::string why;
                        if (!t || !t->IsInWorld())                  why = "They're no longer online.";
                        else if (!t->IsAlive())                     why = t->GetName() + " is dead.";
                        else if (t->IsInCombat())                   why = t->GetName() + " is in combat.";
                        else if (t->GetMap()->Instanceable())       why = t->GetName() + " is in a dungeon, raid or battleground.";
                        else if (t->IsInFlight())                   why = t->GetName() + " is flying.";
                        else if (p->IsInCombat())                   why = "You can't summon while in combat.";
                        if (!why.empty())
                        {
                            ZeroCraftDeploy::RedError(p, why);
                            return CloseGossipMenuFor(p);
                        }
                        if (t && t->GetGuildId() == p->GetGuildId() && t->GetGuildId())
                        {
                            float sx, sy, sz;
                            p->GetPosition(sx, sy, sz);
                            t->SetSummonPoint(p->GetMapId(), sx, sy, sz);
                            WorldPacket data(SMSG_SUMMON_REQUEST, 8 + 4 + 4);
                            data << p->GetGUID();
                            data << uint32(p->GetZoneId());
                            data << uint32(MAX_PLAYER_SUMMON_DELAY * IN_MILLISECONDS);
                            t->SendDirectMessage(&data);
                            ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("The stone calls to {}.", t->GetName()));
                        }
                        return CloseGossipMenuFor(p);
                    }
                    return StoneMenu(p, go);
            }
        }

        if (action == A_DONE)
            return CloseGossipMenuFor(p);
        if (action == A_USE)
        {
            if (Usable(fu))
                return ReallyUse(p, go);
            ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} works for crafting - just stand near it.", fu->name));
            return CloseGossipMenuFor(p);
        }
        if (!CanEdit(p, go))
        {
            ZeroCraftDeploy::RedError(p, "You don't have building privilege here.");
            return CloseGossipMenuFor(p);
        }

        Steps& st = steps[p->GetGUID().GetCounter()];
        switch (action)
        {
            case A_DUPLICATE:
                if (fu->stone)
                {
                    ZeroCraftDeploy::RedError(p, "Summoning Stones can't be copied.");
                    return MainMenu(p, go);
                }
                if (!p->HasItemCount(DUPLICATRON, 1))
                {
                    ZeroCraftDeploy::RedError(p, "You need a Tinker's Duplicatron-9000. Gnomes leave them lying around in dungeons.");
                    return MainMenu(p, go);
                }
                duplicating.insert(p->GetGUID().GetCounter());
                dupTemplate[p->GetGUID().GetCounter()] = { go->GetEntry(), go->GetObjectScale(), go->GetOrientation() };
                ChatHandler(p->GetSession()).SendSysMessage("Duplicating: click the ground to stamp copies. Press Esc to stop.");
                [[fallthrough]];
            case A_PLACE:
            {
                if (action == A_PLACE)
                    duplicating.erase(p->GetGUID().GetCounter());
                selected[p->GetGUID().GetCounter()] = go->GetSpawnId();
                if (ClearNpcSelection) ClearNpcSelection(p);
                if (!p->HasItemCount(ROD, 1, true))
                    p->AddItem(ROD, 1);
                CloseGossipMenuFor(p);
                ChatHandler(p->GetSession()).SendSysMessage("ZCROD:start");
                return;
            }
            case A_UNSELECT:
                selected.erase(p->GetGUID().GetCounter());
                duplicating.erase(p->GetGUID().GetCounter());
                return MainMenu(p, go);
            case A_MAIN:   return MainMenu(p, go);
            case A_MOVE:   return MoveMenu(p, go);
            case A_TURN:   return TurnMenu(p, go);
            case A_RESIZE: return ResizeMenu(p, go);
            case A_MSTEP:  st.move = (st.move + 1) % 6; return MoveMenu(p, go);
            case A_TSTEP:  st.turn = (st.turn + 1) % 4; return TurnMenu(p, go);
            case A_SSTEP:  st.size = (st.size + 1) % 4; return ResizeMenu(p, go);
            default: break;
        }

        Map* map = go->GetMap();
        ObjectGuid::LowType id = go->GetSpawnId();
        uint32 ownerGuild = 0, ownerPlayer = 0;
        if (QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT owner_guild, owner_player FROM zerocraft_placed WHERE kind = 0 AND spawn_id = {}", id)))
        {
            ownerGuild = (*r)[0].Get<uint32>();
            ownerPlayer = (*r)[1].Get<uint32>();
        }

        if (action == A_DELETE)
        {
            ClearGossipMenuFor(p);
            AddGossipItemFor(p, GOSSIP_ICON_BATTLE, "|cffcc0000Yes - destroy " + fu->name + "|r", GOSSIP_SENDER_MAIN, A_DELETE_YES);
            AddGossipItemFor(p, GOSSIP_ICON_CHAT, "No, keep it", GOSSIP_SENDER_MAIN, A_MAIN);
            SendGossipMenuFor(p, T_MAIN, go->GetGUID());
            return;
        }
        if (action == A_DELETE_YES)
        {
            if (fu->stone)
            {
                ZeroCraftDeploy::RedError(p, "Pick up a Summoning Stone instead - deleting it would drop your claim.");
                return MainMenu(p, go);
            }
            std::string name = fu->name;
            Despawn(map, id);
            CloseGossipMenuFor(p);
            ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} destroyed.", name));
            return;
        }
        if (action == A_PICKUP10 || action == A_PICKUP30)
        {
            float range = action == A_PICKUP10 ? 10.0f : 30.0f;
            std::vector<GameObject*> near;
            for (auto const& kv : map->GetGameObjectBySpawnIdStore())
            {
                GameObject* o = kv.second;
                if (!o || !o->IsInWorld() || o->GetEntry() < CLONE || o->GetExactDist(go) > range)
                    continue;
                Furn const* f = OfGo(o->GetEntry());
                if (!f || f->stone || !CanEdit(p, o))
                    continue;
                near.push_back(o);
            }
            uint32 got = 0, full = 0;
            for (GameObject* o : near)
            {
                Furn const* f = OfGo(o->GetEntry());
                ItemPosCountVec dest;
                if (p->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, f->item, 1) != EQUIP_ERR_OK)
                {
                    ++full;
                    continue;
                }
                Despawn(map, o->GetSpawnId());
                p->StoreNewItem(dest, f->item, true);
                ++got;
            }
            CloseGossipMenuFor(p);
            ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("Picked up {} thing{} within {} yards{}.", got, got == 1 ? "" : "s",
                uint32(range), full ? Acore::StringFormat(" - {} didn't fit in your bags", full) : std::string("")));
            return;
        }
        if (action == A_PICKUP)
        {
            ItemPosCountVec dest;
            if (p->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, fu->item, 1) != EQUIP_ERR_OK)
            {
                ZeroCraftDeploy::RedError(p, "Your bags are full.");
                return MainMenu(p, go);
            }
            Despawn(map, id);
            p->StoreNewItem(dest, fu->item, true);
            CloseGossipMenuFor(p);
            ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("Picked up {}.", fu->name));
            return;
        }

        Position pos = go->GetPosition();
        float scale = go->GetObjectScale();
        float away = std::atan2(pos.GetPositionY() - p->GetPositionY(), pos.GetPositionX() - p->GetPositionX());
        float step = MOVE_STEPS[st.move];
        float turn = TURN_STEPS[st.turn] * float(M_PI) / 180.0f;
        float grow = 1.0f + SIZE_STEPS[st.size] / 100.0f;
        uint32 back = action / 100;   // 1 = move menu, 2 = turn menu, 3 = resize menu
        switch (action)
        {
            case A_FWD:      pos.m_positionX += step * std::cos(away); pos.m_positionY += step * std::sin(away); break;
            case A_BACK:     pos.m_positionX -= step * std::cos(away); pos.m_positionY -= step * std::sin(away); break;
            case A_LEFT:     pos.m_positionX += step * std::cos(away + float(M_PI) / 2); pos.m_positionY += step * std::sin(away + float(M_PI) / 2); break;
            case A_RIGHT:    pos.m_positionX += step * std::cos(away - float(M_PI) / 2); pos.m_positionY += step * std::sin(away - float(M_PI) / 2); break;
            case A_UP:       pos.m_positionZ += step; break;
            case A_DOWN:     pos.m_positionZ -= step; break;
            case A_HERE:
            {
                float x, y, z;
                p->GetClosePoint(x, y, z, p->GetCombatReach(), 3.0f, 0.0f);
                pos.Relocate(x, y, z, Position::NormalizeOrientation(p->GetOrientation() + float(M_PI)));
                break;
            }
            case A_TURNL:    pos.SetOrientation(Position::NormalizeOrientation(pos.GetOrientation() + turn)); break;
            case A_TURNR:    pos.SetOrientation(Position::NormalizeOrientation(pos.GetOrientation() - turn)); break;
            case A_TURNL90:  pos.SetOrientation(Position::NormalizeOrientation(pos.GetOrientation() + float(M_PI) / 2)); break;
            case A_TURNR90:  pos.SetOrientation(Position::NormalizeOrientation(pos.GetOrientation() - float(M_PI) / 2)); break;
            case A_FACE:
            case A_MFACE:    pos.SetOrientation(Position::NormalizeOrientation(away + float(M_PI))); break;
            case A_FACEAWAY: pos.SetOrientation(Position::NormalizeOrientation(away)); break;
            case A_BIG:      scale = std::min(scale * grow, 5.0f); break;
            case A_SMALL:    scale = std::max(scale / grow, 0.1f); break;
            case A_RESET:    scale = 1.0f; break;
            default:         return MainMenu(p, go);
        }
        std::string err;
        if (!CanBuildAt(p, pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ(), fu->stone, err, id))
        {
            ZeroCraftDeploy::RedError(p, err);
            return MainMenu(p, go);
        }
        uint32 phase = go->GetPhaseMask();
        uint32 entry = go->GetEntry();
        Despawn(map, id);
        ObjectGuid::LowType nid = Spawn(map, phase, entry, pos, scale, ownerGuild, ownerPlayer);
        GameObject* ngo = nid ? Find(map, nid) : nullptr;
        if (!ngo)
            return CloseGossipMenuFor(p);
        if (back == 1) return MoveMenu(p, ngo);
        if (back == 2) return TurnMenu(p, ngo);
        return ResizeMenu(p, ngo);
    }
}

// ============================================================================
// Profession Masters (NPCs 911150-911160): professions left the spellbook; talk to
// the right master and that profession's crafting window opens.
// ============================================================================
namespace ZeroCraftProf
{
    struct Prof { uint32 npc; char const* name; std::vector<uint32> ranks; };   // opener spells, lowest rank first
    static std::vector<Prof> const& All()
    {
        static std::vector<Prof> v = {
            { 911150, "Alchemy",        { 2259, 3101, 3464, 11611, 28596, 51304 } },
            { 911151, "Blacksmithing",  { 2018, 3100, 3538, 9785, 29844, 51300 } },
            { 911152, "Enchanting",     { 7411, 7412, 7413, 13920, 28029, 51313 } },
            { 911153, "Engineering",    { 4036, 4037, 4038, 12656, 30350, 51306 } },
            { 911154, "Inscription",    { 45357, 45358, 45359, 45360, 45361, 45363 } },
            { 911155, "Jewelcrafting",  { 25229, 25230, 28894, 28895, 28897, 51311 } },
            { 911156, "Leatherworking", { 2108, 3104, 3811, 10662, 32549, 51302 } },
            { 911157, "Tailoring",      { 3908, 3909, 3910, 12180, 26790, 51309 } },
            { 911158, "Cooking",        { 2550, 3102, 3413, 18260, 33359, 51296 } },
            { 911159, "First Aid",      { 3273, 3274, 7924, 10846, 27028, 45542 } },
            { 911160, "Smelting",       { 2656 } },
        };
        return v;
    }
    static Prof const* Of(uint32 entry)
    {
        for (Prof const& p : All())
            if (p.npc == entry)
                return &p;
        return nullptr;
    }
    static bool Is(uint32 entry) { return Of(entry) != nullptr; }

    static void Open(Player* player, Creature* c)
    {
        CloseGossipMenuFor(player);
        Prof const* pr = Of(c->GetEntry());
        if (!pr)
            return;
        uint32 spell = 0;
        for (uint32 id : pr->ranks)
            if (player->HasSpell(id))
                spell = id;   // the highest rank you know
        if (!spell)
        {
            ZeroCraftDeploy::RedError(player, std::string("You haven't learned ") + pr->name + ".");
            return;
        }
        player->CastSpell(player, spell, true);
        // the addon shows an "Open" button if the window didn't pop up by itself
        ChatHandler(player->GetSession()).SendSysMessage(Acore::StringFormat("ZCPROF:{}", spell));
    }
}

// ============================================================================
// The Enchanter (NPC 911172): pick one of the things you're wearing, pick an enchant
// (every enchant an enchanter can make up to skill 300), and it's done - free.
// ============================================================================
namespace ZeroCraftEnchanter
{
    struct Ench { uint32 id; uint32 itemClass; uint32 subMask; uint32 invMask; char const* name; };
    static std::vector<Ench> const& All()
    {
        static std::vector<Ench> v = {
        { 24, 4, 31u, 1048608u, "Chest - Minor Mana" },
        { 41, 4, 31u, 1048608u, "Chest - Minor Health" },
        { 44, 4, 31u, 1048608u, "Chest - Minor Absorption" },
        { 63, 4, 31u, 1048608u, "Chest - Lesser Absorption" },
        { 65, 4, 31u, 65536u, "Cloak - Minor Resistance" },
        { 66, 4, 64u, 0u, "Shield - Minor Stamina" },
        { 241, 2, 189939u, 0u, "Weapon - Lesser Striking" },
        { 242, 4, 31u, 1048608u, "Chest - Lesser Health" },
        { 243, 4, 31u, 512u, "Bracer - Minor Spirit" },
        { 246, 4, 31u, 1048608u, "Chest - Lesser Mana" },
        { 247, 4, 30u, 65536u, "Cloak - Minor Agility" },
        { 248, 4, 31u, 512u, "Bracer - Minor Strength" },
        { 249, 2, 189939u, 0u, "Weapon - Minor Beastslayer" },
        { 250, 2, 189939u, 0u, "Weapon - Minor Striking" },
        { 254, 4, 31u, 1048608u, "Chest - Health" },
        { 255, 4, 30u, 256u, "Boots - Lesser Spirit" },
        { 256, 4, 31u, 65536u, "Cloak - Lesser Fire Resistance" },
        { 368, 4, 30u, 65536u, "Cloak - Greater Agility" },
        { 369, 4, 30u, 512u, "Bracer - Major Intellect" },
        { 723, 4, 31u, 512u, "Bracer - Lesser Intellect" },
        { 724, 4, 30u, 256u, "Boots - Lesser Stamina" },
        { 744, 4, 0u, 65536u, "Cloak - Lesser Protection" },
        { 783, 4, 31u, 65536u, "Cloak - Minor Protection" },
        { 803, 2, 189939u, 0u, "Weapon - Fiery Weapon" },
        { 804, 4, 31u, 65536u, "Cloak - Lesser Shadow Resistance" },
        { 805, 2, 189939u, 0u, "Weapon - Greater Striking" },
        { 823, 4, 31u, 512u, "Bracer - Lesser Strength" },
        { 843, 4, 31u, 1048608u, "Chest - Mana" },
        { 844, 4, 31u, 1024u, "Gloves - Mining" },
        { 845, 4, 31u, 1024u, "Gloves - Herbalism" },
        { 847, 4, 31u, 1048608u, "Chest - Minor Stats" },
        { 848, 4, 30u, 65536u, "Cloak - Defense" },
        { 849, 4, 30u, 65536u, "Cloak - Lesser Agility" },
        { 850, 4, 30u, 1048608u, "Chest - Greater Health" },
        { 851, 4, 30u, 256u, "Boots - Spirit" },
        { 852, 4, 30u, 256u, "Boots - Stamina" },
        { 853, 2, 189939u, 0u, "Weapon - Lesser Beastslayer" },
        { 854, 2, 189939u, 0u, "Weapon - Lesser Elemental Slayer" },
        { 856, 4, 31u, 1024u, "Gloves - Strength" },
        { 857, 4, 30u, 1048608u, "Chest - Greater Mana" },
        { 863, 4, 64u, 0u, "Shield - Lesser Block" },
        { 865, 4, 31u, 1024u, "Gloves - Skinning" },
        { 866, 4, 31u, 1048608u, "Chest - Lesser Stats" },
        { 884, 4, 30u, 65536u, "Cloak - Greater Defense" },
        { 903, 4, 30u, 65536u, "Cloak - Resistance" },
        { 904, 4, 30u, 256u, "Boots - Agility" },
        { 905, 4, 30u, 512u, "Bracer - Intellect" },
        { 906, 4, 31u, 1024u, "Gloves - Advanced Mining" },
        { 907, 4, 64u, 0u, "Shield - Greater Spirit" },
        { 908, 4, 31u, 1048608u, "Chest - Superior Health" },
        { 909, 4, 31u, 1024u, "Gloves - Advanced Herbalism" },
        { 910, 4, 31u, 65536u, "Cloak - Stealth" },
        { 911, 4, 30u, 256u, "Boots - Minor Speed" },
        { 912, 2, 189939u, 0u, "Weapon - Demonslaying" },
        { 913, 4, 31u, 1048608u, "Chest - Superior Mana" },
        { 923, 4, 30u, 512u, "Bracer - Deflection" },
        { 924, 4, 31u, 512u, "Bracer - Minor Deflection" },
        { 925, 4, 30u, 512u, "Bracer - Lesser Deflection" },
        { 926, 4, 64u, 0u, "Shield - Frost Resistance" },
        { 927, 4, 31u, 1024u, "Gloves - Greater Strength" },
        { 928, 4, 31u, 1048608u, "Chest - Stats" },
        { 929, 4, 64u, 0u, "Shield - Greater Stamina" },
        { 930, 4, 31u, 1024u, "Gloves - Riding Skill" },
        { 931, 4, 31u, 1024u, "Gloves - Minor Haste" },
        { 943, 2, 189939u, 0u, "Weapon - Striking" },
        { 963, 2, 1378u, 0u, "2H Weapon - Greater Impact" },
        { 1593, 4, 30u, 512u, "Bracer - Assault" },
        { 1594, 4, 31u, 1024u, "Gloves - Assault" },
        { 1883, 4, 30u, 512u, "Bracer - Greater Intellect" },
        { 1884, 4, 30u, 512u, "Bracer - Superior Spirit" },
        { 1885, 4, 30u, 512u, "Bracer - Superior Strength" },
        { 1886, 4, 30u, 512u, "Bracer - Superior Stamina" },
        { 1887, 4, 30u, 256u, "Boots - Greater Agility" },
        { 1888, 4, 30u, 65536u, "Cloak - Greater Resistance" },
        { 1889, 4, 30u, 65536u, "Cloak - Superior Defense" },
        { 1890, 4, 64u, 0u, "Shield - Vitality" },
        { 1891, 4, 31u, 1048608u, "Chest - Greater Stats" },
        { 1892, 4, 31u, 1048608u, "Chest - Major Health" },
        { 1893, 4, 31u, 1048608u, "Chest - Major Mana" },
        { 1894, 2, 189939u, 0u, "Weapon - Icy Chill" },
        { 1896, 2, 1378u, 0u, "2H Weapon - Superior Impact" },
        { 1897, 2, 189939u, 0u, "Weapon - Superior Striking" },
        { 1898, 2, 189939u, 0u, "Weapon - Lifestealing" },
        { 1899, 2, 189939u, 0u, "Weapon - Unholy Weapon" },
        { 1900, 2, 189939u, 0u, "Weapon - Crusader" },
        { 1903, 2, 1378u, 0u, "2H Weapon - Major Spirit" },
        { 1904, 2, 1378u, 0u, "2H Weapon - Major Intellect" },
        { 2443, 2, 196083u, 0u, "Weapon - Winter's Might" },
        { 2463, 4, 30u, 65536u, "Cloak - Fire Resistance" },
        { 2504, 2, 58867u, 0u, "Weapon - Spellpower" },
        { 2505, 2, 58867u, 0u, "Weapon - Healing Power" },
        { 2563, 2, 58867u, 0u, "Weapon - Strength" },
        { 2564, 4, 31u, 1024u, "Gloves - Superior Agility" },
        { 2565, 4, 30u, 512u, "Bracer - Mana Regeneration" },
        { 2567, 2, 58867u, 0u, "Weapon - Mighty Spirit" },
        { 2568, 2, 58867u, 0u, "Weapon - Mighty Intellect" },
        { 2603, 4, 31u, 1024u, "Gloves - Fishing" },
        { 2613, 4, 31u, 1024u, "Gloves - Threat" },
        { 2614, 4, 31u, 1024u, "Gloves - Shadow Power" },
        { 2615, 4, 31u, 1024u, "Gloves - Frost Power" },
        { 2616, 4, 31u, 1024u, "Gloves - Fire Power" },
        { 2617, 4, 31u, 1024u, "Gloves - Healing Power" },
        { 2619, 4, 31u, 65536u, "Cloak - Greater Fire Resistance" },
        { 2620, 4, 31u, 65536u, "Cloak - Greater Nature Resistance" },
        { 2621, 4, 31u, 65536u, "Cloak - Subtlety" },
        { 2622, 4, 31u, 65536u, "Cloak - Dodge" },
        { 2646, 2, 1378u, 0u, "2H Weapon - Agility" },
        { 2647, 4, 30u, 512u, "Bracer - Brawn" },
        { 2650, 4, 30u, 512u, "Bracer - Healing Power" },
        { 2653, 4, 64u, 0u, "Shield - Tough Shield" },
        { 2656, 4, 30u, 256u, "Boots - Vitality" },
        { 2662, 4, 30u, 65536u, "Cloak - Major Armor" },
        { 2934, 4, 31u, 1024u, "Gloves - Blasting" },
        { 3150, 4, 31u, 1048608u, "Chest - Restore Mana Prime" },
        { 3858, 4, 30u, 256u, "Boots - Lesser Accuracy" },
        };
        return v;
    }
    static bool Fits(Ench const& e, ItemTemplate const* t)
    {
        if (!t || int32(t->Class) != int32(e.itemClass))
            return false;
        if (e.subMask && !(e.subMask & (1u << t->SubClass)))
            return false;
        if (e.invMask && !(e.invMask & (1u << t->InventoryType)))
            return false;
        return true;
    }
    static void Slots(Player* p, Creature* c)
    {
        ClearGossipMenuFor(p);
        for (uint8 slot = EQUIPMENT_SLOT_START; slot < EQUIPMENT_SLOT_END; ++slot)
            if (Item* it = p->GetItemByPos(INVENTORY_SLOT_BAG_0, slot))
            {
                bool any = false;
                for (Ench const& e : All())
                    if (Fits(e, it->GetTemplate())) { any = true; break; }
                if (any)
                    AddGossipItemFor(p, GOSSIP_ICON_TRAINER, it->GetTemplate()->Name1, GOSSIP_SENDER_MAIN, 100 + slot);
            }
        SendGossipMenuFor(p, DEFAULT_GOSSIP_MESSAGE, c->GetGUID());
    }
    static void Choices(Player* p, Creature* c, uint8 slot)
    {
        Item* it = p->GetItemByPos(INVENTORY_SLOT_BAG_0, slot);
        if (!it)
            return Slots(p, c);
        ClearGossipMenuFor(p);
        AddGossipItemFor(p, GOSSIP_ICON_CHAT, "Back", GOSSIP_SENDER_MAIN, 1);
        uint32 n = 0;
        for (Ench const& e : All())
            if (Fits(e, it->GetTemplate()) && sSpellItemEnchantmentStore.LookupEntry(e.id) && n < 30)
            {
                AddGossipItemFor(p, GOSSIP_ICON_INTERACT_1, e.name, GOSSIP_SENDER_MAIN, 1000000 + slot * 10000 + e.id);
                ++n;
            }
        SendGossipMenuFor(p, DEFAULT_GOSSIP_MESSAGE, c->GetGUID());
    }
    static void Apply(Player* p, Creature* c, uint8 slot, uint32 enchId)
    {
        Item* it = p->GetItemByPos(INVENTORY_SLOT_BAG_0, slot);
        if (!it)
            return Slots(p, c);
        bool ok = false;
        for (Ench const& e : All())
            if (e.id == enchId && Fits(e, it->GetTemplate()))
                ok = true;
        if (!ok || !sSpellItemEnchantmentStore.LookupEntry(enchId))
            return Slots(p, c);
        p->ApplyEnchantment(it, PERM_ENCHANTMENT_SLOT, false);
        it->SetEnchantment(PERM_ENCHANTMENT_SLOT, enchId, 0, 0, p->GetGUID());
        p->ApplyEnchantment(it, PERM_ENCHANTMENT_SLOT, true);
        std::string name;
        for (Ench const& e : All())
            if (e.id == enchId) name = e.name;
        ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} enchanted: {}.", it->GetTemplate()->Name1, name));
        Slots(p, c);
    }
}

class npc_zerocraft_enchanter : public CreatureScript
{
public:
    npc_zerocraft_enchanter() : CreatureScript("npc_zerocraft_enchanter") { }
    bool OnGossipHello(Player* player, Creature* creature) override
    {
        ZeroCraftEnchanter::Slots(player, creature);
        return true;
    }
    bool OnGossipSelect(Player* player, Creature* creature, uint32 /*sender*/, uint32 action) override
    {
        if (action >= 1000000)
            ZeroCraftEnchanter::Apply(player, creature, uint8((action - 1000000) / 10000), (action - 1000000) % 10000);
        else if (action >= 100 && action < 100 + EQUIPMENT_SLOT_END)
            ZeroCraftEnchanter::Choices(player, creature, uint8(action - 100));
        else if (action == 1)
            ZeroCraftEnchanter::Slots(player, creature);
        else
            CloseGossipMenuFor(player);
        return true;
    }
};

class npc_zerocraft_profession : public CreatureScript
{
public:
    npc_zerocraft_profession() : CreatureScript("npc_zerocraft_profession") { }
    bool OnGossipHello(Player* player, Creature* creature) override
    {
        ZeroCraftProf::Open(player, creature);
        return true;
    }
};

namespace ZeroCraftBuild
{
    // kind: 0 = game object, 1 = creature (plain, not owned), 2 = deploy scroll entry (owned NPC)
    struct Thing { uint32 action; uint32 kind; uint32 entry; char const* name; uint32 group; };
    static std::vector<Thing> const& Things()
    {
        static std::vector<Thing> t = {
            { 1000, 1, 31144, "Training Dummy", 1 },
            { 1001, 1, 6491, "Spirit Healer", 1 },
            { 1002, 0, 177232, "Moonwell", 1 },
            { 1003, 0, 1744, "Anvil", 10 },
            { 1004, 0, 172911, "The Black Anvil", 10 },
            { 1005, 0, 1685, "Forge", 10 },
            { 1006, 0, 1915, "Cooking Fire", 10 },
            { 1007, 0, 3769, "Potbelly Stove", 10 },
            { 1008, 0, 186143, "Clay Oven", 10 },
            { 1009, 0, 194490, "Grill", 10 },
            { 1010, 0, 2719, "Bubbling Cauldron", 10 },
            { 1011, 0, 12665, "Cooking Table", 10 },
            { 1012, 0, 142075, "Human (Stormwind)", 5 },
            { 1013, 0, 32349, "Dwarf (Ironforge)", 5 },
            { 1014, 0, 142109, "Night Elf (Darnassus)", 5 },
            { 1015, 0, 182948, "Draenei (Exodar)", 5 },
            { 1016, 0, 143981, "Orc (Orgrimmar)", 5 },
            { 1017, 0, 143983, "Tauren (Thunder Bluff)", 5 },
            { 1018, 0, 177044, "Forsaken (Undercity)", 5 },
            { 1019, 0, 181883, "Blood Elf (Silvermoon)", 5 },
            { 1020, 0, 144112, "Goblin (Gadgetzan)", 5 },
            { 1021, 0, 179895, "Wildhammer (Aerie Peak)", 5 },
            { 1022, 0, 187316, "Northrend (Borean Tundra)", 5 },
            { 1023, 0, 188241, "Northrend (Grizzly Hills)", 5 },
            { 1024, 0, 188604, "Northrend (Dragonblight)", 5 },
            { 1025, 0, 190915, "Ebon Hold (Death Knight)", 5 },
            { 1026, 0, 178824, "Meeting Stone (Barrens)", 6 },
            { 1027, 0, 178826, "Meeting Stone (Feralas)", 6 },
            { 1028, 0, 178828, "Meeting Stone (Ashenvale)", 6 },
            { 1029, 0, 178831, "Meeting Stone (Plaguelands)", 6 },
            { 1030, 0, 178845, "Meeting Stone (Silverpine)", 6 },
            { 1031, 0, 194097, "Summoning Portal (Northrend)", 6 },
            { 1032, 0, 176296, "Portal to Stormwind", 7 },
            { 1033, 0, 176497, "Portal to Ironforge", 7 },
            { 1034, 0, 176498, "Portal to Darnassus", 7 },
            { 1035, 0, 182351, "Portal to Exodar", 7 },
            { 1036, 0, 189993, "Portal to Theramore", 7 },
            { 1037, 0, 176499, "Portal to Orgrimmar", 7 },
            { 1038, 0, 176500, "Portal to Thunder Bluff", 7 },
            { 1039, 0, 176501, "Portal to Undercity", 7 },
            { 1040, 0, 182352, "Portal to Silvermoon", 7 },
            { 1041, 0, 189994, "Portal to Stonard", 7 },
            { 1042, 0, 195141, "Portal to Blasted Lands", 7 },
            { 1043, 0, 181146, "Portal to Karazhan", 7 },
            { 1044, 2, 1267, "Musician", 8 },
            { 1045, 2, 6213, "Dancer", 8 },
            { 1046, 2, 17163, "Stable Master", 8 },
            { 1047, 1, 620, "Chicken", 9 },
            { 1048, 1, 1933, "Sheep", 9 },
            { 1049, 1, 2442, "Cow", 9 },
            { 1050, 1, 10685, "Swine", 9 },
            { 1051, 1, 721, "Rabbit", 9 },
            { 1052, 1, 5951, "Hare", 9 },
            { 1053, 1, 1412, "Squirrel", 9 },
            { 1054, 1, 2620, "Prairie Dog", 9 },
            { 1055, 1, 883, "Deer", 9 },
            { 1056, 1, 4166, "Gazelle", 9 },
            { 1057, 1, 1420, "Toad", 9 },
            { 1058, 1, 7385, "Bombay Cat", 9 },
            { 1059, 1, 7386, "White Kitten", 9 },
            { 1060, 1, 15475, "Beetle", 9 },
            { 1061, 1, 2914, "Snake", 9 },
            { 1062, 0, 1798, "Campfire", 11 },
            { 1063, 0, 180434, "Bonfire", 11 },
            { 1064, 0, 180473, "Brazier", 11 },
            { 1065, 0, 179977, "Lantern", 11 },
            { 1066, 0, 19457, "Lamp Post", 11 },
            { 1067, 0, 180043, "Standing Torch", 11 },
            { 1068, 0, 180352, "Wall Torch", 11 },
            { 1069, 0, 180339, "Candles", 11 },
            { 1070, 0, 180031, "Food Tent", 12 },
            { 1071, 0, 180030, "Fortune Teller's Tent", 12 },
            { 1072, 0, 179966, "Carnival Tent", 12 },
            { 1073, 0, 180032, "Souvenir Tent", 12 },
            { 1074, 0, 180034, "Ticket Master Tent", 12 },
            { 1075, 0, 180039, "Animal Trainer Tent", 12 },
            { 1076, 0, 180042, "Target Practice Tent", 12 },
            { 1077, 0, 19637, "Human Vendor Tent", 12 },
            { 1078, 0, 186680, "Brewfest Canopy", 12 },
            { 1079, 0, 186681, "Brewfest Food Tent", 12 },
            { 1080, 0, 186682, "Brewfest Beer Tent", 12 },
            { 1081, 0, 24388, "Stone Bench", 13 },
            { 1082, 0, 24538, "Wooden Bench", 13 },
            { 1083, 0, 2413, "Wooden Chair", 13 },
            { 1084, 0, 193909, "Stool", 13 },
            { 1085, 0, 179118, "Throne", 13 },
            { 1086, 0, 13948, "Fancy Bed", 13 },
            { 1087, 0, 181075, "Table", 13 },
            { 1088, 0, 180698, "Party Table", 13 },
            { 1089, 0, 180324, "Dwarven Table", 13 },
            { 1090, 0, 183268, "Bookshelf", 13 },
            { 1091, 0, 180334, "Stormwind Rug", 13 },
            { 1092, 0, 188346, "Tauren Rug", 13 },
            { 1093, 0, 19626, "Sign Post", 13 },
            { 1094, 0, 19395, "Spike Wall", 14 },
            { 1095, 0, 19444, "Rock Wall", 14 },
            { 1096, 0, 19454, "Fence", 14 },
            { 1097, 0, 19455, "Stone Fence", 14 },
            { 1098, 0, 211062, "Elwynn Fence", 14 },
            { 1099, 0, 19435, "Gate", 14 },
            { 1100, 0, 19423, "Guard Tower", 14 },
            { 1101, 0, 19450, "Watch Tower", 14 },
            { 1102, 0, 20812, "Orc Tower", 14 },
            { 1103, 0, 19482, "Troll Watch Tower", 14 },
            { 1104, 0, 19452, "Human Ballista", 14 },
            { 1105, 0, 19453, "Orc Catapult", 14 },
            { 1106, 0, 183122, "Alliance Cannon", 14 },
            { 1107, 0, 190576, "Weapon Rack", 14 },
            { 1108, 0, 152079, "Horde Banner", 14 },
            { 1109, 0, 178365, "Alliance Banner", 14 },
            { 1110, 0, 19410, "Lothar Statue", 15 },
            { 1111, 0, 19460, "Lion Statue", 15 },
            { 1112, 0, 19485, "Snake Statue", 15 },
            { 1113, 0, 19506, "Mountain King Statue", 15 },
            { 1114, 0, 19509, "Mage Statue", 15 },
            { 1115, 0, 19510, "Spearman Statue", 15 },
            { 1116, 0, 19397, "Goblin Statue", 15 },
            { 1117, 0, 19507, "Fountain", 15 },
            { 1118, 0, 19459, "Ruined Fountain", 15 },
            { 1119, 0, 20818, "Night Elf Moon Well", 15 },
            { 1120, 0, 19483, "Holy Spring Well", 15 },
            { 1121, 0, 19494, "Emerald Dream Tree", 16 },
            { 1122, 0, 19495, "Emerald Dream Tree 2", 16 },
            { 1123, 0, 19493, "Spinning Flower", 16 },
            { 1124, 0, 185492, "Dream Flower", 16 },
            { 1125, 0, 181103, "Flower", 16 },
            { 1126, 0, 19429, "Hay Stack", 16 },
            { 1127, 0, 180700, "Hay Bale", 16 },
            { 1128, 0, 179968, "Haystack", 16 },
            { 1129, 0, 19432, "Scarecrow", 16 },
            { 1130, 0, 180219, "Pumpkin Patch", 16 },
            { 1131, 0, 181686, "Lumber Pile", 16 },
            { 1132, 0, 178425, "Christmas Tree", 17 },
            { 1133, 0, 186709, "Brewfest Keg", 17 },
            { 1134, 0, 186717, "Brewfest Banner", 17 },
            { 1135, 0, 186737, "Brewfest Wagon", 17 },
            { 1136, 0, 186327, "Pumpkin Table", 17 },
            { 1137, 0, 180026, "Darkmoon Signpost", 17 },
            { 1138, 0, 179967, "Barrel", 18 },
            { 1139, 0, 179976, "Beer Keg", 18 },
            { 1140, 0, 179969, "Supply Crate", 18 },
            { 1141, 0, 1560, "Storage Chest", 18 },
            { 1142, 0, 126260, "Ancient Chest", 18 },
            { 1143, 0, 178666, "Gypsy Wagon", 18 },
            { 1144, 0, 19430, "Hay Wagon", 18 },
            { 1145, 0, 182403, "Broken Cart", 18 },
            { 1146, 0, 19481, "Small Boat", 18 },
            { 1147, 3, 911150, "Master Alchemist", 19 },
            { 1148, 3, 911151, "Master Blacksmith", 19 },
            { 1149, 3, 911152, "Master Enchanter", 19 },
            { 1150, 3, 911153, "Master Engineer", 19 },
            { 1151, 3, 911154, "Master Scribe (Inscription)", 19 },
            { 1152, 3, 911155, "Master Jewelcrafter", 19 },
            { 1153, 3, 911156, "Master Leatherworker", 19 },
            { 1154, 3, 911157, "Master Tailor", 19 },
            { 1155, 3, 911158, "Master Chef (Cooking)", 19 },
            { 1156, 3, 911159, "Master Healer (First Aid)", 19 },
            { 1157, 3, 911160, "Master Miner (Smelting)", 19 },
        };
        return t;
    }
    static std::vector<std::pair<uint32, char const*>> const& Groups()
    {
        static std::vector<std::pair<uint32, char const*>> g = {
            { 1, "Useful" },
            { 19, "Profession Masters" },
            { 10, "Crafting stations" },
            { 5, "Mailboxes" },
            { 6, "Summoning stones" },
            { 7, "Portals" },
            { 8, "People (musician, dancer, stable master)" },
            { 9, "Animals" },
            { 11, "Fire and light" },
            { 12, "Tents" },
            { 13, "Furniture" },
            { 14, "Walls and defenses" },
            { 15, "Statues and monuments" },
            { 16, "Nature" },
            { 17, "Festive" },
            { 18, "Crates, barrels and chests" },
        };
        return g;
    }
    static std::unordered_map<ObjectGuid::LowType, Position> pendingPos;
    static const uint32 LIMIT = 150;
    enum { A_REMOVE = 3, A_BACK = 4, A_EDITNEAR = 5, A_GROUP = 100 }; // A_GROUP + group id opens that list

    static uint32 CountFor(Player* p)
    {
        std::string who = p->GetGuildId() ? Acore::StringFormat("owner_guild = {}", p->GetGuildId())
                                          : Acore::StringFormat("owner_guild = 0 AND owner_player = {}", p->GetGUID().GetCounter());
        if (QueryResult r = WorldDatabase.Query("SELECT COUNT(*) FROM zerocraft_placed WHERE " + who))
            return uint32((*r)[0].Get<uint64>());
        return 0;
    }

    static bool Place(Player* player, Thing const& t, Position const& pos)
    {
        Map* map = player->GetMap();
        if (t.kind != 0)
        {
            std::string err;
            if (!ZeroCraftHome::CanBuildAt(player, pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ(), false, err))
            {
                ZeroCraftDeploy::RedError(player, err);
                return false;
            }
        }
        if (t.kind == 2)
            return ZeroCraftDeploy::Deploy(player, t.entry, pos);
        if (t.kind == 3)
            return ZeroCraftDeploy::Deploy(player, 0, pos, t.entry);
        if (t.kind == 1)
        {
            Creature* c = new Creature();
            if (!c->Create(map->GenerateLowGuid<HighGuid::Unit>(), map, player->GetPhaseMaskForSpawn(), t.entry, 0,
                           pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ(), pos.GetOrientation()))
            {
                delete c;
                return false;
            }
            c->SaveToDB(map->GetId(), (1 << map->GetSpawnMode()), player->GetPhaseMaskForSpawn());
            ObjectGuid::LowType id = c->GetSpawnId();
            c->CleanupsBeforeDelete();
            delete c;
            // record the owner BEFORE it appears, so a Summoning Stone claim doesn't sweep it away
            WorldDatabase.DirectExecute(Acore::StringFormat("INSERT INTO zerocraft_placed (kind, spawn_id, owner_guild, owner_player) VALUES (1, {}, {}, {})",
                id, player->GetGuildId(), player->GetGUID().GetCounter()));
            c = new Creature();
            if (!c->LoadCreatureFromDB(id, map, true, true))
            {
                delete c;
                return false;
            }
            sObjectMgr->AddCreatureToGrid(id, sObjectMgr->GetCreatureData(id));
            return true;
        }

        uint32 goEntry = t.entry;
        if (ZeroCraftHome::OfGo(t.entry + ZeroCraftHome::CLONE))
            goEntry = t.entry + ZeroCraftHome::CLONE;   // the clickable copy
        {
            std::string err;
            ZeroCraftHome::Furn const* fu = ZeroCraftHome::OfGo(goEntry);
            if (!ZeroCraftHome::CanBuildAt(player, pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ(), fu && fu->stone, err))
            {
                ZeroCraftDeploy::RedError(player, err);
                return false;
            }
        }
        GameObjectTemplate const* info = sObjectMgr->GetGameObjectTemplate(goEntry);
        if (!info)
            return false;
        GameObject* go = new GameObject();
        G3D::Quat rot = G3D::Quat::fromAxisAngleRotation(G3D::Vector3::unitZ(), pos.GetOrientation());
        if (!go->Create(map->GenerateLowGuid<HighGuid::GameObject>(), goEntry, map, player->GetPhaseMaskForSpawn(),
                        pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ(), pos.GetOrientation(), rot, 0, GO_STATE_READY))
        {
            delete go;
            return false;
        }
        go->SaveToDB(map->GetId(), (1 << map->GetSpawnMode()), player->GetPhaseMaskForSpawn());
        ObjectGuid::LowType id = go->GetSpawnId();
        delete go;
        go = new GameObject();
        if (!go->LoadGameObjectFromDB(id, map, true))
        {
            delete go;
            return false;
        }
        sObjectMgr->AddGameobjectToGrid(id, sObjectMgr->GetGameObjectData(id));
        WorldDatabase.DirectExecute(Acore::StringFormat("INSERT INTO zerocraft_placed (kind, spawn_id, owner_guild, owner_player, owner_guild_name) VALUES (0, {}, {}, {}, COALESCE((SELECT name FROM acore_characters.guild WHERE guildid = {}), ''))",
            id, player->GetGuildId(), player->GetGUID().GetCounter(), player->GetGuildId()));
        return true;
    }

    // take back the nearest thing (within 10 yards) your guild placed
    // For things that are hard to click (flat logs, rugs...): open the edit menu of the
    // nearest object your guild built, as if you had clicked it.
    static void EditNearest(Player* player);
    static struct NearbyInit { NearbyInit() { ZeroCraftHome::EditNearby = &EditNearest; } } nearbyInit;
    static void EditNearest(Player* player)
    {
        std::string who = Acore::StringFormat("owner_guild = 0 AND owner_player = {}", player->GetGUID().GetCounter());
        if (Guild* g = sGuildMgr->GetGuildById(player->GetGuildId()))
        {
            std::string gname = g->GetName();
            WorldDatabase.EscapeString(gname);
            who = Acore::StringFormat("owner_guild = {} OR owner_guild_name = '{}'", g->GetId(), gname);
        }
        std::vector<std::pair<float, GameObject*>> near;
        if (QueryResult r = WorldDatabase.Query("SELECT spawn_id FROM zerocraft_placed WHERE kind = 0 AND (" + who + ")"))
            do
            {
                auto range = player->GetMap()->GetGameObjectBySpawnIdStore().equal_range((*r)[0].Get<uint32>());
                for (auto it = range.first; it != range.second; ++it)
                    if (it->second->IsInWorld() && ZeroCraftHome::OfGo(it->second->GetEntry()) && !ZeroCraftHome::OfGo(it->second->GetEntry())->stone)
                    {
                        float d = player->GetDistance(it->second);
                        if (d < 100.0f)
                            near.push_back({ d, it->second });
                    }
            } while (r->NextRow());
        if (near.empty())
        {
            ZeroCraftDeploy::RedError(player, "Nothing your guild built is within 100 yards.");
            return;
        }
        std::sort(near.begin(), near.end(), [](auto const& a, auto const& b) { return a.first < b.first; });
        // several things close by: pick which one (handy for flat things like rune circles and logs)
        auto& list = ZeroCraftHome::pickList[player->GetGUID().GetCounter()];
        list.clear();
        ClearGossipMenuFor(player);
        for (size_t i = 0; i < near.size() && i < 20; ++i)
        {
            list.push_back(near[i].second->GetGUID());
            ZeroCraftHome::Furn const* fu = ZeroCraftHome::OfGo(near[i].second->GetEntry());
            AddGossipItemFor(player, GOSSIP_ICON_BATTLE, Acore::StringFormat("|cffcc0000Delete|r {} ({} yd)", fu ? fu->name : std::string("?"), int32(near[i].first + 0.5f)),
                GOSSIP_SENDER_MAIN, ZeroCraftHome::A_PICK + uint32(i));
        }
        SendGossipMenuFor(player, ZeroCraftHome::T_MAIN, near[0].second->GetGUID());
    }

    static void RemoveNearest(Player* player)
    {
        std::string who = Acore::StringFormat("owner_guild = 0 AND owner_player = {}", player->GetGUID().GetCounter());
        if (Guild* g = sGuildMgr->GetGuildById(player->GetGuildId()))
        {
            std::string gname = g->GetName();
            WorldDatabase.EscapeString(gname);
            who = Acore::StringFormat("owner_guild = {} OR owner_guild_name = '{}'", g->GetId(), gname);
        }
        QueryResult r = WorldDatabase.Query("SELECT kind, spawn_id FROM zerocraft_placed WHERE " + who);
        float best = 10.0f; uint32 bestKind = 0, bestId = 0;
        if (r)
            do
            {
                uint32 kind = (*r)[0].Get<uint32>(), id = (*r)[1].Get<uint32>();
                float x, y, z; uint32 mapId;
                if (kind == 1) { CreatureData const* d = sObjectMgr->GetCreatureData(id); if (!d) continue; x = d->posX; y = d->posY; z = d->posZ; mapId = d->mapid; }
                else { GameObjectData const* d = sObjectMgr->GetGameObjectData(id); if (!d) continue; x = d->posX; y = d->posY; z = d->posZ; mapId = d->mapid; }
                if (mapId != player->GetMapId()) continue;
                float dist = player->GetExactDist(x, y, z);
                if (dist < best) { best = dist; bestKind = kind; bestId = id; }
            } while (r->NextRow());
        if (!bestId)
        {
            ZeroCraftDeploy::RedError(player, "Nothing your guild built is within 10 yards.");
            return;
        }
        Map* map = player->GetMap();
        if (bestKind == 1)
        {
            auto range = map->GetCreatureBySpawnIdStore().equal_range(bestId);
            for (auto it = range.first; it != range.second; ++it)
                it->second->AddObjectToRemoveList();
            if (CreatureData const* d = sObjectMgr->GetCreatureData(bestId))
                sObjectMgr->RemoveCreatureFromGrid(bestId, d);
            sObjectMgr->DeleteCreatureData(bestId);
            WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM creature WHERE guid = {}", bestId));
        }
        else
        {
            auto range = map->GetGameObjectBySpawnIdStore().equal_range(bestId);
            std::vector<GameObject*> gos;
            for (auto it = range.first; it != range.second; ++it) gos.push_back(it->second);
            for (GameObject* go : gos) { go->SetRespawnTime(0); go->Delete(); }
            if (GameObjectData const* d = sObjectMgr->GetGameObjectData(bestId))
                sObjectMgr->RemoveGameobjectFromGrid(bestId, d);
            sObjectMgr->DeleteGOData(bestId);
            WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM gameobject WHERE guid = {}", bestId));
        }
        WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM zerocraft_placed WHERE kind = {} AND spawn_id = {}", bestKind, bestId));
        ChatHandler(player->GetSession()).SendSysMessage("Taken down.");
    }
}

// Destructor's Rod (60419): lists everything your guild built within 100 yards - click one and it's gone.
// (The list lives on the rod itself, so it stays open no matter how far away the things are.)
class ZeroCraftDestructorRod : public ItemScript
{
public:
    ZeroCraftDestructorRod() : ItemScript("item_zerocraft_destructor") { }
    static std::unordered_map<ObjectGuid::LowType, std::vector<ObjectGuid>> lists;

    static void Menu(Player* player, Item* item)
    {
        std::string who = Acore::StringFormat("owner_guild = 0 AND owner_player = {}", player->GetGUID().GetCounter());
        if (Guild* g = sGuildMgr->GetGuildById(player->GetGuildId()))
        {
            std::string gname = g->GetName();
            WorldDatabase.EscapeString(gname);
            who = Acore::StringFormat("owner_guild = {} OR owner_guild_name = '{}'", g->GetId(), gname);
        }
        std::vector<std::pair<float, GameObject*>> near;
        if (QueryResult r = WorldDatabase.Query("SELECT spawn_id FROM zerocraft_placed WHERE kind = 0 AND (" + who + ")"))
            do
            {
                auto range = player->GetMap()->GetGameObjectBySpawnIdStore().equal_range((*r)[0].Get<uint32>());
                for (auto it = range.first; it != range.second; ++it)
                {
                    ZeroCraftHome::Furn const* fu = it->second->IsInWorld() ? ZeroCraftHome::OfGo(it->second->GetEntry()) : nullptr;
                    if (!fu || fu->stone)
                        continue;
                    float d = player->GetDistance(it->second);
                    if (d < 100.0f)
                        near.push_back({ d, it->second });
                }
            } while (r->NextRow());
        std::sort(near.begin(), near.end(), [](auto const& a, auto const& b) { return a.first < b.first; });
        auto& list = lists[player->GetGUID().GetCounter()];
        list.clear();
        ClearGossipMenuFor(player);
        for (size_t i = 0; i < near.size() && i < 25; ++i)
        {
            list.push_back(near[i].second->GetGUID());
            AddGossipItemFor(player, GOSSIP_ICON_BATTLE, Acore::StringFormat("|cffcc0000Delete|r {} ({} yd)",
                ZeroCraftHome::OfGo(near[i].second->GetEntry())->name, int32(near[i].first + 0.5f)), GOSSIP_SENDER_MAIN, 1000 + uint32(i));
        }
        if (near.empty())
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Nothing your guild built is within 100 yards.", GOSSIP_SENDER_MAIN, 1);
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    }

    bool OnUse(Player* player, Item* item, SpellCastTargets const& /*targets*/) override
    {
        Menu(player, item);
        return true;
    }

    void OnGossipSelect(Player* player, Item* item, uint32 /*sender*/, uint32 action) override
    {
        auto& list = lists[player->GetGUID().GetCounter()];
        if (action < 1000 || action - 1000 >= list.size())
            return CloseGossipMenuFor(player);
        GameObject* go = player->GetMap()->GetGameObject(list[action - 1000]);
        ZeroCraftHome::Furn const* fu = go ? ZeroCraftHome::OfGo(go->GetEntry()) : nullptr;
        if (!fu || fu->stone)
            return Menu(player, item);
        if (!ZeroCraftHome::CanEdit(player, go))
        {
            ZeroCraftDeploy::RedError(player, "You don't have building privilege for that.");
            return Menu(player, item);
        }
        std::string name = fu->name;
        ZeroCraftHome::Despawn(go->GetMap(), go->GetSpawnId());
        ChatHandler(player->GetSession()).PSendSysMessage(Acore::StringFormat("{} destroyed.", name));
        Menu(player, item);   // stays open for the next one
    }
};
std::unordered_map<ObjectGuid::LowType, std::vector<ObjectGuid>> ZeroCraftDestructorRod::lists;

class ZeroCraftBuilderKit : public ItemScript
{
public:
    ZeroCraftBuilderKit() : ItemScript("item_zerocraft_builder") { }

    static void Menu(Player* player, Item* item, uint32 group)
    {
        ClearGossipMenuFor(player);
        if (!group)
        {
            AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "Take down the nearest thing we built.", GOSSIP_SENDER_MAIN, ZeroCraftBuild::A_REMOVE);
        AddGossipItemFor(player, GOSSIP_ICON_INTERACT_2, "Edit the nearest thing we built (move, turn, pick up).", GOSSIP_SENDER_MAIN, ZeroCraftBuild::A_EDITNEAR);
            for (auto const& g : ZeroCraftBuild::Groups())
                AddGossipItemFor(player, GOSSIP_ICON_INTERACT_1, std::string(g.second) + "...", GOSSIP_SENDER_MAIN, ZeroCraftBuild::A_GROUP + g.first);
        }
        else
        {
            for (auto const& t : ZeroCraftBuild::Things())
                if (t.group == group)
                    AddGossipItemFor(player, t.kind ? GOSSIP_ICON_TRAINER : GOSSIP_ICON_TABARD, t.name, GOSSIP_SENDER_MAIN, t.action);
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Back.", GOSSIP_SENDER_MAIN, ZeroCraftBuild::A_BACK);
        }
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    }

    bool OnUse(Player* player, Item* item, SpellCastTargets const& targets) override
    {
        if (!targets.HasDst())
        {
            ZeroCraftDeploy::RedError(player, "Click a spot on the ground.");
            return true;
        }
        WorldLocation const* dst = targets.GetDstPos();
        if (player->GetMap()->Instanceable() || player->GetTransport())
        {
            ZeroCraftDeploy::RedError(player, "You can only build in the open world.");
            return true;
        }
        if (player->GetExactDist(dst->GetPositionX(), dst->GetPositionY(), dst->GetPositionZ()) > 45.0f)
        {
            ZeroCraftDeploy::RedError(player, "That spot is too far away.");
            return true;
        }
        Position p;
        p.Relocate(dst->GetPositionX(), dst->GetPositionY(), dst->GetPositionZ(), player->GetOrientation());
        ZeroCraftBuild::pendingPos[player->GetGUID().GetCounter()] = p;
        Menu(player, item, 0);
        return true;
    }

    void OnGossipSelect(Player* player, Item* item, uint32 /*sender*/, uint32 action) override
    {
        if (action > ZeroCraftBuild::A_GROUP && action < 1000)
            return Menu(player, item, action - ZeroCraftBuild::A_GROUP);
        if (action == ZeroCraftBuild::A_BACK)
            return Menu(player, item, 0);
        CloseGossipMenuFor(player);
        if (action == ZeroCraftBuild::A_REMOVE)
            return ZeroCraftBuild::RemoveNearest(player);
        if (action == ZeroCraftBuild::A_EDITNEAR)
            return ZeroCraftBuild::EditNearest(player);

        auto pos = ZeroCraftBuild::pendingPos.find(player->GetGUID().GetCounter());
        if (pos == ZeroCraftBuild::pendingPos.end())
            return;
        bool ownedNpc = false;
        for (auto const& t : ZeroCraftBuild::Things())
            if (t.action == action && t.kind == 2) ownedNpc = true;
        (void)ownedNpc; // no limit on how much a guild can build
        for (auto const& t : ZeroCraftBuild::Things())
            if (t.action == action)
            {
                if (ZeroCraftBuild::Place(player, t, pos->second))
                    ChatHandler(player->GetSession()).PSendSysMessage(Acore::StringFormat("Built: {}.", t.name));
                else
                    ZeroCraftDeploy::RedError(player, "Couldn't build that here.");
                break;
            }
    }
};

class ZeroCraftBuilderGiver : public PlayerScript
{
public:
    ZeroCraftBuilderGiver() : PlayerScript("ZeroCraftBuilderGiver") { }
    void OnPlayerLogin(Player* player) override
    {
        static uint32 entry = 0;
        static bool looked = false;
        if (!looked)
        {
            looked = true;
            uint32 sid = sObjectMgr->GetScriptId("item_zerocraft_builder");
            for (auto const& kv : *sObjectMgr->GetItemTemplateStore())
                if (kv.second.ScriptId == sid) { entry = kv.first; break; }
        }
        // retired: replaced by the themed Builder's Scrolls
        if (entry && player->HasItemCount(entry, 1, true))
            player->DestroyItemCount(entry, 255, true, false);
    }
};

// ============================================================================
// Builder's Catalog: everything placeable found in the game files (about 1,700
// objects), sorted by style (Human, Orc, Northrend, Outland...). Click a spot,
// pick a style, flip through the pages, pick an object. Shares the Builder's
// Kit limit and its "take down" option.
// ============================================================================
namespace ZeroCraftCatalog
{
    struct Row { uint32 entry; std::string name; };
    static std::vector<std::pair<std::string, std::vector<Row>>>& Cats()
    {
        static std::vector<std::pair<std::string, std::vector<Row>>> c;
        static bool loaded = false;
        if (!loaded)
        {
            loaded = true;
            std::map<std::string, std::vector<Row>> m;
            if (QueryResult r = WorldDatabase.Query("SELECT category, name, entry FROM zerocraft_catalog ORDER BY category, name"))
                do { m[(*r)[0].Get<std::string>()].push_back({ (*r)[2].Get<uint32>(), (*r)[1].Get<std::string>() }); } while (r->NextRow());
            for (auto& kv : m) c.emplace_back(kv.first, kv.second);
            std::sort(c.begin(), c.end(), [](auto const& a, auto const& b) { return a.second.size() > b.second.size(); });
        }
        return c;
    }
    static const uint32 PER_PAGE = 20;
    // actions: 1..999 open category page (cat*? see below), placing = 1000000 + cat*10000 + index
    static uint32 PageAction(uint32 cat, uint32 page) { return 100000 + cat * 1000 + page; }
    static uint32 PlaceAction(uint32 cat, uint32 idx) { return 1000000 + cat * 10000 + idx; }
}

class ZeroCraftCatalogItem : public ItemScript
{
public:
    ZeroCraftCatalogItem() : ItemScript("item_zerocraft_catalog") { }

    static void Top(Player* player, Item* item)
    {
        ClearGossipMenuFor(player);
        AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "Take down the nearest thing we built.", GOSSIP_SENDER_MAIN, ZeroCraftBuild::A_REMOVE);
        AddGossipItemFor(player, GOSSIP_ICON_INTERACT_2, "Edit the nearest thing we built (move, turn, pick up).", GOSSIP_SENDER_MAIN, ZeroCraftBuild::A_EDITNEAR);
        auto& cats = ZeroCraftCatalog::Cats();
        for (uint32 i = 0; i < cats.size(); ++i)
            AddGossipItemFor(player, GOSSIP_ICON_INTERACT_1, Acore::StringFormat("{} ({})", cats[i].first, cats[i].second.size()),
                GOSSIP_SENDER_MAIN, ZeroCraftCatalog::PageAction(i, 0));
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    }

    static void Page(Player* player, Item* item, uint32 cat, uint32 page)
    {
        auto& cats = ZeroCraftCatalog::Cats();
        if (cat >= cats.size())
            return Top(player, item);
        auto const& rows = cats[cat].second;
        uint32 pages = (rows.size() + ZeroCraftCatalog::PER_PAGE - 1) / ZeroCraftCatalog::PER_PAGE;
        ClearGossipMenuFor(player);
        uint32 from = page * ZeroCraftCatalog::PER_PAGE;
        for (uint32 i = from; i < rows.size() && i < from + ZeroCraftCatalog::PER_PAGE; ++i)
            AddGossipItemFor(player, GOSSIP_ICON_TABARD, rows[i].name, GOSSIP_SENDER_MAIN, ZeroCraftCatalog::PlaceAction(cat, i));
        if (page + 1 < pages)
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, Acore::StringFormat("Next page ({} of {})", page + 2, pages), GOSSIP_SENDER_MAIN, ZeroCraftCatalog::PageAction(cat, page + 1));
        if (page > 0)
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Previous page", GOSSIP_SENDER_MAIN, ZeroCraftCatalog::PageAction(cat, page - 1));
        AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Back to styles.", GOSSIP_SENDER_MAIN, ZeroCraftBuild::A_BACK);
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    }

    bool OnUse(Player* player, Item* item, SpellCastTargets const& targets) override
    {
        if (!targets.HasDst())
        {
            ZeroCraftDeploy::RedError(player, "Click a spot on the ground.");
            return true;
        }
        WorldLocation const* dst = targets.GetDstPos();
        if (player->GetMap()->Instanceable() || player->GetTransport())
        {
            ZeroCraftDeploy::RedError(player, "You can only build in the open world.");
            return true;
        }
        if (player->GetExactDist(dst->GetPositionX(), dst->GetPositionY(), dst->GetPositionZ()) > 45.0f)
        {
            ZeroCraftDeploy::RedError(player, "That spot is too far away.");
            return true;
        }
        Position p;
        p.Relocate(dst->GetPositionX(), dst->GetPositionY(), dst->GetPositionZ(), player->GetOrientation());
        ZeroCraftBuild::pendingPos[player->GetGUID().GetCounter()] = p;
        Top(player, item);
        return true;
    }

    void OnGossipSelect(Player* player, Item* item, uint32 /*sender*/, uint32 action) override
    {
        if (action == ZeroCraftBuild::A_BACK)
            return Top(player, item);
        if (action >= 100000 && action < 1000000)
            return Page(player, item, (action - 100000) / 1000, (action - 100000) % 1000);
        CloseGossipMenuFor(player);
        if (action == ZeroCraftBuild::A_REMOVE)
            return ZeroCraftBuild::RemoveNearest(player);
        if (action == ZeroCraftBuild::A_EDITNEAR)
            return ZeroCraftBuild::EditNearest(player);
        if (action < 1000000)
            return;
        uint32 cat = (action - 1000000) / 10000, idx = (action - 1000000) % 10000;
        auto& cats = ZeroCraftCatalog::Cats();
        if (cat >= cats.size() || idx >= cats[cat].second.size())
            return;
        auto pos = ZeroCraftBuild::pendingPos.find(player->GetGUID().GetCounter());
        if (pos == ZeroCraftBuild::pendingPos.end())
            return;
        // no limit on how much a guild can build
        auto const& row = cats[cat].second[idx];
        ZeroCraftBuild::Thing t{ 0, 0, row.entry, row.name.c_str(), 0 };
        if (ZeroCraftBuild::Place(player, t, pos->second))
            ChatHandler(player->GetSession()).PSendSysMessage(Acore::StringFormat("Built: {}.", row.name));
        else
            ZeroCraftDeploy::RedError(player, "Couldn't build that here.");
        // stay on the same page so you can keep building
        Page(player, item, cat, idx / ZeroCraftCatalog::PER_PAGE);
    }
};

class ZeroCraftCatalogGiver : public PlayerScript
{
public:
    ZeroCraftCatalogGiver() : PlayerScript("ZeroCraftCatalogGiver") { }
    void OnPlayerLogin(Player* player) override
    {
        static uint32 entry = 0;
        static bool looked = false;
        if (!looked)
        {
            looked = true;
            uint32 sid = sObjectMgr->GetScriptId("item_zerocraft_catalog");
            for (auto const& kv : *sObjectMgr->GetItemTemplateStore())
                if (kv.second.ScriptId == sid) { entry = kv.first; break; }
        }
        // retired: replaced by the themed Builder's Scrolls
        if (entry && player->HasItemCount(entry, 1, true))
            player->DestroyItemCount(entry, 255, true, false);
    }
};

// ============================================================================
// Builder's Scrolls: themed sets of one useful thing + ~24 decorations.
// Green = crafting station, rare = mailbox / musician / dancer, epic = summoning
// stone / spirit healer / stable master, legendary = a portal. Never used up.
// ============================================================================
namespace ZeroCraftBScroll
{
    struct Row { uint32 kind; uint32 entry; std::string name; bool useful; };
    static std::unordered_map<uint32, std::vector<Row>>& All()
    {
        static std::unordered_map<uint32, std::vector<Row>> m;
        static bool loaded = false;
        if (!loaded)
        {
            loaded = true;
            if (QueryResult r = WorldDatabase.Query("SELECT item_entry, kind, entry, name, useful FROM zerocraft_bscroll_items ORDER BY item_entry, idx"))
                do
                {
                    Field* f = r->Fetch();
                    m[f[0].Get<uint32>()].push_back({ f[1].Get<uint32>(), f[2].Get<uint32>(), f[3].Get<std::string>(), f[4].Get<uint8>() != 0 });
                } while (r->NextRow());
        }
        return m;
    }
    // first-login gift: one random scroll of each tier
    static void Starter(Player* player)
    {
        for (uint32 q = 2; q <= 5; ++q)
            if (QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT item_entry FROM zerocraft_bscroll WHERE quality = {} ORDER BY RAND() LIMIT 1", q)))
                player->AddItem((*r)[0].Get<uint32>(), 1);
    }
}

class ZeroCraftBScrollItem : public ItemScript
{
public:
    ZeroCraftBScrollItem() : ItemScript("item_zerocraft_bscroll") { }

    static void Menu(Player* player, Item* item)
    {
        ClearGossipMenuFor(player);
        AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "Take down the nearest thing we built.", GOSSIP_SENDER_MAIN, ZeroCraftBuild::A_REMOVE);
        AddGossipItemFor(player, GOSSIP_ICON_INTERACT_2, "Edit the nearest thing we built (move, turn, pick up).", GOSSIP_SENDER_MAIN, ZeroCraftBuild::A_EDITNEAR);
        auto& all = ZeroCraftBScroll::All();
        auto itr = all.find(item->GetEntry());
        if (itr != all.end())
            for (uint32 i = 0; i < itr->second.size(); ++i)
            {
                auto const& r = itr->second[i];
                AddGossipItemFor(player, r.useful ? GOSSIP_ICON_INTERACT_1 : (r.kind ? GOSSIP_ICON_TRAINER : GOSSIP_ICON_TABARD),
                    r.useful ? "|cff0070dd" + r.name + "|r" : r.name, GOSSIP_SENDER_MAIN, 1000 + i);
            }
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    }

    bool OnUse(Player* player, Item* item, SpellCastTargets const& /*targets*/) override
    {
        if (player->GetMap()->Instanceable() || player->GetTransport())
        {
            ZeroCraftDeploy::RedError(player, "You can only build in the open world.");
            return true;
        }
        Menu(player, item); // everything builds right in front of you
        return true;
    }

    void OnGossipSelect(Player* player, Item* item, uint32 /*sender*/, uint32 action) override
    {
        if (action == ZeroCraftBuild::A_REMOVE)
        {
            ZeroCraftBuild::RemoveNearest(player);
            return Menu(player, item); // stays open so it can be clicked again and again
        }
        if (action == ZeroCraftBuild::A_EDITNEAR)
            return ZeroCraftBuild::EditNearest(player);
        auto& all = ZeroCraftBScroll::All();
        auto itr = all.find(item->GetEntry());
        if (itr == all.end() || action < 1000 || action - 1000 >= itr->second.size())
            return CloseGossipMenuFor(player);
        if (player->GetMap()->Instanceable() || player->GetTransport())
        {
            ZeroCraftDeploy::RedError(player, "You can only build in the open world.");
            return Menu(player, item);
        }
        // always build right in front of the player, wherever they're standing now
        float x, y, z;
        player->GetClosePoint(x, y, z, player->GetCombatReach(), 3.0f, 0.0f);
        Position here;
        here.Relocate(x, y, z, player->GetOrientation());
        auto const& r = itr->second[action - 1000];
        ZeroCraftBuild::Thing t{ 0, r.kind, r.entry, r.name.c_str(), 0 };
        if (ZeroCraftBuild::Place(player, t, here))
            ChatHandler(player->GetSession()).PSendSysMessage(Acore::StringFormat("Built: {}.", r.name));
        else
            ZeroCraftDeploy::RedError(player, "Couldn't build that here.");
        Menu(player, item); // stay open to keep building
    }
};

// ============================================================================
// ZeroCraft NPC Books: every summonable NPC bundled 14 to a book, plus a Flight
// Master first in every book. Use the book, pick an NPC, and it appears right in
// front of you, facing you. Books are never used up (upkeep still applies).
// Heroes, villains and guards only show up if they'd answer to your side.
// ============================================================================
namespace ZeroCraftNBook
{
    struct Row { uint32 kind; uint32 entry; std::string name; };
    static std::unordered_map<uint32, std::vector<Row>>& All()
    {
        static std::unordered_map<uint32, std::vector<Row>> m;
        static bool loaded = false;
        if (!loaded)
        {
            loaded = true;
            if (QueryResult r = WorldDatabase.Query("SELECT item_entry, kind, entry, name FROM zerocraft_nbook_npcs ORDER BY item_entry, idx"))
                do
                {
                    Field* f = r->Fetch();
                    m[f[0].Get<uint32>()].push_back({ f[1].Get<uint32>(), f[2].Get<uint32>(), f[3].Get<std::string>() });
                } while (r->NextRow());
        }
        return m;
    }

    // NPCs this player (or their guild) already has out in the world
    static std::unordered_set<uint32> Deployed(Player* player)
    {
        std::unordered_set<uint32> out;
        std::string who = player->GetGuildId()
            ? Acore::StringFormat("owner_guild = {}", player->GetGuildId())
            : Acore::StringFormat("owner_guild = 0 AND owner_player = {}", player->GetGUID().GetCounter());
        if (QueryResult r = WorldDatabase.Query("SELECT DISTINCT entry FROM zerocraft_deployables WHERE " + who))
            do { out.insert((*r)[0].Get<uint32>()); } while (r->NextRow());
        return out;
    }

    static bool Allowed(Player* player, Row const& r)
    {
        if (!r.entry)
            return true;
        TeamId t = ZeroCraftDeploy::TeamOfEntry(r.entry);
        TeamId mine = ZeroCraftRebels::IsOutlaw(player) ? TEAM_NEUTRAL : player->GetTeamId(true);
        return t == TEAM_NEUTRAL || t == mine;
    }

    // same rules as the Flight Master scroll: near a real flight point, one per flight point
    static bool FlightOk(Player* player, float x, float y, float z)
    {
        TaxiNodesEntry const* node = ZeroCraftDeploy::NearestTaxiNode(player->GetMapId(), x, y, z);
        if (!node)
        {
            ZeroCraftDeploy::RedError(player, "Stand closer to an in-game flight master location.");
            return false;
        }
        if (QueryResult r = WorldDatabase.Query(Acore::StringFormat(
            "SELECT c.map, c.position_x, c.position_y, c.position_z, d.owner_guild, d.owner_player FROM zerocraft_deployables d "
            "JOIN creature c ON c.guid = d.spawn_id JOIN creature_template ct ON ct.entry = d.entry "
            "WHERE (ct.npcflag & 0x2000) <> 0 AND c.map = {}", player->GetMapId())))
        {
            do
            {
                Field* f = r->Fetch();
                TaxiNodesEntry const* held = ZeroCraftDeploy::NearestTaxiNode(f[0].Get<uint32>(), f[1].Get<float>(), f[2].Get<float>(), f[3].Get<float>());
                if (held && held->ID == node->ID)
                {
                    bool ours = (player->GetGuildId() && f[4].Get<uint32>() == player->GetGuildId()) ||
                                (!f[4].Get<uint32>() && f[5].Get<uint32>() == player->GetGUID().GetCounter());
                    ZeroCraftDeploy::RedError(player, ours
                        ? "Your guild already has a Flight Master at this flight point."
                        : "Another guild holds this flight point. Kill their Flight Master to take it.");
                    return false;
                }
            } while (r->NextRow());
        }
        return true;
    }
}

// NPC items (replace the NPC Books): each one calls one NPC, where you click with the green circle.
class ZeroCraftNpcItem : public ItemScript
{
public:
    ZeroCraftNpcItem() : ItemScript("item_zerocraft_npcitem") { }
    bool OnUse(Player* player, Item* item, SpellCastTargets const& targets) override
    {
        QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT kind, entry FROM zerocraft_npcitem WHERE item_entry = {}", item->GetEntry()));
        if (!r)
            return true;
        uint32 kind = (*r)[0].Get<uint32>(), entry = (*r)[1].Get<uint32>();
        if (player->GetMap()->Instanceable() || player->GetTransport())
        {
            ZeroCraftDeploy::RedError(player, "You can only call NPCs in the open world.");
            return true;
        }
        float x, y, z;
        if (WorldLocation const* dst = targets.HasDst() ? targets.GetDstPos() : nullptr)
        {
            x = dst->GetPositionX(); y = dst->GetPositionY(); z = dst->GetPositionZ();
            if (player->GetExactDist(x, y, z) > 60.0f)
            {
                ZeroCraftDeploy::RedError(player, "That's too far away.");
                return true;
            }
        }
        else
            player->GetClosePoint(x, y, z, player->GetCombatReach(), 3.0f, 0.0f);
        if (kind == ZeroCraftDeploy::ITEM_DEPLOY_FLIGHT && !ZeroCraftNBook::FlightOk(player, x, y, z))
            return true;
        Position pos;
        pos.Relocate(x, y, z, player->GetOrientation());
        if (ZeroCraftDeploy::Deploy(player, kind, pos, entry))
            player->DestroyItemCount(item->GetEntry(), 1, true);
        return true;
    }
};

class ZeroCraftNBookItem : public ItemScript
{
public:
    ZeroCraftNBookItem() : ItemScript("item_zerocraft_nbook") { }

    static void Menu(Player* player, Item* item)
    {
        ClearGossipMenuFor(player);
        auto& all = ZeroCraftNBook::All();
        auto itr = all.find(item->GetEntry());
        std::unordered_set<uint32> out = ZeroCraftNBook::Deployed(player);
        if (itr != all.end())
            for (uint32 i = 0; i < itr->second.size(); ++i)
            {
                auto const& r = itr->second[i];
                if (!ZeroCraftNBook::Allowed(player, r))
                    continue;
                if (r.entry && out.count(r.entry))   // already out in the world: greyed until dismissed or killed
                    AddGossipItemFor(player, GOSSIP_ICON_CHAT, "|cff808080" + r.name + " (called)|r", GOSSIP_SENDER_MAIN, 1000 + i);
                else
                    AddGossipItemFor(player, r.entry ? GOSSIP_ICON_TRAINER : GOSSIP_ICON_TAXI,
                        r.entry ? r.name : "|cff0070dd" + r.name + "|r", GOSSIP_SENDER_MAIN, 1000 + i);
            }
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    }

    bool OnUse(Player* player, Item* item, SpellCastTargets const& /*targets*/) override
    {
        if (player->GetMap()->Instanceable() || player->GetTransport())
        {
            ZeroCraftDeploy::RedError(player, "You can only call NPCs in the open world.");
            return true;
        }
        Menu(player, item);
        return true;
    }

    void OnGossipSelect(Player* player, Item* item, uint32 /*sender*/, uint32 action) override
    {
        auto& all = ZeroCraftNBook::All();
        auto itr = all.find(item->GetEntry());
        if (itr == all.end() || action < 1000 || action - 1000 >= itr->second.size())
            return CloseGossipMenuFor(player);
        auto const& r = itr->second[action - 1000];
        if (!ZeroCraftNBook::Allowed(player, r))
            return Menu(player, item);
        if (r.entry && ZeroCraftNBook::Deployed(player).count(r.entry))
        {
            ZeroCraftDeploy::RedError(player, r.name + " is already out. Dismiss them with Recall Orders to call them again.");
            return Menu(player, item);
        }

        float x, y, z;
        player->GetClosePoint(x, y, z, player->GetCombatReach(), 3.0f, 0.0f);
        Position here;
        here.Relocate(x, y, z, player->GetOrientation());

        if (r.kind == ZeroCraftDeploy::ITEM_DEPLOY_FLIGHT && !ZeroCraftNBook::FlightOk(player, x, y, z))
            return Menu(player, item);

        ZeroCraftDeploy::Deploy(player, r.kind, here, r.entry);
        Menu(player, item); // stay open to keep calling
    }
};

// ============================================================================
// ZeroCraft weapon-mastery scrolls: rare dungeon drops that break class rules.
//   Titan's Grip: Swords / Axes / Maces / Staves - wield that two-hander in each hand
//   Shield Mastery - hold a shield alongside a two-hander
//   Beastmaster (hunters) - your first stabled pet fights beside your active pet
// Any class can read the weapon scrolls; they teach the weapon skill too.
// ============================================================================
namespace ZeroCraftTitanGrip
{
    struct Kind { uint32 item; uint32 bit; uint32 proficiency; uint32 skill; char const* name; };
    static const uint32 SHIELD_BIT = 31;
    static const Kind KINDS[] = {
        { 60401, ITEM_SUBCLASS_WEAPON_SWORD2, 202, SKILL_2H_SWORDS, "wield two-handed swords in each hand" },
        { 60402, ITEM_SUBCLASS_WEAPON_AXE2,   197, SKILL_2H_AXES,   "wield two-handed axes in each hand"   },
        { 60403, ITEM_SUBCLASS_WEAPON_MACE2,  199, SKILL_2H_MACES,  "wield two-handed maces in each hand"  },
        { 60404, ITEM_SUBCLASS_WEAPON_STAFF,  227, SKILL_STAVES,    "wield staves in each hand"            },
        { 60405, SHIELD_BIT,                  9116, SKILL_SHIELD,   "hold a shield alongside a two-handed weapon" },
    };
    static const uint32 ITEM_BEASTMASTER = 60406;
    static std::unordered_map<ObjectGuid::LowType, uint32> masks;   // player -> bit per weapon subclass (+ shield)

    static uint32 MaskOf(Player const* p)
    {
        auto it = masks.find(p->GetGUID().GetCounter());
        return it == masks.end() ? 0 : it->second;
    }
    static bool Has(Player const* p, uint32 bit) { return (MaskOf(p) >> bit) & 1; }

    static void Ensure(Player* p)
    {
        uint32 mask = MaskOf(p);
        if (!(mask & ~(1u << SHIELD_BIT) & ~(1u << 30)) && !(mask & (1u << SHIELD_BIT)))
            return;
        if ((mask & ~(1u << SHIELD_BIT) & ~(1u << 30)) && !p->HasSpell(674))
            p->learnSpell(674, false);
        if (!p->HasSpell(46917))
            p->learnSpell(46917, false);
        if ((mask & ~(1u << SHIELD_BIT) & ~(1u << 30)) && !p->CanDualWield())
            p->SetCanDualWield(true);
        if (!p->CanTitanGrip())
            p->SetCanTitanGrip(true);
    }

    static void Save(Player* p, uint32 mask)
    {
        masks[p->GetGUID().GetCounter()] = mask;
        CharacterDatabase.DirectExecute(Acore::StringFormat("REPLACE INTO zerocraft_titangrip (guid, mask) VALUES ({}, {})",
            p->GetGUID().GetCounter(), mask));
    }

    static void Load(Player* p)
    {
        uint32 mask = 0;
        if (QueryResult r = CharacterDatabase.Query(Acore::StringFormat("SELECT mask FROM zerocraft_titangrip WHERE guid = {}", p->GetGUID().GetCounter())))
            mask = (*r)[0].Get<uint32>();
        // Titan's Grip (swords, axes, maces, staves) is back; Shield Mastery and Beastmaster stay scrapped
        uint32 kept = mask & ((1u << ITEM_SUBCLASS_WEAPON_SWORD2) | (1u << ITEM_SUBCLASS_WEAPON_AXE2) |
                              (1u << ITEM_SUBCLASS_WEAPON_MACE2) | (1u << ITEM_SUBCLASS_WEAPON_STAFF));
        if (kept != mask)
        {
            CharacterDatabase.DirectExecute(Acore::StringFormat("REPLACE INTO zerocraft_titangrip (guid, mask) VALUES ({}, {})", p->GetGUID().GetCounter(), kept));
            mask = kept;
            // an off-hand two-hander (or a shield next to a two-hander) goes back into the bags
            Item* mh = p->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_MAINHAND);
            if (Item* oh = p->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_OFFHAND))
                if (oh->GetTemplate()->InventoryType == INVTYPE_2HWEAPON || (mh && mh->GetTemplate()->InventoryType == INVTYPE_2HWEAPON))
                {
                    ItemPosCountVec dest;
                    if (p->CanStoreItem(NULL_BAG, NULL_SLOT, dest, oh, false) == EQUIP_ERR_OK)
                    {
                        p->RemoveItem(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_OFFHAND, true);
                        p->StoreItem(dest, oh, true);
                    }
                }
            if (p->getClass() != CLASS_WARRIOR || !p->HasTalent(46917, p->GetActiveSpec()))
            {
                if (p->HasSpell(46917))
                    p->removeSpell(46917, SPEC_MASK_ALL, false);
                p->SetCanTitanGrip(false);
            }
        }
        if (mask)
            masks[p->GetGUID().GetCounter()] = mask;
        else
            masks.erase(p->GetGUID().GetCounter());
    }

    static bool Is2H(ItemTemplate const* t) { return t && t->InventoryType == INVTYPE_2HWEAPON; }
    static bool IsShield(ItemTemplate const* t) { return t && t->Class == ITEM_CLASS_ARMOR && t->SubClass == ITEM_SUBCLASS_ARMOR_SHIELD; }

    // may `off` sit in the off hand next to `main`? (only asked for players with a grip of some kind)
    static bool PairAllowed(Player const* p, ItemTemplate const* main, ItemTemplate const* off)
    {
        bool talent = p->HasTalent(46917, p->GetActiveSpec());
        auto ok2H = [&](ItemTemplate const* t)
        {
            if (t->SubClass == ITEM_SUBCLASS_WEAPON_STAFF)
                return Has(p, ITEM_SUBCLASS_WEAPON_STAFF);
            return talent || Has(p, t->SubClass);
        };
        if (!off)
            return true;
        if (Is2H(main))
        {
            if (IsShield(off))
                return Has(p, SHIELD_BIT);
            if (!ok2H(main))
                return false;
            return !Is2H(off) || ok2H(off);
        }
        return !Is2H(off) || ok2H(off);
    }
}

namespace ZeroCraftBeastmaster
{
    static std::unordered_map<ObjectGuid::LowType, ObjectGuid> second;   // hunter -> the stabled pet fighting beside them

    static bool Knows(Player const* p) { return ZeroCraftTitanGrip::Has(p, 30); }

    static void Dismiss(Player* p)
    {
        auto it = second.find(p->GetGUID().GetCounter());
        if (it == second.end())
            return;
        if (Creature* c = ObjectAccessor::GetCreature(*p, it->second))
            if (TempSummon* ts = c->ToTempSummon())
                ts->UnSummon();
        second.erase(it);
    }

    static void Update(Player* p)
    {
        Pet* pet = p->GetPet();
        bool want = Knows(p) && pet && pet->IsAlive() && p->IsAlive() && !p->IsMounted() && !p->IsInFlight() && !p->GetTransport();
        auto it = second.find(p->GetGUID().GetCounter());
        Creature* cur = it != second.end() ? ObjectAccessor::GetCreature(*p, it->second) : nullptr;
        if (!want || (it != second.end() && (!cur || !cur->IsAlive() || cur->GetMap() != p->GetMap())))
        {
            Dismiss(p);
            if (!want)
                return;
            cur = nullptr;
        }
        if (cur)
            return;
        PetStable* stable = p->GetPetStable();
        uint32 entry = 0;
        if (stable)
            for (auto const& info : stable->StabledPets)
                if (info && info->CreatureId) { entry = info->CreatureId; break; }
        if (!entry || !sObjectMgr->GetCreatureTemplate(entry))
            return;
        Position pos;
        p->GetNearPoint(p, pos.m_positionX, pos.m_positionY, pos.m_positionZ, 0.0f, 2.0f, p->GetOrientation() + float(M_PI) / 2);
        TempSummon* ts = p->SummonCreature(entry, pos, TEMPSUMMON_MANUAL_DESPAWN, 0, 0, sSummonPropertiesStore.LookupEntry(61));
        if (!ts)
            return;
        if (ts->IsGuardian())
            static_cast<Guardian*>(static_cast<Creature*>(ts))->InitStatsForLevel(p->GetLevel());
        ts->SetLevel(p->GetLevel());
        ts->SetFaction(p->GetFaction());
        ts->GetMotionMaster()->MoveFollow(p, PET_FOLLOW_DIST, float(M_PI) / 2);
        second[p->GetGUID().GetCounter()] = ts->GetGUID();
    }
}

class ZeroCraftTitanGripItem : public ItemScript
{
public:
    ZeroCraftTitanGripItem() : ItemScript("item_zerocraft_titangrip") { }

    bool OnUse(Player* player, Item* item, SpellCastTargets const& /*targets*/) override
    {
        if (item->GetEntry() == ZeroCraftTitanGrip::ITEM_BEASTMASTER)
        {
            if (player->getClass() != CLASS_HUNTER)
            {
                ZeroCraftDeploy::RedError(player, "Only hunters can learn the Beastmaster's secrets.");
                return true;
            }
            if (ZeroCraftBeastmaster::Knows(player))
            {
                ZeroCraftDeploy::RedError(player, "You are already a Beastmaster.");
                return true;
            }
            ZeroCraftTitanGrip::Save(player, ZeroCraftTitanGrip::MaskOf(player) | (1u << 30));
            player->DestroyItemCount(item->GetEntry(), 1, true);
            ChatHandler(player->GetSession()).SendSysMessage(
                "You are a Beastmaster: the first pet in your stable now fights beside your active pet.");
            return true;
        }
        for (auto const& k : ZeroCraftTitanGrip::KINDS)
        {
            if (k.item != item->GetEntry())
                continue;
            uint32 mask = ZeroCraftTitanGrip::MaskOf(player);
            if (mask & (1u << k.bit))
            {
                ZeroCraftDeploy::RedError(player, Acore::StringFormat("You already know how to {}.", k.name));
                return true;
            }
            ZeroCraftTitanGrip::Save(player, mask | (1u << k.bit));
            if (!player->HasSpell(k.proficiency))
                player->learnSpell(k.proficiency, false);
            if (k.bit == ZeroCraftTitanGrip::SHIELD_BIT && !player->HasSpell(107))
                player->learnSpell(107, false);   // Block
            player->SetSkill(k.skill, 0, 300, 300);
            ZeroCraftTitanGrip::Ensure(player);
            player->DestroyItemCount(item->GetEntry(), 1, true);
            ChatHandler(player->GetSession()).PSendSysMessage(Acore::StringFormat("You can now {}.", k.name));
            return true;
        }
        return true;
    }
};

class ZeroCraftTitanGripPlayer : public PlayerScript
{
public:
    ZeroCraftTitanGripPlayer() : PlayerScript("ZeroCraftTitanGripPlayer") { }

    void OnPlayerLogin(Player* player) override
    {
        ZeroCraftTitanGrip::Load(player);
        ZeroCraftTitanGrip::Ensure(player);   // right away, so the off-hand two-hander counts from the start
        ObjectGuid g = player->GetGUID();
        player->m_Events.AddEventAtOffset([player, g]()
        {
            if (player->IsInWorld() && player->GetGUID() == g)
            {
                ZeroCraftTitanGrip::Ensure(player);
                // Cast Titan's Grip once so the game client itself hears about it. Without this,
                // after a relog the client didn't know you may hold a two-hander in the off hand
                // and animated those swings as bare fists.

            }
        }, Seconds(2));
    }

    void OnPlayerLogout(Player* player) override { ZeroCraftBeastmaster::Dismiss(player); }

    // Two two-handers: keep both weapons drawn in your hands. The drawn-weapon display could
    // fall out of step (weapons worked, but you swung with bare fists) - check it every second.
    void OnPlayerUpdate(Player* player, uint32 diff) override
    {
        uint32& t = gripTimers[player->GetGUID().GetCounter()];
        t += diff;
        if (t < 250)
            return;
        t = 0;
        if (!ZeroCraftTitanGrip::MaskOf(player) || !player->IsInWorld())
            return;
        ZeroCraftTitanGrip::Ensure(player);
    }

    // Only the kinds of two-hander (and shields) you've learned may share your hands.
    bool OnPlayerCanEquipItem(Player* player, uint8 slot, uint16& /*dest*/, Item* pItem, bool swap, bool /*not_loading*/) override
    {
        ItemTemplate const* proto = pItem ? pItem->GetTemplate() : nullptr;
        if (!proto || (proto->Class != ITEM_CLASS_WEAPON && !ZeroCraftTitanGrip::IsShield(proto)))
            return true;
        if (!ZeroCraftTitanGrip::MaskOf(player) && !player->HasTalent(46917, player->GetActiveSpec()))
            return true;
        ZeroCraftTitanGrip::Ensure(player);
        uint8 target = slot != NULL_SLOT ? slot : player->FindEquipSlot(proto, NULL_SLOT, swap);
        Item* mh = player->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_MAINHAND);
        Item* oh = player->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_OFFHAND);
        bool ok = true;
        if (target == EQUIPMENT_SLOT_OFFHAND)
            ok = ZeroCraftTitanGrip::PairAllowed(player, mh && mh != pItem ? mh->GetTemplate() : nullptr, proto);
        else if (target == EQUIPMENT_SLOT_MAINHAND && ZeroCraftTitanGrip::Is2H(proto) && oh && oh != pItem)
            ok = ZeroCraftTitanGrip::PairAllowed(player, proto, oh->GetTemplate());
        if (ok)
            return true;
        ZeroCraftDeploy::RedError(player, "You haven't learned to hold those two together. Take off your off-hand first.");
        return false;
    }
private:
    std::unordered_map<ObjectGuid::LowType, uint32> gripTimers;
};

class ZeroCraftBeastmasterWorld : public WorldScript
{
public:
    ZeroCraftBeastmasterWorld() : WorldScript("ZeroCraftBeastmasterWorld") { }
    void OnUpdate(uint32 diff) override
    {
        timer += diff;
        if (timer < 2 * IN_MILLISECONDS)
            return;
        timer = 0;
        for (auto const& pair : ObjectAccessor::GetPlayers())
            if (Player* p = pair.second)
                if (p->IsInWorld() && p->getClass() == CLASS_HUNTER && (ZeroCraftBeastmaster::Knows(p) || ZeroCraftBeastmaster::second.count(p->GetGUID().GetCounter())))
                    ZeroCraftBeastmaster::Update(p);
    }
private:
    uint32 timer = 0;
};

// Furniture items: use one and it appears right in front of you, facing you.
class ZeroCraftFurnitureItem : public ItemScript
{
public:
    ZeroCraftFurnitureItem() : ItemScript("item_zerocraft_furniture") { }

    bool OnUse(Player* player, Item* item, SpellCastTargets const& targets) override
    {
        ZeroCraftHome::Furn const* fu = ZeroCraftHome::OfItem(item->GetEntry());
        if (!fu)
            return true;
        if (player->GetMap()->Instanceable() || player->GetTransport())
        {
            ZeroCraftDeploy::RedError(player, "You can only build in the open world.");
            return true;
        }
        // placed where you clicked with the green ground circle (right in front of you if no spot was picked)
        float x, y, z;
        if (WorldLocation const* dst = targets.HasDst() ? targets.GetDstPos() : nullptr)
        {
            x = dst->GetPositionX(); y = dst->GetPositionY(); z = dst->GetPositionZ();
            if (player->GetExactDist(x, y, z) > 60.0f)
            {
                ZeroCraftDeploy::RedError(player, "That's too far away.");
                return true;
            }
        }
        else
            player->GetClosePoint(x, y, z, player->GetCombatReach(), 3.0f, 0.0f);
        std::string err;
        if (!ZeroCraftHome::CanBuildAt(player, x, y, z, fu->stone, err))
        {
            ZeroCraftDeploy::RedError(player, err);
            return true;
        }
        Position pos;
        pos.Relocate(x, y, z, std::atan2(player->GetPositionY() - y, player->GetPositionX() - x));   // faces you
        float scale = fu->stone ? 1.0f : 1.5f;   // furniture arrives big
        if (!ZeroCraftHome::Spawn(player->GetMap(), player->GetPhaseMaskForSpawn(), fu->go, pos, scale, player->GetGuildId(), player->GetGUID().GetCounter()))
        {
            ZeroCraftDeploy::RedError(player, "Couldn't place that here.");
            return true;
        }
        player->DestroyItemCount(item->GetEntry(), 1, true);
        ChatHandler(player->GetSession()).PSendSysMessage(Acore::StringFormat(fu->stone
            ? "{} placed. Your guild now claims this whole area - nobody else can build or deploy here. Talk to it to summon guildmates or reach the guild bank."
            : "{} placed. Click it to move, turn, resize or pick it up.", fu->name));
        return true;
    }
};

static bool fu0Stone(GameObject* go)
{
    ZeroCraftHome::Furn const* f = ZeroCraftHome::OfGo(go->GetEntry());
    return f && f->stone;
}

class ZeroCraftHomeObjects : public AllGameObjectScript
{
public:
    ZeroCraftHomeObjects() : AllGameObjectScript("ZeroCraftHomeObjects") { }

    void OnGameObjectAddWorld(GameObject* go) override
    {
        if (go->GetEntry() < ZeroCraftHome::CLONE || !go->GetSpawnId())
            return;
        ZeroCraftHome::Load();
        auto it = ZeroCraftHome::scales.find(go->GetSpawnId());
        if (it != ZeroCraftHome::scales.end())
            go->SetObjectScale(it->second);
        if (fu0Stone(go))
        {
            go->m_Events.AddEventAtOffset([go]() { if (go->IsInWorld()) ZeroCraftHome::EnsureGuardian(go); }, Milliseconds(1500));
            // a hidden guild-bank chest inside the stone: the bank window needs a real vault to talk to
            go->m_Events.AddEventAtOffset([go]()
            {
                if (!go->IsInWorld() || ZeroCraftHome::focusTwin.count(go->GetGUID()))
                    return;
                uint32 og = 0, oo = 0;
                ZeroCraftHome::Resolve(go->GetSpawnId(), og, oo, nullptr);
                if (GameObject* v = go->SummonGameObject(ZeroCraftVault::VAULT_ENTRY, go->GetPositionX(), go->GetPositionY(), go->GetPositionZ(),
                                                         go->GetOrientation(), 0, 0, 0, 0, 0, false, GO_SUMMON_TIMED_DESPAWN))
                {
                    v->SetObjectScale(0.01f);
                    v->SetGameObjectFlag(GO_FLAG_NOT_SELECTABLE);
                    ZeroCraftVault::vaultGuild[v->GetGUID()] = og;
                    ZeroCraftHome::focusTwin[go->GetGUID()] = v->GetGUID();
                }
            }, Milliseconds(600));
        }
        // crafting stations (anvil, forge, cooking fire...) are clickable copies, which don't count for crafting,
        // so a tiny, invisible real one sits inside
        ZeroCraftHome::Furn const* fu = ZeroCraftHome::OfGo(go->GetEntry());
        if (fu && fu->srcType == GAMEOBJECT_TYPE_SPELL_FOCUS && !ZeroCraftHome::focusTwin.count(go->GetGUID()))
        {
            uint32 src = fu->src;
            go->m_Events.AddEventAtOffset([go, src]()
            {
                if (!go->IsInWorld() || ZeroCraftHome::focusTwin.count(go->GetGUID()))
                    return;
                if (GameObject* twin = go->SummonGameObject(src, go->GetPositionX(), go->GetPositionY(), go->GetPositionZ(),
                                                            go->GetOrientation(), 0, 0, 0, 0, 0, false, GO_SUMMON_TIMED_DESPAWN))
                {
                    twin->SetObjectScale(0.01f);
                    twin->SetGameObjectFlag(GO_FLAG_NOT_SELECTABLE);
                    ZeroCraftHome::focusTwin[go->GetGUID()] = twin->GetGUID();
                }
            }, Milliseconds(500));
        }
    }

    void OnGameObjectRemoveWorld(GameObject* go) override
    {
        auto it = ZeroCraftHome::focusTwin.find(go->GetGUID());
        if (it == ZeroCraftHome::focusTwin.end())
            return;
        if (GameObject* twin = go->GetMap()->GetGameObject(it->second))
        {
            twin->SetRespawnTime(0);
            twin->Delete();
        }
        ZeroCraftHome::focusTwin.erase(it);
    }

    bool CanGameObjectGossipHello(Player* player, GameObject* go) override
    {
        if (go->GetEntry() < ZeroCraftHome::CLONE || !ZeroCraftHome::OfGo(go->GetEntry()))
            return false;
        if (go->GetGUID() == ZeroCraftHome::bypass)
            return false;   // "Use it": let the object do its normal thing
        ZeroCraftHome::Hello(player, go);
        return true;
    }

    bool CanGameObjectGossipSelect(Player* player, GameObject* go, uint32 /*sender*/, uint32 action) override
    {
        if (go->GetEntry() < ZeroCraftHome::CLONE || !ZeroCraftHome::OfGo(go->GetEntry()))
            return false;
        ZeroCraftHome::Select(player, go, action);
        return true;
    }

    // "Store gold": the amount typed into the box
    bool CanGameObjectGossipSelectCode(Player* p, GameObject* go, uint32 /*sender*/, uint32 action, char const* code) override
    {
        if (go->GetEntry() < ZeroCraftHome::CLONE || !ZeroCraftHome::OfGo(go->GetEntry()) || action != ZeroCraftHome::A_DEPANY)
            return false;
        uint32 gold = code ? uint32(std::strtoul(code, nullptr, 10)) : 0;
        Guild* guild = p->GetGuildId() ? sGuildMgr->GetGuildById(p->GetGuildId()) : nullptr;
        if (!gold)
            ZeroCraftDeploy::RedError(p, "Type a number of gold, e.g. 250.");
        else if (!guild)
            ZeroCraftDeploy::RedError(p, "You need a guild for a guild bank.");
        else if (uint64(gold) * GOLD > 0xFFFFFFFFull || !p->HasEnoughMoney(uint32(gold * GOLD)))
            ZeroCraftDeploy::RedError(p, "You don't have that much gold.");
        else
        {
            guild->HandleMemberDepositMoney(p->GetSession(), gold * GOLD);
            ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} gold stored in the guild bank.", gold));
        }
        ZeroCraftHome::StoneMenu(p, go);
        return true;
    }
};

// ============================================================================
// Your deployed NPCs get the same edit menu as furniture: hover shows the speech
// bubble, click for Use (their normal services), Move, Turn and Place (Builder's Rod).
// ============================================================================
namespace ZeroCraftNpcEdit
{
    static const uint32 SENDER = 9110;
    static const uint32 TAXI_SENDER = 9112;
    static std::unordered_map<ObjectGuid::LowType, ObjectGuid::LowType> selected;   // player -> NPC spawn picked for "Place"
    static std::unordered_map<ObjectGuid::LowType, ObjectGuid::LowType> patrolPick; // player -> NPC waiting for its 2nd patrol point
    struct Look { float scale = 1.0f; uint32 path = 0; };
    static std::unordered_map<ObjectGuid::LowType, Look> looks;                     // spawn -> saved size / patrol
    static bool looksLoaded = false;
    static const uint32 PATH_BASE = 800000000;   // our own two-point routes: PATH_BASE + spawn id

    static void LoadLooks()
    {
        if (looksLoaded)
            return;
        looksLoaded = true;
        if (QueryResult r = WorldDatabase.Query("SELECT spawn_id, scale, patrol_path FROM zerocraft_deployables WHERE scale <> 1 OR patrol_path <> 0"))
            do { looks[(*r)[0].Get<uint32>()] = { (*r)[1].Get<float>(), (*r)[2].Get<uint32>() }; } while (r->NextRow());
    }

    static const uint32 PATROL_WANDER = 1;                       // roam freely around the post
    static const uint32 CIRCLE_BASE = 900000000;                 // walk a ring around the post: CIRCLE_BASE + spawn id
    static std::unordered_map<ObjectGuid::LowType, ObjectGuid> escorting;   // NPC spawn -> player it follows

    static void StartPatrol(Creature* c, uint32 path)
    {
        escorting.erase(c->GetSpawnId());
        if (path == PATROL_WANDER)
        {
            c->SetWalk(true);
            c->LoadPath(0);
            c->SetWanderDistance(12.0f);
            c->SetDefaultMovementType(RANDOM_MOTION_TYPE);
            c->GetMotionMaster()->Initialize();
            return;
        }
        c->SetWanderDistance(0.0f);
        if (path && sWaypointMgr->GetPath(path))
        {
            c->LoadPath(path);
            c->SetDefaultMovementType(WAYPOINT_MOTION_TYPE);
            c->GetMotionMaster()->Clear();
            c->SetWalk(true);                                  // patrols stroll, never run
            c->GetMotionMaster()->MoveWaypoint(path, true);   // real patrol: walks, pauses, loops forever
            return;
        }
        else
        {
            c->LoadPath(0);
            c->SetDefaultMovementType(IDLE_MOTION_TYPE);
        }
        c->GetMotionMaster()->Initialize();
    }

    static void SetPatrol(Creature* c, uint32 path)
    {
        looks[c->GetSpawnId()].path = path;
        WorldDatabase.DirectExecute(Acore::StringFormat("UPDATE zerocraft_deployables SET patrol_path = {} WHERE spawn_id = {}", path, c->GetSpawnId()));
        StartPatrol(c, path);
    }

    static void SetScale(Creature* c, float scale)
    {
        looks[c->GetSpawnId()].scale = scale;
        c->SetObjectScale(scale);
        WorldDatabase.DirectExecute(Acore::StringFormat("UPDATE zerocraft_deployables SET scale = {} WHERE spawn_id = {}", scale, c->GetSpawnId()));
    }

    // routes of the townsfolk who used to live within 80 yards
    static std::vector<std::pair<uint32, std::string>> OldRoutes(Creature* c)
    {
        std::vector<std::pair<uint32, std::string>> v;
        if (QueryResult r = WorldDatabase.Query(Acore::StringFormat(
            "SELECT DISTINCT r.guid * 10, ct.name, (SELECT COUNT(*) FROM waypoint_data w2 WHERE w2.id = r.guid * 10) FROM zerocraft_removed_creatures r "
            "JOIN creature_template ct ON ct.entry = r.id JOIN waypoint_data w ON w.id = r.guid * 10 "
            "WHERE r.map = {} AND POW(r.position_x - {}, 2) + POW(r.position_y - {}, 2) < 6400 LIMIT 12",
            c->GetMapId(), c->GetPositionX(), c->GetPositionY())))
            do
            {
                v.push_back({ (*r)[0].Get<uint32>(), Acore::StringFormat("Walk {}'s old route ({} stops)", (*r)[1].Get<std::string>(), (*r)[2].Get<uint64>()) });
            } while (r->NextRow());
        return v;
    }

    static bool Services(Creature* c)
    {
        if (ZeroCraftProf::Is(c->GetEntry()) || c->GetEntry() == 911172)
            return true;
        return c->GetNpcFlags() & (UNIT_NPC_FLAG_VENDOR_MASK | UNIT_NPC_FLAG_FLIGHTMASTER | UNIT_NPC_FLAG_INNKEEPER |
                                   UNIT_NPC_FLAG_AUCTIONEER | UNIT_NPC_FLAG_STABLEMASTER | UNIT_NPC_FLAG_TRAINER | UNIT_NPC_FLAG_REPAIR);
    }

    static Creature* Find(Map* map, ObjectGuid::LowType id)
    {
        auto range = map->GetCreatureBySpawnIdStore().equal_range(id);
        return range.first == range.second ? nullptr : range.first->second;
    }

    // move a deployed NPC for good (world, spawn data and database)
    static bool MoveTo(Player* p, Creature* c, float x, float y, float z, float o)
    {
        ObjectGuid::LowType id = c->GetSpawnId();
        std::string err;
        if (ZeroCraftDeploy::BuildCheck && !ZeroCraftDeploy::BuildCheck(p, x, y, z, err))
        {
            ZeroCraftDeploy::RedError(p, err);
            return false;
        }
        if (c->IsTaxi())
        {
            TaxiNodesEntry const* now = ZeroCraftDeploy::NearestTaxiNode(c->GetMapId(), c->GetPositionX(), c->GetPositionY(), c->GetPositionZ());
            TaxiNodesEntry const* then = ZeroCraftDeploy::NearestTaxiNode(c->GetMapId(), x, y, z);
            if (!then || (now && then->ID != now->ID))
            {
                ZeroCraftDeploy::RedError(p, "A Flight Master has to stay at his flight point.");
                return false;
            }
        }
        if (CreatureData const* d = sObjectMgr->GetCreatureData(id))
        {
            sObjectMgr->RemoveCreatureFromGrid(id, d);
            CreatureData& data = sObjectMgr->NewOrExistCreatureData(id);
            data.posX = x; data.posY = y; data.posZ = z; data.orientation = o;
            sObjectMgr->AddCreatureToGrid(id, &data);
        }
        WorldDatabase.DirectExecute(Acore::StringFormat(
            "UPDATE creature SET position_x = {}, position_y = {}, position_z = {}, orientation = {} WHERE guid = {}", x, y, z, o, id));
        c->SetHomePosition(x, y, z, o);
        c->NearTeleportTo(x, y, z, o);
        if (c->GetWaypointPath())
            SetPatrol(c, 0);   // moved: stands guard at the new post until given a new patrol
        return true;
    }

    enum { A_USE = 1, A_MOVE, A_TURN, A_PLACE, A_UNSELECT, A_MAIN, A_DONE, A_RESIZE, A_PATROL, A_PATROL2, A_STOPPATROL, A_CIRCLE, A_WANDER, A_ESCORT, A_PACK, A_RECORD, A_RECCANCEL, A_NDELETE, A_NDELETE_YES, A_ROAM, A_ROAM10, A_ROAM30, A_STOP30, A_STOPMAIN, A_CLAIM,
           A_SSTEP = 300, A_BIG, A_SMALL, A_RESET,
           A_ROUTE = 1000,
           A_MSTEP = 100, A_FWD, A_BACK, A_LEFT, A_RIGHT, A_UP, A_DOWN, A_HERE, A_MFACE,
           A_TSTEP = 200, A_TURNL, A_TURNR, A_TURNL90, A_TURNR90, A_FACE, A_FACEAWAY };

    // talking to a patroller: he stops, turns to you, and his post stays where it was
    static void HoldStill(Player* p, Creature* c)
    {
        if (CreatureData const* d = sObjectMgr->GetCreatureData(c->GetSpawnId()))
            c->SetHomePosition(d->posX, d->posY, d->posZ, d->orientation);
        c->StopMoving();
        c->PauseMovement(20000, MOTION_SLOT_IDLE);
        c->SetFacingToObject(p);
    }

    static void Add(Player* p, std::string const& text, uint32 action) { AddGossipItemFor(p, GOSSIP_ICON_CHAT, text, SENDER, action); }

    static void MainMenu(Player* p, Creature* c)
    {
        ZeroCraftCommand::lastClicked[p->GetGUID().GetCounter()] = c->GetGUID();   // Commander's Banner: Target falls back to this
        ClearGossipMenuFor(p);
        if (Services(c))
            AddGossipItemFor(p, GOSSIP_ICON_INTERACT_1, "Use it", SENDER, A_USE);
        if (c->IsTaxi())
            AddGossipItemFor(p, GOSSIP_ICON_TAXI, "Claim this flight point for my guild", SENDER, A_CLAIM);
        Add(p, "Move it", A_MOVE);
        Add(p, "Place it (use the Builder's Rod and click the ground)", A_PLACE);
        Add(p, "Turn it", A_TURN);
        Add(p, "Resize it", A_RESIZE);
        Add(p, "Patrol", A_PATROL);
        {
            auto lk = looks.find(c->GetSpawnId());
            if (c->GetWaypointPath() || escorting.count(c->GetSpawnId()) || (lk != looks.end() && lk->second.path))
                Add(p, "Stop patrolling - stand guard here", A_STOPMAIN);
        }
        Add(p, "Pick up (pack into a scroll - keeps their health)", A_PACK);
        AddGossipItemFor(p, GOSSIP_ICON_BATTLE, "|cffcc0000Delete them (gone for good)|r", SENDER, A_NDELETE_YES);
        auto sel = selected.find(p->GetGUID().GetCounter());
        if (sel != selected.end() && sel->second == c->GetSpawnId())
            Add(p, "Selected -- click to clear", A_UNSELECT);
        Add(p, " ", A_MAIN);
        Add(p, "Done\nExit edit mode", A_DONE);
        SendGossipMenuFor(p, ZeroCraftHome::T_MAIN, c->GetGUID());
    }

    static void MoveMenu(Player* p, Creature* c)
    {
        auto& st = ZeroCraftHome::steps[p->GetGUID().GetCounter()];
        ClearGossipMenuFor(p);
        Add(p, "Back", A_MAIN);
        Add(p, "Step: " + ZeroCraftHome::Num(ZeroCraftHome::MOVE_STEPS[st.move]) + " yards (click to change)", A_MSTEP);
        Add(p, "Away", A_FWD); Add(p, "Towards", A_BACK); Add(p, "Left", A_LEFT); Add(p, "Right", A_RIGHT);
        Add(p, "Up", A_UP); Add(p, "Down", A_DOWN); Add(p, "Bring it to me", A_HERE); Add(p, "Face Player", A_MFACE);
        SendGossipMenuFor(p, ZeroCraftHome::T_MOVE, c->GetGUID());
    }

    static void TurnMenu(Player* p, Creature* c)
    {
        auto& st = ZeroCraftHome::steps[p->GetGUID().GetCounter()];
        ClearGossipMenuFor(p);
        Add(p, "Back", A_MAIN);
        Add(p, "Step: " + ZeroCraftHome::Num(ZeroCraftHome::TURN_STEPS[st.turn]) + " degrees (click to change)", A_TSTEP);
        Add(p, "Left", A_TURNL); Add(p, "Right", A_TURNR); Add(p, "Left 90", A_TURNL90); Add(p, "Right 90", A_TURNR90);
        Add(p, "Face Player", A_FACE); Add(p, "Face Away from Player", A_FACEAWAY);
        SendGossipMenuFor(p, ZeroCraftHome::T_TURN, c->GetGUID());
    }

    static struct ClearInit { ClearInit() {
        ZeroCraftHome::ClearNpcSelection = [](Player* p) { selected.erase(p->GetGUID().GetCounter()); };
        ZeroCraftCommand::StopPatrol = [](Creature* c)
        {
            escorting.erase(c->GetSpawnId());
            auto lk = looks.find(c->GetSpawnId());
            if ((lk != looks.end() && lk->second.path) || c->GetWaypointPath())
            {
                looks[c->GetSpawnId()].path = 0;
                WorldDatabase.DirectExecute(Acore::StringFormat("UPDATE zerocraft_deployables SET patrol_path = 0 WHERE spawn_id = {}", c->GetSpawnId()));
                c->LoadPath(0);
                c->SetDefaultMovementType(IDLE_MOTION_TYPE);
            }
        };
    } } clearInit;

    static void ResizeMenu(Player* p, Creature* c)
    {
        ClearGossipMenuFor(p);
        Add(p, "Bigger", A_BIG); Add(p, "Smaller", A_SMALL);
        SendGossipMenuFor(p, ZeroCraftHome::T_RESIZE, c->GetGUID());
    }

    // "Walk the route for me": while the player walks, drop a stop every few yards.
    // The Builder's Rod finishes it; the NPC then walks it there and back, forever.
    struct Recording { ObjectGuid::LowType npc; uint32 map; std::vector<Position> pts; };
    static std::unordered_map<ObjectGuid::LowType, Recording> recording;   // player -> route being walked
    static const float ROAM_SPEED = 2.5f;   // a stroll (normal walking pace), never a run
    static const float REC_STEP = 4.0f;
    static const size_t REC_MAX = 250;

    static void RecordTick(Player* p)
    {
        auto it = recording.find(p->GetGUID().GetCounter());
        if (it == recording.end())
            return;
        Recording& r = it->second;
        if (!p->IsInWorld() || p->GetMapId() != r.map || p->IsInFlight() || p->GetTransport())
        {
            recording.erase(it);
            ZeroCraftDeploy::RedError(p, "Route cancelled - you left the area.");
            return;
        }
        Position const& last = r.pts.back();
        float d = p->GetExactDist2d(last.GetPositionX(), last.GetPositionY());
        if (d > 60.0f)
        {
            recording.erase(it);
            ZeroCraftDeploy::RedError(p, "Route cancelled - you jumped too far (teleport or death?).");
            return;
        }
        if (d >= REC_STEP && r.pts.size() < REC_MAX)
        {
            r.pts.push_back(p->GetPosition());
            if (r.pts.size() == REC_MAX)
                ChatHandler(p->GetSession()).SendSysMessage("That's as long as a route can be. Use the Builder's Rod to finish it.");
        }
        ObjectGuid guid = p->GetGUID();
        p->m_Events.AddEventAtOffset([p, guid]() { if (p->IsInWorld() && p->GetGUID() == guid) RecordTick(p); }, Milliseconds(500));
    }

    static void StartRecording(Player* p, Creature* c)
    {
        float hx, hy, hz, ho;
        c->GetHomePosition(hx, hy, hz, ho);
        Recording r;
        r.npc = c->GetSpawnId();
        r.map = c->GetMapId();
        Position start; start.Relocate(hx, hy, hz, ho);
        r.pts.push_back(start);            // the route always starts at their post
        if (p->GetExactDist2d(hx, hy) >= REC_STEP)
            r.pts.push_back(p->GetPosition());
        recording[p->GetGUID().GetCounter()] = r;
        patrolPick.erase(p->GetGUID().GetCounter());
        selected.erase(p->GetGUID().GetCounter());
        if (!p->HasItemCount(ZeroCraftHome::ROD, 1, true))
            p->AddItem(ZeroCraftHome::ROD, 1);
        ChatHandler(p->GetSession()).SendSysMessage("ZCROD:start");
        ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat(
            "Walk the route you want {} to patrol. When you're done, use the Builder's Rod and click the ground to finish.", c->GetName()));
        RecordTick(p);
    }

    static void FinishRecording(Player* p)
    {
        auto it = recording.find(p->GetGUID().GetCounter());
        if (it == recording.end())
            return;
        Recording r = it->second;
        recording.erase(it);
        Creature* c = p->GetMapId() == r.map ? Find(p->GetMap(), r.npc) : nullptr;
        if (!c || !ZeroCraftOrders::Owns(p, c))
        {
            ZeroCraftDeploy::RedError(p, "Couldn't find that NPC any more.");
            return;
        }
        if (p->GetExactDist2d(r.pts.back().GetPositionX(), r.pts.back().GetPositionY()) >= 1.0f && r.pts.size() < REC_MAX)
            r.pts.push_back(p->GetPosition());
        if (r.pts.size() < 2)
        {
            ZeroCraftDeploy::RedError(p, "Walk a bit further first - the route is too short.");
            return;
        }
        for (Position const& pt : r.pts)
        {
            std::string err;
            if (ZeroCraftDeploy::BuildCheck && !ZeroCraftDeploy::BuildCheck(p, pt.GetPositionX(), pt.GetPositionY(), pt.GetPositionZ(), err))
            {
                ZeroCraftDeploy::RedError(p, "Part of that route crosses land you don't have building privilege on.");
                return;
            }
        }
        // there and back again: 1..N, then N-1..2 (the path loops back to 1)
        std::vector<Position> full = r.pts;
        for (size_t i = r.pts.size() - 1; i-- > 1;)
            full.push_back(r.pts[i]);
        uint32 path = PATH_BASE + c->GetSpawnId();
        StartPatrol(c, 0);
        WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM waypoint_data WHERE id = {}", path));
        std::string values;
        for (size_t i = 0; i < full.size(); ++i)
        {
            bool end = i == 0 || i == r.pts.size() - 1;   // pause a moment at each end
            values += Acore::StringFormat("{}({}, {}, {}, {}, {}, NULL, {}, {}, 0, 0, 0, 100, 0)", i ? ", " : "",
                path, i + 1, full[i].GetPositionX(), full[i].GetPositionY(), full[i].GetPositionZ(), ROAM_SPEED, end ? 3000 : 0);
        }
        WorldDatabase.DirectExecute("INSERT INTO waypoint_data (id, point, position_x, position_y, position_z, orientation, velocity, delay, smoothTransition, move_type, action, action_chance, wpguid) VALUES " + values);
        sWaypointMgr->ReloadPath(path);
        SetPatrol(c, path);
        ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat(
            "{} learns your route ({} stops) and will walk it there and back until told otherwise.", c->GetName(), r.pts.size()));
    }

    // "Roam": a random loop of stops around the post, every stop on land you may build on,
    // so they keep walking all over your claim without ever leaving it.
    static bool Roam(Player* p, Creature* c)
    {
        if (c->IsTaxi() || c->HasNpcFlag(UNIT_NPC_FLAG_BANKER) || c->IsInCombat())
            return false;
        float hx, hy, hz, ho;
        c->GetHomePosition(hx, hy, hz, ho);
        // inside a Summoning Stone claim: roam the whole claim. In the wild: 60 yards around the post.
        ZeroCraftHome::Stone stone;
        bool claimed = ZeroCraftHome::ClaimAt(c->GetMap(), hx, hy, hz, stone);
        auto inside = [&](float x, float y, float z) -> bool
        {
            std::string err;
            if (ZeroCraftDeploy::BuildCheck && !ZeroCraftDeploy::BuildCheck(p, x, y, z, err))
                return false;
            if (claimed)
            {
                ZeroCraftHome::Stone s2;
                return ZeroCraftHome::ClaimAt(c->GetMap(), x, y, z, s2) && s2.spawn == stone.spawn;
            }
            return (x - hx) * (x - hx) + (y - hy) * (y - hy) < 60.0f * 60.0f;
        };
        // a long wandering walk: each stop 15-35 yards on from the last, heading off in a
        // new-ish direction, then they walk it all the way back and start again
        std::vector<Position> pts;
        Position first; first.Relocate(hx, hy, hz, 0.0f);
        pts.push_back(first);
        float heading = frand(0.0f, 2.0f * float(M_PI));
        for (uint32 tries = 0; tries < 200 && pts.size() < 25; ++tries)
        {
            Position const& last = pts.back();
            float a = heading + frand(-1.2f, 1.2f), d = frand(15.0f, 35.0f);
            float x = last.GetPositionX() + d * std::cos(a), y = last.GetPositionY() + d * std::sin(a), z = last.GetPositionZ() + 5.0f;
            c->UpdateGroundPositionZ(x, y, z);
            if (std::fabs(z - last.GetPositionZ()) > 10.0f || !inside(x, y, z))
            {
                heading = frand(0.0f, 2.0f * float(M_PI));   // hit the edge of your land: turn around
                continue;
            }
            heading = a;
            Position pt; pt.Relocate(x, y, z, 0.0f);
            pts.push_back(pt);
        }
        if (pts.size() < 3)
            return false;
        std::vector<Position> full = pts;
        for (size_t i = pts.size() - 1; i-- > 1;)
            full.push_back(pts[i]);
        uint32 path = CIRCLE_BASE + c->GetSpawnId();
        StartPatrol(c, 0);
        WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM waypoint_data WHERE id = {}", path));
        std::string values;
        for (size_t i = 0; i < full.size(); ++i)
            values += Acore::StringFormat("{}({}, {}, {}, {}, {}, NULL, {}, {}, 0, 0, 0, 100, 0)", i ? ", " : "",
                path, i + 1, full[i].GetPositionX(), full[i].GetPositionY(), full[i].GetPositionZ(),
                ROAM_SPEED, urand(0, 4) ? 0 : urand(2000, 6000));
        WorldDatabase.DirectExecute("INSERT INTO waypoint_data (id, point, position_x, position_y, position_z, orientation, velocity, delay, smoothTransition, move_type, action, action_chance, wpguid) VALUES " + values);
        sWaypointMgr->ReloadPath(path);
        SetPatrol(c, path);
        return true;
    }

    static struct RoamInit { RoamInit() {
        ZeroCraftDeploy::AutoRoam = [](Player* p, Creature* c) { return Roam(p, c); };
        ZeroCraftDeploy::AutoScale = [](Creature* c, float sc) { SetScale(c, sc); };
    } } roamInit;

    static std::vector<Creature*> MineNear(Player* p, float range)
    {
        std::vector<Creature*> v;
        auto& store = p->GetMap()->GetCreatureBySpawnIdStore();
        for (auto const& pair : ZeroCraftDeploy::spawnFaction)
        {
            auto r = store.equal_range(pair.first);
            for (auto it = r.first; it != r.second; ++it)
                if (it->second && it->second->IsInWorld() && p->IsWithinDistInMap(it->second, range) && ZeroCraftOrders::Owns(p, it->second))
                    v.push_back(it->second);
        }
        return v;
    }

    static void RoamAll(Player* p, float range)
    {
        uint32 n = 0, skipped = 0;
        for (Creature* c : MineNear(p, range))
            Roam(p, c) ? ++n : ++skipped;
        ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat(
            "{} of your NPCs within {} yards set off to roam your land.{}", n, uint32(range),
            skipped ? Acore::StringFormat(" ({} stayed put - Flight Masters, Bankers, or no room to roam.)", skipped) : std::string()));
    }

    static void StopAll(Player* p, float range)
    {
        uint32 n = 0;
        for (Creature* c : MineNear(p, range))
        {
            SetPatrol(c, 0);
            c->GetMotionMaster()->MoveTargetedHome();
            ++n;
        }
        ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} of your NPCs within {} yards stop and stand guard.", n, uint32(range)));
    }

    // Claim the flight point this Flight Master stands at. Works for any Flight Master:
    // a world one (not anybody's yet) joins your guild; your own just plants your colours;
    // one serving another guild has to be defeated first.
    static void ClaimFlightPoint(Player* p, Creature* c)
    {
        if (!c->IsTaxi())
            return;
        if (!ZeroCraftOrders::Owns(p, c))
        {
            if (ZeroCraftDeploy::spawnFaction.count(c->GetSpawnId()))
            {
                std::string owner;
                if (QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT owner_guild_name FROM zerocraft_deployables WHERE spawn_id = {}", c->GetSpawnId())))
                    owner = (*r)[0].Get<std::string>();
                std::string mine = ZeroCraftDeploy::GuildNameOf(p);
                if (owner.empty() || owner != mine)
                {
                    ZeroCraftDeploy::RedError(p, c->GetName() + (owner.empty() ? std::string(" serves someone else.") : " serves <" + owner + ">.") + " Defeat them to take this flight point.");
                    return;
                }
            }
            // take them into your service
            int64 key = ZeroCraftDeploy::OwnerKey(p);
            uint32 tpl = ZeroCraftDeploy::GetOrClaimSlot(key);
            if (!tpl)
            {
                ZeroCraftDeploy::RedError(p, "No free deployment slots left on this server.");
                return;
            }
            ZeroCraftDeploy::spawnFaction[c->GetSpawnId()] = tpl;
            WorldDatabase.DirectExecute(Acore::StringFormat(
                "REPLACE INTO zerocraft_deployables (spawn_id, entry, owner_player, owner_guild, faction_template, owner_guild_name) VALUES ({}, {}, {}, {}, {}, '{}')",
                c->GetSpawnId(), c->GetEntry(), p->GetGUID().GetCounter(), p->GetGuildId(), tpl, ZeroCraftDeploy::GuildNameOf(p)));
            c->SetFaction(ZeroCraftDeploy::ZC_FACTION);
            c->SetNpcFlag(UNIT_NPC_FLAG_GOSSIP);
            ZeroCraftDeploy::ApplyReactions(p);
            ZeroCraftTaxi::Register(c);
        }
                TaxiNodesEntry const* n = ZeroCraftWar::NearestWarNode(c->GetMapId(), c->GetPositionX(), c->GetPositionY(), c->GetPositionZ());
                if (!n)
                {
                    ZeroCraftDeploy::RedError(p, "There's no flight point within 150 yards to claim. Deploy the Flight Master closer to one.");
                    return;
                }
                if (c->GetExactDist(n->x, n->y, n->z) > 8.0f)
                {
                    // walk over and take up the post at the flight point itself
                    float x = n->x, y = n->y, z = n->z;
                    c->UpdateGroundPositionZ(x, y, z);
                    CreatureData& data = sObjectMgr->NewOrExistCreatureData(c->GetSpawnId());
                    data.posX = x; data.posY = y; data.posZ = z;
                    WorldDatabase.DirectExecute(Acore::StringFormat(
                        "UPDATE creature SET position_x = {}, position_y = {}, position_z = {} WHERE guid = {}", x, y, z, c->GetSpawnId()));
                    c->SetHomePosition(x, y, z, c->GetOrientation());
                    c->GetMotionMaster()->MovePoint(0, x, y, z);
                }
                if (p->GetGuildId())
                    WorldDatabase.DirectExecute(Acore::StringFormat(
                        "UPDATE zerocraft_deployables SET owner_guild = {}, owner_guild_name = '{}' WHERE spawn_id = {}",
                        p->GetGuildId(), ZeroCraftDeploy::GuildNameOf(p), c->GetSpawnId()));
                ZeroCraftWar::Refresh();
                ZeroCraftWar::SendNow(p);   // your map updates right away
                ZeroCraftTaxi::Apply(p);
                ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat(
                    "{} plants your colours at {}. The flight point is yours - check your world map.", c->GetName(), ZeroCraftWar::CleanName(n->name[0])));
    }

    static void PatrolMenu(Player* p, Creature* c)
    {
        ClearGossipMenuFor(p);
        Add(p, "EVERYONE within 30 yards: roam my land", A_ROAM30);
        Add(p, "EVERYONE within 30 yards: stop and stand guard", A_STOP30);
        Add(p, "Follow me (bodyguard)", A_ESCORT);
        auto lk = looks.find(c->GetSpawnId());
        if (c->GetWaypointPath() || escorting.count(c->GetSpawnId()) || (lk != looks.end() && lk->second.path))
            Add(p, "Stop patrolling - stand guard here", A_STOPPATROL);
        SendGossipMenuFor(p, DEFAULT_GOSSIP_MESSAGE, c->GetGUID());
    }

    // Builder's Rod after "Patrol between here and another point": the NPC walks between its post and the clicked spot
    static void SetSecondPoint(Player* p, WorldLocation const& dst)
    {
        auto it = patrolPick.find(p->GetGUID().GetCounter());
        Creature* c = it != patrolPick.end() ? Find(p->GetMap(), it->second) : nullptr;
        patrolPick.erase(p->GetGUID().GetCounter());
        if (!c || !ZeroCraftOrders::Owns(p, c))
            return;
        if (c->IsTaxi() || c->HasNpcFlag(UNIT_NPC_FLAG_BANKER))
        {
            ZeroCraftDeploy::RedError(p, "Flight Masters and Bankers stay at their posts.");
            return;
        }
        float hx, hy, hz, ho;
        c->GetHomePosition(hx, hy, hz, ho);
        if (c->GetExactDist(dst.GetPositionX(), dst.GetPositionY(), dst.GetPositionZ()) > 100.0f)
        {
            ZeroCraftDeploy::RedError(p, "That's too far - keep patrols within 100 yards.");
            return;
        }
        std::string err;
        if (ZeroCraftDeploy::BuildCheck && !ZeroCraftDeploy::BuildCheck(p, dst.GetPositionX(), dst.GetPositionY(), dst.GetPositionZ(), err))
        {
            ZeroCraftDeploy::RedError(p, err);
            return;
        }
        uint32 path = PATH_BASE + c->GetSpawnId();
        StartPatrol(c, 0);   // stop walking the old route before it is replaced
        WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM waypoint_data WHERE id = {}", path));
        WorldDatabase.DirectExecute(Acore::StringFormat(
            "INSERT INTO waypoint_data (id, point, position_x, position_y, position_z, orientation, velocity, delay, smoothTransition, move_type, action, action_chance, wpguid) VALUES "
            "({}, 1, {}, {}, {}, NULL, 0, 3000, 0, 0, 0, 100, 0), ({}, 2, {}, {}, {}, NULL, 0, 3000, 0, 0, 0, 100, 0)",
            path, hx, hy, hz, path, dst.GetPositionX(), dst.GetPositionY(), dst.GetPositionZ()));
        sWaypointMgr->ReloadPath(path);
        SetPatrol(c, path);
        ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} starts patrolling.", c->GetName()));
    }

    static void PlaceSelected(Player* p, WorldLocation const& dst)
    {
        auto sel = selected.find(p->GetGUID().GetCounter());
        Creature* c = sel != selected.end() ? Find(p->GetMap(), sel->second) : nullptr;
        if (!c || !ZeroCraftOrders::Owns(p, c))
        {
            selected.erase(p->GetGUID().GetCounter());
            ZeroCraftDeploy::RedError(p, "Click one of your NPCs and choose \"Place it\" first.");
            return;
        }
        if (c->GetExactDist(dst.GetPositionX(), dst.GetPositionY(), dst.GetPositionZ()) > 60.0f)
        {
            ZeroCraftDeploy::RedError(p, "That's too far from where they stand now.");
            return;
        }
        if (MoveTo(p, c, dst.GetPositionX(), dst.GetPositionY(), dst.GetPositionZ(), c->GetOrientation()))
            ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} takes up the new post.", c->GetName()));
    }
}

class ZeroCraftNpcEditScript : public AllCreatureScript
{
public:
    ZeroCraftNpcEditScript() : AllCreatureScript("ZeroCraftNpcEditScript") { }

private:
    std::unordered_map<ObjectGuid::LowType, uint32> timers;
public:

    // patrol watchdog: every few seconds, a patroller that has stopped (after a fight, a chat, a
    // finished route...) is sent back on its route. Patrols run until someone stops them.
    void OnAllCreatureUpdate(Creature* c, uint32 diff) override
    {
        ObjectGuid::LowType id = c->GetSpawnId();
        if (!id || !ZeroCraftNpcEdit::looksLoaded)
            return;
        auto it = ZeroCraftNpcEdit::looks.find(id);
        if (it == ZeroCraftNpcEdit::looks.end() || !it->second.path || ZeroCraftNpcEdit::escorting.count(id))
            return;
        uint32& t = timers[id];
        t += diff;
        if (t < 4 * IN_MILLISECONDS)
            return;
        t = 0;
        if (!c->IsAlive() || c->IsInCombat() || c->IsInEvadeMode() || c->HasUnitState(UNIT_STATE_CASTING))
            return;
        MovementGeneratorType want = it->second.path == ZeroCraftNpcEdit::PATROL_WANDER ? RANDOM_MOTION_TYPE : WAYPOINT_MOTION_TYPE;
        MovementGeneratorType now = c->GetMotionMaster()->GetCurrentMovementGeneratorType();
        // only restart a patroller who has really stopped (not one pausing to talk or walking home)
        if (now != want && (now == IDLE_MOTION_TYPE || now == NULL_MOTION_TYPE))
            ZeroCraftNpcEdit::StartPatrol(c, it->second.path);
    }

    void OnCreatureAddWorld(Creature* c) override
    {
        if (c->IsTaxi() && c->GetSpawnId())
            c->SetNpcFlag(UNIT_NPC_FLAG_GOSSIP);   // every Flight Master can be talked to (and claimed)
        if (c->GetSpawnId() && ZeroCraftDeploy::spawnFaction.count(c->GetSpawnId()))
        {
            c->SetNpcFlag(UNIT_NPC_FLAG_GOSSIP);   // speech-bubble cursor
            ZeroCraftNpcEdit::LoadLooks();
            auto it = ZeroCraftNpcEdit::looks.find(c->GetSpawnId());
            if (it != ZeroCraftNpcEdit::looks.end())
            {
                if (it->second.scale != 1.0f)
                    c->SetObjectScale(it->second.scale);
                if (it->second.path)
                {
                    uint32 path = it->second.path;
                    ObjectGuid g = c->GetGUID();
                    c->m_Events.AddEventAtOffset([c, path]() { if (c->IsInWorld() && c->IsAlive()) ZeroCraftNpcEdit::StartPatrol(c, path); }, Milliseconds(1000));
                    (void)g;
                }
            }
        }
    }

    bool CanCreatureGossipHello(Player* p, Creature* c) override
    {
        if (c->IsTaxi() && c->GetSpawnId() && !ZeroCraftOrders::Owns(p, c))
        {
            ClearGossipMenuFor(p);
            AddGossipItemFor(p, GOSSIP_ICON_TAXI, "Show me where you can fly", ZeroCraftNpcEdit::TAXI_SENDER, 1);
            AddGossipItemFor(p, GOSSIP_ICON_BATTLE, "Claim this flight point for my guild", ZeroCraftNpcEdit::TAXI_SENDER, 2);
            SendGossipMenuFor(p, DEFAULT_GOSSIP_MESSAGE, c->GetGUID());
            return true;
        }
        if (!c->GetSpawnId() || !ZeroCraftDeploy::spawnFaction.count(c->GetSpawnId()) || !ZeroCraftOrders::Owns(p, c))
            return false;
        if (c->GetEntry() == ZeroCraftDeploy::STONE_GUARD)
        {
            if (GameObject* go = ZeroCraftHome::Find(c->GetMap(), ZeroCraftHome::StoneOf(c->GetSpawnId())))
                ZeroCraftHome::Hello(p, go);
            return true;
        }
        if (c->HasNpcFlag(UNIT_NPC_FLAG_BANKER))
            return false;   // the Banker has his own menu (with an edit entry)
        ZeroCraftNpcEdit::HoldStill(p, c);
        ZeroCraftNpcEdit::MainMenu(p, c);
        return true;
    }

    bool CanCreatureGossipSelect(Player* p, Creature* c, uint32 sender, uint32 action) override
    {
        using namespace ZeroCraftNpcEdit;
        if (sender == TAXI_SENDER && c->IsTaxi())
        {
            CloseGossipMenuFor(p);
            if (action == 1)
                p->GetSession()->SendTaxiMenu(c);
            else
                ClaimFlightPoint(p, c);
            return true;
        }
        if (sender != SENDER || !c->GetSpawnId() || !ZeroCraftOrders::Owns(p, c))
            return false;
        auto& st = ZeroCraftHome::steps[p->GetGUID().GetCounter()];
        switch (action)
        {
            case A_DONE: CloseGossipMenuFor(p); c->ResumeMovement(); return true;
            case A_MAIN: MainMenu(p, c); return true;
            case A_MOVE: MoveMenu(p, c); return true;
            case A_TURN: TurnMenu(p, c); return true;
            case A_MSTEP: st.move = (st.move + 1) % 6; MoveMenu(p, c); return true;
            case A_TSTEP: st.turn = (st.turn + 1) % 4; TurnMenu(p, c); return true;
            case A_UNSELECT: selected.erase(p->GetGUID().GetCounter()); MainMenu(p, c); return true;
            case A_RESIZE: ResizeMenu(p, c); return true;
            case A_NDELETE:
                ClearGossipMenuFor(p);
                AddGossipItemFor(p, GOSSIP_ICON_BATTLE, "|cffcc0000Yes - dismiss " + c->GetName() + " forever|r", SENDER, A_NDELETE_YES);
                Add(p, "No, keep them", A_MAIN);
                SendGossipMenuFor(p, ZeroCraftHome::T_MAIN, c->GetGUID());
                return true;
            case A_NDELETE_YES:
                CloseGossipMenuFor(p);
                if (c->IsInCombat())
                {
                    ZeroCraftDeploy::RedError(p, "They can't be dismissed while fighting.");
                    return true;
                }
                selected.erase(p->GetGUID().GetCounter());
                SetPatrol(c, 0);
                ZeroCraftRecallItem::Pack(p, c, false);
                return true;
            case A_PACK:
                CloseGossipMenuFor(p);
                if (c->IsInCombat())
                {
                    ZeroCraftDeploy::RedError(p, "They can't pack up while fighting.");
                    return true;
                }
                ZeroCraftRecallItem::Pack(p, c);
                return true;
            case A_SSTEP: st.size = (st.size + 1) % 4; ResizeMenu(p, c); return true;
            case A_BIG: case A_SMALL: case A_RESET:
            {
                float grow = 1.0f + ZeroCraftHome::SIZE_STEPS[st.size] / 100.0f;
                float sc = action == A_RESET ? 1.0f : action == A_BIG ? std::min(c->GetObjectScale() * grow, 4.0f) : std::max(c->GetObjectScale() / grow, 0.2f);
                SetScale(c, sc);
                ResizeMenu(p, c);
                return true;
            }
            case A_PATROL: PatrolMenu(p, c); return true;
            case A_STOPMAIN:
                SetPatrol(c, 0);
                c->GetMotionMaster()->Clear();
                c->GetMotionMaster()->MoveIdle();
                c->SetHomePosition(c->GetPositionX(), c->GetPositionY(), c->GetPositionZ(), c->GetAngle(p));
                if (MoveTo(p, c, c->GetPositionX(), c->GetPositionY(), c->GetPositionZ(), c->GetAngle(p)))
                    ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} stops and stands guard right here.", c->GetName()));
                MainMenu(p, c);
                return true;
            case A_STOPPATROL:
                SetPatrol(c, 0);
                c->GetMotionMaster()->MoveTargetedHome();
                PatrolMenu(p, c);
                return true;
            case A_CIRCLE: case A_WANDER: case A_ESCORT:
            {
                if (c->IsTaxi() || c->HasNpcFlag(UNIT_NPC_FLAG_BANKER))
                {
                    ZeroCraftDeploy::RedError(p, "Flight Masters and Bankers stay at their posts.");
                    PatrolMenu(p, c);
                    return true;
                }
                if (action == A_WANDER)
                {
                    SetPatrol(c, PATROL_WANDER);
                    ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} wanders about, keeping an eye on things.", c->GetName()));
                }
                else if (action == A_CIRCLE)
                {
                    float hx, hy, hz, ho;
                    c->GetHomePosition(hx, hy, hz, ho);
                    uint32 path = CIRCLE_BASE + c->GetSpawnId();
                    StartPatrol(c, 0);
                    WorldDatabase.DirectExecute(Acore::StringFormat("DELETE FROM waypoint_data WHERE id = {}", path));
                    std::string values;
                    for (uint32 i = 0; i < 8; ++i)
                    {
                        float a = float(i) * float(M_PI) / 4.0f;
                        float x = hx + 8.0f * std::cos(a), y = hy + 8.0f * std::sin(a), z = hz;
                        c->UpdateGroundPositionZ(x, y, z);
                        values += Acore::StringFormat("{}({}, {}, {}, {}, {}, NULL, 0, 0, 0, 0, 0, 100, 0)", i ? ", " : "", path, i + 1, x, y, z);
                    }
                    WorldDatabase.DirectExecute("INSERT INTO waypoint_data (id, point, position_x, position_y, position_z, orientation, velocity, delay, smoothTransition, move_type, action, action_chance, wpguid) VALUES " + values);
                    sWaypointMgr->ReloadPath(path);
                    SetPatrol(c, path);
                    ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} walks a ring around the post.", c->GetName()));
                }
                else
                {
                    SetPatrol(c, 0);
                    escorting[c->GetSpawnId()] = p->GetGUID();
                    c->GetMotionMaster()->Clear();
                    c->GetMotionMaster()->MoveFollow(p, 2.5f, frand(float(M_PI) * 0.6f, float(M_PI) * 1.4f));
                    ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat(
                        "{} falls in behind you. Choose \"Stop patrolling\" to send them back to their post.", c->GetName()));
                }
                CloseGossipMenuFor(p);
                return true;
            }
            case A_CLAIM:
                CloseGossipMenuFor(p);
                ClaimFlightPoint(p, c);
                return true;
            case A_ROAM:
                CloseGossipMenuFor(p);
                if (Roam(p, c))
                    ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} sets off to roam your land.", c->GetName()));
                else
                    ZeroCraftDeploy::RedError(p, "They can't roam from here (Flight Masters and Bankers stay put, or there's no land of yours around them).");
                return true;
            case A_ROAM10: CloseGossipMenuFor(p); RoamAll(p, 10.0f); return true;
            case A_ROAM30: CloseGossipMenuFor(p); RoamAll(p, 30.0f); return true;
            case A_STOP30: CloseGossipMenuFor(p); StopAll(p, 30.0f); return true;
            case A_RECORD:
                if (c->IsTaxi() || c->HasNpcFlag(UNIT_NPC_FLAG_BANKER))
                {
                    ZeroCraftDeploy::RedError(p, "Flight Masters and Bankers stay at their posts.");
                    PatrolMenu(p, c);
                    return true;
                }
                CloseGossipMenuFor(p);
                StartRecording(p, c);
                return true;
            case A_RECCANCEL:
                recording.erase(p->GetGUID().GetCounter());
                ChatHandler(p->GetSession()).SendSysMessage("Route cancelled.");
                PatrolMenu(p, c);
                return true;
            case A_PATROL2:
                recording.erase(p->GetGUID().GetCounter());
                patrolPick[p->GetGUID().GetCounter()] = c->GetSpawnId();
                selected.erase(p->GetGUID().GetCounter());
                if (!p->HasItemCount(ZeroCraftHome::ROD, 1, true))
                    p->AddItem(ZeroCraftHome::ROD, 1);
                CloseGossipMenuFor(p);
                ChatHandler(p->GetSession()).SendSysMessage("ZCROD:start");
                return true;
            case A_USE:
                if (ZeroCraftProf::Is(c->GetEntry()))
                {
                    ZeroCraftProf::Open(p, c);
                    return true;
                }
                if (c->GetEntry() == 911172)
                {
                    ZeroCraftEnchanter::Slots(p, c);
                    return true;
                }
                ClearGossipMenuFor(p);
                p->PrepareGossipMenu(c, c->GetCreatureTemplate()->GossipMenuId, true);
                p->SendPreparedGossip(c);
                return true;
            case A_PLACE:
                selected[p->GetGUID().GetCounter()] = c->GetSpawnId();
                ZeroCraftHome::selected.erase(p->GetGUID().GetCounter());
                if (!p->HasItemCount(ZeroCraftHome::ROD, 1, true))
                    p->AddItem(ZeroCraftHome::ROD, 1);
                CloseGossipMenuFor(p);
                ChatHandler(p->GetSession()).SendSysMessage("ZCROD:start");
                return true;
            default: break;
        }
        float x = c->GetPositionX(), y = c->GetPositionY(), z = c->GetPositionZ(), o = c->GetOrientation();
        float away = std::atan2(y - p->GetPositionY(), x - p->GetPositionX());
        float step = ZeroCraftHome::MOVE_STEPS[st.move];
        float turn = ZeroCraftHome::TURN_STEPS[st.turn] * float(M_PI) / 180.0f;
        switch (action)
        {
            case A_FWD:   x += step * std::cos(away); y += step * std::sin(away); break;
            case A_BACK:  x -= step * std::cos(away); y -= step * std::sin(away); break;
            case A_LEFT:  x += step * std::cos(away + float(M_PI) / 2); y += step * std::sin(away + float(M_PI) / 2); break;
            case A_RIGHT: x += step * std::cos(away - float(M_PI) / 2); y += step * std::sin(away - float(M_PI) / 2); break;
            case A_UP:    z += step; break;
            case A_DOWN:  z -= step; break;
            case A_HERE:  p->GetClosePoint(x, y, z, p->GetCombatReach(), 3.0f, 0.0f); o = Position::NormalizeOrientation(p->GetOrientation() + float(M_PI)); break;
            case A_TURNL:    o = Position::NormalizeOrientation(o + turn); break;
            case A_TURNR:    o = Position::NormalizeOrientation(o - turn); break;
            case A_TURNL90:  o = Position::NormalizeOrientation(o + float(M_PI) / 2); break;
            case A_TURNR90:  o = Position::NormalizeOrientation(o - float(M_PI) / 2); break;
            case A_FACE:
            case A_MFACE:    o = Position::NormalizeOrientation(away + float(M_PI)); break;
            case A_FACEAWAY: o = Position::NormalizeOrientation(away); break;
            default:
                if (action >= A_ROUTE)
                {
                    if (c->IsTaxi() || c->HasNpcFlag(UNIT_NPC_FLAG_BANKER))
                    {
                        ZeroCraftDeploy::RedError(p, "Flight Masters and Bankers stay at their posts.");
                        MainMenu(p, c);
                        return true;
                    }
                    // find the matching route again (the action only carries part of the path id)
                    for (auto const& r : OldRoutes(c))
                        if (A_ROUTE + (r.first / 10) % 1000000 == action)
                        {
                            SetPatrol(c, r.first);
                            ChatHandler(p->GetSession()).PSendSysMessage(Acore::StringFormat("{} takes up the old patrol.", c->GetName()));
                            break;
                        }
                    CloseGossipMenuFor(p);
                    return true;
                }
                MainMenu(p, c);
                return true;
        }
        MoveTo(p, c, x, y, z, o);
        if (action / 100 == 2) TurnMenu(p, c); else MoveMenu(p, c);
        return true;
    }
};

// ============================================================================
// ZeroCraft full loot: when you die, everything in your bags - but not what
// you're wearing - spills onto the ground as "Fallen Adventurer's Packs" (16
// stacks per pack) that anyone can loot for 30 minutes. You keep your
// Hearthstone, both Commander's Banners, Recall Orders and the Builder's Rod.
// ============================================================================
class ZeroCraftDeathDrop : public PlayerScript
{
public:
    ZeroCraftDeathDrop() : PlayerScript("ZeroCraftDeathDrop") { }

    static bool Keep(Item* it)
    {
        static uint32 recall = 0;
        static bool looked = false;
        if (!looked)
        {
            looked = true;
            uint32 sid = sObjectMgr->GetScriptId("item_zerocraft_recall");
            for (auto const& kv : *sObjectMgr->GetItemTemplateStore())
                if (kv.second.ScriptId == sid) { recall = kv.first; break; }
        }
        uint32 e = it->GetEntry();
        return e == 6948 || e == 23700 || e == 23701 || e == 60407 || (recall && e == recall);
    }

    void OnPlayerJustDied(Player* p) override
    {
        if (!p || !p->IsInWorld() || p->IsGameMaster() || p->InBattleground() || p->InArena())
            return;
        std::vector<std::pair<uint32, uint32>> drop;
        auto take = [&](uint8 bag, uint8 slot, Item* it)
        {
            if (!it || Keep(it))
                return;
            drop.push_back({ it->GetEntry(), it->GetCount() });
            p->DestroyItem(bag, slot, true);
        };
        for (uint8 slot = INVENTORY_SLOT_ITEM_START; slot < INVENTORY_SLOT_ITEM_END; ++slot)
            take(INVENTORY_SLOT_BAG_0, slot, p->GetItemByPos(INVENTORY_SLOT_BAG_0, slot));
        for (uint8 bag = INVENTORY_SLOT_BAG_START; bag < INVENTORY_SLOT_BAG_END; ++bag)
            if (Bag* b = p->GetBagByPos(bag))
                for (uint32 i = 0; i < b->GetBagSize(); ++i)
                    take(bag, uint8(i), b->GetItemByPos(uint8(i)));
        if (drop.empty())
            return;

        Map* map = p->GetMap();
        size_t i = 0;
        uint32 packs = 0;
        while (i < drop.size())
        {
            float a = float(packs) * 1.1f;
            float x = p->GetPositionX() + (packs ? 1.5f * std::cos(a) : 0.0f);
            float y = p->GetPositionY() + (packs ? 1.5f * std::sin(a) : 0.0f);
            float z = p->GetPositionZ();
            p->UpdateGroundPositionZ(x, y, z);
            GameObject* go = map->SummonGameObject(911200, x, y, z, p->GetOrientation(), 0, 0, 0, 0, 30 * MINUTE);
            if (!go)
                break;
            ++packs;
            for (uint32 n = 0; n < MAX_NR_LOOT_ITEMS && i < drop.size(); ++n, ++i)
            {
                uint32 count = std::min<uint32>(drop[i].second, 255);
                go->loot.AddItem(LootStoreItem(drop[i].first, 0, 100.0f, false, LOOT_MODE_DEFAULT, 0, uint8(count), uint8(count)));
            }
        }
        ZeroCraftDeploy::RedError(p, Acore::StringFormat("You dropped everything in your bags ({} item{}). Get back to your {} before someone else does!",
            drop.size(), drop.size() == 1 ? "" : "s", packs == 1 ? "pack" : "packs"));
    }
};

// ============================================================================
// A guild's claimed land is safe ground: nothing hostile or neutral may appear
// inside a Summoning Stone's claim - no wandering beasts, no Enraged Wyverns
// called by flight masters, no other guild's troops. The owning guild's own
// NPCs, the things it built, and players' pets and summons are left alone.
// ============================================================================
class ZeroCraftClaimSafe : public AllCreatureScript
{
public:
    ZeroCraftClaimSafe() : AllCreatureScript("ZeroCraftClaimSafe") { }

    void OnCreatureAddWorld(Creature* c) override
    {
        if (!c || (c->GetMapId() != 0 && c->GetMapId() != 1) || c->GetMap()->Instanceable())
            return;
        if (c->IsPet() || c->IsTotem() || c->GetEntry() == ZeroCraftDeploy::STONE_GUARD || c->GetEntry() == 31144 /*Training Dummy*/)
            return;
        if (Unit* owner = c->GetCharmerOrOwner())
            if (owner->IsPlayer())
                return;
        ZeroCraftHome::Stone st;
        if (!ZeroCraftHome::ClaimAt(c->GetMap(), c->GetPositionX(), c->GetPositionY(), c->GetPositionZ(), st))
            return;
        if (ObjectGuid::LowType id = c->GetSpawnId())
        {
            // the claim owner's own NPCs and things they built stay
            auto it = ZeroCraftDeploy::spawnFaction.find(id);
            if (it != ZeroCraftDeploy::spawnFaction.end())
            {
                int64 key = st.guild ? int64(st.guild) : -int64(st.owner);
                auto slot = ZeroCraftDeploy::ownerSlot.find(key);
                if (slot != ZeroCraftDeploy::ownerSlot.end() && slot->second == it->second)
                    return;
            }
            else if (QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT owner_guild, owner_player FROM zerocraft_placed WHERE kind = 1 AND spawn_id = {}", id)))
            {
                if ((st.guild && (*r)[0].Get<uint32>() == st.guild) || (!st.guild && (*r)[1].Get<uint32>() == st.owner))
                    return;
            }
        }
        // anything else (including creatures summoned by the guild's own NPCs, like Enraged Wyverns) never appears
        c->m_Events.AddEventAtOffset([c]()
        {
            if (!c->IsInWorld())
                return;
            if (c->GetSpawnId() && !c->ToTempSummon())
            {
                c->SetRespawnDelay(0x7FFFFFFF);
                c->SetRespawnTime(0x7FFFFFFF);
            }
            c->DespawnOrUnsummon();
        }, Milliseconds(1));
    }
};

// Summoning Stones are guild banks on the server, but the client is told they're ordinary clickable
// objects: speech-bubble cursor, and clicking opens the stone's menu instead of going straight to the bank.
class ZeroCraftStoneQuery : public ServerScript
{
public:
    ZeroCraftStoneQuery() : ServerScript("ZeroCraftStoneQuery") { }
    bool CanPacketSend(WorldSession* /*session*/, WorldPacket const& packet) override
    {
        if (packet.GetOpcode() != SMSG_GAMEOBJECT_QUERY_RESPONSE || packet.size() < 12)
            return true;
        uint32 entry = packet.read<uint32>(0);
        if (entry < ZeroCraftHome::CLONE)
            return true;
        ZeroCraftHome::Furn const* fu = ZeroCraftHome::OfGo(entry);
        if (!fu || !(fu->stone || fu->srcType == GAMEOBJECT_TYPE_MAILBOX))
            return true;
        // mailboxes and stones would open straight away in the client; make them plain clickable objects
        WorldPacket& w = const_cast<WorldPacket&>(packet);
        w.put<uint32>(4, uint32(GAMEOBJECT_TYPE_GOOBER));
        size_t pos = 12;
        auto skipStr = [&]() { while (pos < w.size() && w.contents()[pos] != 0) ++pos; ++pos; };
        skipStr();          // name
        pos += 3;           // name2-4
        skipStr();          // icon
        skipStr();          // cast bar caption
        skipStr();          // unk1
        for (uint32 i = 0; i < MAX_GAMEOBJECT_DATA && pos + 4 <= w.size(); ++i, pos += 4)
            w.put<uint32>(pos, 0);   // goober data all zero: no lock, no spell
        return true;
    }
};

// Builder's Rod: ground circle, moves the object chosen with "Place it".
class ZeroCraftPlaceRod : public ItemScript
{
public:
    ZeroCraftPlaceRod() : ItemScript("item_zerocraft_placerod") { }
    bool OnUse(Player* player, Item* /*item*/, SpellCastTargets const& targets) override
    {
        if (WorldLocation const* dst = targets.HasDst() ? targets.GetDstPos() : nullptr)
        {
            if (ZeroCraftNpcEdit::recording.count(player->GetGUID().GetCounter()))
                ZeroCraftNpcEdit::FinishRecording(player);
            else if (ZeroCraftNpcEdit::patrolPick.count(player->GetGUID().GetCounter()))
                ZeroCraftNpcEdit::SetSecondPoint(player, *dst);
            else if (ZeroCraftNpcEdit::selected.count(player->GetGUID().GetCounter()))
                ZeroCraftNpcEdit::PlaceSelected(player, *dst);
            else if (ZeroCraftHome::selected.count(player->GetGUID().GetCounter()))
                ZeroCraftHome::PlaceSelected(player, *dst);
            else
                ZeroCraftBuild::EditNearest(player);   // nothing picked: edit whatever you built nearest you (for hard-to-click things)
        }
        else
            ZeroCraftDeploy::RedError(player, "Click a spot on the ground.");
        return true;
    }
};

// Training Dummy (item 60408): use it and a level 60 training dummy stands in front of you.
class ZeroCraftDummyItem : public ItemScript
{
public:
    ZeroCraftDummyItem() : ItemScript("item_zerocraft_dummy") { }
    bool OnUse(Player* player, Item* item, SpellCastTargets const& /*targets*/) override
    {
        if (player->GetMap()->Instanceable() || player->GetTransport())
        {
            ZeroCraftDeploy::RedError(player, "You can only build in the open world.");
            return true;
        }
        float x, y, z;
        player->GetClosePoint(x, y, z, player->GetCombatReach(), 3.0f, 0.0f);
        Position pos;
        pos.Relocate(x, y, z, Position::NormalizeOrientation(player->GetOrientation() + float(M_PI)));
        ZeroCraftBuild::Thing t{ 0, 1, 31144, "Training Dummy", 0 };
        if (ZeroCraftBuild::Place(player, t, pos))
        {
            player->DestroyItemCount(item->GetEntry(), 1, true);
            ChatHandler(player->GetSession()).SendSysMessage("Training Dummy set up. Take down the nearest thing you built to pack it away.");
        }
        else
            ZeroCraftDeploy::RedError(player, "The Training Dummy couldn't be set up here.");
        return true;
    }
};

// ============================================================================
// Guild Standard-Bearer: a guard in your guild's tabard - your emblem, your colours.
// The client draws guild emblems only on player-shaped models, so the bearer is a
// "mirror image" (like the mage spell) of whoever placed it, wearing the guild tabard.
// The emblem always follows the guild's current tabard design.
// ============================================================================
namespace ZeroCraftHerald
{
    static const uint32 NPC = 911140;
    static const uint32 ITEM = 60409;
    struct Look { uint32 display; uint8 race, gender, cls, skin, face, hair, hairColor, facial; uint32 items[11]; };
    static std::unordered_map<ObjectGuid::LowType, Look> looks;

    static bool Get(ObjectGuid::LowType spawn, Look& out)
    {
        auto it = looks.find(spawn);
        if (it != looks.end()) { out = it->second; return true; }
        QueryResult r = WorldDatabase.Query(Acore::StringFormat(
            "SELECT display, race, gender, cls, skin, face, hair, hair_color, facial, items FROM zerocraft_herald WHERE spawn_id = {}", spawn));
        if (!r)
            return false;
        Field* f = r->Fetch();
        Look l{};
        l.display = f[0].Get<uint32>(); l.race = f[1].Get<uint8>(); l.gender = f[2].Get<uint8>(); l.cls = f[3].Get<uint8>();
        l.skin = f[4].Get<uint8>(); l.face = f[5].Get<uint8>(); l.hair = f[6].Get<uint8>(); l.hairColor = f[7].Get<uint8>(); l.facial = f[8].Get<uint8>();
        std::string items = f[9].Get<std::string>();
        size_t pos = 0;
        for (uint32 i = 0; i < 11; ++i)
        {
            size_t c = items.find(',', pos);
            l.items[i] = uint32(std::strtoul(items.substr(pos, c == std::string::npos ? std::string::npos : c - pos).c_str(), nullptr, 10));
            if (c == std::string::npos) { for (uint32 j = i + 1; j < 11; ++j) l.items[j] = 0; break; }
            pos = c + 1;
        }
        looks[spawn] = l;
        out = l;
        return true;
    }

    static void Save(ObjectGuid::LowType spawn, Player* p)
    {
        static EquipmentSlots const slots[] = { EQUIPMENT_SLOT_HEAD, EQUIPMENT_SLOT_SHOULDERS, EQUIPMENT_SLOT_BODY, EQUIPMENT_SLOT_CHEST,
            EQUIPMENT_SLOT_WAIST, EQUIPMENT_SLOT_LEGS, EQUIPMENT_SLOT_FEET, EQUIPMENT_SLOT_WRISTS, EQUIPMENT_SLOT_HANDS, EQUIPMENT_SLOT_BACK, EQUIPMENT_SLOT_TABARD };
        Look l{};
        l.display = p->GetNativeDisplayId(); l.race = p->getRace(); l.gender = p->getGender(); l.cls = p->getClass();
        l.skin = p->GetByteValue(PLAYER_BYTES, 0); l.face = p->GetByteValue(PLAYER_BYTES, 1); l.hair = p->GetByteValue(PLAYER_BYTES, 2);
        l.hairColor = p->GetByteValue(PLAYER_BYTES, 3); l.facial = p->GetByteValue(PLAYER_BYTES_2, 0);
        std::string items;
        for (uint32 i = 0; i < 11; ++i)
        {
            uint32 d = 0;
            if (i == 10)   // always the guild tabard: that's the point
                d = sObjectMgr->GetItemTemplate(5976) ? sObjectMgr->GetItemTemplate(5976)->DisplayInfoID : 0;
            else if (!(i == 0 && p->HasPlayerFlag(PLAYER_FLAGS_HIDE_HELM)))
                if (Item* it = p->GetItemByPos(INVENTORY_SLOT_BAG_0, slots[i]))
                    d = it->GetTemplate()->DisplayInfoID;
            l.items[i] = d;
            items += (i ? "," : "") + std::to_string(d);
        }
        looks[spawn] = l;
        WorldDatabase.DirectExecute(Acore::StringFormat(
            "REPLACE INTO zerocraft_herald (spawn_id, display, race, gender, cls, skin, face, hair, hair_color, facial, items) VALUES ({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, '{}')",
            spawn, l.display, l.race, l.gender, l.cls, l.skin, l.face, l.hair, l.hairColor, l.facial, items));
    }

    static uint32 GuildOf(ObjectGuid::LowType spawn)
    {
        if (QueryResult r = WorldDatabase.Query(Acore::StringFormat("SELECT owner_guild FROM zerocraft_deployables WHERE spawn_id = {}", spawn)))
            return (*r)[0].Get<uint32>();
        return 0;
    }
    // Any guild NPC with a person-shaped model (a guard, a banker...) wears the guild tabard.
    // Its normal look comes from CreatureDisplayInfoExtra; only playable races, to be safe.
    static CreatureDisplayInfoExtraEntry const* Humanoid(Creature const* c)
    {
        CreatureDisplayInfoEntry const* d = sCreatureDisplayInfoStore.LookupEntry(c->GetDisplayId());
        if (!d || !d->ExtendedDisplayInfoID)
            return nullptr;
        CreatureDisplayInfoExtraEntry const* x = sCreatureDisplayInfoExtraStore.LookupEntry(d->ExtendedDisplayInfoID);
        if (!x)
            return nullptr;
        switch (x->DisplayRaceID)
        {
            case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 10: case 11: return x;
            default: return nullptr;
        }
    }
    static bool WantsTabard(Creature const* c)
    {
        return c->GetEntry() != NPC && c->GetSpawnId() && ZeroCraftDeploy::spawnFaction.count(c->GetSpawnId())
            && Humanoid(c) && GuildOf(c->GetSpawnId());
    }
}

class ZeroCraftHeraldItem : public ItemScript
{
public:
    ZeroCraftHeraldItem() : ItemScript("item_zerocraft_herald") { }
    bool OnUse(Player* player, Item* item, SpellCastTargets const& /*targets*/) override
    {
        if (!player->GetGuildId())
        {
            ZeroCraftDeploy::RedError(player, "You need a guild - the Standard-Bearer wears its tabard.");
            return true;
        }
        if (player->GetMap()->Instanceable() || player->GetTransport())
        {
            ZeroCraftDeploy::RedError(player, "You can only build in the open world.");
            return true;
        }
        float x, y, z;
        player->GetClosePoint(x, y, z, player->GetCombatReach(), 3.0f, 0.0f);
        Position pos;
        pos.Relocate(x, y, z, 0.0f);
        if (!ZeroCraftDeploy::Deploy(player, 0, pos, ZeroCraftHerald::NPC))
            return true;
        if (QueryResult r = WorldDatabase.Query(Acore::StringFormat(
            "SELECT MAX(spawn_id) FROM zerocraft_deployables WHERE entry = {} AND owner_player = {}", ZeroCraftHerald::NPC, player->GetGUID().GetCounter())))
        {
            ObjectGuid::LowType id = (*r)[0].Get<uint32>();
            ZeroCraftHerald::Save(id, player);
            auto range = player->GetMap()->GetCreatureBySpawnIdStore().equal_range(id);
            for (auto it = range.first; it != range.second; ++it)
            {
                Creature* c = it->second;
                c->SetDisplayId(ZeroCraftHerald::looks[id].display);
                c->SetNativeDisplayId(ZeroCraftHerald::looks[id].display);
                c->SetFlag(UNIT_FIELD_FLAGS_2, UNIT_FLAG2_MIRROR_IMAGE);
            }
        }
        player->DestroyItemCount(item->GetEntry(), 1, true);
        ChatHandler(player->GetSession()).SendSysMessage("Your Guild Standard-Bearer takes up the colours. Click them to move, turn, resize or send them on patrol.");
        return true;
    }
};

class ZeroCraftHeraldView : public AllCreatureScript
{
public:
    ZeroCraftHeraldView() : AllCreatureScript("ZeroCraftHeraldView") { }
    void OnCreatureAddWorld(Creature* c) override
    {
        if (ZeroCraftHerald::WantsTabard(c))
        {
            c->SetFlag(UNIT_FIELD_FLAGS_2, UNIT_FLAG2_MIRROR_IMAGE);   // client asks us what they wear
            return;
        }
        if (c->GetEntry() != ZeroCraftHerald::NPC || !c->GetSpawnId())
            return;
        ZeroCraftHerald::Look l;
        if (!ZeroCraftHerald::Get(c->GetSpawnId(), l))
            return;
        c->SetDisplayId(l.display);
        c->SetNativeDisplayId(l.display);
        c->SetFlag(UNIT_FIELD_FLAGS_2, UNIT_FLAG2_MIRROR_IMAGE);
    }
};

class ZeroCraftHeraldPackets : public ServerScript
{
public:
    ZeroCraftHeraldPackets() : ServerScript("ZeroCraftHeraldPackets") { }
    bool CanPacketReceive(WorldSession* session, WorldPacket const& packet) override
    {
        if (packet.GetOpcode() != CMSG_GET_MIRRORIMAGE_DATA || packet.size() < 8 || !session || !session->GetPlayer())
            return true;
        ObjectGuid guid(packet.read<uint64>(0));
        Creature* c = ObjectAccessor::GetCreature(*session->GetPlayer(), guid);
        if (!c)
            return true;
        if (c->GetEntry() != ZeroCraftHerald::NPC)
        {
            // a guild NPC: its own face, hair and clothes, but the guild tabard on top
            CreatureDisplayInfoExtraEntry const* x = ZeroCraftHerald::Humanoid(c);
            if (!x || !c->GetSpawnId() || !ZeroCraftDeploy::spawnFaction.count(c->GetSpawnId()))
                return true;
            uint32 guild = ZeroCraftHerald::GuildOf(c->GetSpawnId());
            WorldPacket data(SMSG_MIRRORIMAGE_DATA, 68);
            data << guid << uint32(c->GetDisplayId()) << uint8(x->DisplayRaceID) << uint8(x->DisplaySexID) << uint8(CLASS_WARRIOR)
                 << uint8(x->SkinID) << uint8(x->FaceID) << uint8(x->HairStyleID) << uint8(x->HairColorID) << uint8(x->FacialHairID)
                 << uint32(guild);
            static uint32 const guildTabard = sObjectMgr->GetItemTemplate(5976) ? sObjectMgr->GetItemTemplate(5976)->DisplayInfoID : 0;
            // the DBC lists ...hands, tabard, cloak; the packet wants ...hands, cloak, tabard
            for (uint32 i = 0; i < 9; ++i)
                data << uint32(x->NPCItemDisplay[i]);
            data << uint32(x->NPCItemDisplay[10]);
            data << uint32(guild ? guildTabard : x->NPCItemDisplay[9]);
            session->SendPacket(&data);
            return false;
        }
        ZeroCraftHerald::Look l;
        if (!ZeroCraftHerald::Get(c->GetSpawnId(), l))
            return false;
        WorldPacket data(SMSG_MIRRORIMAGE_DATA, 68);
        data << guid << uint32(l.display) << uint8(l.race) << uint8(l.gender) << uint8(l.cls)
             << uint8(l.skin) << uint8(l.face) << uint8(l.hair) << uint8(l.hairColor) << uint8(l.facial)
             << uint32(ZeroCraftHerald::GuildOf(c->GetSpawnId()));
        for (uint32 i = 0; i < 11; ++i)
            data << uint32(l.items[i]);
        session->SendPacket(&data);
        return false;
    }
};

// Commander's Banner (bag item): uses the Flamestrike circle to pick the spot.
class ZeroCraftCommandBanner : public ItemScript
{
    bool _all;
public:
    ZeroCraftCommandBanner(char const* name, bool all) : ItemScript(name), _all(all) { }

    bool OnUse(Player* player, Item* /*item*/, SpellCastTargets const& targets) override
    {
        if (WorldLocation const* dst = targets.HasDst() ? targets.GetDstPos() : nullptr)
            ZeroCraftCommand::MoveTo(player, *dst, !_all);
        else
            ChatHandler(player->GetSession()).SendSysMessage("Click a spot on the ground.");
        return true; // never consumed, never casts
    }
};

// Everyone carries one banner; the old Meteor-based spell is removed.
class ZeroCraftCommandGiver : public PlayerScript
{
public:
    ZeroCraftCommandGiver() : PlayerScript("ZeroCraftCommandGiver") { }
    void OnPlayerLogin(Player* player) override
    {
        if (player->HasSpell(ZeroCraftCommand::SPELL_COMMAND))
            player->removeSpell(ZeroCraftCommand::SPELL_COMMAND, SPEC_MASK_ALL, false);
        if (!player->HasItemCount(23701, 1, true))
            player->AddItem(23701, 1); // red: targeted NPC only
        if (!player->HasItemCount(23700, 1, true))
            player->AddItem(23700, 1); // blue: all NPCs
    }
};

// Owners/guildmates see their NPCs as friendly (green, usable); everyone else
// sees the real hostile faction. Done per viewer, so there's no owner limit.
class ZeroCraftDeployView : public UnitScript
{
public:
    ZeroCraftDeployView() : UnitScript("ZeroCraftDeployView") { }

    void OnPatchValuesUpdate(Unit const* unit, ByteBuffer& buf, BuildValuesCachePosPointers& pos, Player* target) override
    {
        if (!unit || !target)
            return;

        // Guild war: everyone is free-for-all hostile (GameType = 16), except
        // guildmates - to a guildmate you (and your pet) look like their own
        // faction with no FFA flag, so their client shows you friendly.
        if (unit->IsControlledByPlayer())
        {
            if (Player const* owner = const_cast<Unit*>(unit)->GetCharmerOrOwnerPlayerOrPlayerItself())
                if (owner != target && owner->GetGuildId() && owner->GetGuildId() == target->GetGuildId())
                {
                    if (pos.UnitFieldBytes2Pos >= 0)
                        buf.put(pos.UnitFieldBytes2Pos, unit->GetUInt32Value(UNIT_FIELD_BYTES_2) & ~(uint32(UNIT_BYTE2_FLAG_FFA_PVP) << 8));
                    if (pos.UnitFieldFactionTemplatePos >= 0)
                        buf.put(pos.UnitFieldFactionTemplatePos, uint32(target->GetFaction()));
                }
            return;
        }

        if (pos.UnitFieldFactionTemplatePos < 0 || !unit->IsCreature())
            return;
        int64 tag = ZeroCraftDeploy::TagOfCreature(unit->ToCreature());
        if (tag && ZeroCraftDeploy::PlayerOwnsTag(target, tag))
            buf.put(pos.UnitFieldFactionTemplatePos, ZeroCraftDeploy::ZC_FRIENDLY_VIEW);
    }
};

// Testing helper: if etc/clear_characters.flag exists at startup, every
// character on the server is permanently deleted, then the flag is removed.
class ZeroCraftClearChars : public WorldScript
{
public:
    ZeroCraftClearChars() : WorldScript("ZeroCraftClearChars") { }

    void OnStartup() override
    {
        char const* flag = "/azerothcore/env/dist/etc/clear_characters.flag";
        FILE* f = std::fopen(flag, "r");
        if (!f)
            return;
        char buf[64] = {};
        size_t n = std::fread(buf, 1, sizeof(buf) - 1, f);
        std::fclose(f);
        std::string who;
        for (size_t i = 0; i < n; ++i)
            if (std::isalnum(static_cast<unsigned char>(buf[i])))
                who += char(std::toupper(static_cast<unsigned char>(buf[i])));

        std::string where;
        if (who.empty() || who == "ALL" || who == "DELETE")
            where = "";                               // everyone (developer wipe)
        else if (QueryResult a = LoginDatabase.Query(Acore::StringFormat("SELECT id FROM account WHERE username = '{}'", who)))
            where = Acore::StringFormat(" WHERE account = {}", (*a)[0].Get<uint32>());
        else
        {
            std::remove(flag);
            LOG_INFO("server.loading", "ZeroCraft: clear characters - account {} not found.", who);
            return;
        }

        uint32 count = 0;
        if (QueryResult r = CharacterDatabase.Query("SELECT guid, account FROM characters" + where))
        {
            do
            {
                Player::DeleteFromDB((*r)[0].Get<uint32>(), (*r)[1].Get<uint32>(), true, true);
                ++count;
            } while (r->NextRow());
        }
        std::remove(flag);
        LOG_INFO("server.loading", "ZeroCraft: cleared {} characters.", count);
    }
};

// ============================================================================
// Level squish: every creature in a TBC or Wrath dungeon/raid (and anything
// above level 63 in any instance, e.g. Wrath-era Onyxia) becomes vanilla
// level 60. Health, armor and melee damage follow the level automatically.
// Their spell damage is scaled down to match (TBC x0.5, Wrath x0.25).
// ============================================================================
namespace ZeroCraftSquish
{
    // 0 = not squished, else the map's expansion (1 TBC, 2 Wrath)
    static uint32 SquishTier(Map const* map, CreatureTemplate const* cinfo)
    {
        if (!map || !map->IsDungeon())
            return 0;
        MapEntry const* me = map->GetEntry();
        uint32 exp = me ? me->Expansion() : 0;
        if (exp >= 1)
            return exp;
        if (cinfo && cinfo->maxlevel > 63)
            return 2;
        return 0;
    }

    static bool IsBoss(CreatureTemplate const* cinfo)
    {
        if (cinfo->rank == 3)
            return true;
        std::string const& sn = sObjectMgr->GetScriptName(cinfo->ScriptID);
        return sn.rfind("boss", 0) == 0;
    }
}

class ZeroCraftSquishLevels : public AllCreatureScript
{
public:
    ZeroCraftSquishLevels() : AllCreatureScript("ZeroCraftSquishLevels") { }

    void OnBeforeCreatureSelectLevel(CreatureTemplate const* cinfo, Creature* creature, uint8& level) override
    {
        if (!cinfo || !creature || creature->IsPet() || creature->IsControlledByPlayer())
            return;

        // Deployed heroes/villains are never below level 60.
        if (creature->GetSpawnId() && ZeroCraftDeploy::spawnFaction.count(creature->GetSpawnId()))
        {
            static std::unordered_set<uint32> heroes;
            static bool loaded = false;
            if (!loaded)
            {
                loaded = true;
                if (QueryResult r = WorldDatabase.Query("SELECT entry FROM zerocraft_hero_pool"))
                    do { heroes.insert((*r)[0].Get<uint32>()); } while (r->NextRow());
            }
            if (heroes.count(cinfo->Entry) && level < 60)
                level = 60;

            // Deployed guards (city guards and dungeon elites) are level 55-60.
            static std::unordered_set<uint32> guards;
            static bool guardsLoaded = false;
            if (!guardsLoaded)
            {
                guardsLoaded = true;
                if (QueryResult r = WorldDatabase.Query("SELECT entry FROM zerocraft_guard_pool"))
                    do { guards.insert((*r)[0].Get<uint32>()); } while (r->NextRow());
            }
            if (guards.count(cinfo->Entry))
                level = uint8(55 + creature->GetSpawnId() % 6); // stable per NPC
            return;
        }

        Map* map = creature->FindMap();
        if (!ZeroCraftSquish::SquishTier(map, cinfo))
            return;
        if (ZeroCraftSquish::IsBoss(cinfo))
            level = map->IsRaid() ? 63 : 62;
        else if (cinfo->rank == 1 || cinfo->rank == 2)
            level = 61;
        else
            level = 60;
    }
};

class ZeroCraftSquishDamage : public UnitScript
{
public:
    ZeroCraftSquishDamage() : UnitScript("ZeroCraftSquishDamage") { }

    static float Factor(Unit* attacker)
    {
        if (!attacker || attacker->IsControlledByPlayer())
            return 1.0f;
        Creature* c = attacker->ToCreature();
        if (!c)
            return 1.0f;
        switch (ZeroCraftSquish::SquishTier(c->FindMap(), c->GetCreatureTemplate()))
        {
            case 1: return 0.5f;
            case 2: return 0.25f;
            default: return 1.0f;
        }
    }

    void ModifySpellDamageTaken(Unit* /*target*/, Unit* attacker, int32& damage, SpellInfo const* /*spellInfo*/) override
    {
        float f = Factor(attacker);
        if (f < 1.0f && damage > 0)
            damage = int32(float(damage) * f);
    }

    void ModifyPeriodicDamageAurasTick(Unit* /*target*/, Unit* attacker, uint32& damage, SpellInfo const* /*spellInfo*/) override
    {
        float f = Factor(attacker);
        if (f < 1.0f)
            damage = uint32(float(damage) * f);
    }
};

// Deployed villains (dungeon/raid bosses) use a plain combat AI instead of their
// boss script, which expects to be inside its own dungeon.
class ZeroCraftEntertainerAI : public AllCreatureScript
{
public:
    ZeroCraftEntertainerAI() : AllCreatureScript("ZeroCraftEntertainerAI") { }
    CreatureAI* GetCreatureAI(Creature* creature) const override
    {
        if (!creature || !creature->GetSpawnId() || !ZeroCraftDeploy::spawnFaction.count(creature->GetSpawnId()))
            return nullptr;
        ZeroCraftPool::Entry const* pe = ZeroCraftPool::Of(creature->GetEntry());
        if (!pe || creature->IsVendor() || creature->HasNpcFlag(UNIT_NPC_FLAG_STABLEMASTER))
            return nullptr;
        return new PassiveAI(creature);
    }
};

class ZeroCraftVillainAI : public AllCreatureScript
{
public:
    ZeroCraftVillainAI() : AllCreatureScript("ZeroCraftVillainAI") { }

    static std::unordered_set<uint32>& Villains()
    {
        static std::unordered_set<uint32> v;
        static bool loaded = false;
        if (!loaded)
        {
            loaded = true;
            if (QueryResult r = WorldDatabase.Query("SELECT entry FROM zerocraft_hero_pool WHERE villain = 1"))
                do { v.insert((*r)[0].Get<uint32>()); } while (r->NextRow());
        }
        return v;
    }

    CreatureAI* GetCreatureAI(Creature* creature) const override
    {
        if (!creature || !creature->GetSpawnId())
            return nullptr;
        if (!ZeroCraftDeploy::spawnFaction.count(creature->GetSpawnId()))
            return nullptr;
        if (!Villains().count(creature->GetEntry()))
            return nullptr;
        return new CombatAI(creature);
    }
};

// ============================================================================
// Guild flight networks: a flight point only exists for you while a deployed
// Flight Master owned by you (or your guild) stands at it. Each deployed
// Flight Master claims the nearest built-in flight point (within 150 yards).
// Your flight map shows only your network's points; routes need a chain of
// your own flight points. Native (non-deployed) flight masters don't fly.
// ============================================================================
class ZeroCraftTaxiPlayer : public PlayerScript
{
public:
    ZeroCraftTaxiPlayer() : PlayerScript("ZeroCraftTaxiPlayer") { }

    void OnPlayerLogin(Player* player) override { ZeroCraftTaxi::Apply(player); }

    void OnPlayerUpdate(Player* player, uint32 diff) override
    {
        uint32& t = timers[player->GetGUID().GetCounter()];
        if (t > diff) { t -= diff; return; }
        t = 3000;
        ZeroCraftTaxi::Apply(player);
    }

private:
    std::unordered_map<ObjectGuid::LowType, uint32> timers;
};

class ZeroCraftTaxiCreatures : public AllCreatureScript
{
public:
    ZeroCraftTaxiCreatures() : AllCreatureScript("ZeroCraftTaxiCreatures") { }

    void OnCreatureAddWorld(Creature* c) override
    {
        ZeroCraftTaxi::Register(c);
    }

    // refresh the player's network right before any flight master interaction
    bool CanCreatureGossipHello(Player* player, Creature* c) override
    {
        if (player && c && c->IsTaxi())
            ZeroCraftTaxi::Apply(player);
        return false;
    }
};

class ZeroCraftTaxiPackets : public ServerScript
{
public:
    ZeroCraftTaxiPackets() : ServerScript("ZeroCraftTaxiPackets") { }

    // Only deployed flight masters may open the flight map.
    bool CanPacketSend(WorldSession* session, WorldPacket const& packet) override
    {
        if (packet.GetOpcode() != SMSG_SHOWTAXINODES || packet.size() < 12 || !session || !session->GetPlayer())
            return true;
        ObjectGuid guid(packet.read<uint64>(4));
        Creature* c = ObjectAccessor::GetCreature(*session->GetPlayer(), guid);
        if (!c || !ZeroCraftTaxi::fmNode.count(c->GetSpawnId()))
        {
            ChatHandler(session).SendSysMessage("This flight point is not held by you or your guild.");
            return false;
        }
        ZeroCraftTaxi::Apply(session->GetPlayer());
        ZeroCraftTaxi::SendVisible(session->GetPlayer());
        return true;
    }

    // You can only fly TO one of your guild's own flight points; the stopovers
    // in between are just for passing through.
    bool CanPacketReceive(WorldSession* session, WorldPacket const& packet) override
    {
        if (!session || !session->GetPlayer())
            return true;
        uint16 op = packet.GetOpcode();

        // Guild Vaults only open for the guild that owns them
        if ((op == CMSG_GUILD_BANKER_ACTIVATE || op == CMSG_GUILD_BANK_QUERY_TAB || op == CMSG_GUILD_BANK_SWAP_ITEMS ||
             op == CMSG_GUILD_BANK_BUY_TAB || op == CMSG_GUILD_BANK_UPDATE_TAB || op == CMSG_GUILD_BANK_DEPOSIT_MONEY ||
             op == CMSG_GUILD_BANK_WITHDRAW_MONEY) && packet.size() >= 8)
        {
            ObjectGuid vault(packet.read<uint64>(0));
            // a bank window opened from a stone's menu may carry no (or the wrong) object: point it at that stone
            {
                GameObject* hit = vault.IsGameObject() ? session->GetPlayer()->GetMap()->GetGameObject(vault) : nullptr;
                if (!hit || hit->GetGoType() != GAMEOBJECT_TYPE_GUILD_BANK)
                {
                    auto ls = ZeroCraftHome::lastStone.find(session->GetPlayer()->GetGUID().GetCounter());
                    if (ls != ZeroCraftHome::lastStone.end())
                    {
                        vault = ls->second;
                        const_cast<WorldPacket&>(packet).put<uint64>(0, vault.GetRawValue());
                    }
                }
            }
            if (vault.IsGameObject())
                if (GameObject* sgo = session->GetPlayer()->GetMap()->GetGameObject(vault))
                    if (ZeroCraftHome::Furn const* sfu = ZeroCraftHome::OfGo(sgo->GetEntry()))
                        if (sfu->stone)
                        {
                            Player* sp = session->GetPlayer();
                            uint32 og = 0, oo = 0;
                            ZeroCraftHome::Resolve(sgo->GetSpawnId(), og, oo, sp);
                            if (!og || og != sp->GetGuildId())
                            {
                                if (op == CMSG_GUILD_BANKER_ACTIVATE)
                                    ZeroCraftDeploy::RedError(sp, og ? "This Summoning Stone belongs to " + ZeroCraftHome::OwnerName(og) + ". Break it to plunder their bank."
                                                                     : "Join a guild to use a Summoning Stone's bank.");
                                return false;
                            }
                            ZeroCraftHome::lastStone[sp->GetGUID().GetCounter()] = sgo->GetGUID();
                            if (op == CMSG_GUILD_BANKER_ACTIVATE)
                                if (Guild* g = sGuildMgr->GetGuildById(og))
                                    if (ZcGuildPeek::Tabs(g).empty())
                                    {
                                        sp->ModifyMoney(100 * GOLD);
                                        g->HandleBuyBankTab(session, 0);
                                        if (ZcGuildPeek::Tabs(g).empty())
                                            sp->ModifyMoney(-int32(100 * GOLD));
                                    }
                            return true;
                        }
            auto itr = ZeroCraftVault::vaultGuild.find(vault);
            if (itr != ZeroCraftVault::vaultGuild.end() && itr->second != session->GetPlayer()->GetGuildId())
            {
                if (op == CMSG_GUILD_BANKER_ACTIVATE)
                    ZeroCraftDeploy::RedError(session->GetPlayer(), "This vault belongs to another guild. Kill their Banker to loot it.");
                return false;
            }
            // the first bank tab comes free: opening your vault with no tabs buys tab 1 on the house
            if (op == CMSG_GUILD_BANKER_ACTIVATE && itr != ZeroCraftVault::vaultGuild.end())
                if (Guild* g = sGuildMgr->GetGuildById(itr->second))
                    if (ZcGuildPeek::Tabs(g).empty())
                    {
                        Player* p = session->GetPlayer();
                        p->ModifyMoney(100 * GOLD);
                        g->HandleBuyBankTab(session, 0);
                        if (ZcGuildPeek::Tabs(g).empty())
                            p->ModifyMoney(-int32(100 * GOLD)); // didn't go through: take the gift back
                    }
            return true;
        }
        uint32 dest = 0;
        if (op == CMSG_ACTIVATETAXIEXPRESS && packet.size() >= 12)
        {
            uint32 count = packet.read<uint32>(8);
            if (count && packet.size() >= 12 + count * 4)
                dest = packet.read<uint32>(12 + (count - 1) * 4);
        }
        else if (op == CMSG_ACTIVATETAXI && packet.size() >= 16)
            dest = packet.read<uint32>(12);
        else
            return true;
        if (dest && !ZeroCraftTaxi::CanFlyTo(session->GetPlayer(), dest))
        {
            ZeroCraftDeploy::RedError(session->GetPlayer(), "Your guild has no Flight Master there.");
            return false;
        }
        return true;
    }
};

void Addmod_instant_60_bisScripts()
{
    new ModInstant60BisPlayerScript();
    new ZeroCraftQoLPlayer();
    new ZeroCraftQoLServer();
    new ZeroCraftDeployItem();
    RegisterSpellScript(spell_zerocraft_deploy_conjure);
    new ZeroCraftDeployCreatures();
    new ZeroCraftDeployWorld();
    new ZeroCraftDeployPlayer();
    new ZeroCraftDeployGuild();
    new ZeroCraftDeployDeath();
    new ZeroCraftDeployDefend();
    new ZeroCraftDeployReaction();
    new ZeroCraftDeployView();
    new ZeroCraftClearChars();
    new ZeroCraftSquishLevels();
    new ZeroCraftSquishDamage();
    new ZeroCraftVillainAI();
    new ZeroCraftTaxiPlayer();
    new ZeroCraftTaxiCreatures();
    new ZeroCraftTaxiPackets();
    new ZeroCraftCommandBanner("item_zerocraft_command", false);
    new ZeroCraftCommandBanner("item_zerocraft_command_all", true);
    new ZeroCraftCommandGiver();
    new ZeroCraftAmmo();
    new ZeroCraftLFG();
    new ZeroCraftBordersPlayer();
    new ZeroCraftCharterItem();
    new ZeroCraftCharterGiver();
    new ZeroCraftNoDeathKnights();
    new ZeroCraftUpkeepWorld();
    new ZeroCraftUpkeepLogin();
    new ZeroCraftBankerGossip();
    new ZeroCraftNoStartAchievements();
    new ZeroCraftAdoptGuild();
    new ZeroCraftAdoptLogin();
    new ZeroCraftRecallItem();
    new ZeroCraftRecallGiver();
    new npc_zerocraft_vault_marker();
    new npc_zerocraft_profession();
    new npc_zerocraft_enchanter();
    new ZeroCraftTalentChat();
    new ZeroCraftBuilderKit();
    new ZeroCraftBuilderGiver();
    new ZeroCraftCatalogItem();
    new ZeroCraftCatalogGiver();
    new ZeroCraftBScrollItem();
    new ZeroCraftNpcItem();
    new ZeroCraftDestructorRod();
    new ZeroCraftNBookItem();
    new ZeroCraftWarWorld();
    new ZeroCraftTitanGripItem();
    new ZeroCraftTitanGripPlayer();
    new ZeroCraftBeastmasterWorld();
    new ZeroCraftFurnitureItem();
    new ZeroCraftHomeObjects();
    new ZeroCraftPlaceRod();
    new ZeroCraftDeathDrop();
    new ZeroCraftClaimSafe();
    new ZeroCraftStoneQuery();
    new ZeroCraftNpcEditScript();
    new ZeroCraftDummyItem();
    new ZeroCraftHeraldItem();
    new ZeroCraftHeraldView();
    new ZeroCraftHeraldPackets();
    new ZeroCraftWarLogin();
    new ZeroCraftEntertainerAI();
}
