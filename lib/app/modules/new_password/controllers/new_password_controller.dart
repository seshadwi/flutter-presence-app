import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presence_app/app/routes/app_pages.dart';

class NewPasswordController extends GetxController {
  TextEditingController newPassC = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  void newPassword() async {
    if (newPassC.text.isNotEmpty) {
      if (newPassC.text != "password") {
        try {
          String email = auth.currentUser!.email!;
          await auth.currentUser!.updatePassword(newPassC.text);
          await auth.signOut();

          await auth.signInWithEmailAndPassword(
            email: email,
            password: newPassC.text,
          );

          Get.offAllNamed(Routes.HOME);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            Get.snackbar(
                "Terjadi kesalahan", "Password lemah. Setidaknya 6 karakter.");
          } else if (e.code == 'wrong-password') {
            Get.snackbar("Terjadi kesalahan", "Password salah.");
          }
        } catch (e) {
          Get.snackbar("Terjadi kesalahan",
              "Tidak dapat membuat password baru. Hubungi admin / cs");
        }
      } else {
        Get.snackbar("Terjadi kesalahan", "password baru harus diubah");
      }
    } else {
      Get.snackbar("Terjadi kesalahan", "Password baru wajib diisi");
    }
  }
}
