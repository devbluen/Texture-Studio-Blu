
// Group objects
new Text3D:GroupObjectText[MAX_PLAYERS][MAX_TEXTURE_OBJECTS];
new bool:GroupedObjects[MAX_PLAYERS][MAX_TEXTURE_OBJECTS];
new Float:PivotOffset[MAX_PLAYERS][XYZ];
new Float:LastPivot[MAX_PLAYERS][XYZR];
new Float:LastGroupPosition[MAX_PLAYERS][XYZ];
new bool:PivotReset[MAX_PLAYERS];

public OnFilterScriptInit()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		for(new j = 0; j < MAX_TEXTURE_OBJECTS; j++)
		{
	        GroupObjectText[i][j] = Text3D:-1;
	    }
	}

	#if defined GR_OnFilterScriptInit
		GR_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit GR_OnFilterScriptInit
#if defined GR_OnFilterScriptInit
	forward GR_OnFilterScriptInit();
#endif


public OnPlayerDisconnect(playerid, reason)
{
	for(new i = 0; i < MAX_TEXTURE_OBJECTS; i++)
	{
		if(_:GroupObjectText[playerid][i])
		{
			DestroyDynamic3DTextLabel(GroupObjectText[playerid][i]);
	        GroupObjectText[playerid][i] = Text3D:-1;
		}
    }
	ClearGroup(playerid);

	#if defined GR_OnPlayerDisconnect
		GR_OnPlayerDisconnect(playerid, reason);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect GR_OnPlayerDisconnect
#if defined GR_OnPlayerDisconnect
	forward GR_OnPlayerDisconnect(playerid, reason);
#endif

HideGroupLabels(playerid)
{
	for(new i = 0; i < MAX_TEXTURE_OBJECTS; i++)
	{
		if(_:GroupObjectText[playerid][i])
		{
            UpdateDynamic3DTextLabelText(GroupObjectText[playerid][i], 0, "");
		}
    }
}

ShowGroupLabels(playerid)
{
	for(new i = 0; i < MAX_TEXTURE_OBJECTS; i++)
	{
		if(_:GroupObjectText[playerid][i])
		{
            UpdateDynamic3DTextLabelText(GroupObjectText[playerid][i], 0x7D26CDFF, "Grouped");
		}
    }
}




public OnUpdateGroup3DText(index)
{
	foreach(new i : Player)
	{
		if(_:GroupObjectText[i][index] != -1)
		{
			DestroyDynamic3DTextLabel(GroupObjectText[i][index]);
			GroupObjectText[i][index] = Text3D:-1;
		}

        if(TextOption[tShowText] && TextOption[tShowGrouped] && GroupedObjects[i][index])
        {
			// 3D Text Label (To identify objects)
			new line[32];
			format(line, sizeof(line), "Grouped");

			// Shows the models index
		    GroupObjectText[i][index] = CreateDynamic3DTextLabel(line, 0x7D26CDFF, ObjectData[index][oX], ObjectData[index][oY], ObjectData[index][oZ]+0.5, TEXT3D_DRAW_DIST, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0,  -1, -1, i);

			Streamer_Update(i);
        }
	}
	return 1;
}

public OnDeleteGroup3DText(index)
{
	foreach(new i : Player)
	{
        if(GroupedObjects[i][index])
        {
			DestroyDynamic3DTextLabel(GroupObjectText[i][index]);
			GroupObjectText[i][index] = Text3D:-1;
		}
	}
	return 1;
}


public OnPlayerSelectDynamicObject(playerid, objectid, modelid, Float:x, Float:y, Float:z)
{
	if(GetEditMode(playerid) == EDIT_MODE_GROUP)
	{
	    new Keys,ud,lr,index;
	    GetPlayerKeys(playerid,Keys,ud,lr);

		// Find edit object
		foreach(new i : Objects)
		{
			// Object found
		    if(ObjectData[i][oID] == objectid)
			{
				index = i;
			    break;
			}
		}
        
        if(!CanSelectObject(playerid, index))
            SendClientMessage(playerid, STEALTH_YELLOW, "Você não pode selecionar objetos no grupo deste objeto");
        else
        {
            SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
            // Try and add to group
            if(Keys & KEY_CTRL_BACK || (InFlyMode(playerid) && (Keys & KEY_SECONDARY_ATTACK)))
            {
                if(GroupedObjects[playerid][index]) SendClientMessage(playerid, STEALTH_YELLOW, "O objeto já está na sua seleção de grupo");
                else
                {
                    SendClientMessage(playerid, STEALTH_GREEN, "Objeto adicionado à sua seleção de grupo");
                    GroupedObjects[playerid][index] = true;
                    OnUpdateGroup3DText(index);

                }
            }

            // Try and remove from group
            else if(Keys & KEY_WALK)
            {
                if(!GroupedObjects[playerid][index]) SendClientMessage(playerid, STEALTH_YELLOW, "O objeto não está na sua seleção de grupo");
                else
                {
                    SendClientMessage(playerid, STEALTH_GREEN, "O objeto não está na sua seleção de grupo");
                    GroupedObjects[playerid][index] = false;
                    OnUpdateGroup3DText(index);
                }
            }
            else
            {
                SendClientMessage(playerid, STEALTH_YELLOW, "Segure a tecla 'H' ('Enter' em /flymode) e clique em um objeto para selecioná-lo");
                SendClientMessage(playerid, STEALTH_YELLOW, "Segure a tecla 'Walk' e clique em um objeto para desmarcá-lo");

            }
        }
	}

	#if defined GR_OnPlayerSelectDynamicObject
		GR_OnPlayerSelectDynamicObject(playerid, objectid, modelid, Float:x, Float:y, Float:z);
	#endif
	return 1;
}
#if defined _ALS_OnPlayerSelectDynamicObj
	#undef OnPlayerSelectDynamicObject
#else
	#define _ALS_OnPlayerSelectDynamicObj
#endif
#define OnPlayerSelectDynamicObject GR_OnPlayerSelectDynamicObject
#if defined GR_OnPlayerSelectDynamicObject
	forward GR_OnPlayerSelectDynamicObject(playerid, objectid, modelid, Float:x, Float:y, Float:z);
#endif

OnPlayerKeyStateGroupChange(playerid, newkeys, oldkeys)
{
	#pragma unused newkeys
    if(GetEditMode(playerid) == EDIT_MODE_OBJECTGROUP)
    {
		if(oldkeys & KEY_WALK)
		{
			if(PivotReset[playerid] == false) return 1;
			SendClientMessage(playerid, STEALTH_GREEN, "O pivô foi definido");
			PivotReset[playerid] = false;
			return 1;
		}
    }
    return 0;
}

OnPlayerEditDOGroup(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	#pragma unused objectid
	if(response == EDIT_RESPONSE_FINAL)
	{
		// Get the center (never changes)
		new Float:gCenterX, Float:gCenterY, Float:gCenterZ;
		GetGroupCenter(playerid, gCenterX, gCenterY, gCenterZ);

		new time = GetTickCount();

		db_begin_transaction(EditMap);
		foreach(new i : Objects)
		{
	   		if(GroupedObjects[playerid][i])
			{
				SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

				new Float:offx, Float:offy, Float:offz;
				offx = (ObjectData[i][oX] + (LastGroupPosition[playerid][xPos] - gCenterX)) - PivotOffset[playerid][xPos];
				offy = (ObjectData[i][oY] + (LastGroupPosition[playerid][yPos] - gCenterY)) - PivotOffset[playerid][yPos];
				offz = (ObjectData[i][oZ] + (LastGroupPosition[playerid][zPos] - gCenterZ)) - PivotOffset[playerid][zPos];

                AttachObjectToPoint_GroupEdit(i, offx, offy, offz, x, y, z, rx, ry, rz, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
				SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
  				SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);

			    sqlite_UpdateObjectPos(i);

			    UpdateObject3DText(i);
			}
		}
		db_end_transaction(EditMap);

		EditingMode[playerid] = false;
		SetEditMode(playerid, EDIT_MODE_NONE);

		DestroyDynamicObject(PivotObject[playerid]);
	}
	else if(response == EDIT_RESPONSE_UPDATE)
	{

		// Get the center (never changes)
		new Float:gCenterX, Float:gCenterY, Float:gCenterZ;
		GetGroupCenter(playerid, gCenterX, gCenterY, gCenterZ);

	    new Keys,ud,lr;
	    GetPlayerKeys(playerid,Keys,ud,lr);

		if(Keys & KEY_WALK)
		{
			if(!PivotReset[playerid])
			{
		       	SetDynamicObjectPos(PivotObject[playerid], LastGroupPosition[playerid][xPos], LastGroupPosition[playerid][yPos], LastGroupPosition[playerid][zPos]);
				SendClientMessage(playerid, STEALTH_YELLOW, "Salve seu objeto antes de alterar o pivô novamente");
			}
			else
			{
				PivotOffset[playerid][xPos] = x - LastPivot[playerid][xPos];
				PivotOffset[playerid][yPos] = y - LastPivot[playerid][yPos];
				PivotOffset[playerid][zPos] = z - LastPivot[playerid][zPos];

				SetDynamicObjectRot(PivotObject[playerid], 0.0, 0.0, 0.0);
			}
		}

		else
		{
			foreach(new i : Objects)
			{
		   		if(GroupedObjects[playerid][i])
				{
					new Float:offx, Float:offy, Float:offz, Float:newx, Float:newy, Float:newz, Float:newrx, Float:newry, Float:newrz;
					offx = (ObjectData[i][oX] + (x - gCenterX)) - PivotOffset[playerid][xPos];
					offy = (ObjectData[i][oY] + (y - gCenterY)) - PivotOffset[playerid][yPos];
					offz = (ObjectData[i][oZ] + (z - gCenterZ)) - PivotOffset[playerid][zPos];

                    AttachObjectToPoint_GroupEdit(i, offx, offy, offz, x, y, z, rx, ry, rz, newx, newy, newz, newrx, newry, newrz);
					SetDynamicObjectPos(ObjectData[i][oID], newx, newy, newz);
	  				SetDynamicObjectRot(ObjectData[i][oID], newrx, newry, newrz);
				}
			}

			LastGroupPosition[playerid][xPos] = x - PivotOffset[playerid][xPos];
			LastGroupPosition[playerid][yPos] = y - PivotOffset[playerid][yPos];
			LastGroupPosition[playerid][zPos] = z - PivotOffset[playerid][zPos];

			LastPivot[playerid][xPos] = x;
			LastPivot[playerid][yPos] = y;
			LastPivot[playerid][zPos] = z;

			LastPivot[playerid][xPos] = rx;
			LastPivot[playerid][yPos] = ry;
			LastPivot[playerid][zPos] = rz;


			PivotReset[playerid] = false;
		}
	}

	else if(response == EDIT_RESPONSE_CANCEL)
	{
		foreach(new i : Objects)
		{
	   		if(GroupedObjects[playerid][i])
			{
				SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
  				SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);

				EditingMode[playerid] = false;
				SetEditMode(playerid, EDIT_MODE_NONE);
				DestroyDynamicObject(PivotObject[playerid]);
			}
		}
	}
	return 1;
}

