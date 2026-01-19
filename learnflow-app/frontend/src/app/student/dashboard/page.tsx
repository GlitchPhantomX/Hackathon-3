'use client';

import { useState, useEffect } from 'react';
import MonacoEditor from '@/components/editor/MonacoEditor';
import { api } from '@/services/api';
import WebSocketService from '@/services/websocket';
import ProtectedRoute from '@/components/ProtectedRoute';
import { useAuth } from '@/auth/AuthProvider';
import { useRouter } from 'next/navigation';

interface ModuleProgress {
  id: string;
  title: string;
  progress: number;
  mastery: number;
  completed: boolean;
}

interface QuizQuestion {
  id: string;
  question: string;
  options: string[];
  correctAnswer: string;
}

const StudentDashboard = () => {
  const [modules, setModules] = useState<ModuleProgress[]>([]);
  const [streak, setStreak] = useState<number>(0);
  const [chatMessages, setChatMessages] = useState<{id: string, text: string, sender: 'user' | 'ai', timestamp: Date}[]>([]);
  const [newMessage, setNewMessage] = useState<string>('');
  const [currentQuiz, setCurrentQuiz] = useState<QuizQuestion | null>(null);
  const [quizAnswers, setQuizAnswers] = useState<{[key: string]: string}>({});
  const [currentUserId, setCurrentUserId] = useState<string>('');

  const [code, setCode] = useState<string>('# Write your Python code here\ndef greet(name):\n    return f"Hello, {name}!"\n\nprint(greet("LearnFlow"))');
  const [output, setOutput] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(false);

  // Initialize the dashboard
  useEffect(() => {
    // In a real app, this would come from authentication
    const userId = 'user-123'; // Mock user ID
    setCurrentUserId(userId);

    // Fetch user's modules and progress
    fetchModuleProgress(userId);

    // Connect to WebSocket for real-time chat
    WebSocketService.connect(userId);

    // Subscribe to chat events
    WebSocketService.subscribeToChatEvents({
      onMessageReceived: (data) => {
        setChatMessages(prev => [
          ...prev,
          {
            id: data.id,
            text: data.message,
            sender: data.sender,
            timestamp: new Date()
          }
        ]);
      }
    });

    // Cleanup on unmount
    return () => {
      WebSocketService.unsubscribeFromChatEvents();
      WebSocketService.disconnect();
    };
  }, []);

  const fetchModuleProgress = async (userId: string) => {
    try {
      // In a real implementation, we would call the API
      // const response = await api.modules.getByUserId(userId);
      // setModules(response.data);

      // Mock data for now
      setModules([
        { id: '1', title: 'Introduction to Python', progress: 100, mastery: 95, completed: true },
        { id: '2', title: 'Variables and Data Types', progress: 100, mastery: 88, completed: true },
        { id: '3', title: 'Control Flow', progress: 100, mastery: 92, completed: true },
        { id: '4', title: 'Functions', progress: 75, mastery: 80, completed: false },
        { id: '5', title: 'Data Structures', progress: 50, mastery: 65, completed: false },
        { id: '6', title: 'Object-Oriented Programming', progress: 25, mastery: 40, completed: false },
        { id: '7', title: 'File Handling', progress: 0, mastery: 0, completed: false },
        { id: '8', title: 'Error Handling', progress: 0, mastery: 0, completed: false },
      ]);

      // Mock streak
      setStreak(7);
    } catch (error) {
      console.error('Error fetching module progress:', error);
    }
  };

  const handleSendMessage = async () => {
    if (newMessage.trim() === '') return;

    // Add user message to UI immediately
    const userMessage = {
      id: Date.now().toString(),
      text: newMessage,
      sender: 'user' as const,
      timestamp: new Date()
    };

    setChatMessages(prev => [...prev, userMessage]);
    setNewMessage('');

    try {
      // Send message to backend
      const response = await api.chat.sendMessage(newMessage, currentUserId);

      // Backend would typically respond with AI-generated response
      // For now, we'll simulate it
    } catch (error) {
      console.error('Error sending message:', error);
    }
  };

  const handleRunCode = async () => {
    setIsLoading(true);
    setOutput('Running code...');

    try {
      console.log('Sending code to backend:', code);

      // Call backend API to execute code
      const response = await api.code.execute(code, 'python');

      // Update output with the result from the backend
      setOutput(response.data.output || 'Code executed successfully!');
    } catch (error) {
      console.error('Error executing code:', error);
      setOutput('Error executing code. Please check your code and try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const startQuiz = async (moduleId: string) => {
    try {
      // In a real implementation, fetch quiz from backend
      // const response = await api.quizzes.getByModuleId(moduleId);
      // setCurrentQuiz(response.data);

      // Mock quiz data for now
      const mockQuiz: QuizQuestion = {
        id: moduleId,
        question: `What is the output of print(${moduleId.slice(-1)} + 2)?`,
        options: ['2', moduleId.slice(-1), (parseInt(moduleId.slice(-1)) + 2).toString(), 'Error'],
        correctAnswer: (parseInt(moduleId.slice(-1)) + 2).toString()
      };
      setCurrentQuiz(mockQuiz);
    } catch (error) {
      console.error('Error starting quiz:', error);
    }
  };

  const handleQuizSubmit = async () => {
    if (!currentQuiz) return;

    try {
      // Submit answers to backend
      const response = await api.quizzes.submit(currentQuiz.id, quizAnswers);

      // Show results
      alert(response.data.correct ? 'Correct! Great job!' : `Incorrect. ${response.data.feedback || 'Please try again.'}`);

      // Clear current quiz
      setCurrentQuiz(null);
      setQuizAnswers({});
    } catch (error) {
      console.error('Error submitting quiz:', error);
      alert('There was an error submitting your quiz. Please try again.');
    }
  };

  const getColorForMastery = (mastery: number) => {
    if (mastery >= 90) return 'bg-green-500';
    if (mastery >= 70) return 'bg-yellow-500';
    if (mastery >= 50) return 'bg-orange-500';
    return 'bg-red-500';
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 py-6 sm:px-6 lg:px-8 flex justify-between items-center">
          <h1 className="text-3xl font-bold text-gray-900">LearnFlow Student Dashboard</h1>
          <div className="flex items-center space-x-4">
            <span className="text-gray-600">Student: John Doe</span>
            <div className="bg-gray-200 border-2 border-dashed rounded-xl w-10 h-10" />
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-6 sm:px-6 lg:px-8">
        {/* Stats Section */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-lg font-medium text-gray-900">Current Streak</h3>
            <p className="text-3xl font-bold text-indigo-600 mt-2">{streak} days</p>
            <div className="mt-2 text-sm text-gray-600">Keep up the momentum!</div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-lg font-medium text-gray-900">Modules Completed</h3>
            <p className="text-3xl font-bold text-indigo-600 mt-2">
              {modules.filter(m => m.completed).length}/{modules.length}
            </p>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-lg font-medium text-gray-900">Avg. Mastery</h3>
            <p className="text-3xl font-bold text-indigo-600 mt-2">
              {Math.round(modules.reduce((sum, mod) => sum + mod.mastery, 0) / modules.length)}%
            </p>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-lg font-medium text-gray-900">Next Goal</h3>
            <p className="text-lg font-bold text-indigo-600 mt-2">Complete Functions module</p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left Column - Progress & Quiz */}
          <div className="lg:col-span-2 space-y-8">
            {/* Module Progress */}
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h2 className="text-xl font-bold text-gray-900 mb-4">Module Progress</h2>

              <div className="space-y-4">
                {modules.map((module) => (
                  <div key={module.id} className="border-b border-gray-200 pb-4 last:border-0 last:pb-0">
                    <div className="flex justify-between items-center mb-2">
                      <h3 className="font-medium text-gray-900">{module.title}</h3>
                      <span className={`px-2 py-1 rounded-full text-xs font-medium text-white ${getColorForMastery(module.mastery)}`}>
                        {module.mastery}% Mastery
                      </span>
                    </div>

                    <div className="w-full bg-gray-200 rounded-full h-2.5 mb-2">
                      <div
                        className="h-2.5 rounded-full bg-blue-600"
                        style={{ width: `${module.progress}%` }}
                      ></div>
                    </div>

                    <div className="flex space-x-2">
                      <button
                        onClick={() => startQuiz(module.id)}
                        className="text-sm bg-indigo-100 text-indigo-700 px-3 py-1 rounded hover:bg-indigo-200"
                      >
                        Take Quiz
                      </button>
                      <button className="text-sm bg-gray-100 text-gray-700 px-3 py-1 rounded hover:bg-gray-200">
                        {module.completed ? 'Review' : 'Continue'}
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Quiz Interface */}
            {currentQuiz && (
              <div className="bg-white p-6 rounded-lg shadow-md">
                <h2 className="text-xl font-bold text-gray-900 mb-4">Quiz Time!</h2>

                <div className="mb-6">
                  <h3 className="text-lg font-medium text-gray-900">{currentQuiz.question}</h3>

                  <div className="mt-4 space-y-2">
                    {currentQuiz.options.map((option, idx) => (
                      <div key={idx} className="flex items-center">
                        <input
                          type="radio"
                          id={`option-${idx}`}
                          name={`quiz-${currentQuiz.id}`}
                          value={option}
                          checked={quizAnswers[currentQuiz.id] === option}
                          onChange={(e) => setQuizAnswers({
                            ...quizAnswers,
                            [currentQuiz.id]: e.target.value
                          })}
                          className="mr-2"
                        />
                        <label htmlFor={`option-${idx}`} className="text-gray-700">
                          {option}
                        </label>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="flex justify-end">
                  <button
                    onClick={handleQuizSubmit}
                    className="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700"
                  >
                    Submit Answer
                  </button>
                </div>
              </div>
            )}
          </div>

          {/* Right Column - Code Editor & Chat */}
          <div className="space-y-8">
            {/* Code Editor */}
            <div className="bg-white p-6 rounded-lg shadow-md">
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-bold text-gray-900">Python Code Editor</h2>
                <button
                  onClick={handleRunCode}
                  disabled={isLoading}
                  className={`bg-indigo-600 text-white px-4 py-2 rounded-md transition-colors ${
                    isLoading ? 'opacity-50 cursor-not-allowed' : 'hover:bg-indigo-700'
                  }`}
                >
                  {isLoading ? 'Running...' : 'Run Code'}
                </button>
              </div>

              <div className="border border-gray-300 rounded-md overflow-hidden mb-4">
                <MonacoEditor
                  value={code}
                  onChange={(newValue) => setCode(newValue || '')}
                  language="python"
                  height="300px"
                />
              </div>

              <div>
                <h3 className="font-medium text-gray-900 mb-2">Output:</h3>
                <div className="bg-gray-900 text-green-400 font-mono text-sm p-4 rounded-md min-h-[100px] max-h-40 overflow-auto">
                  {output || '// Output will appear here after running your code'}
                </div>
              </div>
            </div>

            {/* AI Tutor Chat */}
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h2 className="text-xl font-bold text-gray-900 mb-4">AI Tutor</h2>

              <div className="bg-gray-100 rounded-lg p-4 h-64 overflow-y-auto mb-4">
                {chatMessages.map((msg) => (
                  <div
                    key={msg.id}
                    className={`mb-3 p-3 rounded-lg max-w-[80%] ${
                      msg.sender === 'user'
                        ? 'ml-auto bg-indigo-500 text-white rounded-br-none'
                        : 'bg-gray-200 text-gray-800 rounded-bl-none'
                    }`}
                  >
                    {msg.text}
                  </div>
                ))}
              </div>

              <div className="flex">
                <input
                  type="text"
                  value={newMessage}
                  onChange={(e) => setNewMessage(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
                  placeholder="Ask your AI tutor..."
                  className="flex-1 border border-gray-300 rounded-l-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
                <button
                  onClick={handleSendMessage}
                  className="bg-indigo-600 text-white px-4 py-2 rounded-r-lg hover:bg-indigo-700"
                >
                  Send
                </button>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

// Wrap the component with ProtectedRoute to ensure only students can access it
const StudentDashboardWithAuth = () => (
  <ProtectedRoute allowedRoles={['student']}>
    <StudentDashboard />
  </ProtectedRoute>
);

export default StudentDashboardWithAuth;