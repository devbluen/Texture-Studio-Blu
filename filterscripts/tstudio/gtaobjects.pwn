#include "tstudio\allobjects.pwn"

#define         MIN_GTAOBJECT_LABEL_DIST            5.0

static bool:ObjectsShown;
static Text3D:GTAObjectText[SEARCH_DATA_SIZE];
static bool:GTAObjectDeleted[SEARCH_DATA_SIZE];
static bool:GTAObjectSwapped[SEARCH_DATA_SIZE];
static HighLightObject[MAX_PLAYERS] = -1;

public OnPlayerDisconnect(playerid, reason)
{
	if(HighLightObject[playerid] > -1)
	{
		DestroyDynamicObject(HighLightObject[playerid]);
        HighLightObject[playerid] = -1;
	}

	#if defined GO_OnPlayerDisconnect
		GO_OnPlayerDisconnect(playerid, reason);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect GO_OnPlayerDisconnect
#if defined GO_OnPlayerDisconnect
	forward GO_OnPlayerDisconnect(playerid, reason);
#endif


ResetGTADeletedObjects()
{
	for(new i = 0; i < SEARCH_DATA_SIZE; i++) GTAObjectDeleted[i] = false;
	for(new i = 0; i < SEARCH_DATA_SIZE; i++) GTAObjectSwapped[i] = false;
	return 1;
}

YCMD:gtaobjects(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Exiba informações sobre todos os edifícios de San Andreas.");
		return 1;
	}

	new Float:colradius;
	sscanf(arg, "F(0)", colradius);
	
	if(ObjectsShown && !colradius)
	{
		for(new i = 0; i < SEARCH_DATA_SIZE; i++) DestroyDynamic3DTextLabel(GTAObjectText[i]);
        ObjectsShown = false;
		SendClientMessage(playerid, STEALTH_GREEN, "Escondendo objetos GTA");
	}
	else
	{
		if(ObjectsShown)
			for(new i = 0; i < SEARCH_DATA_SIZE; i++) DestroyDynamic3DTextLabel(GTAObjectText[i]);

		new index, model;
		AO_RESULT = db_query(AO_DB, "SELECT * FROM `buildings`");
		do
		{
			index = db_get_field_int(AO_RESULT, 0);
			model = db_get_field_int(AO_RESULT, 1);
			//db_get_field(AO_RESULT, 3, name, sizeof name[]);
			
 			if(!colradius)
			{
				colradius = GetColSphereRadius(model);
				if(colradius < MIN_GTAOBJECT_LABEL_DIST) colradius = MIN_GTAOBJECT_LABEL_DIST;
				colradius *= 2;
			}
		
            GTAObjectText[index] = CreateDynamic3DTextLabel(
				sprintf("Index: %i\nName: %s\nModelID: %i", index, GetModelName(model), model), 
				(GTAObjectDeleted[index] ? (GTAObjectSwapped[index] ? 0x5A34FFFF : 0xFF345AFF) : 0xFF69B4FF), 
				db_get_field_float(AO_RESULT, 4), db_get_field_float(AO_RESULT, 5), db_get_field_float(AO_RESULT, 6) + db_get_field_float(AO_RESULT, 10), colradius * 2.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, colradius
			);
		}
		while(db_next_row(AO_RESULT));
		
	    ObjectsShown = true;
	    SendClientMessage(playerid, STEALTH_GREEN, "Mostrando objetos GTA");
	}

	return 1;
}

/*YCMD:gtaobjects(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Display information on all San Andreas buildings.");
		return 1;
	}

	if(ObjectsShown)
	{
		for(new i = 0; i < SEARCH_DATA_SIZE; i++) DestroyDynamic3DTextLabel(GTAObjectText[i]);
        ObjectsShown = false;
		SendClientMessage(playerid, STEALTH_GREEN, "Hiding GTA Objects");
	}
	else
	{
		new text[64], Float:colradius;
		
	    for(new i = 0; i < SEARCH_DATA_SIZE; i++)
		{
 			colradius = GetColSphereRadius(SearchData[i][Search_Model]);
 			if(colradius < MIN_GTAOBJECT_LABEL_DIST) colradius = MIN_GTAOBJECT_LABEL_DIST;
		    format(text, sizeof(text), "Index: %i\nName: %s\nModelID: %i", i, SearchData[i][Search_Model_Name], SearchData[i][Search_Model]);
            GTAObjectText[i] = CreateDynamic3DTextLabel(text, 0xFF69B4FF, SearchData[i][SearchX], SearchData[i][SearchY], SearchData[i][SearchZ]+SearchData[i][SearchOffset], colradius*2.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, colradius*2.0);
		}
	    ObjectsShown = true;
	    SendClientMessage(playerid, STEALTH_GREEN, "Showing GTA Objects");
	}

	return 1;
}*/

