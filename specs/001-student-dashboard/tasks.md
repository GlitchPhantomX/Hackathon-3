# Implementation Tasks: Student Dashboard
**Feature**: Professional Student Dashboard | **Plan**: Complete Specification
**Created**: 2026-01-20 | **Status**: Ready for Implementation
**Prerequisites**: Design complete, dependencies installed

---

## 📋 Overview

Implementation of a world-class, professional-grade student learning dashboard with stunning animations, modern design, and exceptional user experience. The dashboard will serve as the central hub for students to interact with AI tutors, practice coding exercises, track their progress, and access learning materials.

**Architecture**:
- Next.js 15 with App Router for routing
- Tailwind CSS + shadcn/ui for styling
- Framer Motion for smooth animations
- Radix UI primitives for accessibility
- Lucide React for consistent icons
- Recharts + Tremor for data visualization
- Sonner for toast notifications
- Monaco Editor for code editing
- Zustand for state management

**Total Estimated Time**: 3-4 days

---

## 🎯 Success Criteria

- ✅ Stunning UI that rivals professional SaaS products
- ✅ Smooth 60fps animations throughout
- ✅ Perfect light/dark mode with zero flicker
- ✅ All features accessible via keyboard
- ✅ Sub-1s page load times
- ✅ Responsive across all device sizes
- ✅ Real-time AI chat working perfectly
- ✅ Code editor with syntax highlighting
- ✅ Interactive charts and analytics
- ✅ Professional navigation and layout

---

## Phase 0: Project Setup (Critical Path - 2 hours)

### TASK-P001: Initialize Frontend Project Structure
- **Effort**: M (45 min)
- **Priority**: P0 - BLOCKER
- **Dependencies**: None

**Commands**:
```bash
cd /c/hackathon-3/learnflow-app

# Create frontend directories
mkdir -p frontend/{app,components,lib,pages,public,styles}

# Create app directory structure
mkdir -p frontend/app/{(auth),(dashboard),api,globals.css,layout.tsx,providers.tsx}

# Create auth section
mkdir -p frontend/app/(auth)/{login,register}

# Create dashboard sections
mkdir -p frontend/app/(dashboard)/{chat,code,exercises,progress,topics,settings}

# Create API routes
mkdir -p frontend/app/api/{chat,exercises,progress}

# Create components structure
mkdir -p frontend/components/{ui,layout,chat,code-editor,exercises,progress,charts,animations,search,shared}

# Create lib structure
mkdir -p frontend/lib/{utils,hooks,store}

# Create public assets
mkdir -p frontend/public/{icons,images,animations}
```

**Acceptance Criteria**:
- [ ] All directory structure created successfully
- [ ] Directory paths match plan.md specification
- [ ] No duplicate or incorrect paths
- [ ] Structure supports all planned features

---

### TASK-P002: Install Dependencies
- **Effort**: S (30 min)
- **Priority**: P0 - BLOCKER
- **Dependencies**: TASK-P001

**Commands**:
```bash
cd /c/hackathon-3/learnflow-app/frontend

# Initialize Next.js project if not already done
npm init next-app@latest . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"

# Install core dependencies
npm install next react react-dom typescript @types/react @types/node @types/react-dom

# Install styling dependencies
npm install tailwindcss postcss autoprefixer

# Install shadcn/ui dependencies
npm install @radix-ui/react-dialog @radix-ui/react-dropdown-menu @radix-ui/react-tabs @radix-ui/react-select @radix-ui/react-switch @radix-ui/react-tooltip @radix-ui/react-popover @radix-ui/react-accordion @radix-ui/react-label @radix-ui/react-slot @radix-ui/react-separator

# Install utility dependencies
npm install class-variance-authority clsx tailwind-merge lucide-react

# Install animation dependencies
npm install framer-motion @auto-animate/react canvas-confetti

# Install chart dependencies
npm install recharts @tremor/react

# Install editor dependencies
npm install @monaco-editor/react react-syntax-highlighter

# Install state management
npm install zustand @tanstack/react-query

# Install forms/validation
npm install react-hook-form zod @hookform/resolvers

# Install theme management
npm install next-themes

# Install notifications
npm install sonner

# Install auth
npm install better-auth
```

**Acceptance Criteria**:
- [ ] All dependencies installed without errors
- [ ] package.json updated with all required dependencies
- [ ] Lock file (package-lock.json) updated
- [ ] Dependencies match plan.md specification

---

### TASK-P003: Configure shadcn/ui and Tailwind
- **Effort**: S (30 min)
- **Priority**: P0 - BLOCKER
- [ ] **Dependencies**: TASK-P002

**Commands**:
```bash
cd /c/hackathon-3/learnflow-app/frontend

# Initialize Tailwind
npx tailwindcss init -p

# Configure Tailwind to scan component files
# Update tailwind.config.js to include:
# content: [
#   "./pages/**/*.{ts,tsx}",
#   "./components/**/*.{ts,tsx}",
#   "./app/**/*.{ts,tsx}",
#   "./src/**/*.{ts,tsx}",
# ],

# Initialize shadcn components
npx shadcn-ui@latest init

# Add initial components
npx shadcn-ui@latest add button card dialog dropdown-menu input tabs badge avatar separator sheet skeleton tooltip popover select switch progress slider scroll-area command
```

**Acceptance Criteria**:
- [ ] Tailwind configured to scan all component files
- [ ] shadcn initialized with base configuration
- [ ] Initial UI components installed successfully
- [ ] Configuration files created (components.json, tailwind.config.js)

---

## Phase 1: Core Layout Components (2 hours)

### TASK-001: Create Root Layout and Providers
- **Effort**: M (45 min)
- **Priority**: P1
- **Dependencies**: TASK-P003

**Create**: `frontend/app/layout.tsx`

```tsx
import './globals.css'
import { Inter } from 'next/font/google'
import { Providers } from './providers'

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: 'LearnFlow - Professional Learning Dashboard',
  description: 'World-class student learning platform with AI tutors',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```

**Create**: `frontend/app/providers.tsx`

```tsx
'use client'

import { ThemeProvider } from 'next-themes'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { Toaster } from 'sonner'
import { motion } from 'framer-motion'

const queryClient = new QueryClient()

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
        {children}
        <Toaster richColors />
      </ThemeProvider>
    </QueryClientProvider>
  )
}
```

**Create**: `frontend/app/globals.css`

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 47.4% 11.2%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 212.7 26.8% 83.9%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}

