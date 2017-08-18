"A selection of utility methods for accessing Unicode 
 information about `Character`s and performing locale-aware
 transformations on `String`s:
 
 - [[uppercase]] and [[lowercase]] change the case of a
   `String` according to the rules of a certain locale,
 - [[graphemes]], [[words]], and [[sentences]] allow 
   iteration of the Unicode graphemes, words, and sentences
   in a `String`, according to locale-specific rules,
 - [[characterName]] returns the Unicode character name of
   a character, and
 - [[generalCategory]] and [[directionality]] return the
   Unicode general category and directionality of a 
   `Character`."
by("Tom Bentley")
native("jvm")
module ceylon.unicode maven:"org.ceylon-lang" "1.3.3" {
    shared import java.base "7";
}
