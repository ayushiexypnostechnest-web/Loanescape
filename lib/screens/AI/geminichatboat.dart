import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/models/chat.dart';
import 'package:loan_app/models/chat_storage.dart';
import 'package:loan_app/models/loan_model.dart';
import 'package:loan_app/theme/app_colors.dart';
import 'package:loan_app/utils/loan_calculator.dart';

class Geminichatboat extends StatefulWidget {
  final LoanModel loan;

  const Geminichatboat({super.key, required this.loan});

  @override
  State<Geminichatboat> createState() => _GeminichatboatState();
}

class _GeminichatboatState extends State<Geminichatboat> {
  final ScrollController _scrollController = ScrollController();
  bool showScrollButton = false;

  bool isTyping = false;
  bool isPaused = false;
  bool stopRequested = false;

  bool isThinking = false;

  final TextEditingController promptController = TextEditingController();

  static const String apiKey = "AIzaSyCxSfPcEEaT989HhNSratlc22FXRcdIWr8";
  late final GenerativeModel model;

  List<ModelMessage> get prompt => ChatStorage().messages;
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  //PROMPT FOR LOAN
  String _buildLoanContext() {
    final loan = widget.loan;

    return """
USER LOAN DATA (SOURCE OF TRUTH):

Loan Name: ${loan.name}
Loan Type: ${loan.type}

Principal Amount: ₹${loan.amount}
Interest Rate (Current): ${loan.rate}% per annum
Loan Duration: ${loan.durationYears} years
Monthly EMI: ₹${loan.emi}

Loan Start Date: ${loan.startMonthYear}
Paid EMIs: ${loan.paidEmi}
EMI Reminder Enabled: ${loan.reminder}

Interest Rate Changes:
${loan.rateChanges.isEmpty ? "No rate changes" : loan.rateChanges.map((e) => "- ${e['monthYear']} → ${e['rate']}%").join("\n")}

RULES FOR AI:
- Use ONLY the above loan data
- Perform calculations only if user asks
- Explain answers clearly in simple language
- Do not assume missing data
""";
  }

