if {[catch {package require Tcl 8.2}]} return
global tcl_platform
#package ifneeded Tktable 2.8  [list load [file join $dir Tktable28.dll] Tktable]
if {[string range $tcl_platform(os) 0 2] == "Win" } then {
	package ifneeded Tktable 2.9  [list load [file join $dir Tktable29.dll] Tktable]
} else {
	package ifneeded Tktable 2.9  [list load [file join $dir libTktable2.9.aix.so] Tktable]
}
