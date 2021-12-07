// ignore_for_file: public_member_api_docs

extension ListNumExtensions on List<num> {
  int findSmallestIndexWithMinimumValue() {
    int index = 0;
    for (int i = 1; i < length; i++) {
      if (this[i] < this[index]) {
        index = i;
      }
    }
    return index;
  }
}
