import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katalog Buku Perpustakaan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const CatalogPage(),
    );
  }
}


/// Fungsi kategoriRating 
String kategoriRating(double rating) {
  if (rating >= 4.5) return 'Sangat Baik';
  if (rating >= 3.5) return 'Baik';
  return 'Cukup';
}

/// Fungsi tambahan untuk mengambil genre unik menggunakan Set
Set<String> getUniqueGenres(List<Map<String, dynamic>> books) {
  Set<String> genres = {}; // Inisialisasi Set kosong
  for (var book in books) {
    String? genre = book['genre'] as String?;
    if (genre != null && genre.isNotEmpty) {
      genres.add(genre); // Set otomatis mencegah duplikat
    }
  }
  return genres;
}

// ============================================================
// HALAMAN UTAMA: KATALOG BUKU
// ============================================================

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  // --- DATA BUKU ---
  final List<Map<String, dynamic>> _allBooks = [
    {'judul': 'Laskar Pelangi', 'pengarang': 'Andrea Hirata', 'tahunTerbit': 2005, 'rating': 4.8, 'tersedia': true, 'genre': 'Novel'},
    {'judul': 'Atomic Habits', 'pengarang': 'James Clear', 'tahunTerbit': 2018, 'rating': 4.9, 'tersedia': false, 'genre': 'Self-Help'},
    {'judul': 'Filosofi Kopi', 'pengarang': 'Dee Lestari', 'tahunTerbit': 2006, 'rating': 4.2, 'tersedia': true, 'genre': 'Novel'},
    {'judul': 'Clean Code', 'pengarang': 'Robert C. Martin', 'tahunTerbit': 2008, 'rating': 4.7, 'tersedia': true, 'genre': 'Teknologi'},
    {'judul': 'Bumi Manusia', 'pengarang': 'Pramoedya A. Toer', 'tahunTerbit': 1980, 'rating': 4.6, 'tersedia': false, 'genre': 'Sejarah'},
    {'judul': 'The Psychology of Money', 'pengarang': 'Morgan Housel', 'tahunTerbit': 2020, 'rating': 4.5, 'tersedia': true, 'genre': 'Keuangan'},
  ];

  List<Map<String, dynamic>> _filteredBooks = [];
  // ignore: unused_field
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredBooks = List.from(_allBooks);
  }

  void _filterBooks(String query) {
    setState(() {
      _searchQuery = query;
      _filteredBooks = _allBooks.where((book) {
        return book['judul'].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- SET GENRE UNIK ( ---
    final uniqueGenres = getUniqueGenres(_allBooks);

    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Buku Perpustakaan')),
      body: Column(
        children: [
          // TextField Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari judul buku...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterBooks,
            ),
          ),

          // Wrap of Chip untuk Genre Unik
          if (uniqueGenres.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: uniqueGenres.map((genre) => 
                  Chip(label: Text(genre), backgroundColor: Colors.blue.shade50)
                ).toList(),
              ),
            ),
          const SizedBox(height: 8),

          // ListView Builder (Kontrol Alur & Koleksi)
          Expanded(
            child: ListView.builder(
              itemCount: _filteredBooks.length,
              itemBuilder: (context, index) {
                final book = _filteredBooks[index];
                final bool tersedia = book['tersedia'] as bool;
                final double rating = book['rating'] as double;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: tersedia ? Colors.green : Colors.red,
                      child: Icon(tersedia ? Icons.check : Icons.close, color: Colors.white),
                    ),
                    title: Text(book['judul'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${book['pengarang']} • ${book['tahunTerbit']}'),
                        const SizedBox(height: 4),
                        Text('Rating: $rating (${kategoriRating(rating)})'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: tersedia ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tersedia ? 'Tersedia' : 'Dipinjam',
                        style: TextStyle(
                          color: tersedia ? Colors.green.shade800 : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailPage(book: book),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HALAMAN DETAIL BUKU
// ============================================================

class BookDetailPage extends StatefulWidget {
  final Map<String, dynamic> book;
  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  // --- NULL SAFETY: Field nullable karena belum diisi user ---
  String? catatanPeminjam;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book['judul'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi Buku
            Text('Pengarang: ${widget.book['pengarang']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Tahun Terbit: ${widget.book['tahunTerbit']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Rating: ${widget.book['rating']} (${kategoriRating(widget.book['rating'])})', 
                 style: const TextStyle(fontSize: 16)),
            const Divider(height: 32),

            // Input Catatan Peminjam (Nullable)
            const Text('Catatan Peminjam:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan catatan peminjaman...',
                alignLabelWithHint: true,
              ),
              onChanged: (value) => setState(() => catatanPeminjam = value.isEmpty ? null : value),
            ),
            const SizedBox(height: 24),

            // --- NULL COALESCING OPERATOR ?? (Null Safety) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Preview: ${catatanPeminjam ?? '(Tidak ada catatan)'}',
                style: TextStyle(
                  color: catatanPeminjam == null ? Colors.grey.shade600 : Colors.black87,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}