'use client';

import { useState, useEffect } from 'react';
import { api } from '@/services/api';
import ProtectedRoute from '@/components/ProtectedRoute';
import { useAuth } from '@/auth/AuthProvider';
import { useRouter } from 'next/navigation';

interface Student {
  id: string;
  name: string;
  progress: number;
  mastery: number;
  lastActive: string;
  struggling: boolean;
}

interface ClassProgress {
  id: string;
  name: string;
  totalStudents: number;
  avgProgress: number;
  avgMastery: number;
  strugglingStudents: number;
}

interface Exercise {
  id: string;
  title: string;
  description: string;
  difficulty: 'easy' | 'medium' | 'hard';
  topic: string;
}

interface Alert {
  id: string;
  studentId: string;
  studentName: string;
  message: string;
  lastActivity: string;
  severity: 'high' | 'medium';
}

const TeacherDashboard = () => {
  const [classes, setClasses] = useState<ClassProgress[]>([]);
  const [students, setStudents] = useState<Student[]>([]);
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [alerts, setAlerts] = useState<Alert[]>([]);
  const [currentUserId, setCurrentUserId] = useState<string>('');

  const [newExercise, setNewExercise] = useState({
    title: '',
    description: '',
    difficulty: 'easy' as 'easy' | 'medium' | 'hard',
    topic: ''
  });

  const [showExerciseGenerator, setShowExerciseGenerator] = useState(false);

  const { user } = useAuth();
  const router = useRouter();

  // Initialize the dashboard
  useEffect(() => {
    if (user) {
      // In a real app, this would come from authentication
      const userId = user.id; // Get user ID from auth context
      setCurrentUserId(userId);

      // Fetch initial data
      fetchDashboardData(userId);
    } else {
      // If no user, redirect to login
      router.push('/auth/login');
    }
  }, [user, router]);

  // If user is not a teacher, don't render anything (ProtectedRoute will handle redirect)
  if (user && user.role !== 'teacher') {
    return null;
  }

  const fetchDashboardData = async (userId: string) => {
    try {
      // Fetch classes for the teacher
      // const classesResponse = await api.classes.getByTeacherId(userId);
      // setClasses(classesResponse.data);

      // Fetch students in all classes
      // const studentsResponse = await api.progress.getAll(userId);
      // setStudents(studentsResponse.data);

      // Fetch exercises
      // const exercisesResponse = await api.exercises.getByTeacherId(userId);
      // setExercises(exercisesResponse.data);

      // Fetch alerts
      // const alertsResponse = await api.progress.getAlerts(userId);
      // setAlerts(alertsResponse.data);

      // Mock data for now
      setClasses([
        { id: '1', name: 'Intro to Python - Fall 2024', totalStudents: 24, avgProgress: 65, avgMastery: 72, strugglingStudents: 3 },
        { id: '2', name: 'Advanced Python - Spring 2025', totalStudents: 18, avgProgress: 82, avgMastery: 89, strugglingStudents: 1 },
        { id: '3', name: 'Python Bootcamp - Summer', totalStudents: 32, avgProgress: 45, avgMastery: 58, strugglingStudents: 7 },
      ]);

      setStudents([
        { id: '1', name: 'Alice Johnson', progress: 85, mastery: 90, lastActive: '2 hours ago', struggling: false },
        { id: '2', name: 'Bob Smith', progress: 45, mastery: 52, lastActive: '1 day ago', struggling: true },
        { id: '3', name: 'Charlie Brown', progress: 78, mastery: 85, lastActive: '30 mins ago', struggling: false },
        { id: '4', name: 'Diana Prince', progress: 32, mastery: 40, lastActive: '3 days ago', struggling: true },
        { id: '5', name: 'Ethan Hunt', progress: 92, mastery: 96, lastActive: '1 hour ago', struggling: false },
      ]);

      setExercises([
        { id: '1', title: 'Basic Variables', description: 'Practice declaring and assigning variables', difficulty: 'easy', topic: 'Variables' },
        { id: '2', title: 'Loops Practice', description: 'Work with for and while loops', difficulty: 'medium', topic: 'Control Flow' },
        { id: '3', title: 'Function Challenges', description: 'Create functions with parameters and return values', difficulty: 'medium', topic: 'Functions' },
      ]);

      setAlerts([
        { id: '1', studentId: '2', studentName: 'Bob Smith', message: 'Struggling with Control Flow concepts', lastActivity: '1 day ago', severity: 'high' },
        { id: '2', studentId: '4', studentName: 'Diana Prince', message: 'Having trouble with Functions', lastActivity: '3 days ago', severity: 'high' },
        { id: '3', studentId: '6', studentName: 'John Doe', message: 'Slowing down in Data Structures', lastActivity: '2 days ago', severity: 'medium' },
        { id: '4', studentId: '7', studentName: 'Sarah Connor', message: 'Needs reinforcement on Variables', lastActivity: '1 day ago', severity: 'medium' },
      ]);
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
    }
  };

  const handleGenerateExercise = async () => {
    if (!newExercise.title || !newExercise.topic) return;

    try {
      // Call API to generate exercise
      // const response = await api.exercises.generate(
      //   newExercise.topic,
      //   newExercise.difficulty,
      //   newExercise.description
      // );

      // For mock implementation:
      const exercise: Exercise = {
        id: `ex-${Date.now()}`,
        title: newExercise.title,
        description: newExercise.description,
        difficulty: newExercise.difficulty,
        topic: newExercise.topic
      };

      setExercises([...exercises, exercise]);
      setNewExercise({ title: '', description: '', difficulty: 'easy', topic: '' });
      setShowExerciseGenerator(false);

      // Optionally, create the exercise in the backend
      // await api.exercises.create(exercise);
    } catch (error) {
      console.error('Error generating exercise:', error);
    }
  };

  const getDifficultyColor = (difficulty: 'easy' | 'medium' | 'hard') => {
    switch (difficulty) {
      case 'easy': return 'bg-green-100 text-green-800';
      case 'medium': return 'bg-yellow-100 text-yellow-800';
      case 'hard': return 'bg-red-100 text-red-800';
    }
  };

  const getProgressColor = (progress: number) => {
    if (progress >= 80) return 'bg-green-500';
    if (progress >= 60) return 'bg-yellow-500';
    if (progress >= 40) return 'bg-orange-500';
    return 'bg-red-500';
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 py-6 sm:px-6 lg:px-8 flex justify-between items-center">
          <h1 className="text-3xl font-bold text-gray-900">LearnFlow Teacher Dashboard</h1>
          <div className="flex items-center space-x-4">
            <span className="text-gray-600">Teacher: Jane Smith</span>
            <div className="bg-gray-200 border-2 border-dashed rounded-xl w-10 h-10" />
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-6 sm:px-6 lg:px-8">
        {/* Stats Section */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-lg font-medium text-gray-900">Total Classes</h3>
            <p className="text-3xl font-bold text-indigo-600 mt-2">{classes.length}</p>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-lg font-medium text-gray-900">Total Students</h3>
            <p className="text-3xl font-bold text-indigo-600 mt-2">
              {classes.reduce((sum, cls) => sum + cls.totalStudents, 0)}
            </p>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-lg font-medium text-gray-900">Avg. Class Progress</h3>
            <p className="text-3xl font-bold text-indigo-600 mt-2">
              {Math.round(classes.reduce((sum, cls) => sum + cls.avgProgress, 0) / classes.length)}%
            </p>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="text-lg font-medium text-gray-900">Struggling Students</h3>
            <p className="text-3xl font-bold text-indigo-600 mt-2">
              {classes.reduce((sum, cls) => sum + cls.strugglingStudents, 0)}
            </p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left Column - Class Overview & Student Monitoring */}
          <div className="lg:col-span-2 space-y-8">
            {/* Class Progress Overview */}
            <div className="bg-white p-6 rounded-lg shadow-md">
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-bold text-gray-900">Class Progress Overview</h2>
              </div>

              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Class
                      </th>
                      <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Students
                      </th>
                      <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Avg. Progress
                      </th>
                      <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Avg. Mastery
                      </th>
                      <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Struggling
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {classes.map((cls) => (
                      <tr key={cls.id}>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                          {cls.name}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {cls.totalStudents}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center">
                            <div className="w-24 bg-gray-200 rounded-full h-2.5 mr-2">
                              <div
                                className={`h-2.5 rounded-full ${getProgressColor(cls.avgProgress)}`}
                                style={{ width: `${cls.avgProgress}%` }}
                              ></div>
                            </div>
                            <span className="text-sm text-gray-500">{cls.avgProgress}%</span>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {cls.avgMastery}%
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                            {cls.strugglingStudents} students
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            {/* Student Monitoring */}
            <div className="bg-white p-6 rounded-lg shadow-md">
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-bold text-gray-900">Student Monitoring</h2>
              </div>

              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Student
                      </th>
                      <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Progress
                      </th>
                      <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Mastery
                      </th>
                      <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Last Active
                      </th>
                      <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Status
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {students.map((student) => (
                      <tr key={student.id} className={student.struggling ? 'bg-red-50' : ''}>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                          {student.name}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center">
                            <div className="w-20 bg-gray-200 rounded-full h-2.5 mr-2">
                              <div
                                className={`h-2.5 rounded-full ${getProgressColor(student.progress)}`}
                                style={{ width: `${student.progress}%` }}
                              ></div>
                            </div>
                            <span className="text-sm text-gray-500">{student.progress}%</span>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {student.mastery}%
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {student.lastActive}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          {student.struggling ? (
                            <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                              Needs Help
                            </span>
                          ) : (
                            <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                              On Track
                            </span>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          {/* Right Column - Struggle Alerts & Exercise Generator */}
          <div className="space-y-8">
            {/* Struggle Alerts */}
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h2 className="text-xl font-bold text-gray-900 mb-4">Struggle Alerts</h2>

              <div className="space-y-4">
                {alerts.map((alert) => (
                  <div
                    key={alert.id}
                    className={`border-l-4 pl-4 py-1 ${
                      alert.severity === 'high' ? 'border-red-500' : 'border-yellow-500'
                    }`}
                  >
                    <p className="text-sm font-medium text-gray-900">{alert.studentName}</p>
                    <p className="text-sm text-gray-500">{alert.message}</p>
                    <p className="text-xs text-gray-400">Last activity: {alert.lastActivity}</p>
                  </div>
                ))}
              </div>
            </div>

            {/* Exercise Generator */}
            <div className="bg-white p-6 rounded-lg shadow-md">
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-bold text-gray-900">Exercise Generator</h2>
                <button
                  onClick={() => setShowExerciseGenerator(!showExerciseGenerator)}
                  className="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700"
                >
                  {showExerciseGenerator ? 'Cancel' : 'Create New'}
                </button>
              </div>

              {showExerciseGenerator ? (
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                    <input
                      type="text"
                      value={newExercise.title}
                      onChange={(e) => setNewExercise({...newExercise, title: e.target.value})}
                      className="w-full border border-gray-300 rounded-md px-3 py-2"
                      placeholder="Exercise title"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                    <textarea
                      value={newExercise.description}
                      onChange={(e) => setNewExercise({...newExercise, description: e.target.value})}
                      className="w-full border border-gray-300 rounded-md px-3 py-2"
                      placeholder="Exercise description"
                      rows={3}
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Topic</label>
                    <input
                      type="text"
                      value={newExercise.topic}
                      onChange={(e) => setNewExercise({...newExercise, topic: e.target.value})}
                      className="w-full border border-gray-300 rounded-md px-3 py-2"
                      placeholder="Related topic (e.g., Variables, Functions)"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Difficulty</label>
                    <select
                      value={newExercise.difficulty}
                      onChange={(e) => setNewExercise({...newExercise, difficulty: e.target.value as 'easy' | 'medium' | 'hard'})}
                      className="w-full border border-gray-300 rounded-md px-3 py-2"
                    >
                      <option value="easy">Easy</option>
                      <option value="medium">Medium</option>
                      <option value="hard">Hard</option>
                    </select>
                  </div>

                  <button
                    onClick={handleGenerateExercise}
                    className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700"
                  >
                    Generate Exercise
                  </button>
                </div>
              ) : (
                <div>
                  <h3 className="font-medium text-gray-900 mb-2">Recent Exercises</h3>
                  <div className="space-y-3">
                    {exercises.map((exercise) => (
                      <div key={exercise.id} className="border border-gray-200 rounded-lg p-3">
                        <div className="flex justify-between">
                          <h4 className="font-medium text-gray-900">{exercise.title}</h4>
                          <span className={`text-xs px-2 py-1 rounded-full ${getDifficultyColor(exercise.difficulty)}`}>
                            {exercise.difficulty}
                          </span>
                        </div>
                        <p className="text-sm text-gray-600 mt-1">{exercise.description}</p>
                        <div className="text-xs text-gray-500 mt-2">Topic: {exercise.topic}</div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

// Wrap the component with ProtectedRoute to ensure only teachers can access it
const TeacherDashboardWithAuth = () => (
  <ProtectedRoute allowedRoles={['teacher']}>
    <TeacherDashboard />
  </ProtectedRoute>
);

export default TeacherDashboardWithAuth;