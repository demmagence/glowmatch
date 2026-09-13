// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'GlowMatch';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get delete => 'Hapus';

  @override
  String get close => 'Tutup';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get loading => 'Memuat...';

  @override
  String get error => 'Kesalahan';

  @override
  String get success => 'Berhasil';

  @override
  String get all => 'Semua';

  @override
  String get add => 'Tambah';

  @override
  String get edit => 'Ubah';

  @override
  String get navHome => 'Beranda';

  @override
  String get navBudget => 'Anggaran';

  @override
  String get navScan => 'Pindai';

  @override
  String get navJournal => 'Jurnal';

  @override
  String get navShelf => 'Koleksi';

  @override
  String get onboardingTitle1 => 'Pantau Kilau Kulitmu';

  @override
  String get onboardingDesc1 =>
      'Catat rutinitas skincare pagi & malam serta simpan jurnal perkembangan kulit visual Anda.';

  @override
  String get onboardingTitle2 => 'Pindai Komposisi';

  @override
  String get onboardingDesc2 =>
      'Gunakan AI untuk memindai komposisi produk melalui OCR dan periksa keamanan serta kecocokannya.';

  @override
  String get onboardingTitle3 => 'Anggaran Pintar';

  @override
  String get onboardingDesc3 =>
      'Pantau pengeluaran skincare Anda dan analisis efisiensi biaya per pemakaian.';

  @override
  String get skip => 'Lewati';

  @override
  String get next => 'Lanjut';

  @override
  String get getStarted => 'Mulai Sekarang';

  @override
  String get signInTitle => 'Masuk';

  @override
  String get signInSubtitle =>
      'Selamat datang kembali! Masuk untuk menyinkronkan rutinitas Anda.';

  @override
  String get signUpTitle => 'Daftar';

  @override
  String get signUpSubtitle =>
      'Buat akun untuk mencadangkan koleksi & perkembangan Anda.';

  @override
  String get emailLabel => 'Alamat Email';

  @override
  String get emailHint => 'kamu@example.com';

  @override
  String get passwordLabel => 'Kata Sandi';

  @override
  String get passwordHint => '••••••••';

  @override
  String get confirmPasswordLabel => 'Konfirmasi Kata Sandi';

  @override
  String get signInButton => 'Masuk';

  @override
  String get signUpButton => 'Daftar';

  @override
  String get continueAsGuest => 'Lanjutkan sebagai Tamu';

  @override
  String get dontHaveAccount => 'Belum punya akun? Daftar';

  @override
  String get alreadyHaveAccount => 'Sudah punya akun? Masuk';

  @override
  String get orDivider => 'ATAU';

  @override
  String get emailValidationError => 'Silakan masukkan alamat email yang valid';

  @override
  String get passwordLengthError => 'Kata sandi minimal 6 karakter';

  @override
  String get passwordsDoNotMatch => 'Kata sandi tidak cocok';

  @override
  String get forgotPassword => 'Lupa Kata Sandi?';

  @override
  String get morningRoutine => 'Rutinitas Pagi';

  @override
  String get eveningRoutine => 'Rutinitas Malam';

  @override
  String get steps => 'Langkah';

  @override
  String stepsCompleted(int completed, int total) {
    return '$completed/$total Selesai';
  }

  @override
  String get noRoutineSteps =>
      'Belum ada langkah rutinitas. Ketuk di bawah untuk menambahkan langkah pertama Anda!';

  @override
  String get deleteStepTitle => 'Hapus Langkah?';

  @override
  String deleteStepMessage(String stepName, String routineName) {
    return 'Hapus \"$stepName\" dari rutinitas $routineName Anda?';
  }

  @override
  String get deleteStepWarning =>
      'Apakah Anda yakin ingin menghapus langkah ini? Langkah yang tersisa akan dinomori ulang.';

  @override
  String get completePreviousStepsOrder =>
      'Harap selesaikan langkah sebelumnya secara berurutan.';

  @override
  String usedOneApply(String productName) {
    return 'Menggunakan 1 pemakaian dari $productName!';
  }

  @override
  String stepNumber(int number) {
    return 'Langkah $number';
  }

  @override
  String get customStep => 'Langkah Khusus';

  @override
  String get clickToAdd => 'Ketuk untuk menambah';

  @override
  String get completedForToday => 'Selesai untuk Hari Ini';

  @override
  String get completeRoutine => 'Selesaikan Rutinitas';

  @override
  String get routineCompletedToast =>
      'Rutinitas Selesai! Skor konsistensi diperbarui.';

  @override
  String get milestone7DaysToast =>
      '🎉 Pencapaian 7 Hari! Dedikasi luar biasa!';

  @override
  String get milestone14DaysToast =>
      '🎉 Pencapaian 14 Hari! Anda tak terhentikan!';

  @override
  String get milestone30DaysToast =>
      '🎉 Pencapaian 30 Hari! Anda adalah master skincare!';

  @override
  String dayStreakBadge(int count) {
    return 'Beruntun $count Hari';
  }

  @override
  String get startRoutineMotivation =>
      'Mulai rutinitas Anda hari ini untuk memulai rangkaian kulit sehat! 🔥';

  @override
  String get milestone30Motivation =>
      '👑 Pencapaian 30+ Hari! Status Master Skincare terbuka!';

  @override
  String get milestone14Motivation =>
      '🌟 Pencapaian 14 Hari! Penghalang kulit Anda berterima kasih!';

  @override
  String get milestone7Motivation =>
      '🏆 Pencapaian 7 Hari! Anda membangun kebiasaan skincare yang solid!';

  @override
  String get keepItUpMotivation =>
      '✨ Pertahankan! Konsistensi adalah kunci kulit sehat berseri.';

  @override
  String get addRoutineStep => 'Tambah Langkah Rutinitas';

  @override
  String get editRoutineStep => 'Ubah Langkah Rutinitas';

  @override
  String get stepNameLabel => 'Nama Langkah (cth., Toner)';

  @override
  String get stepNameSimpleLabel => 'Nama Langkah';

  @override
  String get instructionsLabel => 'Instruksi (cth., Aplikasikan dengan kapas)';

  @override
  String get instructionsSimpleLabel => 'Instruksi';

  @override
  String get linkShelfProductOptional => 'Tautkan Produk Koleksi (Opsional)';

  @override
  String get linkShelfProduct => 'Tautkan Produk Koleksi';

  @override
  String get selectProductHint => 'Pilih produk';

  @override
  String get noneOption => 'Tidak ada';

  @override
  String get streakHistoryAndStats => 'Riwayat & Statistik Beruntun';

  @override
  String get currentStreak => 'Beruntun Saat Ini';

  @override
  String get longestStreak => 'Beruntun Terpanjang';

  @override
  String get totalCompleted => 'Total Selesai';

  @override
  String streakDaysCount(int count) {
    return '$count Hari';
  }

  @override
  String get streakHistory => 'Riwayat Beruntun';

  @override
  String get noStreakHistoryYet =>
      'Belum ada riwayat beruntun. Selesaikan rutinitas pertama Anda!';

  @override
  String get completed => 'Selesai';

  @override
  String get missed => 'Terlewat';

  @override
  String get skincareMasterMilestone => '👑 Pencapaian Master Skincare!';

  @override
  String get unstoppableBarrierMilestone =>
      '🌟 Pencapaian pertahanan kulit tak terhentikan!';

  @override
  String get solidHabitMilestone => '🏆 Pencapaian kebiasaan solid!';

  @override
  String get visualCalendar => 'Kalender Visual';

  @override
  String get totalSpendInPeriod => 'TOTAL PENGELUARAN PERIODE';

  @override
  String get period30Days => '30 Hari';

  @override
  String get period90Days => '90 Hari';

  @override
  String get periodAllTime => 'Semua';

  @override
  String get calculatingBudget => 'Menghitung anggaran...';

  @override
  String get allocation => 'ALOKASI';

  @override
  String get noActiveProductsAllocation =>
      'Tidak ada produk aktif di koleksi Anda untuk menghitung alokasi.';

  @override
  String get categoriesCount => 'Kategori';

  @override
  String get costPerApplyCalculator => 'KALKULATOR BIAYA PER PEMAKAIAN';

  @override
  String get selectProductFromShelf => 'Pilih Produk dari Koleksi';

  @override
  String get customValuesNoProduct => 'Nilai khusus (tanpa produk)';

  @override
  String get productPrice => 'Harga Produk';

  @override
  String get estimatedUses => 'Estimasi Pemakaian';

  @override
  String get efficiencyMetric => 'METRIK EFISIENSI';

  @override
  String get perApplication => '/ pemakaian';

  @override
  String get spendingHistory => 'RIWAYAT PENGELUARAN (6 BULAN TERAKHIR)';

  @override
  String get setMonthlyBudgetLimit => 'Atur Batas Anggaran Bulanan';

  @override
  String budgetLimit(String currency) {
    return 'Batas Anggaran ($currency)';
  }

  @override
  String get myShelf => 'Koleksi Saya';

  @override
  String get shelfSubtitle => 'Inventaris skincare & pelacak pemakaian Anda.';

  @override
  String get searchProducts => 'Cari produk...';

  @override
  String get filter => 'FILTER';

  @override
  String get filterByCategory => 'Filter berdasarkan Kategori';

  @override
  String get categories => 'Kategori';

  @override
  String get tapToAddSkincare => 'tekan untuk tambah skincare baru';

  @override
  String get addSkincareProduct => 'Tambah Produk Skincare';

  @override
  String get editSkincareProduct => 'Ubah Produk Skincare';

  @override
  String get productImage => 'Foto Produk';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galeri';

  @override
  String get productName => 'Nama Produk';

  @override
  String get productNameHint => 'cth. Moisture Surge Intense';

  @override
  String get brand => 'Merek';

  @override
  String get brandHint => 'cth. Clinique';

  @override
  String get category => 'Kategori';

  @override
  String get selectCategoryHint => 'Pilih kategori';

  @override
  String priceWithCurrency(String currency) {
    return 'Harga ($currency)';
  }

  @override
  String get priceHint => 'cth. 150000';

  @override
  String get productSize => 'Ukuran Produk';

  @override
  String get productSizeHint => 'cth. 30ml, 50g';

  @override
  String get ingredients => 'Komposisi';

  @override
  String get ingredientsHint => 'cth. Niacinamide, Hyaluronic Acid, Ceramide';

  @override
  String get addProduct => 'Tambah Produk';

  @override
  String get saveChanges => 'Simpan Perubahan';

  @override
  String get deleteProductTitle => 'Hapus Produk?';

  @override
  String deleteProductConfirm(String name) {
    return 'Apakah Anda yakin ingin menghapus $name dari koleksi Anda?';
  }

  @override
  String deletedProductSnackbar(String name) {
    return 'Dihapus $name';
  }

  @override
  String get productDetailPrice => 'HARGA';

  @override
  String get productDetailUsesRemaining => 'SISA PEMAKAIAN';

  @override
  String get productDetailCostPerUse => 'BIAYA PER PEMAKAIAN';

  @override
  String get productDetailSize => 'UKURAN PRODUK';

  @override
  String get productDetailDateAdded => 'TANGGAL DITAMBAHKAN';

  @override
  String get productDetailIngredients => 'KOMPOSISI';

  @override
  String get noIngredientsListed => 'Tidak ada komposisi tercantum.';

  @override
  String get editProductUpper => 'UBAH PRODUK';

  @override
  String get deleteProductUpper => 'HAPUS PRODUK';

  @override
  String get manageCategoriesTitle => 'Kelola Kategori';

  @override
  String get createNewCategory => 'Buat Kategori Baru';

  @override
  String get categoryNameHint => 'Nama Kategori (cth. Essence)';

  @override
  String get categoryNameLabel => 'Nama Kategori';

  @override
  String get chooseCategoryColor => 'Pilih Warna Kategori';

  @override
  String get addCategoryUpper => 'TAMBAH KATEGORI';

  @override
  String get allCategories => 'Semua Kategori';

  @override
  String get defaultBadge => 'BAWAAN';

  @override
  String get renameCategory => 'Ganti Nama Kategori';

  @override
  String get chooseColor => 'Pilih Warna';

  @override
  String get categoryAlreadyExists => 'Nama kategori sudah ada!';

  @override
  String get deleteCategoryTitle => 'Hapus Kategori';

  @override
  String deleteCategoryWarningInUse(int count, String categoryName) {
    return 'Peringatan: Ada $count produk yang saat ini menggunakan \"$categoryName\". Menghapus kategori ini akan menetapkannya kembali ke kategori bawaan \"Serum\". Apakah Anda yakin ingin menghapus?';
  }

  @override
  String deleteCategoryWarningSimple(String categoryName) {
    return 'Apakah Anda yakin ingin menghapus kategori \"$categoryName\"?';
  }

  @override
  String categoryDeletedSnackbar(String categoryName) {
    return 'Kategori \"$categoryName\" dihapus.';
  }

  @override
  String get journal => 'Jurnal';

  @override
  String get journalSubtitle => 'Pantau perkembangan kulit sehatmu.';

  @override
  String get uploadingGlow => 'Mengunggah foto Anda...';

  @override
  String get compareModeTooltip => 'Mode Perbandingan';

  @override
  String get cancelCompareTooltip => 'Batal Bandingkan';

  @override
  String selectedComparisonCount(int count) {
    return 'Dipilih: $count/2 catatan';
  }

  @override
  String get compare => 'Bandingkan';

  @override
  String get compareMaxLimitError =>
      'Anda hanya dapat memilih hingga 2 catatan untuk perbandingan.';

  @override
  String get glowActivity => 'Aktivitas Kulit';

  @override
  String get less => 'Sedikit';

  @override
  String get more => 'Banyak';

  @override
  String get thisWeek => 'MINGGU INI';

  @override
  String get lastWeek => 'MINGGU LALU';

  @override
  String weeksAgo(int count) {
    return '$count MINGGU LALU';
  }

  @override
  String get addPhoto => 'Tambah Foto';

  @override
  String scoreLabel(int score) {
    return 'Skor: $score';
  }

  @override
  String get addProgressPhoto => 'TAMBAH FOTO PERKEMBANGAN';

  @override
  String get chooseCaptureGlow =>
      'Pilih cara untuk mengabadikan kondisi kulit Anda.';

  @override
  String get takePhoto => 'Ambil Foto';

  @override
  String get useCameraNow => 'Gunakan kamera sekarang';

  @override
  String get chooseFromGallery => 'Pilih dari Galeri';

  @override
  String get pickExistingPhoto => 'Pilih foto yang ada';

  @override
  String get addProgressNote => 'Tambah Catatan Perkembangan';

  @override
  String get skinFeelHint =>
      'Bagaimana kondisi kulit Anda hari ini? (opsional)';

  @override
  String get logProgress => 'Catat Perkembangan';

  @override
  String get skinLogUploaded => '📸 Catatan kulit diunggah! Skor diperbarui.';

  @override
  String get uploadFailed => 'Pengunggahan gagal. Coba lagi.';

  @override
  String get compareGlow => 'BANDINGKAN KULIT';

  @override
  String get beforeUpper => 'SEBELUM';

  @override
  String get afterUpper => 'SESUDAH';

  @override
  String get progressDetails => 'DETAIL PERKEMBANGAN';

  @override
  String get closeComparison => 'TUTUP PERBANDINGAN';

  @override
  String get logEntry => 'CATATAN JURNAL';

  @override
  String get notesUpper => 'CATATAN';

  @override
  String get noNotesLogged => 'Tidak ada catatan untuk entri ini.';

  @override
  String get deleteLogEntry => 'HAPUS CATATAN JURNAL';

  @override
  String get deleteEntryDialogTitle => 'Hapus Catatan?';

  @override
  String get deleteEntryConfirmMessage =>
      'Apakah Anda yakin ingin menghapus catatan perkembangan ini secara permanen?';

  @override
  String get entryDeletedSnackbar => '🗑️ Catatan dihapus.';

  @override
  String get scannerTitle => 'Pemindai Kulit';

  @override
  String get scanIngredientsUpper => 'PINDAI KOMPOSISI';

  @override
  String get scanHistoryUpper => 'RIWAYAT PINDAI';

  @override
  String get alignIngredientsInFrame =>
      'Posisikan daftar komposisi di dalam bingkai';

  @override
  String get cameraInitializing => 'Menginisialisasi Kamera...';

  @override
  String get cameraPermissionRequired => 'Izin Kamera Diperlukan';

  @override
  String get cameraPermissionDesc =>
      'Harap berikan izin kamera di pengaturan perangkat Anda untuk memindai label komposisi.';

  @override
  String get openSettings => 'Buka Pengaturan';

  @override
  String get analyzingIngredients => 'Menganalisis Komposisi...';

  @override
  String get clearAllScanHistoryTitle => 'Hapus semua riwayat scan?';

  @override
  String get clearAllScanHistoryDesc =>
      'Apakah Anda yakin ingin menghapus semua riwayat pemindaian yang tersimpan? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get clearHistoryButton => 'Hapus Riwayat';

  @override
  String get historyClearedSnackbar => 'Riwayat pemindaian telah dihapus.';

  @override
  String get noScanHistoryTitle => 'Belum ada riwayat pemindaian';

  @override
  String get noScanHistoryDesc =>
      'Komposisi yang dianalisis akan muncul di sini.';

  @override
  String analyzedOnDate(String date) {
    return 'Dianalisis pada $date';
  }

  @override
  String detectedIngredientsCount(int count) {
    return 'Komposisi Terdeteksi ($count)';
  }

  @override
  String safetyScore(int score) {
    return 'Skor Keamanan: $score/100';
  }

  @override
  String get skinSuitability => 'Kesesuaian Kulit:';

  @override
  String get recommendations => 'Rekomendasi:';

  @override
  String get scanAgain => 'PINDAI LAGI';

  @override
  String statusLevel(String level) {
    return 'Status: $level';
  }

  @override
  String get galleryTooltip => 'Pilih dari Galeri';

  @override
  String textBlocksDetectedTap(int count) {
    return '$count blok teks terdeteksi — KETUK untuk analisis';
  }

  @override
  String get detectingText => 'Mendeteksi teks...';

  @override
  String get noCameraAvailable => 'Kamera Tidak Tersedia';

  @override
  String get noCameraDesc =>
      'GlowMatch tidak dapat mendeteksi kamera fisik pada perangkat atau simulator ini.';

  @override
  String get scanAnalysisUpper => 'ANALISIS PINDAI';

  @override
  String get noIngredientsFoundMessage =>
      'Tidak ada bahan ditemukan.\nCoba ketuk blok teks yang berisi daftar bahan.';

  @override
  String get ingredientInteractionsUpper => 'INTERAKSI BAHAN';

  @override
  String get safetyAndDescription => 'Keamanan & Deskripsi Bahan:';

  @override
  String get pastProductScans => 'Riwayat pemindaian produk';

  @override
  String get noDetailAvailable => 'Tidak ada detail tersedia.';

  @override
  String get imageScanner => 'PEMINDAI GAMBAR';

  @override
  String get profileAndSettings => 'Profil & Pengaturan';

  @override
  String get guestUser => 'Pengguna Tamu';

  @override
  String get securedUser => 'Pengguna Terdaftar';

  @override
  String get guestAccountWarning => 'Akun Tamu (Data bersifat sementara)';

  @override
  String get secureYourAccount => 'Amankan Akun Anda';

  @override
  String get secureAccountDesc =>
      'Tautkan email dan kata sandi agar koleksi skincare dan rutinitas Anda tidak hilang.';

  @override
  String get linkEmailAccount => 'Tautkan Akun Email';

  @override
  String get accountSecuredSuccess => 'Akun berhasil diamankan!';

  @override
  String get appSettings => 'Pengaturan Aplikasi';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get darkModeDesc => 'Ganti tema gelap untuk seluruh aplikasi';

  @override
  String get language => 'Bahasa';

  @override
  String get languageDesc => 'Pilih bahasa yang Anda inginkan';

  @override
  String get systemDefault => 'Bawaan Sistem';

  @override
  String get english => 'English';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get preferredCurrency => 'Mata Uang Pilihan';

  @override
  String get preferredCurrencyDesc =>
      'Pilih mata uang tampilan dan anggaran Anda';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get routineReminders => 'Pengingat Rutinitas';

  @override
  String get routineRemindersDesc =>
      'Aktifkan notifikasi rutinitas pagi & malam';

  @override
  String get amReminder => '🌅  Pengingat Pagi';

  @override
  String get amReminderDesc => 'Notifikasi rutinitas pagi';

  @override
  String get pmReminder => '🌙  Pengingat Malam';

  @override
  String get pmReminderDesc => 'Notifikasi rutinitas malam';

  @override
  String get signOut => 'Keluar';

  @override
  String get confirmSignOut => 'Konfirmasi Keluar';

  @override
  String get confirmSignOutGuest =>
      'Peringatan: Anda saat ini menggunakan akun Tamu. Keluar akan menghapus koleksi skincare dan rutinitas Anda secara permanen. Apakah Anda yakin ingin keluar?';

  @override
  String get confirmSignOutUser =>
      'Apakah Anda yakin ingin keluar dari akun Anda?';
}
