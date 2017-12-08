import ceylon.test {
    assertEquals,
    assertTrue,
    assertFalse,
    test
}
import ceylon.time {
    Date,
    Period,
    Duration,
    date,
    DateRange,
    DateTimeRange,
    dateTime
}
import ceylon.time.base {
    january,
    march,
    february,
    milliseconds,
    months,
    years,
    saturday,
    days,
    october,
    december
}

DateTimeRange jan_date_time_range = dateTime(2013, january, 1).rangeTo(dateTime(2013, january, 31));
DateTimeRange jan_date_time_range_reverse = dateTime(2013, january, 31).rangeTo(dateTime(2013, january, 1));

shared test void testEqualsAndHashDateTimeRange() {
    DateTimeRange instanceA_1 = dateTime(2013, january, 1).rangeTo(dateTime(2013, january, 31));
    DateTimeRange instanceA_2 = dateTime(2013, january, 1).rangeTo(dateTime(2013, january, 31));
    DateTimeRange instanceB_1 = dateTime(2013, january, 5).rangeTo(dateTime(2013, january, 20, 9 ,9));
    DateTimeRange instanceB_2 = dateTime(2013, january, 5).rangeTo(dateTime(2013, january, 20, 9 ,9));

    assertTrue(instanceA_1 == instanceA_2);
    assertTrue(instanceA_1.hash == instanceA_2.hash);

    assertTrue(instanceB_1 == instanceB_2);
    assertTrue(instanceB_1.hash == instanceB_2.hash);

    assertFalse(instanceA_1 == instanceB_1);
    assertFalse(instanceA_2 == instanceB_1);
    assertFalse(instanceA_1.hash == instanceB_1.hash);
    assertFalse(instanceA_2.hash == instanceB_1.hash);
}

shared test void testStepDateTime() {
    assertEquals { expected = days; actual = jan_date_range.step; };
}

shared test void testAnyExistDateTime() {
    assertTrue(jan_date_range.any(( Date date ) => date.dayOfWeek == saturday));
}

shared test void testAnyNotExistDateTime() {
    assertFalse(jan_date_range.any(( Date date ) => date.year == 2014));
}

shared test void testRangeDateTime() {
    assertIntervalDateTime{
         start = date(2013, february,1);
         end = date(2013, february,28);
         period = Period{ days = 27; };
         duration = Duration( 27 * milliseconds.perDay );
    };
}

shared test void testRangeDateTimeFourYears() {
    assertIntervalDateTime{
         start = date(2010, january, 1);
         end = date(2014, december, 31);
         period = Period{ years = 4; months = 11; days = 30; };
    };
}

shared test void testIntervalDateTimeReverse() {
    assertIntervalDateTime{
         start = date(2013, february,28);
         end = date(2013, february,1);
         period = Period{ days = -27; };
         duration = Duration( -27 * milliseconds.perDay );
    };
}

shared test void testGapDateTimeEmpty() {
    DateTimeRange feb = dateTime(2013, january, 1).rangeTo(dateTime(2013, january,28));
    
    assertEquals { expected = empty; actual = jan_date_time_range.gap(feb); };
}

shared test void testOverlapDateTimeEmpty() {
    DateTimeRange decemberRange = dateTime(2013, december, 1).rangeTo(dateTime(2013, december, 31));

    assertEquals { expected = empty; actual = jan_date_time_range.overlap(decemberRange); };
}

shared test void testGapDateTime() {
    DateRange mar = date(2013, march, 1).rangeTo(date(2013, march, 31));
    DateRange gap = date(2013, february, 1).rangeTo(date(2013, february, 28));
    
    assertEquals { expected = gap; actual = jan_date_range.gap(mar); };
}

shared test void testGapDateTimeReverse() {
    DateRange mar = date(2013, march, 1).rangeTo(date(2013, march,31));
    DateRange gap = date(2013, february, 1).rangeTo(date(2013, february, 28));
    
    assertEquals { expected = gap; actual = jan_date_range_reverse.gap(mar); };
}

shared test void testOverlapDateTime() {
    DateRange halfJan = date(2013, january, 5).rangeTo(date(2013, january, 15));
    DateRange overlap = date(2013, january, 5).rangeTo(date(2013, january, 15));

    assertEquals { expected = overlap; actual = jan_date_range.overlap(halfJan); };
}

shared test void testStepDayReverseDateTime() {
    assertEquals { expected = 31; actual = jan_date_range_reverse.size; };
    assertEquals { expected = date { year = 2013; month = january; day = 31; }; actual = jan_date_range_reverse.first; };
    assertEquals { expected = date(2013, january, 1); actual = jan_date_range_reverse.last; };
}

shared test void testStepMonthReverseDateTime() {
    DateRange interval = jan_date_range_reverse.stepBy(months);
    assertEquals { expected = 1; actual = interval.size; };
    assertEquals { expected = date(2013, january, 31); actual = interval.first; };
    assertEquals { expected = date(2013, january, 31); actual = interval.last; };
}

shared test void testStepYearReverseDateTime() {
    DateRange interval = jan_date_range_reverse.stepBy(years);
    assertEquals { expected = 1; actual = interval.size; };
    assertEquals { expected = date(2013, january, 31); actual = interval.first; };
    assertEquals { expected = date(2013, january, 31); actual = interval.last; };
}

shared test void testContainsDateTime() {
    assertEquals { expected = true; actual = date(2013, january, 15) in jan_date_range; };
}

