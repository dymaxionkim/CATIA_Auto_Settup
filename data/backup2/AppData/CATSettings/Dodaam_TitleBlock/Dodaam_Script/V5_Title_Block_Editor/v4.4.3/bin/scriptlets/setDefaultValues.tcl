image create photo but_def      	-file  "$where_am_i/icons/pic_default_1.gif"
image create photo but_from3d		-file  "$where_am_i/icons/pic_from3d.gif"
image create photo but_allfrom3d	-file  "$where_am_i/icons/pic_allfrom3d.gif"
image create photo but_calendar 	-file  "$where_am_i/icons/pic_calendar_1.gif"
image create photo but_ok 			-file  "$where_am_i/icons/pic_ok.gif"
image create photo but_can 			-file  "$where_am_i/icons/pic_can.gif"
image create photo but_change 		-file  "$where_am_i/icons/pic_change_small.gif"
image create photo but_data_copy	-file  "$where_am_i/icons/pic_data_copy.gif"
image create photo logo 			-file  "$where_am_i/icons/logo.gif"
image create photo but_open 		-file  "$where_am_i/icons/open.gif"
image create photo but_save 		-file  "$where_am_i/icons/save.gif"
image create photo but_help 		-file  "$where_am_i/icons/help.gif"
image create photo but_down 		-file  "$where_am_i/icons/pic_down.gif"
image create photo but_td1  		-file  "$where_am_i/icons/td1.gif"
image create photo nothing  		-file  "$where_am_i/icons/nothing.gif"
image create photo but_config  		-file  "$where_am_i/icons/pic_config.gif"
image create photo pic_mandOpen  	-file  "$where_am_i/icons/pic_mandopen.gif"
image create photo pic_mandFilled	-file  "$where_am_i/icons/pic_mandfilled.gif"
image create photo pic_empty 		-file  "$where_am_i/icons/pic_nothing.gif"
image create photo pic_insertRow	-file  "$where_am_i/icons/pic_insertrow.gif"
image create photo pic_deleteRow 	-file  "$where_am_i/icons/pic_deleterow.gif"


#set log [open "$where_am_i/log.txt" w]


# default screen size for the notebook part of the window
set screen_height 400
set screen_width 270
# default screen size for the changes
set change_height 270
set change_width 300
#Screen size for the drawing data part
set dwgdata_height 300
set dwgdata_width 270

set choosePanelHeight 3
set choosePanelWidth  50
set choosePanelDeltaY 110

set entry_width 20

set background_colour "#FFE7BD"
set dateUppercase "No"

set modeMandatory "none"

set showMenuConfig true
set showMenuAllFrom3D true

set CATIA_TEMPLATES "dummy"
set emptyChar "-"
set entry_alignment "left"

#####################################################################
#   define the behavior for Cut / Copy / Paste
#   default    : OSDependant
#   OSDependant: Control c on Windows, Select on Unix for Copy
#   Windows    : Control c to Copy 
#   Unix       : Selection
#####################################################################
set CutCopyPaste "OSDependant"
#####################################################################
#   show, noshow the button box
#   default    : yes
#   noshow     : no
#####################################################################
set showButtonBox "yes"
#####################################################################
#   For Boms: preselect Modify Bom
#   default    : yes
#####################################################################
set preselectModifyBom "yes"
#set showBomMode "none"

set revisionEnableDelete "yes"

set callBackEnabled "no"

proc callBackReadIntermediateFile {mode} {
	global titleBlockFieldsCB
	#if {$titleBlockFieldsCB(Geprueft) == "Neukirchen" } then {
	#	set titleBlockFieldsCB(Geprueft) "Michael"
	#}
} 

proc tbFieldCallBack {mode sheet field number} {
	#set nSheets [getNumberOfSheets]
	#if {$mode == "normal"} then {
		#if {[getTBData $sheet "Geprueft"]=="Neukirchen"} then {
		#	setTBData $sheet "Geprueft" "Michael"
		#}
	#} else {
	# revision entries
		#if {[getTBRData $sheet "Geprueft" $number]=="Neukirchen"} then {
		#	setTBRData $sheet "Geprueft" $number "Michael"
		#}
	#}
    #tk_messageBox -message "$mode\n$sheet\n$field\n$number"
}


proc callBackFields {name1 name2 op} {
	global callBackEnabled
	#tk_messageBox -message "$name1 $name2"

	if {$callBackEnabled == "yes"} then {
		#cbTurnOff
	 
		set temp [split $name2 "_"]
		if {[lindex $temp 1] =="TitleBlock"} then {
			set field [string range $name2 [expr [string first "TitleBlock_Text_" $name2] + 16] end]
			set sheet [lindex $temp 0]
			tbFieldCallBack "normal" $sheet $field 0
		} else  {
			set temp1 [string range $name2 [expr [string first "RevisionBlock_Text" $name2] + 19] end]
	 	    set sheet [lindex $temp 0]
			set number [lindex $temp end]
			#tk_messageBox -message [expr [string length $number] + 1]
			#set field [string trimright $temp1 [expr [string length $number] + 1]]
			set field [string trimright $temp1 "_$number"]

			tbFieldCallBack "revision" $sheet $field $number
		}
		#cbTurnOn
	}
}