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

var ALT_min = func (min_agl=1000){
        var current_elev =  getprop("/position/ground-elev-ft");
	if (current_elev == nil) { current_elev = 0;}
    	var min_alt_ft = min_agl + current_elev;
    	setprop("autopilot/internal/min-alt-ft", min_alt_ft);
    }
settimer (ALT_min, 10);

var ALTLimit = func (alt){
    var min_alt = getprop("autopilot/internal/min-alt-ft");
    if (alt < min_alt) {
       alt = min_alt;
    }
    return (alt);
}

var ALT_Sync = func (alt_set=nil) {
    if (alt_set==nil){
       var alt_set = getprop("position/altitude-ft");
    }
    alt_set = ALTLimit (alt_set);
    setprop("autopilot/settings/target-altitude-ft", alt_set);
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

var AP_Toggle = func () {
    #When AP is engaged; then disengage
    if (getprop("autopilot/settings/ap-armed")){
       setprop("autopilot/settings/ap-armed", "false");
       return ("AP off");
    }

    #When AP is not engaged; first sync to current condition
    HDG_Sync();
    FPA_Sync();
    VS_Sync();
    ALT_Sync();
    SPD_Sync();
    
    #then engage HDG or FPA by default if no option pre-selected
    if (getprop("autopilot/locks/heading")==nil){
       setprop("autopilot/locks/heading","dg-heading-hold");      
    }
    if (getprop("autopilot/locks/altitude")==nil) {
       setprop("autopilot/locks/altitude","pitch-hold");
    }

    #Finally engage autopilot
    setprop("autopilot/settings/ap-armed","true");
    return ("AP on");
}
