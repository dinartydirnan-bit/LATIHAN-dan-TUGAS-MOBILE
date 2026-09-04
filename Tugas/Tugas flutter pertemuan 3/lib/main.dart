import 'package:flutter/material.dart';
import 'dart:math';

// Abstract Class Tiket
abstract class Tiket {
  final String nama;
  final double harga;

  Tiket({required this.nama, required this.harga});

  String deskripsi(); // Abstract method
}

mixin BisaDiskon on Tiket {
  double hitungHargaDiskon(double persen) {
    return harga - (harga * persen / 100);
  }
}

class TiketEkonomi extends Tiket {
  final String fasilitas;

  TiketEkonomi({
    required String nama,
    required double harga,
    this.fasilitas = 'Tempat duduk standar',
  }) : super(nama: nama, harga: harga);

  @override
  String deskripsi() {
    return 'Tiket Ekonomi - $nama\nHarga: Rp ${harga.toStringAsFixed(0)}\nFasilitas: $fasilitas';
  }
}

class TiketVIP extends Tiket with BisaDiskon {
  final List<String> fasilitasVIP;

  TiketVIP({
    required String nama,
    required double harga,
    this.fasilitasVIP = const ['Lounge', 'Makanan', 'Tempat duduk premium'],
  }) : super(nama: nama, harga: harga);

  @override
  String deskripsi() {
    return 'Tiket VIP - $nama\nHarga Normal: Rp ${harga.toStringAsFixed(0)}\nFasilitas: ${fasilitasVIP.join(", ")}';
  }
}

class TiketPremium extends Tiket with BisaDiskon {
  final bool termasukAkomodasi;

  TiketPremium({
    required String nama,
    required double harga,
    this.termasukAkomodasi = true,
  }) : super(nama: nama, harga: harga);

  @override
  String deskripsi() {
    return 'Tiket Premium - $nama\nHarga: Rp ${harga.toStringAsFixed(0)}\n${termasukAkomodasi ? "Termasuk akomodasi" : "Tanpa akomodasi"}';
  }
}

class TiketHabisException implements Exception {
  final String message;
  TiketHabisException(this.message);

  @override
  String toString() => 'TiketHabisException: $message';
}

class PembayaranGagalException implements Exception {
  final String message;
  PembayaranGagalException(this.message);

  @override
  String toString() => 'PembayaranGagalException: $message';
}

class TiketService {
  Future<List<Tiket>> ambilDaftarTiket() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (Random().nextDouble() < 0.1) {
      throw Exception('Gagal mengambil data tiket. Silakan coba lagi.');
    }

    return [
      TiketEkonomi(nama: 'Jakarta-Bandung', harga: 150000),
      TiketVIP(
        nama: 'Jakarta-Surabaya', 
        harga: 750000,
        fasilitasVIP: ['Lounge Eksekutif', 'Makanan Premium', 'Prioritas Boarding']
      ),
      TiketPremium(nama: 'Jakarta-Bali', harga: 1200000),
      TiketEkonomi(nama: 'Bandung-Yogyakarta', harga: 200000),
      TiketVIP(
        nama: 'Surabaya-Makassar', 
        harga: 900000,
        fasilitasVIP: ['Lounge', 'Catering', 'Tempat Tidur']
      ),
    ];
  }

  Future<String> pesanTiket(Tiket tiket) async {
    await Future.delayed(const Duration(seconds: 1));

    double random = Random().nextDouble();
    
    if (random < 0.15) {
      throw TiketHabisException('Maaf, tiket ${tiket.nama} sudah habis terjual.');
    } else if (random < 0.30) {
      throw PembayaranGagalException('Pembayaran gagal. Silakan gunakan metode pembayaran lain.');
    }

    return 'Pemesanan berhasil!\n${tiket.deskripsi()}\n\nSilakan cek email Anda untuk e-ticket.';
  }
}

