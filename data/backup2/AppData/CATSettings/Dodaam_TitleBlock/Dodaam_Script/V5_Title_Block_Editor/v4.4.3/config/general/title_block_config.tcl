#####################################################################
#  Titleblock fields section
#####################################################################
# catia name = component name
#
#                 		catia name    		Description    		 type
#
set global_fields(1)   	{Number		    	"Zeichnungsnummer" 	entry mandatory}
set global_fields(2)   	{Materialnummer    	Materialnummer      entry}
set global_fields(3)   	{AuftragsNummer   	Auftragsnummer      entry}
set global_fields(4)   	{Projekt  			Projekt	      		entry}
set global_fields(5)   	{Baugruppe 			Baugruppe	      	entry}
set global_fields(6)   	{Ursprung   		Ursprung      		entry}
set global_fields(7)   	{ErsatzFuer   		"Ersatz Fuer"      	entry}
set global_fields(8)   	{ErsatzDurch   		"Ersatz Durch"      entry}
set global_fields(9)    {Verwendung			Verwendung			entry}
#set global_fields(11)	{Werkstoff		    Werkstoff			entry}
#set global_fields(11)	{UPUserPropSample   UserProperty3D		entry}
#set global_fields(11)	{CADSystem		    CADSystem			entry}
#set global_fields(12)	{Detail		 		TestForDetail		entry}
#set global_fields(11)	{NumSheets		    Blaetter			entry}


set fields(1)   		{Description		Benennung  				entry}
set fields(2)   		{Bearbeitet       	Ersteller 				entry}
set fields(3)   		{BearbeitetDate    	Erstelldatum     		date}
set fields(4)   		{Geprueft         	Pruefer					entry}
set fields(5)   		{GeprueftDate		Pruefdatum      		date}
set fields(6)   		{Norm         		Normgeprueft			entry}
set fields(7)  		 	{NormDate    		"Norm Geprueft Datum"   date}
set fields(8)   		{Freigegeben    	Freigegeben       		entry}
set fields(9)   		{FreigegebenDate	"Datum der Freigabe"    date}
#set fields(10)			{SheetScale		    Masstab					entry}
set fields(10)			{Massstab		    Masstab					list}
set fields(11)			{Weight		     	Gewicht					entry}


#  modemandatory can be one of
#  		none 	- no field is mandatory
#       enabled - fields are mandatory and a warning is issued if mandatory fileds are not filled
#		forced	- the TB macro will only offer an ok, if all mandatory fields are filled

set modeMandatory none

# the name of the list must correlate to the name of the field

set l_Massstab     {"M 1:1" "M 1:2.5" "M 1:5"}
#####################################################################
#  Units section for fields from 3D (Weight, WetArea, Volume)
#
# define the list of fields for which a Unit conversion will be done
# if you want to use more than one field, add the fields to the list
# sample  set u_Units {Weight Volume}
#####################################################################

set u_Units {Weight}
# define the Units for the field
set u_Weight { {kg 1} {g 1000} {mg 1000000} {t 0.001} {lb 2.204623} {oz  35.27396} {slug 0.06852177} }
# define the precision (decimal digits) for the field
set dp_Weight 2
# use the old behavior - don't display the Unit in the tb (number without unit)
set showUnit_Weight no

#####################################################################
#  Revision section
#####################################################################

# If you don't want revision entries, comment/delete the lines revisions
# and change_fields
set revisions { 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 }

set change_fields(1) {Rev		"Aenderungs ID"			list}
set change_fields(2) {Aenderung "Beschreibung"			entry}
set change_fields(3) {Datum		"Datum der Aenderung"	date}
set change_fields(4) {Name		"Name"					entry}

set l_Rev     {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 }

#####################################################################
#  Add default values
#####################################################################

# --> set cat_title_block_field_default variable


if {$tcl_platform(machine) == "intel"} then {
	set TitleBlock_Text_Bearbeitet_default 		$env(USERNAME)
	set TitleBlock_Text_Freigegeben_default 	$env(USERNAME)
	set TitleBlock_Text_Norm_default 			$env(USERNAME)
	set TitleBlock_Text_Geprueft_default 		$env(USERNAME)
	set RevisionBlock_Text_Name_default 		$env(USERNAME)
	} else {
	set TitleBlock_Text_Bearbeitet_default 		$env(USER)
	set TitleBlock_Text_Freigegeben_default 	$env(USER)
	set TitleBlock_Text_Norm_default 			$env(USER)
	set TitleBlock_Text_Geprueft_default 		$env(USER)
	set RevisionBlock_Text_Name_default 		$env(USER)
}

#####################################################################
#  some default behaviors
#####################################################################
# Date Format
set date_format "%d/%m/%Y"

# date uppercase will translate all date entries to uppercase
#set dateUppercase "Yes"

#####################################################################
#  GUI section
#####################################################################

# width for the entry fields (characters)
set entry_width 20

#Screen size for the notebook part of the window
set screen_height 300
set screen_width 280
#Screen size for the revision fields - all revisions will be scrolled in this area
set change_height 230
set change_width 580
#Screen size for the drawing data part
set dwgdata_height 240
set dwgdata_width 230

# define the directory for the CATIA Drawing Templates
set CATIA_TEMPLATES "$where_am_i/templates"