YCMD:gtashow(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "\"Destacar\"um edifício de San Andreas.");
		return 1;
	}

	if(isnull(arg)) return SendClientMessage(playerid, STEALTH_YELLOW, "YVocê deve fornecer um índice para destacar!");
	new line[128], index = strval(arg);

	if(index < 0 || index >= SEARCH_DATA_SIZE)
	{
		format(line, sizeof(line), "O índice deve estar entre 0 e %i", SEARCH_DATA_SIZE-1);
	    return SendClientMessage(playerid, STEALTH_YELLOW, line);
	}

	if(HighLightObject[playerid] > -1) DestroyDynamicObject(HighLightObject[playerid]);

    HighLightObject[playerid] = CreateDynamicObject(db_get_field_int(AO_RESULT, 1),
		db_get_field_float(AO_RESULT, 4), db_get_field_float(AO_RESULT, 5), db_get_field_float(AO_RESULT, 6) + 1.0,
		db_get_field_float(AO_RESULT, 7), db_get_field_float(AO_RESULT, 8), db_get_field_float(AO_RESULT, 9),
		-1, -1, playerid
	);
	
	for(new i = 0; i < 16; i++) SetDynamicObjectMaterial(HighLightObject[playerid], i, -1, "none", "none", 0xFFFF0000);

	return 1;
}

YCMD:gtahide(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Oculte um edifício \"destacado\" de San Andreas.");
		return 1;
	}

	if(HighLightObject[playerid] > -1)
	{
		DestroyDynamicObject(HighLightObject[playerid]);
        HighLightObject[playerid] = -1;
	}

	return 1;
}

YCMD:remobject(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Destrua um edifício de San Andreas. (CUIDADO: Permanente!)");
		return 1;
	}

    MapOpenCheck();
	
	new index;
	if(sscanf(arg, "i", index)) return SendClientMessage(playerid, STEALTH_YELLOW, "Você deve fornecer um índice para excluir!");

	new line[128];

	if(index < 0 || index >= SEARCH_DATA_SIZE)
	{
		format(line, sizeof(line), "O índice deve estar entre 0 e %i", SEARCH_DATA_SIZE-1);
	    return SendClientMessage(playerid, STEALTH_YELLOW, line);
	}

	if(GTAObjectDeleted[index] == true) return SendClientMessage(playerid, STEALTH_YELLOW, "Esse objeto já foi excluído!");

    GTAObjectDeleted[index] = true;
	
	AO_RESULT = db_query(AO_DB, sprintf("SELECT * FROM `buildings` WHERE `ID` = %i", index));
	//db_get_field(AO_RESULT, 3, name, sizeof name[]);
	
	AddRemoveBuilding(db_get_field_int(AO_RESULT, 1), db_get_field_float(AO_RESULT, 4), db_get_field_float(AO_RESULT, 5), db_get_field_float(AO_RESULT, 6), 0.25, true);
	if(db_get_field_int(AO_RESULT, 2) != INVALID_OBJECT_ID)
		AddRemoveBuilding(db_get_field_int(AO_RESULT, 2), db_get_field_float(AO_RESULT, 4), db_get_field_float(AO_RESULT, 5), db_get_field_float(AO_RESULT, 6), 0.25, true);

	UpdateDynamic3DTextLabelText(GTAObjectText[index],
		(GTAObjectDeleted[index] ? (GTAObjectSwapped[index] ? 0x5A34FFFF : 0xF51414FF) : 0xFF69B4FF),
		sprintf("Índice: %i\nNome: %s\nModelID: %i", index, GetModelName(db_get_field_int(AO_RESULT, 1)), db_get_field_int(AO_RESULT, 1)));

	SendClientMessage(playerid, STEALTH_YELLOW, "Objeto foi removido!");
	
	return 1;
}

YCMD:rremobject(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Destrua todos os edifícios de San Andreas do modelo especificado em um raio específico de sua localização. (CUIDADO: Permanente!)");
		return 1;
	}

    MapOpenCheck();
	
	new model, Float:range;
	if(sscanf(arg, "if", model, range))
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Uso: /rremobject <Modelo> <Intervalo>");
		return 1;
	}

	if(model < 0 || model >= 19999)
	{
	    SendClientMessage(playerid, STEALTH_YELLOW, "O modelo deve estar entre 0 e 19999");
		return 1;
	}
	
	new index, name[50], count, Float:x, Float:y, Float:z;
	strcat(name, GetModelName(model));
	
	if(IsFlyMode(playerid))
		GetFlyModePos(playerid, x, y, z);
	else
		GetPlayerPos(playerid, x, y, z);
	
	AO_RESULT = db_query(AO_DB, sprintf("SELECT * FROM `buildings` WHERE `Model` = %i", model));
	db_begin_transaction(AO_DB);
	do
	{
		index = db_get_field_int(AO_RESULT, 0);
		
		if(GTAObjectDeleted[index] == true) continue;

		new Float:dbx = db_get_field_float(AO_RESULT, 4), Float:dby = db_get_field_float(AO_RESULT, 5), Float:dbz = db_get_field_float(AO_RESULT, 6);
		new Float:dist = VectorSize(dbx - x, dby - y, dbz - z);
		
		if(dist < range)
		{
			GTAObjectDeleted[index] = true;
			
			//db_get_field(AO_RESULT, 3, name, sizeof name[]);
			
			AddRemoveBuilding(model, dbx, dby, dbz, 0.25, true);
			if(db_get_field_int(AO_RESULT, 2) != INVALID_OBJECT_ID)
				AddRemoveBuilding(db_get_field_int(AO_RESULT, 2), dbx, dby, dbz, 0.25, true);

			UpdateDynamic3DTextLabelText(GTAObjectText[index],
				(GTAObjectDeleted[index] ? (GTAObjectSwapped[index] ? 0x5A34FFFF : 0xF51414FF) : 0xFF69B4FF),
				sprintf("Índice: %i\nNome: %s\nModelID: %i", index, name, model));
			
			count++;
		}
	}
	while(db_next_row(AO_RESULT));
	db_end_transaction(AO_DB);

	SendClientMessage(playerid, STEALTH_YELLOW, sprintf("%i objetos foram removidos!", count));
	
	return 1;
}