shared test void testGapRulesABSmallerCD_DateTime() {
    //Combinations to Test: AB < CD
    //C1: 12 gap 56 = (2,5)
    //C2: 12 gap 65 = (2,5)
    //C3: 21 gap 56 = (2,5)
    //C4: 21 gap 65 = (2,5)

    value a = dateTime(2013, january, 1, 9);
    value b = dateTime(2013, january, 2, 15);
    value c = dateTime(2013, january, 5, 9);
    value d = dateTime(2013, january, 6, 15);

    value result = dateTime(2013, january, 2, 15, 0, 0, 1).rangeTo( dateTime(2013, january, 5, 8, 59, 59, 999) );

    //C1
    assertEquals{ 
        expected = result;
        actual = a.rangeTo( b ).gap( c.rangeTo( d ) );
    };

    //C2
    assertEquals{ 
        expected = result;
        actual = a.rangeTo( b ).gap( d.rangeTo( c ) );
    };

    //C3
    assertEquals{ 
        expected = result;
        actual = b.rangeTo( a ).gap( c.rangeTo( d ) );
    };

    //C4
    assertEquals{ 
        expected = result;
        actual = b.rangeTo( a ).gap( d.rangeTo( c ) );
    };
}

shared test void testGapRulesABHigherCD_DateTime() {
    //Combinations to Test: AB > CD
    //56 gap 12 = (2,5)
    //56 gap 21 = (2,5)
    //65 gap 12 = (2,5)
    //65 gap 21 = (2,5)

    value a = dateTime(2013, january, 5, 9);
    value b = dateTime(2013, january, 6, 15);
    value c = dateTime(2013, january, 1, 9);
    value d = dateTime(2013, january, 2, 15);

    value result = dateTime(2013, january, 2, 15, 0, 0, 1).rangeTo(dateTime(2013, january, 5, 8, 59, 59, 999));

    //C1
    assertEquals{ 
        expected = result;
        actual = a.rangeTo( b ).gap( c.rangeTo( d ) );
    };

    //C2
    assertEquals{ 
        expected = result;
        actual = a.rangeTo( b ).gap( d.rangeTo( c ) );
    };

    //C3
    assertEquals{ 
        expected = result;
        actual = b.rangeTo( a ).gap( c.rangeTo( d ) );
    };

    //C4
    assertEquals{ 
        expected = result;
        actual = b.rangeTo( a ).gap( d.rangeTo( c ) );
    };
}

shared test void testOverlapRulesABSmallerCD_DateTime() {
    //Combinations to Test: AB < CD
    //C1: 16 overlap 39 = [3,6]
    //C2: 16 overlap 93 = [3,6]
    //C3: 61 overlap 39 = [3,6]
    //C4: 61 overlap 93 = [3,6]

    value a = dateTime(2013, january, 1, 9);
    value b = dateTime(2013, january, 6, 15);
    value c = dateTime(2013, january, 3, 9);
    value d = dateTime(2013, january, 9, 15);

    value result = dateTime(2013, january, 3, 9).rangeTo( dateTime(2013, january, 6, 15) );

    //C1
    assertEquals{ 
        expected = result;
        actual = a.rangeTo( b ).overlap( c.rangeTo( d ) );
    };

    //C2
    assertEquals{ 
        expected = result;
        actual = a.rangeTo( b ).overlap( d.rangeTo( c ) );
    };

    //C3
    assertEquals{ 
        expected = result;
        actual = b.rangeTo( a ).overlap( c.rangeTo( d ) );
    };

    //C4
    assertEquals{ 
        expected = result;
        actual = b.rangeTo( a ).overlap( d.rangeTo( c ) );
    };
}

shared test void testOverlapRulesABHigherCD_DateTime() {
    //Combinations to Test: AB > CD
    //39 gap 16 = [3,6]
    //39 gap 61 = [3,6]
    //93 gap 16 = [3,6]
    //93 gap 61 = [3,6]

    value a = dateTime(2013, january, 3, 9);
    value b = dateTime(2013, january, 9, 15);
    value c = dateTime(2013, january, 1, 9);
    value d = dateTime(2013, january, 6, 15);

    value result = dateTime(2013, january, 3, 9).rangeTo( dateTime(2013, january, 6, 15) );

    //C1
    assertEquals{ 
        expected = result;
        actual = a.rangeTo( b ).overlap( c.rangeTo( d ) );
    };

    //C2
    assertEquals{ 
        expected = result;
        actual = a.rangeTo( b ).overlap( d.rangeTo( c ) );
    };

    //C3
    assertEquals{ 
        expected = result;
        actual = b.rangeTo( a ).overlap( c.rangeTo( d ) );
    };

    //C4
    assertEquals{ 
        expected = result;
        actual = b.rangeTo( a ).overlap( d.rangeTo( c ) );
    };
}

test void testDateTimeRangeString() {
    assertEquals { expected = "2013-10-01T09:10:11.000/2013-10-31T11:00:00.999"; actual = DateTimeRange(dateTime(2013, october, 1, 9, 10, 11), dateTime(2013, october, 31, 11, 0, 0, 999)).string; };
    assertEquals { expected = "2014-01-01T23:00:00.000/2013-01-01T00:00:00.000"; actual = DateTimeRange(dateTime(2014, january, 1, 23), dateTime(2013, january, 1)).string; };
}

void assertIntervalDateTime( Date start, Date end, Period period, Duration? duration = null )  {
    value range = start.rangeTo(end);
    assertEquals { expected = period; actual = range.period; };

    assertEquals { expected = end; actual = start.plus(period); };
    assertEquals { expected = start; actual = end.minus(period); };

    assertEquals { expected = start; actual = range.first; };
    assertEquals { expected = end; actual = range.last; };

    if( exists duration ) {
        assertEquals { expected = duration; actual = range.duration; };
    }
}
