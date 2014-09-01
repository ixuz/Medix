MEDIX_ACTION_ABORT = {
	[[player, "AinvPknlMstpSnonWrflDnon_medicEnd"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP;
	player enableSimulation true;
	MEDIX_ABORT = true;
	MEDIX_TREATINGUNIT = nil;
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
		if ((_actionObject getVariable "MEDIX_ACT_ID_CARRYRELEASE") == -1) then {
			[[_actionObject, "<t color='#FF9903'>Carry</t>", MEDIX_ACT_CARRY, "MEDIX_ACT_ID_CARRY", 28, "_target != player && !MEDIX_PERFORMING_ACTION && ((player distance _target) < MEDIX_PRP_TREATRANGE) && !(player getVariable ""MEDIX_ISBLEEDING"")"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
		};
		if ((_actionObject getVariable "MEDIX_ACT_ID_PRESSURERELEASE") == -1) then {
			[[_actionObject, "<t color='#FF9903'>Direct Pressure</t>", MEDIX_FNC_PRESSURE, "MEDIX_ACT_ID_PRESSURE", 27, "_target != player && !MEDIX_PERFORMING_ACTION && ((player distance _target) < MEDIX_PRP_TREATRANGE) && !(player getVariable ""MEDIX_ISBLEEDING"")"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
		};
	} else {
		[[_actionObject, "<t color='#FF9903'>Take Dog Tag</t>", MEDIX_FNC_DOGTAG, "MEDIX_ACT_ID_DOGTAG", 29, "_target != player && ((player distance _target) < MEDIX_PRP_TREATRANGE)"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_HEAL"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_CHECKPULSE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_STABILIZE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_FULLTREATMENT"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_DRAG"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_DRAGRELEASE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_PRESSURE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_PRESSURERELEASE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_CARRY"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_CARRYRELEASE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
	};
};

MEDIX_FNC_STABILIZE = {
	_actionObject = _this select 0;

	// Exit if player missing FirstAidKit
	if (!("FirstAidKit" in (items player))) exitWith { hint "You need a First Aid Kit"; };

	MEDIX_TREATINGUNIT = _actionObject;

	MEDIX_PERFORMING_ACTION = true;

	hint "Moving will cancel treatment";

	// Stabilize animation sequence
	_treatmentStartedAtTime = time;
	_treatmentDuration = 14;
	_treatmentCompletedAtTime = (_treatmentStartedAtTime+_treatmentDuration);
	player switchMove "AinvPknlMstpSnonWrflDnon_medic0s";

	waitUntil { ((animationState player != "AinvPknlMstpSnonWrflDnon_medic0s") || (time >= _treatmentCompletedAtTime) || MEDIX_ABORT) };
	[[player, "AinvPercMstpSnonWrflDnon"], "MEDIX_FNC_SWITCHMOVENOW"] call BIS_fnc_MP;

	// Check whether the treatment was completed or aborted
	_treatment_completed = false;
	if ((time >= _treatmentCompletedAtTime)) then { _treatment_completed = true; };

	if (_treatment_completed) then {
		MEDIX_TREATINGUNIT setVariable ["MEDIX_ISSTABILIZED", true, true];

		// Remove a first aid kit
		player removeItem "FirstAidKit";

		MEDIX_EVT_STABILIZED = [MEDIX_TREATINGUNIT, player];
		publicVariable "MEDIX_EVT_STABILIZED";

		[[_actionObject, "MEDIX_ACT_ID_STABILIZE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "<t color='#FF2203'>Full Medical Treament</t>", MEDIX_FNC_TREAT, "MEDIX_ACT_ID_FULLTREATMENT", 30, "_target != player && (""FirstAidKit"" in (items player)) && (""Medikit"" in (items player)) && !MEDIX_PERFORMING_ACTION && ((player distance _target) < MEDIX_PRP_TREATRANGE) && !(player getVariable ""MEDIX_ISBLEEDING"")"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
		hint format["You have treated %1", (MEDIX_TREATINGUNIT getVariable "MEDIX_DOGTAG")];
	}
	else
	{
		hint "Treatment aborted";
	};

	MEDIX_PERFORMING_ACTION = false;
	MEDIX_TREATINGUNIT = nil;
	MEDIX_ABORT = false;
};

MEDIX_FNC_TREAT = {
	_actionObject = _this select 0;

	// Exit if player missing FirstAidKit+Medikit
	if (!("FirstAidKit" in (items player))) exitWith { hint "You need a First Aid Kit"; };
	if (!("Medikit" in (items player))) exitWith { hint "You need a Medikit"; };

	MEDIX_TREATINGUNIT = _actionObject;

	MEDIX_PERFORMING_ACTION = true;

	hint "Moving will cancel treatment";

	// Full medical treatment animation sequence
	_treatmentStartedAtTime = time;
	_treatmentDuration = 38;
	_treatmentCompletedAtTime = (_treatmentStartedAtTime+_treatmentDuration);
	player switchMove "AinvPknlMstpSnonWrflDnon_medic0s";
	waitUntil { ((animationState player != "AinvPknlMstpSnonWrflDnon_medic0s") || (time >= _treatmentCompletedAtTime) || MEDIX_ABORT) };
	[[player, "AinvPercMstpSnonWrflDnon"], "MEDIX_FNC_SWITCHMOVENOW"] call BIS_fnc_MP;

	// Check whether the treatment was completed or aborted
	_treatment_completed = false;
	if ((time >= _treatmentCompletedAtTime)) then { _treatment_completed = true; };

	if (_treatment_completed) then {
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
		[[_actionObject, "MEDIX_ACT_ID_CARRY"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
		[[_actionObject, "MEDIX_ACT_ID_CARRYRELEASE"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;

		hint format["You have treated %1", (MEDIX_TREATINGUNIT getVariable "MEDIX_DOGTAG")];
	}
	else
	{
		hint "Treatment aborted";
	};
	
	MEDIX_PERFORMING_ACTION = false;
	MEDIX_TREATINGUNIT = nil;
	MEDIX_ABORT = false;
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
	waitUntil { (animationState player != "AinvPknlMstpSnonWrflDnon_medic0s") };
	MEDIX_PRESSUREUNIT setVariable ["MEDIX_ISPRESSURE", false, true];
	MEDIX_PERFORMING_ACTION = false;
};

MEDIX_ACT_CARRY = {
	_actionObject = _this select 0;
	MEDIX_CARRYING = _actionObject;

	MEDIX_PERFORMING_ACTION = true;

	player playMoveNow "amovpercmstpsraswrfldnon";

	MEDIX_EVT_CARRIED_UP = [player, MEDIX_CARRYING];
	publicVariable "MEDIX_EVT_CARRIED_UP";

	waitUntil { animationState player == "amovpercmstpsraswrfldnon" };
	player setVariable ["MEDIX_ANI_READY", true, true];

	waitUntil { (MEDIX_CARRYING getVariable "MEDIX_ANI_READY") };
	sleep 1;

	player playMoveNow "AcinPknlMstpSrasWrflDnon_AcinPercMrunSrasWrflDnon";
	[[_actionObject, "MEDIX_ACT_ID_CARRY"], "MEDIX_REMOVEACTION"] call BIS_fnc_MP;
	[player, "<t color='#FF9903'>Release</t>", MEDIX_ACT_CARRYRELEASE, "MEDIX_ACT_ID_CARRYRELEASE", 31, ""] spawn MEDIX_ADDACTION;
};

MEDIX_ACT_CARRYRELEASE = {
	player playMoveNow "acinpercmrunsraswrfldf_amovpercmstpslowwrfldnon";

	MEDIX_EVT_CARRIED_DOWN = [player, MEDIX_CARRYING];
	publicVariable "MEDIX_EVT_CARRIED_DOWN";
	
	[player, "MEDIX_ACT_ID_CARRYRELEASE"] spawn MEDIX_REMOVEACTION;
	[[MEDIX_CARRYING, "<t color='#FF9903'>Carry</t>", MEDIX_ACT_CARRY, "MEDIX_ACT_ID_CARRY", 28, "_target != player && !MEDIX_PERFORMING_ACTION && ((player distance _target) < MEDIX_PRP_TREATRANGE) && !(player getVariable ""MEDIX_ISBLEEDING"")"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
	
	MEDIX_CARRYING = nil;

	MEDIX_PERFORMING_ACTION = false;
};

MEDIX_FNC_SUICIDE = {
	MEDIX_CACHE_DAMAGE = 1;
};

MEDIX_FNC_UNCONSCIOUS = {
	_unit = _this select 0;
	//_unit playAction "Unconscious";
	_unit playMoveNow "AinjPpneMstpSnonWrflDnon";

	MEDIX_UNCONSCIOUS_UNIT = _unit;
	[[MEDIX_UNCONSCIOUS_UNIT, true], "MEDIX_FNC_SETCAPTIVE"] call BIS_fnc_MP;
	if (_unit == player) then {
		[[player, "<t color='#FF9903'>Check pulse</t>", MEDIX_FNC_CHECKPULSE, "MEDIX_ACT_ID_CHECKPULSE", 26, "_target != player && !MEDIX_PERFORMING_ACTION && ((player distance _target) < MEDIX_PRP_TREATRANGE) && !(player getVariable ""MEDIX_ISBLEEDING"")"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
		sleep 2;
		// player enableSimulation false;
		MEDIX_CACHE_UNCONSCIOUS_DIRECTION = direction player;
	};
};

MEDIX_FNC_PUTDRAGGEDINCARGO = {
	if (isNil "MEDIX_DRAGGINGUNIT") exitWith {};

	MEDIX_UNITTOPUTINCARGO = MEDIX_DRAGGINGUNIT;
	MEDIX_VEHICLE = cursorTarget;
	[] spawn MEDIX_FNC_RELEASE;

	waitUntil { (isNil "MEDIX_DRAGGINGUNIT") };

	sleep 2;
	if (MEDIX_VEHICLE isKindOf "LandVehicle" || MEDIX_VEHICLE isKindOf "Air") then {
		MEDIX_EVT_MOVEDINTOCARGO = [MEDIX_UNITTOPUTINCARGO, MEDIX_VEHICLE];
		publicVariable "MEDIX_EVT_MOVEDINTOCARGO";
	};
};

MEDIX_FNC_DOGTAG = {
	_actionObject = _this select 0;

	hint format["Dog tag: %1", (_actionObject getVariable "MEDIX_DOGTAG")];
	[_actionObject, "MEDIX_ACT_ID_DOGTAG"] spawn MEDIX_REMOVEACTION;
};
