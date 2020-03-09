#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = 
{
	name		= "Speed Booster",
	version		= "1.0",
	description	= "Simple plugin to boost you speed",
	author		= "ღ λŌK0ЌЭŦ ღ ™",
	url			= "https://github.com/IL0co"
}

ConVar 	cvar_Enable,
		cvar_Bonus;

bool c_enable;
float cBonus;

public void OnPluginStart()
{
	HookEvent("player_jump", PlayerJumpEvent, EventHookMode_Pre);
	
	(cvar_Enable = CreateConVar("sm_booster_enable", "1", "RU: Включён ли плагин \nEN: Is plugin enabled", _, true, 0.0, true, 1.0)).AddChangeHook(OnConVarChanged);
	c_enable = cvar_Enable.BoolValue;

	(cvar_Bonus = CreateConVar("sm_booster_bonus", "30", "RU: Бонус к скорости (юнитов/прыжок) \nEN: Speed Bonus (Units/Jump)", _)).AddChangeHook(OnConVarChanged);
	cBonus = cvar_Bonus.FloatValue;

	AutoExecConfig(true, "speed_booster");
}

public void OnConVarChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	if(cvar == cvar_Enable)
		c_enable = cvar_Enable.BoolValue;
	else if(cvar == cvar_Bonus)
		cBonus = cvar_Bonus.FloatValue;
}

public void PlayerJumpEvent(Event event, const char[] name, bool dontBroadcast)
{
	if(!c_enable || cBonus == 0.0)
		return;
	
	int client = GetClientOfUserId(event.GetInt("userid"));

	if(!IsClientInGame(client))
		return;

	CreateTimer(0.1, Timer_Delay, GetClientUserId(client));
}

public Action Timer_Delay(Handle timer, int client)
{
	client = GetClientOfUserId(client);

	RequestFrame(BonusVelocity, GetClientUserId(client));
}

void BonusVelocity(any data)
{
	int client = GetClientOfUserId(data);

	if(!IsClientInGame(client)) 
		return;
	
	if(data != 0)
	{
		float iAbsVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", iAbsVelocity);
		
		float fCurrentSpeed = SquareRoot(Pow(iAbsVelocity[0], 2.0) + Pow(iAbsVelocity[1], 2.0));
		
		if(fCurrentSpeed > 0.0)
		{
			float x = fCurrentSpeed / (fCurrentSpeed + cBonus);
			iAbsVelocity[0] /= x;
			iAbsVelocity[1] /= x;
			
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, iAbsVelocity);
		}
	}
}