tsfunc ClearGroup(playerid)
{
	for(new i = 0; i < MAX_TEXTURE_OBJECTS; i++)
	{
		GroupedObjects[playerid][i] = false;
		OnUpdateGroup3DText(i);
	}
	return 1;
}

tsfunc GroupUpdate(index)
{
	foreach(new i : Player)
	{
        GroupedObjects[i][index] = false;
	}
	return 1;
}

#if defined COMPILE_MANGLE
tsfunc GroupRotate(playerid, Float:rx, Float:ry, Float:rz, update = true)
{
	new Float:gCenterX, Float:gCenterY, Float:gCenterZ;
	GetGroupCenter(playerid, gCenterX, gCenterY, gCenterZ);

	// Loop through all objects and perform rotation calculations
	db_begin_transaction(EditMap);
	foreach(new i : Objects)
	{
		if(GroupedObjects[playerid][i])
		{
			AttachObjectToPoint(i, gCenterX, gCenterY, gCenterZ, rx, ry, rz, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
			if(update)
			{
				SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
				SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
				UpdateObject3DText(i);
				sqlite_UpdateObjectPos(i);
			}
		}
	}
	db_end_transaction(EditMap);
}
#endif

YCMD:ginfront(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Mova todos os objetos agrupados na frente do jogador.");
		return 1;
	}
	MapOpenCheck();
	new Float:radius;
	if(GetGroupRadius(playerid, radius))
	{
		radius += 1.0;
		new Float:x, Float:y, Float:z, Float:gcx, Float:gcy, Float:gcz, count, line[128];
		GetPlayerPos(playerid, x, y, z);
		GetPosFaInFrontOfPlayer(playerid, radius, x, y, z, gcz);
		GetGroupCenter(playerid, gcx, gcy, gcz);
		
		x -= gcx;
		y -= gcy;
		z -= gcz;

		new time = GetTickCount();

		db_begin_transaction(EditMap);
		foreach(new i : Objects)
		{
			if(GroupedObjects[playerid][i])
			{
				SaveUndoInfo(i, UNDO_TYPE_EDIT, time);
				
				ObjectData[i][oX] += x;
				ObjectData[i][oY] += y;
				ObjectData[i][oZ] += z;
				
				SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
				UpdateObject3DText(i);
				sqlite_UpdateObjectPos(i);
				count++;
			}
		}
		db_end_transaction(EditMap);
		
		format(line, sizeof(line), "%i objetos agrupados foram movidos para a frente", count);
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, line);
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Você não tem nenhum objeto agrupado");
	}
	return 1;
}

GetGroupRadius(playerid, &Float:radius)
{
	new Float:highX = -9999999.0;
	new Float:highY = -9999999.0;
	new Float:highZ = -9999999.0;

	new Float:lowX  = 9999999.0;
	new Float:lowY  = 9999999.0;
	new Float:lowZ  = 9999999.0;

	new count;

	foreach(new i : Objects)
	{
		if(GroupedObjects[playerid][i])
		{
			if(ObjectData[i][oX] > highX) highX = ObjectData[i][oX];
			if(ObjectData[i][oY] > highY) highY = ObjectData[i][oY];
			if(ObjectData[i][oZ] > highZ) highZ = ObjectData[i][oZ];
			if(ObjectData[i][oX] < lowX) lowX = ObjectData[i][oX];
			if(ObjectData[i][oY] < lowY) lowY = ObjectData[i][oY];
			if(ObjectData[i][oZ] < lowZ) lowZ = ObjectData[i][oZ];
			count++;
		}
	}

	// Not enough objects grouped
	if(count < 1) return 0;

	radius = floatdiv(getdist3d(highX, highY, highZ, lowX, lowY, lowZ), 2);

	return 1;
}

tsfunc GetGroupCenter(playerid, &Float:X, &Float:Y, &Float:Z)
{
	new Float:highX = -9999999.0;
	new Float:highY = -9999999.0;
	new Float:highZ = -9999999.0;

	new Float:lowX  = 9999999.0;
	new Float:lowY  = 9999999.0;
	new Float:lowZ  = 9999999.0;

	new count;

	foreach(new i : Objects)
	{
		if(GroupedObjects[playerid][i])
		{
			if(ObjectData[i][oX] > highX) highX = ObjectData[i][oX];
			if(ObjectData[i][oY] > highY) highY = ObjectData[i][oY];
			if(ObjectData[i][oZ] > highZ) highZ = ObjectData[i][oZ];
			if(ObjectData[i][oX] < lowX) lowX = ObjectData[i][oX];
			if(ObjectData[i][oY] < lowY) lowY = ObjectData[i][oY];
			if(ObjectData[i][oZ] < lowZ) lowZ = ObjectData[i][oZ];
			count++;
		}
	}

	// Not enough objects grouped
	if(count < 1) return 0;


	X = (highX + lowX) / 2;
	Y = (highY + lowY) / 2;
	Z = (highZ + lowZ) / 2;

	return 1;
}

YCMD:setgroup(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Define o ID do grupo dos objetos atualmente selecionados.");
		return 1;
	}

    MapOpenCheck();
    NoEditingMode(playerid);

    new groupid = strval(arg);

    new time = GetTickCount();

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	if(PlayerHasGroup(playerid))
	{
		db_begin_transaction(EditMap);
		foreach(new i : Objects)
		{
			if(GroupedObjects[playerid][i])
			{
				SaveUndoInfo(i, UNDO_TYPE_EDIT, time);
				ObjectData[i][oGroup] = groupid;
				OnUpdateGroup3DText(i);
				UpdateObject3DText(i);
				sqlite_ObjGroup(i);
			}
		}
		db_end_transaction(EditMap);
		
		new line[128];
		format(line, sizeof(line), "Defina todos os objetos do seu grupo para agrupar: %i", groupid);
		SendClientMessage(playerid, STEALTH_GREEN, line);
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "Você não tem objetos para definir como grupo!");

	return 1;
}

YCMD:selectgroup(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Selecione um grupo de objetos por ID de grupo.");
		return 1;
	}

    MapOpenCheck();
    NoEditingMode(playerid);

    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new groupid = strval(arg);
    
    if(!CanSelectGroup(playerid, groupid))
        return SendClientMessage(playerid, STEALTH_YELLOW, "Você não pode selecionar este grupo");

	if(PlayerHasGroup(playerid)) ClearGroup(playerid);

	new count;
	foreach(new i : Objects)
	{
	    if(ObjectData[i][oGroup] == groupid)
		{
		    GroupedObjects[playerid][i] = true;
			OnUpdateGroup3DText(i);
			UpdateObject3DText(i);
		    count++;
		}
	}
	if(count)
	{
		new line[128];

		// Update the Group GUI
		UpdatePlayerGSelText(playerid);
		format(line, sizeof(line), "Grupo selecionado %i Objetos: %i", groupid, count);
		SendClientMessage(playerid, STEALTH_GREEN, line);
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "Não há objetos com este ID de grupo");
	return 1;
}

