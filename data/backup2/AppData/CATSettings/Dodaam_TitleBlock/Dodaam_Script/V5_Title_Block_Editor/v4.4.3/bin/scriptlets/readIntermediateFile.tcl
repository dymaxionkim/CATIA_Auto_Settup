#########################################################################
# Results from VBscript
# Read line by line, store. Each line contains: Catia Text Name§Value
# Map Catia Component Name to internal variables (cut off .n + add index of sheet)
# e.g. cat_index_title_block_engineer.1 -> 1_cat_index_title_block_engineer
#
# handling for change history
# storage in list change_history
# variable names must be cat_title_block_change_"type"_n
# the actual change entry has to be 0, history starting with 1
#########################################################################
proc readIntermediateFile {} {
	global in
	global numsheets
	global num_changes
	global compat_mode
	global sheetTables
	global passThrough
	global generative_models
	global sheetTableInfo
	global sheetTableNames
	global sheet_names
	global num_catia_parms
	global view_names
	global catia_parameter_on_sheet
	global bom_info
	global bom_show
	global generative_fields
	global catia_active_sheet
	global generative_models
	global catia_active_sheet
	global catia_names_stored
	global title_fields
	global change_fields revisions
	global change_number
	global TBConfig
	global sheetPaperSize
	global TBLocaleDecSep
	global bom_type
	
	set numsheets 0
	set num_changes -1
	set compat_mode "Nothing"

	set generative_models ""
	set sheetTables ""
	set passThrough ""
	
	global titleBlockFieldsCB

	set f1 [open $in r]
	while {![eof $f1]} {
	    gets $f1 line
		if {[string range $line 0 7] == "TBConfig"} {
			set items [split $line "§"]
			set TBConfig [lindex $items 1]
		}
		
		if {[string range $line 0 14] == "TBLocaleDecSep§"} {
			set items [split $line "§"]
			if {[string trim [lindex $items 1]] == "0.75"} then {
				set TBLocaleDecSep "."
			} else {
				set TBLocaleDecSep ","
			}
		}
		
	    if {[string range $line 0  9] == "cat_sheet§" } {
	    	set items [split $line "§"]
	    	incr numsheets
			set sheetTableNames($numsheets) ""
	    	set num_catia_parms 0
	    	set sheet_names($numsheets) [lindex $items 1]
	    	set view_names($numsheets)  [lindex $items 2]
	    	set catia_parameter_on_sheet($numsheets) 0
	    }
		# check for PaperSizes
	    if {[string range $line 0 21] == "cat_active_sPaperSize§"} {
	    	set items [split $line "§"]
	    	set paperSize [lindex $items 1]
			set sheetPaperSize $paperSize
		}
		
		set bom_show($numsheets) 1

	    if {[string range $line 0  12] == "cat_bom_info§" } {
	    	set items [split $line "§"]
	    	set bom_info($numsheets) [lindex $items 1]
			set bom_show($numsheets) [lindex $items 2]
			set bom_type($numsheets) [lindex $items 3]
			
			if {$bom_show($numsheets) == 0} then {
				set bom_show($numsheets) 1
			} else {
				set bom_show($numsheets) 0
			}
	    }

	    if {[string range $line 0  19] == "cat_generative_sheet" } {
	    	set items [split $line "§"]
			set temp [lindex $items 0]
			set field [string range $temp 21 end]
	    	set generative_fields($numsheets\_$field) [lindex $items 1]
	    	set sheet0 0
	    	set generative_fields($sheet0\_$field) [lindex $items 1]
	    }

	    if {[string range $line 0  16] == "cat_configuration" } {
	    	set items [split $line "§"]
			set compat_mode [lindex $items 1]
	    }
	    if {[string range $line 0  21] == "cat_generative_3dmodel"} {
	    	set items [split $line "§"]
	#		each 3d models once in the list
	    	if {[lsearch -exact $generative_models [lindex $items 3]] < 0 } {
	    		 lappend generative_models [lindex $items 3]
	    	}
	    }

	    if {[string range $line 0  15] == "cat_active_sheet"} {
	    	set items [split $line "§"]
	    	set catia_active_sheet [lindex $items 1]
	    }

	#	check for passthrough data
	    if {[string range $line 0  10] == "passthrough"} {
	    	lappend passThrough $line
	    }


		# check for table data
	    if {[string range $line 0 26] == "TitleBlock_Text_TData_Start"} {
	    	set items [split $line "§"]
	    	set tname [lindex $items 1]
	    	lappend sheetTables $numsheets
	    	lappend sheetTableNames($numsheets) $tname

	    	set sheetTableInfo($numsheets\_$tname) $line

			while {[string range $line 0 24] != "TitleBlock_Text_TData_End"} {
	    		gets $f1 line
		    	lappend sheetTableInfo($numsheets\_$tname) $line
	    	}
		}

	    if {[string range $line 0 14] == "TitleBlock_Text" || [string range $line 0 17] == "RevisionBlock_Text"} {
	    	set items [split $line "§"]
	    	set catia_field [lindex $items 0]
	    	set temp [split $catia_field "."]
	    	set current_field "$numsheets\_[lindex $temp 0]"
	    	set catia_names_stored($current_field) $catia_field
	    	set title_fields($numsheets\_[lindex $temp 0]) [lindex $items 1]

			#     check for number of changes
			if {[info exists change_fields]==1} {

	            if {[string range $line 0 21] == "RevisionBlock_Text_Rev"} {
	                set temp [split $current_field "_"]
	                set change_number [lindex $temp 4]
	                set ipos [lsearch $revisions $change_number]
	                if {$ipos > $num_changes} {set num_changes $ipos}
	            }
	        }
	    }
		

	}
	close $f1
	incr num_changes
	if {$generative_models == "" } {
		set generative_models "No 3D model linked"
	}

	# allow a dynamic handling and managing of tb data
	
#	for {set i 0} {$i <= $numsheets} {incr i} {
#		array unset titleBlockFieldsCB

#		foreach name [array names title_fields "$i\_T*"] {
#			set temp [split $name "_"]
#			set titleBlockFieldsCB([lindex $temp 3]) $title_fields($name)
#		}
#		if {$i == 0} then {
#			callBackReadIntermediateFile "global"
#		} else {
#			callBackReadIntermediateFile "fields"
#		}
#		foreach name [array names title_fields "$i\_T*"] {
#			set temp [split $name "_"]
#			set title_fields($name) $titleBlockFieldsCB([lindex $temp 3]) 
#		}
		#set title_fields(1_TitleBlock_Text_Geprueft) "Michael"
#	}
}

