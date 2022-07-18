import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPegawaiController extends GetxController {
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController passAdminC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addPegawaiProcess() async {
    if (passAdminC.text.isNotEmpty) {
      try {
        String emailAdmin = auth.currentUser!.email!;

        UserCredential userCredentialAdmin =
            await auth.signInWithEmailAndPassword(
          email: emailAdmin,
          password: passAdminC.text,
        );

        UserCredential pegawaiCredential =
            await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: "password",
        );

        if (pegawaiCredential.user != null) {
          String uid = pegawaiCredential.user!.uid;

          await firestore.collection("pegawai").doc(uid).set({
            "nip": nipC.text,
            "nama": nameC.text,
            "email": emailC.text,
            "uid": uid,
            "createdAt": DateTime.now().toIso8601String(),
          });

          await pegawaiCredential.user!.sendEmailVerification();

          await auth.signOut();

          UserCredential userCredentialAdmin =
              await auth.signInWithEmailAndPassword(
            email: emailAdmin,
            password: passAdminC.text,
          );

          Get.back(); // close dialog
          Get.back(); // back to home
          Get.snackbar("Berhasil", "Berhasil menambahkan pegawai");
          // await auth.signInWithEmailAndPassword(email: email, password: password);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Get.snackbar("Terjadi kesalahan", "Password yang digunakan lemah.");
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar("Terjadi kesalahan", "Akun telah digunakan.");
        } else if (e.code == 'wrong-password') {
          Get.snackbar("Terjadi kesalahan", "Password salah.");
        } else {
          Get.snackbar("Terjadi kesalahan", "${e.code}");
        }
      } catch (e) {
        Get.snackbar("Terjadi Kesalahan", "Tidak dapat menambahkan akun.");
      }
    } else {
      Get.snackbar(
          "Terjadi kesalahan", "Password wajib diisi untuk keperluan validasi");
    }
  }

  void addPegawai() async {
    if (nameC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty) {
      Get.defaultDialog(
        title: "Validasi Admin",
        content: Column(
          children: [
            Text("Masukkan password untuk validasi admin."),
            TextField(
              controller: passAdminC,
              autocorrect: false,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await addPegawaiProcess();
            },
            child: Text("Add Pegawai"),
          ),
        ],
      );

// excute storage
    } else {
      Get.snackbar("Terjadi Kesalahan", "NIP, Nama, Email tidak boleh kosong.");
    }
  }
}
