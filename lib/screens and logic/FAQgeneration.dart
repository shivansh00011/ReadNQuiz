import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pdf_text/pdf_text.dart';
class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  String? selectedAnswer;
  bool isAnswered = false;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  bool get isCorrect => selectedAnswer == correctAnswer;
}

class QuizResult {
  final int score;
  final int totalQuestions;
  final List<QuizQuestion> questions;
  final List<String> improvementAreas;

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.questions,
    required this.improvementAreas,
  });
}
class PDFUploadScreen extends StatefulWidget {
  const PDFUploadScreen({super.key});

  @override
  State<PDFUploadScreen> createState() => _PDFUploadScreenState();
}

class _PDFUploadScreenState extends State<PDFUploadScreen> {
    String? _extractedText;
  bool _isLoading = false;
  bool _isGeneratingFAQ = false;
  bool _isGeneratingQuiz = false;
  bool _showingQuiz = false;
  List<Map<String, dynamic>> _faqList = [];
  List<QuizQuestion> _quizQuestions = [];
  QuizResult? _quizResult;
  String _errorMessage = '';
 

  final String geminiApiKey = 'YOUR_GEMINI_API_KEY';

  Future<void> _pickPDFAndExtractText() async {
    setState(() {
      _isLoading = true;
      _extractedText = null;
      _faqList = [];
      _errorMessage = '';
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        PDFDoc doc = await PDFDoc.fromFile(file);
        String text = await doc.text;

        setState(() {
          _extractedText = text;
          _isLoading = false;
        });

        await _generateFAQsFromText(text);
      } else {
        setState(() {
          _isLoading = false;
          _extractedText = "No file selected.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error processing PDF: $e";
      });
      print("PDF processing error: $e");
    }
  }

 Future<void> _generateFAQsFromText(String text) async {
  setState(() {
    _isGeneratingFAQ = true;
    _errorMessage = '';
  });

  try {
    final prompt = '''
Generate 5 of the most critical and important FAQs from this text. Each answer should be detailed and comprehensive (at least 3-4 sentences). Focus on the main concepts, key findings, and important details.

Requirements:
1. Questions should focus on the most important aspects only
2. Answers must be detailed and thorough
3. Include specific examples or data from the text when relevant
4. Explain concepts clearly and completely
5. Each answer should be at least 3-4 sentences long

Return ONLY a JSON array in exactly this format:
[
  {
    "question": "What is the most significant...?",
    "answer": "The detailed answer explaining the concept thoroughly..."
  }
]

Text to analyze:
$text
''';

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyAsyjvx7fdAbrH2RFqL8p3YjfR-zE4tzjk',
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "contents": [
          {
            "parts": [{"text": prompt}]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 2048,  // Increased for longer responses
        },
      }),
    );

    if (response.statusCode == 200) {
      final content = json.decode(response.body);
      if (content["candidates"] != null && content["candidates"].isNotEmpty) {
        final textContent = content["candidates"][0]["content"]["parts"][0]["text"];
        
        // Clean up the response to ensure it's valid JSON
        String cleanedText = textContent.trim();
        
        // Find the first '[' and last ']'
        int startIndex = cleanedText.indexOf('[');
        int endIndex = cleanedText.lastIndexOf(']');
        
        if (startIndex != -1 && endIndex != -1) {
          cleanedText = cleanedText.substring(startIndex, endIndex + 1);
          
          try {
            final parsedFAQ = json.decode(cleanedText);
            setState(() {
              _faqList = List<Map<String, dynamic>>.from(parsedFAQ);
              _errorMessage = '';
            });
          } catch (e) {
            print("JSON parsing error: $e");
            print("Cleaned text: $cleanedText");
            setState(() {
              _errorMessage = "Failed to parse FAQs";
            });
          }
        } else {
          setState(() {
            _errorMessage = "Invalid response format";
          });
        }
      }
    } else {
      print("API Error: ${response.body}");
      setState(() {
        _errorMessage = "Failed to generate FAQs";
      });
    }
  } catch (e) {
    print("FAQ generation error: $e");
    setState(() {
      _errorMessage = "Error generating FAQs";
    });
  } finally {
    setState(() {
      _isGeneratingFAQ = false;
    });
  }


}
  Future<void> _generateQuiz() async {
    setState(() {
      _isGeneratingQuiz = true;
      _quizQuestions = [];
      _quizResult = null;
      _errorMessage = '';
    });

    try {
      final prompt = '''
Generate a quiz with 5 multiple-choice questions based on the content. 
Return ONLY a JSON array with this exact format:
[
  {
    "question": "Detailed question here?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctAnswer": "A"
  }
]

Requirements:
- Each question must test understanding of key concepts
- Make questions challenging but clear
- Each question must have exactly 4 options
- Correct answer must be A, B, C, or D
- Questions should cover different aspects of the content

Content to base questions on:
$_extractedText
''';

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyAsyjvx7fdAbrH2RFqL8p3YjfR-zE4tzjk',
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final content = json.decode(response.body);
        if (content["candidates"] != null && content["candidates"].isNotEmpty) {
          final textContent = content["candidates"][0]["content"]["parts"][0]["text"];
          
          String cleanedText = textContent.trim();
          int startIndex = cleanedText.indexOf('[');
          int endIndex = cleanedText.lastIndexOf(']');
          
          if (startIndex != -1 && endIndex != -1) {
            cleanedText = cleanedText.substring(startIndex, endIndex + 1);
            
            final List<dynamic> parsedQuiz = json.decode(cleanedText);
            _quizQuestions = parsedQuiz.map((q) => QuizQuestion(
              question: q['question'],
              options: List<String>.from(q['options']),
              correctAnswer: q['correctAnswer'],
            )).toList();

            setState(() {
              _showingQuiz = true;
              _errorMessage = '';
            });
          }
        }
      }
    } catch (e) {
      print("Quiz generation error: $e");
      setState(() {
        _errorMessage = "Failed to generate quiz";
      });
    } finally {
      setState(() {
        _isGeneratingQuiz = false;
      });
    }
  }

  void _handleQuizAnswer(int questionIndex, String answer) {
    setState(() {
      _quizQuestions[questionIndex].selectedAnswer = answer;
      _quizQuestions[questionIndex].isAnswered = true;

      // Check if all questions are answered
      if (_quizQuestions.every((q) => q.isAnswered)) {
        _showQuizResult();
      }
    });
  }

  void _showQuizResult() {
    final int score = _quizQuestions.where((q) => q.isCorrect).length;
    final List<String> improvementAreas = [];

    // Generate improvement areas based on incorrect answers
    for (var question in _quizQuestions.where((q) => !q.isCorrect)) {
      improvementAreas.add(
        "Review: ${question.question}\nCorrect Answer: ${question.correctAnswer}) ${question.options[question.correctAnswer.codeUnitAt(0) - 65]}"
      );
    }

    setState(() {
      _quizResult = QuizResult(
        score: score,
        totalQuestions: _quizQuestions.length,
        questions: _quizQuestions,
        improvementAreas: improvementAreas,
      );
    });

    // Show result dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildResultDialog(),
    );
  }

  Widget _buildResultDialog() {
    final percentage = (_quizResult!.score / _quizResult!.totalQuestions) * 100;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Quiz Results",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: percentage >= 80 
                    ? Colors.green.shade100 
                    : percentage >= 60 
                        ? Colors.orange.shade100 
                        : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "${_quizResult!.score}/${_quizResult!.totalQuestions}",
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: percentage >= 80 
                          ? Colors.green.shade700 
                          : percentage >= 60 
                              ? Colors.orange.shade700 
                              : Colors.red.shade700,
                    ),
                  ),
                  Text(
                    "${percentage.round()}%",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_quizResult!.improvementAreas.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                "Areas for Improvement",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                _quizResult!.improvementAreas.length,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _quizResult!.improvementAreas[index],
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _showingQuiz = false;
                  _quizQuestions = [];
                  _quizResult = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Done",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A237E), // Deep Blue
              Color(0xFF0D47A1), // Rich Blue
              Color(0xFF2196F3), // Bright Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Upload Button
                Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(34),
                  child: InkWell(
                    onTap: _isLoading || _isGeneratingFAQ ? null : _pickPDFAndExtractText,
                    borderRadius: BorderRadius.circular(34),
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: (_isLoading || _isGeneratingFAQ)
                            ? Colors.grey[300]
                            : const Color(0xFFFDD835),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_file,
                            color: (_isLoading || _isGeneratingFAQ)
                                ? Colors.grey[600]
                                : Colors.black87,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isLoading
                                ? "Processing PDF..."
                                : _isGeneratingFAQ
                                    ? "Generating FAQs..."
                                    : "Upload PDF file",
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: (_isLoading || _isGeneratingFAQ)
                                  ? Colors.grey[600]
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Content Section
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Loading States
                        if (_isLoading || _isGeneratingFAQ || _isGeneratingQuiz)
                          Column(
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isLoading 
                                    ? "Processing PDF..." 
                                    : _isGeneratingFAQ 
                                        ? "Generating FAQs..." 
                                        : "Generating Quiz...",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )

                        // Error Message
                        else if (_errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: GoogleFonts.poppins(
                                      color: Colors.red.shade700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )

                        // Quiz Section
                        else if (_showingQuiz)
                          ..._quizQuestions.asMap().entries.map((entry) {
                            final index = entry.key;
                            final question = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Question ${index + 1}:",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A237E),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    question.question,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...List.generate(
                                    question.options.length,
                                    (optionIndex) {
                                      final letter = String.fromCharCode(65 + optionIndex);
                                      final isSelected = question.selectedAnswer == letter;
                                      final isCorrect = question.isAnswered && letter == question.correctAnswer;
                                      final isWrong = question.isAnswered && isSelected && !isCorrect;

                                      return GestureDetector(
                                        onTap: question.isAnswered ? null : () => _handleQuizAnswer(index, letter),
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isCorrect
                                                ? Colors.green.shade100
                                                : isWrong
                                                    ? Colors.red.shade100
                                                    : isSelected
                                                        ? Colors.blue.shade100
                                                        : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isCorrect
                                                  ? Colors.green
                                                  : isWrong
                                                      ? Colors.red
                                                      : isSelected
                                                          ? Colors.blue
                                                          : Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: isCorrect
                                                      ? Colors.green
                                                      : isWrong
                                                          ? Colors.red
                                                          : isSelected
                                                              ? Colors.blue
                                                              : Colors.grey.shade400,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    letter,
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  question.options[optionIndex],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          })

                        // FAQ List
                        else if (_faqList.isNotEmpty)
                          Column(
                            children: [
                              ..._faqList.asMap().entries.map(
                                (entry) {
                                  final index = entry.key;
                                  final faq = entry.value;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      title: Text(
                                        "Q${index + 1}: ${faq['question']}",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: const Color(0xFF1A237E),
                                        ),
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            bottom: 20,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Divider(),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Answer:",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "${faq['answer']}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  height: 1.5,
                                                  color: Colors.black87,
                                                ),
                                                textAlign: TextAlign.justify,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              // Generate Quiz Button
                              if (!_showingQuiz)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Material(
                                    elevation: 8,
                                    borderRadius: BorderRadius.circular(34),
                                    child: InkWell(
                                      onTap: _isGeneratingQuiz ? null : _generateQuiz,
                                      borderRadius: BorderRadius.circular(34),
                                      child: Container(
                                        height: 60,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: _isGeneratingQuiz
                                              ? Colors.grey[300]
                                              : const Color(0xFF4CAF50),
                                          borderRadius: BorderRadius.circular(34),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.quiz,
                                              color: _isGeneratingQuiz
                                                  ? Colors.grey[600]
                                                  : Colors.white,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              _isGeneratingQuiz
                                                  ? "Generating Quiz..."
                                                  : "Test Your Knowledge",
                                              style: GoogleFonts.poppins(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                color: _isGeneratingQuiz
                                                    ? Colors.grey[600]
                                                    : Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        else
                          Center(
                            child: Text(
                              _extractedText == null
                                  ? "Upload a PDF to get started"
                                  : _extractedText == "No file selected."
                                      ? "No file selected"
                                      : "Processing content...",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}