import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConfig.spacingMD),
      decoration: BoxDecoration(
        color: AppConfig.cardColor,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppConfig.borderColor.withValues(alpha: 0.5),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          onTap: () {
            // يمكن إضافة تفاعل عند النقر على البطاقة
          },
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.spacingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الأيقونة والقيمة الرئيسية
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConfig.spacingSM),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppConfig.borderRadius / 2,
                        ),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: GoogleFonts.cairo(
                        fontSize: AppConfig.fontSizeXXXLarge,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.textPrimaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConfig.spacingMD),

                // العنوان
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                    color: AppConfig.textSecondaryColor,
                  ),
                ),

                const SizedBox(height: AppConfig.spacingSM),

                // مؤشر الاتجاه
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConfig.spacingSM,
                    vertical: AppConfig.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppConfig.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConfig.borderRadius / 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppConfig.successColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend,
                        style: GoogleFonts.cairo(
                          fontSize: AppConfig.fontSizeSmall,
                          fontWeight: FontWeight.w600,
                          color: AppConfig.successColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
