MEDIX_EVT_CARRY = {
	_actionObject = _this select 0;
	_carrier = _actionObject;
	player enableSimulation true;
	player playMoveNow "ainjppnemstpsnonwrfldnon_rolltoback";
	waitUntil { animationState player == "ainjppnemstpsnonwrfldnon_rolltoback" };
	player setVariable ["MEDIX_ANI_READY", true, true];

	waitUntil { (_carrier getVariable "MEDIX_ANI_READY") };
	sleep 1;
	player attachTo [_carrier, [0.35, 0.1, 0] ]; 
	// player setDir 180;
	player setVariable ["MEDIX_CACHE_UNCONSCIOUS_DIRECTION", 180, true];

	player playMoveNow "AinjPfalMstpSnonWrflDnon_carried_up";
	waitUntil { animationState player == "AinjPfalMstpSnonWrflDnon_carried_still" };
	player attachTo [_carrier, [0.15, 0.1, 0] ]; 
	// player setDir 0;
	player setVariable ["MEDIX_CACHE_UNCONSCIOUS_DIRECTION", 0, true];
};

MEDIX_EVT_CARRYRELEASE = {
	_carrier = _this select 0;
	player playMoveNow "AinjPfalMstpSnonWrflDnon_carried_down";
	waitUntil { animationState player == "AinjPpneMstpSnonWrflDnon" };
	detach player;
	player setVariable ["MEDIX_CACHE_UNCONSCIOUS_DIRECTION", (direction _carrier)+180, true];
};

// Public Event handlers
"MEDIX_EVT_TREATED" addPublicVariableEventHandler {
	_treated = (_this select 1 select 0);
	_treater = (_this select 1 select 1);
	if (_treated == player) then {
		MEDIX_CACHE_DAMAGE = 1-(MEDIX_PRP_TREATRESULT/100);
		player setDamage MEDIX_CACHE_DAMAGE;
		player enableSimulation true;
		player playAction "AgonyStop";
		hint format["You have been fully treated by %1", name _treater];
		MEDIX_EFFECT1 ppEffectAdjust [0.0];
		MEDIX_EFFECT1 ppEffectCommit 5;
		MEDIX_EFFECT2 ppEffectAdjust [1.0, 1.0, 0.0, [0.0, 0.0, 0.0, 0.0], [0.0, 1.0, 1.0, 1.0], [0.0, 0.0, 0.0, 0.0]];
		MEDIX_EFFECT2 ppEffectCommit 5;

		[[player, false], "MEDIX_FNC_SETCAPTIVE"] call BIS_fnc_MP;

		// Restore TFAR voice range to normal
		if (MEDIX_PRP_TFAR > 0) then { 20 call TFAR_fnc_setVoiceVolume; };
		if (MEDIX_PRP_TFAR > 1) then { player setVariable ["tf_unable_to_use_radio", false, true]; };
	};
};

"MEDIX_EVT_STABILIZED" addPublicVariableEventHandler {
	_treated = (_this select 1 select 0);
	_treater = (_this select 1 select 1);
	if (_treated == player) then {
		hint format["You received first aid by %1", name _treater];
	};
};

"MEDIX_EVT_UNCONSCIOUS" addPublicVariableEventHandler {
	_unconscious = (_this select 1 select 0);
	[_unconscious] spawn MEDIX_FNC_UNCONSCIOUS;
};

"MEDIX_EVT_DRAGGED" addPublicVariableEventHandler {
	_dragged = (_this select 1 select 0);
	_dragger = (_this select 1 select 1);
	_dragged attachTo [_dragger, [0, 1.1, 0.092]];
	_dragged switchMove "AinjPpneMstpSnonWrflDb";
	// _dragged setDir 180;

	if (_dragged == player) then {
		player setVariable ["MEDIX_CACHE_UNCONSCIOUS_DIRECTION", 180, true];
		player enableSimulation false;
	};
};

"MEDIX_EVT_RELEASED" addPublicVariableEventHandler {
	_dragged = (_this select 1 select 0);
	_dragger = (_this select 1 select 1);
	detach _dragged;
	if (_dragged == player) then {
		_dragged enableSimulation true;
		_dragged enableSimulation false;
		_dragged enableSimulation true;

		MEDIX_EVT_UNCONSCIOUS = [_dragged];
		publicVariable "MEDIX_EVT_UNCONSCIOUS";
		[_dragged] spawn MEDIX_FNC_UNCONSCIOUS;
	};
};

"MEDIX_EVT_ISKILLED" addPublicVariableEventHandler {
	_killed = (_this select 1 select 0);

	if (!isNil "MEDIX_DRAGGINGUNIT") then {
		if (MEDIX_DRAGGINGUNIT == _killed) then {
			[] spawn MEDIX_FNC_RELEASE;
		};
	};

	if (!isNil "MEDIX_TREATINGUNIT") then {
		if (MEDIX_TREATINGUNIT == _killed) then {
			hint format["%1 died in your hands", (MEDIX_TREATINGUNIT getVariable "MEDIX_DOGTAG")];
			[] spawn MEDIX_ACTION_ABORT;
		};
	};
};

