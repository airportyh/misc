abstract class Addable[T]{
  def +(x: T, y: T): T
}
object HelloWorld extends Application{

    def add[T](x: T, y: T)(implicit addy: Addable[T]): T = addy.+(x, y)
	implicit object IntAddable extends Addable[Int]{
	  def +(x: Int, y: Int): Int = x + y
	}
	implicit object DoubleAddable extends Addable[Double]{
	  def +(x: Double, y: Double): Double = x + y
	}
	implicit object StringAddable extends Addable[String]{
	  def +(x: String, y: String): String = x concat y
	}
	println(add(1, 2))
	println(add(1.5, 2.5))
	println(add("abc", "def"))
	
}