/* Glassmorphism classes */
.glass {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.glass-dark {
  background: rgba(17, 25, 40, 0.75);
  backdrop-filter: blur(16px) saturate(180%);
  -webkit-backdrop-filter: blur(16px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.125);
}
```

**Acceptance Criteria**:
- [ ] Root layout created with proper metadata
- [ ] Providers component wraps children with theme and query providers
- [ ] Global CSS includes Tailwind directives and custom variables
- [ ] Glassmorphism classes defined for use in components
- [ ] Theme transition classes included

---

### TASK-002: Create Dashboard Layout Component
- **Effort**: M (30 min)
- **Priority**: P1
- **Dependencies**: TASK-001

**Create**: `frontend/app/(dashboard)/layout.tsx`

```tsx
'use client'

import { Sidebar } from '@/components/layout/sidebar'
import { Navbar } from '@/components/layout/navbar'
import { useState } from 'react'

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false)

  return (
    <div className="flex h-screen bg-background">
      <Sidebar collapsed={sidebarCollapsed} setCollapsed={setSidebarCollapsed} />
      <div className="flex flex-col flex-1 overflow-hidden">
        <Navbar />
        <main className="flex-1 overflow-y-auto p-6 bg-muted/20">
          {children}
        </main>
      </div>
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Dashboard layout component created
- [ ] Layout includes sidebar and navbar
- [ ] Main content area with proper padding
- [ ] State management for sidebar collapse
- [ ] Responsive layout structure

---

### TASK-003: Create Sidebar Component
- **Effort**: M (45 min)
- **Priority**: P1
- **Dependencies**: TASK-001

**Create**: `frontend/components/layout/sidebar.tsx`

```tsx
'use client'

import { Home, MessageSquare, Code2, BookOpen, Trophy, TrendingUp, Settings } from 'lucide-react'
import { Button } from '../ui/button'
import { cn } from '@/lib/utils'
import Link from 'next/link'
import { usePathname } from 'next/navigation'

interface SidebarProps {
  collapsed: boolean
  setCollapsed: (collapsed: boolean) => void
}

export function Sidebar({ collapsed, setCollapsed }: SidebarProps) {
  const pathname = usePathname()

  const sidebarItems = [
    {
      icon: Home,
      label: 'Dashboard',
      href: '/',
      badge: null
    },
    {
      icon: MessageSquare,
      label: 'AI Chat',
      href: '/chat',
      badge: { count: 3, variant: 'success' } as const
    },
    {
      icon: Code2,
      label: 'Code Playground',
      href: '/code',
      badge: null
    },
    {
      icon: BookOpen,
      label: 'Topics',
      href: '/topics',
      badge: { count: 12, variant: 'info' } as const
    },
    {
      icon: Trophy,
      label: 'Exercises',
      href: '/exercises',
      badge: null
    },
    {
      icon: TrendingUp,
      label: 'Progress',
      href: '/progress',
      badge: null
    },
    {
      icon: Settings,
      label: 'Settings',
      href: '/settings',
      badge: null
    },
  ]

  return (
    <aside
      className={cn(
        "h-full bg-card border-r transition-all duration-300 ease-in-out flex-col justify-between",
        collapsed ? "w-16" : "w-64"
      )}
    >
      <div className="p-4">
        <div className="flex items-center gap-2 mb-8">
          {!collapsed && (
            <h1 className="text-xl font-bold">LearnFlow</h1>
          )}
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setCollapsed(!collapsed)}
            className="ml-auto"
          >
            <span className="sr-only">Toggle sidebar</span>
            <ChevronLeftIcon className={cn(
              "h-4 w-4 transition-transform",
              collapsed && "rotate-180"
            )} />
          </Button>
        </div>

        <nav className="space-y-1">
          {sidebarItems.map((item) => {
            const isActive = pathname === item.href
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "flex items-center gap-3 rounded-lg px-3 py-2 transition-colors",
                  isActive
                    ? "bg-primary text-primary-foreground"
                    : "hover:bg-accent hover:text-accent-foreground"
                )}
              >
                <item.icon className="h-5 w-5" />
                {!collapsed && (
                  <>
                    <span>{item.label}</span>
                    {item.badge && (
                      <span className={cn(
                        "ml-auto flex h-5 w-5 items-center justify-center rounded-full text-xs",
                        item.badge.variant === 'success' ? "bg-green-500 text-white" :
                        item.badge.variant === 'info' ? "bg-blue-500 text-white" :
                        "bg-gray-500 text-white"
                      )}>
                        {item.badge.count}
                      </span>
                    )}
                  </>
                )}
              </Link>
            )
          })}
        </nav>
      </div>
    </aside>
  )
}

// We need to define ChevronLeftIcon
import { ChevronLeft as ChevronLeftIcon } from 'lucide-react'
```

**Acceptance Criteria**:
- [ ] Sidebar component created with collapsible functionality
- [ ] All navigation items from specification included
- [ ] Active route highlighting works correctly
- [ ] Badges display properly with correct variants
- [ ] Smooth transition animations on collapse/expand

---

### TASK-004: Create Navbar Component
- **Effort**: M (30 min)
- **Priority**: P1
- **Dependencies**: TASK-001

**Create**: `frontend/components/layout/navbar.tsx`

```tsx
'use client'

import { Search, Bell, Sun, Moon, Menu } from 'lucide-react'
import { Button } from '../ui/button'
import { Avatar, AvatarFallback, AvatarImage } from '../ui/avatar'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger
} from '../ui/dropdown-menu'
import { useTheme } from 'next-themes'
import { useState } from 'react'
import { Sheet, SheetContent, SheetTrigger } from '../ui/sheet'
import { MobileNav } from './mobile-nav'

export function Navbar() {
  const { theme, setTheme } = useTheme()
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

  return (
    <header className="h-16 flex items-center gap-4 border-b bg-card px-6">
      {/* Mobile menu trigger */}
      <Sheet open={mobileMenuOpen} onOpenChange={setMobileMenuOpen}>
        <SheetTrigger asChild>
          <Button
            variant="ghost"
            size="icon"
            className="md:hidden"
          >
            <Menu className="h-5 w-5" />
            <span className="sr-only">Toggle navigation menu</span>
          </Button>
        </SheetTrigger>
        <SheetContent side="left" className="w-64">
          <MobileNav onClose={() => setMobileMenuOpen(false)} />
        </SheetContent>
      </Sheet>

      {/* Search */}
      <div className="relative ml-auto flex-1 md:grow-0">
        <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
        <input
          type="search"
          placeholder="Search..."
          className="w-full rounded-lg bg-background pl-8 pr-4 py-2 text-sm md:w-64 lg:w-80"
        />
      </div>

      {/* Right side icons */}
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" className="relative">
          <Bell className="h-5 w-5" />
          <span className="sr-only">Notifications</span>
          <span className="absolute -top-1 -right-1 h-4 w-4 rounded-full bg-red-500 text-xs flex items-center justify-center text-white">
            5
          </span>
        </Button>

        <Button
          variant="ghost"
          size="icon"
          onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
        >
          {theme === 'dark' ? (
            <Sun className="h-5 w-5" />
          ) : (
            <Moon className="h-5 w-5" />
          )}
          <span className="sr-only">Toggle theme</span>
        </Button>

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="icon" className="rounded-full">
              <Avatar>
                <AvatarImage src="/placeholder-avatar.jpg" alt="@learner" />
                <AvatarFallback>LF</AvatarFallback>
              </Avatar>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuLabel>My Account</DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem>Profile</DropdownMenuItem>
            <DropdownMenuItem>Settings</DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem>Logout</DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  )
}
```

**Create**: `frontend/components/layout/mobile-nav.tsx`

```tsx
'use client'

import { Home, MessageSquare, Code2, BookOpen, Trophy, TrendingUp, Settings } from 'lucide-react'
import { Button } from '../ui/button'
import { cn } from '@/lib/utils'
import Link from 'next/link'
import { usePathname } from 'next/navigation'

interface MobileNavProps {
  onClose: () => void
}

export function MobileNav({ onClose }: MobileNavProps) {
  const pathname = usePathname()

  const navItems = [
    {
      icon: Home,
      label: 'Dashboard',
      href: '/'
    },
    {
      icon: MessageSquare,
      label: 'AI Chat',
      href: '/chat'
    },
    {
      icon: Code2,
      label: 'Code Playground',
      href: '/code'
    },
    {
      icon: BookOpen,
      label: 'Topics',
      href: '/topics'
    },
    {
      icon: Trophy,
      label: 'Exercises',
      href: '/exercises'
    },
    {
      icon: TrendingUp,
      label: 'Progress',
      href: '/progress'
    },
    {
      icon: Settings,
      label: 'Settings',
      href: '/settings'
    },
  ]

  return (
    <div className="flex flex-col space-y-2 mt-8">
      {navItems.map((item) => {
        const isActive = pathname === item.href
        return (
          <Link
            key={item.href}
            href={item.href}
            onClick={onClose}
            className={cn(
              "flex items-center gap-3 rounded-lg px-3 py-2 transition-colors",
              isActive
                ? "bg-primary text-primary-foreground"
                : "hover:bg-accent hover:text-accent-foreground"
            )}
          >
            <item.icon className="h-5 w-5" />
            <span>{item.label}</span>
          </Link>
        )
      })}
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Navbar component created with search functionality
- [ ] Theme toggle working correctly
- [ ] Notification bell with badge counter
- [ ] User dropdown menu with profile options
- [ ] Mobile navigation accessible via hamburger menu
- [ ] All elements properly positioned and styled

---

## Phase 2: AI Chat Interface (3 hours)

### TASK-050: Create AI Chat Page Structure
- **Effort**: M (45 min)
- **Priority**: P1
- **Dependencies**: Phase 1 complete

**Create**: `frontend/app/(dashboard)/chat/page.tsx`

```tsx
'use client'

import { ChatInterface } from '@/components/chat/chat-interface'

export default function ChatPage() {
  return (
    <div className="container mx-auto py-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold">AI Learning Assistant</h1>
        <p className="text-muted-foreground">
          Get help with Python concepts, debugging, and exercises
        </p>
      </div>

      <div className="bg-card rounded-lg border h-[calc(100vh-200px)]">
        <ChatInterface />
      </div>
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Chat page created with proper layout
- [ ] Page includes header with title and description
- [ ] Chat interface component integrated
- [ ] Responsive height calculation for chat area
- [ ] Proper container and styling classes

---

### TASK-051: Create Chat Interface Component
- **Effort**: L (90 min)
- **Priority**: P1
- **Dependencies**: TASK-050

**Create**: `frontend/components/chat/chat-interface.tsx`

```tsx
'use client'

import { useState, useRef, useEffect } from 'react'
import { MessageList } from './message-list'
import { MessageInput } from './message-input'
import { TypingIndicator } from './typing-indicator'
import { BotMessageSquare, User } from 'lucide-react'

interface Message {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
}

export function ChatInterface() {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      role: 'assistant',
      content: 'Hello! I\'m your AI learning assistant. How can I help you with Python today?',
      timestamp: new Date(Date.now() - 300000)
    }
  ])
  const [inputValue, setInputValue] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const messagesEndRef = useRef<HTMLDivElement>(null)

  // Auto-scroll to bottom when messages change
  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!inputValue.trim() || isLoading) return

    // Add user message
    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: inputValue,
      timestamp: new Date()
    }

    setMessages(prev => [...prev, userMessage])
    setInputValue('')
    setIsLoading(true)

    try {
      // Simulate API call to AI service
      setTimeout(() => {
        const aiResponse: Message = {
          id: (Date.now() + 1).toString(),
          role: 'assistant',
          content: `I understand you're asking about "${inputValue}". This is a simulated response from the AI tutor. In a real implementation, this would connect to an AI service like OpenAI to provide detailed explanations, code examples, and personalized learning guidance.`,
          timestamp: new Date()
        }
        setMessages(prev => [...prev, aiResponse])
        setIsLoading(false)
      }, 1500)
    } catch (error) {
      console.error('Error getting AI response:', error)
      setIsLoading(false)
    }
  }

  return (
    <div className="flex flex-col h-full">
      <div className="p-4 border-b">
        <div className="flex items-center gap-3">
          <BotMessageSquare className="h-8 w-8 text-primary" />
          <div>
            <h2 className="font-semibold">AI Learning Assistant</h2>
            <p className="text-xs text-muted-foreground">Available to help 24/7</p>
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-4">
        <MessageList messages={messages} />
        <div ref={messagesEndRef} />
      </div>

      {isLoading && (
        <div className="px-4 py-2">
          <TypingIndicator />
        </div>
      )}

      <div className="border-t p-4">
        <MessageInput
          value={inputValue}
          onChange={setInputValue}
          onSubmit={handleSubmit}
          disabled={isLoading}
        />
      </div>
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Chat interface component created with proper structure
- [ ] Message history display with auto-scroll
- [ ] Input area with submit functionality
- [ ] Typing indicator during AI processing
- [ ] Proper state management for messages and loading states
- [ ] Simulated AI response for demonstration

---

### TASK-052: Create Message Components
- **Effort**: M (45 min)
- **Priority**: P1
- **Dependencies**: TASK-051

**Create**: `frontend/components/chat/message-list.tsx`

```tsx
import { Message } from './chat-interface'
import { MessageBubble } from './message-bubble'

interface MessageListProps {
  messages: Message[]
}

export function MessageList({ messages }: MessageListProps) {
  return (
    <div className="space-y-4">
      {messages.map((message) => (
        <MessageBubble
          key={message.id}
          role={message.role}
          content={message.content}
          timestamp={message.timestamp}
        />
      ))}
    </div>
  )
}
```

**Create**: `frontend/components/chat/message-bubble.tsx`

```tsx
import { cn } from '@/lib/utils'
import { BotMessageSquare, User } from 'lucide-react'

interface MessageBubbleProps {
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
}

export function MessageBubble({ role, content, timestamp }: MessageBubbleProps) {
  const isUser = role === 'user'

  return (
    <div className={cn(
      "flex gap-3 max-w-3xl",
      isUser ? "ml-auto flex-row-reverse" : "mr-auto"
    )}>
      <div className={cn(
        "flex h-10 w-10 shrink-0 select-none items-center justify-center rounded-full border",
        isUser ? "bg-primary text-primary-foreground" : "bg-secondary text-secondary-foreground"
      )}>
        {isUser ? <User className="h-5 w-5" /> : <BotMessageSquare className="h-5 w-5" />}
      </div>

      <div className={cn(
        "flex-1 space-y-2 overflow-hidden rounded-2xl px-4 py-3",
        isUser
          ? "bg-primary text-primary-foreground rounded-tr-md"
          : "bg-secondary text-secondary-foreground rounded-tl-md"
      )}>
        <div className="prose prose-sm dark:prose-invert max-w-none">
          {content.split('\n').map((paragraph, i) => (
            <p key={i}>{paragraph}</p>
          ))}
        </div>

        <div className={cn(
          "text-xs opacity-70",
          isUser ? "text-right" : "text-left"
        )}>
          {timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
        </div>
      </div>
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Message list component displays all messages
- [ ] Message bubble component with proper styling for user/assistant
- [ ] Timestamps displayed for each message
- [ ] Different styling for user vs assistant messages
- [ ] Proper alignment (user messages on right, assistant on left)

---

### TASK-053: Create Input and Typing Components
- **Effort**: M (30 min)
- **Priority**: P1
- **Dependencies**: TASK-052

**Create**: `frontend/components/chat/message-input.tsx`

```tsx
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'
import { Send } from 'lucide-react'
import { ChangeEvent } from 'react'

interface MessageInputProps {
  value: string
  onChange: (value: string) => void
  onSubmit: (e: React.FormEvent) => void
  disabled: boolean
}

export function MessageInput({ value, onChange, onSubmit, disabled }: MessageInputProps) {
  const handleChange = (e: ChangeEvent<HTMLTextAreaElement>) => {
    onChange(e.target.value)
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      if (!disabled) {
        onSubmit(e as unknown as React.FormEvent)
      }
    }
  }

  return (
    <form onSubmit={onSubmit} className="relative">
      <Textarea
        value={value}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        placeholder="Type your question here..."
        className="min-h-[60px] resize-none pr-12"
        disabled={disabled}
      />
      <Button
        type="submit"
        size="sm"
        className="absolute right-2 top-2"
        disabled={disabled || !value.trim()}
      >
        <Send className="h-4 w-4" />
        <span className="sr-only">Send</span>
      </Button>
    </form>
  )
}
```

**Create**: `frontend/components/chat/typing-indicator.tsx`

```tsx
import { cn } from '@/lib/utils'