YCMD:gselmodel(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Selecione um grupo de objetos por ID de modelo.");
		return 1;
	}

    MapOpenCheck();
    NoEditingMode(playerid);

    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new modelid = strval(arg);

	if(PlayerHasGroup(playerid)) ClearGroup(playerid);

	new count;
	foreach(new i : Objects)
	{
        if(!CanSelectObject(playerid, i))
            continue;
        
	    if(ObjectData[i][oModel] == modelid)
		{
		    GroupedObjects[playerid][i] = true;
			OnUpdateGroup3DText(i);
			UpdateObject3DText(i);
		    count++;
		}
	}
	if(count)
	{
		new line[128];

		// Update the Group GUI
		UpdatePlayerGSelText(playerid);
		format(line, sizeof(line), "Modelo selecionado %i Objetos: %i", modelid, count);
		SendClientMessage(playerid, STEALTH_GREEN, line);
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "Não há objetos com este ID de modelo");
	return 1;
}


PlayerHasGroup(playerid)
{
	foreach(new i : Objects)
	{
		if(GroupedObjects[playerid][i])
		{
			return 1;
		}
	}
	return 0;
}


// Edit a group
YCMD:editgroup(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Edite os objetos atualmente editados simultaneamente.");
		SendClientMessage(playerid, STEALTH_GREEN, "Segure 'Walk Key' para definir o pivô de rotação do grupo, você só pode fazer isso uma vez por edição.");
		return 1;
	}

    MapOpenCheck();
    NoEditingMode(playerid);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	if(PlayerHasGroup(playerid))
	{
		GetGroupCenter(playerid, LastPivot[playerid][xPos], LastPivot[playerid][yPos], LastPivot[playerid][zPos]);

		LastGroupPosition[playerid][xPos] = LastPivot[playerid][xPos];
		LastGroupPosition[playerid][yPos] = LastPivot[playerid][yPos];
		LastGroupPosition[playerid][zPos] = LastPivot[playerid][zPos];

		PivotOffset[playerid][xPos] = 0.0;
		PivotOffset[playerid][yPos] = 0.0;
		PivotOffset[playerid][zPos] = 0.0;

		PivotObject[playerid] = CreateDynamicObject(1974, LastPivot[playerid][xPos], LastPivot[playerid][yPos], LastPivot[playerid][zPos], 0.0, 0.0, 0.0, -1, -1, playerid);

		Streamer_SetFloatData(STREAMER_TYPE_OBJECT, PivotObject[playerid], E_STREAMER_DRAW_DISTANCE, 3000.0);

		SetDynamicObjectMaterial(PivotObject[playerid], 0, 10765, "airportgnd_sfse", "white", -256);

		Streamer_Update(playerid);

		EditingMode[playerid] = true;
		PivotReset[playerid] = true;
		SetEditMode(playerid, EDIT_MODE_OBJECTGROUP);
	    EditDynamicObject(playerid, PivotObject[playerid]);

	    SendClientMessage(playerid, STEALTH_GREEN, "Editando seu grupo");
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "Você deve ter pelo menos um objeto agrupado");

	return 1;
}


YCMD:gmtset(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Defina o material de todos os objetos atualmente selecionados.");
		return 1;
	}

    MapOpenCheck();

	EditCheck(playerid);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	if(PlayerHasGroup(playerid))
	{
		new mindex;
		new tref;
		new time = GetTickCount();

		if(GetMaterials(playerid, arg, mindex, tref))
		{
			db_begin_transaction(EditMap);
			foreach(new i : Objects)
			{
				if(GroupedObjects[playerid][i])
				{
					SaveUndoInfo(i, UNDO_TYPE_EDIT, time);
					SetMaterials(i, mindex, tref);
					UpdateObjectText(i);

					if(ObjectData[i][oAttachedVehicle] > -1)
						UpdateAttachedVehicleObject(ObjectData[i][oAttachedVehicle], i, VEHICLE_REATTACH_UPDATE);
				}
			}
			db_end_transaction(EditMap);

			SendClientMessage(playerid, STEALTH_GREEN, "Todos os materiais foram alterados");

			foreach(new i : Player)
				Streamer_Update(i);
		
			UpdateTextureSlot(playerid, mindex);
		}
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "Você deve ter pelo menos um objeto agrupado");
	
	return 1;
}


YCMD:gmtcolor(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Defina o material de todos os objetos atualmente selecionados.");
		return 1;
	}

    MapOpenCheck();

	EditCheck(playerid);

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	if(PlayerHasGroup(playerid))
	{
		new mindex;
		new time = GetTickCount();
		new HexColor[12];

		sscanf(arg, "is[12]", mindex, HexColor);
		
		if(mindex < 0 || mindex > MAX_MATERIALS - 1)
		{
			new line[128];
			format(line, sizeof(line), "A seleção do material deve estar entre <0 - %i>", MAX_MATERIALS - 1);
			return SendClientMessage(playerid, STEALTH_YELLOW, line);
		}
		
		if(IsHexValue(HexColor))
		{
			new hcolor;
			sscanf(HexColor, "h", hcolor);
			
			db_begin_transaction(EditMap);
			foreach(new i : Objects)
			{
				if(GroupedObjects[playerid][i])
				{
					SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

					ObjectData[i][oColorIndex][mindex] = hcolor;

					// Destroy the object
					DestroyDynamicObject(ObjectData[i][oID]);

					// Re-create object
					ObjectData[i][oID] = CreateDynamicObject(ObjectData[i][oModel], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ], MapSetting[mVirtualWorld], MapSetting[mInterior], -1, 300.0);
					Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[i][oID], E_STREAMER_DRAW_DISTANCE, 300.0);

					// Update the materials
					UpdateMaterial(i);

					UpdateObjectText(i);

					if(ObjectData[i][oAttachedVehicle] > -1)
						UpdateAttachedVehicleObject(ObjectData[i][oAttachedVehicle], i, VEHICLE_REATTACH_UPDATE);

					// Save this material index to the data base
					sqlite_SaveColorIndex(i);
				}
			}
			db_end_transaction(EditMap);

			SendClientMessage(playerid, STEALTH_GREEN, "Mudou todas as cores");
		}
		else
		{
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_YELLOW, "Cor hexadecimal inválida.");
			return 1;
		}

		foreach(new i : Player)
			Streamer_Update(i);
	
		UpdateTextureSlot(playerid, mindex);
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "Você deve ter pelo menos um objeto agrupado");
	
	return 1;
}


YCMD:gsel(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Select/deselect objects using the cursor.");
		SendClientMessage(playerid, STEALTH_YELLOW, "Segure a tecla 'H' ('Enter' em /flymode) e clique em um objeto para selecioná-lo");
		SendClientMessage(playerid, STEALTH_YELLOW, "Segure a tecla 'Walk' e clique em um objeto para desmarcá-lo");
		return 1;
	}

    NoEditingMode(playerid);

    MapOpenCheck();

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	if(Iter_Count(Objects))
	{
		SetEditMode(playerid, EDIT_MODE_GROUP);
		SelectObject(playerid);
		SendClientMessage(playerid, STEALTH_GREEN, "Entrou no modo de seleção de grupo");
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "There are no objects right now");

	return 1;
}

YCMD:gadd(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Adicione um objeto à seleção atual.");
		return 1;
	}

    MapOpenCheck();
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	if(isnull(arg)) return SendClientMessage(playerid, STEALTH_YELLOW, "Você deve fornecer um índice de objeto para agrupar");
	
	new index, range;
	sscanf(arg, "iI(-1)", index, range);
    
    if(range == -1 && !CanSelectObject(playerid, index))
        return SendClientMessage(playerid, STEALTH_YELLOW, "Você não pode selecionar objetos no grupo deste objeto");
        
	if(index < 0 || (range != -1 && range < 0)) return SendClientMessage(playerid, STEALTH_YELLOW, "O índice não pode ser inferior a 0");
	if(index >= MAX_TEXTURE_OBJECTS || range >= MAX_TEXTURE_OBJECTS)
	{
		new line[128];
		format(line, sizeof(line), "O índice não pode ser maior que %i", MAX_TEXTURE_OBJECTS - 1);
		return SendClientMessage(playerid, STEALTH_YELLOW, line);
	}
	if(range != -1 && range <= index) return SendClientMessage(playerid, STEALTH_YELLOW, "O intervalo não pode ser maior que o índice.");
	
	if(range != -1)
	{
		new count;
		for(new i = index; i <= range; i++)
		{
			if(CanSelectObject(playerid, i) && Iter_Contains(Objects, i) && !GroupedObjects[playerid][i])
			{
				// Update the Group GUI
				UpdatePlayerGSelText(playerid);

				GroupedObjects[playerid][i] = true;
				OnUpdateGroup3DText(i);
				
				count++;
			}
		}
		if(count) SendClientMessage(playerid, STEALTH_GREEN, sprintf("Adicionados %i objetos à sua seleção de grupo", count));
		else SendClientMessage(playerid, STEALTH_YELLOW, "Nenhum objeto nesse intervalo está na sua seleção de grupo");
	}
	else
	{
		if(Iter_Contains(Objects, index))
		{
			if(GroupedObjects[playerid][index]) SendClientMessage(playerid, STEALTH_YELLOW, "O objeto já está na sua seleção de grupo");
			else
			{
				// Update the Group GUI
				UpdatePlayerGSelText(playerid);

				SendClientMessage(playerid, STEALTH_GREEN, "Objeto adicionado à sua seleção de grupo");
				GroupedObjects[playerid][index] = true;
				OnUpdateGroup3DText(index);
			}
		}
		else SendClientMessage(playerid, STEALTH_YELLOW, "Nenhum objeto existe nesse índice");
	}
	
	return 1;
}

