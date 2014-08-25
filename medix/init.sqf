// Wait for player to spawn
waitUntil {alive player};
sleep 1;

MEDIX_ACTIVE = false;
MEDIX_ABORT = false;

// Load properties
[] execVM "medix\properties.sqf";

// Setup effects
[] execVM "medix\effects.sqf";


// Functions
MEDIX_FNC_BLEED = {
	while {1==1} do {
		if (MEDIX_ACTIVE) then {
			_bleedSpeed = (MEDIX_PRP_BLEEDSPEED/100);
			if (player getVariable "MEDIX_ISSTABILIZED") then {
				_bleedSpeed = _bleedSpeed * (1/MEDIX_PRP_STABILIZEEFFECT);
			};
			if (player getVariable "MEDIX_ISPRESSURE") then {
				_bleedSpeed = _bleedSpeed * (1/MEDIX_PRP_PRESSUREDEFFECT);
			};

			if (player getVariable "MEDIX_ISBLEEDING") then {
				// hint format["I'm bleeding! Dmg: %1", damage player];
				MEDIX_CACHE_DAMAGE = MEDIX_CACHE_DAMAGE+_bleedSpeed;
				player setDamage MEDIX_CACHE_DAMAGE;
			};
		} else {
			// hint "Medix not active!";
		};
		sleep 1;
	};
};

F_MEDIX_SwitchMoveEverywhere = compileFinal "_this select 0 switchMove (_this select 1);";
F_MEDIX_PlayMoveEverywhere = compileFinal "_this select 0 playMoveNow (_this select 1);";
F_MEDIX_SetCaptive = compileFinal "_this select 0 setcaptive (_this select 1);";

MEDIX_ADDACTION =
{
	private["_object","_actionName","_actionFunc", "_actionIdVariable", "_actionPriority", "_actionCondition"];
	_object = _this select 0;
	_actionName = _this select 1;
	_actionFunc = _this select 2;
	_actionIdVariable = _this select 3;
	_actionPriority = _this select 4;
	_actionCondition = _this select 5;
	if(isNull _object) exitWith {};

	if (_object getVariable _actionIdVariable > -1) then {
		_object removeAction (_object getVariable _actionIdVariable);
	};

	_actionId = _object addAction [_actionName, _actionFunc, nil, _actionPriority, true, true, "", _actionCondition];
	_object setVariable [_actionIdVariable, _actionId, false];
	// hint format["Created new action %1, with id: %2", _actionIdVariable, _actionId];
};

MEDIX_REMOVEACTION = {
	_object = _this select 0;
	_actionIdVariable = _this select 1;
	_actionId = _object getVariable _actionIdVariable;
	// hint format["Remove action:\nIDVAR: %1\nID: %2\n", _object, _actionId];
	_object removeAction _actionId;
	_object setVariable [_actionIdVariable, -1, false];
};

