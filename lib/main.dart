import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppData.load();
  runApp(const WayKidsApp());
}

class WayKidsApp extends StatelessWidget {
  const WayKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Way Kids',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F7A4D),
        ),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}

class AppData {
  static int points = 120;
  static String childName = 'Адам';
  static String ageGroup = '7–9 лет';
  static bool profileCreated = false;
  static int get level {
  if (points >= 700) return 4;
  if (points >= 300) return 3;
  if (points >= 100) return 2;
  return 1;
}

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    points = prefs.getInt('points') ?? 120;
    childName = prefs.getString('childName') ?? 'Адам';
    ageGroup = prefs.getString('ageGroup') ?? '7–9 лет';
    profileCreated = prefs.getBool('profileCreated') ?? false;
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('points', points);
    await prefs.setString('childName', childName);
    await prefs.setString('ageGroup', ageGroup);
    await prefs.setBool('profileCreated', profileCreated);
  }

  static Future<void> addPoints(int value) async {
    points += value;
    await save();
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  final nameController = TextEditingController();

  void nextStep() {
    if (step == 1 && nameController.text.trim().isNotEmpty) {
      AppData.childName = nameController.text.trim();
      AppData.save();
    }

    if (step < 2) {
      setState(() {
        step++;
      });
    } else {
      AppData.profileCreated = true;
AppData.save();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
      );
    }
  }

  void selectAge(String age) {
    setState(() {
      AppData.ageGroup = age;
      AppData.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              if (step == 0) ...[
                const Text(
                  'Way Kids',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Развивающие задания для детей с пользой для всей семьи',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                    height: 1.35,
                  ),
                ),
              ],

              if (step == 1) ...[
                const Text(
                  'Как зовут ребенка?',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Например: Адам',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],

              if (step == 2) ...[
                const Text(
                  'Выберите возраст',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                AgeButton(
                  title: '4–6 лет',
                  selected: AppData.ageGroup == '4–6 лет',
                  onTap: () => selectAge('4–6 лет'),
                ),
                const SizedBox(height: 14),
                AgeButton(
                  title: '7–9 лет',
                  selected: AppData.ageGroup == '7–9 лет',
                  onTap: () => selectAge('7–9 лет'),
                ),
                const SizedBox(height: 14),
                AgeButton(
                  title: '10–12 лет',
                  selected: AppData.ageGroup == '10–12 лет',
                  onTap: () => selectAge('10–12 лет'),
                ),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: nextStep,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    backgroundColor: const Color(0xFF1F7A4D),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    step == 2 ? 'Перейти в приложение' : 'Продолжить',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AgeButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const AgeButton({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF6EF) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFF1F7A4D) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final screens = const [
  HomeScreen(),
  QuizScreen(),
  BalanceScreen(),
  PartnersScreen(),
  ProfileScreen(),
  AchievementsScreen(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
  NavigationDestination(
    icon: Icon(Icons.home),
    label: 'Главная',
  ),

  NavigationDestination(
    icon: Icon(Icons.quiz),
    label: 'Задания',
  ),

  NavigationDestination(
    icon: Icon(Icons.stars),
    label: 'Баллы',
  ),

  NavigationDestination(
    icon: Icon(Icons.store),
    label: 'Партнеры',
  ),

  NavigationDestination(
    icon: Icon(Icons.person),
    label: 'Профиль',
  ),

  NavigationDestination(
    icon: Icon(Icons.emoji_events),
    label: 'Достижения',
  ),
],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1F7A4D),
                    Color(0xFF2FA66A),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Way Kids',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ассаляму алейкум, ${AppData.childName} 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppData.ageGroup,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    title: '${AppData.points}',
                    subtitle: 'баллов',
                    icon: Icons.stars_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: InfoCard(
                    title: '3/5',
                    subtitle: 'цель дня',
                    icon: Icons.track_changes_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Категории',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const CategoryCard(
              title: 'Ислам',
              subtitle: 'Адаб, дуа, добрые поступки',
              icon: Icons.mosque_rounded,
            ),
            const SizedBox(height: 14),
            const CategoryCard(
              title: 'Логика',
              subtitle: 'Мышление и внимательность',
              icon: Icons.psychology_rounded,
            ),
            const SizedBox(height: 14),
            const CategoryCard(
              title: 'Математика',
              subtitle: 'Счет, задачи и примеры',
              icon: Icons.calculate_rounded,
            ),
            const SizedBox(height: 14),
            const CategoryCard(
              title: 'Финансовая грамотность',
              subtitle: 'Деньги, выбор и польза',
              icon: Icons.savings_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F4),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1F7A4D), size: 30),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const CategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE9EFE9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1F7A4D),
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuizQuestion {
  final String category;
  final String question;
  final List<String> answers;
  final String correctAnswer;

  const QuizQuestion({
    required this.category,
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String selectedCategory = 'Математика';
  int questionIndex = 0;
  String? selectedAnswer;
  bool answered = false;

  final List<QuizQuestion> questions = const [
    QuizQuestion(
      category: 'Ислам',
      question: 'Что нужно сказать перед едой?',
      answers: ['Бисмиллях', 'Спасибо', 'До свидания', 'Доброе утро'],
      correctAnswer: 'Бисмиллях',
    ),
    QuizQuestion(
      category: 'Ислам',
      question: 'Какой поступок считается добрым?',
      answers: ['Помочь родителям', 'Обидеть друга', 'Сломать игрушку', 'Кричать'],
      correctAnswer: 'Помочь родителям',
    ),
    QuizQuestion(
      category: 'Логика',
      question: 'Что лишнее: яблоко, банан, машина, груша?',
      answers: ['Яблоко', 'Банан', 'Машина', 'Груша'],
      correctAnswer: 'Машина',
    ),
    QuizQuestion(
      category: 'Логика',
      question: 'Продолжи ряд: 2, 4, 6, 8...',
      answers: ['9', '10', '11', '12'],
      correctAnswer: '10',
    ),
    QuizQuestion(
      category: 'Математика',
      question: 'У Али было 3 упаковки фиников. В каждой по 5. Сколько всего?',
      answers: ['8', '10', '15', '20'],
      correctAnswer: '15',
    ),
    QuizQuestion(
      category: 'Математика',
      question: 'Сколько будет 7 + 6?',
      answers: ['11', '12', '13', '14'],
      correctAnswer: '13',
    ),
    QuizQuestion(
      category: 'Финансовая грамотность',
      question: 'Что лучше сделать с частью денег?',
      answers: ['Сразу всё потратить', 'Сохранить часть', 'Потерять', 'Отдать незнакомцу'],
      correctAnswer: 'Сохранить часть',
    ),
    QuizQuestion(
      category: 'Финансовая грамотность',
      question: 'Что такое полезная покупка?',
      answers: ['То, что нужно', 'То, что просто яркое', 'То, что купил друг', 'То, что самое дорогое'],
      correctAnswer: 'То, что нужно',
    ),
  ];

  List<QuizQuestion> get filteredQuestions {
    return questions.where((q) => q.category == selectedCategory).toList();
  }

  QuizQuestion get currentQuestion {
    final list = filteredQuestions;
    return list[questionIndex % list.length];
  }

  void chooseCategory(String category) {
    setState(() {
      selectedCategory = category;
      questionIndex = 0;
      selectedAnswer = null;
      answered = false;
    });
  }

  void answer(String answer) {
    if (answered) return;

    setState(() {
      selectedAnswer = answer;
      answered = true;

      if (answer == currentQuestion.correctAnswer) {
        AppData.addPoints(5);
      }
    });
  }

  void nextQuestion() {
    setState(() {
      questionIndex++;
      selectedAnswer = null;
      answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedAnswer == currentQuestion.correctAnswer;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Задания',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryChip(
                    title: 'Ислам',
                    selected: selectedCategory == 'Ислам',
                    onTap: () => chooseCategory('Ислам'),
                  ),
                  CategoryChip(
                    title: 'Логика',
                    selected: selectedCategory == 'Логика',
                    onTap: () => chooseCategory('Логика'),
                  ),
                  CategoryChip(
                    title: 'Математика',
                    selected: selectedCategory == 'Математика',
                    onTap: () => chooseCategory('Математика'),
                  ),
                  CategoryChip(
                    title: 'Фин грамотность',
                    selected: selectedCategory == 'Финансовая грамотность',
                    onTap: () => chooseCategory('Финансовая грамотность'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6EF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                currentQuestion.question,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),

            const SizedBox(height: 26),

            ...currentQuestion.answers.map(
              (answerText) {
                final isSelected = selectedAnswer == answerText;
                final isRight = answerText == currentQuestion.correctAnswer;

                Color borderColor = Colors.transparent;
                Color backgroundColor = Colors.white;

                if (answered && isSelected && isRight) {
                  borderColor = Colors.green;
                  backgroundColor = const Color(0xFFEAF8EE);
                } else if (answered && isSelected && !isRight) {
                  borderColor = Colors.red;
                  backgroundColor = const Color(0xFFFFEEEE);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AnswerButton(
                    text: answerText,
                    backgroundColor: backgroundColor,
                    borderColor: borderColor,
                    onTap: () => answer(answerText),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            if (answered)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? const Color(0xFFEAF8EE)
                      : const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  isCorrect ? 'Молодец! +5 баллов' : 'Ничего страшного, попробуй следующее',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ),

            const SizedBox(height: 18),

            if (answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: nextQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    backgroundColor: const Color(0xFF1F7A4D),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Следующий вопрос',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(title),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFFEAF6EF),
        labelStyle: TextStyle(
          color: selected ? const Color(0xFF1F7A4D) : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AnswerButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  const AnswerButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = (AppData.points / 500).clamp(0.0, 1.0);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Баланс семьи',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Баллы начисляются за правильные ответы и активность ребенка',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 26),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F7A4D), Color(0xFF2FA66A)],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Доступно',
                    style: TextStyle(fontSize: 17, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppData.points} баллов',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Можно использовать у партнеров Way Kids',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F4),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Прогресс до награды',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(20),
                    backgroundColor: Colors.white,
                    color: const Color(0xFF1F7A4D),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${AppData.points}/500 баллов до следующего уровня',
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'История начислений',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            const BalanceHistoryItem(
              title: 'Математика',
              subtitle: 'Правильный ответ',
              points: '+5',
            ),
            const BalanceHistoryItem(
              title: 'Ислам',
              subtitle: 'Добрый поступок',
              points: '+5',
            ),
            const BalanceHistoryItem(
              title: 'Логика',
              subtitle: 'Задание выполнено',
              points: '+5',
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Text(
                'В тестовой версии баллы не являются деньгами. Позже их можно будет использовать у партнеров приложения.',
                style: TextStyle(fontSize: 15, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BalanceHistoryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String points;

  const BalanceHistoryItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9EFE9)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFEAF6EF),
            child: Icon(Icons.add_rounded, color: Color(0xFF1F7A4D)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F7A4D),
            ),
          ),
        ],
      ),
    );
  }
}

class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Партнеры',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Места, где семья сможет использовать баллы Way Kids',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            SizedBox(height: 26),

            PartnerCard(
              title: 'Исламская аптека',
              category: 'Здоровье и витамины',
              address: 'Грозный, центр',
              percent: 'до 20%',
              icon: Icons.local_pharmacy_rounded,
            ),
            SizedBox(height: 16),
            PartnerCard(
              title: 'Sunnah Market',
              category: 'Финики, мед, полезные продукты',
              address: 'Грозный',
              percent: 'до 15%',
              icon: Icons.storefront_rounded,
            ),
            SizedBox(height: 16),
            PartnerCard(
              title: 'Детский центр',
              category: 'Курсы и развитие',
              address: 'Грозный',
              percent: 'до 10%',
              icon: Icons.school_rounded,
            ),
            SizedBox(height: 16),
            PartnerCard(
              title: 'Книжный магазин',
              category: 'Книги для детей',
              address: 'Грозный',
              percent: 'до 15%',
              icon: Icons.menu_book_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class PartnerCard extends StatelessWidget {
  final String title;
  final String category;
  final String address;
  final String percent;
  final IconData icon;

  const PartnerCard({
    super.key,
    required this.title,
    required this.category,
    required this.address,
    required this.percent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE9EFE9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFF1F7A4D), size: 29),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(category, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 5),
                Text(address, style: const TextStyle(fontSize: 14, color: Colors.black45)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              percent,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9A6A00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  String selectedAge = AppData.ageGroup;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: AppData.childName);
  }

  Future<void> saveProfile() async {
    AppData.childName = nameController.text.trim().isEmpty
        ? 'Ребенок'
        : nameController.text.trim();

    AppData.ageGroup = selectedAge;
    AppData.profileCreated = true;

    await AppData.save();

    setState(() {});
    Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const MainScreen(),
  ),
);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Профиль сохранен'),
      ),
    );
  }

  Future<void> resetProfile() async {
    AppData.childName = 'Адам';
    AppData.ageGroup = '7–9 лет';
    AppData.points = 120;
    AppData.profileCreated = false;

    await AppData.save();

    setState(() {
      nameController.text = AppData.childName;
      selectedAge = AppData.ageGroup;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Профиль сброшен'),
      ),
    );
  }

  Widget ageOption(String age) {
    final selected = selectedAge == age;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAge = age;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF6EF) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? const Color(0xFF1F7A4D) : const Color(0xFFE9EFE9),
            width: 2,
          ),
        ),
        child: Text(
          age,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Профиль ребенка',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Здесь можно создать или изменить профиль ребенка',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 28),

            const Text(
              'Имя ребенка',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Например: Адам',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: Color(0xFFE9EFE9)),
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Возраст',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ageOption('4–6 лет'),
            ageOption('7–9 лет'),
            ageOption('10–12 лет'),

            const SizedBox(height: 26),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                  backgroundColor: const Color(0xFF1F7A4D),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Сохранить профиль',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: resetProfile,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                ),
                child: const Text(
                  'Сбросить профиль',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void goToApp(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainScreen(),
      ),
    );
  }

  void goToCreateProfile(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              const Text(
                'Way Kids',
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Развивающие задания для детей с пользой для всей семьи',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                  height: 1.35,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => goToApp(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    backgroundColor: const Color(0xFF1F7A4D),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Войти в существующий профиль',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => goToCreateProfile(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                  ),
                  child: const Text(
                    'Создать новый профиль',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  bool unlocked(int requiredPoints) {
    return AppData.points >= requiredPoints;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Достижения',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Уровень ребенка: ${AppData.level}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 28),

            AchievementCard(
              title: 'Первый шаг',
              subtitle: 'Набрать 20 баллов',
              unlocked: unlocked(20),
            ),

            const SizedBox(height: 14),

            AchievementCard(
              title: 'Любитель знаний',
              subtitle: 'Набрать 100 баллов',
              unlocked: unlocked(100),
            ),

            const SizedBox(height: 14),

            AchievementCard(
              title: 'Маленький ученый',
              subtitle: 'Набрать 300 баллов',
              unlocked: unlocked(300),
            ),

            const SizedBox(height: 14),

            AchievementCard(
              title: 'Мастер Way Kids',
              subtitle: 'Набрать 700 баллов',
              unlocked: unlocked(700),
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool unlocked;

  const AchievementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFFEAF6EF)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: unlocked
              ? const Color(0xFF1F7A4D)
              : const Color(0xFFE5E5E5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: unlocked
                  ? const Color(0xFF1F7A4D)
                  : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              unlocked
                  ? Icons.emoji_events_rounded
                  : Icons.lock_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}