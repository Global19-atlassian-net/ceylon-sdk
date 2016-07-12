import java.lang {
    JInt=Integer {
        maxInt=MAX_VALUE
    },
    Long {
        maxLong=MAX_VALUE,
        minLong=MIN_VALUE
    }
}
import java.math {
    BigInteger
}

"A `Whole` instance representing zero."
shared Whole zero => zeroImpl;
WholeImpl zeroImpl = WholeImpl(BigInteger.zero);

"A `Whole` instance representing one."
shared Whole one => oneImpl;
WholeImpl oneImpl = WholeImpl(BigInteger.one);

"A `Whole` instance representing two."
shared Whole two = wholeNumber(2);

Whole intMax = wholeNumber(maxInt);
Whole longMax= wholeNumber(maxLong);
Whole longMin = wholeNumber(minLong);