MEDIX_ACTION_ABORT = {
	[[player, "AinvPknlMstpSnonWrflDnon_medicEnd"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP;
	player enableSimulation true;
	MEDIX_ABORT = true;
};

MEDIX_FNC_CHECKPULSE = {
	_actionObject = _this select 0;

	_msg = "The pulse is strong";
	if (damage _actionObject > 1-(MEDIX_PRP_PULSEWEAK/100)) then { _msg = "The pulse is weak "; };
	if (damage _actionObject > 1-(MEDIX_PRP_PULSEEXTREMELYWEAK/100)) then { _msg = "The pulse is extremely weak "; };
	if (damage _actionObject == 1) then { _msg = "There is no pulse"; };
	hint _msg;

	if (damage _actionObject < 1) then {
		if (!(_actionObject getVariable "MEDIX_ISSTABILIZED")) then {
			[[_actionObject, "<t color='#FF5503'>First Aid</t>", MEDIX_FNC_STABILIZE, "MEDIX_ACT_ID_STABILIZE", 29, "_target != player && (""FirstAidKit"" in (items player)) && !MEDIX_PERFORMING_ACTION && ((player distance _target) < MEDIX_PRP_TREATRANGE) && !(player getVariable ""MEDIX_ISBLEEDING"")"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
		};
		if ((_actionObject getVariable "MEDIX_ACT_ID_DRAGRELEASE") == -1) then {
			[[_actionObject, "<t color='#FF9903'>Drag</t>", MEDIX_FNC_DRAG, "MEDIX_ACT_ID_DRAG", 28, "_target != player && !MEDIX_PERFORMING_ACTION && ((player distance _target) < MEDIX_PRP_TREATRANGE) && !(player getVariable ""MEDIX_ISBLEEDING"")"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
		};
		if ((_actionObject getVariable "MEDIX_ACT_ID_PRESSURERELEASE") == -1) then {
			[[_actionObject, "<t color='#FF9903'>Direct Pressure</t>", MEDIX_FNC_PRESSURE, "MEDIX_ACT_ID_PRESSURE", 27, "_target != player && !MEDIX_PERFORMING_ACTION && ((player distance _target) < MEDIX_PRP_TREATRANGE) && !(player getVariable ""MEDIX_ISBLEEDING"")"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
		};
	} else {
		[[_actionObject, "MEDIX_ACT_ID_HEAL"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_CHECKPULSE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_STABILIZE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_FULLTREATMENT"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_DRAG"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_DRAGRELEASE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_PRESSURE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_PRESSURERELEASE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
	};
};

MEDIX_FNC_STABILIZE = {
	_actionObject = _this select 0;

	// Exit if player missing FirstAidKit
	if (!("FirstAidKit" in (items player))) exitWith { hint "You need a First Aid Kit"; };

	MEDIX_TREATINGUNIT = _actionObject;

	MEDIX_PERFORMING_ACTION = true;

	[player, "<t color='#FF9903'>Abort action</t>", MEDIX_ACTION_ABORT, "MEDIX_ACT_ID_ABORT", 31, ""] spawn MEDIX_ADDACTION;

	// Stabilize animation sequence
	MEDIX_ABORT = false;
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic0"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 3.225; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic1"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 3.846; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic2"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 4.263; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medicEnd"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 2.000; };

	[player, "MEDIX_ACT_ID_ABORT"] spawn MEDIX_REMOVEACTION;

	if (!MEDIX_ABORT) then {
		MEDIX_TREATINGUNIT setVariable ["MEDIX_ISSTABILIZED", true, true];

		// Remove a first aid kit
		player removeItem "FirstAidKit";

		MEDIX_EVT_STABILIZED = [MEDIX_TREATINGUNIT, player];
		publicVariable "MEDIX_EVT_STABILIZED";

		[[_actionObject, "MEDIX_ACT_ID_STABILIZE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "<t color='#FF2203'>Full Medical Treament</t>", MEDIX_FNC_TREAT, "MEDIX_ACT_ID_FULLTREATMENT", 30, "_target != player && (""FirstAidKit"" in (items player)) && (""Medikit"" in (items player)) && !MEDIX_PERFORMING_ACTION && ((player distance _target) < MEDIX_PRP_TREATRANGE) && !(player getVariable ""MEDIX_ISBLEEDING"")"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
	};

	MEDIX_PERFORMING_ACTION = false;
};

MEDIX_FNC_TREAT = {
	_actionObject = _this select 0;

	// Exit if player missing FirstAidKit+Medikit
	if (!("FirstAidKit" in (items player))) exitWith { hint "You need a First Aid Kit"; };
	if (!("Medikit" in (items player))) exitWith { hint "You need a Medikit"; };

	MEDIX_TREATINGUNIT = _actionObject;

	MEDIX_PERFORMING_ACTION = true;

	[player, "<t color='#FF9903'>Abort action</t>", MEDIX_ACTION_ABORT, "MEDIX_ACT_ID_ABORT", 31, ""] spawn MEDIX_ADDACTION;

	// Full medical treatment animation sequence
	MEDIX_ABORT = false;
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic0"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 3.225; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic1"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 3.846; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic2"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 4.263; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic3"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 5.000; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic4"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 7.692; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic0"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 3.225; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic1"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 3.846; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic3"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 5.000; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medicEnd"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 2.000; };

	[player, "MEDIX_ACT_ID_ABORT"] spawn MEDIX_REMOVEACTION;

	if (!MEDIX_ABORT) then {
		MEDIX_TREATINGUNIT setVariable ["MEDIX_ISBLEEDING", false, true];

		// Remove a first aid kit
		player removeItem "FirstAidKit";

		MEDIX_EVT_TREATED = [MEDIX_TREATINGUNIT, player];
		publicVariable "MEDIX_EVT_TREATED";

		[[_actionObject, "MEDIX_ACT_ID_HEAL"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_CHECKPULSE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_STABILIZE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_FULLTREATMENT"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_DRAG"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_DRAGRELEASE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_PRESSURE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_PRESSURERELEASE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
	};
	
	MEDIX_PERFORMING_ACTION = false;
};

MEDIX_FNC_UNCONSCIOUS = {
	_unit = _this select 0;
	_unit playAction "Unconscious";

	MEDIX_UNCONSCIOUS_UNIT = _unit;
	[[MEDIX_UNCONSCIOUS_UNIT, true], "F_MEDIX_SetCaptive"] call BIS_fnc_MP;
	if (_unit == player) then {
		[[player, "<t color='#FF9903'>Check pulse</t>", MEDIX_FNC_CHECKPULSE, "MEDIX_ACT_ID_CHECKPULSE", 26, "_target != player && !MEDIX_PERFORMING_ACTION && ((player distance _target) < MEDIX_PRP_TREATRANGE) && !(player getVariable ""MEDIX_ISBLEEDING"")"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
		sleep 2;
		player enableSimulation false;
	};
};

MEDIX_FNC_DRAG = {
	_actionObject = _this select 0;

	MEDIX_PERFORMING_ACTION = true;
	player playMoveNow "AcinPknlMstpSrasWrflDnon";

	_actionObject switchMove "AinjPpneMstpSnonWrflDb";
	MEDIX_EVT_DRAGGED = [_actionObject, player];
	publicVariable "MEDIX_EVT_DRAGGED";
	[[_actionObject, "MEDIX_ACT_ID_DRAG"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
	[player, "<t color='#FF9903'>Release</t>", MEDIX_FNC_RELEASE, "MEDIX_ACT_ID_DRAGRELEASE", 31, ""] spawn MEDIX_ADDACTION;
	MEDIX_DRAGGINGUNIT = _actionObject;
};

MEDIX_FNC_RELEASE = {
	_actionObject = _this select 0;

	MEDIX_PERFORMING_ACTION = false;
	player playMoveNow "amovpknlmstpsraswrfldnon";
	MEDIX_EVT_RELEASED = [MEDIX_DRAGGINGUNIT, player];
	publicVariable "MEDIX_EVT_RELEASED";
	[player, "MEDIX_ACT_ID_DRAGRELEASE"] spawn MEDIX_REMOVEACTION;
	[[MEDIX_DRAGGINGUNIT, "<t color='#FF9903'>Drag</t>", MEDIX_FNC_DRAG, "MEDIX_ACT_ID_DRAG", 28, "_target != player && !MEDIX_PERFORMING_ACTION && ((player distance _target) < MEDIX_PRP_TREATRANGE) && !(player getVariable ""MEDIX_ISBLEEDING"")"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
	MEDIX_DRAGGINGUNIT = nil;
};

MEDIX_FNC_PRESSURE = {
	_actionObject = _this select 0;

	MEDIX_PERFORMING_ACTION = true;
	MEDIX_PRESSUREUNIT = _actionObject;
	MEDIX_PRESSUREUNIT setVariable ["MEDIX_ISPRESSURE", true, true];
	player switchMove "AinvPknlMstpSnonWrflDnon_medic0s";
	// hint format["Is pressuring"];
	waitUntil { (animationState player != "AinvPknlMstpSnonWrflDnon_medic0s") };
	MEDIX_PRESSUREUNIT setVariable ["MEDIX_ISPRESSURE", false, true];
	MEDIX_PERFORMING_ACTION = false;
	// hint format["Stopped pressuring"];
};

MEDIX_FNC_STOPPRESSURE = {
	_actionObject = _this select 0;

	player enableSimulation true;
	player enableSimulation false;
	player enableSimulation true;
	[[player, "AinvPknlMstpSnonWrflDnon_medicEnd"], "F_MEDIX_PlayMoveEverywhere"] call BIS_fnc_MP; sleep 0.525;

	MEDIX_PERFORMING_ACTION = false;
	MEDIX_PRESSUREUNIT setVariable ["MEDIX_ISPRESSURE", false, true];
	[player, "MEDIX_ACT_ID_PRESSURERELEASE"] spawn MEDIX_REMOVEACTION;
	[[MEDIX_PRESSUREUNIT, "<t color='#FF9903'>Direct Pressure</t>", MEDIX_FNC_PRESSURE, "MEDIX_ACT_ID_PRESSURE", 27, "_target != player && !MEDIX_PERFORMING_ACTION && ((player distance _target) < MEDIX_PRP_TREATRANGE) && !(player getVariable ""MEDIX_ISBLEEDING"")"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
	MEDIX_PRESSUREUNIT = nil;
};

// Spawn threads
[] spawn MEDIX_FNC_BLEED;

MEDIX_ANIMVIEWER = {
	[] call bis_fnc_animviewer;
};

MEDIX_SUICIDE = {
	MEDIX_CACHE_DAMAGE = 1;
};

while {true} do
{
	// Wait for player to spawn
	waitUntil {alive player};
	sleep 1;

	// Reset the player variables to default on spawn/respawn
	player setVariable ["MEDIX_ACT_ID_HEAL", -1, true];
	player setVariable ["MEDIX_ACT_ID_CHECKPULSE", -1, true];
	player setVariable ["MEDIX_ACT_ID_STABILIZE", -1, true];
	player setVariable ["MEDIX_ACT_ID_FULLTREATMENT", -1, true];
	player setVariable ["MEDIX_ACT_ID_DRAG", -1, true];
	player setVariable ["MEDIX_ACT_ID_DRAGRELEASE", -1, true];
	player setVariable ["MEDIX_ACT_ID_PRESSURE", -1, true];
	player setVariable ["MEDIX_ACT_ID_PRESSURERELEASE", -1, true];
	player setVariable ["MEDIX_ACT_ID_ABORT", -1, true];
	player setVariable ["MEDIX_ISBLEEDING", false, true];
	player setVariable ["MEDIX_ISSTABILIZED", false, true];
	player setVariable ["MEDIX_ISPRESSURE", false, true];
	player setVariable ["MEDIX_ISKILLED", false, true];
	player setVariable ["MEDIX_EVT_DRAGGED", false, true];
	player setVariable ["MEDIX_EVT_ISKILLED", false, true];
	MEDIX_DRAGGINGUNIT = nil;
	MEDIX_TREATINGUNIT = nil;
	MEDIX_PRESSUREUNIT = nil;
	MEDIX_PERFORMING_ACTION = false;
	MEDIX_CACHE_DAMAGE = 0;

	// Make sure postprocesses are to default on respawn
	MEDIX_EFFECT1 ppEffectAdjust [0.0];
	MEDIX_EFFECT1 ppEffectCommit 2;
	MEDIX_EFFECT2 ppEffectAdjust [1.0, 1.0, 0.0, [0.0, 0.0, 0.0, 0.0], [0.0, 1.0, 1.0, 1.0], [0.0, 0.0, 0.0, 0.0]];
	MEDIX_EFFECT2 ppEffectCommit 2;

	player addAction ["Suicide", MEDIX_SUICIDE, nil, 1, true, true, "", "_target == player && (player getVariable ""MEDIX_ISBLEEDING"")"];
	
	// Load handlers
	[] execVM "medix\handlers.sqf";

	// Activate Medix
	MEDIX_ACTIVE = true;
	hint format["Medix wounding system 1.5"];

	// The loop waits here until the player have died.
	waitUntil { sleep 0.5; !alive player};

	// Inactivate Medix
	MEDIX_ACTIVE = false;
};
