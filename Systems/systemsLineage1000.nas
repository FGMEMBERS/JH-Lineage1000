# Lineage 1000 SYSTEMS
#########################

## LIGHTS
#########

# create all lights
var beacon_switch = props.globals.getNode("controls/switches/beacon", 2);
var beacon = aircraft.light.new("sim/model/lights/beacon", [0.015, 3], "controls/lighting/beacon");

var strobe_switch = props.globals.getNode("controls/switches/strobe", 2);
var strobe = aircraft.light.new("sim/model/lights/strobe", [0.025, 1.5], "controls/lighting/strobe");

## SOUNDS
#########

# seatbelt/no smoking sign triggers
setlistener("controls/switches/seatbelt-sign", func {
	props.globals.getNode("sim/sound/seatbelt-sign").setBoolValue(1);
	settimer(func {
  		props.globals.getNode("sim/sound/seatbelt-sign").setBoolValue(0);
  	}, 2);
});

setlistener("controls/switches/no-smoking-sign", func {
	props.globals.getNode("sim/sound/no-smoking-sign").setBoolValue(1);
	settimer(func {
		props.globals.getNode("sim/sound/no-smoking-sign").setBoolValue(0);
	}, 2);
});

## INSTRUMENTS
##############

var instruments = {

	calcBugDeg: func(bug, limit) {
		var heading = getprop("orientation/heading-magnetic-deg");
		var bugDeg = 0;

		while (bug < 0) {
			bug += 360;
		}
		while (bug > 360) {
			bug -= 360;
		}
		if (bug < limit) {
			bug += 360;
		}
		if (heading < limit) {
			heading += 360;
		}

		# bug is adjusted normally
		if (math.abs(heading - bug) < limit) {
			bugDeg = heading - bug;
		} elsif (heading - bug < 0) {
			if (math.abs(heading - bug + 360 >= 180)) {
				# bug is on the far right
				bugDeg = -limit;
			} elsif (math.abs(heading - bug + 360 < 180)) {
				# bug is on the far left
				bugDeg = limit;
			}
		} else {
			if (math.abs(heading - bug >= 180)) {
				# bug is on the far right
				bugDeg = -limit;
			} elsif (math.abs(heading - bug < 180)) {
				# bug is on the far left
				bugDeg = limit;
			}
		}
		return bugDeg;
	},

	loop: func {
		instruments.setHSIBugsDeg();
		instruments.setSpeedBugs();
		instruments.setMPProps();
		instruments.calcEGTDegC();

		settimer(instruments.loop, 0);
	},

	# set the rotation of the HSI bugs
	setHSIBugsDeg: func {
#		setprop("sim/model/ERJ/heading-bug-pfd-deg", instruments.calcBugDeg(getprop("autopilot/settings/heading-bug-deg"), 80));
#		setprop("sim/model/ERJ/heading-bug-deg", instruments.calcBugDeg(getprop("autopilot/settings/heading-bug-deg"), 37));
#		setprop("sim/model/ERJ/nav1-bug-deg", instruments.calcBugDeg(getprop("instrumentation/nav[0]/heading-deg"), 37));
#		setprop("sim/model/ERJ/nav2-bug-deg", instruments.calcBugDeg(getprop("instrumentation/nav[1]/heading-deg"), 37));
#		if (getprop("autopilot/route-manager/route/num") > 0 and getprop("autopilot/route-manager/wp[0]/bearing-deg") != nil) {
#			setprop("sim/model/ERJ/wp-bearing-deg", instruments.calcBugDeg(getprop("autopilot/route-manager/wp[0]/bearing-deg"), 45));
#		}
	},

	setSpeedBugs: func {
#		setprop("sim/model/ERJ/ias-bug-kt-norm", getprop("autopilot/settings/target-speed-kt") - getprop("velocities/airspeed-kt"));
#		setprop("sim/model/ERJ/mach-bug-kt-norm", (getprop("autopilot/settings/target-speed-mach") - getprop("velocities/mach")) * 600);
	},

	setMPProps: func {
		var calcMPDistance = func(tree) {
			var x = getprop(tree ~ "position/global-x");
			var y = getprop(tree ~ "position/global-y");
			var z = getprop(tree ~ "position/global-z");
			var coords = geo.Coord.new().set_xyz(x, y, z);

			var distance = nil;
			call(func distance = geo.aircraft_position().distance_to(coords), nil, var err = []);
			if (size(err) or distance == nil) {
				return 0;
			} else {
				return distance;
			}
		};

		var calcMPBearing = func(tree) {
			var x = getprop(tree ~ "position/global-x");
			var y = getprop(tree ~ "position/global-y");
			var z = getprop(tree ~ "position/global-z");
			var coords = geo.Coord.new().set_xyz(x, y, z);

			return geo.aircraft_position().course_to(coords);
		};

		if (getprop("ai/models/multiplayer[0]/valid")) {
			setprop("sim/model/ERJ/multiplayer-distance[0]", calcMPDistance("ai/models/multiplayer[0]/"));
			setprop("sim/model/ERJ/multiplayer-bearing[0]", instruments.calcBugDeg(calcMPBearing("ai/models/multiplayer[0]/"), 45));
		}
		if (getprop("ai/models/multiplayer[1]/valid")) {
			setprop("sim/model/ERJ/multiplayer-distance[1]", calcMPDistance("ai/models/multiplayer[1]/"));
			setprop("sim/model/ERJ/multiplayer-bearing[1]", instruments.calcBugDeg(calcMPBearing("ai/models/multiplayer[1]/"), 45));
		}
		if (getprop("ai/models/multiplayer[2]/valid")) {
			setprop("sim/model/ERJ/multiplayer-distance[2]", calcMPDistance("ai/models/multiplayer[2]/"));
			setprop("sim/model/ERJ/multiplayer-bearing[2]", instruments.calcBugDeg(calcMPBearing("ai/models/multiplayer[2]/"), 45));
		}
		if (getprop("ai/models/multiplayer[3]/valid")) {
			setprop("sim/model/ERJ/multiplayer-distance[3]", calcMPDistance("ai/models/multiplayer[3]/"));
			setprop("sim/model/ERJ/multiplayer-bearing[3]", instruments.calcBugDeg(calcMPBearing("ai/models/multiplayer[3]/"), 45));
		}
		if (getprop("ai/models/multiplayer[4]/valid")) {
			setprop("sim/model/ERJ/multiplayer-distance[4]", calcMPDistance("ai/models/multiplayer[4]/"));
			setprop("sim/model/ERJ/multiplayer-bearing[4]", instruments.calcBugDeg(calcMPBearing("ai/models/multiplayer[4]/"), 45));
		}
		if (getprop("ai/models/multiplayer[5]/valid")) {
			setprop("sim/model/ERJ/multiplayer-distance[5]", calcMPDistance("ai/models/multiplayer[5]/"));
			setprop("sim/model/ERJ/multiplayer-bearing[5]", instruments.calcBugDeg(calcMPBearing("ai/models/multiplayer[5]/"), 45));
		}
	},

	calcEGTDegC: func() {
		if (getprop("engines/engine[0]/egt-degf") != nil) {
			setprop("engines/engine[0]/egt-degc", (getprop("engines/engine[0]/egt-degf") - 32) * 1.8);
		}
		if (getprop("engines/engine[1]/egt-degf") != nil) {
			setprop("engines/engine[1]/egt-degc", (getprop("engines/engine[1]/egt-degf") - 32) * 1.8);
		}
	}

};

