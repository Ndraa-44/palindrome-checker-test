import 'package:flutter_test/flutter_test.dart';
import 'package:km_test/core/utils/palindrome_checker.dart';

void main() {
  group('Palindrome Checker', () {
    test('kasur rusak is a palindrome', () {
      expect(isPalindrome("kasur rusak"), isTrue);
    });

    test('step on no pets is a palindrome', () {
      expect(isPalindrome("step on no pets"), isTrue);
    });

    test('put it up is a palindrome', () {
      expect(isPalindrome("put it up"), isTrue);
    });

    test('suitmedia is not a palindrome', () {
      expect(isPalindrome("suitmedia"), isFalse);
    });

    test('empty string or spaces only is false', () {
      expect(isPalindrome(""), isFalse);
      expect(isPalindrome("   "), isFalse);
    });

    test('1 character string is a palindrome', () {
      expect(isPalindrome("a"), isTrue);
      expect(isPalindrome(" A "), isTrue);
    });
  });
}
