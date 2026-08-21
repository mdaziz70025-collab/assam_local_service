class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> translations = {
    'en': {
      'explore': 'Explore',
      'bookings': 'Bookings',
      'account': 'Account',
      'offer': 'Get Flat 20% OFF\nOn Doorstep Services',
      'select_service': 'Select A Service',
      'top_partners': '⭐ Top Verified Partners in Assam',
      'store_title': '🛍️ Essential Parts & Marketing Deals',
      'trust_title': '🛡️ Assam Local Service Guarantee',
      'search': "Search 'Electrician', 'AC', 'Plumber'...",
      'otp_badge': 'Completion OTP:',
    },
    'as': {
      'explore': 'অন্বেষণ',
      'bookings': 'অৰ্ডাৰসমূহ',
      'account': 'একাউণ্ট',
      'offer': 'ঘৰুৱা সেৱাত পাওক\n২০% ৰেহাই',
      'select_service': 'সেৱা বাছক',
      'top_partners': '⭐ অসমৰ শীৰ্ষ প্ৰমাণিত অংশীদাৰ',
      'store_title': '🛍️ প্ৰয়োজনীয় সামগ্ৰী আৰু সামগ্ৰীৰ দোকান',
      'trust_title': '🛡️ নিশ্চিত আৰু বিশ্বাসযোগ্য সেৱা',
      'search': 'ইলেক্ট্ৰিচিয়ান, প্লাম্বাৰ সন্ধান কৰক...',
      'otp_badge': 'সমাপ্তি অ’টিপি:',
    },
    'bn': {
      'explore': 'সার্ভিস',
      'bookings': 'অর্ডার',
      'account': 'অ্যাকাউন্ট',
      'offer': 'হোম সার্ভিসে পান\n২০% ডিসকাউন্ট',
      'select_service': 'সার্ভিস বেছে নিন',
      'top_partners': '⭐ শীর্ষ ভেরিফাইড পার্টনার্স',
      'store_title': '🛍️ প্রয়োজনীয় পার্টস ও বিশেষ ডিল',
      'trust_title': '🛡️ ১০০% বিশ্বস্ত ও নিরাপদ সার্ভিস',
      'search': 'ইলেকট্রিশিয়ান, প্লাম্বার খুঁজুন...',
      'otp_badge': 'সমাপ্তি ওটিপি:',
    },
  };

  static String t(String lang, String key) {
    return translations[lang]?[key] ?? translations['en']![key] ?? key;
  }
}