YCMD:grem(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Remova um objeto da sua seleção atual.");
		return 1;
	}

    MapOpenCheck();
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	if(isnull(arg)) return SendClientMessage(playerid, STEALTH_YELLOW, "Você deve fornecer um índice de objeto para agrupar");
	

	new index, range;
	sscanf(arg, "iI(-1)", index, range);
	
	if(index < 0 || (range != -1 && range < 0)) return SendClientMessage(playerid, STEALTH_YELLOW, "O índice não pode ser inferior a 0");
	if(index >= MAX_TEXTURE_OBJECTS || range >= MAX_TEXTURE_OBJECTS)
	{
		new line[128];
		format(line, sizeof(line), "O índice não pode ser maior que %i", MAX_TEXTURE_OBJECTS - 1);
		return SendClientMessage(playerid, STEALTH_YELLOW, line);
	}
	if(range != -1 && range <= index) return SendClientMessage(playerid, STEALTH_YELLOW, "O intervalo não pode ser maior que o índice.");
	
	if(range != -1)
	{
		new count;
		for(new i = index; i <= range; i++)
		{
			if(Iter_Contains(Objects, i) && GroupedObjects[playerid][i])
			{
				// Update the Group GUI
				UpdatePlayerGSelText(playerid);

				GroupedObjects[playerid][i] = false;
				OnUpdateGroup3DText(i);
				
				count++;
			}
		}
		if(count) SendClientMessage(playerid, STEALTH_GREEN, sprintf("Foram removidos %i objetos da sua seleção de grupo", count));
		else SendClientMessage(playerid, STEALTH_YELLOW, "Nenhum objeto nesse intervalo está na sua seleção de grupo");
	}
	else
	{
		if(Iter_Contains(Objects, index))
		{
			if(!GroupedObjects[playerid][index]) SendClientMessage(playerid, STEALTH_YELLOW, "O objeto não está na sua seleção de grupo");
			else
			{
				// Update the Group GUI
				UpdatePlayerGSelText(playerid);

				SendClientMessage(playerid, STEALTH_GREEN, "Objeto removido da sua seleção de grupo");
				GroupedObjects[playerid][index] = false;
				OnUpdateGroup3DText(index);
			}
		}
		else SendClientMessage(playerid, STEALTH_YELLOW, "Nenhum objeto existe nesse índice");
	}
	
	return 1;
}

YCMD:gclear(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Limpa a seleção atual.");
		return 1;
	}

	MapOpenCheck();
    ClearGroup(playerid);
	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
    SendClientMessage(playerid, STEALTH_GREEN, "Sua seleção de grupo foi apagada");

	// Update the Group GUI
	UpdatePlayerGSelText(playerid);

	return 1;
}

new bool:tmpgrp[MAX_TEXTURE_OBJECTS];

YCMD:gclone(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Clonar todos os objetos atualmente selecionados.");
		return 1;
	}

    MapOpenCheck();

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new index;
	new count;
	new time = GetTickCount();

	for(new i = 0; i < MAX_TEXTURE_OBJECTS; i++) { tmpgrp[i] = false; }

	db_begin_transaction(EditMap);
    foreach(new i : Objects)
    {
        if(GroupedObjects[playerid][i])
        {
			index = CloneObject(i, time);
            GroupedObjects[playerid][i] = false;
            tmpgrp[index] = true;
			OnUpdateGroup3DText(i);
			count++;
        }
    }
	db_end_transaction(EditMap);

    // Update grouped objects
    for(new i = 0; i < MAX_TEXTURE_OBJECTS; i++)
	{
		GroupedObjects[playerid][i] = tmpgrp[i];
		if(GroupedObjects[playerid][i] == true)
		OnUpdateGroup3DText(i);
	}

    if(count)
	{
		// Update the Group GUI
		UpdatePlayerGSelText(playerid);

		new line[128];
		format(line, sizeof(line), "Seleção de grupo clonado Objetos: %i", count);
		SendClientMessage(playerid, STEALTH_GREEN, line);
	}
    else SendClientMessage(playerid, STEALTH_YELLOW, "Nenhum objeto de grupo para clonar");

    return 1;
}

YCMD:gdelete(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Destrua todos os objetos atualmente selecionados.");
		return 1;
	}

    MapOpenCheck();

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new count;
	new time = GetTickCount();

	db_begin_transaction(EditMap);
    foreach(new i : Objects)
    {
        if(GroupedObjects[playerid][i])
        {
			SaveUndoInfo(i, UNDO_TYPE_DELETED, time);
			i = DeleteDynamicObject(i);
        	count++;
        }
    }
	db_end_transaction(EditMap);

    if(count)
	{
		// Update the Group GUI
		UpdatePlayerGSelText(playerid);

		new line[128];
		format(line, sizeof(line), "Objetos de seleção de grupo excluídos: %i", count);
		SendClientMessage(playerid, STEALTH_GREEN, line);
	}
    else SendClientMessage(playerid, STEALTH_YELLOW, "Nenhum objeto de grupo para excluir");

	return 1;
}

YCMD:gall(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Adicione todos os objetos carregados à seleção atual.");
		return 1;
	}

    MapOpenCheck();

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	new count;

    foreach(new i : Objects)
	{
        if(!CanSelectObject(playerid, i))
            continue;
        
        GroupedObjects[playerid][i] = true;
		OnUpdateGroup3DText(i);
		count++;
    }

    if(count)
	{
		// Update the Group GUI
		UpdatePlayerGSelText(playerid);

		new line[128];
		format(line, sizeof(line), "Todos os objetos agrupados", count);
		SendClientMessage(playerid, STEALTH_GREEN, line);
	}
    else SendClientMessage(playerid, STEALTH_YELLOW, "Não há objetos para agrupar");

	return 1;
}

YCMD:ginvert(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Inverta todos os objetos atualmente selecionados no eixo selecionado.");
		return 1;
	}

    MapOpenCheck();
//	NoEditingMode(playerid);
//	EditCheck(playerid);
	
	inline Mirror(mxpid, mxdialogid, mxresponse, mxlistitem, string:mxtext[])
	{
		#pragma unused mxpid, mxdialogid, mxtext
		if(!mxresponse)
			return 1;
			
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		
		new Float:gcx, Float:gcy, Float:gcz;
		GetGroupCenter(playerid, gcx, gcy, gcz);
		new time = GetTickCount();
		
		db_begin_transaction(EditMap);
		foreach(new i: Objects)
		{
			if(GroupedObjects[playerid][i])
			{
				SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

				switch(mxlistitem) {
					case 0: {
						ObjectData[i][oX] = -ObjectData[i][oX] + (2.0 * gcx);
					//	ObjectData[i][oRY] = -ObjectData[i][oRY];
					//	ObjectData[i][oRZ] = -ObjectData[i][oRZ];
					
					//	ObjectData[i][oRY] += 180.0;
					//	ObjectData[i][oRZ] += 180.0;
					
					//	ObjectData[i][oRX] += 180.0;
					}
					case 1: {
						ObjectData[i][oY] = -ObjectData[i][oY] + (2.0 * gcy);
					//	ObjectData[i][oRX] = -ObjectData[i][oRX];
					//	ObjectData[i][oRZ] = -ObjectData[i][oRZ];
					
					//	ObjectData[i][oRX] += 180.0;
					//	ObjectData[i][oRZ] += 180.0;

					//	ObjectData[i][oRY] += 180.0;
					}
					case 2: {
						ObjectData[i][oZ] = -ObjectData[i][oZ] + (2.0 * gcz);
					//	ObjectData[i][oRX] = -ObjectData[i][oRX];
					//	ObjectData[i][oRY] = -ObjectData[i][oRY];
					
					//	ObjectData[i][oRX] += 180.0;
					//	ObjectData[i][oRY] += 180.0;

					//	ObjectData[i][oRZ] += 180.0;
					}
				}
				EDIT_FloatGetRemainder(ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
				
				SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
				SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);

				UpdateObject3DText(i);

				sqlite_UpdateObjectPos(i);
			}
		}
		db_end_transaction(EditMap);
		
		//(Not added to GUI yet)
		// Update the Group GUI
		//UpdatePlayerGSelText(playerid);
		
		new c = mxlistitem == 0 ? 'X' : mxlistitem == 1 ? 'Y' : 'Z';
		SendClientMessage(playerid, STEALTH_GREEN, sprintf("Inverteu tudo atualmente selecionado ao longo do eixo %c.", c));
	}
	Dialog_ShowCallback(playerid, using inline Mirror, DIALOG_STYLE_LIST, "Texture Studio - Selecione o eixo do espelho", "X\nY\nZ", "Selecionar", "");

	return 1;
}