YCMD:swapbuilding(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Destrói um edifício de San Andreas e cria um objeto de mapa em seu lugar.");
		return 1;
	}

    MapOpenCheck();


	if(isnull(arg)) return SendClientMessage(playerid, STEALTH_YELLOW, "Você deve fornecer um índice para trocar!");
	new line[128], index = strval(arg);

	if(index < 0 || index >= SEARCH_DATA_SIZE)
	{
		format(line, sizeof(line), "O índice deve estar entre 0 e %i", SEARCH_DATA_SIZE-1);
	    return SendClientMessage(playerid, STEALTH_YELLOW, line);
	}

	if(GTAObjectSwapped[index] == true) return SendClientMessage(playerid, STEALTH_YELLOW, "Esse objeto já foi trocado!");

	AO_RESULT = db_query(AO_DB, sprintf("SELECT * FROM `buildings` WHERE `ID` = %i", index));
	//db_get_field(AO_RESULT, 3, name, sizeof name[]);
	
	new model = db_get_field_int(AO_RESULT, 1);
	if(GTAObjectDeleted[index] == false)
	{
		AddRemoveBuilding(model, db_get_field_float(AO_RESULT, 4), db_get_field_float(AO_RESULT, 5), db_get_field_float(AO_RESULT, 6), 0.25, true);
		if(db_get_field_int(AO_RESULT, 2) != INVALID_OBJECT_ID)
			AddRemoveBuilding(db_get_field_int(AO_RESULT, 2), db_get_field_float(AO_RESULT, 4), db_get_field_float(AO_RESULT, 5), db_get_field_float(AO_RESULT, 6), 0.25, true);
	    
		GTAObjectDeleted[index] = true;
	}

	// Swap object
	UpdateObject3DText(AddDynamicObject(model, db_get_field_float(AO_RESULT, 4), db_get_field_float(AO_RESULT, 5), db_get_field_float(AO_RESULT, 6), db_get_field_float(AO_RESULT, 7), db_get_field_float(AO_RESULT, 8), db_get_field_float(AO_RESULT, 9)), true);
    GTAObjectSwapped[index] = true;

	UpdateDynamic3DTextLabelText(GTAObjectText[index],
		(GTAObjectDeleted[index] ? (GTAObjectSwapped[index] ? 0x5A34FFFF : 0xFF345AFF) : 0xFF69B4FF),
		sprintf("Índice: %i\nNome: %s\nModelID: %i", index, GetModelName(model), model));
	
	SendClientMessage(playerid, STEALTH_YELLOW, "O objeto foi trocado!");
	return 1;
}

YCMD:clonebuilding(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Clona um prédio de San Andreas em seu lugar.");
		return 1;
	}

    MapOpenCheck();

	EditCheck(playerid);

	NoEditingMode(playerid);

	if(isnull(arg)) return SendClientMessage(playerid, STEALTH_YELLOW, "Você deve fornecer um índice para clonar!");
	new line[128], index = strval(arg);

	if(index < 0 || index >= SEARCH_DATA_SIZE)
	{
		format(line, sizeof(line), "O índice deve estar entre 0 e %i", SEARCH_DATA_SIZE-1);
	    return SendClientMessage(playerid, STEALTH_YELLOW, line);
	}
	
	AO_RESULT = db_query(AO_DB, sprintf("SELECT * FROM `buildings` WHERE `ID` = %i", index));

	SetCurrObject(playerid, AddDynamicObject(db_get_field_int(AO_RESULT, 1), db_get_field_float(AO_RESULT, 4), db_get_field_float(AO_RESULT, 5), db_get_field_float(AO_RESULT, 6), db_get_field_float(AO_RESULT, 7), db_get_field_float(AO_RESULT, 8), db_get_field_float(AO_RESULT, 9)));

	UpdateObject3DText(CurrObject[playerid], true);
	
	SaveUndoInfo(CurrObject[playerid], UNDO_TYPE_CREATED);
	
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	SendClientMessage(playerid, STEALTH_GREEN, "Clonou seu objeto selecionado, o novo objeto agora é sua seleção");

	return 1;
}

