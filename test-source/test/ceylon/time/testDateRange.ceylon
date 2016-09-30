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
    DateRange
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

DateRange jan_date_range = date(2013, january, 1).rangeTo(date(2013, january, 31));
DateRange jan_date_range_reverse = date(2013, january, 31).rangeTo(date(2013, january, 1));

shared test void testEqualsAndHashDateRange() {
    DateRange instanceA_1 = date(2013, january, 1).rangeTo(date(2013, january, 31));
    DateRange instanceA_2 = date(2013, january, 1).rangeTo(date(2013, january, 31));
    DateRange instanceB_1 = date(2013, december, 1).rangeTo(date(2013, december, 31));
    DateRange instanceB_2 = date(2013, december, 1).rangeTo(date(2013, december, 31));
    
    assertTrue(instanceA_1 == instanceA_2);
    assertTrue(instanceA_1.hash == instanceA_2.hash);
    
    assertTrue(instanceB_1 == instanceB_2);
    assertTrue(instanceB_1.hash == instanceB_2.hash);
    
    assertFalse(instanceA_1 == instanceB_1);
    assertFalse(instanceA_2 == instanceB_1);
    assertFalse(instanceA_1.hash == instanceB_1.hash);
    assertFalse(instanceA_2.hash == instanceB_1.hash);
}

shared test void testStepDays() {
    assertEquals { expected = days; actual = jan_date_range.step; };
}

shared test void testStepMonths() {
    assertEquals { expected = months; actual = jan_date_range.stepBy(months).step; };
}

shared test void testStepYears() {
    assertEquals { expected = years; actual = jan_date_range.stepBy(years).step; };
}

shared test void testAnyExist() {
    assertTrue(jan_date_range.any(( Date date ) => date.dayOfWeek == saturday));
}

shared test void testAnyNotExist() {
    assertFalse(jan_date_range.any(( Date date ) => date.year == 2014));
}

shared test void testRangeDate() {
    assertIntervalDate{
         start = date(2013, february,1);
         end = date(2013, february,28);
         period = Period{ days = 27; };
         duration = Duration( 27 * milliseconds.perDay );
    };
}

shared test void testRangeDateFourYears() {
    assertIntervalDate{
         start = date(2010, january, 1);
         end = date(2014, december, 31);
         period = Period{ years = 4; months = 11; days = 30; };
    };
}

shared test void testIntervalDateReverse() {
    assertIntervalDate{
         start = date(2013, february,28);
         end = date(2013, february,1);
         period = Period{ days = -27; };
         duration = Duration( -27 * milliseconds.perDay );
    };
}

shared test void testGapDate() {
    DateRange mar = date(2013, march, 1).rangeTo(date(2013, march, 31));
    DateRange gap = date(2013, february, 1).rangeTo(date(2013, february, 28));
    
    assertEquals { expected = gap; actual = jan_date_range.gap(mar); };
}

shared test void testGapDateReverse() {
    DateRange mar = date(2013, march, 1).rangeTo(date(2013, march,31));
    DateRange gap = date(2013, february, 1).rangeTo(date(2013, february, 28));
    
    assertEquals { expected = gap; actual = jan_date_range_reverse.gap(mar); };
}

shared test void testGapDateOneYear() {
    DateRange _2013 = date(2013, january, 1).rangeTo(date(2013, december, 31));
    DateRange _2015 = date(2015, january, 1).rangeTo(date(2015, december, 31));

    DateRange _2014 = date(2014, january, 1).rangeTo(date(2014, december, 31));
    assertEquals { expected = _2014; actual = _2015.gap(_2013); };
}

shared test void testGapDateEmpty() {
    DateRange feb = date(2013, february, 1).rangeTo(date(2013, february,28));
    
    assertEquals { expected = empty; actual = jan_date_range_reverse.gap(feb); };
}

shared test void testOverlapDateEmpty() {
    DateRange decemberRange = date(2013, december, 1).rangeTo(date(2013, december, 31));

    assertEquals { expected = empty; actual = jan_date_range.overlap(decemberRange); };
}

