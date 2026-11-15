import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const KycApp());
}

class KycApp extends StatelessWidget {
  const KycApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KYC Bank',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F6FB),
      ),
      home: const KycPage(),
    );
  }
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);
}

class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  final PageController pageController = PageController();

  final GlobalKey<FormState> formKeyStep1 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyStep2 = GlobalKey<FormState>();

  final TextEditingController nikController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController jumlahPinjamanController =
      TextEditingController();

  final FocusNode nikFocus = FocusNode();
  final FocusNode namaFocus = FocusNode();
  final FocusNode tanggalFocus = FocusNode();
  final FocusNode pinjamanFocus = FocusNode();

  int currentPage = 0;
  bool isLoading = false;
  bool simulasiError = false;

  @override
  void initState() {
    super.initState();

    nikFocus.addListener(() {
      if (nikFocus.hasFocus) {
        HapticFeedback.lightImpact();
      }
    });

    namaFocus.addListener(() {
      if (namaFocus.hasFocus) {
        HapticFeedback.lightImpact();
      }
    });

    tanggalFocus.addListener(() {
      if (tanggalFocus.hasFocus) {
        HapticFeedback.lightImpact();
      }
    });

    pinjamanFocus.addListener(() {
      if (pinjamanFocus.hasFocus) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();

    nikController.dispose();
    namaController.dispose();
    tanggalController.dispose();
    jumlahPinjamanController.dispose();

    nikFocus.dispose();
    namaFocus.dispose();
    tanggalFocus.dispose();
    pinjamanFocus.dispose();

    super.dispose();
  }

  // Menghitung usia berdasarkan tanggal lahir.
  int hitungUsia(DateTime tanggalLahir) {
    final sekarang = DateTime.now();

    int usia = sekarang.year - tanggalLahir.year;

    if (sekarang.month < tanggalLahir.month ||
        (sekarang.month == tanggalLahir.month &&
            sekarang.day < tanggalLahir.day)) {
      usia--;
    }

    return usia;
  }

  // Validasi NIK.
  String? validasiNIK(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIK wajib diisi';
    }

    if (!RegExp(r'^[0-9]{16}$').hasMatch(value)) {
      return 'NIK harus terdiri dari 16 digit angka';
    }

    return null;
  }

  // Validasi nama lengkap (tidak boleh mengandung angka).
  String? validasiNama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }

    if (RegExp(r'[0-9]').hasMatch(value)) {
      return 'Nama tidak boleh mengandung angka';
    }

    return null;
  }

  // Validasi tanggal lahir.
  String? validasiTanggal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tanggal lahir wajib diisi';
    }

    final tanggalLahir = DateTime.tryParse(value);

    if (tanggalLahir == null) {
      return 'Tanggal lahir tidak valid';
    }

    if (tanggalLahir.isAfter(DateTime.now())) {
      return 'Tanggal lahir tidak boleh di masa depan';
    }

    if (hitungUsia(tanggalLahir) < 17) {
      return 'Usia minimal 17 tahun';
    }

    return null;
  }

  // Memilih tanggal lahir.
  Future<void> pilihTanggal() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (tanggal != null) {
      setState(() {
        tanggalController.text =
            '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
      });

      HapticFeedback.lightImpact();
    }
  }

  // Berpindah ke halaman berikutnya.
  void lanjutkan() {
    if (currentPage == 0) {
      if (formKeyStep1.currentState!.validate()) {
        HapticFeedback.lightImpact();

        pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );

        setState(() {
          currentPage = 1;
        });
      }
    } else {
      if (formKeyStep2.currentState!.validate()) {
        prosesVerifikasi();
      }
    }
  }

  // Kembali ke halaman sebelumnya.
  void kembali() {
    HapticFeedback.lightImpact();

    pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    setState(() {
      currentPage = 0;
    });
  }

  // Simulasi verifikasi jaringan selama 3 detik.
  Future<void> prosesVerifikasi() async {
    setState(() {
      isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 3));

      if (simulasiError) {
        throw NetworkException(
          'Terjadi kesalahan jaringan. Silakan coba kembali.',
        );
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            title: const Text('Verifikasi Berhasil'),
            content: const Text(
              'Data identitas dan pengajuan pinjaman '
              'berhasil diverifikasi.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } on NetworkException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 50,
            ),
            title: const Text('Konfirmasi Kesalahan'),
            content: Text(e.message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Tutup'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  prosesVerifikasi();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF123B70),
        foregroundColor: Colors.white,
        title: const Text(
          'KYC Bank',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const Icon(Icons.account_balance),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Verifikasi Identitas Nasabah',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF123B70),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              const Text(
                'Lengkapi data untuk pengajuan pinjaman.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  stepIndicator(0, 'Identitas'),
                  Expanded(
                    child: Container(
                      height: 3,
                      color: currentPage == 1
                          ? Colors.blue
                          : Colors.grey.shade300,
                    ),
                  ),
                  stepIndicator(1, 'Pinjaman'),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 430,
                child: PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Form(
                      key: formKeyStep1,
                      child: identitasForm(),
                    ),
                    Form(
                      key: formKeyStep2,
                      child: pinjamanForm(),
                    ),
                  ],
                ),
              ),

              if (isLoading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                const Text('Memverifikasi data...'),
              ],

              const SizedBox(height: 20),

              Row(
                children: [
                  if (currentPage == 1)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : kembali,
                        child: const Text('Kembali'),
                      ),
                    ),

                  if (currentPage == 1)
                    const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : lanjutkan,
                      icon: Icon(
                        currentPage == 0
                            ? Icons.arrow_forward
                            : Icons.verified_user,
                      ),
                      label: Text(
                        currentPage == 0
                            ? 'Lanjutkan'
                            : 'Submit Verifikasi',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (currentPage == 1)
                CheckboxListTile(
                  value: simulasiError,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() {
                            simulasiError = value ?? false;
                          });
                        },
                  title: const Text(
                    'Simulasikan gangguan jaringan',
                    style: TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget stepIndicator(int index, String label) {
    final aktif = currentPage >= index;

    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor:
              aktif ? const Color(0xFF1565C0) : Colors.grey.shade300,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: aktif ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: aktif ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget identitasForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Langkah 1: Data Identitas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        TextFormField(
          controller: nikController,
          focusNode: nikFocus,
          keyboardType: TextInputType.number,
          maxLength: 16,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: validasiNIK,
          decoration: const InputDecoration(
            labelText: 'Nomor Induk Kependudukan (NIK)',
            hintText: 'Masukkan 16 digit NIK',
            prefixIcon: Icon(Icons.badge),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: namaController,
          focusNode: namaFocus,
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            // Hanya huruf, spasi, titik, apostrof, dan tanda hubung.
            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s.'\-]")),
          ],
          validator: validasiNama,
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: tanggalController,
          focusNode: tanggalFocus,
          readOnly: true,
          onTap: pilihTanggal,
          validator: validasiTanggal,
          decoration: const InputDecoration(
            labelText: 'Tanggal Lahir',
            hintText: 'Pilih tanggal lahir',
            prefixIcon: Icon(Icons.calendar_month),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Pastikan data identitas sesuai dengan KTP.',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget pinjamanForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Langkah 2: Pengajuan Pinjaman',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        TextFormField(
          controller: jumlahPinjamanController,
          focusNode: pinjamanFocus,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jumlah pinjaman wajib diisi';
            }

            final jumlah = int.tryParse(value);

            if (jumlah == null || jumlah < 1000000) {
              return 'Minimal pinjaman Rp1.000.000';
            }

            return null;
          },
          decoration: const InputDecoration(
            labelText: 'Jumlah Pinjaman',
            hintText: 'Contoh: 5000000',
            prefixIcon: Icon(Icons.account_balance_wallet),
            prefixText: 'Rp ',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE1EEFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 30,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Periksa kembali data sebelum '
                  'melakukan verifikasi.',
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Tekan Submit Verifikasi untuk '
          'memulai simulasi pemeriksaan jaringan.',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}