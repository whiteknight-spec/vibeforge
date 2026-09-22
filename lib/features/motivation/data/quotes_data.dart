import 'dart:math';

/// Motivational quotes database in English + Tamil.
class QuotesData {
  QuotesData._();

  static final _random = Random();

  static String getDailyQuote({bool isTamil = false}) {
    // Use date as seed for consistent daily quote
    final now = DateTime.now();
    final dayIndex = (now.year * 1000 + now.month * 31 + now.day) % (isTamil ? _tamilQuotes.length : _englishQuotes.length);
    return isTamil ? _tamilQuotes[dayIndex] : _englishQuotes[dayIndex];
  }

  static String getRandomQuote({bool isTamil = false}) {
    final list = isTamil ? _tamilQuotes : _englishQuotes;
    return list[_random.nextInt(list.length)];
  }

  static String getCelebrationQuote({bool isTamil = false}) {
    final list = isTamil ? _tamilCelebration : _englishCelebration;
    return list[_random.nextInt(list.length)];
  }

  static const List<String> _englishQuotes = [
    "The only bad workout is the one that didn't happen.",
    "Small daily improvements are the key to staggering long-term results.",
    "Your body can stand almost anything. It's your mind that you have to convince.",
    "Don't count the days, make the days count.",
    "The pain you feel today will be the strength you feel tomorrow.",
    "Success is the sum of small efforts, repeated day in and day out.",
    "The secret of getting ahead is getting started.",
    "It does not matter how slowly you go, as long as you don't stop.",
    "Push yourself because no one else is going to do it for you.",
    "The best time to start was yesterday. The next best time is now.",
    "You don't have to be great to start, but you have to start to be great.",
    "Believe you can and you're halfway there.",
    "What you get by achieving your goals is not as important as what you become.",
    "Discipline is choosing between what you want now and what you want most.",
    "The body achieves what the mind believes.",
    "Consistency is more important than perfection.",
    "Every champion was once a beginner.",
    "Your only limit is you.",
    "Fall in love with the process and the results will come.",
    "One day or day one. You decide.",
    "Progress, not perfection.",
    "The harder you work for something, the greater you'll feel when you achieve it.",
    "Dream it. Wish it. Do it.",
    "Motivation gets you started. Habit keeps you going.",
    "Strong people don't give up when things get tough. They push harder.",
    "No shortcuts. Work for it.",
    "Be stronger than your excuses.",
    "Success doesn't come from what you do occasionally. It comes from what you do consistently.",
    "Results happen over time, not overnight. Work hard, stay consistent, and be patient.",
    "Your future self will thank you.",
  ];

  static const List<String> _tamilQuotes = [
    "நடக்காத ஒரே மோசமான உடற்பயிற்சி தான்.",
    "சிறிய தினசரி முன்னேற்றங்கள் நீண்டகால வெற்றிக்கு திறவுகோல்.",
    "உங்கள் உடல் எதையும் தாங்கும். உங்கள் மனதை நீங்கள் சமாதானப்படுத்த வேண்டும்.",
    "நாட்களை எண்ணாதீர்கள், நாட்களை மதிப்புள்ளதாக்குங்கள்.",
    "இன்று நீங்கள் உணரும் வலி நாளை உங்கள் வலிமையாக மாறும்.",
    "வெற்றி என்பது சிறு முயற்சிகளின் கூட்டுத்தொகை, தினமும் மீண்டும் மீண்டும்.",
    "முன்னேறுவதற்கான ரகசியம் தொடங்குவதுதான்.",
    "நீங்கள் எவ்வளவு மெதுவாக சென்றாலும் பரவாயில்லை, நிறுத்தாதீர்கள்.",
    "உங்களை நீங்களே தள்ளுங்கள், வேறு யாரும் செய்யப் போவதில்லை.",
    "தொடங்குவதற்கு சிறந்த நேரம் நேற்று. அடுத்த சிறந்த நேரம் இப்போது.",
    "சிறப்பாக இருக்க தொடங்க வேண்டியதில்லை, ஆனால் சிறப்பாக இருக்க தொடங்க வேண்டும்.",
    "உங்களால் முடியும் என்று நம்புங்கள், நீங்கள் பாதி வழியில் இருக்கிறீர்கள்.",
    "ஒழுக்கம் என்பது இப்போது நீங்கள் விரும்புவதற்கும் மிகவும் விரும்புவதற்கும் இடையில் தேர்வு செய்வது.",
    "உடல் மனம் நம்புவதை அடைகிறது.",
    "நிலைத்தன்மை முழுமையை விட முக்கியமானது.",
    "ஒவ்வொரு சாம்பியனும் ஒரு காலத்தில் ஆரம்பநிலையாளர்.",
    "உங்கள் ஒரே வரம்பு நீங்கள் தான்.",
    "செயல்முறையை நேசியுங்கள், முடிவுகள் வரும்.",
    "ஒரு நாள் அல்லது முதல் நாள். நீங்கள் முடிவு செய்யுங்கள்.",
    "முன்னேற்றம், முழுமை அல்ல.",
    "கடினமாக உழைத்தால், அடையும்போது பெரிய திருப்தி கிடைக்கும்.",
    "கனவு காணுங்கள். விரும்புங்கள். செய்யுங்கள்.",
    "உத்வேகம் தொடங்க வைக்கிறது. பழக்கம் தொடர வைக்கிறது.",
    "வலிமையான மனிதர்கள் கஷ்டமான நேரத்தில் விட்டுக்கொடுப்பதில்லை.",
    "குறுக்குவழிகள் இல்லை. அதற்காக உழையுங்கள்.",
    "உங்கள் சாக்குகளை விட வலிமையாக இருங்கள்.",
    "நீங்கள் எப்போதாவது செய்வதிலிருந்து வெற்றி வராது. நீங்கள் தொடர்ந்து செய்வதிலிருந்து வரும்.",
    "முடிவுகள் ஒரே இரவில் வராது. கடினமாக உழையுங்கள், நிலைத்தன்மையாக இருங்கள்.",
    "உங்கள் எதிர்காலத்தில் உள்ள நீங்கள் நன்றி சொல்வீர்கள்.",
    "ஒவ்வொரு அடியும் முன்னேற்றம்.",
  ];

  static const List<String> _englishCelebration = [
    "You absolutely crushed it today! 🔥",
    "100% completion! You're unstoppable! 💪",
    "Another perfect day in the books! 📖",
    "Champions don't skip days. You proved it! 🏆",
    "Your consistency is building your future! 🚀",
    "Beast mode: ACTIVATED! 🦁",
    "This is what discipline looks like! ⭐",
  ];

  static const List<String> _tamilCelebration = [
    "இன்று நீங்கள் அசத்திவிட்டீர்கள்! 🔥",
    "100% நிறைவு! நீங்கள் தடுக்க முடியாதவர்! 💪",
    "இன்னொரு சிறந்த நாள்! 📖",
    "சாம்பியன்கள் நாட்களை தவிர்ப்பதில்லை. நிரூபித்தீர்கள்! 🏆",
    "உங்கள் நிலைத்தன்மை உங்கள் எதிர்காலத்தை உருவாக்குகிறது! 🚀",
    "மிருக பயன்முறை: செயல்படுத்தப்பட்டது! 🦁",
    "ஒழுக்கம் இப்படித்தான் இருக்கும்! ⭐",
  ];
}
