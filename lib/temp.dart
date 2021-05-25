import 'dart:io';

void main() {
  print('pas1');
  ct();
  print('pass2');
}

void ct() {
  bt();
}

void bt() async {
  int a = await rt();
  print('ans $a');
}

Future<int> rt() {
  Future<int> ret = Future.delayed(Duration(seconds: 5), () {
    return 6;
  });
  print('in fnc');
  return ret;
}
