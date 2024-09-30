#if defined ALLOBJECTS
	#endinput
#endif
#define ALLOBJECTS

new DB:AO_DB, DBResult:AO_RESULT;

public OnFilterScriptInit()
{
	if((AO_DB = db_open("tstudio/allbuildings.db")) == DB:0)
		print("Todos os edifícios - Falha no carregamento (não foi possível abrir o banco de dados).");
	#if defined AO_OnFilterScriptInit
		AO_OnFilterScriptInit();
	#endif
	return 1;
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit AO_OnFilterScriptInit
#if defined AO_OnFilterScriptInit
	forward AO_OnFilterScriptInit();
#endif

#define SEARCH_DATA_SIZE (44763)
