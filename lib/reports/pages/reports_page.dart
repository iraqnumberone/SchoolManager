import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with TickerProviderStateMixin {
  String _selectedReportType = 'تقرير الأداء الشهري';
  String _selectedClass = 'الكل';
  String _selectedPeriod = 'الشهر الحالي';
  bool _includeCharts = true;
  bool _includeDetails = true;
  bool _isGenerating = false;

  late AnimationController _generateButtonController;
  late AnimationController _previewController;
  late Animation<double> _generateButtonScale;
  late Animation<double> _previewSlide;

  @override
  void initState() {
    super.initState();

    // متحكم تأثير زر الإنشاء
    _generateButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // متحكم تأثير المعاينة
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // تأثير تكبير زر الإنشاء
    _generateButtonScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_generateButtonController);

    // تأثير انزلاق المعاينة
    _previewSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _previewController, curve: Curves.easeOut),
    );

    // بدء تأثير المعاينة
    _previewController.forward();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
    });

    // تشغيل تأثير زر الإنشاء
    await _generateButtonController.forward();

    // محاكاة إنشاء التقرير
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isGenerating = false;
    });

    // إظهار رسالة النجاح
    if (mounted) {
      _showSuccessMessage();
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'تم إنشاء التقرير بنجاح',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppConfig.successColor,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'عرض',
          textColor: Colors.white,
          onPressed: () {
            // الانتقال إلى عرض التقرير
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _generateButtonController.dispose();
    _previewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: Text(
          'إنشاء تقرير',
          style: GoogleFonts.cairo(
            fontSize: AppConfig.fontSizeXXLarge,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConfig.primaryColor,
        elevation: AppConfig.cardElevation,
        shadowColor: AppConfig.primaryColor.withValues(alpha: 0.3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppConfig.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان الصفحة
            Text(
              'إنشاء تقرير أداء شامل',
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeXXLarge,
                fontWeight: FontWeight.bold,
                color: AppConfig.textPrimaryColor,
              ),
            ),

            const SizedBox(height: AppConfig.spacingSM),

            Text(
              'اختر إعدادات التقرير وقم بإنشائه بسهولة',
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeMedium,
                color: AppConfig.textSecondaryColor,
              ),
            ),

            const SizedBox(height: AppConfig.spacingXXL),

            // نوع التقرير
            _buildSectionCard(
              title: 'نوع التقرير',
              icon: Icons.analytics_outlined,
              color: AppConfig.primaryColor,
              child: Column(
                children: [
                  _buildRadioOption(
                    'تقرير الأداء الشهري',
                    _selectedReportType == 'تقرير الأداء الشهري',
                  ),
                  _buildRadioOption(
                    'تقرير الحضور والدرجات',
                    _selectedReportType == 'تقرير الحضور والدرجات',
                  ),
                  _buildRadioOption(
                    'تقرير الدرجات التفصيلي',
                    _selectedReportType == 'تقرير الدرجات التفصيلي',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConfig.spacingLG),

            // نطاق البيانات
            _buildSectionCard(
              title: 'نطاق البيانات',
              icon: Icons.date_range_outlined,
              color: AppConfig.secondaryColor,
              child: Column(
                children: [
                  _buildDropdownOption(
                    'الصف الدراسي',
                    _selectedClass,
                    ['الكل', 'الصف الأول أ', 'الصف الأول ب', 'الصف الثاني أ'],
                    (value) => setState(() => _selectedClass = value!),
                  ),

                  const SizedBox(height: AppConfig.spacingMD),

                  _buildDropdownOption(
                    'الفترة الزمنية',
                    _selectedPeriod,
                    [
                      'الشهر الحالي',
                      'الشهر الماضي',
                      'الفصل الحالي',
                      'السنة الحالية',
                    ],
                    (value) => setState(() => _selectedPeriod = value!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConfig.spacingLG),

            // خيارات التقرير
            _buildSectionCard(
              title: 'خيارات التقرير',
              icon: Icons.settings_outlined,
              color: AppConfig.secondaryColor,
              child: Column(
                children: [
                  _buildCheckboxOption(
                    'تضمين الرسوم البيانية',
                    _includeCharts,
                    (value) => setState(() => _includeCharts = value!),
                  ),

                  _buildCheckboxOption(
                    'تضمين التفاصيل الكاملة',
                    _includeDetails,
                    (value) => setState(() => _includeDetails = value!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConfig.spacingLG),

            // معاينة التقرير
            AnimatedBuilder(
              animation: _previewController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_previewSlide.value, 0),
                  child: Opacity(
                    opacity: _previewController.value,
                    child: _buildSectionCard(
                      title: 'معاينة التقرير',
                      icon: Icons.preview_outlined,
                      color: AppConfig.infoColor,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppConfig.backgroundColor,
                          borderRadius: BorderRadius.circular(
                            AppConfig.borderRadius / 2,
                          ),
                          border: Border.all(
                            color: AppConfig.borderColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.insert_chart_outlined,
                              size: 48,
                              color: AppConfig.textLightColor,
                            ),
                            const SizedBox(height: AppConfig.spacingMD),
                            Text(
                              'معاينة التقرير ستظهر هنا',
                              style: GoogleFonts.cairo(
                                fontSize: AppConfig.fontSizeMedium,
                                color: AppConfig.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: AppConfig.spacingSM),
                            Text(
                              'سيتم عرض الرسوم البيانية والإحصائيات',
                              style: GoogleFonts.cairo(
                                fontSize: AppConfig.fontSizeSmall,
                                color: AppConfig.textLightColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppConfig.spacingXXL),

            // زر الإنشاء المتحرك
            AnimatedBuilder(
              animation: _generateButtonScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _generateButtonScale.value,
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _generateReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.secondaryColor,
                      foregroundColor: Colors.white,
                      elevation: AppConfig.buttonElevation,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConfig.spacingXXL,
                        vertical: AppConfig.spacingLG,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConfig.borderRadius,
                        ),
                      ),
                      shadowColor: AppConfig.secondaryColor.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    child: _isGenerating
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'جاري الإنشاء...',
                                style: GoogleFonts.cairo(
                                  fontSize: AppConfig.fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.analytics_outlined, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'إنشاء التقرير',
                                style: GoogleFonts.cairo(
                                  fontSize: AppConfig.fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppConfig.spacingLG),

            // خيارات إضافية
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // حفظ كمسودة
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: Text('حفظ كمسودة', style: GoogleFonts.cairo()),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppConfig.borderColor),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConfig.spacingMD,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConfig.borderRadius,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppConfig.spacingMD),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // مشاركة الإعدادات
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: Text('مشاركة', style: GoogleFonts.cairo()),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppConfig.borderColor),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConfig.spacingMD,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConfig.borderRadius,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConfig.spacingXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppConfig.cardColor,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppConfig.borderColor.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConfig.borderRadius / 2,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.textPrimaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConfig.spacingLG),

            child,
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConfig.spacingSM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
          onTap: () {
            setState(() => _selectedReportType = title);
          },
          child: Container(
            padding: const EdgeInsets.all(AppConfig.spacingMD),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppConfig.primaryColor.withValues(alpha: 0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
              border: Border.all(
                color: isSelected
                    ? AppConfig.primaryColor.withValues(alpha: 0.3)
                    : AppConfig.borderColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppConfig.primaryColor
                          : AppConfig.borderColor,
                      width: 2,
                    ),
                    color: isSelected
                        ? AppConfig.primaryColor
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeMedium,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: AppConfig.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownOption(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: AppConfig.fontSizeMedium,
            fontWeight: FontWeight.w600,
            color: AppConfig.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppConfig.spacingSM),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppConfig.borderColor, width: 1),
            borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeMedium,
                    color: AppConfig.textPrimaryColor,
                  ),
                ),
              );
            }).toList(),
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeMedium,
              color: AppConfig.textPrimaryColor,
            ),
            underline: Container(),
            isExpanded: true,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.spacingMD,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxOption(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConfig.spacingSM),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppConfig.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeMedium,
              color: AppConfig.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
