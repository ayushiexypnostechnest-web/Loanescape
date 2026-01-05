import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/models/chat.dart';
import 'package:loan_app/theme/app_colors.dart';

class AiAssistant extends StatefulWidget {
  const AiAssistant({super.key});

  @override
  State<AiAssistant> createState() => _AiAssistantState();
}

class _AiAssistantState extends State<AiAssistant>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  bool showScrollButton = false;
  bool isTyping = false;
  bool isPaused = false;
  bool stopRequested = false;

  bool isThinking = false;

  final TextEditingController promptController = TextEditingController();

  static String apiKey = "AIzaSyBenG78uYeuADmNWX_gVfKmlBYHFiwsLxI";
  late final GenerativeModel model;
  final List<ModelMessage> prompt = [];
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(
      model: "gemini-2.5-flash-lite",
      apiKey: apiKey,
      systemInstruction: Content.text("""
You are Loanescape’s AI assistant.

Your job is to help users with questions related to:
- Loans
- Banking services
- Interest rates and EMIs
- Credit scores
- ATMs and basic financial guidance

### How to respond
- Speak naturally, like a knowledgeable financial assistant
- Keep answers clear and concise
- Change wording and sentence structure in every response
- Avoid repeating the same phrases or explanations
- Do not sound scripted, mechanical, or pre-written

### Identity
- If asked your name or who you are, reply naturally as Loanescape’s AI assistant
- Do not use phrases like “I am designed to”, “I am programmed to”, or similar technical wording

### Scope handling
- If a question is outside finance or banking:
  - Politely say you can’t help with that topic
  - Briefly mention you focus on financial matters
  - Invite the user to ask a finance-related question
  - Use different wording each time (do not repeat the same refusal message)

### Accuracy
- Provide information that is accurate and practical
- If something is unclear or uncertain, say so honestly
- Do not guess or invent financial details

### Goal
Make every response feel human, helpful, and trustworthy — like a real financial assistant.

      """),
    );
    _scrollController.addListener(() {
      final atBottom =
          _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50;

      if (showScrollButton == atBottom) {
        setState(() {
          showScrollButton = !atBottom;
        });
      }
    });
  }

  List<Content> _buildChatHistory() {
    return prompt.map((msg) {
      return Content.text(msg.message);
    }).toList();
  }

  Future<void> _typeResponse(String fullText) async {
    isTyping = true;
    isPaused = false;
    stopRequested = false;

    final index = prompt.length;

    setState(() {
      prompt.add(
        ModelMessage(isPrompt: false, message: "", time: DateTime.now()),
      );
    });

    String current = "";

    for (int i = 0; i < fullText.length; i++) {
      if (stopRequested) break;

      current += fullText[i];

      if (!mounted) return;

      setState(() {
        prompt[index] = ModelMessage(
          isPrompt: false,
          message: current,
          time: prompt[index].time,
        );
      });

      await Future.delayed(Duration(milliseconds: 20));
    }

    setState(() {
      isTyping = false;
      isPaused = false;
      stopRequested = false;
    });
  }

  Future<void> sendMessage() async {
    final message = promptController.text.trim();
    if (message.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      promptController.clear();
      prompt.add(
        ModelMessage(isPrompt: true, message: message, time: DateTime.now()),
      );
      isThinking = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    });

    try {
      final chatHistory = _buildChatHistory();

      final response = await model.generateContent(chatHistory);

      final output = response.text ?? "I couldn't understand that.";

      setState(() => isThinking = false);

      await _typeResponse(output);
    } catch (e) {
      setState(() {
        isThinking = false;

        prompt.add(
          ModelMessage(
            isPrompt: false,
            message:
                "⚠️ Unable to fetch response. Please check your internet connection.",
            time: DateTime.now(),
          ),
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Unable to fetch response. Please check your internet connection.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      debugPrint("Gemini error: $e");
    }
  }

  DateTime? _lastBackPressed;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // return WillPopScope(
    //   onWillPop: () async {
    //     final now = DateTime.now();

    //     if (_lastBackPressed == null ||
    //         now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
    //       _lastBackPressed = now;

    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: const Text("Press back again to exit"),
    //           duration: const Duration(seconds: 2),
    //           behavior: SnackBarBehavior.floating,
    //           margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    //           shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.circular(12),
    //           ),
    //         ),
    //       );

    //       return false;
    //     }

    //     return true;
    //   },
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isDark
                  ? 'assets/images/dark_ai.png'
                  : 'assets/images/light_ai.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: prompt.isEmpty
                    ? _emptyState(context)
                    : Container(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                Theme.of(context).brightness == Brightness.dark
                                    ? 'assets/images/ai_chat_screen.png'
                                    : 'assets/images/ai_chat_screen_light.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppDarkColors.scaffold.withOpacity(
                                            0.30,
                                          )
                                        : AppColors.white,
                                    border: isDark
                                        ? Border(
                                            bottom: BorderSide(
                                              color: const Color(
                                                0xFF757575,
                                              ).withOpacity(0.20),
                                              width: 1,
                                            ),
                                          )
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? Color(
                                                0xff000000,
                                              ).withOpacity(0.25)
                                            : AppColors.shadow.withOpacity(
                                                0.12,
                                              ),
                                        blurRadius: isDark ? 20 : 2,
                                        spreadRadius: isDark ? -20 : 0,
                                        offset: isDark
                                            ? Offset(0, 12)
                                            : Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: SafeArea(
                                    bottom: false,
                                    child: Center(
                                      child: Text(
                                        "AI Assistant",
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppDarkColors.white
                                              : AppColors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Stack(
                                    children: [
                                      ListView.builder(
                                        controller: _scrollController,
                                        padding: EdgeInsets.only(
                                          top: 20,
                                          bottom: 120,
                                        ),
                                        itemCount:
                                            prompt.length +
                                            (isThinking ? 1 : 0),
                                        itemBuilder: (ctx, index) {
                                          if (isThinking &&
                                              index == prompt.length) {
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 8,
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    height: 16,
                                                    width: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    "Thinking...",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          final message = prompt[index];
                                          return userPrompt(
                                            isPrompt: message.isPrompt,
                                            message: message.message,
                                            date: DateFormat(
                                              'hh:mm a',
                                            ).format(message.time),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),

              // Padding(
              //   padding: EdgeInsets.only(
              //     left: 15,
              //     right: 15,
              //     bottom: 15,
              //     top: 15,
              //   ),
              //   child: Container(
              //     constraints: BoxConstraints(maxHeight: 140),
              //     padding: EdgeInsets.fromLTRB(14, 8, 8, 8),
              //     decoration: BoxDecoration(
              //       color: Theme.of(context).brightness == Brightness.dark
              //           ? AppDarkColors.textfeild
              //           : Color(0xffEEF1F4),

              //       borderRadius: BorderRadius.circular(24),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.12),
              //           blurRadius: 4,
              //           offset: Offset(0, 0),
              //         ),
              //       ],
              //     ),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.end,
              //       children: [
              //         Expanded(
              //           child: Padding(
              //             padding: EdgeInsets.only(bottom: 7),
              //             child: TextField(
              //               controller: promptController,
              //               minLines: 1,
              //               maxLines: null,
              //               keyboardType: TextInputType.multiline,
              //               textInputAction: TextInputAction.send,
              //               onSubmitted: (_) {
              //                 if (!isTyping) {
              //                   sendMessage();
              //                 }
              //               },
              //               cursorColor:
              //                   Theme.of(context).brightness == Brightness.dark
              //                   ? AppColors.white
              //                   : AppColors.black,
              //               style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
              //               decoration: InputDecoration(
              //                 hintText: "Ask anything...",
              //                 hintStyle: TextStyle(fontSize: 14, height: 1.35),
              //                 border: InputBorder.none,
              //                 isDense: true,
              //                 contentPadding: EdgeInsets.zero,
              //               ),
              //             ),
              //           ),
              //         ),

              //         SizedBox(width: 6),

              //         /// SEND / STOP BUTTON
              //         GestureDetector(
              //           onTap: () {
              //             if (isTyping) {
              //               setState(() => stopRequested = true);
              //             } else {
              //               sendMessage();
              //             }
              //           },
              //           child: Container(
              //             height: 38,
              //             width: 38,
              //             decoration: BoxDecoration(
              //               color: Color(0xff7F8897),
              //               shape: BoxShape.circle,
              //             ),
              //             child: Center(
              //               child: isTyping
              //                   ? Icon(
              //                       Icons.stop,
              //                       size: 20,
              //                       color:
              //                           Theme.of(context).brightness ==
              //                               Brightness.dark
              //                           ? AppColors.black
              //                           : AppColors.white,
              //                     )
              //                   : SvgPicture.asset(
              //                       'assets/images/send.svg',
              //                       height: 18,
              //                       color:
              //                           Theme.of(context).brightness ==
              //                               Brightness.dark
              //                           ? AppColors.black
              //                           : AppColors.white,
              //                     ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
          Positioned(
            left: 15,
            right: 15,
            bottom: 15,
            child: SafeArea(
              child: Container(
                constraints: BoxConstraints(maxHeight: 140),
                padding: EdgeInsets.fromLTRB(14, 8, 8, 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppDarkColors.textfeild.withOpacity(0.92)
                      : Color(0xffEEF1F4).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: promptController,
                        minLines: 1,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => isTyping ? null : sendMessage(),
                        decoration: InputDecoration(
                          hintText: "Ask anything...",
                          contentPadding: EdgeInsets.only(bottom: 7),
                          hintStyle: TextStyle(fontFamily: 'Lato'),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => isTyping
                          ? setState(() => stopRequested = true)
                          : sendMessage(),
                      child: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: Color(0xff7F8897),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isTyping
                              ? Icon(Icons.stop, size: 20, color: Colors.white)
                              : SvgPicture.asset(
                                  'assets/images/send.svg',
                                  height: 18,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (showScrollButton)
            Positioned(
              right: 16,
              bottom: 100,
              child: GestureDetector(
                onTap: _scrollToBottom,
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Color(0xFF1E1E1E)
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.25)
                            : Colors.black.withOpacity(0.25),
                        blurRadius: 4,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 22,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget userPrompt({
    required bool isPrompt,
    required String message,
    required String date,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: isPrompt ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric().copyWith(
            left: isPrompt ? 40 : 15,
            right: isPrompt ? 15 : 30,
          ),

          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? (isPrompt ? AppDarkColors.message : AppDarkColors.response)
                : (isPrompt ? const Color(0xffCFDFFF) : Colors.white),

            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isPrompt ? 18 : 4),
              topRight: Radius.circular(isPrompt ? 4 : 18),
              bottomRight: const Radius.circular(18),
              bottomLeft: const Radius.circular(18),
            ),

            border: Border.all(
              width: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.10)
                  : Colors.grey.shade300,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 0),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(right: isPrompt ? 42 : 0),
                child: isPrompt
                    ? Text(
                        message,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : const Color(0xff001230),
                        ),
                      )
                    : MarkdownBody(
                        data: message,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontSize: 14,
                            height: 1.6,

                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontFamily: 'Lato',
                          ),
                          h1: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          h2: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          h3: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          listBullet: const TextStyle(fontSize: 15),
                          strong: const TextStyle(fontWeight: FontWeight.bold),
                          blockquote: TextStyle(
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                          code: TextStyle(
                            backgroundColor: Colors.grey.shade200,
                            fontFamily: 'Lato',
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),

              Text(
                date,
                style: TextStyle(
                  fontSize: 8,
                  color: isDark
                      ? Colors.white
                      : (isPrompt ? const Color(0xff001230) : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _emptyState(BuildContext context) {
  return Stack(
    children: [
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/ai_robot.png', height: 165),
            SizedBox(height: 20),

            Text(
              "How can I help?",
              style: TextStyle(
                fontSize: 40,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppDarkColors.white
                    : AppColors.primary,
              ),
            ),
            SizedBox(height: 8),

            Text(
              "Ask Anything About Your Loan, Plan EMIs,\nAnd Make Smarter Payments.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppDarkColors.white
                    : AppColors.primary,
                fontFamily: 'Lato',
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