// Move all grouped objects on X axis
YCMD:gox(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Mova todos os objetos atualmente selecionados ao longo do eixo X.");
		return 1;
	}

    MapOpenCheck();

	new Float:dist;
	new time = GetTickCount();

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

	db_begin_transaction(EditMap);
 	foreach(new i : Objects)
	{
		if(GroupedObjects[playerid][i])
		{
			SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

		    ObjectData[i][oX] += dist;

		    SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);

			UpdateObject3DText(i);

		    sqlite_UpdateObjectPos(i);
		}
	}
	db_end_transaction(EditMap);
	
	// Update the Group GUI
	UpdatePlayerGSelText(playerid);

	return 1;
}

// Move all grouped objects on Y axis
YCMD:goy(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Mova todos os objetos atualmente selecionados ao longo do eixo Y.");
		return 1;
	}

    MapOpenCheck();

	new Float:dist;
    new time = GetTickCount();

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

	db_begin_transaction(EditMap);
 	foreach(new i : Objects)
	{
		if(GroupedObjects[playerid][i])
		{
			SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

		    ObjectData[i][oY] += dist;

		    SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);

			UpdateObject3DText(i);

		    sqlite_UpdateObjectPos(i);

		}
	}
	db_end_transaction(EditMap);

	// Update the Group GUI
	UpdatePlayerGSelText(playerid);


	return 1;
}

// Move all grouped objects on Z axis
YCMD:goz(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Mova todos os objetos atualmente selecionados ao longo do eixo Z.");
		return 1;
	}

    MapOpenCheck();

	new Float:dist;
	new time = GetTickCount();

	dist = floatstr(arg);
	if(dist == 0) dist = 1.0;

	db_begin_transaction(EditMap);
 	foreach(new i : Objects)
	{
		if(GroupedObjects[playerid][i])
		{
			SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

		    ObjectData[i][oZ] += dist;

		    SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);

			UpdateObject3DText(i);

		    sqlite_UpdateObjectPos(i);
		}
	}
	db_end_transaction(EditMap);

	// Update the Group GUI
	UpdatePlayerGSelText(playerid);

	return 1;
}

// Rotate map on RX
YCMD:grx(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Gire todos os objetos atualmente selecionados em torno do eixo X.");
		return 1;
	}

    MapOpenCheck();
	new time = GetTickCount();
	new Float:Delta;
	if(sscanf(arg, "f", Delta))
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Uso: /grx <rotação>");
		return 1;
	}

	// We need to get the map center as the rotation node
	new bool:value, Float:gCenterX, Float:gCenterY, Float:gCenterZ;

	if(PivotPointOn[playerid])
	{
		new bool:hasgroup;
		foreach(new i : Objects)
		{
		    if(GroupedObjects[playerid][i])
		    {
			    gCenterX = PivotPoint[playerid][xPos];
			    gCenterY = PivotPoint[playerid][yPos];
			    gCenterZ = PivotPoint[playerid][zPos];
				value = true;
                hasgroup = true;
				break;
			}
		}
		if(!hasgroup)
		{
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_YELLOW, "Não há objetos suficientes para este comando funcionar");
		}
	}
	else if(GetGroupCenter(playerid, gCenterX, gCenterY, gCenterZ)) value = true;

	if(value)
	{
		// Loop through all objects and perform rotation calculations
		db_begin_transaction(EditMap);
		foreach(new i : Objects)
		{
			if(GroupedObjects[playerid][i])
			{
				SaveUndoInfo(i, UNDO_TYPE_EDIT, time);
				AttachObjectToPoint(i, gCenterX, gCenterY, gCenterZ, Delta, 0.0, 0.0, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
				SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
				SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);

				UpdateObject3DText(i);

				sqlite_UpdateObjectPos(i);

			}
		}
		db_end_transaction(EditMap);

		// Update the Group GUI
		UpdatePlayerGSelText(playerid);

		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotação do Grupo RX concluída");
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Não há objetos suficientes para este comando funcionar");
	}

	return 1;
}

// Rotate map on RX
YCMD:gry(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Gire todos os objetos atualmente selecionados em torno do eixo Y.");
		return 1;
	}

    MapOpenCheck();
	new time = GetTickCount();
	new Float:Delta;
	if(sscanf(arg, "f", Delta))
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Uso: /gry <rotação>");
		return 1;
	}

	// We need to get the map center as the rotation node
	new bool:value, Float:gCenterX, Float:gCenterY, Float:gCenterZ;

	if(PivotPointOn[playerid])
	{
		new bool:hasgroup;
		foreach(new i : Objects)
		{
		    if(GroupedObjects[playerid][i])
		    {
			    gCenterX = PivotPoint[playerid][xPos];
			    gCenterY = PivotPoint[playerid][yPos];
			    gCenterZ = PivotPoint[playerid][zPos];
				value = true;
                hasgroup = true;
				break;
			}
		}
		if(!hasgroup)
		{
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_YELLOW, "Não há objetos suficientes para este comando funcionar");
		}
	}
	else if(GetGroupCenter(playerid, gCenterX, gCenterY, gCenterZ)) value = true;

	if(value)
	{
		// Loop through all objects and perform rotation calculations
		db_begin_transaction(EditMap);
		foreach(new i : Objects)
		{
			if(GroupedObjects[playerid][i])
			{
				SaveUndoInfo(i, UNDO_TYPE_EDIT, time);
				AttachObjectToPoint(i, gCenterX, gCenterY, gCenterZ, 0.0, Delta, 0.0, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
				SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
				SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);

				UpdateObject3DText(i);

				sqlite_UpdateObjectPos(i);
			}
		}
		db_end_transaction(EditMap);

   		// Update the Group GUI
		UpdatePlayerGSelText(playerid);

		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotação do Grupo RY concluída");
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Não há objetos suficientes para este comando funcionar");
	}

	return 1;
}

// Rotate map on RX
YCMD:grz(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Gire todos os objetos atualmente selecionados em torno do eixo Z.");
		return 1;
	}

    MapOpenCheck();
	new time = GetTickCount();
	new Float:Delta;
	if(sscanf(arg, "f", Delta))
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Uso: /grz <rotação>");
		return 1;
	}

	// We need to get the map center as the rotation node
	new bool:value, Float:gCenterX, Float:gCenterY, Float:gCenterZ;

	if(PivotPointOn[playerid])
	{
		new bool:hasgroup;
		foreach(new i : Objects)
		{
		    if(GroupedObjects[playerid][i])
		    {
			    gCenterX = PivotPoint[playerid][xPos];
			    gCenterY = PivotPoint[playerid][yPos];
			    gCenterZ = PivotPoint[playerid][zPos];
				value = true;
                hasgroup = true;
				break;
			}
		}
		if(!hasgroup)
		{
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			SendClientMessage(playerid, STEALTH_YELLOW, "Não há objetos suficientes para este comando funcionar");
		}
	}
	else if(GetGroupCenter(playerid, gCenterX, gCenterY, gCenterZ)) value = true;

	if(value)
	{
		// Loop through all objects and perform rotation calculations
		db_begin_transaction(EditMap);
		foreach(new i : Objects)
		{
			if(GroupedObjects[playerid][i])
			{
				SaveUndoInfo(i, UNDO_TYPE_EDIT, time);
				AttachObjectToPoint(i, gCenterX, gCenterY, gCenterZ, 0.0, 0.0, Delta, ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);
				SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);
				SetDynamicObjectRot(ObjectData[i][oID], ObjectData[i][oRX], ObjectData[i][oRY], ObjectData[i][oRZ]);

				UpdateObject3DText(i);

				sqlite_UpdateObjectPos(i);
			}
		}
		db_end_transaction(EditMap);

   		// Update the Group GUI
		UpdatePlayerGSelText(playerid);

		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Rotação do Grupo RZ concluída");
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Não há objetos suficientes para este comando funcionar");
	}

	return 1;
}

YCMD:gdd(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Defina a distância de visão de um grupo.");
		return 1;
	}

    MapOpenCheck();
	new time = GetTickCount();
	new Float:dd;
	sscanf(arg, "F(300.0)", dd);

    db_begin_transaction(EditMap);
    foreach(new i : Objects)
    {
        if(GroupedObjects[playerid][i])
        {
            SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

            ObjectData[i][oDD] = dd;
            Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[i][oID], E_STREAMER_DRAW_DISTANCE, dd);
            Streamer_SetFloatData(STREAMER_TYPE_OBJECT, ObjectData[i][oID], E_STREAMER_STREAM_DISTANCE, dd);

            sqlite_UpdateObjectDD(i);
        }
    }
    db_end_transaction(EditMap);

    SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
    SendClientMessage(playerid, STEALTH_GREEN, sprintf("Distância de desenho dos grupos definida como %.2f", dd));

	return 1;
}


