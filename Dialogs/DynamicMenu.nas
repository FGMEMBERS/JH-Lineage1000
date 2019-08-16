# Overwrite the original menu
gui.menuBind("radio", "lineage1000.radio()");

var showDialog = func(name) {
    fgcommand("dialog-show", props.Node.new({ "dialog-name" : name }));
}

