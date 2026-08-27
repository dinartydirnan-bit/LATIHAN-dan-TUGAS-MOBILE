import 'package:flutter/material.dart';

void main(){
  runApp(Latihan());
}
class Latihan extends StatelessWidget {
  const Latihan({super.key});

  @override
  Widget build(BuildContext context) {
    final String nama = "Dinarty Dirnan";
    return MaterialApp(
      home: Scaffold(appBar:AppBar(title: Text("Profil Mahasiswi Informatika")), 
      body: Center (
        child: Card(
          child: Padding(
            child: Column(children:[
              CircleAvatar(child: Icon(Icons.person)), 
              SizedBox(height:20),
              Text(nama, style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text ("Teknik Informatika"),
              Divider(height: 24),
              Text("Umur: 20 Tahun"),
              Text("IPK: 4.00"),
              Text("SKS: 144"),
              Text ("Mahasiswa Aktif"),
              
              ],),
              
              padding: EdgeInsets.all(20)))))


    );
  }
}