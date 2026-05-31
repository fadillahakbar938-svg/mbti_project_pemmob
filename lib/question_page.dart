import 'package:flutter/material.dart';
import '../data/mbti_questions.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {

  int selectedScore = 0;

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

  int currentQuestion = 0;

  void nextQuestion(){

    if(currentQuestion <
        questions.length-1){

      setState(() {
        currentQuestion++;
      });

    }else{

      // pindah ke hasil MBTI
      print("Tes selesai");
    }

  }

  @override
  Widget build(BuildContext context) {
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
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Colors.black12,
                          offset: Offset(0,3),
                        )
                      ],
                    ),

                    child: Icon(
                      Icons.arrow_back,
                    ),
                  ),

                  Text(
                     "${currentQuestion+1}/${questions.length}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Colors.black12,
                          offset: Offset(0,3),
                        )
                      ],
                    ),

                    child: Text(
                      "skip",
                      style: TextStyle(
                        color: Color(0xffA162C5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// PROGRESS BAR
              Row(
                children: List.generate(
                  25,
                  (index) => Expanded(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 2),

                      height: 8,

                      decoration: BoxDecoration(
                        color: index == 0
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

              /// CATEGORY
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10),

                decoration: BoxDecoration(
                  color: Color(0xffEEDCF4),
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Text(
                  "${questions[currentQuestion]["category"]}",
                  style: TextStyle(
                    color: Color(0xffA162C5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
              onTap: nextQuestion,

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
                      "Next",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(width: 15),

                    Icon(
                      Icons.arrow_forward,
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