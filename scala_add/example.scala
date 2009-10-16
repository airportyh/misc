scala> abstract class Addable[T]{
     |   def +(x: T, y: T): T
     | }
defined class Addable

scala> def add[T](x: T, y: T)(implicit addy: Addable[T]): T = 
     | addy.+(x, y)
add: [T](T,T)(implicit Addable[T])T

scala> implicit object IntAddable extends Addable[Int]{
     |   def +(x: Int, y: Int): Int = x + y
     | }
defined module IntAddable

scala> implicit object DoubleAddable extends Addable[Double]{
     |   def +(x: Double, y: Double): Double = x + y
     | }
defined module DoubleAddable

scala> add(1,2)
res0: Int = 3

scala> add(1.0, 2.0)
res1: Double = 3.0

scala> implicit object StringAddable extends Addable[String]{
     |   def +(x: String, y: String): String = x concat y
     | }
defined module StringAddable

scala> add("abc", "def")
res2: java.lang.String = abcdef
