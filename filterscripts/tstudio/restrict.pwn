public OnFilterScriptInit()
{
	Iter_Init(Restriction);
    
	#if defined RS_OnFilterScriptInit
		RS_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit RS_OnFilterScriptInit
#if defined RS_OnFilterScriptInit
	forward RS_OnFilterScriptInit();
#endif

public OnPlayerDisconnect(playerid, reason)
{
	for(new g; g < 51; g++)
        Iter_Remove(Restriction[g], playerid);
    
	#if defined RS_OnPlayerDisconnect
		RS_OnPlayerDisconnect(playerid, reason);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect RS_OnPlayerDisconnect
#if defined RS_OnPlayerDisconnect
	forward RS_OnPlayerDisconnect(playerid, reason);
#endif

YCMD:restrict(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "[SOMENTE RCON] Impedir que um grupo de objetos seja editado.");
		return 1;
	}
    
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, STEALTH_YELLOW, "Somente administradores RCON podem usar este comando");
    
    new groupid, players[10];
    if(sscanf(arg, "iA<i>(-1)[10]", groupid, players))
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "/restrict <ID do grupo> <Opcional: jogadores, até 10>");
		SendClientMessage(playerid, STEALTH_GREEN, "Se nenhum jogador estiver listado, somente VOCÊ poderá editar este grupo");
		return 1;
	}
    
    if(!(0 < groupid <= 50))
        return SendClientMessage(playerid, STEALTH_YELLOW, "Você só pode restringir os grupos de 1 a 50");
    
    Iter_Clear(Restriction[groupid]);
    
    for(new i; i < 10; i++)
    {
        if(players[i] != -1)
            Iter_Add(Restriction[groupid], players[i]);
        else
            break;
    }
    
    gRestricted[groupid] = true;
    
    foreach(new p: Player)
    {
        new bool:cont;
        for(new i; i < 10; i++)
        {
            if(players[i] == p)
            {
                cont = true;
                break;
            }
        }
        if(cont || IsPlayerAdmin(p))
            continue;
        
        if(ObjectData[CurrObject[p]][oGroup] == groupid)
        {
            CurrObject[p] = -1;
            SendClientMessage(p, STEALTH_YELLOW, "Seu objeto selecionado foi desmarcado devido a uma restrição");
        }
        
        new count;
        foreach(new i : Objects)
        {
            if(GroupedObjects[p][i] && ObjectData[i][oGroup] == groupid)
            {
                GroupedObjects[p][i] = false;
                OnUpdateGroup3DText(i);
                UpdateObject3DText(i);
                count++;
            }
        }
        if(count)
        {
            UpdatePlayerGSelText(p);
            SendClientMessage(p, STEALTH_YELLOW, sprintf("%i dos seus objetos agrupados foram desmarcados devido a uma restrição", count));
        }
    }
    
    SendClientMessage(playerid, STEALTH_GREEN, "Você restringiu este grupo");
    return 1;
}

YCMD:unrestrict(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "[RCON SOMENTE] Permitir que todos os jogadores editem um grupo.");
		return 1;
	}
    
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, STEALTH_YELLOW, "Somente administradores RCON podem usar este comando");
    
    new groupid;
    if(sscanf(arg, "i", groupid))
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Você deve fornecer um ID de grupo");
		return 1;
	}
    
    if(!(0 < groupid <= 50))
        return SendClientMessage(playerid, STEALTH_YELLOW, "Você só pode restringir os grupos de 1 a 50");
    
    Iter_Clear(Restriction[groupid]);
    gRestricted[groupid] = false;
    
    SendClientMessage(playerid, STEALTH_GREEN, "Você irrestritou este grupo");
    return 1;
}
