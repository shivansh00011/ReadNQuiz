import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class PDFHomePage extends StatefulWidget {
  const PDFHomePage({super.key});

  @override
  State<PDFHomePage> createState() => _PDFHomePageState();
}

class _PDFHomePageState extends State<PDFHomePage> {
  File? selectedFile;
  final TextEditingController _questionController = TextEditingController();
  String _answer = '';
  bool _isLoading = false;
  bool _isPdfUploaded = false;
  String _errorMessage = '';

  // Replace with your actual backend URL
  final String backendUrl = 'http://127.0.0.1:8000';

  Future<void> pickPDF() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedFile = File(result.files.single.path!);
          _isPdfUploaded = false; // Reset when new file is picked
        });
        
        // Automatically upload the PDF when selected
        await uploadPDF();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking PDF: ${e.toString()}';
      });
      _showSnackBar(_errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> uploadPDF() async {
    if (selectedFile == null) {
      _showSnackBar('Please select a PDF file first');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final uri = Uri.parse('$backendUrl/upload_pdf/');
      final request = http.MultipartRequest('POST', uri);
      
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        selectedFile!.path,
        filename: path.basename(selectedFile!.path),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        setState(() {
          _isPdfUploaded = true;
        });
        _showSnackBar('PDF uploaded and processed successfully');
      } else {
        final errorMessage = jsonDecode(response.body)['error'] ?? 'Failed to upload PDF';
        throw Exception(errorMessage);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error uploading PDF: ${e.toString()}';
        _isPdfUploaded = false;
      });
      _showSnackBar(_errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

 Future<void> askQuestion() async {
  final question = _questionController.text.trim();
  if (question.isEmpty) {
    _showSnackBar('Please enter a question');
    return;
  }

  if (!_isPdfUploaded) {
    _showSnackBar('Please upload a PDF first');
    return;
  }

  try {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _answer = '';
    });

    print('[DEBUG] Sending question: $question'); // Debug log

    final uri = Uri.parse('$backendUrl/ask_question/');
    final response = await http.post(
  uri,
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'question': question}), // Changed 'query' to 'question'
);

    print('[DEBUG] Response status: ${response.statusCode}'); // Debug log
    print('[DEBUG] Response body: ${response.body}'); // Debug log

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data.containsKey('error')) {
        throw Exception(data['error']);
      }

      final answer = data['answer'];
      final sourceCount = data['source_count'];

      if (answer != null && answer.isNotEmpty) {
        setState(() {
          if (sourceCount != null) {
            _answer = 'Based on $sourceCount relevant sections:\n\n$answer';
          } else {
            _answer = answer;
          }
        });
      } else {
        setState(() {
          _errorMessage = 'No relevant answer found. Please try rephrasing your question.';
        });
      }
    } else {
      // Handle non-200 status codes
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to get answer from server');
    }
  } catch (e) {
    print('[ERROR] $e'); // Debug log
    setState(() {
      _errorMessage = 'Error: ${e.toString().replaceAll('Exception:', '')}';
      _answer = '';
    });
    _showSnackBar(_errorMessage);
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.blueGrey.shade900.withOpacity(0.9),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.menu_book_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'PDF Assistant',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Help or info button
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A237E), // Deep Blue
              Color(0xFF3949AB), // Royal Blue
              Color(0xFF0288D1), // Light Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(), 
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  // Upload section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.file_upload_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload Document',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Select a PDF to analyze',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _isLoading ? null : pickPDF,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _isLoading 
                                  ? Colors.grey.withOpacity(0.3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _isLoading 
                                  ? [] 
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  color: _isLoading 
                                      ? Colors.white60 
                                      : const Color(0xFF1A237E),
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _isLoading ? 'Processing...' : 'Select PDF',
                                  style: TextStyle(
                                    color: _isLoading 
                                        ? Colors.white60 
                                        : const Color(0xFF1A237E),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (selectedFile != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8EAF6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.picture_as_pdf_rounded,
                                      color: Color(0xFF1A237E),
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        path.basename(selectedFile!.path),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A237E),
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _isPdfUploaded
                                              ? Colors.green.shade50
                                              : Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _isPdfUploaded
                                                  ? Icons.check_circle
                                                  : Icons.hourglass_bottom,
                                              color: _isPdfUploaded
                                                  ? Colors.green.shade700
                                                  : Colors.orange.shade700,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _isPdfUploaded
                                                  ? 'Ready to query'
                                                  : 'Processing...',
                                              style: TextStyle(
                                                color: _isPdfUploaded
                                                    ? Colors.green.shade700
                                                    : Colors.orange.shade700,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            selectedFile = null;
                                            _isPdfUploaded = false;
                                            _answer = '';
                                          });
                                        },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Question section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.question_answer_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ask a Question',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Query your document',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _questionController,
                            decoration: InputDecoration(
                              hintText: _isPdfUploaded
                                  ? 'What would you like to know about the PDF?'
                                  : 'Upload a PDF first',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                              suffixIcon: _questionController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        _questionController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            enabled: _isPdfUploaded && !_isLoading,
                            maxLines: 3,
                            minLines: 1,
                            onChanged: (value) {
                              // Trigger rebuild to show/hide clear button
                              setState(() {});
                            },
                            onSubmitted: (_) => askQuestion(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_isPdfUploaded && !_isLoading && _questionController.text.isNotEmpty)
                                ? askQuestion
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1A237E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                              disabledForegroundColor: Colors.white60,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isLoading ? Icons.hourglass_top : Icons.search,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isLoading ? 'Processing...' : 'Get Answer',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Loading indicator
                  if (_isLoading)
                    Center(
                      child: Container(
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A237E)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              selectedFile != null && !_isPdfUploaded
                                  ? 'Processing document...'
                                  : 'Analyzing your document...',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Error message
                  if (_errorMessage.isNotEmpty && !_isLoading)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Error',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _errorMessage,
                                  style: TextStyle(color: Colors.red.shade900),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.red.shade300,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _errorMessage = '';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  
                  // Answer section
                  if (_answer.isNotEmpty && !_isLoading)
                    Container(
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A237E),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Answer',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(
                                    Icons.copy_outlined,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    // Copy answer to clipboard functionality
                                    _showSnackBar('Answer copied to clipboard');
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              _answer,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Answer generated from your PDF document',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}