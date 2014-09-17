// Wait for player to spawn
waitUntil {alive player};
sleep 1;

MEDIX_ACTIVE = false;

MEDIX_FNC_SWITCHMOVE = compileFinal "_this select 0 switchMove (_this select 1);";
MEDIX_FNC_PLAYMOVENOW = compileFinal "_this select 0 playMoveNow (_this select 1);";
MEDIX_FNC_SETCAPTIVE = compileFinal "_this select 0 setcaptive (_this select 1);";

// Enable screen effects
MEDIX_EFFECT1 = ppEffectCreate ["dynamicBlur", 505];
MEDIX_EFFECT1 ppEffectEnable true;
MEDIX_EFFECT2 = ppEffectCreate ["colorCorrections", 1501];
MEDIX_EFFECT2 ppEffectEnable true;

[] execVM "medix\properties.sqf";
[] execVM "medix\reset.sqf";
[] execVM "medix\effects.sqf";
[] execVM "medix\actionmenu.sqf";
[] execVM "medix\actions.sqf";

MEDIX_PRP_TFAR = (_this select 0);

MEDIX_FNC_BLEED = {
	while {1==1} do {
		if (MEDIX_ACTIVE) then {
			_bleedSpeed = (MEDIX_PRP_BLEEDSPEED/100);
			if (player getVariable "MEDIX_ISSTABILIZED") then { _bleedSpeed = _bleedSpeed * (1/MEDIX_PRP_STABILIZEEFFECT); };
			if (player getVariable "MEDIX_ISPRESSURE") then { _bleedSpeed = _bleedSpeed * (1/MEDIX_PRP_PRESSUREDEFFECT); };
			if (player getVariable "MEDIX_ISBLEEDING") then {
				MEDIX_CACHE_DAMAGE = MEDIX_CACHE_DAMAGE+_bleedSpeed;
				player setDamage MEDIX_CACHE_DAMAGE;
				// hint format["I'm bleeding, dmg: %1", MEDIX_CACHE_DAMAGE];

				// Lower your voice in TFAR
				if (MEDIX_PRP_TFAR > 0) then { 5 call TFAR_fnc_setVoiceVolume; };
				if (MEDIX_PRP_TFAR > 1) then { player setVariable ["tf_unable_to_use_radio", true, true]; };
				if (MEDIX_PRP_TFAR > 2) then { 0.1 call TFAR_fnc_setVoiceVolume; };
			};
		};
		sleep 1;
	};
};
[] spawn MEDIX_FNC_BLEED;

MEDIX_FNC_UNCONSCIOUS_ACTIONS_DISABLE = {
	while {1==1} do {
		if (player getVariable "MEDIX_ISBLEEDING") then {
			if (alive player && !(player getVariable "MEDIX_ISDRAGGED") && !(player getVariable "MEDIX_ISCARRIED")) then {
				// hint format["Updating Animation: %1", time];
				waitUntil { animationstate player != "AinjPpneMstpSnonWrflDnon"};
				if (player getVariable "MEDIX_ISBLEEDING") then {
					player playMoveNow "AinjPpneMstpSnonWrflDnon";
				};
				sleep 0.1;
			};
		} else {
			sleep 1;
		};
	};
};
[] spawn MEDIX_FNC_UNCONSCIOUS_ACTIONS_DISABLE;

MEDIX_FNC_UNCONSCIOUS_ROTATION_DISABLE = {
	while {1==1} do {
		if (player getVariable "MEDIX_ISBLEEDING") then {
			player setDir (player getVariable "MEDIX_CACHE_UNCONSCIOUS_DIRECTION");
			waitUntil { (player getVariable "MEDIX_CACHE_UNCONSCIOUS_DIRECTION") != direction player };
		} else {
			sleep 1;
		};
	};
};
[] spawn MEDIX_FNC_UNCONSCIOUS_ROTATION_DISABLE;

// MEDIX_ANIM = {
// 	[] call BIS_fnc_animViewer;
// };
// player addAction ["Anim", MEDIX_ANIM];

while {true} do
{
	// Wait for player to spawn
	waitUntil {alive player};
	sleep 1;

	// Reset all variables to default
	player addAction ["<t color='#FF9903'>Suicide</t>", MEDIX_FNC_SUICIDE, nil, 1, true, true, "", "_target == player && (player getVariable ""MEDIX_ISBLEEDING"")"];
	[] execVM "medix\reset.sqf";

	// Activate Medix
	MEDIX_ACTIVE = true;
	hint format["Medix wounding system 1.7"];

	// The loop waits here until the player have died.
	waitUntil { sleep 0.5; !alive player};

	// Inactivate Medix
	MEDIX_ACTIVE = false;
};
