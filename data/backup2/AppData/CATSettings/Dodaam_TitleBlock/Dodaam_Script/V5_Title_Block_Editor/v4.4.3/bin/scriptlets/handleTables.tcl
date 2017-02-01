#########################################################################
# edit tables in the drawing
#########################################################################
proc insertRow {count} {
	global tab
	if {[$tab curselection] ==""} then {
		tk_messageBox -message [translate "No Cell selected, select a cell!"]
	} else {
		set rowAct [lindex [split [$tab curselection] ","] 0]
		$tab insert rows $rowAct $count
	}
}
proc deleteRow {} {
	global tab
	if {[$tab curselection] ==""} then {
		tk_messageBox -message [translate "No Cell selected, select a cell!"]
	} else {
		set rowAct [lindex [split [$tab curselection] ","] 0]
		$tab delete rows $rowAct 1
	}
}
proc helpTable {} {
	tk_messageBox -message [translate "Insert or delete Rows, Mouse Button 2 for options"]
}

proc editTable { sheet table } {
	global ary
	global sheetTableInfo
	global background_colour
	global first
	global last
	global numRows
	global numCols
	global sheetStream
	global tempTable
	global tab
	global editTabWindow
	global os_type
	
	set tempTable $table
	
	set sheetStream $sheet

	package require Tktable
	set editTabWindow [toplevel .tableEditor]
	wm title $editTabWindow "TitleBlock Table Editor"
    
	putWindowOnTop $editTabWindow
	 
	if {$os_type == "windows"} then {
		grab .tableEditor
	}
	
	set mf [MainFrame $editTabWindow.mf  -textvariable statusInfo -background $background_colour]
	pack $mf -in $editTabWindow

#   provide a toolbar
	set toolbar [$mf addtoolbar]
	set bBox [ButtonBox $toolbar.bbox -spacing 0 -padx 1 -pady 1 -background $background_colour]
	$bBox add -image pic_insertRow -command {insertRow 1}
	$bBox add -image pic_deleteRow -command deleteRow
	$bBox add -image but_help -command helpTable

#	set binsertRow [ButtonBox $toolbar.but1 -image pic_insertRow]
	$mf showtoolbar 0 1
#	pack $binsertRow -in $toolbar
    pack $bBox
	
	$mf showstatusbar status
	set body [$mf getframe]

	set statusInfo $table

	set numRows 0
	set numCols 0
	array unset ary
	if {[array exists colWidths]} {array unset colWidths}
	
	set first [lindex $sheetTableInfo($sheetStream\_$table) 0]
	set last  [lindex $sheetTableInfo($sheetStream\_$table) end]

	foreach tabLine $sheetTableInfo($sheetStream\_$table) {
#	tk_messageBox -message $tabLine

		if {[string first ";" $tabLine  ] > 0} {
			set temp [split $tabLine ";"]
			set numCols [expr [llength $temp] - 1]
			for {set i 1} {$i < [llength $temp]} {incr i} {
				set ary($numRows,[expr $i -1]) [lindex $temp $i]
			}
			incr numRows

		}
	}
	
	for {set i 0} {$i < $numCols} {incr i} {
		set colWidths($i) 0
		for {set j 0} {$j < $numRows} {incr j} {
			set length [string length $ary($j,$i)] 
			if { $length > $colWidths($i)} { set colWidths($i) $length}   
		}
		set colWidths($i) [expr $colWidths($i) + 2]
	}

	set tab [table $body.table§$sheetStream -rows $numRows -cols $numCols -variable ary \
		-yscrollcommand {.tableEditor.mf.frame.sy set} -xscrollcommand {.tableEditor.mf.frame.sx set} \
	    -maxwidth 1000 -background $background_colour \
	]

	# adjust the width of the columns
	for {set i 0} {$i < $numCols} {incr i} {
		$tab width $i $colWidths($i)
	}
	
	$tab tag col LEFT 0 1 2
	$tab tag col RIGHT 3

#	$tab width 0 30 1 15 2 80 3 15 5 15


	scrollbar $body.sy -command [list $tab yview]
	scrollbar $body.sx -command [list $tab xview] -orient horizontal
	grid $tab $body.sy -sticky news
	grid $body.sx -sticky ew
	menu $editTabWindow.m -tearoff 0

	$editTabWindow.m add command -label "Insert row above" -command {insertRow -1}
	$editTabWindow.m add command -label "Insert row below" -command {insertRow 1}
	$editTabWindow.m add command -label "Delete row" -command deleteRow

	bind $tab <Button-3> {
		global tab
		global editTabWindow
		tk_popup $editTabWindow.m [winfo pointerx %W] [winfo pointery %W]
	}
	
	button $body.butok  -image but_ok -height 15 -width 75 -background $background_colour \
			-command {
				global tempTable
				global tab
				set table $tempTable
#			tk_messageBox -message $table

				# rebuild list for the table according to entries
				set sheetTableInfo($sheetStream\_$table) $first
#				tk_messageBox -message [$tab cget -rows]
				for {set j 0} {$j < [$tab cget -rows]} {incr j} {
					set temp "TitleBlock_Text_TData_data§"
                    for {set i 0} {$i < $numCols} {incr i} {
						set temp "$temp;[$tab get $j,$i]"
#                    	set temp "$temp;$ary($j,$i)"
                    }
                   	lappend sheetTableInfo($sheetStream\_$table) $temp

				}
               	lappend sheetTableInfo($sheetStream\_$table) $last
		#		tk_messageBox -message "$sheetStream: $sheetTableInfo($sheetStream\_$table)"

				destroy .tableEditor
			}
	button $body.butcan  -image but_can -height 15 -width 75 -background $background_colour \
			-command { 	destroy .tableEditor  }

    grid $body.butok
    grid $body.butcan

}
#########################################################################
# write tables to file
#########################################################################
proc streamTableData { stream sheet } {
	global sheetTableInfo
	global sheetTables
	global sheetTableNames
 	set tabAvailable [lsearch $sheetTables $sheet]

	if { $tabAvailable > -1 } {

		foreach table $sheetTableNames($sheet) {
			foreach tabLine $sheetTableInfo($sheet\_$table) {
				if {$tabLine != ""} {puts $stream $tabLine}
			}
		}
	}
}
