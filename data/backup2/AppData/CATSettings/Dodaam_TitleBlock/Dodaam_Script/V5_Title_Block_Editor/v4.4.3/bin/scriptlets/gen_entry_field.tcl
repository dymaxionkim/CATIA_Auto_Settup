#########################################################################
# gen_entry_field generates an entry field
#########################################################################

proc gen_entry_field {f sheet field e_type change {number_in 0}} {
	global os_type
	global log
	global title_fields
	global temp_var
	global active_sheet
	global revisions
	global generative_fields
	global background_colour
	global foreground
	global change_fields
	global entry_width
	global sheet_dirty
	global notebook
	global allDirtyItems
	global modeMandatory
	global emptyChar
	global listOfTextFields
	global date_format
	
	array unset listOfTextFields
	
	set foreground "black"

	cbTurnOn
	
	if {[info exists change_fields]==1} {
		set number [lindex $revisions $number_in]
	} else {
		set number 0
	}

	set background "white"
	if {$change == "normal"} {
		set enter_field title_fields($sheet\_TitleBlock_Text_$field)
	} else {
		set enter_field title_fields($sheet\_RevisionBlock_Text_$field\_$number)
#020628		if {$number_in != 0} {set background grey}
	}

	# check, if field is mandatory

	
	set mode [getExtFieldDef $field "Mode"]

	set pass3dProperties [getExtFieldDef $field "pass3dProperties"]
	
	# add icons for mandatory fields
	set entryValue [subst $[subst $enter_field]]
	if {$change == "normal"} {
		if {$modeMandatory != "none"} {
			if {$mode == "mandatory" } then {
#				tk_messageBox -message [expr ($entryValue == $emptyChar)] 
	            if {$entryValue == "" } then {
	                Label $f.labMode -image pic_mandOpen -bg $background_colour
				} elseif {$entryValue == $emptyChar} {
#					tk_messageBox -message "Hallo"
	                Label $f.labMode -image pic_mandOpen -bg $background_colour
	            } else {
	                Label $f.labMode -image pic_mandFilled -bg $background_colour
	            }
			} else {
				Label $f.labMode -image pic_empty -bg $background_colour
			}
			pack $f.labMode -in $f -side left
		}
		
	}
	
#	tk_messageBox -message [getTBData $sheet $field]
	
	
	if {$e_type == "entry"} then {
		set width [getExtFieldDef $field "entry_width"]
		set align [getExtFieldDef $field "entry_alignment"]

#		set myEntry [Entry $f.ent_seq§$change§$field§$mode§$sheet -helptype balloon -textvariable $enter_field \
#					-dropenabled 1 -dragenabled 1 -background $background -width $width\
#					-justify $align -validate key -vcmd {CBentry %W %d %s %P} -invcmd {CBinvCmd %W} ]

		set myEntry [entry $f.ent_seq§$change§$field§$mode§$sheet§$number§$change -textvariable $enter_field \
					-background $background -fg "black" -width $width\
					-justify $align -validate key -vcmd {CBentry %W %d %s %P} -invcmd {CBinvCmd %W} ]
					
		if {[getExtFieldDef $field "entry_mode"] == "disabled"} then {
			$myEntry configure -state "disabled"
		}
		
		# if enter_field = empty, check for default values
		
		if {[isAnEmptyString [subst $$enter_field]]} then {

			if {[getExtFieldDef $field "Default"] != "no default value given"} then {
				set $enter_field [getExtFieldDef $field "Default"]
			
				set mode [getExtFieldDef $field "Mode"]
				# CHANGE icons for mandatory fields
				if {$change == "normal"} {
					if {$modeMandatory != "none"} then {
						if {$mode == "mandatory" } then {
							$f.labMode configure -image pic_mandFilled -bg $background_colour
						}
					}
				}
			}
		}
		
	

		  	
		

#		bind $myEntry <Button-2> { soapTranslService %W } 
		bind $myEntry <Alt-d> { tk_messageBox -message "%x"} 

		bind $myEntry <Alt-s> { getSpecialChar %W %X %Y} 
		
		set helpText [getExtFieldDef $field "Help"]
		if {$helpText != "??"} {
			DynamicHelp::register $myEntry balloon $helpText
		}
		
		set entryValue [subst $[subst $enter_field]]
		pack $f.ent_seq§$change§$field§$mode§$sheet§$number§$change  -in $f -side left
#		global f.ent_seq_$change\_$field
		global TitleBlock_Text_$field\_default
		global RevisionBlock_Text_$field\_default

#		check for default values
		set defaultValue "none"
		if {[info exists TitleBlock_Text_$field\_default]} {
					set defaultValue  "yes"
		}
		if {$change != "normal"} {
			if {[info exists RevisionBlock_Text_$field\_default]} {
			   		set defaultValue  "yes"
			}
		}

		if {$defaultValue != "none"} then {
			# stack all necessary info into the button's name, can be retrieved later (bind)
			Button $f.but_seq§$change§$field§$sheet§$number -image but_def -height 10 -width 10 \
				     -background  $background_colour \
				     -helptext [translate {Default Values}]
			pack $f.but_seq§$change§$field§$sheet§$number -in $f -side left
			if {[getExtFieldDef $field "entry_mode"] == "disabled"} then {
				$f.but_seq§$change§$field§$sheet§$number configure -state "disabled"
			} else {

				bind $f.but_seq§$change§$field§$sheet§$number <Button-1> {
					set widget %W
					set temp 		[split $widget "§"]
					set changeMode  [lindex $temp 1]
					set field	  	[lindex $temp 2]
					set sheetact  	[lindex $temp 3]
					if {$changeMode == "normal"} {
						set title_fields($sheetact\_TitleBlock_Text_$field) [subst $[subst TitleBlock_Text_$field\_default]]
					} else {
					    set numrev [lindex $temp 4]
						set title_fields($sheetact\_RevisionBlock_Text_$field\_$numrev) [subst $[subst     RevisionBlock_Text_$field\_default]]
						update
					}

				}
			}

		}
#		check for data from generative process
#		tk_messageBox -message "$field , $sheet"
		if {[info exists generative_fields($sheet\_$field)]} {
			global u_$field
			global def_$field

			if {[info exists u_$field]} then {

					set val3D [convUnits $field "1 [subst $[subst def_$field]]" [subst $[subst generative_fields($sheet\_$field)]]]
			} else {
					set val3D [subst $[subst generative_fields($sheet\_$field)]]
			}

			set genInfo $generative_fields($sheet\_$field)
 
			if {$pass3dProperties == "No"} then {

				if {$val3D != $entryValue} then {
					$f.ent_seq§$change§$field§$mode§$sheet§$number§$change configure -bg yellow
					lappend allDirtyItems $f.but_seq3d§$change§$field§$mode§$sheet§$number

					# question hint only for sheet entries - not global
					if {$sheet != 0} {
						incr sheet_dirty($sheet)
						$notebook itemconfigure $sheet -image but_help
					}
				}

				Button $f.but_seq3d§$change§$field§$sheet§$mode§$number -image but_from3d -height 10 -width 10 \
					     -background  $background_colour \
					     -helptext $val3D

#				     -helptext [translate {Supply 3D data}]

				pack $f.but_seq3d§$change§$field§$sheet§$mode§$number -in $f -side left
				if {[getExtFieldDef $field "entry_mode"] == "disabled"} then {
					$f.but_seq3d§$change§$field§$sheet§$mode§$number configure -state "disabled"
				} else {

					bind $f.but_seq3d§$change§$field§$sheet§$mode§$number <Button-1> {
						set widget %W
						set temp 		[split $widget "§"]
						set change      [lindex $temp 1]
						set field	  	[lindex $temp 2]
						set sheetact  	[lindex $temp 3]
						set mode		[lindex $temp 4]
						set number		[lindex $temp 5]

						#				set frameEntry  [string trimright [lindex $temp 0] ".but_seq3d"]
						set frameEntry  [string range [lindex $temp 0] 0 [expr [string length [lindex $temp 0]] - 11]]

						if {[info exists u_$field]} then {
							set val3D [convUnits $field "1 [subst $[subst def_$field]]" [subst $[subst generative_fields($sheetact\_$field)]]]
						} else {
							set val3D [subst $[subst generative_fields($sheetact\_$field)]]
						}
						set valAct $title_fields($sheetact\_TitleBlock_Text_$field)
						# is unit info available?

						if {$change == "normal"} {
							set title_fields($sheetact\_TitleBlock_Text_$field) $val3D
						} else {
							set title_fields($sheetact\_TitleBlock_Text_$field\_$number) $val3D

						}
						
						if {[$frameEntry.ent_seq§$change§$field§$mode§$sheetact§$number§$change cget -bg] == "yellow"} then {
							$frameEntry.ent_seq§$change§$field§$mode§$sheetact§$number§$change configure -bg "white"
							if {$sheetact != 0} then {
								set sheet_dirty($sheetact) [expr $sheet_dirty($sheetact) -1]
								if {$sheet_dirty($sheetact) == 0} then {
									$notebook itemconfigure $sheetact -image nothing

								}
							}
						}
					}
				}
			} else {
				if {$change == "normal"} {
					setTBData $sheet $field $val3D
				} else {
					setTBRData $sheet $field $number $val3D
				}
				if {$val3D == $entryValue} then {
					$myEntry configure -bg "lightgreen"
				} else {
					$myEntry configure -bg "lightpink"
					DynamicHelp::register $myEntry balloon "[translate "Value 3D:"] $val3D \n [translate "Drawing"] $entryValue"  
				}
			}
		}


#	Date selector
 	} elseif {$e_type == "date"} then {
		set width [getExtFieldDef $field "entry_width"]
		set align [getExtFieldDef $field "entry_alignment"]

#		Entry  $f.ent_seq_$change\_$field -textvariable $enter_field  -dropenabled 1 -dragenabled 1 -background $background -width $width -justify $align
		entry  $f.ent_seq_$change\_$field -textvariable $enter_field  -background $background -fg $foreground -width $width -justify $align

		Button $f.but_seq§$change§$field§$sheet§$number -image but_calendar -height 10 -width 10 \
				     -background $background_colour \
   				     -helptext [translate {Choose Date}]

		pack $f.ent_seq_$change\_$field $f.but_seq§$change§$field§$sheet§$number -in $f -side left
		bind $f.but_seq§$change§$field§$sheet§$number <Button-1> { date_select  %W %X %Y }
		
		if {$change == "normal" } then {
			if {![isAnEmptyString $enter_field]} then {
			  if {[getExtFieldDef $field "Default"] == "autoInsertDate"} then {
				set $enter_field [clock format [clock seconds] -format $date_format]
			  }	
			}
		}
		
	} elseif {$e_type == "list"} then {
		set width [getExtFieldDef $field "entry_width"]
		set values ""
		global l_$field
		foreach i [subst $[subst l_$field]] {
        		set values "$values \"$i\""
        	}
        	ComboBox $f.ent_seq§$change§$field§$mode§$sheet§$number§$change§  -values $values \
                	                -textvariable $enter_field  -width $width -dropenabled 1 -dragenabled 1 -entrybg $background -background $background_colour  -fg $foreground 
                                    
			pack $f.ent_seq§$change§$field§$mode§$sheet§$number§$change§  -in $f -side left
	} elseif {$e_type == "text"} then {
		set width [getExtFieldDef $field "text_width"]
		set height [getExtFieldDef $field "text_height"]
		
		set myText [text $f.ent_seq§$change§$field§$mode§$sheet§$number§$change -fg $foreground -width $width -height $height]
		set listOfTextFields($sheet§$field) $myText
		set tData [string map {"%%" "\n"} [getTBData $sheet $field]]
		$myText insert end $tData
		pack $myText -in $f -side left
		bind $myText <FocusOut> {
				set widget %W
				set temp 		[split $widget "§"]
				set change      [lindex $temp 1]
				set field	  	[lindex $temp 2]
				set sheetact  	[lindex $temp 4]
				set mode		[lindex $temp 3]
				set number		[lindex $temp 5]

				set tData [$widget get 1.0 {end -1c}]
				set tData [string map {"\n" "%%%%"} $tData]
				setTBData $sheetact $field $tData
		}

		if {[info exists generative_fields($sheet\_$field)]} {
			global u_$field
			global def_$field

			set val3D [subst $[subst generative_fields($sheet\_$field)]]

			set genInfo $generative_fields($sheet\_$field)
			# if 3d data differs from entry value -> Background of the entry field yellow
			# calculate into different unit, if necessary
			if {$pass3dProperties == "No"} then {

				if {$val3D != $entryValue} then {
					$f.ent_seq§$change§$field§$mode§$sheet§$number§$change configure -bg yellow
					lappend allDirtyItems $f.but_seq3d§$change§$field§$mode§$sheet§$number§$change

					# question hint only for sheet entries - not global
					if {$sheet != 0} {
						incr sheet_dirty($sheet)
						$notebook itemconfigure $sheet -image but_help
					}
				}

				Button $f.but_seq3d§$change§$field§$mode§$sheet§$number§$change -image but_from3d -height 10 -width 10 \
					     -background  $background_colour \
					     -helptext $val3D

#				     -helptext [translate {Supply 3D data}]
				pack $f.but_seq3d§$change§$field§$mode§$sheet§$number§$change -in $f -side left
				bind $f.but_seq3d§$change§$field§$mode§$sheet§$number§$change <Button-1> {
					set widget %W
					set temp 		[split $widget "§"]
					set change      [lindex $temp 1]
					set field	  	[lindex $temp 2]
					set sheetact  	[lindex $temp 4]
					set mode		[lindex $temp 3]
					set number		[lindex $temp 5]
					#				set frameEntry  [string trimright [lindex $temp 0] ".but_seq3d"]
					set frameEntry  [string range [lindex $temp 0] 0 [expr [string length [lindex $temp 0]] - 11]]

					set val3D [subst $[subst generative_fields($sheetact\_$field)]]

					# enter the data into the text field
					set textWidget [string map {"but_seq3d" "ent_seq"} $widget]
					$textWidget delete 1.0 {end -1c} 
					$textWidget insert end [string map {"%%%%" "\n"} $val3D]
					
					set valAct $title_fields($sheetact\_TitleBlock_Text_$field)
					# is unit info available?

					if {$change == "normal"} {
						set title_fields($sheetact\_TitleBlock_Text_$field) $val3D
					} else {
						set title_fields($sheetact\_TitleBlock_Text_$field\_$number) $val3D

					}
					if {[$frameEntry.ent_seq§$change§$field§$mode§$sheetact§$number§$change cget -bg] == "yellow"} then {
						$frameEntry.ent_seq§$change§$field§$mode§$sheetact§$number§$change configure -bg "white"
						if {$sheetact != 0} then {
							set sheet_dirty($sheetact) [expr $sheet_dirty($sheetact) -1]
							if {$sheet_dirty($sheetact) == 0} then {
								$notebook itemconfigure $sheetact -image nothing

							}
						}
					}
				}
			} else {
				if {$change == "normal"} {
					setTBData $sheet $field $val3D
				} else {
					setTBRData $sheet $field $number $val3D
				}
				if {$val3D == $entryValue} then {
					$myEntry configure -bg "lightgreen"
				} else {
					$myEntry configure -bg "lightpink"
					DynamicHelp::register $myEntry balloon "[translate "Value 3D:"] $val3D \n [translate "Drawing"] $entryValue"  
				}
			}
		}


	} else {
		tk_messageBox -message [translate "$field specification wrong for field:>$field< , dont know $e_type \n check title_block_config.tcl"]
	}
}

