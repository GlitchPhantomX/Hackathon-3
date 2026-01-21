'use client'

import { ExerciseList } from '@/components/exercises/exercise-list'

export default function ExercisesPage() {
  return (
    <div className="container mx-auto py-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold">Coding Challenges</h1>
        <p className="text-muted-foreground">
          Practice Python with guided exercises and challenges
        </p>
      </div>

      <div className="flex flex-col lg:flex-row gap-6">
        <div className="lg:w-64 flex-shrink-0">
          <FilterPanel />
        </div>
        <div className="flex-1">
          <ExerciseList />
        </div>
      </div>
    </div>
  )
}