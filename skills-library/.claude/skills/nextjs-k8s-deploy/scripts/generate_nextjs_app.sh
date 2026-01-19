#!/bin/bash

# NextJS K8s Deploy - Generate Next.js App Script
# Creates a Next.js project with App Router and Tailwind CSS

set -euo pipefail

APP_NAME="${1:-learnflow-frontend}"
OUTPUT_DIR="${2:-.}"

echo "Generating Next.js application: $APP_NAME"

# Create the Next.js app with TypeScript, App Router, and Tailwind
cd "$OUTPUT_DIR"
npx create-next-app@latest "$APP_NAME" --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"

cd "$APP_NAME"

# Install additional dependencies for LearnFlow
echo "Installing additional dependencies..."

# Install Better Auth for authentication
npm install better-auth @better-auth/react

# Install Monaco Editor
npm install @monaco-editor/react monaco-editor

# Install additional UI libraries
npm install lucide-react clsx tailwind-merge
npm install -D @types/lucide-react

# Create the src/app directory structure
mkdir -p src/app/{api,components,dashboard,pages}

# Create the main layout file
cat > src/app/layout.tsx << 'EOF'
import './globals.css'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'LearnFlow',
  description: 'AI-Powered Learning Platform',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
EOF

# Create the main page
cat > src/app/page.tsx << 'EOF'
'use client';

import { useEffect, useState } from 'react';
import { useSession } from '@better-auth/react';
import Link from 'next/link';

export default function Home() {
  const { data: session, isPending } = useSession();

  if (isPending) {
    return <div className="flex justify-center items-center h-screen">Loading...</div>;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-indigo-600">LearnFlow</h1>
          <nav>
            {session ? (
              <Link href="/dashboard" className="text-indigo-600 hover:text-indigo-800 font-medium">
                Dashboard
              </Link>
            ) : (
              <Link href="/api/auth/login" className="text-indigo-600 hover:text-indigo-800 font-medium">
                Sign In
              </Link>
            )}
          </nav>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="text-center">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Welcome to LearnFlow
          </h2>
          <p className="text-lg text-gray-600 mb-8 max-w-2xl mx-auto">
            An AI-powered learning platform that adapts to your needs and helps you master programming concepts.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mt-12">
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h3 className="text-xl font-semibold mb-2">Personalized Learning</h3>
              <p className="text-gray-600">AI-powered lessons tailored to your learning style and pace.</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h3 className="text-xl font-semibold mb-2">Interactive Coding</h3>
              <p className="text-gray-600">Practice coding with our integrated Monaco editor and instant feedback.</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-md">
              <h3 className="text-xl font-semibold mb-2">Progress Tracking</h3>
              <p className="text-gray-600">Track your learning journey and celebrate your achievements.</p>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
EOF

# Create a basic dashboard page
cat > src/app/dashboard/page.tsx << 'EOF'
'use client';

import { useSession } from '@better-auth/react';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

export default function DashboardPage() {
  const { data: session, isPending } = useSession();
  const router = useRouter();

  useEffect(() => {
    if (!isPending && !session) {
      router.push('/api/auth/login');
    }
  }, [isPending, session, router]);

  if (isPending || !session) {
    return <div className="flex justify-center items-center h-screen">Loading...</div>;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 py-6 sm:px-6 lg:px-8 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
          <div className="flex items-center space-x-4">
            <span className="text-gray-700">Welcome, {session.user.name || session.user.email}</span>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-6 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="px-4 py-5 sm:p-6">
              <h3 className="text-lg leading-6 font-medium text-gray-900">Learning Progress</h3>
              <div className="mt-2">
                <div className="w-full bg-gray-200 rounded-full h-2.5">
                  <div className="bg-indigo-600 h-2.5 rounded-full" style={{width: '65%'}}></div>
                </div>
                <p className="mt-2 text-sm text-gray-600">65% Complete</p>
              </div>
            </div>
          </div>

          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="px-4 py-5 sm:p-6">
              <h3 className="text-lg leading-6 font-medium text-gray-900">Current Module</h3>
              <p className="mt-1 text-sm text-gray-600">Advanced JavaScript Patterns</p>
              <div className="mt-4">
                <button className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                  Continue Learning
                </button>
              </div>
            </div>
          </div>

          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="px-4 py-5 sm:p-6">
              <h3 className="text-lg leading-6 font-medium text-gray-900">Upcoming Exercises</h3>
              <ul className="mt-2 space-y-2">
                <li className="text-sm text-gray-600">- Async/Await Challenge</li>
                <li className="text-sm text-gray-600">- Closure Practice</li>
                <li className="text-sm text-gray-600">- Prototype Chain Exercise</li>
              </ul>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
EOF

# Create the globals CSS file
cat > src/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --foreground-rgb: 0, 0, 0;
  --background-start-rgb: 214, 219, 220;
  --background-end-rgb: 255, 255, 255;
}

@media (prefers-color-scheme: dark) {
  :root {
    --foreground-rgb: 255, 255, 255;
    --background-start-rgb: 0, 0, 0;
    --background-end-rgb: 0, 0, 0;
  }
}

body {
  color: rgb(var(--foreground-rgb));
  background: linear-gradient(
      to bottom,
      transparent,
      rgb(var(--background-end-rgb))
    )
    rgb(var(--background-start-rgb));
}
EOF

echo "✓ Next.js application '$APP_NAME' generated successfully!"
echo "  - Created with App Router, TypeScript, and Tailwind CSS"
echo "  - Added authentication with Better Auth"
echo "  - Included dashboard and home pages"
echo "  - Ready for Monaco Editor integration"