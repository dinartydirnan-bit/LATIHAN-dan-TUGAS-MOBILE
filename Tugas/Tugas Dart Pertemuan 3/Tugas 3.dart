import 'dart:io';

class StokHabisException implements Exception {
  @override
  String toString() => '❌ Stok produk habis!';
}

class ProdukTidakAda implements Exception {
  @override
  String toString() => '❌ Produk tidak ditemukan!';
}

abstract class Produk {
  String id;
  String nama;
  double harga;
  int stok;

  Produk(this.id, this.nama, this.harga, this.stok);
  String deskripsi();
}

mixin BisaDiskon on Produk {
  bool validasiDiskon(double persen) {
    return persen >= 0 && persen <= 100;
  }

  double hitungHargaDiskon(double persen) {
    if (!validasiDiskon(persen)) {
      throw Exception('Diskon harus antara 0-100%');
    }
    return harga - (harga * persen / 100);
  }
}

class ProdukDigital extends Produk with BisaDiskon {
  double ukuranMB;
  String formatFile;

  ProdukDigital(id, nama, harga, stok, this.ukuranMB, this.formatFile)
      : super(id, nama, harga, stok);

  @override
  String deskripsi() {
    return '[DIGITAL] $nama | ID: $id | Format: $formatFile (${ukuranMB}MB) | Rp${harga.toInt()} | Stok: $stok';
  }
}

class ProdukFisik extends Produk with BisaDiskon {
  double beratGram;
  String dimensi;

  ProdukFisik(id, nama, harga, stok, this.beratGram, this.dimensi)
      : super(id, nama, harga, stok);

  @override
  String deskripsi() {
    return '[FISIK] $nama | ID: $id | Berat: ${beratGram}g | Dimensi: $dimensi | Rp${harga.toInt()} | Stok: $stok';
  }
}

class Keranjang {
  List<Produk> items = [];

  void tambah(Produk p) {
    if (p.stok <= 0) throw StokHabisException();
    p.stok--;
    items.add(p);
    print('✅ "$p.nama" berhasil ditambahkan ke keranjang');
  }

  void hapus(String nama) {
    items.removeWhere((p) => p.nama == nama);
    print('️ "$nama" dihapus dari keranjang');
  }

  double totalHarga() => items.fold(0, (t, p) => t + p.harga);
}

class TokoService {
  List<Produk> katalog = [];

  Future<Produk> cariProduk(String nama) async {
    await Future.delayed(Duration(seconds: 1)); // Simulasi loading
    try {
      return katalog.firstWhere((p) => p.nama.toLowerCase().contains(nama.toLowerCase()));
    } catch (_) {
      throw ProdukTidakAda();
    }
  }

  Future<String> prosesCheckout(Keranjang k) async {
    await Future.delayed(Duration(seconds: 1)); // Simulasi pembayaran
    if (k.items.isEmpty) throw Exception('Keranjang belanja kosong!');
    return '✅ Checkout berhasil! Total bayar: Rp${k.totalHarga().toInt()}';
  }
}

String input(String text) {
  stdout.write(text);
  return stdin.readLineSync() ?? '';
}

void main() async {
  var toko = TokoService();
  var keranjang = Keranjang();

  print('══════════════════════════════════╗');
  print('║   SISTEM MANAJEMEN TOKO ONLINE  ║');
  print('╚═════════════════════════════════╝\n');

  while (true) {
    print('--- MENU UTAMA ---');
    print('1. Tambah Produk Digital');
    print('2. Tambah Produk Fisik');
    print('3. Lihat Katalog');
    print('4. Cari Produk (Async)');
    print('5. Tambah ke Keranjang');
    print('6. Lihat Keranjang');
    print('7. Hapus dari Keranjang');
    print('8. Checkout (Async)');
    print('9. Hitung Diskon');
    print('0. Keluar');

    var pilih = input('Pilih menu (0-9): ');

    try {
      if (pilih == '1') {
        print('\n[INPUT PRODUK DIGITAL]');
        var id = input('ID Produk: ');
        var nama = input('Nama: ');
        var harga = double.parse(input('Harga: '));
        var stok = int.parse(input('Stok: '));
        var ukuran = double.parse(input('Ukuran MB: '));
        var format = input('Format File: ');
        
        toko.katalog.add(ProdukDigital(id, nama, harga, stok, ukuran, format));
        print('✅ Produk digital berhasil disimpan!');
      } 
      else if (pilih == '2') {
        print('\n[INPUT PRODUK FISIK]');
        var id = input('ID Produk: ');
        var nama = input('Nama: ');
        var harga = double.parse(input('Harga: '));
        var stok = int.parse(input('Stok: '));
        var berat = double.parse(input('Berat (gram): '));
        var dimensi = input('Dimensi (PxLxT): ');
        
        toko.katalog.add(ProdukFisik(id, nama, harga, stok, berat, dimensi));
        print('✅ Produk fisik berhasil disimpan!');
      } 
      else if (pilih == '3') {
        print('\n KATALOG PRODUK:');
        print('=' * 60);
        if (toko.katalog.isEmpty) {
          print('Katalog masih kosong.');
        } else {
          for (var p in toko.katalog) print(p.deskripsi());
        }
      } 
      else if (pilih == '4') {
        var keyword = input('Masukkan kata kunci pencarian: ');
        print('⏳ Sedang mencari...');
        var hasil = await toko.cariProduk(keyword);
        print('✅ Ditemukan: ${hasil.deskripsi()}');
      } 
      else if (pilih == '5') {
        var nama = input('Cari nama produk untuk dibeli: ');
        var produk = await toko.cariProduk(nama);
        keranjang.tambah(produk);
      } 
      else if (pilih == '6') {
        print('\n🛒 ISI KERANJANG:');
        if (keranjang.items.isEmpty) {
          print('Keranjang masih kosong.');
        } else {
          for (var item in keranjang.items) {
            print('- ${item.nama}: Rp${item.harga.toInt()}');
          }
          print('Total: Rp${keranjang.totalHarga().toInt()}');
        }
      } 
      else if (pilih == '7') {
        var nama = input('Nama produk yang ingin dihapus: ');
        keranjang.hapus(nama);
      } 
      else if (pilih == '8') {
        print('⏳ Memproses checkout...');
        var hasil = await toko.prosesCheckout(keranjang);
        print(hasil);
        keranjang.items.clear();
      } 
      else if (pilih == '9') {
        var nama = input('Nama produk untuk diskon: ');
        var produk = await toko.cariProduk(nama);
        var persen = double.parse(input('Masukkan persen diskon (%): '));
        
        if (produk is BisaDiskon) {
          print(' Harga Asli: Rp${produk.harga.toInt()}');
          print('💸 Harga Diskon ${persen}%: Rp${produk.hitungHargaDiskon(persen).toInt()}');
        }
      } 
      else if (pilih == '0') {
        print('\n Terima kasih telah menggunakan sistem kami!');
        break;
      } 
      else {
        print('❌ Pilihan tidak valid, silakan coba lagi.');
      }
    } on StokHabisException catch (e) {
      print(e);
    } on ProdukTidakAda catch (e) {
      print(e);
    } on FormatException {
      print('❌ Input harus berupa angka yang valid!');
    } catch (e) {
      print('❌ Terjadi kesalahan: $e');
    }
  }
}