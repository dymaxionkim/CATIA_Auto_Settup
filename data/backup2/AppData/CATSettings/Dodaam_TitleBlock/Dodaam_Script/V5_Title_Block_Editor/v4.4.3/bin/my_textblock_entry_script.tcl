#--------------------------------------------------------------------------
#**************************************************************************
# PROGRAM: Text_block
#**************************************************************************
#
# (C) COPYRIGHT Michael Neukirchen 2005
#**************************************************************************
#               Erstellt: 20.07.2001   	Name: M. Neukirchen
#               change  : 31.07.2001   	Name: M. Neukirchen
#					V 2.0
#					GUI written in TCL
#               change  : 12.08.2001   	Name: M. Neukirchen
#					V 2.1.1
#					1) Support of Change Entries
#					2) Support of multiple sheets
#                             3) internal naming conventions
#               change  : 21.08.2001   	Name: M. Neukirchen
#					V 2.1.2
#					1) Activate the tab for the active
#					   CATIA sheet
#					2) in case of a new change entry
#					   display the change history in a
#					   new toplevel window
#					3) Copy content of Sheets
#					4) Date Selector from iTcl
#               change  : 31.08.2001   	Name: M. Neukirchen
#					V 2.1.4
#					1) Save content of current sheet to disk
#					2) Load content of current sheet from disk
#					3) MainFrame application BWidget
#					4) Active sheet determinded bei tabs
#					5) OS type from tcl_platform
#					6) Help file (Windows)
#               change  : 15.02.2002   	Name: M. Neukirchen
#					V 2.3.0
#					1) drawing (global) data and sheet data separation
#					2) support of CATIA parameters (mapped to drawing fields)
#					3) Checker for consistency of data
#               change  : 03.06.2002   	Name: M. Neukirchen
#					V 2.3.1
#					1) show the 3d master models used
#               change  : 26.06.2002   	Name: M. Neukirchen
#					V 2.3.2
#					1) allow all revisions to be edited
#				change  : 27.09.2002
#					V 2.3.3, 2.3.4
#					1) Unix compatibilities
#					2) Date Selector sourced to avoid iWidget Set
#					3) td1 compatibility
#				change : 06.11.2002
#					1) wm WM_DELETE_WINDOW checks for ending the GUI by selection of Windows "x"
#				change : 27.11.2002
#					V 2.4.3
#					1) background colour customizable through variable background_colour
#					2) error if calling the selection panel for titleblocks on unix
#				change : 04.02.2003
#					V 2.4.4
#					1) enable no change items
#					2) Support of Blanks within default values
#				change : 22.02.2003
#					V 2.4.6
#					1) bug fix for scrolling revision entries
#					2) support of scrolling for revisions
#				change : 12.03.2003
#					V 2.4.7
#					1) in case of missing entries, allow selection of a new frame
#					2) command for wish fixed (unix environment)
#				change : 01.05.2003
#					V 2.4.8
#					1) allow drawing data frame to be scrolled
#					2) grab problem for selection of dates on unix fixed
#				change : 12.05.2003
#					V 2.4.9
#					1) date chooser looses focus on windows (due to grab comment)
#					2) enable default handling for the revision blocks
#					3) date chooser 'normal' window
#					4) all grabs only for windows
#				change : 12.12.2003
#					V 2.4.13
#					1) bug fix in case of missing fields
#				change : 18.02.2004
#					V 2.4.15
#					1) bug fix for help files in case of UNC names
#				change : 11.03.2005
#					V 3.1.4
#					1) table editor added
#					2) unit support
#				change : 29.12.2005
#					V 4.0.0
#					1) split up into different files
#					2) support of mandatory fields, extended field definition
#					3) table edits
#                   4) user defined bom data
#				change : 12.01.2008
#					1) bug fixes
#
#		Internal Variables / Arrays
#
#		sheet_names 	: 	array to store the names of the catia
#					  		sheets
#		view_names		: 	array to store the view names
#       title_fields	: 	array to hold the title block names
#						 	and values
#		num_changes		: 	number of changes
#**************************************************************************
# Description: TCL/TK GUI for the title block editor
#**************************************************************************

global TBConfig

set version "V 4.4.0"

if {$os_type == "windows"} then {
	set in  	"$TempFolder\\cat_title_block.txt"
	set out  	"$TempFolder\\cat_title_block.txt"
	set out_2 	"$TempFolder\\cat_title_block_2.txt"
	set out_3   "$TempFolder\\cat_title_block_3.txt"

} else {
	set in  	"$TempFolder/cat_title_block.txt"
   	set out 	"$TempFolder/cat_title_block.txt"
   	set out_2 	"$TempFolder/cat_title_block_2.txt"
   	set out_3 	"$TempFolder/cat_title_block_3.txt"
}

set wishcommand	 	"[lindex $argv 3] -f $where_am_i/bin/my_textblock_entry.tcl "

set where_am_i [string map {"\\" "/"} $where_am_i]

set auto_path [linsert $auto_path 0 "$where_am_i/lib"]

package forget BWidget
package require BWidget

source "$where_am_i/bin/scriptlets/date_chooser.tcl"
source "$where_am_i/bin/scriptlets/choose_frame.tcl"
source "$where_am_i/bin/scriptlets/setDefaultValues.tcl"

source "$where_am_i/config/general/skin.tcl"

source "$where_am_i/bin/scriptlets/nls.tcl"
source "$where_am_i/bin/scriptlets/dataStreaming.tcl"
source "$where_am_i/bin/scriptlets/gen_entry_field.tcl"
source "$where_am_i/bin/scriptlets/handleOptions.tcl"
source "$where_am_i/bin/scriptlets/handleUnits.tcl"
source "$where_am_i/bin/scriptlets/handleTables.tcl"
source "$where_am_i/bin/scriptlets/callBacks.tcl"
source "$where_am_i/bin/scriptlets/utilities.tcl"
source "$where_am_i/bin/scriptlets/buildInternalLists.tcl"
source "$where_am_i/bin/scriptlets/checkConsistency.tcl"
source "$where_am_i/bin/scriptlets/readIntermediateFile.tcl"
source "$where_am_i/bin/scriptlets/buildGUI.tcl"


#########################################################################
# init nls
#########################################################################
get_nls

#########################################################################
# modify communication data sets
#########################################################################
modifyComFiles "init"
#########################################################################
# read data from VBScript for config guesser (only for the start)
#########################################################################
readIntermediateFile

if {![file exists $out_2]} then {
	configGuesser
}

if {$TBConfig == ""} then {set TBConfig "standard"}

source "$where_am_i/config/custom/$TBConfig/title_block_config.tcl"
#if { [catch {source "$where_am_i/config/custom/$TBConfig/title_block_config.tcl"} result] } {
#    tk_messageBox -message "Error reading : $where_am_i/config/custom/$TBConfig/title_block_config.tcl \n$result"
#	exit
#}

#########################################################################
# set the Copy, Cut, Paste Behavior
#########################################################################
setCopyCutPasteBehavior

#########################################################################
# read intermediate file again, to apply revision info
#########################################################################
set TBact $TBConfig
readIntermediateFile
set TBConfig $TBact
#########################################################################
# apply default values
#########################################################################
setTBDefaults

#########################################################################
# build the internal lists
#########################################################################
buildInternalLists

#########################################################################
# check, if everything is available
#########################################################################
checkConsistency "showPanel"

#########################################################################
# copy global data from first sheet, assuming all data are the same
# (after running the macro all global data will(!) be the same on all sheets
#########################################################################
setGlobalData

#########################################################################
# build the main panel
#########################################################################
buildGUI 
tkwait window .t