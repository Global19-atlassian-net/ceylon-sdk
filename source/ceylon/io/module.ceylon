
"This module allows you to read and write to streams, such 
 as files, sockets and pipes.
 
 See the `ceylon.io` package for usage examples."
by("Stéphane Épardaud")
license("Apache Software License")
native("jvm")
module ceylon.io "1.2.3.SNAPSHOT" {
    shared import ceylon.buffer "1.2.3.SNAPSHOT";
    shared import ceylon.file "1.2.3.SNAPSHOT";
    import ceylon.collection "1.2.3.SNAPSHOT";
    import java.base "7";
    import java.tls "7";
    import ceylon.interop.java "1.2.3.SNAPSHOT";
}