  @override
  void initState() {
    super.initState();

    model = GenerativeModel(
      model: "gemini-2.5-flash-lite",
      apiKey: apiKey,
      systemInstruction: Content.text(""" 
    Prompt for Loan Application AI:

---
Context: You are an AI designed to assist users with loan-related inquiries. Your goal is to provide clear, accurate, and helpful answers regarding loans, including aspects such as EMIs, interest rates, loan terms, and repayment strategies.

Instructions:

1. User Inquiry Handling:
   - Listen carefully to the user's question about loans.
   - Identify key terms such as "EMI," "interest rate," "loan amount," "tenure," and "repayment."

2. Answer Structure:
   - Provide a concise answer that directly addresses the user's query.
   - Use simple language and avoid jargon to ensure clarity.
   - If applicable, provide examples or scenarios to illustrate your points.

3. Key Concepts to Include:
   - EMI (Equated Monthly Installment): Explain how reducing EMI may increase the total interest paid over the loan term.
   -Interest Rate: Clarify the relationship between interest rates and EMI; if the interest rate increases, the EMI may also increase unless the loan term is extended.
   - Loan Tenure: Discuss how extending the loan tenure can lower EMI but may increase the overall interest cost.
   - Prepayment Options:** Describe how prepaying a loan can reduce the interest burden and lower total repayment.

4. Example Questions to Respond To:
   - "What happens to my EMI if I increase my loan tenure?"
   - "How does reducing my EMI affect my total interest payments?"
   - "Can I negotiate my interest rate after securing a loan?"
   - "If I make a prepayment, how will it affect my loan balance and interest?"

5. Follow-Up Questions:
   - Encourage users to ask for further clarification or additional questions related to their loan situation.
   - Suggest exploring different scenarios based on user inputs for a better understanding of loan dynamics.

---

End of Prompt
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
      ChatStorage().messages = prompt;
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
        ChatStorage().messages = prompt;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      await Future.delayed(const Duration(milliseconds: 20));
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
    // Close the keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      promptController.clear();
      prompt.add(
        ModelMessage(isPrompt: true, message: message, time: DateTime.now()),
      );
      ChatStorage().messages = prompt;
      isThinking = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    try {
      final response = await model.generateContent([
        Content.text(_buildLoanContext()),
        ..._buildChatHistory(),
        Content.text(message),
      ]);

      final output = response.text ?? "No response";

      setState(() => isThinking = false);

      await _typeResponse(output);
    } catch (e) {
      setState(() {
        isThinking = false;

        // Add a failed AI response bubble
        prompt.add(
          ModelMessage(
            isPrompt: false,
            message:
                "⚠️ Unable to fetch response. Please check your internet connection.",
            time: DateTime.now(),
          ),
        );

        // Auto-scroll to show error bubble
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Unable to fetch response. Please check your internet connection.",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      debugPrint("Gemini error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppDarkColors.scaffold
          : AppColors.scaffold,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 144),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(bottom: 20, left: 12),
                    itemCount: prompt.length + 1 + (isThinking ? 1 : 0),
                    itemBuilder: (ctx, index) {
                      if (index == 0) {
                        return _welcomeMessage(widget.loan);
                      }

                      if (isThinking && index == prompt.length + 1) {
                        return Row(
                          children: const [
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Thinking...",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Lato',
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        );
                      }

                      return _messageBubble(prompt[index - 1]);
                    },
                  ),
                ),
                _inputBar(),
              ],
            ),
          ),
          if (showScrollButton)
            Positioned(
              right: 16,
              bottom: 120,
              child: GestureDetector(
                onTap: _scrollToBottom,
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.25)
                            : Colors.black.withOpacity(0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 0),
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

          _header(),
        ],
      ),
    );
  }

  Widget _inputBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppDarkColors.scaffold.withOpacity(0.30)
            : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: isDark ? 5 : 4,
          ),
        ],
        border: isDark
            ? Border(
                top: BorderSide(
                  color: const Color(0xFF757575).withOpacity(0.20),
                  width: 1,
                ),
              )
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppDarkColors.textfeild : const Color(0xFFEEF1F4),

          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (!isTyping) {
                      sendMessage();
                    }
                  },
                  controller: promptController,
                  minLines: 1,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  cursorColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.black,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontFamily: 'Lato',
                  ),
                  decoration: const InputDecoration(
                    hintText: "Ask anything...",
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            GestureDetector(
              onTap: sendMessage,
              child: Container(
                height: 36,
                width: 36,
                decoration: const BoxDecoration(
                  color: Color(0xff7F8897),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset('assets/images/send.svg', height: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 134,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppDarkColors.scaffold.withOpacity(0.30)
            : AppColors.scaffold,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 2,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppDarkColors.white
                          : AppColors.primary,
                    ),

                    Text(
                      "Loan Information",
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppDarkColors.white
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Ask AI",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lato',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppDarkColors.white
                      : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcomeMessage(LoanModel loan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double emiAmount = double.tryParse(loan.emi.toString()) ?? 0;

    final int totalMonths = (int.tryParse(loan.durationYears) ?? 0) * 12;

    final int remainingEmis = totalMonths - loan.paidEmi;

    final DateTime nextEmiDate = LoanCalculator.getNextEmiDate(
      loan.startMonthYear,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppDarkColors.searchbar
                    : AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(2),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi 👋",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lato',
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppDarkColors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "I'm reviewing your ${loan.type ?? 'Loan'} of "
                    "₹${loan.amount.toStringAsFixed(0)}.\n\n"
                    "You're paying ₹${emiAmount.toStringAsFixed(0)} EMI, "
                    "with $remainingEmis EMIs remaining.\n"
                    "Your next EMI is due on "
                    "${LoanCalculator.formatDate(nextEmiDate)}.\n\n"
                    "How can I help you today?",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Lato',
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppDarkColors.white
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              height: 25,
              width: 25,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: SvgPicture.asset(
                isDark
                    ? "assets/images/awesome_dark.svg"
                    : "assets/images/awesome.svg",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(ModelMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isPrompt;

    // For AI response, use welcome bubble style
    final responseBubble = !isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        children: [
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: IntrinsicWidth(
              child: Container(
                margin: EdgeInsets.symmetric().copyWith(
                  left: isUser ? 40 : 30,
                  right: isUser ? 15 : 20,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: responseBubble
                      ? (isDark ? AppDarkColors.searchbar : AppColors.white)
                      : (isDark
                            ? AppDarkColors.message
                            : const Color(0xffCFDFFF)),
                  borderRadius: responseBubble
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                          bottomLeft: Radius.circular(2),
                        )
                      : BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(4),
                          bottomRight: const Radius.circular(18),
                          bottomLeft: const Radius.circular(18),
                        ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: isUser ? 42 : 0),
                      child: isUser
                          ? Text(
                              message.message,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xff001230),
                              ),
                            )
                          : MarkdownBody(
                              data: message.message,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
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
                                strong: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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
                      DateFormat('hh:mm a').format(message.time),

                      style: TextStyle(
                        fontSize: 8,
                        color: isDark
                            ? Colors.white
                            : (isUser
                                  ? const Color(0xff001230)
                                  : Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // AWESOME ICON FOR AI RESPONSES
          if (responseBubble)
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                height: 25,
                width: 25,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: SvgPicture.asset(
                  isDark
                      ? "assets/images/awesome_dark.svg"
                      : "assets/images/awesome.svg",
                ),
              ),
            ),
        ],
      ),
    );
  }
}
