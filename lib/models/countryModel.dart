import 'package:phonecodes/phonecodes.dart';

class CountryModel {
  final String country;
  final String code;
  final String flagUrl;
  const CountryModel({this.country="", this.code="", this.flagUrl=""});
}

class Language {
  final String englishName;
  final String nativeName;
  final String flag;
  final String code;

  Language(this.englishName, this.nativeName, this.flag, this.code);
}
List<CountryModel> dummyCountries = <CountryModel>[
];

final List<Language> languages = [
    Language('English', 'English', '🇺🇸', 'eng'),
    Language('Russian', 'Русский', '🇷🇺', 'rus'),
    Language('Armenian', 'Հայերեն', '🇦🇲', 'arm'),
    /*
    Language('Spanish', 'Español', '🇪🇸', 'spa'),
    Language('Mandarin Chinese', '普通话', '🇨🇳', 'zho'),
    Language('Hindi', 'हिन्दी', '🇮🇳', 'hin'),
    Language('Arabic', 'العربية', '🇸🇦', 'ara'),
    Language('Portuguese', 'Português', '🇵🇹', 'por'),
    Language('Bengali', 'বাংলা', '🇧🇩', 'ben'),
    Language('Russian', 'Русский', '🇷🇺', 'rus'),
    Language('Japanese', '日本語', '🇯🇵', 'jpn'),
    Language('Punjabi', 'ਪੰਜਾਬੀ', '🇮🇳', 'pan'),
    Language('German', 'Deutsch', '🇩🇪', 'deu'),
    Language('Javanese', 'Basa Jawa', '🇮🇩', 'jav'),
    Language('Wu Chinese', '吴语', '🇨🇳', 'wuu'),
    Language('Malay', 'Bahasa Melayu', '🇲🇾', 'msa'),
    Language('Telugu', 'తెలుగు', '🇮🇳', 'tel'),
    Language('Vietnamese', 'Tiếng Việt', '🇻🇳', 'vie'),
    Language('Korean', '한국어', '🇰🇷', 'kor'),
    Language('French', 'Français', '🇫🇷', 'fra'),
    Language('Marathi', 'मराठी', '🇮🇳', 'mar'),
    Language('Tamil', 'தமிழ்', '🇮🇳', 'tam'),
    Language('Urdu', 'اردو', '🇵🇰', 'urd'),
    Language('Turkish', 'Türkçe', '🇹🇷', 'tur'),
    Language('Italian', 'Italiano', '🇮🇹', 'ita'),
    Language('Yue Chinese', '粤语', '🇨🇳', 'yue'),
    Language('Thai', 'ไทย', '🇹🇭', 'tha'),
    Language('Gujarati', 'ગુજરાતી', '🇮🇳', 'guj'),
    Language('Jin Chinese', '晋语', '🇨🇳', 'cjy'),
    Language('Southern Min', '闽南语', '🇨🇳', 'nan'),
    Language('Persian', 'فارسی', '🇮🇷', 'fas'),
    Language('Polish', 'Polski', '🇵🇱', 'pol'),
    Language('Pashto', 'پښتو', '🇦🇫', 'pus'),
    Language('Kannada', 'ಕನ್ನಡ', '🇮🇳', 'kan'),
    Language('Xiang Chinese', '湘语', '🇨🇳', 'hsn'),
    Language('Malayalam', 'മലയാളം', '🇮🇳', 'mal'),
    Language('Sundanese', 'Basa Sunda', '🇮🇩', 'sun'),
    Language('Hausa', 'Hausa', '🇳🇬', 'hau'),
    Language('Odia', 'ଓଡ଼ିଆ', '🇮🇳', 'ori'),
    Language('Burmese', 'မြန်မာစာ', '🇲🇲', 'mya'),
    Language('Hakka Chinese', '客家语', '🇨🇳', 'hak'),
    Language('Ukrainian', 'Українська', '🇺🇦', 'ukr'),
    Language('Bhojpuri', 'भोजपुरी', '🇮🇳', 'bho'),
    Language('Tagalog', 'Tagalog', '🇵🇭', 'tgl'),
    Language('Yoruba', 'Yorùbá', '🇳🇬', 'yor'),
    Language('Maithili', 'मैथिली', '🇮🇳', 'mai'),
    Language('Uzbek', 'Oʻzbek', '🇺🇿', 'uzb'),
    Language('Sindhi', 'سنڌي', '🇵🇰', 'snd'),
    Language('Amharic', 'አማርኛ', '🇪🇹', 'amh'),
    Language('Fula', 'Fulfulde', '🇳🇬', 'ful'),
    Language('Romanian', 'Română', '🇷🇴', 'ron'),
    Language('Oromo', 'Afaan Oromoo', '🇪🇹', 'orm'),
    Language('Igbo', 'Igbo', '🇳🇬', 'ibo'),
    Language('Azerbaijani', 'Azərbaycanca', '🇦🇿', 'aze'),
    Language('Awadhi', 'अवधी', '🇮🇳', 'awa'),
    Language('Gan Chinese', '贛语', '🇨🇳', 'gan'),
    Language('Cebuano', 'Bisaya', '🇵🇭', 'ceb'),
    Language('Dutch', 'Nederlands', '🇳🇱', 'nld'),
    Language('Kurdish', 'Kurdî', '🇮🇶', 'kur'),
    Language('Serbo-Croatian', 'Srpskohrvatski', '🇷🇸', 'hbs'),
    Language('Malagasy', 'Malagasy', '🇲🇬', 'mlg'),
    Language('Saraiki', 'سرائیکی', '🇵🇰', 'skr'),
    Language('Nepali', 'नेपाली', '🇳🇵', 'nep'),
    Language('Sinhala', 'සිංහල', '🇱🇰', 'sin'),
    Language('Chittagonian', 'চাটগাঁইয়া', '🇧🇩', 'ctg'),
    Language('Zhuang', 'Vahcuengh', '🇨🇳', 'zha'),
    Language('Khmer', 'ភាសាខ្មែរ', '🇰🇭', 'khm'),
    Language('Turkmen', 'Türkmençe', '🇹🇲', 'tuk'),
    Language('Assamese', 'অসমীয়া', '🇮🇳', 'asm'),
    Language('Madurese', 'Basa Madura', '🇮🇩', 'mad'),
    Language('Somali', 'Soomaali', '🇸🇴', 'som'),
    Language('Marwari', 'मारवाड़ी', '🇮🇳', 'mwr'),
    Language('Magahi', 'मगही', '🇮🇳', 'mag'),
    Language('Haryanvi', 'हरयाणवी', '🇮🇳', 'bgc'),
    Language('Hungarian', 'Magyar', '🇭🇺', 'hun'),
    Language('Chhattisgarhi', 'छत्तीसगढ़ी', '🇮🇳', 'hne'),
    Language('Greek', 'Ελληνικά', '🇬🇷', 'ell'),
    Language('Chewa', 'Chichewa', '🇲🇼', 'nya'),
    Language('Deccan', 'دکنی', '🇮🇳', 'dcc'),
    Language('Akan', 'Akan', '🇬🇭', 'aka'),
    Language('Kazakh', 'Қазақша', '🇰🇿', 'kaz'),
    Language('Northern Min', '闽北语', '🇨🇳', 'mnp'),
    Language('Sylheti', 'ꠍꠤꠟꠐꠤ', '🇧🇩', 'syl'),
    Language('Zulu', 'isiZulu', '🇿🇦', 'zul'),
    Language('Czech', 'Čeština', '🇨🇿', 'ces'),
    Language('Kinyarwanda', 'Ikinyarwanda', '🇷🇼', 'kin'),
    Language('Dhundhari', 'ढूंढाड़ी', '🇮🇳', 'dhd'),
    Language('Haitian Creole', 'Kreyòl ayisyen', '🇭🇹', 'hat'),
    Language('Eastern Min', '闽东语', '🇨🇳', 'cdo'),
    Language('Ilocano', 'Ilokano', '🇵🇭', 'ilo'),
    Language('Quechua', 'Runa Simi', '🇵🇪', 'que'),
    Language('Kirundi', 'Ikirundi', '🇧🇮', 'run'),
    Language('Swedish', 'Svenska', '🇸🇪', 'swe'),
    Language('Hmong', 'Hmoob', '🇨🇳', 'hmn'),
    Language('Shona', 'chiShona', '🇿🇼', 'sna'),
    Language('Uyghur', 'ئۇيغۇرچە', '🇨🇳', 'uig'),
    Language('Hiligaynon', 'Ilonggo', '🇵🇭', 'hil'),
    Language('Mossi', 'Mooré', '🇧🇫', 'mos'),
    Language('Xhosa', 'isiXhosa', '🇿🇦', 'xho'),
    Language('Belarusian', 'Беларуская', '🇧🇾', 'bel'),
    Language('Balochi', 'بلوچی', '🇵🇰', 'bal'),
    Language('Konkani', 'कोंकणी', '🇮🇳', 'kok'),*/
  ];

void initCountries() {
  for (var cn in Countries.list) {
    dummyCountries.add(CountryModel(code: cn.dialCode, country: cn.name, flagUrl: cn.flag));
  }
}