export function TypingIndicator() {
  return (
    <div className="flex items-center gap-2 text-sm text-muted-foreground">
      <div className="flex space-x-1">
        <div className="h-2 w-2 rounded-full bg-current animate-bounce"></div>
        <div className="h-2 w-2 rounded-full bg-current animate-bounce" style={{ animationDelay: '0.2s' }}></div>
        <div className="h-2 w-2 rounded-full bg-current animate-bounce" style={{ animationDelay: '0.4s' }}></div>
      </div>
      <span>AI is thinking...</span>
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Message input component with textarea and send button
- [ ] Enter key submits message (Shift+Enter for new line)
- [ ] Send button disabled when input is empty
- [ ] Typing indicator with bouncing animation
- [ ] Proper disabled states during AI processing

---

## Phase 3: Code Editor Interface (3 hours)

### TASK-100: Create Code Editor Page
- **Effort**: M (30 min)
- **Priority**: P1
- **Dependencies**: Phase 1 complete

**Create**: `frontend/app/(dashboard)/code/page.tsx`

```tsx
'use client'

import { CodeEditor } from '@/components/code-editor/monaco-editor'

export default function CodePage() {
  return (
    <div className="container mx-auto py-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold">Code Playground</h1>
        <p className="text-muted-foreground">
          Practice Python coding with syntax highlighting and execution
        </p>
      </div>

      <div className="bg-card rounded-lg border h-[calc(100vh-200px)]">
        <CodeEditor />
      </div>
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Code playground page created with proper layout
- [ ] Page includes header with title and description
- [ ] Code editor component integrated
- [ ] Responsive height calculation for editor area

---

### TASK-101: Create Monaco Editor Component
- **Effort**: L (90 min)
- **Priority**: P1
- **Dependencies**: TASK-100

**Create**: `frontend/components/code-editor/monaco-editor.tsx`

```tsx
'use client'

import dynamic from 'next/dynamic'
import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Play, Save, Palette } from 'lucide-react'
import { EditorToolbar } from './editor-toolbar'
import { OutputPanel } from './output-panel'

// Dynamically import Monaco Editor to avoid SSR issues
const MonacoEditor = dynamic(() => import('@monaco-editor/react'), {
  ssr: false,
  loading: () => <div className="bg-muted rounded-md h-full flex items-center justify-center">Loading editor...</div>
})

export function CodeEditor() {
  const [code, setCode] = useState<string>(
`# Welcome to the LearnFlow Code Playground
# Try running this Python code to get started

def greet(name):
    return f"Hello, {name}! Welcome to Python programming."

print(greet("Student"))
print("Practice makes perfect!")
`
  )
  const [language, setLanguage] = useState<'python' | 'javascript'>('python')
  const [theme, setTheme] = useState('vs-dark')
  const [output, setOutput] = useState<string>('')
  const [isRunning, setIsRunning] = useState(false)

  // Handle code execution
  const runCode = async () => {
    setIsRunning(true)
    setOutput('Running code...\n')

    // Simulate code execution
    setTimeout(() => {
      setOutput(`Hello, Student! Welcome to Python programming.\nPractice makes perfect!\n\nCode executed successfully!`)
      setIsRunning(false)
    }, 1500)
  }

  // Handle code saving
  const saveCode = () => {
    // In a real implementation, this would save to a backend
    alert('Code saved successfully!')
  }

  // Handle theme change
  const toggleTheme = () => {
    setTheme(prev => prev === 'vs-dark' ? 'vs' : 'vs-dark')
  }

  return (
    <div className="flex flex-col h-full">
      <EditorToolbar
        onRun={runCode}
        onSave={saveCode}
        onThemeToggle={toggleTheme}
        isRunning={isRunning}
        theme={theme}
      />

      <div className="flex flex-1 overflow-hidden">
        <div className="flex-1">
          <MonacoEditor
            height="100%"
            language={language}
            value={code}
            theme={theme}
            onChange={(value) => setCode(value || '')}
            options={{
              minimap: { enabled: true },
              fontSize: 14,
              fontFamily: 'JetBrains Mono, Fira Code, monospace',
              lineNumbers: 'on',
              roundedSelection: false,
              scrollBeyondLastLine: false,
              automaticLayout: true,
              tabSize: 4,
              insertSpaces: true,
            }}
          />
        </div>

        <div className="w-80 border-l">
          <OutputPanel output={output} />
        </div>
      </div>
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Monaco editor integrated with dynamic import
- [ ] Code execution simulation with output panel
- [ ] Theme switching functionality
- [ ] Proper editor configuration (font, line numbers, etc.)
- [ ] Responsive layout with editor and output panels

---

### TASK-102: Create Editor Toolbar and Output Components
- **Effort**: M (45 min)
- **Priority**: P1
- **Dependencies**: TASK-101

**Create**: `frontend/components/code-editor/editor-toolbar.tsx`

```tsx
import { Button } from '@/components/ui/button'
import { Play, Save, Palette } from 'lucide-react'

interface EditorToolbarProps {
  onRun: () => void
  onSave: () => void
  onThemeToggle: () => void
  isRunning: boolean
  theme: string
}

export function EditorToolbar({ onRun, onSave, onThemeToggle, isRunning, theme }: EditorToolbarProps) {
  return (
    <div className="flex items-center justify-between p-3 border-b bg-muted">
      <div className="flex items-center gap-2">
        <Button
          variant="default"
          size="sm"
          onClick={onRun}
          disabled={isRunning}
        >
          {isRunning ? (
            <>
              <Play className="mr-2 h-4 w-4 animate-pulse" />
              Running...
            </>
          ) : (
            <>
              <Play className="mr-2 h-4 w-4" />
              Run Code
            </>
          )}
        </Button>

        <Button
          variant="outline"
          size="sm"
          onClick={onSave}
        >
          <Save className="mr-2 h-4 w-4" />
          Save
        </Button>
      </div>

      <div className="flex items-center gap-2">
        <Button
          variant="outline"
          size="sm"
          onClick={onThemeToggle}
        >
          <Palette className="mr-2 h-4 w-4" />
          {theme === 'vs-dark' ? 'Light Theme' : 'Dark Theme'}
        </Button>
      </div>
    </div>
  )
}
```

**Create**: `frontend/components/code-editor/output-panel.tsx`

```tsx
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Terminal } from 'lucide-react'

interface OutputPanelProps {
  output: string
}

export function OutputPanel({ output }: OutputPanelProps) {
  return (
    <Card className="h-full border-0 rounded-none shadow-none">
      <CardHeader className="pb-2">
        <div className="flex items-center gap-2">
          <Terminal className="h-4 w-4" />
          <CardTitle className="text-sm font-medium">Output</CardTitle>
        </div>
      </CardHeader>
      <CardContent className="p-0 h-[calc(100%-40px)]">
        <div className="h-full bg-black text-green-400 font-mono text-sm p-3 overflow-auto">
          {output || (
            <div className="text-muted-foreground italic">
              Output will appear here after running code...
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  )
}
```

**Acceptance Criteria**:
- [ ] Editor toolbar with run, save, and theme buttons
- [ ] Output panel with terminal-like styling
- [ ] Proper state management for running state
- [ ] Visual feedback during code execution
- [ ] Responsive layout that works with editor

---

## Phase 4: Progress Dashboard (4 hours)

### TASK-150: Create Progress Dashboard Page
- **Effort**: M (30 min)
- **Priority**: P1
- [ ] **Dependencies**: Phase 1 complete

**Create**: `frontend/app/(dashboard)/progress/page.tsx`

```tsx
'use client'

import { ProgressOverview } from '@/components/progress/progress-overview'
import { TopicMastery } from '@/components/progress/topic-mastery'
import { SkillRadar } from '@/components/progress/skill-radar'
import { RecentActivity } from '@/components/progress/recent-activity'

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
        <TopicMastery />
        <SkillRadar />
      </div>
      <RecentActivity />
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Progress dashboard page created with proper layout
- [ ] Page includes header with title and description
- [ ] All progress components integrated
- [ ] Responsive grid layout for charts

---

### TASK-151: Create Progress Overview Component
- **Effort**: M (45 min)
- **Priority**: P1
- **Dependencies**: TASK-150

**Create**: `frontend/components/progress/progress-overview.tsx`

```tsx
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Flame, Trophy, TrendingUp, Target } from 'lucide-react'

export function ProgressOverview() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Learning Streak</CardTitle>
          <Flame className="h-4 w-4 text-orange-500" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">7 days</div>
          <p className="text-xs text-muted-foreground">Keep it up!</p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">XP Earned</CardTitle>
          <Trophy className="h-4 w-4 text-yellow-500" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">1,250</div>
          <p className="text-xs text-muted-foreground">+120 this week</p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Exercises Completed</CardTitle>
          <TrendingUp className="h-4 w-4 text-green-500" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">24</div>
          <p className="text-xs text-muted-foreground">+5 this week</p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Mastery</CardTitle>
          <Target className="h-4 w-4 text-purple-500" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">68%</div>
          <p className="text-xs text-muted-foreground">of Python fundamentals</p>
        </CardContent>
      </Card>
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Progress overview component with 4 key metrics
- [ ] Each metric card with appropriate icon and styling
- [ ] Responsive grid layout that adapts to screen size
- [ ] Proper typography and spacing

---

### TASK-152: Create Topic Mastery Component
- **Effort**: M (45 min)
- **Priority**: P1
- **Dependencies**: TASK-150

**Create**: `frontend/components/progress/topic-mastery.tsx`

```tsx
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'

interface Topic {
  name: string
  progress: number
  color: string
}

export function TopicMastery() {
  const topics: Topic[] = [
    { name: 'Variables & Data Types', progress: 90, color: 'bg-blue-500' },
    { name: 'Control Flow', progress: 85, color: 'bg-green-500' },
    { name: 'Functions', progress: 75, color: 'bg-purple-500' },
    { name: 'Loops', progress: 80, color: 'bg-yellow-500' },
    { name: 'Lists & Tuples', progress: 70, color: 'bg-pink-500' },
    { name: 'Dictionaries', progress: 65, color: 'bg-indigo-500' },
  ]

  return (
    <Card>
      <CardHeader>
        <CardTitle>Topic Mastery</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {topics.map((topic, index) => (
            <div key={index} className="space-y-2">
              <div className="flex justify-between">
                <span className="text-sm font-medium">{topic.name}</span>
                <span className="text-sm text-muted-foreground">{topic.progress}%</span>
              </div>
              <Progress value={topic.progress} className="h-2" indicatorClassName={topic.color} />
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
```

**Acceptance Criteria**:
- [ ] Topic mastery component with progress bars
- [ ] Each topic shows name, percentage, and progress bar
- [ ] Different colors for each topic
- [ ] Proper spacing and alignment

---

### TASK-153: Create Charts Components
- **Effort**: L (90 min)
- **Priority**: P1
- **Dependencies**: TASK-150

**Create**: `frontend/components/progress/skill-radar.tsx`

```tsx
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import {
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  Radar,
  ResponsiveContainer
} from 'recharts'

const data = [
  { subject: 'Loops', A: 80, fullMark: 100 },
  { subject: 'Functions', A: 65, fullMark: 100 },
  { subject: 'OOP', A: 40, fullMark: 100 },
  { subject: 'Debugging', A: 70, fullMark: 100 },
  { subject: 'Data Structures', A: 55, fullMark: 100 },
  { subject: 'Algorithms', A: 45, fullMark: 100 },
]

export function SkillRadar() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Skill Radar</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="h-80">
          <ResponsiveContainer width="100%" height="100%">
            <RadarChart cx="50%" cy="50%" outerRadius="80%" data={data}>
              <PolarGrid />
              <PolarAngleAxis dataKey="subject" />
              <PolarRadiusAxis angle={30} domain={[0, 100]} />
              <Radar
                name="Skills"
                dataKey="A"
                stroke="#8884d8"
                fill="#8884d8"
                fillOpacity={0.3}
              />
            </RadarChart>
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  )
}
```

**Create**: `frontend/components/progress/recent-activity.tsx`

```tsx
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Calendar, Trophy, BookOpen, Clock } from 'lucide-react'

interface Activity {
  id: string
  type: 'exercise' | 'topic' | 'achievement'
  title: string
  description: string
  time: string
}

export function RecentActivity() {
  const activities: Activity[] = [
    {
      id: '1',
      type: 'exercise',
      title: 'Completed FizzBuzz Challenge',
      description: 'Solved with 95% accuracy',
      time: '2 hours ago'
    },
    {
      id: '2',
      type: 'topic',
      title: 'Unlocked Functions Module',
      description: 'Started learning about functions',
      time: '5 hours ago'
    },
    {
      id: '3',
      type: 'achievement',
      title: '7-Day Streak Milestone',
      description: 'Maintained daily learning streak',
      time: '1 day ago'
    },
    {
      id: '4',
      type: 'exercise',
      title: 'Passed Loops Quiz',
      description: 'Scored 8/10 on loops concepts',
      time: '1 day ago'
    }
  ]

  const getActivityIcon = (type: Activity['type']) => {
    switch (type) {
      case 'exercise': return <Trophy className="h-4 w-4" />
      case 'topic': return <BookOpen className="h-4 w-4" />
      case 'achievement': return <Trophy className="h-4 w-4 text-yellow-500" />
      default: return <Clock className="h-4 w-4" />
    }
  }

  const getActivityBadge = (type: Activity['type']) => {
    switch (type) {
      case 'exercise': return <Badge variant="secondary">Exercise</Badge>
      case 'topic': return <Badge variant="outline">Topic</Badge>
      case 'achievement': return <Badge variant="default">Achievement</Badge>
      default: return null
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Recent Activity</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {activities.map((activity) => (
            <div key={activity.id} className="flex items-start gap-3 pb-3 border-b last:border-0 last:pb-0">
              <div className="mt-0.5 rounded-full bg-muted p-2">
                {getActivityIcon(activity.type)}
              </div>
              <div className="flex-1 space-y-1">
                <div className="flex items-center gap-2">
                  <h3 className="font-medium leading-none">{activity.title}</h3>
                  {getActivityBadge(activity.type)}
                </div>
                <p className="text-sm text-muted-foreground">{activity.description}</p>
                <p className="text-xs text-muted-foreground">{activity.time}</p>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
```

**Acceptance Criteria**:
- [ ] Skill radar chart component with Recharts
- [ ] Recent activity timeline with different activity types
- [ ] Proper icons and badges for different activity types
- [ ] Responsive chart sizing

---

## Phase 5: Exercises Interface (3 hours)

### TASK-200: Create Exercises Page
- **Effort**: M (30 min)
- **Priority**: P1
- **Dependencies**: Phase 1 complete

**Create**: `frontend/app/(dashboard)/exercises/page.tsx`

```tsx
'use client'

import { useState } from 'react'
import { ExerciseList } from '@/components/exercises/exercise-list'
import { FilterPanel } from '@/components/search/search-filters'

export default function ExercisesPage() {
  const [filters, setFilters] = useState({
    difficulty: 'all',
    topic: 'all',
    status: 'all'
  })

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
          <FilterPanel filters={filters} onFiltersChange={setFilters} />
        </div>
        <div className="flex-1">
          <ExerciseList filters={filters} />
        </div>
      </div>
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Exercises page with filter sidebar and list
- [ ] Page includes header with title and description
- [ ] Filter panel integrated with exercise list
- [ ] Responsive layout that adapts to screen size

---

### TASK-201: Create Exercise Components
- **Effort**: L (90 min)
- **Priority**: P1
- **Dependencies**: TASK-200

**Create**: `frontend/components/exercises/exercise-list.tsx`

```tsx
import { ExerciseCard } from './exercise-card'

interface ExerciseListProps {
  filters: {
    difficulty: string
    topic: string
    status: string
  }
}

// Mock data for exercises
const mockExercises = [
  {
    id: '1',
    title: 'FizzBuzz Challenge',
    description: 'Write a program that prints numbers 1-100, but replace multiples of 3 with "Fizz", multiples of 5 with "Buzz", and multiples of both with "FizzBuzz"',
    difficulty: 'medium' as const,
    topic: 'loops',
    solvedCount: 1240,
    avgTime: '15 min',
    xpReward: 50,
    status: 'available' as const
  },
  {
    id: '2',
    title: 'Palindrome Checker',
    description: 'Create a function that checks if a string is a palindrome (reads the same forwards and backwards)',
    difficulty: 'easy' as const,
    topic: 'strings',
    solvedCount: 890,
    avgTime: '10 min',
    xpReward: 30,
    status: 'available' as const
  },
  {
    id: '3',
    title: 'Factorial Calculator',
    description: 'Implement a recursive function to calculate the factorial of a number',
    difficulty: 'medium' as const,
    topic: 'recursion',
    solvedCount: 650,
    avgTime: '20 min',
    xpReward: 40,
    status: 'available' as const
  },
  {
    id: '4',
    title: 'Binary Search',
    description: 'Implement an efficient binary search algorithm to find an element in a sorted array',
    difficulty: 'hard' as const,
    topic: 'algorithms',
    solvedCount: 420,
    avgTime: '30 min',
    xpReward: 70,
    status: 'locked' as const
  }
]

export function ExerciseList({ filters }: ExerciseListProps) {
  // In a real implementation, this would filter the exercises based on the filters
  const filteredExercises = mockExercises.filter(exercise => {
    if (filters.difficulty !== 'all' && exercise.difficulty !== filters.difficulty) {
      return false
    }
    if (filters.topic !== 'all' && exercise.topic !== filters.topic) {
      return false
    }
    if (filters.status !== 'all' && exercise.status !== filters.status) {
      return false
    }
    return true
  })

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {filteredExercises.map((exercise) => (
        <ExerciseCard key={exercise.id} exercise={exercise} />
      ))}
    </div>
  )
}
```

**Create**: `frontend/components/exercises/exercise-card.tsx`

```tsx
import { Card, CardContent, CardFooter, CardHeader } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Users, Clock, Trophy, Lock, CircleDot } from 'lucide-react'
import { Exercise } from './exercise-list'

