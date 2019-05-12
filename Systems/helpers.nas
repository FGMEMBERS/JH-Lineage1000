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
