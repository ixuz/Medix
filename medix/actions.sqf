MEDIX_ACTION_ABORT = {
	[[player, "AinvPknlMstpSnonWrflDnon_medicEnd"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP;
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
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic0"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP; sleep 3.225; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic1"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP; sleep 3.846; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic2"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP; sleep 4.263; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medicEnd"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP; sleep 2.000; };

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
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic0"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP; sleep 3.225; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic1"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP; sleep 3.846; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic2"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP; sleep 4.263; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic3"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP; sleep 5.000; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic4"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP; sleep 7.692; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic0"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP; sleep 3.225; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic1"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP; sleep 3.846; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medic3"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP; sleep 5.000; };
	if (!MEDIX_ABORT) then { [[player, "AinvPknlMstpSnonWrflDnon_medicEnd"], "MEDIX_FNC_PLAYMOVENOW"] call BIS_fnc_MP; sleep 2.000; };

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

MEDIX_FNC_SUICIDE = {
	MEDIX_CACHE_DAMAGE = 1;
};

MEDIX_FNC_UNCONSCIOUS = {
	_unit = _this select 0;
	_unit playAction "Unconscious";

	MEDIX_UNCONSCIOUS_UNIT = _unit;
	[[MEDIX_UNCONSCIOUS_UNIT, true], "MEDIX_FNC_SETCAPTIVE"] call BIS_fnc_MP;
	if (_unit == player) then {
		[[player, "<t color='#FF9903'>Check pulse</t>", MEDIX_FNC_CHECKPULSE, "MEDIX_ACT_ID_CHECKPULSE", 26, "_target != player && !MEDIX_PERFORMING_ACTION && ((player distance _target) < MEDIX_PRP_TREATRANGE) && !(player getVariable ""MEDIX_ISBLEEDING"")"], "MEDIX_ADDACTION"] call BIS_fnc_MP;
		sleep 2;
		player enableSimulation false;
	};
};