# callback for the entry field - changes the icon, if a mandatory field is filled / cleaned

proc CBentry {widget action oldString newString } {
	global modeMandatory
	global emptyChar
	global globalEntryMessage
	global entry_width

	#wm title .t "$oldString : $newString"
	
	# widget naming convention: $f.ent_seq§$change§$field§$mode§$sheet
	set temp 		[split $widget "§"]
	set laenge 		[expr [string length [lindex $temp 0]] - 9]
	set labToChange [string range [lindex $temp 0] 0 $laenge]
	set changeMode  [lindex $temp 1]
	set field	  	[lindex $temp 2]
	set mode 	  	[lindex $temp 3]
	set sheetact  	[lindex $temp 4]
#	tk_messageBox -message $labToChange

	if {$modeMandatory != "none" } {
	    if {$changeMode == "normal"} {
			if {$mode == "mandatory" } then {
				#last char deleted?
#				tk_messageBox -message "Hello"
				set entryIsEmpty 0
				#deleted last character
				if {$action == 0} then {   
					if {[string length $oldString] == 1} then {
						set entryIsEmpty 1
					}
					if {[string length $oldString] == 2} then {
						if {[string range $oldString 0 0] == $emptyChar} {
							set entryIsEmpty 1
						}
					}
						

#					if {[string length $oldString] == 2} then {
#						if {[string range $oldString 0 0] == $emptyChar]} {set entryIsEmpty 1}
#					}
				}
#				tk_messageBox -message $action
		  		if {([isAnEmptyString [getTBData $sheetact $field]]) || ($entryIsEmpty == 1)} then {
    				$labToChange.labMode configure -image pic_mandOpen
	    		} else {
    				$labToChange.labMode configure -image pic_mandFilled
	    		}
				# empty field - insert
				if {$action == 1} then {
			  		if {$newString != $emptyChar} then {
	    				$labToChange.labMode configure -image pic_mandFilled
		    		}
				}
			}
		}
	}
	set mask [getExtFieldDef $field "Mask"]
	if {$mask != "??"} then {
	#	tkFormat -best globalEntryMessage mask $newString
#		if {$globalEntryMessage != $newString} {
#			setTBData $sheetact $field $globalEntryMessage
#		}
		#
		after idle $widget configure -validate key
		#set newString $widget cget

		set valFormatted [tkFormat -best globalEntryMessage $mask $newString]
		
  		if {[isAnEmptyString $newString]} then {
			$labToChange.labMode configure -image pic_mandOpen
   		}

		setTBData $sheetact $field $globalEntryMessage
		$widget icursor end		
		return $valFormatted

#		return [tkFormat -best globalEntryMessage $mask $newString]

		#		tk_messageBox -message [tkFormat -best globalEntryMessage $mask $newString]
#		tk_messageBox -message $globalEntryMessage
#	    return [tkFormat -best globalEntryMessage $mask $newString]
	}
	set fieldLength [getExtFieldDef $field "entry_width"]
	if {$fieldLength != $entry_width} {
		if {$action == 1} then {
			if {[string length $oldString] >= $fieldLength} {
				bell
				set globalEntryMessage [string range $oldString 0 [expr $fieldLength - 1]] 
				return 0
			}
		}
	}
	return 1
}
proc CBinvCmd {widget} {
	global globalEntryMessage
	global emptyChar
	global modeMandatory

	set temp 		[split $widget "§"]
	set laenge 		[expr [string length [lindex $temp 0]] - 9]
	set labToChange [string range [lindex $temp 0] 0 $laenge]
	set changeMode  [lindex $temp 1]
	set field	  	[lindex $temp 2]
	set mode 	  	[lindex $temp 3]
	set sheetact  	[lindex $temp 4]

	#	tk_messageBox -message "Hello"

    bell
    $widget delete 0 end
    $widget insert 0 $globalEntryMessage
#	$widget icursor end
#	$widget icursor [string length $globalEntryMessage]
    after idle $widget configure -validate key
	if {$modeMandatory != "none" } {
	    if {$changeMode == "normal"} {
			if {$mode == "mandatory" } then {
				if {[isAnEmptyString [getTBData $sheetact $field]]} then {
					$labToChange.labMode configure -image pic_mandOpen
				} else {
					$labToChange.labMode configure -image pic_mandFilled
				}
			}
		}
	}

	#	return 1
}

