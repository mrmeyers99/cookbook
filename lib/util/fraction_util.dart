class FractionUtil {

  // https://stackoverflow.com/a/5128558
  static String toFraction (double x) {
    double error = 0.001;
    bool isNegative = x.isNegative;
    x = x.abs();
    int n = x.floor();
    x -= n;
    if (x < error) {
      return (n * (isNegative ? -1 : 1)).toString();
    } else if (1 - error < x) {
      return ((n + 1) * (isNegative ? -1 : 1)).toString();
    }

    // The lower fraction is 0/1
    int lowerN = 0;
    int lowerD = 1;
    // The upper fraction is 1/1
    int upperN = 1;
    int upperD = 1;
    while(true) {
      // The middle fraction is (lowerN + upperN) / (lowerD + upper_d)
      int middleN = lowerN + upperN;
      int middleD = lowerD + upperD;
      // If x + error < middle
      if (middleD * (x + error) < middleN) {
        // middle is our new upper
        upperN = middleN;
        upperD = middleD;
      }
      // Else If middle < x - error
      else if (middleN < (x - error) * middleD) {
        // middle is our new lower
        lowerN = middleN;
        lowerD = middleD;
      }
      // Else middle is our best fraction
      else if (n == 0) {
        return "${isNegative ? '-' : ''}$middleN/$middleD";
      } else {
        return "${isNegative ? '-' : ''}$n $middleN/$middleD";
      }
    }
  }
//
//
//  static String toFraction(double d) {
//    var numberAsString = d.toStringAsFixed(4);
////    var afterDecimal = numberAsString.split(".")[1].split('');
////    var trailingZeros = afterDecimal.reversed.takeWhile((value) => value == "0").reduce((value, element) => value + element).length;
//    print("is infinite: ${d.isInfinite}");
//    var numerator = (d * pow(10, 4)).toInt();
//    var denominator = 1 * pow(10, 4);
//    print("$numerator / $denominator");
//    var gcd = numerator.gcd(denominator);
//    print("gcd = $gcd");
//    numerator = numerator ~/ gcd;
//    denominator = denominator ~/ gcd;
//    print("$numerator / $denominator");
//
//    print("as fraction: ${Fraction(5, 3).toString()}");
//
//    if (numerator > denominator) {
//      var times = (numerator / denominator).floor();
//      var fraction = "$times ${numerator - times*denominator}/$denominator";
//      print(fraction);
//      return fraction;
//    } else {
//      var fraction = "$numerator/$denominator";
//      print(fraction);
//      return fraction;
//    }
//
//  }
//
//  static String hasRepeating()
}
