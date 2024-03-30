import 'dart:math';

int generateRandomNumbers() {
  Random random = Random();

  int randomNumber = random.nextInt(8081 - 3001) + 3001;

  return randomNumber;
}