interface ExerciseCardProps {
  exercise: Exercise
}

export function ExerciseCard({ exercise }: ExerciseCardProps) {
  const getDifficultyVariant = (level: Exercise['difficulty']) => {
    switch (level) {
      case 'easy': return 'success'
      case 'medium': return 'warning'
      case 'hard': return 'destructive'
      default: return 'secondary'
    }
  }

  const getDifficultyIcon = (level: Exercise['difficulty']) => {
    switch (level) {
      case 'easy': return <CircleDot className="h-3 w-3" />
      case 'medium': return <CircleDot className="h-3 w-3" />
      case 'hard': return <CircleDot className="h-3 w-3" />
      default: return null
    }
  }

  return (
    <Card className={exercise.status === 'locked' ? 'opacity-70' : ''}>
      <CardHeader className="pb-3">
        <div className="flex justify-between items-start">
          <h3 className="font-semibold leading-none tracking-tight">{exercise.title}</h3>
          <Badge
            variant={exercise.status === 'locked' ? 'secondary' : getDifficultyVariant(exercise.difficulty)}
            className="gap-1"
          >
            {exercise.status === 'locked' ? <Lock className="h-3 w-3" /> : getDifficultyIcon(exercise.difficulty)}
            {exercise.status === 'locked' ? 'Locked' : exercise.difficulty.charAt(0).toUpperCase() + exercise.difficulty.slice(1)}
          </Badge>
        </div>
      </CardHeader>
      <CardContent className="pb-3">
        <p className="text-sm text-muted-foreground line-clamp-2">
          {exercise.description}
        </p>
      </CardContent>
      <CardFooter className="flex flex-wrap gap-2 pt-0">
        <div className="flex items-center text-xs text-muted-foreground gap-1">
          <Users className="h-3 w-3" />
          <span>{exercise.solvedCount.toLocaleString()}</span>
        </div>
        <div className="flex items-center text-xs text-muted-foreground gap-1">
          <Clock className="h-3 w-3" />
          <span>{exercise.avgTime}</span>
        </div>
        <div className="flex items-center text-xs text-muted-foreground gap-1">
          <Trophy className="h-3 w-3" />
          <span>{exercise.xpReward} XP</span>
        </div>
        <Button
          className="w-full mt-2"
          size="sm"
          disabled={exercise.status === 'locked'}
        >
          {exercise.status === 'locked' ? 'Unlock First' : 'Start Exercise'}
        </Button>
      </CardFooter>
    </Card>
  )
}
```

**Acceptance Criteria**:
- [ ] Exercise list component with filtering capability
- [ ] Exercise card component with difficulty badges
- [ ] Proper display of exercise stats (solved count, avg time, XP)
- [ ] Locked exercise handling with visual indication
- [ ] Responsive grid layout for exercise cards

---

### TASK-202: Create Filter Components
- **Effort**: M (30 min)
- **Priority**: P1
- **Dependencies**: TASK-201

**Create**: `frontend/components/search/search-filters.tsx`

```tsx
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Checkbox } from '@/components/ui/checkbox'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Separator } from '@/components/ui/separator'

