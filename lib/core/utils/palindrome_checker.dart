bool isPalindrome(String input) {
  final normalized = input.toLowerCase().replaceAll(' ', '');
  if (normalized.isEmpty) return false;
  final reversed = normalized.split('').reversed.join('');
  return normalized == reversed;
}
