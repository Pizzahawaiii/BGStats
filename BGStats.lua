local BGStats = CreateFrame('FRAME', "BGStats", UIParent);

BGStats:RegisterEvent('ADDON_LOADED');
BGStats:RegisterEvent('CHAT_MSG_BG_SYSTEM_NEUTRAL');
BGStats:RegisterEvent('PLAYER_PVP_KILLS_CHANGED');

SLASH_BGSTATS1, SLASH_BGSTATS2 = '/bgstats', '/bgs';

local Maps = {
    ALL = 'Overall',
    WSG = 'Warsong Gulch',
    AB  = 'Arathi Basin',
    AV  = 'Alterac Valley',
};

BGStats_Stats = {
    [Maps.ALL] = {
        games = 0,
        wins = 0,
        kills = 0,
        deaths = 0,
        offCaps = 0,
        defCaps = 0,
    },
    [Maps.WSG] = {
        games = 0,
        wins = 0,
        kills = 0,
        deaths = 0,
        offCaps = 0,
        defCaps = 0,
    },
    [Maps.AB] = {
        games = 0,
        wins = 0,
        kills = 0,
        deaths = 0,
        offCaps = 0,
        defCaps = 0,
    },
    [Maps.AV] = {
        games = 0,
        wins = 0,
        kills = 0,
        deaths = 0,
        offCaps = 0,
        defCaps = 0,
    },
};

function BGStats_Print(arg1)
	DEFAULT_CHAT_FRAME:AddMessage(arg1 or "")
end

function IsBGName(str)
    return str == Maps.WSG or str == Maps.AB or str == Maps.AV;
end

function IsBG(str)
    return str == 'WSG' or str == 'AB' or str == 'AV';
end

function IsMap(str)
    return IsBG(str) or str == 'ALL';
end

function GetWinRate(stats)
    if (stats.games == 0) then return 0; end
    return math.floor((stats.wins / stats.games) * 1000) / 10;
end

function GetKillsPerGame(stats)
    if (stats.games == 0) then return 0; end
    return math.floor(stats.kills / stats.games * 100) / 100;
end

function GetKD(stats)
    if (stats.deaths == 0) then 
        if (stats.kills == 0) then return 0; end
        return 1337; 
    end
    return math.floor(stats.kills / stats.deaths * 100) / 100;
end

function GetDeathsPerGame(stats)
    if (stats.games == 0) then return 0; end
    return math.floor(stats.deaths / stats.games * 100) / 100;
end

function GetOffCapsPerGame(stats)
    if (stats.games == 0) then return 0; end
    return math.floor(stats.offCaps / stats.games * 100) / 100;
end

function GetDefCapsPerGame(stats)
    if (stats.games == 0) then return 0; end
    return math.floor(stats.defCaps / stats.games * 100) / 100;
end

function GetOffCapsPerDeath(stats)
    if (stats.deaths == 0) then
        if (stats.offCaps == 0) then return 0; end
        return 1337;
    end
    return math.floor(stats.offCaps / stats.deaths * 100) / 100;
end

function GetDefCapsPerDeath(stats)
    if (stats.deaths == 0) then
        if (stats.defCaps == 0) then return 0; end
        return 1337;
    end
    return math.floor(stats.defCaps / stats.deaths * 100) / 100;
end

function PrintMapStats(map)
    local stats = BGStats_Stats[map];

	BGStats_Print('|cffff6060BGStats|r ' .. map .. ' |cffAAAAAA(' .. UnitName('player') .. ')|r');
    BGStats_Print('|cff00e0ffGames:|r |cff60ff60' .. stats.games .. '|r');
    BGStats_Print('|cff00e0ffWins:|r |cff60ff60' .. stats.wins .. '|r |cffAAAAAA~|r |cff60ff60' .. GetWinRate(stats) .. '|r%');
    BGStats_Print('|cff00e0ffKills:|r |cff60ff60' .. stats.kills .. '|r total |cffAAAAAA~|r |cff60ff60' .. GetKillsPerGame(stats) .. '|r per game |cffAAAAAA~|r |cff60ff60' .. GetKD(stats) .. '|r per death');
    BGStats_Print('|cff00e0ffDeaths:|r |cff60ff60' .. stats.deaths .. '|r total |cffAAAAAA~|r |cff60ff60' .. GetDeathsPerGame(stats) .. '|r per game');
    BGStats_Print('|cff00e0ffCaps (O):|r |cff60ff60' .. stats.offCaps .. '|r total |cffAAAAAA~|r |cff60ff60' .. GetOffCapsPerGame(stats) .. '|r per game |cffAAAAAA~|r |cff60ff60' .. GetOffCapsPerDeath(stats) .. '|r per death');
    BGStats_Print('|cff00e0ffCaps (D):|r |cff60ff60' .. stats.defCaps .. '|r total |cffAAAAAA~|r |cff60ff60' .. GetDefCapsPerGame(stats) .. '|r per game |cffAAAAAA~|r |cff60ff60' .. GetDefCapsPerDeath(stats) .. '|r per death');
