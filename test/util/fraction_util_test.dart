import 'package:flutter_test/flutter_test.dart';
import 'package:home_cooked/util/fraction_util.dart';

void main() {

  test('To Fraction should convert 1.5', () async {
    expect(FractionUtil.toFraction(1.5), "1 1/2");
  });

  test('To Fraction should convert 1.66666666667', () async {
    expect(FractionUtil.toFraction(5/3), "1 2/3");
  });

  test('To Fraction should convert 0.11111111', () async {
    expect(FractionUtil.toFraction(1/9), "1/9");
  });

  test('To Fraction should convert -0.11111111', () async {
    expect(FractionUtil.toFraction(-1/9), "-1/9");
  });

  test('To Fraction should convert -1.11111111', () async {
    expect(FractionUtil.toFraction(-10/9), "-1 1/9");
  });

  test('To Fraction should convert 1.0', () async {
    expect(FractionUtil.toFraction(1.0), "1");
  });

  test('To Fraction should convert -1.0', () async {
    expect(FractionUtil.toFraction(-1.0), "-1");
  });

  test('To Fraction should convert 0.999999', () async {
    expect(FractionUtil.toFraction(0.999999), "1");
  });

  test('To Fraction should convert -0.999999', () async {
    expect(FractionUtil.toFraction(-0.999999), "-1");
  });

}
