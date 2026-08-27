void main() {
  // --- DATA MAHASISWA FINAL ---
  List<Map<String, dynamic>> dataMahasiswa = [
    {'nama': 'Budi Santoso', 'nilai': [85, 90, 78, 92, 88], 'absensi': 3}, 
    
    {'nama': 'Siti Rahayu', 'nilai': [55, 60, 58, 52, 45], 'absensi': 1},  
    
    {'nama': 'Andi Pratama', 'nilai': [70, 75, 80, 65, 72], 'absensi': 5}, 
   
    {'nama': 'Dewi Lestari', 'nilai': [80, 85, 82, 88, 84], 'absensi': 0}, 
    
    {'nama': 'Eko Kurniawan', 'nilai': [62, 72, 68, 78, 66], 'absensi': 2}, 
  ];

  print("=== LAPORAN NILAI MAHASISWA ===\n");

  List<double> daftarRataRata = [];
  List<int> semuaNilaiIndividu = [];

  for (var mhs in dataMahasiswa) {
    String nama = mhs['nama'] as String;
    List<int> nilai = (mhs['nilai'] as List).cast<int>();
    int absensi = mhs['absensi'] as int;

    double rataRata = hitungRataRata(nilai);
    String grade = tentukanGrade(rataRata);
    bool statusLulus = cekKelulusan(rataRata: rataRata, absensi: absensi);

    daftarRataRata.add(rataRata);
    semuaNilaiIndividu.addAll(nilai);

    print("Nama      : $nama");
    print("Nilai     : $nilai");
    print("Rata-rata : ${rataRata.toStringAsFixed(1)}");
    print("Grade     : $grade");
    print("Status    : ${statusLulus ? 'LULUS' : 'TIDAK LULUS'}");
    print(""); 
  }

  print("=== STATISTIK KELAS ===");
  
  int nilaiTertinggi = semuaNilaiIndividu.reduce((a, b) => a > b ? a : b);
  int nilaiTerendah = semuaNilaiIndividu.reduce((a, b) => a < b ? a : b);
  double rataRataKelas = hitungRataRataDouble(daftarRataRata);

  print("Nilai Tertinggi : $nilaiTertinggi");
  print("Nilai Terendah  : $nilaiTerendah");
  print("Rata-rata Kelas : ${rataRataKelas.toStringAsFixed(1)}");
}

// ============================================================
// FUNGSI-FUNGSI
// ============================================================

double hitungRataRata(List<int> nilai) {
  if (nilai.isEmpty) return 0.0;
  int total = nilai.reduce((a, b) => a + b);
  return total / nilai.length;
}

double hitungRataRataDouble(List<double> list) {
  if (list.isEmpty) return 0.0;
  double total = list.fold(0.0, (sum, val) => sum + val);
  return total / list.length;
}

String tentukanGrade(double rataRata) {
  if (rataRata >= 85) return 'A';
  if (rataRata >= 75) return 'B';
  if (rataRata >= 65) return 'C';
  if (rataRata >= 50) return 'D'; 
  return 'E';
}

bool cekKelulusan({required double rataRata, required int absensi}) {
  return (rataRata >= 60) && (absensi <= 3);
}