proc isAnEmptyString { stringIn } {
	global emptyChar

	if {([string trim $stringIn] == "") || ([string trim $stringIn] == $emptyChar) } then {
		return 1
	} else {
		return 0
	}
}

# tkFormat --
 # This procedure attempts to format a value into a particular format string.
 #
 # Arguments:
 # format        - The format to fit
 # val           - The value to be validated
 #
 # Returns:      0 or 1 (whether it fits the format or not)
 #
 # Switches:
 # -fill ?var?   - Default values will be placed to fill format to spec
 #                 and the resulting value will be placed in variable 'var'.
 #                 It will equal {} if the match invalid
 #                 (doesn't work all that great currently)
 # -best ?var?   - 'Fixes' value to fit format, placing best correct value
 #                 in variable 'var'.  If current value is ok, the 'var'
 #                 will equal it, otherwise it removes chars from the end
 #                 until it fits the format, then adds any fixed format
 #                 chars to value.  Can be slow (recursive tkFormat op).
 # -strict       - Value must be an exact match for format (format && length)
 # --            - End of switches

 proc tkFormat {args} {
    set fill {}; set strict 0; set best {}; set result 1;
    set name [lindex [info level 0] 0]
    while {[string match {-*} [lindex $args 0]]} {
        switch -- [string index [lindex $args 0] 1] {
            b {
                set best [lindex $args 1]
                set args [lreplace $args 0 1]
            }
            f {
                set fill [lindex $args 1]
                set args [lreplace $args 0 1]
            }
            s {
                set strict 1
                set args [lreplace $args 0 0]
            }
            - {
                set args [lreplace $args 0 0]
                break
            }
            default {
                return -code error "bad $name option \"[lindex $args 0]\",\
                        must be: -best, -fill, -strict, or --"
            }
        }
    }

    if {[llength $args] != 2} {
        return -code error "wrong \# args: should be \"$name ?-best varname?\
                ?-fill varname? ?-strict? ?--? format value\""
    }
    set format [lindex $args 0]
    set val    [lindex $args 1]

    set flen [string length $format]
    set slen [string length $val]
    if {$slen > $flen} {set result 0}
    if {$strict && ($slen != $flen)} { set result 0 }

    if {$result} {
        set regform {}
        for {set i 0} {$i < $slen} {incr i} {
            set c [string index $format $i]
            if {$c == "\\"} {
				incr i
                set c [string index $format $i]

            } else {
                switch -- $c {
                    0   { set c {[[:digit:]]} }
                    A   { set c {[[:upper:]]} }
                    a   { set c {[[:lower:]]} }
                    %   { set c {[[:space:]]} }
                    z   { set c {[[:alpha:]]} }
                    Z   { set c {[[:alnum:]]} }
                    + - * - - - ? - \[ - \] - \( - \) - \{ - \} - \^ - \$ - . -
                    \\  { set c "\\$c" }
                    default {}
                }
            }
            lappend regform $c
        }
        #puts [list $regform $format $val]
        set result [regexp -- [join $regform {}] $val]
    }

    if {[string compare $fill {}]} {
        upvar $fill fvar
        if {$result} {
            set fvar $val[string range $format $i end]
        } else {
            set fvar {}
        }
    }

    if {[string compare $best {}]} {
        upvar $best bvar
        set bvar $val
        set len [string length $bvar]
        if {!$result} {
            incr len -2
            set bvar [string range $bvar 0 $len]
            # Remove characters until it's in valid format
            while {$len > 0 && ![tkFormat $format $bvar]} {
                set bvar [string range $bvar 0 [incr len -1]]
            }
            # Add back characters that are fixed
            while {($len<$flen) && ![string match \
                    {[0Aa%zZ]} [string index $format [incr len]]]} {
                append bvar [string index $format $len]
            }
        } else {
            # If it's already valid, at least we can add fixed characters
            while {($len<$flen) && ![string match \
                    {[0Aa%zZ]} [string index $format $len]]} {
                append bvar [string index $format $len]
                incr len
            }
        }
    }

    return $result

}


