#########################################################################
# NLS Support
#########################################################################
proc translate {in_message} {
	global messages
	if [info exists messages(\"$in_message\")] {
		return $messages(\"$in_message\")
	} else {
		return $in_message
	}
}

#**************************************************************************
# Get NLS, store data in messages array
#**************************************************************************
proc get_nls {} {
	global messages
	global where_am_i
	global language
	set nls_data_set "$where_am_i/config/nls/$language/messages.cfg"
	set nls_data_set [file nativename $nls_data_set]

	if {[file exists $nls_data_set]} {
		set f1 [open $nls_data_set r]
		while {![eof $f1]} {
    		gets $f1 line
    		set items [split $line "="]
    		set messages("[string trim [lindex $items 0]]") [string trim [lindex $items 1]]
		}
		close $f1
	}
}