
csvlabelimage =
{
    npc_harvestenable = {image ="sp1/flagharvestenable"},
    npc_harvestdisable = {image ="sp1/flagharvestdisable"},
    npc_bind = {image = "sp1/flagnpcmodbind"},
    npc_mail = {image = "sp1/flagnpcmodmail"},
    npc_shop = {image = "sp1/flagnpcmodshop"},
    npc_business = {image = "sp1/flagnpcmodbusiness"},
    npc_storage = {image = "sp1/flagnpcmodstorage"},
    npc_transfer = {image = "sp1/flagnpcmodtransfer"},
    npc_souvenir = {image = "sp1/flagnpcmodsouvenir"},

    npc_dungeon = {image = "sp1/flagstddungeon"},

    abyss_carrier = {image = "sp1/flagabysscarrier"},
    abyss_castle = {image = "sp1/flagabysscastle"},
    abyss_castlebattle = {image = "sp1/flagabysscastlebattle"},
    abyss_artifact = {image = "sp1/flagabyssartifact"},
    abyss_civgate = {image = "sp1/flagabysscivgate"},

    quest_mainquesting = {image = "sp1/flagnpcmainquesting"},
    quest_mainquestcomplete = {image = "sp1/flagnpcmainquestcomplete"},
    quest_stdqueststart = {image = "sp1/flagnpcstdqueststart"},
    quest_stdquesting = {image = "sp1/flagnpcstdquesting"},
    quest_stdquestcomplete = {image = "sp1/flagnpcstdquestcomplete"},
    quest_guidequeststart = {image = "sp1/flagnpcguidequeststart"},
    quest_guidequesting = {image = "sp1/flagnpcguidequesting"},
    quest_guidequestcomplete = {image = "sp1/flagnpcguidequestcomplete"},
    quest_festqueststart = {image = "sp1/flagnpcfestqueststart"},
    quest_festquesting = {image = "sp1/flagnpcfestquesting"},
    quest_festquestcomplete = {image = "sp1/flagnpcfestquestcomplete"},

    map_teamdead = {image = "sp1/flagteamdead"},
    map_actoricon = {image = "sp1/flagactoricon"},
    map_team = {image = "sp1/flagstdteam"},
    map_raid = {image = "sp1/flagstdraid"},

    hint_system = {image = "sp1/flaghintsystem"},
    hint_player = {image = "sp1/flaghintplayer"},
}

function csvlabelimage_load()
    for key, val in pairs(csvlabelimage) do
		val.width, val.height = c_uigetspritesize(unity_spritepath(val.image))
	end
end
