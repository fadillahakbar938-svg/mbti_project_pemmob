import 'package:flutter/material.dart';
import 'services/supabase_service.dart';


class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  List<Map<String, dynamic>> questions = [];

  bool isLoading = true;
  Future<void> loadQuestions() async {
    final data =
        await SupabaseService.instance.getQuestions();

    setState(() {

      questions = data;

      answers = List.filled(
        data.length,
        0,
      );

      isLoading = false;

    });
  }

@override
void initState() {
  super.initState();

  loadQuestions();
}

  //kumpulan variabel
  List<int> answers = [];
  int selectedScore = 0;
  int currentQuestion = 0;



  //function pop up dialog untuk konfirmasi sebelum keluar dari tes
  Future<void> showExitDialog() async {

  final result = await showDialog<bool>(
    context: context,

    builder: (context) {
      return AlertDialog(

        title: const Text(
          "Keluar Tes?"
        ),

        content: const Text(
          "Apakah Anda yakin ingin keluar dari tes MBTI? Progress yang belum disimpan akan hilang."
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Batal"),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Keluar"),
          ),

        ],
      );
    },
  );

  if(result == true){

    Navigator.pushReplacementNamed(
      context,
      '/home',
    );

  }
}

//function untuk back ke soal sebelumnya
void previousQuestion() {

  if(currentQuestion > 0){

    setState(() {
      currentQuestion--;
    });

  }

}

  final List<Map<String, dynamic>> scores = [
  {
    "num": "1",
    "label": "Strongly\nDisagree"
  },
  {
    "num": "2",
    "label": "Disagree"
  },
  {
    "num": "3",
    "label": "Slightly\nDisagree"
  },
  {
    "num": "4",
    "label": "Neutral"
  },
  {
    "num": "5",
    "label": "Slightly\nAgree"
  },
  {
    "num": "6",
    "label": "Agree"
  },
  {
    "num": "7",
    "label": "Strongly\nAgree"
  },
];

//function untuk next ke soal berikutnya

  void nextQuestion(){

    if(currentQuestion <
        questions.length-1){

      setState(() {
        currentQuestion++;
        selectedScore =
            answers[currentQuestion];
      });

    }else{

      // pindah ke hasil MBTI
      print("Tes selesai");
    }

  }

  //function untuk menyimpan jawaban dan lanjut ke soal berikutnya
  Future<void> saveAnswer() async {

  if(selectedScore == 0){

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Pilih jawaban terlebih dahulu"
        ),
      ),
    );

    return;
  }

  // simpan jawaban
  answers[currentQuestion] = selectedScore;

  final user =
      SupabaseService
          .instance
          .currentUser;

  if(user == null){

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Sesi login telah berakhir, silakan login kembali."
        ),
      ),
    );

    return;
  }


  await SupabaseService.instance.saveAnswer(
    userId: user.id,
    questionId:
        questions[currentQuestion]["id"],
    answerValue: selectedScore,
  );

  nextQuestion();
}

//function untuk menampilkan daftar soal
void showQuestionList() {

  showModalBottomSheet(

    context: context,

    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25),
      ),
    ),

    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              const Text(
                "Daftar Soal",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: GridView.builder(
                  itemCount: questions.length,

                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 700 ? 10 : 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),

                  itemBuilder: (context, index) {

                    bool answered =
                        answers[index] != 0;

                    return GestureDetector(

                      onTap: () {

                        Navigator.pop(context);

                        setState(() {

                          currentQuestion =
                              index;

                          selectedScore =
                              answers[index];

                        });
                      },

                      child: Container(

                        decoration: BoxDecoration(

                          color: index ==
                                  currentQuestion
                              ? const Color(0xffA162C5)
                              : answered
                                  ? Colors.green
                                  : Colors.grey.shade300,

                          borderRadius:
                              BorderRadius.circular(10),
                        ),

                        child: Center(
                          child: Text(

                            "${index + 1}",

                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                                  fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    if(isLoading){
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(

      backgroundColor: const Color(0xffF4EFEB),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

                   /// TOP BAR
                    Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  /// LEFT BUTTONS
                  Row(
                    children: [

                      /// EXIT TEST
                      GestureDetector(
                        onTap: showExitDialog,

                        child: Container(
                          padding: const EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 4,
                                color: Colors.black12,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),

                          child: const Icon(
                            Icons.close,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      /// PREVIOUS QUESTION
                      GestureDetector(
                        onTap: currentQuestion == 0
                            ? null
                            : previousQuestion,

                        child: Container(
                          padding: const EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: currentQuestion == 0
                                ? Colors.grey.shade200
                                : Colors.white,

                            borderRadius:
                                BorderRadius.circular(30),

                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Colors.black12,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),

                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,

                            color: currentQuestion == 0
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                    /// QUESTION NUMBER
                    Text(
                      "${currentQuestion + 1}/${questions.length}",

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),

                    /// SKIP BUTTON
                    GestureDetector(
                      onTap: nextQuestion,

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 4,
                              color: Colors.black12,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),

                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            color: Color(0xffA162C5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


              const SizedBox(height: 20),

              /// PROGRESS BAR
              Row(
                children: List.generate(
                  questions.length,
                  (index) => Expanded(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 2),

                      height: 8,

                      decoration: BoxDecoration(
                        color: index <= currentQuestion
                            ? Color(0xffA162C5)
                            : Color(0xffE7CFF2),

                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// LIST QUESTIONS
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  GestureDetector(
                    onTap: showQuestionList,

                    child: Container(
                      padding: const EdgeInsets.all(10),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(15),

                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 3,
                            color: Colors.black12,
                          )
                        ],
                      ),

                      child: const Icon(
                        Icons.list_alt_rounded,
                        color: Color(0xffA162C5),
                      ),
                    ),
                  ),
                ],
              ),
            

              const SizedBox(height: 20),

              /// QUESTION CARD
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(30),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0,4),
                      )
                    ],
                  ),

                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      Text(
                        questions[currentQuestion]["question"],

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          height: 1.7,
                        ),
                      ),

                      SizedBox(height: 30),

                      Text(
                        "Rate from 1 (strongly disagree) to 7 (strongly agree)",

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25),

              /// SCORE
              Row(
  children: List.generate(
    scores.length,
    (index) {

      bool selected =
          selectedScore == index + 1;

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),

          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedScore = index + 1;
              });
            },

            child: Container(
              height: 80,

              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xffA162C5)
                    : Colors.white,

                borderRadius:
                    BorderRadius.circular(12),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3,
                  )
                ],
              ),

              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Text(
                    scores[index]["num"],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color: selected
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    scores[index]["label"],
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 7,
                      color: selected
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  ),
),

              SizedBox(height: 25),

              /// NEXT BUTTON
              GestureDetector(
              onTap: saveAnswer,

              child: Container(
                height: 60,
                width: double.infinity,

                decoration: BoxDecoration(
                  color: const Color(0xffA162C5),
                  borderRadius: BorderRadius.circular(15),
                ),

                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    Text(
                      "Simpan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(width: 15),

                    Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            )

            ],
          ),
        ),
      ),
    );
  }
}