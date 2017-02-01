#########################################################################
# delete the communication data set
#########################################################################

proc kill_comm_data_set {} {
	global out_3
	if {[file exists $out_3]} {
		 file delete $out_3
	}
}


#########################################################################
# handle data array
#########################################################################
proc dataHandler { mode } {
	global title_fields
	global title_fields_save
	global log
	if {$mode == "save" } {
#		puts $log [array get title_fields]
		array set title_fields_save [array get title_fields]
	}
	if {$mode == "retrieve"} {
		set title_fields $title_fields_save
	}
}

#########################################################################
# interface to the TB Data Structure
#########################################################################
proc setTBData {sheet field data } {
	global title_fields
	set title_fields($sheet\_TitleBlock_Text_$field) $data
}
proc getTBData {sheet field} {
	global title_fields
	set val "-"
	catch {set val $title_fields($sheet\_TitleBlock_Text_$field)}
	return $val
#	return $title_fields($sheet\_TitleBlock_Text_$field)
}
proc getTBDataName {sheet field} {
	global title_fields
	return title_fields($sheet\_TitleBlock_Text_$field)
}
proc setTBRData {sheet field number data } {
	global title_fields
	set title_fields($sheet\_RevisionBlock_Text_$field\_$number) $data
}
proc getTBRData { sheet field number} {
	global title_fields
	return $title_fields($sheet\_RevisionBlock_Text_$field\_$number)
}
proc getTBRDataName { sheet field number} {
	global title_fields
	return title_fields($sheet\_RevisionBlock_Text_$field\_$number)
}

proc saveTBData {} {
	global title_fields
	global saveTitleFields
	array unset saveTitleFields
	foreach name [array names title_fields] {
		set saveTitleFields($name) $title_fields($name)
	}
}
proc restoreTBData {} {
	global title_fields
	global saveTitleFields
	foreach name [array names saveTitleFields] {
		set title_fields($name) $saveTitleFields($name)
	}
}
#########################################################################
# copy global data from first sheet, assuming all data are the same
# (after running the macro all global data will(!) be the same on all sheets
#########################################################################

proc setGlobalData {} {
	global l_global_sequence
	foreach seq $l_global_sequence  {
		setTBData 0 $seq [getTBData 1 $seq]
#		set title_fields(0_TitleBlock_Text_$seq) $title_fields(1_TitleBlock_Text_$seq)
	}
}

#########################################################################
# get the value for an extended field definition
#########################################################################
proc getExtFieldDef {fieldName parameterName} {
	global entry_width
	global entry_alignment
	global extFieldDefInternal
	
	set retValue "??"
	#tk_messageBox -message "$fieldName§$parameterName [array names extFieldDefInternal]"

	#	tk_messageBox -message "$fieldName§$parameterName [lsearch [array names extFieldDefInternal] $fieldName§$parameterName]"
	if {[array names extFieldDefInternal "$fieldName§$parameterName"] != {} } {
		return $extFieldDefInternal($fieldName§$parameterName)
	} else {
		if {$parameterName == "entry_width"} {return $entry_width}
		if {$parameterName == "entry_alignment"} {return $entry_alignment}
		if {$parameterName == "Mode"} {return "optional"}
		if {$parameterName == "Help"} {return $fieldName}
		if {$parameterName == "entry_mode"} {return "enabled"}
		if {$parameterName == "text_width"} {return $entry_width}
		if {$parameterName == "text_height"} {return "2"}
		if {$parameterName == "pass3dProperties"} {return "No"}
		if {$parameterName == "Default"} {return "no default value given"}
	}
	return $retValue
}

#########################################################################
# get the template directory for the tb drawings
#########################################################################
proc getTemplateDirectory {} {
	global CATIA_TEMPLATES
	global where_am_i
	global TBConfig
	global env
	
	
	if {[info exists CATIA_TEMPLATES] == 0} then {return $where_am_i/config/custom/$TBConfig/templates}
	
	if {$CATIA_TEMPLATES == "dummy"} then {return $where_am_i/config/custom/$TBConfig/templates}
	# substitute environment variables

		
	set catTemplate $CATIA_TEMPLATES
	if {[string first "%" $catTemplate] > -1} then {
		set temp [split $catTemplate "%"]
		set envVar [lindex $temp 1]
		if {[lsearch [array names env] $envVar] > -1 } then {
			set catTemplate "[lindex $temp 0]$env($envVar)[lindex $temp 2]"
		} else {
			tk_messageBox -message [translate "check CATIA_TEMPLATES, environment variable not found: $envVar"]
		}
	}
	if {[file exists $catTemplate]} then {
		return "$catTemplate"
	} else {
		return $where_am_i/config/custom/$TBConfig/templates
	}
}

#########################################################################
# window on top of all windows
#########################################################################

proc putWindowOnTop {window} {
	global tcl_platform
	if {$tcl_platform(platform) == "windows"} then {
		wm attributes $window -topmost 1
	}
}

#########################################################################
# set copy cut and paste behavior
#########################################################################

proc setCopyCutPasteBehavior {} {
	global CutCopyPaste
	global os_type
	
	if {$CutCopyPaste == "OSDependant"} then {
		if {$os_type == "windows"} then {
			event add <<Copy>>  <Control-c>
			event add <<Paste>> <Control-v>
			event add <<Cut>>   <Control-x>
			event add <<Copy>>  <Control-C>
			event add <<Paste>> <Control-V>
			event add <<Cut>>   <Control-X>
		}
	}
	if {$CutCopyPaste == "Windows"} then {
		event add <<Copy>>  <Control-c>
		event add <<Paste>> <Control-v>
		event add <<Cut>>   <Control-x>
		event add <<Copy>>  <Control-C>
		event add <<Paste>> <Control-V>
		event add <<Cut>>   <Control-X>
	}

}

#########################################################################
# turn on callback / turnoff callback
#########################################################################

proc cbTurnOn {} {
	global callBackEnabled
	global title_fields
	if {$callBackEnabled == "yes"} then {
		trace variable title_fields w callBackFields
	}	
}

proc cbTurnOff {} {
	global callBackEnabled
	global title_fields
	if {$callBackEnabled == "yes"} then {
		trace vdelete title_fields w callBackFields
	}	
}
#########################################################################
# translate Â§ in temp data sets
#########################################################################
proc changeDelimiter {fileIn delOld delNew} {
	set f1 [open $fileIn r]
	set content [read $f1]
	close $f1
	set map $delOld
	lappend map $delNew
	set content [string map $map $content]
		
	set f1 [open $fileIn w]
	puts $f1 $content
	close $f1
}

proc modifyComFiles {mode} {
	global in
	global out
	global out_2
	global out_3

	if {$mode == "init"} then {
		if {[file exists $in]} then {
			changeDelimiter $in "?+-!?" "§"
		}
		if {[file exists $out]} then {
			changeDelimiter $out  "?+-!?" "§"
		}
		if {[file exists $out_2]} then {
			changeDelimiter $out_2  "?+-!?" "§"
		}
		if {[file exists $out_3]} then {
			changeDelimiter $out_3  "?+-!?" "§"
		}
	} else {
		if {[file exists $in]} then {
			changeDelimiter $in "§" "?+-!?" 
		}
		if {[file exists $out]} then {
			changeDelimiter $out  "§" "?+-!?"
		}
		if {[file exists $out_2]} then {
			changeDelimiter $out_2  "§" "?+-!?"
		}
		if {[file exists $out_3]} then {
			changeDelimiter $out_3  "§" "?+-!?"
		}
	
	}

}

proc tbExit {} {
	modifyComFiles "exit"
	exit
}