class CountdownService {
  Stream<int> startCountdown(int seconds) async* {
    for (int i = seconds; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      yield i;
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Tiket OOP & Async',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HalamanDaftarTiket(),
    );
  }
}

class HalamanDaftarTiket extends StatelessWidget {
  final TiketService _service = TiketService();

  HalamanDaftarTiket({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tiket'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HalamanDaftarTiket()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade100,
            child: Column(
              children: [
                const Icon(Icons.timer, size: 32, color: Colors.orange),
                const SizedBox(height: 8),
                const Text(
                  'Waktu tersisa untuk memesan tiket promo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                StreamBuilder<int>(
                  stream: CountdownService().startCountdown(30),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      int seconds = snapshot.data!;
                      int minutes = seconds ~/ 60;
                      int secs = seconds % 60;
                      return Text(
                        '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Text('Error', style: TextStyle(color: Colors.red));
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ],
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<Tiket>>(
              future: _service.ambilDaftarTiket(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memuat daftar tiket...'),
                      ],
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HalamanDaftarTiket()),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (snapshot.hasData) {
                  List<Tiket> tickets = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      Tiket tiket = tickets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            tiket.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(tiket.deskripsi()),
                              
                              if (tiket is BisaDiskon) ...[
                                const SizedBox(height: 8),
                                Text(
                                  // ignore: unnecessary_cast
                                  'Harga diskon 20%: Rp ${(tiket as BisaDiskon).hitungHargaDiskon(20).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HalamanPemesanan(tiket: tiket),
                                ),
                              );
                            },
                            child: const Text('Pesan'),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                }
                
                return const Center(child: Text('Tidak ada data'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HalamanPemesanan extends StatefulWidget {
  final Tiket tiket;

  const HalamanPemesanan({super.key, required this.tiket});

  @override
  State<HalamanPemesanan> createState() => _HalamanPemesananState();
}

class _HalamanPemesananState extends State<HalamanPemesanan> {
  final TiketService _service = TiketService();
  bool _isLoading = false;
  String? _pesanSukses;
  String? _pesanError;

  Future<void> _prosesPemesanan() async {
    setState(() {
      _isLoading = true;
      _pesanSukses = null;
      _pesanError = null;
    });

    try {
      String hasil = await _service.pesanTiket(widget.tiket);
      
      setState(() {
        _pesanSukses = hasil;
      });
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
            title: const Text('Berhasil!'),
            content: Text(hasil),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                  Navigator.of(context).pop(); 
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } on TiketHabisException catch (e) {
      setState(() {
        _pesanError = e.toString();
      });
      if (mounted) {
        _showErrorDialog('Tiket Habis', e.message);
      }
    } on PembayaranGagalException catch (e) {
      setState(() {
        _pesanError = e.toString();
      });
      if (mounted) {
        _showErrorDialog('Pembayaran Gagal', e.message);
      }
    } catch (e) {
      setState(() {
        _pesanError = 'Terjadi kesalahan: $e';
      });
      if (mounted) {
        _showErrorDialog('Error', e.toString());
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proses pemesanan selesai'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 64),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Coba Lagi'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemesanan Tiket'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Pemesanan',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(widget.tiket.deskripsi()),
                    // PERBAIKAN 3: Casting eksplisit ke BisaDiskon, bukan dynamic
                    if (widget.tiket is BisaDiskon) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '💡 Promo Khusus:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Diskon 20%: Rp ${(widget.tiket as BisaDiskon).hitungHargaDiskon(20).toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (_pesanError != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_pesanError!)),
                  ],
                ),
              ),
            
            if (_pesanSukses != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_pesanSukses!)),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _prosesPemesanan,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.shopping_cart),
                label: Text(_isLoading ? 'Memproses...' : 'Konfirmasi Pemesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📝 Informasi:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Sistem akan mensimulasikan proses pemesanan'),
                  Text('• Ada kemungkinan tiket habis atau pembayaran gagal'),
                  Text('• Error handling menggunakan try/catch/finally'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}