end

function PrintHelp()
	BGStats_Print('|cffff6060BGStats|r Commands');
    BGStats_Print('|cff00e0ff/bgs all|r')
    BGStats_Print('|cff00e0ff/bgs wsg|r')
    BGStats_Print('|cff00e0ff/bgs ab|r')
    BGStats_Print('|cff00e0ff/bgs av|r')
end

function SlashCmdList.BGSTATS(msg)
    local arg = string.upper(msg);
    if (IsMap(arg)) then
        PrintMapStats(Maps[arg]);
        return;
    end

    PrintHelp();
end

function BGStats:OnEvent()
    if (event == 'ADDON_LOADED' and arg1 == 'BGStats') then
        BGStats_Print('|cffff6060BGStats|r |cffAAAAAAby Pizzahawaii|r loaded! Use |cff00e0ff/bgstats|r or |cff00e0ff/bgs|r to check your BG stats.');
    elseif (event == 'CHAT_MSG_BG_SYSTEM_NEUTRAL') then
        if (arg1 == 'The Horde wins!' or arg1 == 'The Alliance wins!') then
            local i;
            for i = 1, MAX_BATTLEFIELD_QUEUES, 1 do
                local status, map, instanceID = GetBattlefieldStatus(i);

                if (status == 'active' and IsBGName(map)) then
                    BGStats_Stats[map].games = BGStats_Stats[map].games + 1;
                    BGStats_Stats[Maps.ALL].games = BGStats_Stats[Maps.ALL].games + 1;

                    if (arg1 == 'The ' .. UnitFactionGroup("player") .. ' wins!') then
                        BGStats_Stats[map].wins = BGStats_Stats[map].wins + 1;
                        BGStats_Stats[Maps.ALL].wins = BGStats_Stats[Maps.ALL].wins + 1;
                    end

                    local players = GetNumBattlefieldScores();
                    for i = 1, players, 1 do
                        name, killingBlows, _, deaths = GetBattlefieldScore(i);
                        if (name == UnitName('player')) then
                            BGStats_Stats[map].kills = BGStats_Stats[map].kills + killingBlows;
                            BGStats_Stats[Maps.ALL].kills = BGStats_Stats[Maps.ALL].kills + killingBlows;

                            BGStats_Stats[map].deaths = BGStats_Stats[map].deaths + deaths;
                            BGStats_Stats[Maps.ALL].deaths = BGStats_Stats[Maps.ALL].deaths + deaths;

                            local offCaps = GetBattlefieldStatData(i, 1);
                            BGStats_Stats[map].offCaps = BGStats_Stats[map].offCaps + offCaps;
                            BGStats_Stats[Maps.ALL].offCaps = BGStats_Stats[Maps.ALL].offCaps + offCaps;

                            local defCaps = GetBattlefieldStatData(i, 2);
                            BGStats_Stats[map].defCaps = BGStats_Stats[map].defCaps + defCaps;
                            BGStats_Stats[Maps.ALL].defCaps = BGStats_Stats[Maps.ALL].defCaps + defCaps;
                        end
                    end

                    BGStats_Print('|cff00e0ff' .. map .. ':|r |cff60ff60' .. GetWinRate(BGStats_Stats[map]) .. '|r% win rate');
                end
            end
        end
    end
end
BGStats:SetScript("OnEvent", BGStats.OnEvent);
