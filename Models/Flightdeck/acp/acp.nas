####################################################################
# acp.nas                                                          # 
# Copyright, @IAHM-COL, 2019                                       #
# www.thejabberwocky.net                                           #
# License, GPL v3.0 or higher                                      #
# Establishes functionality for ACP stack                          #
# Lineage1000 aircraft (FGFS)                                      #
##                                                                ##
#                                                                  #
#@                   Public Methods                               @#
#@                                                                @#
#@   acp.dump();                                                  @#
#@        Dumps status of active instrument                       @#
#@   acp.dump(id);						  @#
#@        Dumps status of instrument id			   	  @#
#@                                                                @#
#@   acp.getDisplay(); 	  	     				  @#
#@        Gets Display string of active instrument		  @#
#@   acp.getDisplay(id);					  @#
#@        Gets display string of instrument id			  @#
#@                                                                @#
#@     example,                                                   @#
#@        var display = acp.getDisplay ();                        @#
#@        print (display);                                        @#
#@								  @#
#@   acp.updateVolumes();					  @#
#@        Updates the master volume for each ACP instrument       @#
#@	  	      	     	    	     	 		  @#
#@   acp.update();						  @#
#@        Updates the active instrument by connecting it          @#
#@        to the Lineage 1000 Systems				  @#
#@                    	     	    	       	      		  @#
#@   acp.paPTTHold();						  @#
#@        Holds the comm audio of stack id to PA                  @#
#@        on the pressed side of the instrument  		  @#	
#@								  @#
#@   acp.paPTTRelease();   	    	      	   		  @#
#@        Releases the last pressed comm audio of stack           @#
#@	  	       						  @#	  
####################################################################


#define bools
var true = 1;
var false = 0;

#define number of ACP Instruments available
var stackSize = 3;

#ACPSelected identifies first ACP of the stack that is currently active
var ACPSelected = func() {
    var id = false;
    for (var index =0; index < stackSize; index=index+1){
    	id = getprop ("/instrumentation/acp["~index~"]/active");
	if (id) {return index;}
    };
    print ("[ERROR] nasal: No ACP currently active");
    return (0);
};

