
# ReadNQuiz

ReadNQuiz is a comprehensive Flutter application that transforms how users interact with PDF documents. Users can upload PDFs, generate FAQs, test their knowledge with auto-generated quizzes, and have natural conversations with their documents through our custom RAG (Retrieval-Augmented Generation) system.


### ✨ Features

**User Authentication:**

Secure login and registration powered by Firebase Authentication

User profile management and document history

Persistent sessions across devices

**PDF Management:** 

Upload and store PDFs securely

Organize documents in personalized collections

**Smart FAQ Generation:** 

Automatically extract and generate frequently asked questions from uploaded PDFs

Key concept identification for study focus

Export FAQs for offline reference

**AI-Powered Quiz Generator:**

Create custom quizzes from any uploaded PDF

Multiple question formats (multiple choice)

Quiz performance tracking and analytics
    
**Conversational PDF Interface (RAG System):**

Ask natural language questions about your PDF content

Get precise answers with relevant context

Support for complex, multi-part questions

Smart response handling when information isn't in the document

### 🛠️ Tech Stack

**Frontend:** – Flutter for cross-platform mobile application.

**Backend:** – 

FastAPI for the RAG system and quiz generation.

Firebase for authentication and document storage.

**AI/ML:** – 

Google Gemini for context-aware quiz generation
 
Custom RAG implementation using:

   * FAISS for vector similarity search

   * HuggingFace embeddings (all-MiniLM-L6-v2)

   * Text chunk processing and retrieval optimization

### 🚀 Getting Started

**Prerequisites**

Flutter SDK (version 3.0+)

Firebase account

Google Gemini API key

Python 3.8+ (for backend services)

### Installing
**Clone the repository** to your local machine:

```bash
  git clone https://github.com/shivansh00011/ReadNQuiz.git
  cd ReadNQuiz  

```

**Install dependencies:** Run the following command in your project directory to fetch all required dependencies:

```bash
flutter pub get
```

**Set up the backend:** You can take the backend code from my repository named "ReadNQuiz-Backend".

**Configure environment variables:**

Create a .env file in the backend directory

Add your Gemini API key: GOOGLE_API_KEY=your_key_here

Add your Firebase configuration settings

**Run the backend server:**

```bash
uvicorn main:app --reload
```

**Launch the Flutter application**

### Architecture Overview

**Mobile Application:**
Flutter-based application.

**Cloud Backend:**
FastAPI server hosting our RAG system and quiz generation logic.

**Firebase Services:**
Authentication, storage, and realtime database for synchronization.

### How does the RAG works:
The RAG system works in two phases:

**Indexing Phase:** When a PDF is uploaded, it's processed, chunked, embedded, and stored in a vector database.

**Query Phase:** When a question is asked, it retrieves relevant chunks from the vector database, constructs context, and generates an answer using Google Gemini

### 🤝 Contributions

We welcome contributions! If you'd like to improve the project, feel free to fork the repository and submit a pull request.









