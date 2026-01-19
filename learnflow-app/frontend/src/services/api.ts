// src/services/api.ts
import axios from 'axios';

// Base URL for the backend API
// In production, this would come from environment variables
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

// Create axios instance with default config
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000, // 30 seconds timeout
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token if available
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken'); // Assuming token is stored in localStorage
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle common errors
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized access - maybe redirect to login
      console.error('Unauthorized access - token may have expired');
      // Could trigger a logout here
    }
    return Promise.reject(error);
  }
);

// API endpoints
export const api = {
  // Authentication endpoints
  auth: {
    login: (credentials: { email: string; password: string }) =>
      apiClient.post('/auth/login', credentials),
    register: (userData: { email: string; password: string; name: string; role: 'student' | 'teacher' }) =>
      apiClient.post('/auth/register', userData),
    logout: () => apiClient.post('/auth/logout'),
    getCurrentUser: () => apiClient.get('/auth/me'),
  },

  // User management
  user: {
    getProfile: (userId: string) => apiClient.get(`/users/${userId}`),
    updateProfile: (userId: string, data: Partial<{ name: string; email: string }>) =>
      apiClient.put(`/users/${userId}`, data),
  },

  // Course/module related endpoints
  modules: {
    getAll: () => apiClient.get('/modules'),
    getById: (id: string) => apiClient.get(`/modules/${id}`),
    getByUserId: (userId: string) => apiClient.get(`/modules/user/${userId}`),
    updateProgress: (moduleId: string, userId: string, progressData: { progress: number; mastery: number }) =>
      apiClient.put(`/modules/${moduleId}/progress/${userId}`, progressData),
  },

  // Code execution related endpoints
  code: {
    execute: (code: string, language: string) =>
      apiClient.post('/code/execute', { code, language }),
    save: (code: string, userId: string, moduleId: string) =>
      apiClient.post('/code/save', { code, userId, moduleId }),
    getHistory: (userId: string) => apiClient.get(`/code/history/${userId}`),
  },

  // Quiz related endpoints
  quizzes: {
    getByModuleId: (moduleId: string) => apiClient.get(`/quizzes/module/${moduleId}`),
    submit: (quizId: string, answers: Record<string, string>) =>
      apiClient.post(`/quizzes/${quizId}/submit`, { answers }),
    getResults: (quizId: string, userId: string) =>
      apiClient.get(`/quizzes/${quizId}/results/${userId}`),
  },

  // Chat/AI tutor related endpoints
  chat: {
    sendMessage: (message: string, userId: string, context?: string) =>
      apiClient.post('/chat/message', { message, userId, context }),
    getConversation: (conversationId: string) =>
      apiClient.get(`/chat/conversation/${conversationId}`),
    startNewConversation: (userId: string) =>
      apiClient.post('/chat/conversation', { userId }),
  },

  // Class management (for teachers)
  classes: {
    getAll: () => apiClient.get('/classes'),
    getById: (id: string) => apiClient.get(`/classes/${id}`),
    getStudents: (classId: string) => apiClient.get(`/classes/${classId}/students`),
    create: (classData: { name: string; description: string; teacherId: string }) =>
      apiClient.post('/classes', classData),
    update: (id: string, classData: Partial<{ name: string; description: string }>) =>
      apiClient.put(`/classes/${id}`, classData),
    delete: (id: string) => apiClient.delete(`/classes/${id}`),
  },

  // Student progress tracking
  progress: {
    getByClass: (classId: string) => apiClient.get(`/progress/class/${classId}`),
    getByStudent: (studentId: string) => apiClient.get(`/progress/student/${studentId}`),
    update: (studentId: string, moduleId: string, data: { progress: number; mastery: number }) =>
      apiClient.put(`/progress/${studentId}/module/${moduleId}`, data),
  },

  // Exercise generation (for teachers)
  exercises: {
    generate: (topic: string, difficulty: string, description?: string) =>
      apiClient.post('/exercises/generate', { topic, difficulty, description }),
    create: (exerciseData: { title: string; description: string; topic: string; difficulty: string; content: string }) =>
      apiClient.post('/exercises', exerciseData),
    getByClass: (classId: string) => apiClient.get(`/exercises/class/${classId}`),
    assign: (exerciseId: string, classIds: string[]) =>
      apiClient.post('/exercises/assign', { exerciseId, classIds }),
  },
};

export default apiClient;