// Export group of objects as an attached object
YCMD:gaexport(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Exporte todos os objetos atualmente selecionados como um objeto anexado.");
		return 1;
	}

	MapOpenCheck();

	new count;
	foreach(new i : Objects)
	{
	    if(GroupedObjects[playerid][i])
		{
			count++;
			break;
		}
	}

	if(count)
	{
	    inline CreateAttachExport(cpid, cdialogid, cresponse, clistitem, string:ctext[])
		{
		    #pragma unused clistitem, cdialogid, cpid
			if(cresponse)
		    {
				if(!isnull(ctext))
				{
					inline DrawDist(dpid, ddialogid, dresponse, dlistitem, string:dtext[])
					{
						#pragma unused dlistitem, ddialogid, dpid
						new Float:dist;

						// Set the drawdistance
						if(dresponse)
						{
							if(sscanf(dtext, "f", dist)) dist = 300.0;
						}
						else dist = 300.0;

						new mapname[128];
						
						if(strlen(ctext) >= 20)
						{
							SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
							SendClientMessage(playerid, STEALTH_YELLOW, "Escolha um nome de mapa mais curto para exportar...");
							return 1;
						}
						
						format(mapname, sizeof(mapname), "tstudio/AttachExport/%s.txt", ctext);

						if(!fexist(mapname)) AttachExport(playerid, mapname, dist);
						else
						{
							inline OverwriteAttachExport(opid, odialogid, oresponse, olistitem, string:otext[])
							{
								#pragma unused olistitem, odialogid, opid, otext

								if(oresponse)
								{
									fremove(mapname);
									AttachExport(playerid, mapname, dist);
								}

							}
							SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
							SendClientMessage(playerid, STEALTH_YELLOW, "Já existe uma exportação de objeto anexado com esse nome");
							Dialog_ShowCallback(playerid, using inline OverwriteAttachExport, DIALOG_STYLE_MSGBOX, "Texture Studio", "O arquivo anexado existe para substituir?", "Ok", "Cancelar");
						}
					}
					Dialog_ShowCallback(playerid, using inline DrawDist, DIALOG_STYLE_INPUT, "Texture Studio (Map Export)", "Insira a distância de visão dos objetos\n(Observação: a distância de visão padrão é 300.0)", "Ok", "Cancelar");
				}
				else
				{
					SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_YELLOW, "Você deve dar um nome de arquivo à exportação anexada");
					Dialog_ShowCallback(playerid, using inline CreateAttachExport, DIALOG_STYLE_INPUT, "Texture Studio", "Insira o arquivo de exportação do objeto anexado", "Ok", "Cancelar");
				}
		    }
		}
		Dialog_ShowCallback(playerid, using inline CreateAttachExport, DIALOG_STYLE_INPUT, "Texture Studio", "Insira o arquivo de exportação do objeto anexado", "Ok", "Cancelar");
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Nenhum objeto para salvar no pré-fabricado");
	}
	return 1;
}

AttachExport(playerid, mapname[], Float:drawdist)
{
	// Choose a object as a center node
	inline SelectObjectCenterNode(spid, sdialogid, sresponse, slistitem, string:stext[])
	{
		#pragma unused slistitem, sdialogid, spid
		if(sresponse)
		{
			if(isnull(stext))
			{
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_YELLOW, "Você deve fornecer um índice como objeto central");
				Dialog_ShowCallback(playerid, using inline SelectObjectCenterNode, DIALOG_STYLE_INPUT, "Texture Studio", "Insira o índice do objeto do centro do objeto anexado", "Ok", "Cancelar");
				return 1;
			}
			new centerindex = strval(stext);

			if(centerindex < 0 || centerindex > MAX_TEXTURE_OBJECTS - 1)
			{
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_YELLOW, "Índice inválido");
				Dialog_ShowCallback(playerid, using inline SelectObjectCenterNode, DIALOG_STYLE_INPUT, "Texture Studio", "Insira o índice do objeto do centro do objeto anexado", "Ok", "Cancelar");
				return 1;
			}

		    if(!GroupedObjects[playerid][centerindex])
		    {
				SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
				SendClientMessage(playerid, STEALTH_YELLOW, "Esse objeto não está na sua seleção de grupo");
				Dialog_ShowCallback(playerid, using inline SelectObjectCenterNode, DIALOG_STYLE_INPUT, "Texture Studio", "Insira o índice do objeto do centro do objeto anexado", "Ok", "Cancelar");
				return 1;
		    }

			// Get Offsets
		    new Float:offx, Float:offy, Float:offz;
		    offx = ObjectData[centerindex][oX];
		    offy = ObjectData[centerindex][oY];
		    offz = ObjectData[centerindex][oZ];

			new exportmap[256];
			format(exportmap, sizeof(exportmap), "%s", mapname);

			new mobjects;
			new templine[256];
			new File:f;
			new syncrot = 1;

			f = fopen(exportmap,io_write);
			if(!f) {
				SendClientMessage(playerid, -1, "For some reason this file isn't being created.");
				SendClientMessage(playerid, -1, "Trying to highjack the existing blank.txt instead (temporary solution).");
				f = fopen("tstudio/AttachExport/blank.txt",io_write);
				if(!f) {
					SendClientMessage(playerid, -1, "Failed to highjack...");
				}
			}
			
			fwrite(f,"//Attached Object Map Exported with Texture Studio By: [uL]Pottus////////////////////////////////////////////////\r\n");
			fwrite(f,"//////////////////////////////////////////////////////////////and Crayder////////////////////////////////////////\r\n");
			fwrite(f,"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");

			// Temp object for setting materials
			format(templine,sizeof(templine),"new centobjid, tmpobjid;\r\n");
			fwrite(f,templine);

			format(templine,sizeof(templine),"centobjid = CreateObject(%i,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f);\r\n",ObjectData[centerindex][oModel],ObjectData[centerindex][oX],ObjectData[centerindex][oY],ObjectData[centerindex][oZ],ObjectData[centerindex][oRX],ObjectData[centerindex][oRY],ObjectData[centerindex][oRZ],drawdist);
			fwrite(f,templine);

			// Write all objects with materials first
			foreach(new i : Objects)
			{
			    if(ObjectData[i][oAttachedVehicle] > -1 || !GroupedObjects[playerid][i] || centerindex == i) continue;

				new bool:writeobject;

				// Does the object have materials?
		        for(new j = 0; j < MAX_MATERIALS; j++)
		        {
		            if(ObjectData[i][oTexIndex][j] != 0 || ObjectData[i][oColorIndex][j] != 0 || ObjectData[i][ousetext])
		            {
						writeobject = true;
						break;
					}
				}

				// Object had materials we will write them to the export file
				if(writeobject)
				{
					mobjects++;

					// Write the create object line
					format(templine,sizeof(templine),"tmpobjid = CreateObject(%i,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f);\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],drawdist);
					fwrite(f,templine);

					// Write all materials and colors
		  			for(new j = 0; j < MAX_MATERIALS; j++)
		        	{
						// Does object have a texture set?
			            if(ObjectData[i][oTexIndex][j] != 0)
			            {
							format(templine,sizeof(templine),"SetObjectMaterial(tmpobjid, %i, %i, %c%s%c, %c%s%c, %i);\r\n", j, GetTModel(ObjectData[i][oTexIndex][j]), 34, GetTXDName(ObjectData[i][oTexIndex][j]), 34, 34,GetTextureName(ObjectData[i][oTexIndex][j]), 34, ObjectData[i][oColorIndex][j]);
							fwrite(f,templine);
			            }
			            // No texture how about a color?
			            else if(ObjectData[i][oColorIndex][j] != 0)
			            {
							format(templine,sizeof(templine),"SetObjectMaterial(tmpobjid, %i, -1, %c%s%c, %c%s%c, %i);\r\n", j, 34, "none", 34, 34,"none", 34, ObjectData[i][oColorIndex][j]);
							fwrite(f,templine);
						}
					}

					// Write any text
					if(ObjectData[i][ousetext])
					{
						format(templine,sizeof(templine),"SetObjectMaterialText(tmpobjid, %c%s%c, 0, %i, %c%s%c, %i, %i, %i, %i, %i);\r\n",
							34, ObjectData[i][oObjectText], 34,
							FontSizes[ObjectData[i][oFontSize]],
							34, FontNames[ObjectData[i][oFontFace]], 34,
							ObjectData[i][oTextFontSize],
							ObjectData[i][oFontBold],
							ObjectData[i][oFontColor],
							ObjectData[i][oBackColor],
							ObjectData[i][oAlignment]
						);
						fwrite(f,templine);
					}

					// Attach the object
					format(templine,sizeof(templine),"AttachObjectToObject(tmpobjid,centobjid,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%i);\r\n",
						offx - ObjectData[i][oX],
						offy - ObjectData[i][oY],
						offz - ObjectData[i][oZ],
						ObjectData[i][oRX],
						ObjectData[i][oRY],
						ObjectData[i][oRZ],
						syncrot
					);
					fwrite(f,templine);
				}
			}

			if(mobjects)
			{
				fwrite(f,"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");
				fwrite(f,"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");
				fwrite(f,"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n");
			}

			// We need to write all of the objects that didn't have materials set now
			foreach(new i : Objects)
			{
			    if(ObjectData[i][oAttachedVehicle] > -1 || !GroupedObjects[playerid][i] || centerindex == i) continue;

				new bool:skipobject = true;

				// Does the object have materials?
		        for(new j = 0; j < MAX_MATERIALS; j++)
		        {
					// This object has already been written
		            if(ObjectData[i][oTexIndex][j] != 0 || ObjectData[i][oColorIndex][j] != 0 || ObjectData[i][ousetext])
		            {
						skipobject = true;
						break;
					}
				}

				// Object has not been exported yet export
				if(!skipobject)
				{
					format(templine,sizeof(templine),"tmpobjid = CreateObject(%i,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f);\r\n",ObjectData[i][oModel],ObjectData[i][oX],ObjectData[i][oY],ObjectData[i][oZ],ObjectData[i][oRX],ObjectData[i][oRY],ObjectData[i][oRZ],drawdist);
					fwrite(f,templine);
				}

				// Attach the object
				format(templine,sizeof(templine),"AttachObjectToObject(tmpobjid,centobjid,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%i);\r\n",
					offx - ObjectData[i][oX],
					offy - ObjectData[i][oY],
					offz - ObjectData[i][oZ],
					ObjectData[i][oRX],
					ObjectData[i][oRY],
					ObjectData[i][oRZ],
					syncrot
				);
				fwrite(f,templine);
			}

			fclose(f);
			SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
			format(templine, sizeof(templine), "O mapa foi exportado para %s", exportmap);
			SendClientMessage(playerid, STEALTH_GREEN, templine);
		}
	}

    Dialog_ShowCallback(playerid, using inline SelectObjectCenterNode, DIALOG_STYLE_INPUT, "Texture Studio", "Insira o índice do objeto do centro do objeto anexado", "Ok", "Cancelar");

	return 1;
}

