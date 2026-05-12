import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/province_data.dart';
import '../utils/constants.dart';

class SriLankaMapPage extends StatefulWidget {
  const SriLankaMapPage({super.key});

  @override
  State<SriLankaMapPage> createState() => _SriLankaMapPageState();
}

class _SriLankaMapPageState extends State<SriLankaMapPage> {
  String? selectedProvinceId;
  String language = 'en'; // 'en', 'si', 'ta'

  @override
  void initState() {
    super.initState();
    selectedProvinceId = 'western';
  }

  void _selectProvince(String provinceId) {
    setState(() {
      selectedProvinceId = provinceId;
    });
  }

  void _setLanguage(String lang) {
    setState(() {
      language = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedProvince = selectedProvinceId != null
        ? ProvinceDataManager.getProvinceById(selectedProvinceId!)
        : null;
    final translation = selectedProvince?.getTranslation(language);

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Column(
              children: [
                // Map Container with padding for language switcher
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                  child: Column(
                    children: [
                      Text(
                        AppLabels.getLabel('tapProvince', language),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInteractiveMap(),
                    ],
                  ),
                ),
                // Province Details Card
                if (selectedProvince != null && translation != null)
                  Container(
                    margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _parseColor(selectedProvince.colorHex)
                            .withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _parseColor(selectedProvince.colorHex)
                              .withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Color Bar Header
                        Container(
                          height: 5,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _parseColor(selectedProvince.colorHex),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(11),
                              topRight: Radius.circular(11),
                            ),
                          ),
                        ),
                        // Details Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Province Name
                              Text(
                                translation.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Capital
                              Text(
                                '${AppLabels.getLabel('capital', language)}: ${selectedProvince.capital}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Districts Label & Content
                              Text(
                                AppLabels.getLabel('districts', language),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                translation.districts,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Tags Label
                              Text(
                                AppLabels.getLabel('tags', language),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: translation.tags
                                    .map((tag) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.card2,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Text(
                                            tag,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 14),
                              // Famous Places Label
                              Text(
                                AppLabels.getLabel('places', language),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: translation.places
                                    .map((place) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _parseColor(
                                                    selectedProvince.colorHex)
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: _parseColor(
                                                      selectedProvince
                                                          .colorHex)
                                                  .withOpacity(0.4),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Text(
                                            place,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: _parseColor(
                                                  selectedProvince.colorHex),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 14),
                              // Industries Label
                              Text(
                                AppLabels.getLabel('industries', language),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.card2,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _parseColor(selectedProvince.colorHex)
                                        .withOpacity(0.2),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  translation.industries,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Language Switcher (Fixed at Top)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.goldLight.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildLanguageButton('EN', 'en'),
                  _buildLanguageButton('සි', 'si'),
                  _buildLanguageButton('தமி', 'ta'),
                ],
              ),
            ),
          ),
          // Legend (Fixed at Top Right)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.goldLight.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 300, maxWidth: 160),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLabels.getLabel('provinces', language),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...ProvinceDataManager.getAllProvinces().map((province) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: _parseColor(province.colorHex),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  province.getTranslation(language).name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String label, String langCode) {
    final isActive = language == langCode;
    return GestureDetector(
      onTap: () => _setLanguage(langCode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.goldLight : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.navy : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveMap() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 450),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldLight.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/maps/Sri_Lanka_provinces.svg',
              fit: BoxFit.contain,
            ),
          ),
          _buildProvinceButtons(),
        ],
      ),
    );
  }

  Widget _buildProvinceButtons() {
    final provinceButtons = [
      _ProvinceButton(id: 'western', left: 0.25, top: 0.65, size: 70),
      _ProvinceButton(id: 'central', left: 0.38, top: 0.45, size: 70),
      _ProvinceButton(id: 'southern', left: 0.32, top: 0.8, size: 60),
      _ProvinceButton(id: 'northern', left: 0.38, top: 0.08, size: 80),
      _ProvinceButton(id: 'eastern', left: 0.58, top: 0.35, size: 70),
      _ProvinceButton(id: 'north_western', left: 0.2, top: 0.38, size: 70),
      _ProvinceButton(id: 'north_central', left: 0.42, top: 0.28, size: 70),
      _ProvinceButton(id: 'uva', left: 0.52, top: 0.55, size: 65),
      _ProvinceButton(id: 'sabaragamuwa', left: 0.35, top: 0.6, size: 65),
    ];

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: provinceButtons
                .map((btn) {
                  final province = ProvinceDataManager.getProvinceById(btn.id);
                  final isSelected = selectedProvinceId == btn.id;
                  final color = province != null
                      ? _parseColor(province.colorHex)
                      : AppColors.goldLight;

                  return Positioned(
                    left: constraints.maxWidth * btn.left - btn.size / 2,
                    top: constraints.maxHeight * btn.top - btn.size / 2,
                    child: GestureDetector(
                      onTap: () => _selectProvince(btn.id),
                      child: Container(
                        width: btn.size,
                        height: btn.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? color.withOpacity(0.5)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            btn.id.replaceAll('_', '\n'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                })
                .toList(),
          );
        },
      ),
    );
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16));
    } else if (hexColor.length == 8) {
      return Color(int.parse('0x$hexColor', radix: 16));
    }
    return AppColors.goldLight;
  }
}

class _ProvinceButton {
  final String id;
  final double left;
  final double top;
  final double size;

  _ProvinceButton({
    required this.id,
    required this.left,
    required this.top,
    required this.size,
  });
}