interface FilterPanelProps {
  filters: {
    difficulty: string
    topic: string
    status: string
  }
  onFiltersChange: (filters: any) => void
}

export function FilterPanel({ filters, onFiltersChange }: FilterPanelProps) {
  const difficulties = [
    { id: 'easy', label: 'Easy' },
    { id: 'medium', label: 'Medium' },
    { id: 'hard', label: 'Hard' },
  ]

  const topics = [
    { id: 'all', label: 'All Topics' },
    { id: 'loops', label: 'Loops' },
    { id: 'functions', label: 'Functions' },
    { id: 'strings', label: 'Strings' },
    { id: 'data-structures', label: 'Data Structures' },
    { id: 'algorithms', label: 'Algorithms' },
  ]

  const statuses = [
    { id: 'all', label: 'All' },
    { id: 'available', label: 'Available' },
    { id: 'locked', label: 'Locked' },
  ]

  return (
    <Card>
      <CardHeader>
        <CardTitle>Filters</CardTitle>
      </CardHeader>
      <CardContent className="space-y-6">
        <div>
          <h3 className="text-sm font-medium mb-3">Difficulty</h3>
          <div className="space-y-2">
            {difficulties.map((diff) => (
              <div key={diff.id} className="flex items-center space-x-2">
                <Checkbox
                  id={`diff-${diff.id}`}
                  checked={filters.difficulty === diff.id || filters.difficulty === 'all'}
                  onCheckedChange={(checked) => {
                    if (checked) {
                      onFiltersChange({ ...filters, difficulty: diff.id })
                    } else if (filters.difficulty === diff.id) {
                      onFiltersChange({ ...filters, difficulty: 'all' })
                    }
                  }}
                />
                <label htmlFor={`diff-${diff.id}`} className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
                  {diff.label}
                </label>
              </div>
            ))}
          </div>
        </div>

        <Separator />

        <div>
          <h3 className="text-sm font-medium mb-3">Topic</h3>
          <Select
            value={filters.topic}
            onValueChange={(value) => onFiltersChange({ ...filters, topic: value })}
          >
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {topics.map((topic) => (
                <SelectItem key={topic.id} value={topic.id}>
                  {topic.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <Separator />

        <div>
          <h3 className="text-sm font-medium mb-3">Status</h3>
          <Select
            value={filters.status}
            onValueChange={(value) => onFiltersChange({ ...filters, status: value })}
          >
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {statuses.map((status) => (
                <SelectItem key={status.id} value={status.id}>
                  {status.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <Button
          variant="outline"
          className="w-full"
          onClick={() => onFiltersChange({ difficulty: 'all', topic: 'all', status: 'all' })}
        >
          Clear Filters
        </Button>
      </CardContent>
    </Card>
  )
}
```

**Acceptance Criteria**:
- [ ] Filter panel component with difficulty checkboxes
- [ ] Topic and status dropdown selectors
- [ ] Clear filters functionality
- [ ] Proper state management for filter changes
- [ ] Responsive design that works in sidebar

---

## Phase 6: Homepage and Final Components (2 hours)

### TASK-250: Create Dashboard Homepage
- **Effort**: M (45 min)
- **Priority**: P1
- **Dependencies**: All previous phases

**Create**: `frontend/app/(dashboard)/page.tsx`

```tsx
'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { ProgressOverview } from '@/components/progress/progress-overview'
import { RecentActivity } from '@/components/progress/recent-activity'
import { Button } from '@/components/ui/button'
import { MessageSquare, Code2, Trophy, BookOpen } from 'lucide-react'
import Link from 'next/link'

export default function HomePage() {
  return (
    <div className="container mx-auto py-6 space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Welcome back, Student!</h1>
        <p className="text-muted-foreground">
          Continue your Python learning journey
        </p>
      </div>

      <ProgressOverview />

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Link href="/chat">
          <Card className="hover:shadow-md transition-shadow cursor-pointer">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">AI Tutor</CardTitle>
              <MessageSquare className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-sm">Get help with Python concepts</div>
            </CardContent>
          </Card>
        </Link>

        <Link href="/code">
          <Card className="hover:shadow-md transition-shadow cursor-pointer">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Code Playground</CardTitle>
              <Code2 className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-sm">Practice coding in a live editor</div>
            </CardContent>
          </Card>
        </Link>

        <Link href="/exercises">
          <Card className="hover:shadow-md transition-shadow cursor-pointer">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Exercises</CardTitle>
              <Trophy className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-sm">Complete coding challenges</div>
            </CardContent>
          </Card>
        </Link>

        <Link href="/topics">
          <Card className="hover:shadow-md transition-shadow cursor-pointer">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Topics</CardTitle>
              <BookOpen className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-sm">Browse learning modules</div>
            </CardContent>
          </Card>
        </Link>
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
                <span>Hours Coded</span>
                <span className="font-medium">8.5</span>
              </div>
              <div className="flex justify-between">
                <span>Topics Mastered</span>
                <span className="font-medium">3/12</span>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Dashboard homepage with welcome message
- [ ] Quick access cards to main features
- [ ] Progress overview and quick stats
- [ ] Recent activity timeline
- [ ] Responsive grid layout

---

### TASK-251: Create Remaining UI Components
- **Effort**: M (45 min)
- **Priority**: P1
- **Dependencies**: All previous phases

**Create**: `frontend/components/shared/theme-toggle.tsx`

```tsx
'use client'

import { Moon, Sun } from 'lucide-react'
import { useTheme } from 'next-themes'

import { Button } from '@/components/ui/button'

export function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
    >
      <Sun className="h-5 w-5 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
      <Moon className="absolute h-5 w-5 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
      <span className="sr-only">Toggle theme</span>
    </Button>
  )
}
```

**Create**: `frontend/components/shared/notification-bell.tsx`

```tsx
import { Bell } from 'lucide-react'
import { Button } from '@/components/ui/button'

interface NotificationBellProps {
  count?: number
}

export function NotificationBell({ count = 0 }: NotificationBellProps) {
  return (
    <Button variant="ghost" size="icon" className="relative">
      <Bell className="h-5 w-5" />
      <span className="sr-only">Notifications</span>
      {count > 0 && (
        <span className="absolute -top-1 -right-1 h-4 w-4 rounded-full bg-red-500 text-xs flex items-center justify-center text-white">
          {count}
        </span>
      )}
    </Button>
  )
}
```

**Create**: `frontend/components/shared/loading-spinner.tsx`

```tsx
import { Loader2 } from 'lucide-react'

interface LoadingSpinnerProps {
  size?: 'sm' | 'md' | 'lg'
  text?: string
}

export function LoadingSpinner({ size = 'md', text }: LoadingSpinnerProps) {
  const sizeClasses = {
    sm: 'h-4 w-4',
    md: 'h-8 w-8',
    lg: 'h-12 w-12'
  }

  return (
    <div className="flex flex-col items-center justify-center gap-2">
      <Loader2 className={`animate-spin ${sizeClasses[size]}`} />
      {text && <p className="text-sm text-muted-foreground">{text}</p>}
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Theme toggle component with sun/moon icons
- [ ] Notification bell with badge counter
- [ ] Loading spinner with different sizes
- [ ] Proper accessibility attributes
- [ ] Responsive sizing options

---

## Phase 7: Authentication Pages (2 hours)

### TASK-300: Create Authentication Pages
- **Effort**: M (60 min)
- **Priority**: P2
- **Dependencies**: Phase 1 complete

**Create**: `frontend/app/(auth)/login/page.tsx`

```tsx
'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'
import { Github, Chrome } from 'lucide-react'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // In a real implementation, this would authenticate the user
    console.log('Login attempt with:', { email, password })
  }

  return (
    <div className="container flex h-screen w-screen flex-col items-center justify-center lg:grid lg:max-w-none lg:grid-cols-2 lg:px-0">
      <div className="hidden lg:block bg-muted h-full" />
      <div className="lg:p-8">
        <div className="mx-auto flex w-full flex-col justify-center space-y-6 sm:w-[350px]">
          <Card>
            <CardHeader className="space-y-1">
              <CardTitle className="text-2xl">Welcome back</CardTitle>
              <CardDescription>
                Enter your credentials to access your learning dashboard
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-4">
              <form onSubmit={handleSubmit}>
                <div className="grid gap-2">
                  <Label htmlFor="email">Email</Label>
                  <Input
                    id="email"
                    type="email"
                    placeholder="name@example.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                  />
                </div>
                <div className="grid gap-2 mt-2">
                  <Label htmlFor="password">Password</Label>
                  <Input
                    id="password"
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                  />
                </div>
                <Button className="w-full mt-4" type="submit">
                  Sign In
                </Button>
              </form>
            </CardContent>
            <CardFooter className="flex flex-col">
              <Separator className="my-4" />
              <div className="grid grid-cols-2 gap-2">
                <Button variant="outline">
                  <Github className="mr-2 h-4 w-4" />
                  GitHub
                </Button>
                <Button variant="outline">
                  <Chrome className="mr-2 h-4 w-4" />
                  Google
                </Button>
              </div>
              <p className="mt-4 text-center text-sm text-muted-foreground">
                Don't have an account?{' '}
                <a href="/register" className="underline underline-offset-4 hover:text-primary">
                  Sign up
                </a>
              </p>
            </CardFooter>
          </Card>
        </div>
      </div>
    </div>
  )
}
```

**Create**: `frontend/app/(auth)/register/page.tsx`

```tsx
'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'
import { Github, Chrome } from 'lucide-react'

export default function RegisterPage() {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // In a real implementation, this would register the user
    console.log('Registration attempt with:', { name, email, password })
  }

  return (
    <div className="container flex h-screen w-screen flex-col items-center justify-center lg:grid lg:max-w-none lg:grid-cols-2 lg:px-0">
      <div className="hidden lg:block bg-muted h-full" />
      <div className="lg:p-8">
        <div className="mx-auto flex w-full flex-col justify-center space-y-6 sm:w-[350px]">
          <Card>
            <CardHeader className="space-y-1">
              <CardTitle className="text-2xl">Create an account</CardTitle>
              <CardDescription>
                Enter your information to get started with LearnFlow
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-4">
              <form onSubmit={handleSubmit}>
                <div className="grid gap-2">
                  <Label htmlFor="name">Full Name</Label>
                  <Input
                    id="name"
                    type="text"
                    placeholder="John Doe"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    required
                  />
                </div>
                <div className="grid gap-2 mt-2">
                  <Label htmlFor="email">Email</Label>
                  <Input
                    id="email"
                    type="email"
                    placeholder="name@example.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                  />
                </div>
                <div className="grid gap-2 mt-2">
                  <Label htmlFor="password">Password</Label>
                  <Input
                    id="password"
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                  />
                </div>
                <Button className="w-full mt-4" type="submit">
                  Create Account
                </Button>
              </form>
            </CardContent>
            <CardFooter className="flex flex-col">
              <Separator className="my-4" />
              <div className="grid grid-cols-2 gap-2">
                <Button variant="outline">
                  <Github className="mr-2 h-4 w-4" />
                  GitHub
                </Button>
                <Button variant="outline">
                  <Chrome className="mr-2 h-4 w-4" />
                  Google
                </Button>
              </div>
              <p className="mt-4 text-center text-sm text-muted-foreground">
                Already have an account?{' '}
                <a href="/login" className="underline underline-offset-4 hover:text-primary">
                  Sign in
                </a>
              </p>
            </CardFooter>
          </Card>
        </div>
      </div>
    </div>
  )
}
```

**Acceptance Criteria**:
- [ ] Login page with email/password form
- [ ] Registration page with name/email/password form
- [ ] Social login options (GitHub, Google)
- [ ] Proper navigation between auth pages
- [ ] Responsive layout that works on all devices

---

### TASK-301: Create Animation Components
- **Effort**: M (30 min)
- **Priority**: P2
- **Dependencies**: Phase 1 complete

**Create**: `frontend/components/animations/page-transition.tsx`

```tsx
'use client'

import { motion } from 'framer-motion'

interface PageTransitionProps {
  children: React.ReactNode
}

export function PageTransition({ children }: PageTransitionProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      transition={{ duration: 0.3, ease: 'easeOut' }}
    >
      {children}
    </motion.div>
  )
}
```

**Create**: `frontend/components/animations/stagger-children.tsx`

```tsx
'use client'

import { motion } from 'framer-motion'

interface StaggerChildrenProps {
  children: React.ReactNode
  staggerAmount?: number
}

export function StaggerChildren({ children, staggerAmount = 0.1 }: StaggerChildrenProps) {
  return (
    <motion.div
      initial="hidden"
      animate="show"
      variants={{
        hidden: { opacity: 0 },
        show: {
          opacity: 1,
          transition: {
            staggerChildren: staggerAmount,
          },
        },
      }}
    >
      {Array.isArray(children)
        ? children.map((child, index) => (
            <motion.div
              key={index}
              variants={{
                hidden: { opacity: 0, y: 20 },
                show: { opacity: 1, y: 0 },
              }}
            >
              {child}
            </motion.div>
          ))
        : children}
    </motion.div>
  )
}
```

**Acceptance Criteria**:
- [ ] Page transition component with framer motion
- [ ] Stagger children animation component
- [ ] Proper variant definitions for animations
- [ ] Configurable stagger amounts

---

## Phase 8: Final Integration and Testing (2 hours)

### TASK-350: Update Global Styles and Configuration
- **Effort**: S (30 min)
- **Priority**: P0
- **Dependencies**: All components complete

**Update**: `frontend/tailwind.config.ts`

```ts
import type { Config } from 'tailwindcss'

const config: Config = {
  darkMode: ["class"],
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "accordion-down": {
          from: { height: "0" },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: "0" },
        },
        "fade-in": {
          from: { opacity: "0" },
          to: { opacity: "1" },
        },
        "slide-up": {
          from: { opacity: "0", transform: "translateY(20px)" },
          to: { opacity: "1", transform: "translateY(0)" },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
        "fade-in": "fade-in 0.3s ease-out",
        "slide-up": "slide-up 0.3s ease-out",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
export default config
```

**Update**: `frontend/tsconfig.json` (ensure proper module resolution)

**Acceptance Criteria**:
- [ ] Tailwind config updated with animation utilities
- [ ] Proper color definitions and CSS variables
- [ ] Responsive breakpoints configured
- [ ] Animation keyframes defined

---

### TASK-351: Create Utility Functions and Hooks
- **Effort**: M (45 min)
- **Priority**: P1
- **Dependencies**: TASK-350

**Create**: `frontend/lib/utils.ts`

```ts
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

// Format date in a human-readable way
export function formatDate(date: Date) {
  return new Intl.DateTimeFormat('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  }).format(date)
}

// Format time in a human-readable way
export function formatTime(date: Date) {
  return new Intl.DateTimeFormat('en-US', {
    hour: '2-digit',
    minute: '2-digit',
  }).format(date)
}

// Generate a random ID
export function generateId() {
  return Math.random().toString(36).substring(2, 9)
}

// Debounce function
export function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout | null = null
  return function executedFunction(...args: Parameters<T>) {
    const later = () => {
      timeout = null
      func(...args)
    }
    if (timeout) clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}
```

**Create**: `frontend/lib/hooks/use-theme.ts`

```ts
// This is already handled by next-themes
// Just export a simple wrapper if needed
import { useTheme as useNextTheme } from 'next-themes'

export const useTheme = () => {
  const { theme, setTheme, systemTheme } = useNextTheme()

  return {
    theme,
    setTheme,
    systemTheme,
    isDark: theme === 'dark' || (theme === 'system' && systemTheme === 'dark'),
    isLight: theme === 'light' || (theme === 'system' && systemTheme === 'light'),
  }
}
```

**Create**: `frontend/lib/hooks/use-media-query.ts`

```ts
import { useState, useEffect } from 'react'

export function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(false)

  useEffect(() => {
    const media = window.matchMedia(query)
    if (media.matches !== matches) {
      setMatches(media.matches)
    }
    const listener = () => setMatches(media.matches)
    media.addEventListener('change', listener)
    return () => media.removeEventListener('change', listener)
  }, [matches, query])

  return matches
}
```

**Acceptance Criteria**:
- [ ] Utility functions for common operations
- [ ] Theme hook wrapper for convenience
- [ ] Media query hook for responsive design
- [ ] Proper TypeScript typing

---

### TASK-352: Create Store Management
- **Effort**: M (45 min)
- **Priority**: P1
- **Dependencies**: TASK-351

**Create**: `frontend/lib/store/auth-store.ts`

```ts
import { create } from 'zustand'

interface AuthState {
  user: {
    id: string
    name: string
    email: string
    avatar?: string
  } | null
  isAuthenticated: boolean
  login: (userData: { id: string; name: string; email: string; avatar?: string }) => void
  logout: () => void
  updateUser: (userData: Partial<{ name: string; email: string; avatar?: string }>) => void
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  login: (userData) => set({ user: userData, isAuthenticated: true }),
  logout: () => set({ user: null, isAuthenticated: false }),
  updateUser: (userData) =>
    set((state) => ({
      user: state.user ? { ...state.user, ...userData } : null,
    })),
}))
```

**Create**: `frontend/lib/store/chat-store.ts`

```ts
import { create } from 'zustand'
import { Message } from '@/components/chat/chat-interface'

interface ChatState {
  messages: Message[]
  activeAgent: string
  addMessage: (message: Message) => void
  clearMessages: () => void
  setActiveAgent: (agent: string) => void
}

export const useChatStore = create<ChatState>((set) => ({
  messages: [],
  activeAgent: 'Python Concepts Tutor',
  addMessage: (message) => set((state) => ({ messages: [...state.messages, message] })),
  clearMessages: () => set({ messages: [] }),
  setActiveAgent: (agent) => set({ activeAgent: agent }),
}))
```

**Acceptance Criteria**:
- [ ] Auth store with user state management
- [ ] Chat store with message history
- [ ] Proper state update functions
- [ ] TypeScript interfaces for store state

---

## 📊 Task Summary

| Phase | Tasks | Estimated Time | Priority |
|-------|-------|----------------|----------|
| Phase 0: Setup | P001-P003 | 2 hours | P0 |
| Phase 1: Layout | 001-004 | 2 hours | P1 |
| Phase 2: Chat | 050-053 | 3 hours | P1 |
| Phase 3: Code Editor | 100-102 | 3 hours | P1 |
| Phase 4: Progress | 150-153 | 4 hours | P1 |
| Phase 5: Exercises | 200-202 | 3 hours | P1 |
| Phase 6: Homepage | 250-251 | 2 hours | P1 |
| Phase 7: Auth | 300-301 | 2 hours | P2 |
| Phase 8: Integration | 350-352 | 2 hours | P0 |
| **TOTAL** | **22 tasks** | **23 hours** | **Mixed** |

---

## 🎯 Critical Path

1. Phase 0 (Project Setup) → Blocks everything
2. Phase 1 (Layout) → Required for all pages
3. Phase 2-5 (Core Features) → Can be developed in parallel
4. Phase 6-8 (Finalization) → Final integration and polish

**Parallel Opportunities**:
- TASK-051, TASK-101, TASK-151, TASK-201 (core components)
- TASK-251, TASK-300, TASK-351 (utility components)

---

## ⚠️ Common Issues & Solutions

**Issue 1: Monaco Editor SSR Error**
```tsx
// Solution: Use dynamic import with ssr: false
const MonacoEditor = dynamic(() => import('@monaco-editor/react'), {
  ssr: false,
  loading: () => <div>Loading editor...</div>
})
```

**Issue 2: Theme Toggle Flickering**
```tsx
// Solution: Use next-themes with suppressHydrationWarning
<ThemeProvider attribute="class" defaultTheme="system" enableSystem>
  <div suppressHydrationWarning>
    {children}
  </div>
</ThemeProvider>
```

**Issue 3: Animation Performance**
```tsx
// Solution: Optimize animations with will-change and transform
.use-motion-safe .animated-element {
  will-change: transform;
}
```

**Issue 4: Responsive Layout Issues**
```tsx
// Solution: Use consistent breakpoints
const breakpoints = {
  sm: '640px',
  md: '768px',
  lg: '1024px',
  xl: '1280px',
}
```

---

## 📝 Quick Start Commands

```bash
# Setup the project:
cd /c/hackathon-3/learnflow-app/frontend
npm install
npx shadcn-ui@latest init
npx shadcn-ui@latest add button card dialog dropdown-menu input tabs badge avatar separator sheet skeleton tooltip popover select switch progress slider scroll-area command

# Run development server:
npm run dev

# Build for production:
npm run build
```

---

**End of Tasks Document**