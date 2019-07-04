#ACPSelected identifies which acp of the stack is currently active
var ACPSelected = func() {
     var id1 = getprop ("/instrumentation/acp[0]/active");
     var id2 = getprop ("/instrumentation/acp[1]/active");
     var id3 = getprop ("/instrumentation/acp[2]/active");
     if (id1) {return (0)};
     if (id2) {return (1)};
     if (id3) {return (2)};
     return (0);
}

var test = func () {
       var active = ACPSelected();
       var activeMic = getprop ("/instrumentation/acp["~active~"]/comm/mic");
       print ("Works");
       print (activeMic);       
}
