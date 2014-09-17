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
player setVariable ["MEDIX_ACT_ID_CARRY", -1, true];
player setVariable ["MEDIX_ACT_ID_CARRYRELEASE", -1, true];
player setVariable ["MEDIX_ACT_ID_DOGTAG", -1, true];
player setVariable ["MEDIX_ISBLEEDING", false, true];
player setVariable ["MEDIX_ISSTABILIZED", false, true];
player setVariable ["MEDIX_ISPRESSURE", false, true];
player setVariable ["MEDIX_ISKILLED", false, true];
player setVariable ["MEDIX_ISDRAGGED", false, true];
player setVariable ["MEDIX_ISCARRIED", false, true];
player setVariable ["MEDIX_EVT_DRAGGED", false, true];
player setVariable ["MEDIX_EVT_ISKILLED", false, true];
player setVariable ["MEDIX_ANI_READY", false, true];
player setVariable ["MEDIX_DOGTAG", (name player), true];
player setVariable ["MEDIX_CACHE_UNCONSCIOUS_DIRECTION", 0, true];
MEDIX_DRAGGINGUNIT = nil;
MEDIX_TREATINGUNIT = nil;
MEDIX_PRESSUREUNIT = nil;
MEDIX_PERFORMING_ACTION = false;
MEDIX_CACHE_DAMAGE = 0;
MEDIX_ABORT = false;

player addAction ["<t color='#FF9903'>Put soldier into vehicle</t>", MEDIX_FNC_PUTDRAGGEDINCARGO, nil, 25.5, true, true, "", "(!isNil ""MEDIX_DRAGGINGUNIT"") && (cursorTarget isKindOf ""LandVehicle"" || cursorTarget isKindOf ""Air"") && (player distance cursorTarget < 5)"];

// Make sure postprocesses are to default on respawn
MEDIX_EFFECT1 ppEffectAdjust [0.0];
MEDIX_EFFECT1 ppEffectCommit 2;
MEDIX_EFFECT2 ppEffectAdjust [1.0, 1.0, 0.0, [0.0, 0.0, 0.0, 0.0], [0.0, 1.0, 1.0, 1.0], [0.0, 0.0, 0.0, 0.0]];
MEDIX_EFFECT2 ppEffectCommit 2;

// Load handlers
[] execVM "medix\handlers.sqf";
