#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Endohstation
//**************************************************************

/datum/map/active
	nameShort = "endoh"
	nameLong = "Endoh Station"
	map_dir = "endohstation"
	tDomeX = 500
	tDomeY = 500
	tDomeZ = 2
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
		)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 253
	center_y = 250

////////////////////////////////////////////////////////////////
#include "endohstation.dmm"
#endif
