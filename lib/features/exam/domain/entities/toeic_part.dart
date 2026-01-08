enum ToeicPart {
  part1,
  part2,
  part3,
  part4,
  part5,
  part6,
  part7;

  String get title {
    switch (this) {
      case ToeicPart.part1:
        return 'Part 1: Photographs';
      case ToeicPart.part2:
        return 'Part 2: Question-Response';
      case ToeicPart.part3:
        return 'Part 3: Conversations';
      case ToeicPart.part4:
        return 'Part 4: Talks';
      case ToeicPart.part5:
        return 'Part 5: Incomplete Sentences';
      case ToeicPart.part6:
        return 'Part 6: Text Completion';
      case ToeicPart.part7:
        return 'Part 7: Reading Comprehension';
    }
  }

  String get description {
    switch (this) {
      case ToeicPart.part1:
        return 'Listen and choose the statement that best describes the photograph';
      case ToeicPart.part2:
        return 'Listen to questions and choose the best response';
      case ToeicPart.part3:
        return 'Listen to conversations and answer questions';
      case ToeicPart.part4:
        return 'Listen to talks and answer questions';
      case ToeicPart.part5:
        return 'Complete sentences with correct grammar';
      case ToeicPart.part6:
        return 'Fill in blanks in texts';
      case ToeicPart.part7:
        return 'Read passages and answer comprehension questions';
    }
  }

  int get partNumber {
    return index + 1;
  }

  int get questionCount {
    switch (this) {
      case ToeicPart.part1:
        return 6;
      case ToeicPart.part2:
        return 25;
      case ToeicPart.part3:
        return 39;
      case ToeicPart.part4:
        return 30;
      case ToeicPart.part5:
        return 30;
      case ToeicPart.part6:
        return 16;
      case ToeicPart.part7:
        return 54;
    }
  }

  bool get isListening {
    return this == ToeicPart.part1 ||
        this == ToeicPart.part2 ||
        this == ToeicPart.part3 ||
        this == ToeicPart.part4;
  }

  bool get isReading {
    return !isListening;
  }
}