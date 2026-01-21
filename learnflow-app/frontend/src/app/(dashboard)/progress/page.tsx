'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { ProgressOverview } from '@/components/dashboard/progress-overview'
import { RecentActivity } from '@/components/dashboard/recent-activity'
import { LineChartComponent } from '@/components/charts/line-chart-component'
import { BarChartComponent } from '@/components/charts/bar-chart-component'
import { Flame, Trophy, TrendingUp, Target } from 'lucide-react'

// Mock data for charts
const studyTimeData = [
  { date: 'Jan 1', hours: 2 },
  { date: 'Jan 2', hours: 3 },
  { date: 'Jan 3', hours: 1 },
  { date: 'Jan 4', hours: 4 },
  { date: 'Jan 5', hours: 2 },
  { date: 'Jan 6', hours: 3 },
  { date: 'Jan 7', hours: 5 },
]

const exerciseCompletionData = [
  { topic: 'Variables', completed: 12, attempted: 15 },
  { topic: 'Loops', completed: 8, attempted: 10 },
  { topic: 'Functions', completed: 5, attempted: 8 },
  { topic: 'OOP', completed: 2, attempted: 5 },
  { topic: 'Data Structures', completed: 4, attempted: 6 },
]

export default function ProgressPage() {
  return (
    <div className="container mx-auto py-6 space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Learning Progress</h1>
        <p className="text-muted-foreground">
          Track your Python learning journey and achievements
        </p>
      </div>

      <ProgressOverview />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <LineChartComponent
          data={studyTimeData}
          title="Study Time Over Last Week"
        />
        <BarChartComponent
          data={exerciseCompletionData}
          title="Exercise Completion by Topic"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <RecentActivity />
        <Card>
          <CardHeader>
            <CardTitle>Quick Stats</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex justify-between">
                <span>Current Streak</span>
                <span className="font-medium">7 days</span>
              </div>
              <div className="flex justify-between">
                <span>Exercises This Week</span>
                <span className="font-medium">5</span>
              </div>
              <div className="flex justify-between">
                <span>Total Hours Coded</span>
                <span className="font-medium">24.5</span>
              </div>
              <div className="flex justify-between">
                <span>Topics Mastered</span>
                <span className="font-medium">3/12</span>
              </div>
              <div className="flex justify-between">
                <span>Overall Mastery</span>
                <span className="font-medium">68%</span>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}