#    label .l4 -text "A phone number formatted widget:\
#            \n(###) ###-####"
#    pack .l4
#    entry .e4 -vcmd {tkFormat -best tmp {(000) 000-0000} %P} -validate key\
#            -invcmd {
#        bell
#        %W delete 0 end
#        %W insert 0 $tmp
#        after idle %W configure -validate key
#    }
#    pack .e4

proc soapTranslService { widget }  {
	tk_messageBox -message "Hello"
#	tk_popup menu x y ?entry?

}

proc getSpecialChar {widget xKoord yKoord} {
	global specCharacterTable
	global background_colour
	global myTempWidget
	global changePanelActive
	global os_type
	
	set myTempWidget $widget
	
	
	if {[info exists specCharacterTable]} then {
	#########################################################################
	# show spec char window
	#########################################################################

		set specCharWindow [toplevel .specCharWindow]
		wm geometry $specCharWindow "+$xKoord+$yKoord"
		putWindowOnTop $specCharWindow 

		wm title $specCharWindow "CATIA title block editor - Spec Chars"
		$specCharWindow configure -background $background_colour
		if {$os_type == "windows"} then {
			grab $specCharWindow
		}
		set fChars [frame $specCharWindow.chars -background $background_colour]
		set fButtons [frame $specCharWindow.buttons -background $background_colour]
		set i 0
		foreach specChar $specCharacterTable {
			button $fChars.but§$i -text $specChar -background $background_colour -command {destroy .specCharWindow}
			bind $fChars.but§$i <Button-1> {
				set widg %W
				global myTempWidget
				set temp [split $widg "§"]
				set numSpecChar [lindex $temp 1]
				#tk_messageBox -message "$widg : $numSpecChar"
				$myTempWidget insert insert [lindex $specCharacterTable $numSpecChar]
				if {$changePanelActive == 1} then {
					grab .change
				}
			}
			pack $fChars.but§$i -in $fChars -side left
			incr i
		}
		button $fButtons.but_can  -image but_can -height 15 -width 75 -background $background_colour \
		-command {
			destroy .specCharWindow
			if {$changePanelActive == 1} then {
					if {$os_type == "windows"} then {
						grab .change
					}
				}
			}
		pack $fButtons.but_can -in $fButtons
	
		pack $fChars $fButtons -in $specCharWindow
	}
}