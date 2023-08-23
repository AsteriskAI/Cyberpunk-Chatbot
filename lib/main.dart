import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MainApp());
}

const String apiKey = 'YOUR-API-KEY';
const String apiUrl = 'YOUR-SERVICE-ENDPOINT';

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FullScreenImage(),
      ),
    );
  }
}

class FullScreenImage extends StatefulWidget {
  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  final List<String> conversation = [];
  final ScrollController _scrollController = ScrollController();

  TextEditingController _textEditingController = TextEditingController();
  bool isAIReplying = false;

  void _clearChat() {
    setState(() {
      conversation.clear();
    });
  }

  void _handleSubmitted(String text) async {
    setState(() {
      conversation.add(text);
      _textEditingController.clear();
      isAIReplying = true;
    });

    _scrollToBottom();

    final headers = {
      'Content-Type': 'application/json',
    };

    final prompt = {
      "prompt": {
        "text":
            "You are Pilar: A foul-mouthed techie and a member of Maine'\''s crew. You are also Rebecca'\''s older brother. \nYour goal is to simulate being Pilar, from the Cyberpunk Edgerunner anime series.\n\nThe setting is: Cyberpunk: Edgerunners is set in Night City, a self-reliant metropolis located in the Free State of California that suffers from extensive corruption, cybernetic addiction, and gang violence. The city is split into six districts, each of which has its own precise living requirements, and is controlled by several megacorporations, including Arasaka and its rival Militech. YOU, however, are located in Santo Domingo, the oldest, poorest, and most industrial district of Night City. Your job is to help new comers and settle in and answer all their doubts as Pilar\n\nThe plot goes along like this : In a dystopia overrun by corruption, crime, and cybernetic implants, an impulsive but talented street kid named David, after losing everything he has in a drive-by shooting, makes the choice to survive on the wrong side of the law as an \"edgerunner\": a high-tech, black-market mercenary also known as a \"cyberpunk\".  \nYou are talking to David.\nDo not write in place of David. You are Pilar. UNDERSTAND YOU CAN ONLY TALK ONCE, YOU ARE NOT ALLOWED TO FORM ANY DIALOGUES. NOR SHALL YOU MENTION YOURSELF\nDavid: " +
                text +
                " \nPilar: "
      },
      "temperature": 0.35,
      "top_k": 40,
      "top_p": 0.95,
      "candidate_count": 1,
      "max_output_tokens": 1024,
      "stop_sequences": [],
      "safety_settings": [
        {"category": "HARM_CATEGORY_DEROGATORY", "threshold": 4},
        {"category": "HARM_CATEGORY_TOXICITY", "threshold": 4},
        {"category": "HARM_CATEGORY_VIOLENCE", "threshold": 4},
        {"category": "HARM_CATEGORY_SEXUAL", "threshold": 4},
        {"category": "HARM_CATEGORY_MEDICAL", "threshold": 4},
        {"category": "HARM_CATEGORY_DANGEROUS", "threshold": 4}
      ]
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(prompt),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData.containsKey('candidates') &&
          responseData['candidates'].length > 0) {
        final generatedText = responseData["candidates"][0]["output"];
        setState(() {
          conversation.add(generatedText);
          isAIReplying = false;
        });
        _scrollToBottom();
        return;
      }
      print('Invalid response from API');
    } else {
      print('Error: ${response.statusCode}');
      print('Response Body: ${response.body}');
      setState(() {
        isAIReplying = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/cyberpunk.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Welcome to Cyberpunk Cityscape',
              style: TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.4),
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                width: 540,
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                height: 450,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: conversation.length,
                        itemBuilder: (context, index) {
                          final message = conversation[index];
                          final isUserMessage = index % 2 == 0;

                          Color backgroundColor = isUserMessage
                              ? Color.fromARGB(227, 241, 162, 230)
                              : Color.fromARGB(255, 212, 89, 212);

                          Color textColor = Colors.white;

                          return Align(
                            alignment: isUserMessage
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(top: 20),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: backgroundColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: backgroundColor.withOpacity(0.4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Text(
                                message,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      color: backgroundColor.withOpacity(0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textEditingController,
                              onSubmitted:
                                  isAIReplying ? null : _handleSubmitted,
                              enabled: !isAIReplying,
                              decoration: InputDecoration(
                                hintText: 'Enter your message...',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: isAIReplying
                                ? CircularProgressIndicator()
                                : Icon(Icons.send, color: Colors.white),
                            onPressed: isAIReplying
                                ? null
                                : () {
                                    if (_textEditingController
                                        .text.isNotEmpty) {
                                      _handleSubmitted(
                                          _textEditingController.text);
                                    }
                                  },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                            ),
                            onPressed: _clearChat,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
