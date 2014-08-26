// Wait for player to spawn
waitUntil {alive player};
sleep 1;

MEDIX_ACTIVE = false;

MEDIX_FNC_SWITCHMOVE = compileFinal "_this select 0 switchMove (_this select 1);";
MEDIX_FNC_PLAYMOVENOW = compileFinal "_this select 0 playMoveNow (_this select 1);";
MEDIX_FNC_SETCAPTIVE = compileFinal "_this select 0 setcaptive (_this select 1);";

[] execVM "medix\properties.sqf";
[] execVM "medix\effects.sqf";
[] execVM "medix\actionmenu.sqf";
[] execVM "medix\actions.sqf";

MEDIX_FNC_BLEED = {
	while {1==1} do {
		if (MEDIX_ACTIVE) then {
			_bleedSpeed = (MEDIX_PRP_BLEEDSPEED/100);
			if (player getVariable "MEDIX_ISSTABILIZED") then { _bleedSpeed = _bleedSpeed * (1/MEDIX_PRP_STABILIZEEFFECT); };
			if (player getVariable "MEDIX_ISPRESSURE") then { _bleedSpeed = _bleedSpeed * (1/MEDIX_PRP_PRESSUREDEFFECT); };
			if (player getVariable "MEDIX_ISBLEEDING") then {
				MEDIX_CACHE_DAMAGE = MEDIX_CACHE_DAMAGE+_bleedSpeed;
				player setDamage MEDIX_CACHE_DAMAGE;
				hint format["I'm bleeding, dmg: %1", MEDIX_CACHE_DAMAGE];
			};
		};
		sleep 1;
	};
};
[] spawn MEDIX_FNC_BLEED;

while {true} do
{
	// Wait for player to spawn
	waitUntil {alive player};
	sleep 1;

	// Reset all variables to default
	[] execVM "medix\reset.sqf";

	// Activate Medix
	MEDIX_ACTIVE = true;
	hint format["Medix wounding system 1.6"];

	// The loop waits here until the player have died.
	waitUntil { sleep 0.5; !alive player};

	// Inactivate Medix
	MEDIX_ACTIVE = false;
};
