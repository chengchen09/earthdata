#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <math.h>
#include "wgrib2.h"
#include "CodeTable4_4.h"

#define  FEB29   (31+29)
static int monthjday[12] = {
        0,31,59,90,120,151,181,212,243,273,304,334};

static int leap(int year) {
	if (year % 4 != 0) return 0;
	if (year % 100 != 0) return 1;
	return (year % 400 == 0);
}


/*
    add_time:  adds a positive value to a time code
    public domain 2006: wesley ebisuzaki
    1/2007 cleanup M. Schwarb, W. Ebisuzaki
    1/2006 removed floor(), case where floor(24/24.0) == 0
    some day should allow +/- dtime (not needed for this application
 */

int add_time(int *year, int *month, int *day, int *hour, int *minute, int *second, 
   unsigned int dtime, int unit) {

    int y, m, d, h, mm, s, jday, i;

    y = *year;
    m = *month;
    d = *day;
    h = *hour;
    mm = *minute;
    s = *second;

    if (unit == 255 || unit == -1) return 0;	// no valid time unit
    if (dtime == 0xffffffff) return 0;		// missing dtime

    if (unit == YEAR) {
	*year = y + dtime;
	return 0;
    }
    if (unit == DECADE) {
	*year =  y + (10 * dtime);
	return 0;
    }
    if (unit == CENTURY) {
	*year = y + (100 * dtime);
	return 0;
    }
    if (unit == NORMAL) {
	*year = y + (30 * dtime);
	return 0;
    }
    if (unit == MONTH) {
/*
        if (dtime < 0) {
           i = (-dtime) / 12 + 1;
           y -= i;
           dtime += (i * 12);
        }
*/
	dtime += (m - 1);
	*year = y + (dtime / 12);
	*month = 1 + (dtime % 12);
	return 0;
    }
    if (unit == SECOND) {
	s += dtime;
	// dtime = floor(s/60.0);
	dtime =  s / 60;
	*second = s - dtime*60;
	if (dtime == 0) return 0;
	unit = MINUTE;
    }
    if (unit == MINUTE) {
	mm += dtime;
	// dtime = floor(mm/60.0);
	dtime = mm /60;
	*minute = mm - dtime*60;
	if (dtime == 0) return 0;
	unit = HOUR;
    }
    if (unit == HOUR3) {
	dtime *= 3;
	unit = HOUR;
    }
    if (unit == HOUR6) {
	dtime *= 6;
	unit = HOUR;
    }
    if (unit == HOUR12) {
	dtime *= 12;
	unit = HOUR;
    }
    if (unit == HOUR) {
	h += dtime;
	// dtime = floor(h/24.0);
	dtime = h / 24;
	*hour = h - dtime*24;
	if (dtime == 0) return 0;
	unit = DAY;
    }

    /* this is the hard part */

    if (unit == DAY) {
	/* set m and day to Jan 0, and readjust dtime */
	jday = d + monthjday[m-1];
	if (leap(y) && m > 2) jday++;
        dtime += jday;
/*
        while (dtime < 0) {
            y--;
	    dtime += 365 + leap(y);
        }
*/
	/* one year chunks */
	while (dtime > 365 + leap(y)) {
	    dtime -= (365 + leap(y));
	    y++;
	}

	/* calculate the month and day */

	if (leap(y) && dtime == FEB29) {
	    m = 2;
	    d = 29;
	}
	else {
	    if (leap(y) && dtime > FEB29) dtime--;
	    for (i = 11; monthjday[i] >= dtime; --i);
	    m = i + 1;
	    d = dtime - monthjday[i];
	}
	*year = y;
	*month = m;
	*day = d;
	return 0;
   }
   fprintf(stderr,"add_time: undefined time unit %d\n", unit);
   return 1;
}

/*
   This routine reads year/month/day.../second byte code and saves it in variables
 */

int get_time(unsigned char *p, int *year, int *month, int *day, int *hour, int *minute, int *second) {
    *year = (p[0] << 8) | p[1];
    p += 2;
    *month = (int) *p++;
    *day = (int) *p++;
    *hour = (int) *p++;
    *minute = (int) *p++;
    *second = (int) *p;
    return 0;
}

/*
   inverse of get_time .. save time code in PDS
 */

int save_time(int year, int month, int day, int hour, int minute, int second, unsigned char *p) {

    *p++ = (unsigned char) (year >> 8) & 255;
    *p++ = (unsigned char) year & 255;
    *p++ = (unsigned char) month;
    *p++ = (unsigned char) day;
    *p++ = (unsigned char) hour;
    *p++ = (unsigned char) minute;
    *p++ = (unsigned char) second;
    return 0;
}

/*
   compare two time codes: return -1 : 0 : 1
 */

int cmp_time(
int year0, int month0, int day0, int hour0, int minute0, int second0, 
int year1, int month1, int day1, int hour1, int minute1, int second1) {

	if (year0 < year1) return -1;
	if (year0 > year1) return 1;
	if (month0 < month1) return -1;
	if (month0 > month1) return 1;
	if (day0 < day1) return -1;
	if (day0 > day1) return 1;
	if (hour0 < hour1) return -1;
	if (hour0 > hour1) return 1;
	if (minute0 < minute1) return -1;
	if (minute0 > minute1) return 1;
	if (second0 < second1) return -1;
	if (second0 > second1) return 1;
	return 0;
}

