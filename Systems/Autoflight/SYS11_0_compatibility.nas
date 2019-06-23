#### AP buttons in cockpit ####

var switchAlt=func() {
	var oldprop=getprop("autopilot/locks/altitude");
	var sysprop=0;
	var newprop="";

	if (oldprop=="altitude-hold") {
		newprop="";
		sysprop=0;
	} else {
		newprop="altitude-hold";
		sysprop=1;
	}

	setprop("autopilot/locks/altitude", newprop);
	setprop("sim/gui/dialogs/autopilot/altitude-active", sysprop);
}

var switchFPA=func() {
	var oldprop=getprop("autopilot/locks/altitude");
	var sysprop=0;
	var newprop="";

	if (oldprop=="fpa-hold") {
		newprop="";
		sysprop=0;
	} else {
		newprop="fpa-hold";
		sysprop=1;
	}

	setprop("autopilot/locks/altitude", newprop);
	setprop("sim/gui/dialogs/autopilot/altitude-active", sysprop);
}

var switchVS=func() {
	var oldprop=getprop("autopilot/locks/altitude");
	var sysprop=0;
	var newprop="";

	if (oldprop=="vertical-speed-hold") {
		newprop="";
		sysprop=0;
	} else {
		newprop="vertical-speed-hold";
		sysprop=1;
	}

	setprop("autopilot/locks/altitude", newprop);
	setprop("sim/gui/dialogs/autopilot/altitude-active", sysprop);
}

var switchVNAV=func() {
	var oldprop=getprop("autopilot/locks/altitude");
	var sysprop=0;
	var newprop="";

	if (oldprop=="vertical-nav") {
		newprop="";
		sysprop=0;
	} else {
		newprop="vertical-nav";
		sysprop=1;
	}

	setprop("autopilot/locks/altitude", newprop);
	setprop("sim/gui/dialogs/autopilot/altitude-active", sysprop);
}

var CRS_dir_nav0 = func () {
    setprop("instrumentation/nav[0]/radials/selected-deg",getprop("instrumentation/nav[0]/heading-deg"));
}

var CRS_dir_nav1 = func () {
    setprop("instrumentation/nav[1]/radials/selected-deg",getprop("instrumentation/nav[1]/heading-deg"));
}

var HDG_Sync = func () {
    setprop("autopilot/settings/heading-bug-deg",getprop("orientation/heading-magnetic-deg"));
}

var pitchLimit = func (pitch, low=-9.9, high=9.9) {
    if (pitch < low) { pitch = low;}
    if (pitch > high) { pitch = high;}
    return (pitch);
}

var FPA_Sync = func () {
    var current_pitch = getprop("orientation/pitch-deg");

    #hard Limits for Pitch Sync
    current_pitch = pitchLimit(current_pitch);

    setprop("autopilot/settings/target-pitch-deg",current_pitch);
}

var VSLimit = func (vs, low=-5500, high=5500) {
    if (vs < low) { vs = low;}
    if (vs > high) { vs = high;}
    return (vs);
}

var VS_Sync = func () {
    var current_vs = getprop("velocities/vertical-speed-fps");

    #hard Limits for Pitch Sync
    current_vs = VSLimit(current_vs);

    setprop("autopilot/settings/vertical-speed-fpm",current_vs);
}

var ALT_Sync = func () {
    setprop("autopilot/settings/target-altitude-ft",getprop("position/altitude-ft"));
}

var KIASLimit = func (KIAS, low=130, high=320) {
    if (KIAS < low) { KIAS = low;}
    if (KIAS > high) { KIAS = high;}
    return (KIAS);
}

var MachLimit = func (mach, low=0.35, high=0.82) {
    if (mach < low) { mach = low;}
    if (mach > high) { mach = high;}
    return (mach);
}
var SPD_Sync = func () {
    var current_KIAS = getprop("velocities/airspeed-kt");
    var current_Mach = getprop("velocities/mach");

    #LIMIT Speed Set by AP
    current_KIAS = KIASLimit(current_KIAS);
    current_Mach = MachLimit(current_Mach);

    setprop("autopilot/settings/target-speed-kt", current_KIAS);
    setprop("autopilot/settings/target-speed-mach", current_Mach);
}

var AP_Start_Clean = func () {
    #AP starts clean with conservation of Heading and pitch
    HDG_Sync();
    FPA_Sync();
    setprop("autopilot/locks/heading","dg-heading-hold");
    setprop("autopilot/locks/altitude","pitch-hold");
    setprop("autopilot/settings/ap-armed",true);
}