#Class Stack declaration and methods
var stack = {
    active:false,
    batteryOn:false,
    mic:true,	
    micMask:"auto",
    audio:"vhf1",
    adf1:false,
    adf2:false,
    dme1:false,
    dme2:false,
    nav1:false,
    nav2:false,
    nav3:false,
    mkr:false,
    filterId:true,
    backup:"norm",
    lastSelected:"vhf1",
    output:"headphone",
    volume:100,
    volumePA:1,
    volumeSAT:1,
    volumeBackup:1,
    new : func (id=nil) {
	var stack = {parents:[stack]};
    	if (id==nil) { id=ACPSelected(); }
    	if (id>stackSize-1) { id = ACPSelected(); }
	stack.loadInstrument(id);
	stack.setVolumeInstrument(id);
	return stack;
    },
    dump: func() {
    	  print ("Active : "~me.active);
    	  print ("Battery on: "~me.batteryOn);
    	  print ("Audio/Last selected :"~me.lastSelected);
    	  print ("Audio/Backup :"~me.backup);
    	  print ("Audio/Backup volume  :"~me.volumeBackup);
    	  print ("Audio/Output :"~me.output);
    	  print ("Audio/Volume PA:"~me.volumePA);
    	  print ("Audio/Volume SAT:"~me.volumeSAT);
    	  print ("Audio/Volume Master:"~me.volume);
    	  print ("Audio/ADF1:"~me.adf1);
    	  print ("Audio/ADF2:"~me.adf2);
    	  print ("Audio/DME1:"~me.dme1);
    	  print ("Audio/DME2:"~me.dme2);
    	  print ("Audio/NAV1:"~me.nav1);
    	  print ("Audio/NAV2:"~me.nav2);
    	  print ("Audio/NAV3:"~me.nav3);
    	  print ("Audio/MKR:"~me.mkr);
	  print ("Comm/Mic: "~me.mic);
	  print ("Comm/Mic mask: "~me.micMask);
	  print ("Comm/Audio: "~me.audio);
    },
    loadInstrument: func (id) {
          me.active=getprop("/instrumentation/acp["~id~"]/active");
    	  me.batteryOn=getprop("/instrumentation/acp["~id~"]/battery-on");
    	  me.lastSelected=getprop("/instrumentation/acp["~id~"]/audio/last-selected");
    	  me.backup=getprop("/instrumentation/acp["~id~"]/audio/backup");
    	  me.volumeBackup=getprop("/instrumentation/acp["~id~"]/audio/backup-volume");
    	  me.output=getprop("/instrumentation/acp["~id~"]/audio/output");
    	  me.volumePA=getprop("/instrumentation/acp["~id~"]/audio/volume-pa");
    	  me.volumeSAT=getprop("/instrumentation/acp["~id~"]/audio/volume-sat");
    	  me.volume=getprop("/instrumentation/acp["~id~"]/audio/volume");
    	  me.adf1=getprop("/instrumentation/acp["~id~"]/audio/adf1");
    	  me.adf2=getprop("/instrumentation/acp["~id~"]/audio/adf2");
    	  me.dme1=getprop("/instrumentation/acp["~id~"]/audio/dme1");
    	  me.dme2=getprop("/instrumentation/acp["~id~"]/audio/dme2");
    	  me.nav1=getprop("/instrumentation/acp["~id~"]/audio/nav1");
    	  me.nav2=getprop("/instrumentation/acp["~id~"]/audio/nav2");
    	  me.nav3=getprop("/instrumentation/acp["~id~"]/audio/nav3");
    	  me.mkr=getprop("/instrumentation/acp["~id~"]/audio/mkr");
    	  me.mic=getprop("/instrumentation/acp["~id~"]/comm/mic");
    	  me.micMask=getprop("/instrumentation/acp["~id~"]/comm/mic-mask");
    	  me.audio=getprop("/instrumentation/acp["~id~"]/comm/audio");
    },
    setInstrument : func (id) {
          me.volumeUpdate();
          setprop("/instrumentation/acp["~id~"]/active", me.active);
    	  setprop("/instrumentation/acp["~id~"]/battery-on", me.batteryOn);
    	  setprop("/instrumentation/acp["~id~"]/audio/last-selected", me.lastSelected);
    	  setprop("/instrumentation/acp["~id~"]/audio/backup", me.backup);
    	  setprop("/instrumentation/acp["~id~"]/audio/backup-volume", me.volumeBackup);
    	  setprop("/instrumentation/acp["~id~"]/audio/output", me.output);
    	  setprop("/instrumentation/acp["~id~"]/audio/volume-pa", me.volumePA);
    	  setprop("/instrumentation/acp["~id~"]/audio/volume-sat", me.volumeSAT);
    	  setprop("/instrumentation/acp["~id~"]/audio/volume", me.volume);
    	  setprop("/instrumentation/acp["~id~"]/audio/adf1", me.adf1);
    	  setprop("/instrumentation/acp["~id~"]/audio/adf2", me.adf2);
    	  setprop("/instrumentation/acp["~id~"]/audio/dme1", me.dme1);
    	  setprop("/instrumentation/acp["~id~"]/audio/dme2", me.dme2);
    	  setprop("/instrumentation/acp["~id~"]/audio/nav1", me.nav1);
    	  setprop("/instrumentation/acp["~id~"]/audio/nav2", me.nav2);
    	  setprop("/instrumentation/acp["~id~"]/audio/nav3", me.nav3);
    	  setprop("/instrumentation/acp["~id~"]/audio/mkr", me.mkr);
    	  setprop("/instrumentation/acp["~id~"]/comm/mic", me.mic);
    	  setprop("/instrumentation/acp["~id~"]/comm/mic-mask", me.micMask);
    	  setprop("/instrumentation/acp["~id~"]/comm/audio", me.audio);
    },
    copy : func (template) {
          me.active=template.active;
    	  me.batteryOn=template.batteryOn;
    	  me.lastSelected=template.lastSelected;
    	  me.backup=template.backup;
    	  me.volumeBackup=template.volumeBackup;
    	  me.output=template.output;
    	  me.volumePA=template.volumePA;
    	  me.volumeSAT=template.volumeSAT;
    	  me.volume=template.volume;
    	  me.adf1=template.adf1;
    	  me.adf2=template.adf2;
    	  me.dme1=template.dme1;
    	  me.dme2=template.dme2;
    	  me.nav1=template.nav1;
    	  me.nav2=template.nav2;
    	  me.nav3=template.nav3;
    	  me.mkr=template.mkr;
    	  me.mic=template.mic;
    	  me.micMask=template.micMask;
    	  me.audio=template.audio;
    },
    ##ACTIVE##
    toggleActive : func () {
          if (me.active) { me.active = false; return (me.active);}
          if (!me.active) { me.active = true; return (me.active);}
    },
    setActive : func (value = true){
          #defaults to true
	  me.active = true;
	  if (value == "true") { me.active = true;}
	  if (value == "false") { me.active = false;}
	  return me.active;
    },
    isActive : func () {
    	 return (me.active);
    },
    ##BATTERY##
    isBatteryOn : func () {
         return (me.batteryOn);
    },
    ##COMM##
    toggleMic : func () {
    	  if (me.mic)  { me.mic = false; return (me.mic); }
	  if (!me.mic) { me.mic = true;  return (me.mic); }
    },
    setMic : func (value=true) {
    	   #defaults to true
	   me.mic = true;
	   if (value == true) {me.mic = true; }
	   if (value == false){me.mic = false;}
	   return (me.mic);
    },
    isActiveMic : func () {
    	   return (me.mic);
    },
    setCommAudio : func (value="vhf1") {
          #defaults to vhf1
          me.audio = "vhf1";
	  me.lastSelected = "vhf1";
	  if (value == "vhf1") {me.audio = "vhf1"; me.lastSelected = "vhf1";}
	  if (value == "vhf2") {me.audio = "vhf2"; me.lastSelected = "vhf2";}
	  if (value == "vhf3") {me.audio = "vhf3"; me.lastSelected = "vhf3";}
	  if (value == "hf") {me.audio = "hf"; me.lastSelected = "hf";}
  	  if (value == "sat") {me.audio = "sat"; me.lastSelected = "sat";}
	  if (value == "pa") {me.audio = "pa"; me.lastSelected = "pa";}
	  return (me.audio);
    },
    isActiveVHF1 : func (){
         if (me.audio == "vhf1") {return true;}
	 return false;
    },
    isActiveVHF2 : func (){
         if (me.audio == "vhf2") {return true;}
	 return false;
    },
    isActiveVHF3 : func (){
         if (me.audio == "vhf3") {return true;}
	 return false;
    },
    isActiveHF : func (){
         if (me.audio == "hf") {return true;}
	 return false;
    },
    isActiveSAT : func (){
         if (me.audio == "sat") {return true;}
	 return false;
    },
    isActivePA : func (){
         if (me.audio == "pa") {return true;}
	 return false;
    },
    toggleMicMask : func () {
    	 if (me.isAutoMicMask()) {me.mask = "mask"; return (me.mask);}
	 if (me.isMaskMicMask()) {me.mask = "auto"; return (me.mask);}
    },
    setMicMask : func (value="auto") {
    	 #defaults to auto
	 me.micMask = "auto";
	 if (value == "auto") { me.micMask = "auto";}
	 if (value == "mask") { me.micMask = "mask";}
	 return (me.micMask)
    },
    isAutoMicMask : func () {
         if (me.micMask == "auto") { return true; }
	 return false;
    },
    isMaskMicMask : func () {
         if (me.micMask == "mask") { return true; }
	 return false;
    },
    ##AUDIO##
    toggleADF1 : func () {
    	 if (me.adf1) { me.adf1 = false; return me.adf1;}
    	 if (!me.adf1) { me.adf1 = true;  me.lastSelected = "adf1"; return me.adf1;}
    },
    setADF1 : func (value = true) {
    	 #defaults to true
	 me.adf1=true;
	 if (value == true)  { me.adf1 = true;  me.lastSelected = "adf1"; }
	 if (value == false) { me.adf1 = false; }
	 return me.adf1;
    },
    isActiveADF1 : func () {
         if (me.adf1) { return true;}
	 return false;
    },
    toggleADF2 : func () {
    	 if (me.adf2) { me.adf2 = false; return me.adf2;}
    	 if (!me.adf2) { me.adf2 = true;  me.lastSelected = "adf2"; return me.adf2;}
    },
    setADF2 : func (value = true) {
    	 #defaults to true
	 me.adf2=true;
	 if (value == true)  { me.adf2 = true;  me.lastSelected = "adf2"; }
	 if (value == false) { me.adf2 = false; }
	 return me.adf2;
    },
    isActiveADF2 : func () {
         if (me.adf2) { return true;}
	 return false;
    },
    toggleDME1 : func () {
    	 if (me.dme1) { me.dme1 = false; return me.dme1;}
    	 if (!me.dme1) { me.dme1 = true;  me.lastSelected = "dme1"; return me.dme1;}
    },
    setDME1 : func (value = true) {
    	 #defaults to true
	 me.dme1=true;
	 if (value == true)  { me.dme1 = true;  me.lastSelected = "dme1"; }
	 if (value == false) { me.dme1 = false; }
	 return me.dme1;
    },
    isActiveDME1 : func () {
         if (me.dme1) { return true;}
	 return false;
    },
    toggleDME2 : func () {
    	 if (me.dme2) { me.dme2 = false; return me.dme2;}
    	 if (!me.dme2) { me.dme2 = true;  me.lastSelected = "dme2"; return me.dme2;}
    },
    setDME2 : func (value = true) {
    	 #defaults to true
	 me.dme2=true;
	 if (value == true)  { me.dme2 = true;  me.lastSelected = "dme2";}
	 if (value == false) { me.dme2 = false; }
	 return me.dme2;
    },
    isActiveDME2 : func () {
         if (me.dme2) { return true;}
	 return false;
    },
    toggleNAV1 : func () {
    	 if (me.nav1)  { me.nav1 = false; return me.nav1;}
    	 if (!me.nav1) { me.nav1 = true;  me.lastSelected = "nav1"; return me.nav1;}
    },
    setNAV1 : func (value = true) {
    	 #defaults to true
	 me.nav1=true;
	 if (value == true)  { me.nav1 = true;  me.lastSelected = "nav1"; }
	 if (value == false) { me.nav1 = false; }
	 return me.nav1;
    },
    isActiveNAV1 : func () {
         if (me.nav1) { return true;}
	 return false;
    },
    toggleNAV2 : func () {
    	 if (me.nav2) { me.nav2 = false; return me.nav2;}
    	 if (!me.nav2) { me.nav2 = true;  me.lastSelected = "nav2"; return me.nav2;}
    },
    setNAV2 : func (value = true) {
    	 #defaults to true
	 me.nav2=true;
	 if (value == true)  { me.nav2 = true;  me.lastSelected = "nav2"; }
	 if (value == false) { me.nav2 = false; }
	 return me.nav2;
    },
    isActiveNAV2 : func () {
         if (me.nav2) { return true;}
	 return false;
    },
    toggleNAV3 : func () {
    	 if (me.nav3) { me.nav3 = false; return me.nav3;}
    	 if (!me.nav3) { me.nav3 = true;  me.lastSelected = "nav3"; return me.nav3;}
    },
    setNAV3 : func (value = true) {
    	 #defaults to true
	 me.nav3=true;
	 if (value == true)  { me.nav3 = true;  me.lastSelected = "nav3"; }
	 if (value == false) { me.nav3 = false; }
	 return me.nav3;
    },
    isActiveNAV3 : func () {
         if (me.nav3) { return true;}
	 return false;
    },    
    toggleMKR : func () {
    	 if (me.mkr) { me.mkr = false; return me.mkr;}
    	 if (!me.mkr) { me.mkr = true;  me.lastSelected = "mkr"; return me.mkr;}
    },
    setMKR : func (value = true) {
    	 #defaults to true
	 me.mkr=true;
	 if (value == true)  { me.mkr = true;  me.lastSelected = "mkr"; }
	 if (value == false) { me.mkr = false; }
	 return me.mkr;
    },
    isActiveMKR : func () {
         if (me.mkr) { return true;}
	 return false;
    },
    setOutput : func (value = "headphone") {
    	 #defaults to headphone
	 me.output = "headphone";
	 if (value == "headphone") { me.output = "headphone";}
	 if (value == "interphone") { me.output = "interphone";}
	 if (value == "speaker") { me.output = "speaker";}
	 return (me.output);
    },
    isActiveHeadphone : func () {
         if (me.output == "headphone"){return true;}
	 return false;
    },
    isActiveInterphone : func () {
         if (me.output == "interphone"){return true;}
	 return false;
    },
    isActiveSpeaker : func () {
         if (me.output == "speaker"){return true;}
	 return false;
    },
    toggleFilterID : func () {
         if (me.filterId) {me.filterId = false; return me.filterId; }
	 if (!me.filterId) {me.filterId = true; return me.filterId; }
    },
    setFilterID : func (value = true) {
         #defaults to true
	 me.filterId = true;
	 if (value == true)   { me.filterId = true; }
         if (value == false) { me.filterId = false;}
	 return me.filterId;
    },
    isActiveFilterID : func () {
         if (me.filterId) { return true;}
	 return false;
    },
    toggleBackup : func () {
    	 if (me.isDisabledBackup()) {me.backup = "backup"; return (me.backup);}
	 if (me.isEnabledBackup()) {me.backup = "norm"; return (me.backup);}
    },
    setBackup : func (value="norm") {
    	 #defaults to norm
	 me.backup = "norm";
	 if (value == "norm") { me.backup = "norm";}
	 if (value == "backup") { me.backup = "backup";}
	 return (me.backup)
    },
    isEnabledBackup : func () {
         if (me.backup == "backup") { return true; }
	 return false;
    },
    isDisabledBackup : func () {
         if (me.backup == "norm") { return true; }
	 return false;
    },
    getBackup : func () {
    	 return me.backup;
    },
    setVolumeInstrument : func (id) {
         me.volumeUpdate();
	 setprop("/instrumentation/acp["~id~"]/audio/volume", me.volume);
    },
    volumeUpdate : func () {
         var vol = 0 ;
         if (me.lastSelected == "vhf1"){ vol=getprop("/instrumentation/comm[0]/volume"); }
         if (me.lastSelected == "vhf2"){ vol=getprop("/instrumentation/comm[1]/volume"); }
         if (me.lastSelected == "vhf3"){ vol=getprop("/instrumentation/comm[2]/volume"); }
         if (me.lastSelected == "hf"){ vol=getprop("/instrumentation/hf/volume"); }
         if (me.lastSelected == "sat"){ vol=me.volumeSAT; }
         if (me.lastSelected == "pa"){ vol=me.volumePA; }
         if (me.lastSelected == "nav1"){ vol=getprop("/instrumentation/nav[0]/volume"); }
         if (me.lastSelected == "nav2"){ vol=getprop("/instrumentation/nav[1]/volume"); }
         if (me.lastSelected == "nav3"){ vol=getprop("/instrumentation/nav[2]/volume"); }
         if (me.lastSelected == "adf1"){ vol=getprop("/instrumentation/adf[0]/volume-norm"); }
         if (me.lastSelected == "adf2"){ vol=getprop("/instrumentation/adf[1]/volume-norm"); }
         if (me.lastSelected == "dme1"){ vol=getprop("/instrumentation/dme[0]/volume"); }
         if (me.lastSelected == "dme2"){ vol=getprop("/instrumentation/dme[1]/volume"); }	
         if (me.lastSelected == "mkr"){ vol=getprop("/instrumentation/marker-beacon/volume"); }
	 if (me.backup == "backup"){ vol=me.volumeBackup; }
	 if (vol == nil) {vol = 0;}
 	 vol = math.round (vol * 100);
	 me.volume = vol;
    },
    getLastSelected : func () {
         return me.lastSelected;
    },
    getVolume : func () {
         return me.volume;
    },
    getDisplay : func () {
    	 if (me.isDisabledBackup()){
	     	 return (me.getLastSelected()~": "~me.getVolume());
	};
    	 if (me.isEnabledBackup()){
	     	 return (me.getBackup()~": "~me.getVolume());
	};
    },
    update : func () {
    	   var fgcom = false;
	   var enabledCommRadio = 0;
	   if (me.isActiveVHF1()) {fgcom = true; enabledCommRadio = 0;}
	   if (me.isActiveVHF2()) {fgcom = true; enabledCommRadio = 1;}
	   if (me.isActiveVHF3()) {fgcom = true; enabledCommRadio = 2;}
	   if (me.isActiveHF())   {fgcom = true; enabledCommRadio = 3;}
	   #Engage COMM
	   setprop("/sim/fgcom/enabled",fgcom);
	   setprop("/controls/radios/comm-radio-selected",enabledCommRadio);
	   #Engage Audio
	   setprop("/instrumentation/nav[0]/audio-btn",me.isActiveNAV1());
	   setprop("/instrumentation/nav[1]/audio-btn",me.isActiveNAV2());
	   setprop("/instrumentation/nav[2]/audio-btn",me.isActiveNAV3());
	   setprop("/instrumentation/adf[0]/ident-audible",me.isActiveADF1());
	   setprop("/instrumentation/adf[1]/ident-audible",me.isActiveADF2());
	   setprop("/instrumentation/dme[0]/volume",me.isActiveDME1());
	   setprop("/instrumentation/dme[1]/volume",me.isActiveDME2());
	   setprop("/instrumentation/marker-beacon[0]/audio-btn",me.isActiveMKR());
    }
};