// Save objects as a prefab data base
new NewPreFabString[512];
new DB: PrefabDB;
YCMD:gprefab(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Salve os objetos atuais como um grupo pré-fabricado.");
		return 1;
	}

	MapOpenCheck();

	new count;
	foreach(new i : Objects)
	{
	    if(GroupedObjects[playerid][i])
		{
			count++;
			break;
		}
	}

	if(count)
	{
	    inline CreatePrefab(cpid, cdialogid, cresponse, clistitem, string:ctext[])
		{
		    #pragma unused clistitem, cdialogid, cpid
			if(cresponse)
		    {
				if(!isnull(ctext))
				{
					new mapname[128];
					format(mapname, sizeof(mapname), "tstudio/PreFabs/%s.db", ctext);

					if(!fexist(mapname))
					{
						// Open the map for editing
			            PrefabDB = db_open_persistent(mapname);

						if(!NewPreFabString[0])
						{
							strimplode(" ",
								NewPreFabString,
								sizeof(NewPreFabString),
								"CREATE TABLE IF NOT EXISTS `Objects`",
								"(ModelID INTEGER,",
								"xPos REAL,",
								"yPos REAL,",
								"zPos REAL,",
								"rxRot REAL,",
								"ryRot REAL,",
								"rzRot REAL,",
								"TextureIndex TEXT,",
								"ColorIndex TEXT,",
								"usetext INTEGER,",
								"FontFace INTEGER,",
								"FontSize INTEGER,",
								"FontBold INTEGER,",
								"FontColor INTEGER,",
								"BackColor INTEGER,",
								"Alignment INTEGER,",
								"TextFontSize INTEGER,",
								"ObjectText TEXT);"
							);
						}

						db_exec(PrefabDB, NewPreFabString);

						// Prefab extra info
						db_exec(PrefabDB, "CREATE TABLE IF NOT EXISTS `PrefabInfo` (zOFF REAL);");
						db_exec(PrefabDB, "INSERT INTO `PrefabInfo` VALUES(0.0);");


						new Float:x, Float:y, Float:z;

						if(!GetGroupCenter(playerid, x, y, z))
						{
							foreach(new i : Objects)
							{
								if(GroupedObjects[playerid][i])
								{
									x = ObjectData[i][oX];
									y = ObjectData[i][oY];
									z = ObjectData[i][oZ];
									break;
								}
						    }
						}


						count = 0;

						db_begin_transaction(EditMap);
						foreach(new i : Objects)
						{
							if(GroupedObjects[playerid][i])
							{
								sqlite_InsertPrefab(i, x, y, z);
								count++;
						    }
						}
						db_end_transaction(EditMap);

						SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
						new line[128];
						format(line, sizeof(line), "Você criou uma contagem de objetos pré-fabricados: %i", count);
						SendClientMessage(playerid, STEALTH_GREEN, line);

						db_free_persistent(PrefabDB);

					}
					else
					{
						SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
						SendClientMessage(playerid, STEALTH_YELLOW, "Já existe uma casa pré-fabricada com esse nome");
						Dialog_ShowCallback(playerid, using inline CreatePrefab, DIALOG_STYLE_INPUT, "Texture Studio", "Insira um nome pré-fabricado", "Ok", "Cancelar");
					}
				}
				else
				{
					SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
					SendClientMessage(playerid, STEALTH_YELLOW, "Você deve dar um nome de arquivo ao seu pré-fabricado");
					Dialog_ShowCallback(playerid, using inline CreatePrefab, DIALOG_STYLE_INPUT, "Texture Studio", "Insira um nome pré-fabricado", "Ok", "Cancelar");
				}
		    }
		}
		Dialog_ShowCallback(playerid, using inline CreatePrefab, DIALOG_STYLE_INPUT, "Texture Studio", "Insira um nome pré-fabricado", "Ok", "Cancelar");
	}
	else
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_YELLOW, "Nenhum objeto para salvar no pré-fabricado");
	}
	return 1;
}


// Insert object to prefab DB
new DBStatement:insertprefabstmt;
new InsertPrefabString[512];

sqlite_InsertPrefab(index, Float:x, Float:y, Float:z)
{
	// Inserts a new index
	if(!InsertPrefabString[0])
	{
		// Prepare query
		strimplode(" ",
			InsertPrefabString,
			sizeof(InsertPrefabString),
			"INSERT INTO `Objects`",
	        "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
		);
	}

	insertprefabstmt = db_prepare(PrefabDB, InsertPrefabString);

	// Bind our results
    stmt_bind_value(insertprefabstmt, 0, DB::TYPE_INT, ObjectData[index][oModel]);
    stmt_bind_value(insertprefabstmt, 1, DB::TYPE_FLOAT, ObjectData[index][oX]-x);
    stmt_bind_value(insertprefabstmt, 2, DB::TYPE_FLOAT, ObjectData[index][oY]-y);
    stmt_bind_value(insertprefabstmt, 3, DB::TYPE_FLOAT, ObjectData[index][oZ]-z);
    stmt_bind_value(insertprefabstmt, 4, DB::TYPE_FLOAT, ObjectData[index][oRX]);
    stmt_bind_value(insertprefabstmt, 5, DB::TYPE_FLOAT, ObjectData[index][oRY]);
    stmt_bind_value(insertprefabstmt, 6, DB::TYPE_FLOAT, ObjectData[index][oRZ]);
    stmt_bind_value(insertprefabstmt, 7, DB::TYPE_ARRAY, ObjectData[index][oTexIndex], MAX_MATERIALS);
    stmt_bind_value(insertprefabstmt, 8, DB::TYPE_ARRAY, ObjectData[index][oColorIndex], MAX_MATERIALS);
    stmt_bind_value(insertprefabstmt, 9, DB::TYPE_INT, ObjectData[index][ousetext]);
    stmt_bind_value(insertprefabstmt, 10, DB::TYPE_INT, ObjectData[index][oFontFace]);
    stmt_bind_value(insertprefabstmt, 11, DB::TYPE_INT, ObjectData[index][oFontSize]);
    stmt_bind_value(insertprefabstmt, 12, DB::TYPE_INT, ObjectData[index][oFontBold]);
    stmt_bind_value(insertprefabstmt, 13, DB::TYPE_INT, ObjectData[index][oFontColor]);
    stmt_bind_value(insertprefabstmt, 14, DB::TYPE_INT, ObjectData[index][oBackColor]);
    stmt_bind_value(insertprefabstmt, 15, DB::TYPE_INT, ObjectData[index][oAlignment]);
    stmt_bind_value(insertprefabstmt, 16, DB::TYPE_INT, ObjectData[index][oTextFontSize]);
    stmt_bind_value(insertprefabstmt, 17, DB::TYPE_STRING, ObjectData[index][oObjectText], MAX_TEXT_LENGTH);

    stmt_execute(insertprefabstmt);
	stmt_close(insertprefabstmt);
}

YCMD:prefabsetz(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Defina o deslocamento do eixo Z do grupo pré-fabricado.");
		return 1;
	}

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	if(isnull(arg)) ShowPrefabs(playerid);
	else
	{
		new Float:offset;
		new mapname[128];

		if(sscanf(arg, "s[128]f", mapname, offset)) return SendClientMessage(playerid, STEALTH_YELLOW, "Você deve fornecer um valor de deslocamento válido!");

		format(mapname, sizeof(mapname), "tstudio/PreFabs/%s.db", mapname);
		if(fexist(mapname))
		{
		    PrefabDB = db_open_persistent(mapname);
			new Query[128];
			format(Query, sizeof(Query), "UPDATE `PrefabInfo` SET `zOFF` = %f;", offset);
			db_exec(PrefabDB, Query);
		    db_free_persistent(PrefabDB);
			SendClientMessage(playerid, STEALTH_GREEN, "Deslocamento Z-Load pré-fabricado atualizado");
		}
		else SendClientMessage(playerid, STEALTH_YELLOW, "Essa pré-fabricada não existe!");
	}

	return 1;
}

