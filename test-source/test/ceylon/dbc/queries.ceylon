import ceylon.test {
    ...
}

import java.util {
    Date,
    UUID {
        randomUUID
    }
}

test void queryTests() {
    sql.Insert("INSERT INTO test1(name,when,count) VALUES (?, ?, ?)")
            .execute("First", Date(), 1);
    sql.Insert("INSERT INTO test1(name,when,count,price,flag) VALUES (?, ?, ?, ?, ?)")
            .execute("Third", Date(), 3, 12.34, true);
    sql.Insert("INSERT INTO test1(name,when,count) VALUES (?, ?, ?)")
            .execute("Second", Date(0), 2);
    
    value q1 = sql.Select("SELECT * FROM test1 WHERE name=?");
    q1.forEachRow("Third")((row) => print(row["count"]));
    assertEquals(q1.execute("Second").size, 1);
    try (r1 = q1.Results("First")) {
        assertTrue(r1.size==1, "Rows with 'First'");
        for (row in r1) {
            assertTrue(row.size==9);
        }
    }
    try (r2 = q1.Results("Second")) {
        assertTrue(r2.size==1, "Rows with 'Second'");
    }
    try (r3 = q1.Results("whatever")) {
        assertTrue(r3.empty, "'whatever' should return empty");
    }
    
    value q2 = sql.Select("SELECT * FROM test1");
    try (r4 = q2.Results()) {
        assertTrue(r4.size==3, "all rows");
    }
    q2.limit=2;
    try (r5 = q2.Results()) {
        assertTrue(r5.size==2, "2 rows");
    }
    q2.limit=1;
    try (r6 = q2.Results()) {
        assertTrue(r6.size==1, "1 row");
    }
    
    value q3 = sql.Select("SELECT name as id, count FROM test1");
    try (r=q3.Results()) {
        assert (!r.empty);
        for (row in r) {
            assert ("id" in row.keys);
            assert ("count" in row.keys);
            assert (!"name" in row.keys);
        }
    }
}

test void selectSingleValue() {
    value uuid1 = randomUUID();
    value byteArray = Array({1.byte, 2.byte, 3.byte});
    
    sql.Insert("INSERT INTO test1(name, count, flag) VALUES (?, ?, ?)").execute("a", 1, true);
    sql.Insert("INSERT INTO test1(name, count) VALUES (?, ?)").execute("b", 2);
    sql.Insert("INSERT INTO test1(name, count) VALUES (?, ?)").execute("c", 3);
    sql.Insert("INSERT INTO test1(name, count, a_uuid) VALUES (?, ?, ?)")
            .execute("c", 4, uuid1);
    sql.Insert("INSERT INTO test1(name, count, bytes) VALUES (?, ?, ?)")
            .execute("d", 5, byteArray);
    
    value count = sql.Select("SELECT COUNT(*) FROM test1").singleValue<Integer>();
    assert(count == 5);
    
    value min = sql.Select("SELECT MIN(count) FROM test1").singleValue<Number<Integer>>();
    assert(min == 1);
    
    value max = sql.Select("SELECT MAX(count) FROM test1").singleValue<Object>();
    assert(is Integer max, max == 5);
    
    value name = sql.Select("SELECT name FROM test1 WHERE count = ?").singleValue<String>(2);
    assert(name == "b");
    
    value flag = sql.Select("SELECT flag FROM test1 WHERE name = ?").singleValue<Boolean>("a");
    assert(flag);    

    value uuidResult = 
            sql.Select("SELECT a_uuid FROM test1 WHERE a_uuid = ?").singleValue<UUID>(uuid1);
    assertEquals(uuidResult, uuid1);

    value byteArrayResult = 
            sql.Select("SELECT bytes FROM test1 WHERE name = ?").singleValue<Array<Byte>>("d");
    assertEquals(byteArrayResult, byteArray);
}