#define a class buffer: it stores a memory of every acp instrument's status,
#and define a memory object of such class, to operate globally
var buffer = { 
    instrument:std.Vector.new(),
    new:func () {
    	     var buffer = {parents:[buffer]};
	     buffer.instrument.clear();
    	     for (var index=0; index < stackSize; index=index+1){
    	     	 buffer.instrument.append(stack.new(index));
    	     };
    	     return (buffer);
    },
    update:func () {
    	     me.new();
    }
};
var memory = buffer.new(); 

#Stack Class with paPTT actions
var paPTT  = {
    id:0,
    new : func (id=nil) {
    	var paPTT = {parents:[stack, paPTT]};
	#id defaults to pilot's instrument (0)
    	if (id==nil) { id=0; }
    	if (id>stackSize-1) { id = 0; }
	paPTT.id = id;
	paPTT.loadInstrument(id);
	paPTT.setVolumeInstrument(id);
	paPTT.setCommAudio("pa");
	paPTT.setMic(true);
	return paPTT;
    },
    hold : func () {
    	me.setInstrument(me.id);
    },
    release :  func () {
    	memory.instrument.vector[me.id].setInstrument(me.id);
    }
};
#Stores last Pressed paPTT button to hold it and restores it on release
var lastPressedpaPTT=0;

##########################################################################
#									 #
#                        Public Methods				         #
# 	 								 #
##########################################################################


var dump = func (id=nil) {
   var object = stack.new(id);
   object.dump();
};

var getDisplay = func (id=nil) {
   var object = stack.new(id);
   return (object.getDisplay());
};

var updateVolumes = func() {
    #Note: It updates the master volume on each acp instrument, by calling them once
    for (var index=0; index < stackSize; index=index+1){
    	var object = stack.new(index);
    };
};

var update = func () {
    #Note: It updates the active ACP, by connecting its properties to the Lineage Systems
    var object = stack.new();
    object.update();
    memory.update();
};

var paPTTHold = func ( ){
    #gets ID of last pressed paPTT button, and restores IDs
    lastPressedpaPTT = getprop("/instrumentation/acp[0]/paPTT/pressed");
    for (var index=0; index < stackSize; index=index+1){
    	setprop ("/instrumentation/acp["~index~"]/paPTT/id", index);
    };
    var object = paPTT.new(lastPressedpaPTT);
    object.hold();
};

var paPTTRelease = func ( ){
    var object = paPTT.new(lastPressedpaPTT);
    object.release();
};

##Initializer
##Note: It runs an update on the active ACP once during initializing.
settimer (update, 0);
