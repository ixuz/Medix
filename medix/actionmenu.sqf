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
