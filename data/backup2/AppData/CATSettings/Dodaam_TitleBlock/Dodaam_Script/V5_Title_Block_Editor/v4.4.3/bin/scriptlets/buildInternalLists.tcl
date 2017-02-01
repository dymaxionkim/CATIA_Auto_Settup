proc buildInternalLists { } {
	global num_fields
	global fields
	global l_sequence
	global l_texts
	global l_entry_type
	global l_mode
	global num_global_fields
	global global_fields
	global l_global_sequence
	global l_global_texts
	global l_global_entry_type
	global l_global_mode
	global num_change_fields
	global change_fields
	global l_change_sequence
	global l_change_texts
	global l_change_entry_type
	global l_change_mode
	global change_enabled
	global num_changes
	global extFieldDef
	global extFieldDefInternal
	global revisions
	
	set l_sequence ""
	set l_texts ""
	set l_entry_type ""
	set l_mode ""
	set l_set_sequence ""
	set l_set_texts ""
	set l_set_entry_type ""
	set l_set_mode ""
	set l_global_sequence ""
	set l_global_texts ""
	set l_global_entry_type ""
	set l_global_mode ""
	set l_change_sequence ""
	set l_change_texts ""
	set l_change_entry_type ""
	set l_change_mode ""
	
	if {[array exists extDefFieldsInternal]} { unset extDefFieldsInternal }
	# build internal lists

	
	set num_fields [array size fields]
	for {set i 1} {$i <= $num_fields} {incr i} {
		lappend l_sequence   [lindex $fields($i) 0]
		lappend l_texts      [lindex $fields($i) 1]
		lappend l_entry_type [lindex $fields($i) 2]
	    if {[llength $fields($i)] < 4 } then {
	        lappend l_mode "optional"
	    } else {
	        lappend l_mode [lindex $fields($i) 3]
	    }

	}
	if {[info exists global_fields]==1} {
		set num_global_fields [array size global_fields]
		for {set i 1} {$i <= $num_global_fields} {incr i} {
			lappend l_global_sequence   [lindex $global_fields($i) 0]
			lappend l_global_texts      [lindex $global_fields($i) 1]
			lappend l_global_entry_type [lindex $global_fields($i) 2]

			if {[llength $global_fields($i)] < 4 } then {
	            lappend l_global_mode "optional"
	        } else {
	            lappend l_global_mode [lindex $global_fields($i) 3]
	        }

		}

	} else {
		set num_global_fields 0
		set l_global_sequence 	""
		set l_global_texts 	""
		set l_global_entry_type ""
	}

	# change fields configured ?
	if {[info exists change_fields]==1} {
		set change_enabled  "true"
	    set num_change_fields [array size change_fields]
	    for {set i 1} {$i <= $num_change_fields} {incr i} {
	        lappend l_change_sequence   [lindex $change_fields($i) 0]
	        lappend l_change_texts      [lindex $change_fields($i) 1]
	        lappend l_change_entry_type [lindex $change_fields($i) 2]
	    }
	} else {
		set change_enabled  "false"
		set num_changes -1
	}
	
	if {[array exists extFieldDef]} {
		foreach fieldName [array names extFieldDef] {
			foreach parTwin $extFieldDef($fieldName) {
				set temp [split $parTwin "="]
				set parName [lindex $temp 0]
				set parValue [string trim [lindex $temp 1] \"]
				set extFieldDefInternal($fieldName§$parName) $parValue
			}
		}
	}
}