"MEDIX_EVT_MOVEDINTOCARGO" addPublicVariableEventHandler {
	_player = (_this select 1 select 0);
	_vehicle = (_this select 1 select 1);
	if (_player == player) then {
		player enableSimulation true;
		_player moveInCargo _vehicle;
		[] spawn MEDIX_EVT_UNCONSCIOUSINVEHICLE;
	};
};

"MEDIX_EVT_CARRIED_UP" addPublicVariableEventHandler {
	_carrier = (_this select 1 select 0);
	_carrying = (_this select 1 select 1);
	if (_carrying == player) then {
		[_carrier] spawn MEDIX_EVT_CARRY;
	};
};

"MEDIX_EVT_CARRIED_DOWN" addPublicVariableEventHandler {
	_carrier = (_this select 1 select 0);
	_carrying = (_this select 1 select 1);
	if (_carrying == player) then {
		[_carrier] spawn MEDIX_EVT_CARRYRELEASE;
	};
};

MEDIX_EVT_UNCONSCIOUSINVEHICLE = {
	sleep 1;
	waitUntil { vehicle player == player };
	sleep 1;
	MEDIX_EVT_UNCONSCIOUS = [player];
	publicVariable "MEDIX_EVT_UNCONSCIOUS";
	[player] spawn MEDIX_FNC_UNCONSCIOUS;
};

// Local Event Handlers
MEDIX_EVT_HANDLEDAMAGE = {
	MEDIX_CACHE_DAMAGE = damage player;
	if (player getVariable "MEDIX_ISBLEEDING") exitWith {};

	_hitDmg = _this select 2;

	if (damage player > (MEDIX_PRP_MAXDAMAGE/100)) then {
		player setVariable ["MEDIX_ISBLEEDING", true, true];
		player setVariable ["MEDIX_ISSTABILIZED", false, true];

		// Check if player is inside a vehicle
		_playerInVehicle = nil;
	    {
	    	_vehicle = _x;
	    	if (player in _vehicle) then {
	    		_playerInVehicle = _vehicle;
	    	};
	    } forEach vehicles;
	    if (!isNil "_playerInVehicle") then {
	    	// If player is inside a vehicle, spawn a thread that waits until the player has left the vehicle, then put unconscious
	    	[] spawn MEDIX_EVT_UNCONSCIOUSINVEHICLE;
	    } else {
	    	// If player is not in a vehicle, put unconscious
			MEDIX_EVT_UNCONSCIOUS = [player];
			publicVariable "MEDIX_EVT_UNCONSCIOUS";
			[player] spawn MEDIX_FNC_UNCONSCIOUS;
	    };
	};

	_hitPart = _this select 1;
	_source = _this select 3;

	if ((player distance _source) > MEDIX_PRP_HELMDEFLECTDISTANCE) then {
		if (_hitPart == "head" || _hitPart == "") then {
			if (_hitDmg > 0.8) then {
				_rand = random 1;
				if (_rand > (1-(MEDIX_PHP_HELMDEFLECTCHANCE/100))) then {
					_hitDmg = (damage player) + (MEDIX_PRP_HELMDEFLECTDMG/100);
					[] spawn MEDIX_EFX_HELMETHIT;
				};
			};
		};
	};
	_hitDmg;
};
player addEventHandler ["HandleDamage", MEDIX_EVT_HANDLEDAMAGE];

MEDIX_EVT_KILLED = {
	MEDIX_EVT_ISKILLED = [player];
	publicVariable "MEDIX_EVT_ISKILLED";
	MEDIX_EFFECT1 ppEffectAdjust [0.0];
	MEDIX_EFFECT1 ppEffectCommit 5;
	MEDIX_EFFECT2 ppEffectAdjust [1.0, 1.0, 0.0, [0.0, 0.0, 0.0, 0.0], [0.0, 1.0, 1.0, 1.0], [0.0, 0.0, 0.0, 0.0]];
	MEDIX_EFFECT2 ppEffectCommit 5;
	MEDIX_CACHE_DAMAGE = 0;
	MEDIX_ACTIVE = false;

	[[player, "MEDIX_ACT_ID_HEAL"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
	[[player, "MEDIX_ACT_ID_STABILIZE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
	[[player, "MEDIX_ACT_ID_FULLTREATMENT"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
	[[player, "MEDIX_ACT_ID_DRAG"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
	[[player, "MEDIX_ACT_ID_DRAGRELEASE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
	[[player, "MEDIX_ACT_ID_PRESSURE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
	[[player, "MEDIX_ACT_ID_PRESSURERELEASE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
	[[player, "MEDIX_ACT_ID_CARRY"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
	[[player, "MEDIX_ACT_ID_CARRYRELEASE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
};
player addEventHandler ["killed", MEDIX_EVT_KILLED];
