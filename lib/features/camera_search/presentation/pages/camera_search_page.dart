import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../search_filter/presentation/pages/product_grid_page.dart';

class CameraSearchPage extends StatefulWidget {
  const CameraSearchPage({super.key});

  @override
  State<CameraSearchPage> createState() => _CameraSearchPageState();
}

class _CameraSearchPageState extends State<CameraSearchPage>
    with SingleTickerProviderStateMixin {
  bool _isCameraActive = false;
  bool _isScanning = false;
  String? _scanningImage;

  // Scanning animation line controller
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;

  final List<String> _galleryImages = [
    'assets/images/cat_fashion.png',
    'assets/images/cat_dresses.png',
    'assets/images/cat_tops.png',
    'assets/images/cat_latest.png',
    'assets/images/cat_bags.png',
    'assets/images/cat_sports.png',
    'assets/images/cat_beauty.png',
    'assets/images/cat_fashion.png',
    'assets/images/cat_dresses.png',
    'assets/images/cat_tops.png',
    'assets/images/cat_latest.png',
    'assets/images/cat_bags.png',
  ];

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _startCameraScanning() {
    setState(() {
      _isCameraActive = true;
      _isScanning = true;
      _scanningImage = 'assets/images/cat_fashion.png';
    });
    _scannerController.repeat(reverse: true);
  }

  void _startGalleryScanning(String imagePath) {
    setState(() {
      _isCameraActive = true;
      _isScanning = true;
      _scanningImage = imagePath;
    });
    _scannerController.repeat(reverse: true);
    
    // Simulate short analysis delay, then route to results grid
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _scannerController.stop();
        setState(() {
          _isCameraActive = false;
          _isScanning = false;
          _scanningImage = null;
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ProductGridPage(categoryName: 'نتائج البحث البصري'),
          ),
        );
      }
    });
  }

  void _capturePhoto() {
    setState(() {
      _isScanning = false;
    });
    _scannerController.stop();
    
    // Show a loading dialog simulating visual search network upload
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'جاري تحليل الصورة والبحث بالذكاء الاصطناعي...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        setState(() {
          _isCameraActive = false;
          _scanningImage = null;
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ProductGridPage(categoryName: 'نتائج البحث البصري'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _isCameraActive ? null : _buildAppBar(),
        body: _isCameraActive ? _buildViewfinderSection() : _buildGallerySection(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'عدسة البحث',
        style: TextStyle(
          color: AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  Widget _buildGallerySection() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Camera pill container box
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.camera_enhance_outlined, size: 48, color: AppColors.primary),
                const SizedBox(height: 12),
                const Text(
                  'ابحث عن المنتجات بالصور',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'التقط صورة للملابس التي تعجبك وسنجد لك شبيهاً بها',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _startCameraScanning,
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                  label: const Text(
                    'افتح الكاميرا',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Photos section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الصور',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4-column local gallery grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: _galleryImages.length,
            itemBuilder: (context, index) {
              final imagePath = _galleryImages[index];
              return GestureDetector(
                onTap: () => _startGalleryScanning(imagePath),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF2F3F8),
                          child: const Icon(Icons.image_outlined, color: AppColors.textGrey, size: 18),
                        ),
                      ),
                      // Hover tint design element
                      Container(
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinderSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double viewportWidth = constraints.maxWidth;
        final double viewportHeight = constraints.maxHeight;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Simulated camera feed view
            Container(
              width: viewportWidth,
              height: viewportHeight,
              color: Colors.black,
              child: Image.asset(
                _scanningImage ?? 'assets/images/cat_fashion.png',
                fit: BoxFit.cover,
              ),
            ),

            // Scanning line animation overlay
            if (_isScanning)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _scannerAnimation,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        Positioned(
                          top: _scannerAnimation.value * viewportHeight,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.8),
                                  blurRadius: 12,
                                  spreadRadius: 4,
                                ),
                              ],
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // Back button icon
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCameraActive = false;
                      _scanningImage = null;
                    });
                    _scannerController.stop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),

            // Scanning Status Banner
            if (_isScanning && _scanningImage != 'assets/images/cat_fashion.png')
              Positioned(
                top: 80,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'جاري تحليل الصورة المحددة...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),

            // Viewfinder shutter action bar
            if (!_isScanning)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    const Text(
                      'قم بمحاذاة المنتج داخل الإطار لالتقاط صورة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _capturePhoto,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
