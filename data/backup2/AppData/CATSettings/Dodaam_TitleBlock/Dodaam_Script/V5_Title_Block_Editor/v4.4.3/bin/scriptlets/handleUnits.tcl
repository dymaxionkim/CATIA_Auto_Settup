#########################################################################
# handle unit conversions
# sets a field with a current Value (incl. Unit) to a value from 3d (mks)
#########################################################################
proc isNumeric x {expr ![catch {expr $x*1}]}

proc convUnits { field curValue mksUnitValue} {
	global u_$field
	global dp_$field
	global showUnit_$field
	global TBLocaleDecSep
	if {$TBLocaleDecSep == "."} then {
		set mksValue [string map {"," ""} $mksUnitValue]
	}
	if {$TBLocaleDecSep == ","} then {
		set mksValue [string map {"," "."} $mksUnitValue]
	}
#	set mksValue [string map {"," "."} $mksUnitValue]
	if {[info exists u_$field]} then {
		for {set i 0} {$i < [string length $curValue]} {incr i}  {
			if {[isNumeric [string range $curValue 0 $i]]} then {
			} else {
				set curWert [string trim [string range $curValue 0 [expr $i-1]]]
				set curUnit [string trim [string range $curValue $i end]]
				break
			}
		}
		set factor 1
		# get factors from array
		foreach l [subst $[subst u_$field]] {
			if {[lindex $l 0] == $curUnit} {set factor [lindex $l 1]}
		}
		set f "f"
		set fString "%.[subst $[subst dp_$field]]$f"
		if {[subst $[subst showUnit_$field]] == "yes"} then {
			set result "[format $fString [expr $factor * $mksValue]] $curUnit"
		} else {
			set result "[format $fString [expr $factor * $mksValue]]"
		}
		if {$TBLocaleDecSep == ","} then {
			set result [string map {"." ","} $result]
		}

		return $result
	} else {
		return $curValue
	}
}
#########################################################################
# stream unit info to file
#########################################################################
proc unitStreamer {stream} {
	global u_Units
	if {[info exists u_Units]} {
		# save unit fields, unit symbols, unit factors, precision, show info
        set tempUnit ""
        set tempUnitSymbols ""
        set tempUnitDP ""
        set tempUnitShow ""
        set tempUnitFactor ""

		foreach unit $u_Units {
			global u_$unit
			global def_$unit
			global dp_$unit
			global showUnit_$unit

			set tempUnit "$unit;$tempUnit"
			set tempUnitSymbols "[subst $[subst def_$unit]];$tempUnitSymbols"
			set tempUnitDP "[subst $[subst dp_$unit]];$tempUnitDP"
			set tempUnitShow "[subst $[subst showUnit_$unit]];$tempUnitShow"

			set factor 1
			foreach l [subst $[subst u_$unit]] {
				if {[lindex $l 0] == [subst $[subst def_$unit]]} {set factor [lindex $l 1]}
			}
			set tempUnitFactor "$factor;$tempUnitFactor"

		}
		puts $stream "cat_global_info_UnitFields§$tempUnit"
		puts $stream "cat_global_info_UnitSymbols§$tempUnitSymbols"
		puts $stream "cat_global_info_UnitDP§$tempUnitDP"
		puts $stream "cat_global_info_UnitFactor§$tempUnitFactor"
		puts $stream "cat_global_info_UnitShow§$tempUnitShow"

	}
}
