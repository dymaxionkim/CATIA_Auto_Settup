#########################################################################
# copy the sheet data to the actual sheet
#########################################################################

proc copy_sheet_data {widget} {
	global log
	global title_fields
	global copy_selector
	global sheet_names
	global active_sheet
	set temp [split $widget "§"]
	if {$copy_selector($active_sheet) !=""} {
		set copy_from_sheet ""
		foreach sheet_index [array names sheet_names] {
			if {$sheet_names($sheet_index) == $copy_selector($active_sheet) } {
				set copy_from_sheet $sheet_index
			}
		}
		foreach field [array names title_fields] {
			set temp [split $field "_"]
			if {[lindex $temp 0] == $active_sheet} {
#				exchange the first part within the field name
				set copy_from_field $copy_from_sheet[string range $field [string first "_" $field] end]
				set title_fields($field) $title_fields($copy_from_field)
			}
		}
	}
}

#########################################################################
# save sheet + drawing data to disk
#########################################################################

proc store_sheet_to_disk {sheet} {
	global log
#	get file
	set types {{{Text Files}       {.txt}        }}

	set filename [tk_getSaveFile -filetypes $types -initialfile "sheet_data.txt"]

	if {$filename != ""} {
   	  set f1 [open $filename w]
	  store_sheet $sheet $f1
	  close $f1
	}
}

proc store_sheet {sheet f1} {
	global log
	global title_fields
	global l_sequence
	global l_global_sequence
	global l_change_sequence
	global num_changes
	global revisions

	foreach seq $l_sequence {
  		puts $f1  TitleBlock_Text_$seq§$title_fields($sheet\_TitleBlock_Text_$seq)
	}
	foreach seq $l_global_sequence {
  		puts $f1  TitleBlock_Text_$seq§$title_fields(0_TitleBlock_Text_$seq)
	}

#       	process changes
	for {set i 0} {$i < $num_changes} {incr i} {
		foreach j  $l_change_sequence {
			puts $f1 RevisionBlock_Text_$j\_$i§$title_fields($sheet\_RevisionBlock_Text_$j\_[lindex $revisions $i])
		}
	}
}


#########################################################################
# get sheet from disk
#########################################################################

proc get_file_from_disk {sheet} {
	global log
#	get file
	set types {{{Text Files}       {.txt}        }}

	set filename [tk_getOpenFile -filetypes $types -initialfile "sheet_data.txt"]

	if {$filename != ""} {
   	  set f1 [open $filename r]
	  open_sheet $sheet $f1
	  close $f1
	}
}


proc open_sheet {sheet f1} {
	global log
	global title_fields
	global l_sequence
	global l_change_sequence
	global num_changes

	while {![eof $f1]} {
    		gets $f1 line
	    	if {[string range $line 0 14] == "TitleBlock_Text" || [string range $line 0 17] == "RevisionBlock_Text"} {
    			set items [split $line "§"]
    			set title_fields($sheet\_[lindex $items 0]) [lindex $items 1]
#			That's a bit to much (doesn't matter)
    			set title_fields(0_[lindex $items 0]) [lindex $items 1]
		}
	}
}
