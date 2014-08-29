// Enable screen effects
MEDIX_EFFECT1 = ppEffectCreate ["dynamicBlur", 505];
MEDIX_EFFECT1 ppEffectEnable true;
MEDIX_EFFECT2 = ppEffectCreate ["colorCorrections", 1501];
MEDIX_EFFECT2 ppEffectEnable true;

MEDIX_EFX_HELMETHIT = {
	addCamShake [155, 0.4, 2];
	MEDIX_EFFECT1 ppEffectAdjust [5.0];
	MEDIX_EFFECT1 ppEffectCommit 0;
	MEDIX_EFFECT1 ppEffectAdjust [0.0];
	MEDIX_EFFECT1 ppEffectCommit 60;
	sleep 0.4;
	addCamShake [20, 60, 0.3];
};

MEDIX_EFX_REGULARHIT = {
	MEDIX_EFFECT1 ppEffectAdjust [3.0];
	MEDIX_EFFECT1 ppEffectCommit 0;
	MEDIX_EFFECT1 ppEffectAdjust [0.0];
	MEDIX_EFFECT1 ppEffectCommit 2.5;
	addCamShake [1, 2, 25];
};

while {1==1} do {
	_fadeSpeed = 4;

	if (alive player && player getVariable "MEDIX_ISBLEEDING") then {
		MEDIX_EFFECT1 ppEffectAdjust [1.0];
		MEDIX_EFFECT1 ppEffectCommit _fadeSpeed;
		MEDIX_EFFECT2 ppEffectAdjust [0.0, 1.0, 0.0, [0.0, 0.0, 0.0, 0.0], [0.0, 1.0, 1.0, 1.0], [0.199, 0.587, 0.114, 0.0]];
		MEDIX_EFFECT2 ppEffectCommit _fadeSpeed;
		sleep (_fadeSpeed*2) + 0.5*(damage player);
	};
	if (alive player && player getVariable "MEDIX_ISBLEEDING") then {
		_brightness = 1.5*(1 - damage player);
		MEDIX_EFFECT1 ppEffectAdjust [0.5];
		MEDIX_EFFECT1 ppEffectCommit _fadeSpeed;
		MEDIX_EFFECT2 ppEffectAdjust [_brightness, 0.0, 0.0, [0.5, 0.0, 0.0, 0.0], [0.0, 1.0, 1.0, 1.0], [0.199, 0.587, 0.114, 0.0]];
		MEDIX_EFFECT2 ppEffectCommit _fadeSpeed*0.75;
		sleep _fadeSpeed*3;
	};
	sleep 0.5;
};