var weathercontrol=func{
	var heading=getprop("/orientation/heading-deg");
	var wind=getprop("/environment/wind-from-heading-deg");
	var result=(wind-heading);
	if (result<0) {
		result=360+result;
	}
	if (result>360) {
		result=result-360;
	}
	setprop("/voodoomaster/weather/relative-wind", result);
	settimer(weathercontrol, 2);
}

var enginecontrol=func{
print("called engine control");	
	var eng0ff=getprop("/fdm/jsbsim/propulsion/engine[0]/fuel-flow-rate-pps");
	var eng1ff=getprop("/fdm/jsbsim/propulsion/engine[1]/fuel-flow-rate-pps");
	var eng2ff=getprop("/fdm/jsbsim/propulsion/engine[2]/fuel-flow-rate-pps");
	var eng3ff=getprop("/fdm/jsbsim/propulsion/engine[3]/fuel-flow-rate-pps");
	var eng4ff=getprop("/fdm/jsbsim/propulsion/engine[4]/fuel-flow-rate-pps");
	var eng5ff=getprop("/fdm/jsbsim/propulsion/engine[5]/fuel-flow-rate-pps");
	var eng6ff=getprop("/fdm/jsbsim/propulsion/engine[6]/fuel-flow-rate-pps");
	var eng7ff=getprop("/fdm/jsbsim/propulsion/engine[7]/fuel-flow-rate-pps");

	if (eng0ff==nil) { eng0ff=0.00; }
	if (eng1ff==nil) { eng1ff=0.00; }
	if (eng2ff==nil) { eng2ff=0.00; }
	if (eng3ff==nil) { eng3ff=0.00; }
	if (eng4ff==nil) { eng4ff=0.00; }
	if (eng5ff==nil) { eng5ff=0.00; }
	if (eng6ff==nil) { eng6ff=0.00; }
	if (eng7ff==nil) { eng7ff=0.00; }

	var fftotal=eng0ff+eng1ff+eng2ff+eng3ff+eng4ff+eng5ff+eng6ff+eng7ff;
	if (fftotal>0.00) {
		var seconds=getprop("/fdm/jsbsim/propulsion/total-fuel-lbs")/fftotal;
		var hours=seconds/3600;
		var range=hours*getprop("/instrumentation/gps/indicated-ground-speed-kt");
		setprop("/voodoomaster/engines/fuel_flow_total_pps", fftotal);
		setprop("/voodoomaster/engines/airtime", hours);
		setprop("/voodoomaster/engines/range_nm", range);
	}
	settimer(enginecontrol, 2);
}

