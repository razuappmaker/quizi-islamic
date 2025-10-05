// widgets/category_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/responsive_utils.dart';

class CategorySelector extends StatefulWidget {
  final bool isDarkMode;
  final Function(String)? onCategorySelected;

  const CategorySelector({
    super.key,
    required this.isDarkMode,
    this.onCategorySelected,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String? selectedCategory;

  final List<String> _categoriesBn = [
    'ইসলামী প্রাথমিক জ্ঞান',
    'কোরআন',
    'মহানবী সঃ এর জীবনী',
    'ইবাদত',
    'আখিরাত',
    'বিচার দিবস',
    'নারী ও ইসলাম',
    'ইসলামী নৈতিকতা ও আচার',
    'ধর্মীয় আইন(বিবাহ-বিচ্ছেদ)',
    'শিষ্টাচার',
    'দাম্পত্য ও পারিবারিক সম্পর্ক',
    'হাদিস',
    'নবী-রাসূল',
    'ইসলামের ইতিহাস',
  ];

  final Map<String, String> _categoryMappings = {
    'ইসলামী প্রাথমিক জ্ঞান': 'islamic_basic_knowledge',
    'কোরআন': 'quran',
    'মহানবী সঃ এর জীবনী': 'prophet_biography',
    'ইবাদত': 'worship',
    'আখিরাত': 'hereafter',
    'বিচার দিবস': 'judgment_day',
    'নারী ও ইসলাম': 'women_in_islam',
    'ইসলামী নৈতিকতা ও আচার': 'islamic_ethics',
    'ধর্মীয় আইন(বিবাহ-বিচ্ছেদ)': 'religious_law',
    'শিষ্টাচার': 'etiquette',
    'দাম্পত্য ও পারিবারিক সম্পর্ক': 'family_relations',
    'হাদিস': 'hadith',
    'নবী-রাসূল': 'prophets',
    'ইসলামের ইতিহাস': 'islamic_history',
  };

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (languageProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ResponsivePadding(
      horizontal: isTablet(context) ? 16 : 12,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(responsiveValue(context, 10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResponsiveText(
                languageProvider.isEnglish
                    ? 'Islamic Knowledge Test: Quiz'
                    : 'ইসলামী মেধাযাচাই: জ্ঞান কুইজ',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: (widget.isDarkMode ? Colors.white : Colors.green[800]!),
                textAlign: TextAlign.center,
              ),
              const ResponsiveSizedBox(height: 6),
              _buildDropdown(languageProvider),
              const ResponsiveSizedBox(height: 8),
              _buildStartButton(languageProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(LanguageProvider languageProvider) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveValue(context, 10),
        vertical: responsiveValue(context, 6),
      ),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.green[800] : Colors.green[50],
        borderRadius: BorderRadius.circular(responsiveValue(context, 10)),
        border: Border.all(
          color: Colors.green[600]!,
          width: responsiveValue(context, 1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          hint: Row(
            children: [
              Icon(
                Icons.search,
                size: responsiveValue(context, 16),
                color: widget.isDarkMode ? Colors.white : Colors.green[700],
              ),
              SizedBox(width: responsiveValue(context, 6)),
              ResponsiveText(
                languageProvider.isEnglish
                    ? 'Select Category'
                    : 'বিষয় বেছে নিন',
                fontSize: 12,
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
          style: TextStyle(
            fontSize: responsiveValue(context, 12),
            color: widget.isDarkMode ? Colors.white70 : Colors.black87,
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: widget.isDarkMode ? Colors.white70 : Colors.green,
            size: responsiveValue(context, 20),
          ),
          isExpanded: true,
          dropdownColor: widget.isDarkMode ? Colors.green[800] : Colors.white,
          menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
          alignment: Alignment.bottomCenter,
          selectedItemBuilder: (BuildContext context) {
            return _categoriesBn.map<Widget>((String item) {
              return Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: responsiveValue(context, 12),
                    color: widget.isDarkMode ? Colors.white : Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
          onChanged: (String? newValue) {
            setState(() {
              selectedCategory = newValue;
            });
            widget.onCategorySelected?.call(newValue ?? '');
          },
          items: _categoriesBn.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: responsiveValue(context, 8),
                  horizontal: responsiveValue(context, 4),
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(responsiveValue(context, 6)),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_border,
                        size: responsiveValue(context, 14),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.green[700],
                      ),
                    ),
                    SizedBox(width: responsiveValue(context, 10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: responsiveValue(context, 12),
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: responsiveValue(context, 2)),
                          Text(
                            'কুইজ: ${_categoriesBn.indexOf(category) + 1}',
                            style: TextStyle(
                              fontSize: responsiveValue(context, 9),
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white60
                                  : Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selectedCategory == category)
                      Icon(
                        Icons.check_circle_rounded,
                        size: responsiveValue(context, 16),
                        color: Colors.green,
                      ),
                    SizedBox(width: responsiveValue(context, 4)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStartButton(LanguageProvider languageProvider) {
    return SizedBox(
      height: responsiveValue(context, 42),
      child: ElevatedButton.icon(
        onPressed: selectedCategory == null ? null : _startQuiz,
        icon: Icon(
          Icons.play_circle_filled,
          size: responsiveValue(context, 18),
        ),
        label: ResponsiveText(
          languageProvider.isEnglish
              ? 'Start Quiz and Win Rewards'
              : 'কুইজ শুরু করুন এবং পুরস্কার জিতুন',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsiveValue(context, 10)),
          ),
          elevation: 4,
          shadowColor: Colors.green.withOpacity(0.5),
        ),
      ),
    );
  }

  void _startQuiz() {
    if (selectedCategory == null) return;

    final String quizId =
        _categoryMappings[selectedCategory!] ?? selectedCategory!;

    // Navigate to MCQ page
    // This will be handled by the parent widget
    widget.onCategorySelected?.call(selectedCategory!);
  }
}
