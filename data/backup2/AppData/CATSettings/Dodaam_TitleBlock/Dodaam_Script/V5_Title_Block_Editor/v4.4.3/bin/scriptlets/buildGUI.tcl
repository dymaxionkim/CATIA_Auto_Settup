############################################################
# provide the gui for the tb macro
############################################################
proc buildGUI {} {
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
	global change_number
	global version
	
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


	global screen_height
	global screen_width 
	global change_height
	global change_width 
	global dwgdata_height 
	global dwgdata_width 
	global entry_width
	global background_colour
	global dateUppercase
	global modeMandatory
	global showMenuConfig
	global showMenuAllFrom3D
	global CATIA_TEMPLATES
	global TBConfig
	global sheet_dirty
	
	global emptyChar
	
	global showButtonBox
	
	global notebook
	global frame_new
	global fbom
	global fbom1
	global fbom2
	global fbom3
	global modify_bom
	global preselectModifyBom 
	global modeBom
	global bom_type
	
	global listOfTextFields
	
	global wButtonOk
	
	global changePanelActive 
	set changePanelActive 0
	
	global showBomMode

	
#	bind Entry <FocusOut> {
		#tk_messageBox -message %W
#		set temp [split %W "§"]
		#tk_messageBox -message [llength $temp]
#		if {[llength $temp] == 7} then {
#			guiFieldCallBack [lindex $temp 6] [lindex $temp 4] [lindex $temp 2] [lindex $temp 5]
			#tk_messageBox -message [lindex $temp 2] 
			#tk_messageBox -message [lindex $temp 4]
#		}
#	}

	cbTurnOn
	
	wm withdraw .
	set top [toplevel .t]

	# handle closing event
	
	wm protocol $top "WM_DELETE_WINDOW" {
		set f1 [open $out w]
		puts $f1 "work§ko"
		close $f1
		kill_comm_data_set
		tbExit
	}

	#keep the window on top
	putWindowOnTop $top

	if {$TBConfig == "standard"} then {
		wm title $top "CATIA title block editor $version"
	} else {
		wm title $top "CATIA title block editor $version - $TBConfig"
	}
	$top configure -background $background_colour

	#set mf [MainFrame $top.mf]
	#set w [$mf getframe]
	
	set w [frame $top.main -background $background_colour]
	pack $w -in $top -fill x 

	if {$showButtonBox == "yes"} then {
		pack [Separator $w.sep0 -orient horizontal] -side top -fill x -expand true
		set f [ButtonBox $w.toolbar -background $background_colour -spacing 0]
		$f add -image but_open	-helptext [translate {Get content of current sheet from disk}] \
			-command {get_file_from_disk $active_sheet} -relief flat
		$f add -image but_save  -helptext [translate {Save content of current sheet to disk}]  \
			-command {store_sheet_to_disk $active_sheet} -relief flat
		$f add -image but_from3d  -helptext [translate {Show the 3d master models}] \
			-command {show_3d_master_models } -relief flat
		if {$showMenuAllFrom3D == "true"} then {
			$f add -image but_allfrom3d  -helptext [translate {Accept all 3d data}] \
				-command {acceptAll3dEntries } -relief flat
		}

		if {$compat_mode == "td1"} then {
			$f add -image but_td1  -helptext [translate {Show td1 parameters managed by macro}]  \
				-command {show_td1_config} -relief flat
		}
		if {$showMenuConfig == "true"} then {

			$f add -image but_config  -helptext [translate {"Options"}] \
				-command {setTBOptions } -relief flat
		}
		$f add -image but_help  -helptext [translate {Show doc}]  \
			-command {
				exec "$env(COMSPEC)" /c  start [file nativename "$where_am_i/doc/doc.pdf"]
			} -relief flat

		pack $f -anchor w
		pack [Separator $w.sep1 -orient horizontal] -side top -fill x -expand true
	}

	frame $w.up			-background $background_colour
	frame $w.drawing	-background $background_colour
	frame $w.middle    	-background $background_colour

	set sw  	[ScrolledWindow   $w.middle.sw   -background $background_colour ]
	set sf 		[ScrollableFrame  $sw.sf    	 -background $background_colour -height $screen_height -width $screen_width]
	$sw setwidget $sf
	#pack $sw -in $w.middle -fill both -expand yes -anchor center
	pack $sw -in $w.middle


	set notebook_frame [$sf getframe]


	frame $w.bottom			-background $background_colour
	frame $w.bottom.left	-background $background_colour
	frame $w.bottom.right	-background $background_colour

	pack $w.up $w.drawing $w.middle $w.bottom -in $w -anchor center -fill x -expand yes
	#pack $w.up $w.drawing $w.middle $w.bottom -in $w -anchor center -pady 20

	#########################################################################
	# global fields (only if available)
	#########################################################################
	if {$num_global_fields != 0} {
		set sheet 0
		set active_sheet 0
		set sw1 [ScrolledWindow   $w.drawing.sw1 -background $background_colour]
		set sf1 [ScrollableFrame  $sw1.sf1    	 -background $background_colour -height $dwgdata_height -width $dwgdata_width]
		$sw1 setwidget $sf1
		set sf1_frame [$sf1 getframe]

		set lf_top [TitleFrame $sf1_frame.lf_top -text [translate {Drawing Data}] -background $background_colour]


		set lf_top_frame [$lf_top getframe]
		pack $lf_top -in $sf1_frame
		pack $sw1 -in $w.drawing

		set last_row 0

		foreach seq $l_global_sequence cur_text $l_global_texts e_type $l_global_entry_type mandatory $l_global_mode {
			label $lf_top_frame.lab_seq_$seq -text $cur_text -background $background_colour

			set f [frame $lf_top_frame.f$seq -background $background_colour ]
			gen_entry_field  $f $sheet $seq $e_type normal
			if { [getExtFieldDef $seq "Mode"] != "hidden"} {
				grid configure $lf_top_frame.lab_seq_$seq   -column 0 -row $last_row   -sticky e

				grid configure $f   -column 1 -row $last_row   -sticky w
				incr last_row
			}
		}
	}

	pack $w.bottom.left $w.bottom.right -in $w.bottom -side left -ipadx 20

	set notebook [NoteBook $notebook_frame.notebook -background $background_colour]

	pack $notebook -in $notebook_frame -anchor center -fill x

	set active_tab 0


		
	for {set sheet 1} {$sheet <= $numsheets} {incr sheet} {

		global [subst modeBoms_$sheet]
		set modeBoms_$sheet "none"
	
		set sheet_dirty($sheet) 0
	#########################################################################
	# Create the tabs for the sheets
	#########################################################################

		set title $sheet_names($sheet)
		set tab_act [$notebook insert end $sheet -text $title \
			-raisecmd {
				set active_sheet [$notebook raise]
			} ]
		set last_row 0

		#########################################################################
		# copy selector
		#########################################################################

		if {$numsheets >1} {

			label $tab_act.copy_sheet -text [translate {Copy data from}] -background $background_colour
			grid configure $tab_act.copy_sheet -pady 6 -column 0 -row $last_row -sticky e

			set values ""
			foreach i [array names sheet_names]  {
				if {$i != $sheet} {
					set values "$values \"$sheet_names($i)\""
				}
        	}
			set f [frame $tab_act.copy -background $background_colour]

	        ComboBox $f.change_combo -values $values -textvariable copy_selector($sheet) -width 18
			button $f.change_but_§$sheet -image but_data_copy -height 10 -width 10

			pack $f.change_combo $f.change_but_§$sheet  -in $f -side left

			grid configure $f -pady 6 -column 1 -row $last_row -sticky w
			bind $f.change_but_§$sheet <Button-1> { copy_sheet_data %W }

		}

		incr last_row

		#########################################################################
		# Normal fields
		#########################################################################

		foreach seq $l_sequence cur_text $l_texts e_type $l_entry_type mandatory $l_mode {
			label $tab_act.lab_seq_$seq -text $cur_text -background $background_colour

			set f [frame $tab_act.f$seq -background $background_colour ]
			gen_entry_field  $f $sheet $seq $e_type normal
			if { [getExtFieldDef $seq "Mode"] != "hidden"} {
				grid configure $tab_act.lab_seq_$seq   -column 0 -row $last_row   -sticky e
				grid configure $f   -column 1 -row $last_row   -sticky w
				incr last_row
			}

		}

		#########################################################################
		# change/revision fields
		# the fields within the catia title block start with *_0
		# a new entry shifts all entries up and inserts a blank one
		#########################################################################

		if {$change_enabled == "true" } {
			label $tab_act.lab_chng   -text [translate {Revision infos}] -background $background_colour
			grid configure $tab_act.lab_chng -column 0 -row $last_row -sticky e
			button $tab_act.check_change§$sheet -image but_change -height 8 -width 50 -background $background_colour

	        bind $tab_act.check_change§$sheet <Button-1> {

	#        	dataHandler {"save"}

	            set widget %W
	            set temp [split $widget "§"]
	            set sheetact  [lindex $temp 1]
			
				set changePanelActive 1
				guiChangePanel $widget $sheetact %X %Y
				set changePanelActive 0
				set xKoord %X
				set yKoord %Y


			}
			
	        grid configure $tab_act.check_change§$sheet -column 1 -padx 20 -row $last_row -sticky w
	        incr last_row

		}
		#
		#########################################################################
		# check for tables display a button for each table
		#########################################################################
	 	set tabAvailable [lsearch $sheetTables $sheet]

		if { $tabAvailable > -1 } {

			foreach table $sheetTableNames($sheet) {
				set temp [split $table "_"]
				set displayName [lindex $temp [expr [llength $temp] -1]]
	            label $tab_act.lab_tab§$table   -text "[translate {Edit:}]$displayName" -background $background_colour
	            grid configure $tab_act.lab_tab§$table -column 0 -row $last_row -sticky e
	            button $tab_act.check_tab§$sheet§$table -image but_change -height 8 -width 50 -background $background_colour
	            grid configure $tab_act.check_tab§$sheet§$table -column 1 -row $last_row -sticky w

	            incr last_row

	            bind $tab_act.check_tab§$sheet§$table <Button-1> {

		            set widget %W
	    	        set temp [split $widget "§"]
	        	    set sheetact  [lindex $temp 1]
	        	    set tname [lindex $temp 2]
					editTable $sheetact $tname
	                # tk_messageBox -message "$tname: not supported Yet"
	                # display all tables in one scrolled window?
	                #
	    #           set sheetTableInfo($sheetact\_$tname) $line
	            }
			}
		}

		#########################################################################
		# Active sheet --> new drawing frame
		#########################################################################

		if {$title == $catia_active_sheet} {
			set active_tab [expr $sheet -1]
			label $tab_act.lab_frame -text [translate {New Drawing Frame}] -background $background_colour
			grid configure $tab_act.lab_frame -column 0 -row $last_row -sticky w

			set search [file nativename "[getTemplateDirectory]/*.CATDrawing"]
			set search [string map {"\\" "/"} $search]
			set cat_frames [glob $search]
			set frame_list {"keep frame"}
			foreach frame $cat_frames {
				set item [file tail $frame]
				set item [file rootname $item]
				lappend frame_list $item
	 		}
			set frame_new "keep frame"
			set f [frame $tab_act.frame -background  $background_colour]
			ComboBox $f.combo -values $frame_list -textvariable frame_new \
	                	                  -width 18 -dropenabled 1 -dragenabled 1 -background $background_colour
			#wm attributes $f.combo -topmost 1
			button $f.but -image but_data_copy -height 10 -width 10 \
					     			-background  $background_colour
			pack $f.combo $f.but -in $f -side left
			bind $f.but <Button-1> {
				set call_origin "from_gui"
				changer
				tkwait window $top_change
				set f2 [open $out_2 r]
				gets $f2 line
				if {$line != "cancelled"} {
					set item [file tail $line]
					set frame_new [file rootname $item]
				}
				close $f2
				update

				set f1 [open $out "w"]
				if {$frame_new != "keep frame"} {
					puts $f1 "work§change title block"
					set f2 [open $out_2 w]
					puts $f2 [file nativename "[getTemplateDirectory]/$frame_new.CATDrawing"]
					puts $f2 $TBConfig
					close $f2
				}
				close $f1
				if {$line != "cancelled"} {
					tbExit
				}
			}
			grid configure $f -column 1 -row $last_row -sticky w -padx 20
			incr last_row
	#
			set showBom $bom_show($sheet)

			if {$bom_info($sheet) == 1} then {
#				label $tab_act.lab_bom -text [translate {Modify Bom}] -background $background_colour
				if {$preselectModifyBom == "yes"} then { 
					set modify_bom 1
				} else {
					set modify_bom 0
				}
				set fbom [frame $tab_act.fbom -background $background_colour]
				set fbom1 [frame $tab_act.fbom.fu -background $background_colour]
				set fbom2 [frame $tab_act.fbom.fd -background $background_colour]
				set fbom3 [frame $tab_act.fbom.fs -background $background_colour]

				pack $fbom1 $fbom2 $fbom3 -in $fbom -anchor w

				label $tab_act.lab_bominfo -text [translate {Bom}] -background $background_colour
					
				label $fbom2.lab_bommodify -text [translate {Modify}] -background $background_colour			
			    checkbutton $fbom2.modify_bom -variable modify_bom -background $background_colour

				set modeBoms_$sheet 1
				label $fbom3.lab_bomMode -text [translate {AllLevels}] -background $background_colour
				if {$bom_type($sheet) == "OneLevel"} then {
					set modeBoms_$sheet 0
				}
				
				checkbutton $fbom3.show_Mode -variable [subst modeBoms_$sheet] -background $background_colour
				if {$bom_type($sheet) == "AllLevels"} then {
					$fbom3.show_Mode select
				}
			
				label $fbom1.lab_bomshow -text [translate {Show}] -background $background_colour
				checkbutton $fbom1.show_bom -variable showBom -background $background_colour -command {
					#global fbom
					if {$showBom == 1} then {
						$fbom1.show_bom select
						$fbom2.modify_bom configure -state normal
						$fbom3.show_Mode configure  -state normal

					} else {
						$fbom1.show_bom deselect
						set modify_bom 0
						$fbom2.modify_bom deselect
						$fbom2.modify_bom configure -state disabled
						$fbom3.show_Mode configure  -state disabled
					}
				}
				if {$showBom == 1} then {
						$fbom1.show_bom select
						$fbom2.modify_bom configure -state normal
						$fbom3.show_Mode configure  -state normal

					} else {
						$fbom1.show_bom deselect
						set modify_bom 0
						$fbom2.modify_bom deselect
						$fbom2.modify_bom configure -state disabled
						$fbom3.show_Mode configure  -state disabled

					}

				pack $fbom1.show_bom $fbom1.lab_bomshow -in $fbom1 -side left -anchor w
				pack $fbom2.modify_bom $fbom2.lab_bommodify -in $fbom2 -side left -anchor w
				
				pack $fbom3.show_Mode $fbom3.lab_bomMode  -in $fbom3 -side left -anchor w
#				pack $fbom3 -in $fbom -anchor w

	            grid configure $tab_act.lab_bominfo -column 0 -row $last_row -sticky w
				grid configure $fbom -column 1 -row $last_row -sticky w

			}

		}
	}
	#########################################################################
	# buttons + logo on the main panel
	#########################################################################

	set wButtonOk [button $w.bottom.right.but_ok  -image but_ok -height 15 -width 75 -background $background_colour \
			-command {
		#force the sync of the text fields
		global wButtonOk
		focus $wButtonOk
		update
		#focus $w.bottom.right.but_ok
		set f1 [open $out "w"]
		if {$frame_new != "keep frame"} {
			puts $f1 "work§change title block"
			set f2 [open $out_2 w]
			puts $f2 [file nativename "[getTemplateDirectory]/$frame_new.CATDrawing"]
			puts $f2 $TBConfig
			close $f2
		} else {
			puts $f1 "work§ok"
		}

		unitStreamer $f1

		if {[info exists modify_bom]} then {
			puts $f1 "cat_bom_info_modify§$modify_bom"
		}

		if {[info exists showBom]} then {
			puts $f1 "cat_bom_info_show§$showBom"
		}

#		if {[info exists modeBom]} then {

#		    if {$modeBom == "none"} then {
#				puts $f1 "cat_bom_info_levels§none"
#			} elseif {$modeBom == 1} then {
#				puts $f1 "cat_bom_info_levels§AllLevels"
#			} elseif {$modeBom == 0} then {
#				puts $f1 "cat_bom_info_levels§OneLevel"
#			}
#		}

		if {[info exists keepBackgroundViewActive]} then {
			puts $f1 "cat_control_keepBackgroundViewActive§$keepBackgroundViewActive"
		}

		set allMandatoryFieldSet "yes"

		for {set sheet 1} {$sheet <= $numsheets} {incr sheet} {
			puts $f1 "cat_sheet§$sheet_names($sheet)§$view_names($sheet)"
			puts $f1 "cat_bom_info§$bom_info($sheet)"
			global [subst modeBoms_$sheet]
			set value [subst $[subst modeBoms_$sheet]]
		    if {$value == "none"} then {
				puts $f1 "cat_bom_info_levels§none"
			} elseif {$value == 1} then {
				puts $f1 "cat_bom_info_levels§AllLevels"
			} elseif {$value == 0} then {
				puts $f1 "cat_bom_info_levels§OneLevel"
			}

	#       	process sequence of fields according to list l_sequence
	#		for {set num_parm 1} { $num_parm <= $catia_parameter_on_sheet($sheet)} {incr num_parm}   {
	#			puts $f1 $catia_parameter($sheet\_$num_parm)
	#		}
			# check for passthrough data
			if {$passThrough != ""} then {
				foreach line $passThrough {
					puts $f1 $line
				}
			}

			foreach seq $l_sequence e_type $l_entry_type {
				set mode [getExtFieldDef $seq "Mode"]

				if {$mode == "mandatory"} then {
					#tk_messageBox -message ">[getTBData $sheet $seq]<"
					if {[isAnEmptyString [getTBData $sheet $seq]]} then {
						set allMandatoryFieldSet "no"
		 			}
				}
		   		puts $f1 $catia_names_stored([subst $sheet\_TitleBlock_Text_$seq])§[subst $title_fields([subst $sheet\_TitleBlock_Text_$seq])]
			}
			
			foreach seq $l_global_sequence {
				set mode [getExtFieldDef $seq "Mode"]
				if {$mode == "mandatory"} then {

					if {[isAnEmptyString [getTBData 0 $seq]]} then {
						set allMandatoryFieldSet "no"
						#tk_messageBox "build_GUI $seq"
		 			}
				}

		   		puts $f1 "TitleBlock_Text_$seq§[subst $title_fields([subst 0_TitleBlock_Text_$seq])]"
			}

	#       	process Revisions
			for {set i 0} {$i < $num_changes} {incr i} {
				foreach j  $l_change_sequence {
	                       	set name [subst $sheet\_RevisionBlock_Text_$j\_[lindex $revisions $i]]
	                       	set value [subst $title_fields([subst $name])]
					puts $f1 "$catia_names_stored($name)§$value"
				}
			}
			streamTableData $f1 $sheet
			puts $f1 "cat_sheet_end"
		}
		close $f1

		if {$modeMandatory == "none" } then {
			kill_comm_data_set
			tbExit
		} else {
			if {$allMandatoryFieldSet == "no"} then {
				if {$modeMandatory == "enabled" } then {
					set answer [tk_messageBox -message [translate {"Not all mandatory data filled, continue anyway?"}] -type yesno -icon question]
					if {$answer == "yes"} then {
						kill_comm_data_set
						tbExit
					}
				} else {
					set answer [tk_messageBox -message [translate {"Not all mandatory data filled, please enter data!"}] -icon warning]
				}

			} else {
				kill_comm_data_set
				tbExit
			}
		}

	}]

	Button $w.bottom.right.but_new_frame  -image but_ok -height 15 -width 75 -background $background_colour \
			-helptext [translate {Choose new frame}] \
			-command {
		set f1 [open $out "w"]
		puts $f1 "work§change title block"
		unitStreamer $f1
		for {set sheet 1} {$sheet <= $numsheets} {incr sheet} {
			# check for passthrough data
			if {$passThrough != ""} then {
				foreach line $passThrough {
					puts $f1 $line
				}
			}

			puts $f1 "cat_sheet§$sheet_names($sheet)§$view_names($sheet)"
			puts $f1 "cat_bom_info§$bom_info($sheet)"
	#       	process sequence of fields according to list l_sequence
	#		for {set num_parm 1} {$num_parm <= $catia_parameter_on_sheet($sheet)} {incr num_parm}  {
	#			puts $f1 $catia_parameter($sheet\_$num_parm)
	#		}
			foreach seq $l_sequence {
		   		puts $f1 $catia_names_stored([subst $sheet\_TitleBlock_Text_$seq])§[subst $title_fields([subst $sheet\_TitleBlock_Text_$seq])]
			}
			foreach seq $l_global_sequence {
		   		puts $f1 $catia_names_stored([subst 0_TitleBlock_Text_$seq])§[subst $title_fields([subst 0_TitleBlock_Text_$seq])]
			}
	#       	process Revisions
			for {set i 0} {$i < $num_changes} {incr i} {
				foreach j  $l_change_sequence {
	               	set name [subst $sheet\_RevisionBlock_Text_$j\_[lindex $revisions $i]]
	               	set value [subst $title_fields([subst $name])]
					puts $f1 "$catia_names_stored($name)§$value"
				}
			}
			streamTableData $f1 $sheet
			puts $f1 "cat_sheet_end"
		}
		close $f1
		kill_comm_data_set
		tbExit
	}

	Button $w.bottom.right.but_can -image but_can    -height 15 -width 75 -background $background_colour -command {
		set f1 [open $out w]
		puts $f1 "work§ko"
		close $f1
		global  widgetName
		kill_comm_data_set
		tbExit
	}

	# logo left bottom

	label $w.bottom.left.logo -image logo -background $background_colour
	pack $w.bottom.left.logo -in $w.bottom.left -anchor w
	pack $w.bottom.right.but_ok  $w.bottom.right.but_can -in $w.bottom.right

	#########################################################################
	# Activate the tab corresponding to the active catia sheet
	#########################################################################

	$notebook raise [$notebook pages $active_tab]
	wm iconify $top
	wm deiconify $top
	focus $top
	cbTurnOn
	#trace variable title_fields w callBackFields
}

