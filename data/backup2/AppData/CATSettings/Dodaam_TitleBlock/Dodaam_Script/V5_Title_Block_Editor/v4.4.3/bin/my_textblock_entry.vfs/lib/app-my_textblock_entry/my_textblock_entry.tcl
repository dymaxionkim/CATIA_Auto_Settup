package provide app-my_textblock_entry 1.0
#--------------------------------------------------------------------------
#**************************************************************************
# PROGRAM: Text_block
#**************************************************************************
#                        IBM Product Lifecyle Management Solutions
#                         Engineering e-Business
#
# (C) COPYRIGHT International Business Machines Corp. 2001
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
#			To Do
#					1) Checker for consistency of data
#					2) Compatible to DS sample Macro
#					3) Get data from 3d model
#
#		Internal Variables / Arrays
#
#		sheet_names 	: array to store the names of the catia
#					  sheets
#		view_names		: array to store the view names
#           title_fields	: array to hold the title block names
#					  and values
#		num_changes		: number of changes
#**************************************************************************
# Description: StartMenu for CATIA
#**************************************************************************


#package require Iwidgets 3.0

set version "V 4.3.4"


if {[info exist tcl_platform(isWrapped)]} {
	set where_am_i [file nativename [lindex $argv 0]]
	set script     [lindex $argv 1]
	set TempFolder [lindex $argv 2]

} else {
	set where_am_i [file nativename [lindex $argv 0]]
	set script     [lindex $argv 1]
	set TempFolder [lindex $argv 2]

}

set os_type unix
if {[string range $tcl_platform(os) 0 2] == "Win" } then {
	set os_type windows
#	package require Iwidgets 3.0
}

source $where_am_i/$script