// Load a prefab specify a filename
YCMD:prefab(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Carregue um grupo pré-fabricado de objetos.");
		return 1;
	}

	MapOpenCheck();

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
	if(isnull(arg)) ShowPrefabs(playerid);
	else
	{
		new mapname[128];
		format(mapname, sizeof(mapname), "tstudio/PreFabs/%s.db", arg);
		if(fexist(mapname))
		{
		    PrefabDB = db_open_persistent(mapname);
		    sqlite_LoadPrefab(playerid);
		    db_free_persistent(PrefabDB);
			SendClientMessage(playerid, STEALTH_GREEN, "Pré-fabricado carregado e definido para sua seleção de grupo");
		}
		else SendClientMessage(playerid, STEALTH_YELLOW, "Essa pré-fabricada não existe!");
	}

	return 1;
}

YCMD:0group(playerid, arg[], help)
{
	if(help)
	{
		SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");
		SendClientMessage(playerid, STEALTH_GREEN, "Centralize todos os objetos atualmente selecionados no centro de San Andreas.");
		return 1;
	}

    MapOpenCheck();

	new Float:gCenterX, Float:gCenterY, Float:gCenterZ;
	GetGroupCenter(playerid, gCenterX, gCenterY, gCenterZ);

	new bool:hasgroup;
	new time = GetTickCount();

	SendClientMessage(playerid, STEALTH_ORANGE, "______________________________________________");

	db_begin_transaction(EditMap);
	foreach(new i : Objects)
	{
   		if(GroupedObjects[playerid][i])
		{
			SaveUndoInfo(i, UNDO_TYPE_EDIT, time);

			ObjectData[i][oX] -= gCenterX;
			ObjectData[i][oY] -= gCenterY;
			ObjectData[i][oZ] -= gCenterZ;

			SetDynamicObjectPos(ObjectData[i][oID], ObjectData[i][oX], ObjectData[i][oY], ObjectData[i][oZ]);

		    sqlite_UpdateObjectPos(i);

		    UpdateObject3DText(i);

			hasgroup = true;
		}
	}
	db_end_transaction(EditMap);

	if(hasgroup) SendClientMessage(playerid, STEALTH_GREEN, "Objetos agrupados movidos para 0,0,0");
	else SendClientMessage(playerid, STEALTH_YELLOW, "Você não tem nenhum objeto agrupado");

	return 1;
}

tsfunc ShowPrefabs(playerid)
{
	new dir:dHandle = dir_open("./scriptfiles/tstudio/PreFabs/");
	new item[40], type;
	new line[128];
	new extension[3];
	new fcount;
	new total;

	// Create a load list
	while(dir_list(dHandle, item, type))
	{
	 	if(type != FM_DIR)
	    {
			// We need to check extension
			if(strlen(item) > 3)
			{
				format(extension, sizeof(extension), "%s%s", item[strlen(item) - 2],item[strlen(item) - 1]);

				// File is apparently a db
				if(!strcmp(extension, "db"))
				{
					format(line, sizeof(line), "%s %s,", line, item);
					fcount++;
					total++;
					if(fcount == 8)
					{
						SendClientMessage(playerid, STEALTH_YELLOW, line);
						fcount = 0;
						line = "";
					}
				}
		    }
		}
	}
	if(fcount != 0) SendClientMessage(playerid, STEALTH_YELLOW, line);
	if(total > 0)
	{
		format(line, sizeof(line), "Exibindo %i pré-fabricados", total);
		SendClientMessage(playerid, STEALTH_GREEN, line);
	}
	else SendClientMessage(playerid, STEALTH_YELLOW, "Não há pré-fabricados para listar!");
	return 1;
}

static DBStatement:loadprefabstmt;

// Loads map objects from a data base
sqlite_LoadPrefab(playerid, offset = true)
{
	// Load query stmt
	loadprefabstmt = db_prepare(PrefabDB, "SELECT * FROM `Objects`");

	new tmpobject[OBJECTINFO];

	// Bind our results
    stmt_bind_result_field(loadprefabstmt, 0, DB::TYPE_INT, tmpobject[oModel]);
    stmt_bind_result_field(loadprefabstmt, 1, DB::TYPE_FLOAT, tmpobject[oX]);
    stmt_bind_result_field(loadprefabstmt, 2, DB::TYPE_FLOAT, tmpobject[oY]);
    stmt_bind_result_field(loadprefabstmt, 3, DB::TYPE_FLOAT, tmpobject[oZ]);
    stmt_bind_result_field(loadprefabstmt, 4, DB::TYPE_FLOAT, tmpobject[oRX]);
    stmt_bind_result_field(loadprefabstmt, 5, DB::TYPE_FLOAT, tmpobject[oRY]);
    stmt_bind_result_field(loadprefabstmt, 6, DB::TYPE_FLOAT, tmpobject[oRZ]);
    stmt_bind_result_field(loadprefabstmt, 7, DB::TYPE_ARRAY, tmpobject[oTexIndex], MAX_MATERIALS);
    stmt_bind_result_field(loadprefabstmt, 8, DB::TYPE_ARRAY, tmpobject[oColorIndex], MAX_MATERIALS);
    stmt_bind_result_field(loadprefabstmt, 9, DB::TYPE_INT, tmpobject[ousetext]);
    stmt_bind_result_field(loadprefabstmt, 10, DB::TYPE_INT, tmpobject[oFontFace]);
    stmt_bind_result_field(loadprefabstmt, 11, DB::TYPE_INT, tmpobject[oFontSize]);
    stmt_bind_result_field(loadprefabstmt, 12, DB::TYPE_INT, tmpobject[oFontBold]);
    stmt_bind_result_field(loadprefabstmt, 13, DB::TYPE_INT, tmpobject[oFontColor]);
    stmt_bind_result_field(loadprefabstmt, 14, DB::TYPE_INT, tmpobject[oBackColor]);
    stmt_bind_result_field(loadprefabstmt, 15, DB::TYPE_INT, tmpobject[oAlignment]);
    stmt_bind_result_field(loadprefabstmt, 16, DB::TYPE_INT, tmpobject[oTextFontSize]);
    stmt_bind_result_field(loadprefabstmt, 17, DB::TYPE_STRING, tmpobject[oObjectText], MAX_TEXT_LENGTH);

	// Get the ZOffset
	new Query[128];
	new DBResult:r;
	new Float:zoff;
	format(Query, sizeof(Query), "SELECT * FROM `PrefabInfo`");
	r = db_query(PrefabDB, Query);
	db_get_field_assoc(r, "zOFF", Query, 128);
	zoff = floatstr(Query);
	db_free_result(r);

	new Float:px, Float:py, Float:pz, Float:fa;
	new time = GetTickCount();

	if(offset) GetPosFaInFrontOfPlayer(playerid, 2.0, px, py, pz, fa);
	else GetPlayerPos(playerid, px, py, pz);

	// Clear any grouped objects
    ClearGroup(playerid);

	// Execute query
    if(stmt_execute(loadprefabstmt))
    {
		db_begin_transaction(EditMap);
        while(stmt_fetch_row(loadprefabstmt))
        {
			new index = AddDynamicObject(tmpobject[oModel], tmpobject[oX]+px, tmpobject[oY]+py, tmpobject[oZ]+pz+zoff, tmpobject[oRX], tmpobject[oRY], tmpobject[oRZ]);

			// Set textures and colors
			for(new i = 0; i < MAX_MATERIALS; i++)
			{
                ObjectData[index][oTexIndex][i] = tmpobject[oTexIndex][i];
	            ObjectData[index][oColorIndex][i] = tmpobject[oColorIndex][i];
			}

			// Get all text settings
		   	ObjectData[index][ousetext] = tmpobject[ousetext];
		    ObjectData[index][oFontFace] = tmpobject[oFontFace];
		    ObjectData[index][oFontSize] = tmpobject[oFontSize];
		    ObjectData[index][oFontBold] = tmpobject[oFontBold];
		    ObjectData[index][oFontColor] = tmpobject[oFontColor];
		    ObjectData[index][oBackColor] = tmpobject[oBackColor];
		    ObjectData[index][oAlignment] = tmpobject[oAlignment];
		    ObjectData[index][oTextFontSize] = tmpobject[oTextFontSize];
		    ObjectData[index][oGroup] = 0;

			// Get any text string
			format(ObjectData[index][oObjectText], MAX_TEXT_LENGTH, "%s", tmpobject[oObjectText]);


			UpdateObject3DText(index, true);

			// Add new object to prefab
			GroupedObjects[playerid][index] = true;
			OnUpdateGroup3DText(index);

			// We need to update textures and materials
			UpdateMaterial(index);

			// Update the object text
			UpdateObjectText(index);

			// Save materials to material database
			sqlite_SaveMaterialIndex(index);

			// Save colors to material database
			sqlite_SaveColorIndex(index);

			// Save all text
			sqlite_SaveAllObjectText(index);

			SaveUndoInfo(index, UNDO_TYPE_CREATED, time);
        }
		db_end_transaction(EditMap);

   		// Update the Group GUI
		UpdatePlayerGSelText(playerid);
		stmt_close(loadprefabstmt);
        return 1;
    }
	stmt_close(loadprefabstmt);
    return 0;
}

