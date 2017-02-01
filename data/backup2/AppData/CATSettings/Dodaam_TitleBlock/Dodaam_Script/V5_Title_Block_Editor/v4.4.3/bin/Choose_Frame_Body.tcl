#--------------------------------------------------------------------------
#**************************************************************************
# PROGRAM: Text_block, Choose frame body
#**************************************************************************
#                        IBM Product Lifecyle Management Solutions
#                         Engineering e-Business
#
# (C) COPYRIGHT International Business Machines Corp. 2001
#**************************************************************************
#               	Erstellt: 07.11.2001   	Name: M. Neukirchen
#			Change 3.12.2001		M. Neukirchen
#							Temp Directory from CATScript (TempFolder)
#**************************************************************************
# Description: Title Block Chooser
#**************************************************************************

global sheetPaperSize

set where_am_i  [string map {"\\" "/"} $where_am_i]
set aut_path [linsert $auto_path 0 "$where_am_i/lib"]
package require BWidget

set call_origin [lindex  $argv 3]

source $where_am_i/bin/scriptlets/choose_frame.tcl
set sConfig [getValueFromGeneralConfig DefaultConfig]
source $where_am_i/bin/scriptlets/setDefaultValues.tcl

source $where_am_i/config/custom/$sConfig/title_block_config.tcl
source $where_am_i/bin/scriptlets/nls.tcl
source $where_am_i/bin/scriptlets/utilities.tcl

wm withdraw .

# get sheet papersize info for an empty drawing
set in  	"$TempFolder\\cat_title_block.txt"
set in [string map {"\\" "/"} $in]

set f1 [open $in]
gets $f1 line
set temp [split $line "§"]
set sheetPaperSize [lindex $temp 1]
close $f1

changer

tkwait window $top_change

exit