'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { BookOpen, Code, Zap, GitBranch, Database, Server } from 'lucide-react'

const topics = [
  {
    id: '1',
    title: 'Python Variables & Data Types',
    description: 'Learn about different data types and how to work with variables',
    progress: 100,
    icon: Code,
    difficulty: 'Beginner',
    exercisesCount: 12
  },
  {
    id: '2',
    title: 'Control Flow',
    description: 'Master if/else statements, loops, and conditional logic',
    progress: 85,
    icon: GitBranch,
    difficulty: 'Beginner',
    exercisesCount: 15
  },
  {
    id: '3',
    title: 'Functions',
    description: 'Understand how to create and use functions effectively',
    progress: 70,
    icon: Zap,
    difficulty: 'Intermediate',
    exercisesCount: 10
  },
  {
    id: '4',
    title: 'Data Structures',
    description: 'Work with lists, tuples, dictionaries, and sets',
    progress: 40,
    icon: Database,
    difficulty: 'Intermediate',
    exercisesCount: 18
  },
  {
    id: '5',
    title: 'Object-Oriented Programming',
    description: 'Learn about classes, objects, inheritance, and polymorphism',
    progress: 0,
    icon: Server,
    difficulty: 'Advanced',
    exercisesCount: 20
  }
]

export default function TopicsPage() {
  return (
    <div className="container mx-auto py-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold">Learning Topics</h1>
        <p className="text-muted-foreground">
          Browse and master Python programming concepts
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {topics.map((topic) => (
          <Card key={topic.id} className="hover:shadow-md transition-shadow">
            <CardHeader>
              <div className="flex items-center gap-3">
                <div className="rounded-lg bg-primary/10 p-2">
                  <topic.icon className="h-6 w-6 text-primary" />
                </div>
                <div>
                  <CardTitle>{topic.title}</CardTitle>
                  <p className="text-sm text-muted-foreground">{topic.difficulty} • {topic.exercisesCount} exercises</p>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground mb-4">{topic.description}</p>
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span>Progress</span>
                  <span>{topic.progress}%</span>
                </div>
                <Progress value={topic.progress} className="h-2" />
              </div>
              <button className="w-full mt-4 py-2 text-center rounded-md bg-primary text-primary-foreground hover:bg-primary/90 transition-colors">
                {topic.progress === 0 ? 'Start Learning' : topic.progress === 100 ? 'Review' : 'Continue'}
              </button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  )
}