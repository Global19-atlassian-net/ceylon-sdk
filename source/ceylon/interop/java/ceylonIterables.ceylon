import java.lang {
    JString=String,
    JLong=Long,
    JInteger=Integer,
    JShort=Short,
    JDouble=Double,
    JFloat=Float,
    JByte=Byte,
    JBoolean=Boolean,
    JIterable=Iterable
}

"A Ceylon [[Iterable]]`<ceylon.language::String>` that adapts an instance of Java's 
   [[`java.lang::Iterable`|java.lang::Iterable]]`<java.lang::String>`, allowing its elements to be 
   iterated using a `for` loop."
shared class CeylonStringIterable(JIterable<out JString> iterable) 
        satisfies {String*} {
    iterator() => { for (str in iterable) str.string }.iterator();
}

"A Ceylon [[Iterable]]`<ceylon.language::Integer>` that adapts an instance of Java's 
 [[`java.lang::Iterable`|Iterable]]`<java.lang::Long>`, 
 `java.lang::Iterable<java.lang::Integer>` or
 `java.lang::Iterable<java.lang::Short>` allowing its elements to be 
 iterated using a `for` loop."
shared class CeylonIntegerIterable(JIterable<out JLong|JInteger|JShort> iterable) 
        satisfies {Integer*} {
    iterator() => { for (int in iterable) int.longValue() }.iterator();
}

"A Ceylon [[Iterable]]`<ceylon.language::Float>` that adapts an instance of Java's 
 [[`java.lang::Iterable`|java.lang::Iterable]]`<java.lang::Double>` or
 `java.lang::Iterable<java.lang::Float>`, allowing its elements to be 
 iterated using a `for` loop."
shared class CeylonFloatIterable(JIterable<out JDouble|JFloat> iterable) 
        satisfies {Float*} {
    iterator() => { for (float in iterable) float.doubleValue() }.iterator();
}

"A Ceylon [[Iterable]]`<ceylon.language::Byte>` that adapts an instance of Java's 
 [[`java.lang::Iterable`|java.lang::Iterable]]`<java.lang::Byte>`, allowing its elements to be 
 iterated using a `for` loop."
shared class CeylonByteIterable(JIterable<out JByte> iterable) 
        satisfies {Byte*} {
    iterator() => { for (byte in iterable) byte.byteValue() }.iterator();
}

"A Ceylon [[Iterable]]`<ceylon.language::Boolean>` that adapts an instance of Java's 
 [[`java.lang::Iterable`|java.lang::Iterable]]`<java.lang::Boolean>`, allowing its elements to be 
 iterated using a `for` loop."
shared class CeylonBooleanIterable(JIterable<out JBoolean> iterable) 
        satisfies {Boolean*} {
    iterator() => { for (boolean in iterable) boolean.booleanValue() }.iterator();
}

