/// Comprehensive Visual Exercise & Stretch Guide for VibeForge.
class ExerciseGuide {
  final String id;
  final String title;
  final String titleTa;
  final String imagePath;
  final String category; // 'strength', 'core', 'mobility'
  final String targetMuscles;
  final String targetMusclesTa;
  final String formCues;
  final String formCuesTa;
  final String reps;

  const ExerciseGuide({
    required this.id,
    required this.title,
    required this.titleTa,
    required this.imagePath,
    required this.category,
    required this.targetMuscles,
    required this.targetMusclesTa,
    required this.formCues,
    required this.formCuesTa,
    required this.reps,
  });
}

class ExerciseGuidesData {
  ExerciseGuidesData._();

  static const List<ExerciseGuide> guides = [
    ExerciseGuide(
      id: 'squats',
      title: 'Bodyweight Squats',
      titleTa: 'பாடிவெயிட் ஸ்குவாட்ஸ் (Squats)',
      imagePath: 'assets/images/squats.jpg',
      category: 'Lower Body & Legs',
      targetMuscles: 'Quadriceps, Glutes, Hamstrings',
      targetMusclesTa: 'தொடை தசைகள் மற்றும் புட்டம்',
      formCues: 'Feet shoulder-width apart. Keep chest tall, sit back into your heels, and lower until thighs are parallel to floor.',
      formCuesTa: 'தோள்களின் அளவுக்கு கால்களை வையுங்கள். மார்பை நிமிர்த்தி, நாற்காலியில் அமர்வது போல் உட்காருங்கள்.',
      reps: '10–12 reps x 3 sets',
    ),
    ExerciseGuide(
      id: 'pushups',
      title: 'Incline / Knee Push-Ups',
      titleTa: 'புஷ்-அப்ஸ் (Push-Ups)',
      imagePath: 'assets/images/pushups.jpg',
      category: 'Upper Body & Chest',
      targetMuscles: 'Chest, Shoulders, Triceps',
      targetMusclesTa: 'மார்பு, தோள்பட்டை, கைகள்',
      formCues: 'Hands aligned slightly wider than shoulders. Keep your spine in a straight plank line. Lower chest to floor and push up with control.',
      formCuesTa: 'கைகளை தோளுக்குக் கீழே நேராக வையுங்கள். உடலை நேர்க்கோட்டில் வைத்து, மார்பை தரை வரை இறக்கி மேலே தள்ளுங்கள்.',
      reps: '8–12 reps x 3 sets',
    ),
    ExerciseGuide(
      id: 'plank',
      title: 'Forearm Plank Hold',
      titleTa: 'பிளாங்க் ஹோல்ட் (Plank Hold)',
      imagePath: 'assets/images/plank.jpg',
      category: 'Core & Stability',
      targetMuscles: 'Abs, Obliques, Lower Back, Core',
      targetMusclesTa: 'வயிற்று தசைகள் மற்றும் முதுகு',
      formCues: 'Rest on elbows directly under shoulders. Squeeze glutes and abs tight. Do not let hips drop or arch up.',
      formCuesTa: 'முழங்கைகளில் எடையை வைத்து, உடலை நேர்க்கோட்டில் வையுங்கள். வயிற்றை இறுக்கி 30-45 வினாடிகள் நில்லுங்கள்.',
      reps: '20–45 seconds hold',
    ),
    ExerciseGuide(
      id: 'glute_bridge',
      title: 'Glute Bridges',
      titleTa: 'க்ளூட் பிரிட்ஜ் (Glute Bridges)',
      imagePath: 'assets/images/glute_bridge.jpg',
      category: 'Lower Body & Posture',
      targetMuscles: 'Glutes, Hamstrings, Lower Back',
      targetMusclesTa: 'புட்டம் மற்றும் கீழ் முதுகு',
      formCues: 'Lie on back with knees bent and feet flat. Drive through heels to lift hips toward ceiling. Squeeze glutes for 1 second at top.',
      formCuesTa: 'முதுகில் படுத்து முழங்கால்களை மடியுங்கள். இடுப்பை மேலே உயர்த்தி 1 வினாடி நிறுத்தி பின்னர் இறக்குங்கள்.',
      reps: '12–15 reps x 3 sets',
    ),
    ExerciseGuide(
      id: 'child_pose',
      title: 'Child’s Pose Mobility Stretch',
      titleTa: 'சைல்ட்ஸ் போஸ் ஸ்ட்ரெட்ச் (Child’s Pose)',
      imagePath: 'assets/images/child_pose.jpg',
      category: 'Cool-Down & Mobility',
      targetMuscles: 'Lats, Lower Back, Hips, Shoulders',
      targetMusclesTa: 'முதுகுத்தண்டு மற்றும் தோள்பட்டை தளர்வு',
      formCues: 'Kneel on mat, sit hips back on heels, and stretch arms forward on floor. Deep breaths to release all back tension.',
      formCuesTa: 'முழங்காலிட்டு, குதிகாலில் அமர்ந்து கைகளை முன்னோக்கி நீட்டி ஆழ்ந்து மூச்சு விடுங்கள்.',
      reps: '45–60 seconds hold',
    ),
  ];

  /// Find matching guides from user input or AI workout recommendations
  static List<ExerciseGuide> findMatching(String text) {
    final lower = text.toLowerCase();
    final matched = <ExerciseGuide>[];

    for (final guide in guides) {
      if (guide.id == 'squats' && (lower.contains('squat') || lower.contains('ஸ்குவாட்') || lower.contains('legs') || lower.contains('beginner') || lower.contains('workout') || lower.contains('பயிற்சி'))) {
        matched.add(guide);
      } else if (guide.id == 'pushups' && (lower.contains('push') || lower.contains('புஷ்') || lower.contains('chest') || lower.contains('upper') || lower.contains('beginner') || lower.contains('workout'))) {
        matched.add(guide);
      } else if (guide.id == 'plank' && (lower.contains('plank') || lower.contains('பிளாங்க்') || lower.contains('core') || lower.contains('abs') || lower.contains('beginner') || lower.contains('workout'))) {
        matched.add(guide);
      } else if (guide.id == 'glute_bridge' && (lower.contains('bridge') || lower.contains('glute') || lower.contains('பிரிட்ஜ்') || lower.contains('posture') || lower.contains('beginner') || lower.contains('workout'))) {
        matched.add(guide);
      } else if (guide.id == 'child_pose' && (lower.contains('child') || lower.contains('stretch') || lower.contains('ஸ்ட்ரெட்ச்') || lower.contains('cool-down') || lower.contains('mobility') || lower.contains('beginner') || lower.contains('workout'))) {
        matched.add(guide);
      }
    }

    if (matched.isEmpty && (lower.contains('workout') || lower.contains('routine') || lower.contains('exercise') || lower.contains('பயிற்சி') || lower.contains('beginner'))) {
      return guides;
    }

    return matched;
  }
}
