import { createJSONHandler, MCPConfig } from '@modelcontextprotocol/sdk';
import express from 'express';
import { z } from 'zod';

// Define the configuration for the LearnFlow MCP server
const config: MCPConfig = {
  name: 'LearnFlow Context Server',
  description: 'Provides context about student progress, exercises, and code submissions for the LearnFlow platform',
  version: '1.0.0',
};

// Define data structures
interface StudentProgress {
  id: string;
  userId: string;
  moduleId: string;
  progress: number;
  mastery: number;
  lastAccessed: Date;
  completed: boolean;
}

interface Exercise {
  id: string;
  title: string;
  description: string;
  topic: string;
  difficulty: 'easy' | 'medium' | 'hard';
  content: string;
  createdAt: Date;
}

interface CodeSubmission {
  id: string;
  userId: string;
  moduleId: string;
  code: string;
  submittedAt: Date;
  executionResult: string;
  grade?: number;
}

// Mock data storage (in a real implementation, this would connect to your database)
let mockStudentProgress: StudentProgress[] = [
  {
    id: 'progress-1',
    userId: 'user-123',
    moduleId: 'module-1',
    progress: 100,
    mastery: 95,
    lastAccessed: new Date(),
    completed: true
  },
  {
    id: 'progress-2',
    userId: 'user-123',
    moduleId: 'module-2',
    progress: 75,
    mastery: 80,
    lastAccessed: new Date(),
    completed: false
  }
];

let mockExercises: Exercise[] = [
  {
    id: 'exercise-1',
    title: 'Basic Variables',
    description: 'Practice declaring and assigning variables',
    topic: 'Variables',
    difficulty: 'easy',
    content: 'Create a variable called "name" and assign it your name as a string.',
    createdAt: new Date()
  },
  {
    id: 'exercise-2',
    title: 'Loops Practice',
    description: 'Work with for and while loops',
    topic: 'Control Flow',
    difficulty: 'medium',
    content: 'Write a loop that prints numbers from 1 to 10.',
    createdAt: new Date()
  }
];

let mockSubmissions: CodeSubmission[] = [
  {
    id: 'submission-1',
    userId: 'user-123',
    moduleId: 'module-1',
    code: 'name = "John"\nprint(name)',
    submittedAt: new Date(),
    executionResult: 'Success: John'
  }
];

// Define the tools available through the MCP server
const tools = {
  getStudentProgress: {
    name: 'getStudentProgress',
    description: 'Retrieve a student\'s progress data',
    inputSchema: z.object({
      userId: z.string().describe('The ID of the student to retrieve progress for'),
    }),
    handler: async ({ userId }: { userId: string }) => {
      const progress = mockStudentProgress.filter(p => p.userId === userId);
      return {
        success: true,
        data: progress,
        message: `Retrieved progress for user ${userId}`
      };
    }
  },

  getStudentProgressByModule: {
    name: 'getStudentProgressByModule',
    description: 'Retrieve a student\'s progress for a specific module',
    inputSchema: z.object({
      userId: z.string().describe('The ID of the student'),
      moduleId: z.string().describe('The ID of the module'),
    }),
    handler: async ({ userId, moduleId }: { userId: string; moduleId: string }) => {
      const progress = mockStudentProgress.find(p => p.userId === userId && p.moduleId === moduleId);
      return {
        success: !!progress,
        data: progress || null,
        message: progress ? `Retrieved progress for user ${userId} in module ${moduleId}` : `No progress found for user ${userId} in module ${moduleId}`
      };
    }
  },

  getExercisesByTopic: {
    name: 'getExercisesByTopic',
    description: 'Retrieve exercises by topic and difficulty',
    inputSchema: z.object({
      topic: z.string().describe('The topic to search for'),
      difficulty: z.enum(['easy', 'medium', 'hard']).optional().describe('The difficulty level'),
    }),
    handler: async ({ topic, difficulty }: { topic: string; difficulty?: 'easy' | 'medium' | 'hard' }) => {
      let exercises = mockExercises.filter(e => e.topic.toLowerCase().includes(topic.toLowerCase()));

      if (difficulty) {
        exercises = exercises.filter(e => e.difficulty === difficulty);
      }

      return {
        success: true,
        data: exercises,
        message: `Found ${exercises.length} exercises for topic "${topic}"${difficulty ? ` at ${difficulty} difficulty` : ''}`
      };
    }
  },

  getCodeSubmissionHistory: {
    name: 'getCodeSubmissionHistory',
    description: 'Retrieve a student\'s code submission history',
    inputSchema: z.object({
      userId: z.string().describe('The ID of the student'),
      moduleId: z.string().optional().describe('The module ID to filter by'),
    }),
    handler: async ({ userId, moduleId }: { userId: string; moduleId?: string }) => {
      let submissions = mockSubmissions.filter(s => s.userId === userId);

      if (moduleId) {
        submissions = submissions.filter(s => s.moduleId === moduleId);
      }

      return {
        success: true,
        data: submissions,
        message: `Retrieved ${submissions.length} submissions for user ${userId}${moduleId ? ` in module ${moduleId}` : ''}`
      };
    }
  },

  getExerciseById: {
    name: 'getExerciseById',
    description: 'Retrieve a specific exercise by its ID',
    inputSchema: z.object({
      exerciseId: z.string().describe('The ID of the exercise to retrieve'),
    }),
    handler: async ({ exerciseId }: { exerciseId: string }) => {
      const exercise = mockExercises.find(e => e.id === exerciseId);
      return {
        success: !!exercise,
        data: exercise || null,
        message: exercise ? `Retrieved exercise ${exerciseId}` : `Exercise ${exerciseId} not found`
      };
    }
  },

  getStudentStruggles: {
    name: 'getStudentStruggles',
    description: 'Identify areas where a student is struggling based on progress data',
    inputSchema: z.object({
      userId: z.string().describe('The ID of the student'),
    }),
    handler: async ({ userId }: { userId: string }) => {
      const progress = mockStudentProgress.filter(p => p.userId === userId && p.mastery < 70);
      const struggles = progress.map(p => ({
        moduleId: p.moduleId,
        mastery: p.mastery,
        title: `Module ${p.moduleId}` // In a real implementation, this would come from the module data
      }));

      return {
        success: true,
        data: struggles,
        message: `Identified ${struggles.length} areas where user ${userId} is struggling`
      };
    }
  }
};

// Create the MCP JSON handler
const mcpHandler = createJSONHandler(config, tools);

// Create Express app
const app = express();
app.use(express.json());

// Mount the MCP handler at the appropriate endpoint
app.use('/mcp', mcpHandler);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'LearnFlow Context MCP Server' });
});

// Start the server
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`LearnFlow Context MCP Server running on port ${PORT}`);
  console.log(`MCP endpoint available at http://localhost:${PORT}/mcp`);
  console.log(`Health check available at http://localhost:${PORT}/health`);
});

export default app;