proc guiChangePanel { widget active_sheet xKoord yKoord } {
	global version
	global change
	
	global background_colour
	global change_height
	global change_width
	
	global os_type

	global title_fields
	
	global num_change_fields
	global change_fields
	global l_change_sequence
	global l_change_texts
	global l_change_entry_type
	global l_change_mode
	global change_enabled
	global num_changes
	
	global revisionEnableDelete
	
	#########################################################################
	# show change history, new toplevel
	#########################################################################

	cbTurnOff
	
	set change [toplevel .change]
	wm geometry $change "+$xKoord+$yKoord"
	putWindowOnTop $change 

	wm title $change "CATIA title block editor $version - [translate {Changes}]"
	$change configure -background $background_colour
	set foben [frame $change.fo_$active_sheet -background $background_colour]
	set funten [frame $change.fu_$active_sheet -background $background_colour]
	pack $foben $funten -in $change

	set f_left_w [ScrolledWindow   $change.fl_$active_sheet   -background $background_colour]
	set f_left   [ScrollableFrame  $f_left_w.f1  -background $background_colour -height $change_height -width $change_width]
	$f_left_w setwidget $f_left
	set f_left_scroll [$f_left getframe]

	set f_right [frame $change.fr_$active_sheet -background $background_colour]
	pack $f_right $f_left_w  -in $foben -side left

	set f_upper [frame $f_left.fu -background $background_colour]
	set f_lower [frame $change.fl -background $background_colour]

	pack $f_upper -in $f_left_scroll
	pack $f_lower -in $change -side bottom
#		save the tb data
	saveTBData
	
	set change_row 0
#       Title
	set col 2

	
	foreach seq $l_change_sequence cur_text $l_change_texts {
		set lWidth [getExtFieldDef $seq "entry_width"]
		Label $f_upper.lab_change_$seq\_title -width $lWidth -text $cur_text -relief groove -background $background_colour
		grid  $f_upper.lab_change_$seq\_title -column $col -row $change_row -sticky w
		incr col
	}

	incr change_row
#       entries
#		tk_messageBox -message $active_sheet
	for {set i [expr $num_changes - 1]} {$i >= 0} {set i [expr $i -1]} {
		set col 0
		
		Button $f_upper.lab_change_butDelRow§$i  -image pic_deleteRow -height 15 -width 15 -background $background_colour \
			-helptext [translate {Delete the revision}] -command {
#               move all entries one down
		}

		bind $f_upper.lab_change_butDelRow§$i <Button-1> {
			set sButton %W
			set temp [split $sButton "§"]
			set rowAct [lindex $temp 1]

			foreach seq $l_change_sequence {
				for {set i $rowAct} {$i < [expr $num_changes - 1]} {incr i} {
					set help  [expr $i + 1]
					set name  [subst $active_sheet\_RevisionBlock_Text_$seq\_[lindex $revisions $i]]
					set value [subst $title_fields([subst $active_sheet\_RevisionBlock_Text_$seq\_[lindex $revisions $help]])]
					set title_fields($name) $value
				}
			}
#               Delete last entry
			set i [expr $num_changes - 1]
			foreach seq $l_change_sequence {
					set name  [subst $active_sheet\_RevisionBlock_Text_$seq\_[lindex $revisions $i]]
					set value " "
					set title_fields($name) $value
			}

		}
#		grid $f_upper.lab_change_butDelRow§$i -column $col -row $change_row
		if {$revisionEnableDelete == "yes"} then {
			grid $f_upper.lab_change_butDelRow§$i -column $col -row $change_row
		}
		incr col

		Button $f_upper.lab_change_butInsertRow§$i  -image pic_insertRow -height 15 -width 15 -background $background_colour \
			-helptext [translate {Insert a revision entry}] -command {
#               move all entries one down
		}

		bind $f_upper.lab_change_butInsertRow§$i <Button-1> {
			set sButton %W
			set temp [split $sButton "§"]
			set rowAct [lindex $temp 1]

			foreach seq $l_change_sequence {
				for {set i $num_changes} {$i > $rowAct} {set i [expr $i - 1]} {
					set help  [expr $i - 1]
					set name  [subst $active_sheet\_RevisionBlock_Text_$seq\_[lindex $revisions $i]]
					set value [subst $title_fields([subst $active_sheet\_RevisionBlock_Text_$seq\_[lindex $revisions $help]])]
					set title_fields($name) $value
				}
			}
#               Blank row Act
			set i $rowAct
			foreach seq $l_change_sequence {
					set name  [subst $active_sheet\_RevisionBlock_Text_$seq\_[lindex $revisions $i]]
					set value " "
					set title_fields($name) $value
			}

		}
		
		
		grid $f_upper.lab_change_butInsertRow§$i -column $col -row $change_row
		incr col

		
		
		foreach seq $l_change_sequence cur_text $l_change_texts e_change_type $l_change_entry_type {
			set f [frame $f_upper.lab_change\_$seq\_$i -background $background_colour]
#     		tk_messageBox -message "$f $active_sheet $seq $e_change_type change $i"

			gen_entry_field $f $active_sheet $seq $e_change_type change $i

			grid $f_upper.lab_change\_$seq\_$i -column $col -row $change_row
			incr col
		}
		incr change_row
	}
	
	

#       ok / cancel
	label $f_lower.logo -image logo -background $background_colour
#        grid configure $f_lower.logo -column 0 -row $last_row -sticky w
	frame $f_lower.buttons
	button $f_lower.buttons.but_ok  -image but_ok -height 15 -width 75 -background $background_colour \
		-command {
				cbTurnOff
				destroy $change
			}
	button $f_lower.buttons.but_can  -image but_can -height 15 -width 75 -background $background_colour \
		-command {
				cbTurnOff
				restoreTBData
				destroy $change
			}
		

	
	pack $f_lower.buttons.but_ok $f_lower.buttons.but_can -in $f_lower.buttons -side left



	grid configure $f_lower.buttons -column 0 -row 2 -sticky w

	update
	focus $change
	if {$os_type == "windows"} then {
		grab $change
	}
	cbTurnOn
}