shared test void testOverlapDate() {
    DateRange halfJan = date(2013, january, 5).rangeTo(date(2013, january, 15));
    DateRange overlap = date(2013, january, 5).rangeTo(date(2013, january, 15));

    assertEquals { expected = overlap; actual = jan_date_range.overlap(halfJan); };
}

shared test void testStepDayReverse() {
    assertEquals { expected = 31; actual = jan_date_range_reverse.size; };
    assertEquals { expected = date(2013, january, 31); actual = jan_date_range_reverse.first; };
    assertEquals { expected = date(2013, january, 1); actual = jan_date_range_reverse.last; };
}

shared test void testStepMonthReverse() {
    DateRange interval = jan_date_range_reverse.stepBy(months);
    assertEquals { expected = 1; actual = interval.size; };
    assertEquals { expected = date(2013, january, 31); actual = interval.first; };
    assertEquals { expected = date(2013, january, 31); actual = interval.last; };
}

shared test void testStepYearReverse() {
    DateRange interval = jan_date_range_reverse.stepBy(years);
    assertEquals { expected = 1; actual = interval.size; };
    assertEquals { expected = date(2013, january, 31); actual = interval.first; };
    assertEquals { expected = date(2013, january, 31); actual = interval.last; };
}

shared test void testContainsDate() {
    assertTrue(date(2013, january, 15) in jan_date_range);    
}

shared test void testNotContainsDate() {
    assertFalse(date(2013, january, 15) in jan_date_range.stepBy(years));   
}

shared test void testGapRulesABSmallerCD() {
    //Combinations to Test: AB < CD
    //C1: 12 gap 56 = (2,5)
    //C2: 12 gap 65 = (2,5)
    //C3: 21 gap 56 = (2,5)
    //C4: 21 gap 65 = (2,5)

    value a = date(2013, january, 1);
    value b = date(2013, january, 2);
    value c = date(2013, january, 5);
    value d = date(2013, january, 6);

    value result = date(2013, january, 3).rangeTo( date(2013, january, 4) );

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

shared test void testGapRulesABHigherCD() {
    //Combinations to Test: AB > CD
    //56 gap 12 = (2,5)
    //56 gap 21 = (2,5)
    //65 gap 12 = (2,5)
    //65 gap 21 = (2,5)

    value a = date(2013, january, 5);
    value b = date(2013, january, 6);
    value c = date(2013, january, 1);
    value d = date(2013, january, 2);

    value result = date(2013, january, 3).rangeTo( date(2013, january, 4) );

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

shared test void testOverlapRulesABSmallerCD() {
    //Combinations to Test: AB < CD
    //C1: 16 overlap 39 = [3,6]
    //C2: 16 overlap 93 = [3,6]
    //C3: 61 overlap 39 = [3,6]
    //C4: 61 overlap 93 = [3,6]

    value a = date(2013, january, 1);
    value b = date(2013, january, 6);
    value c = date(2013, january, 3);
    value d = date(2013, january, 9);

    value result = date(2013, january, 3).rangeTo( date(2013, january, 6) );

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

shared test void testOverlapRulesABHigherCD() {
    //Combinations to Test: AB > CD
    //39 overlap 16 = [3,6]
    //39 overlap 61 = [3,6]
    //93 overlap 16 = [3,6]
    //93 overlap 61 = [3,6]

    value a = date(2013, january, 3);
    value b = date(2013, january, 9);
    value c = date(2013, january, 1);
    value d = date(2013, january, 6);

    value result = date(2013, january, 3).rangeTo( date(2013, january, 6) );

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

test void testDateRangeString() {
    assertEquals { expected = "2013-10-01/2013-10-31"; actual = DateRange(date(2013, october, 1), date(2013, october, 31)).string; };
    assertEquals { expected = "2014-01-01/2013-01-01"; actual = DateRange(date(2014, january, 1), date(2013, january, 1)).string; };
}

void assertIntervalDate( Date start, Date end, Period period, Duration? duration = null )  {
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