var routecontrol=func{
	if (getprop("/autopilot/route-manager/active")) {
		# we have an active route, rebuild display
		var i=0;
		var o=getprop("/autopilot/route-manager/current-wp")-5;
		for (i=0; i<11; i=i+1) {
			if (((i+o)<getprop("/autopilot/route-manager/route/num")) and ((i+o)>=0)) {
				if ((i+o)==getprop("/autopilot/route-manager/current-wp")) {
					setprop("/voodoomaster/route/marker["~i~"]", ">");
				} else {
					setprop("/voodoomaster/route/marker["~i~"]", " ");
				}
				setprop("/voodoomaster/route/number["~i~"]", (i+o));
				setprop("/voodoomaster/route/code["~i~"]", getprop("/autopilot/route-manager/route/wp["~(i+o)~"]/id"));

				var name=getprop("/autopilot/route-manager/route/wp["~(i+o)~"]/id");
				var fixes = findFixesByID(getprop("/autopilot/route-manager/route/wp["~(i+o)~"]/id"));
				foreach(var fix; fixes){
					name=fix.id;
				}

				var navaids = findNavaidsByID(getprop("/autopilot/route-manager/route/wp["~(i+o)~"]/id"));
				foreach(var fix; navaids){
					name=fix.name;
				}

				if (substr(getprop("/autopilot/route-manager/route/wp["~(i+o)~"]/id"), 4, 1)=="-") {
					var airports = findAirportsByICAO(substr(getprop("/autopilot/route-manager/route/wp["~(i+o)~"]/id"), 0, 4));
					print("searching for "~getprop("/autopilot/route-manager/route/wp["~(i+o)~"]/id"));
					foreach(var fix; airports){
						name=fix.name~" ("~substr(getprop("/autopilot/route-manager/route/wp["~(i+o)~"]/id"), 5)~")";
					}
				}
				setprop("/voodoomaster/route/title["~i~"]", name);
				setprop("/voodoomaster/route/bearing["~i~"]", getprop("/autopilot/route-manager/route/wp["~(i+o)~"]/leg-bearing-true-deg"));
				setprop("/voodoomaster/route/distance["~i~"]", getprop("/autopilot/route-manager/route/wp["~(i+o)~"]/leg-distance-nm"));
			} else {
				setprop("/voodoomaster/route/marker["~i~"]", "INVALID");
				setprop("/voodoomaster/route/number["~i~"]", 0);
				setprop("/voodoomaster/route/code["~i~"]", "");
				setprop("/voodoomaster/route/title["~i~"]", "");
				setprop("/voodoomaster/route/bearing["~i~"]", 0.0);
				setprop("/voodoomaster/route/distance["~i~"]", 0.0);
			}
		}
	} else {
		# we have no active route, clear display
		var i=0;
		for (i=0; i<11; i=i+1) {
			setprop("/voodoomaster/route/marker["~i~"]", "INVALID");
			setprop("/voodoomaster/route/number["~i~"]", 0);
			setprop("/voodoomaster/route/code["~i~"]", "");
			setprop("/voodoomaster/route/title["~i~"]", "");
			setprop("/voodoomaster/route/bearing["~i~"]", 0.0);
			setprop("/voodoomaster/route/distance["~i~"]", 0.0);
		}
	}
}


# start the loop 2 seconds after the FDM initializes
setlistener("sim/signals/fdm-initialized", func {
	settimer(instruments.loop, 2);
	settimer(weathercontrol, 2);
	settimer(enginecontrol, 2);
	setlistener("/autopilot/route-manager/active", routecontrol);
	setlistener("/autopilot/route-manager/current-wp", routecontrol);
	setlistener("/autopilot/route-manager/route/num", routecontrol);
});

