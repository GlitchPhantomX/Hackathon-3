'use client'

import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { motion } from 'framer-motion'
import { Code, Brain, Trophy, BookOpen, Zap, Target, Award, Sparkles } from 'lucide-react'

export default function HomePage() {
  const features = [
    {
      icon: <Brain className="h-6 w-6" />,
      title: "AI-Powered Tutoring",
      description: "Get personalized help with Python concepts from our intelligent AI tutors available 24/7",
      gradient: "from-violet-500 to-purple-500"
    },
    {
      icon: <Code className="h-6 w-6" />,
      title: "Interactive Code Editor",
      description: "Practice coding in a live editor with instant feedback and syntax highlighting",
      gradient: "from-blue-500 to-cyan-500"
    },
    {
      icon: <Trophy className="h-6 w-6" />,
      title: "Challenges & Projects",
      description: "Complete real-world coding challenges and build impressive portfolio projects",
      gradient: "from-amber-500 to-orange-500"
    },
    {
      icon: <Target className="h-6 w-6" />,
      title: "Progress Tracking",
      description: "Track your learning journey with detailed analytics and achievement badges",
      gradient: "from-emerald-500 to-teal-500"
    }
  ]

  const stats = [
    { label: "Active Learners", value: "10,000+" },
    { label: "Code Challenges", value: "500+" },
    { label: "Success Rate", value: "95%" },
    { label: "AI Responses", value: "24/7" }
  ]

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  }

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.5,
        ease: "easeOut"
      }
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50 dark:from-slate-950 dark:via-slate-900 dark:to-indigo-950 relative overflow-hidden">
      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          className="absolute top-20 left-10 w-72 h-72 bg-purple-300/20 dark:bg-purple-500/10 rounded-full blur-3xl"
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.3, 0.5, 0.3],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
        <motion.div
          className="absolute bottom-20 right-10 w-96 h-96 bg-blue-300/20 dark:bg-blue-500/10 rounded-full blur-3xl"
          animate={{
            scale: [1.2, 1, 1.2],
            opacity: [0.3, 0.5, 0.3],
          }}
          transition={{
            duration: 10,
            repeat: Infinity,
            ease: "easeInOut"
          }}
        />
      </div>

      <div className="container mx-auto px-4 py-16 relative z-10">
        {/* Hero Section */}
        <motion.div
          className="text-center max-w-4xl mx-auto mb-20"
          initial="hidden"
          animate="visible"
          variants={containerVariants}
        >
          <motion.div
            variants={itemVariants}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-gradient-to-r from-purple-100 to-blue-100 dark:from-purple-900/30 dark:to-blue-900/30 border border-purple-200 dark:border-purple-700/50 mb-6"
          >
            <Sparkles className="h-4 w-4 text-purple-600 dark:text-purple-400" />
            <span className="text-sm font-medium text-purple-700 dark:text-purple-300">
              AI-Powered Learning Platform
            </span>
          </motion.div>

          <motion.h1
            variants={itemVariants}
            className="text-5xl md:text-7xl font-bold mb-6 leading-tight"
          >
            <span className="bg-clip-text text-transparent bg-gradient-to-r from-indigo-600 via-purple-600 to-pink-600 dark:from-indigo-400 dark:via-purple-400 dark:to-pink-400">
              Master Python
            </span>
            <br />
            <span className="text-slate-800 dark:text-slate-100">
              with AI Assistance
            </span>
          </motion.h1>

          <motion.p
            variants={itemVariants}
            className="text-xl text-slate-600 dark:text-slate-300 mb-10 max-w-2xl mx-auto leading-relaxed"
          >
            Transform your coding skills with personalized AI tutoring, interactive exercises,
            and real-time feedback. Start your journey to becoming a Python expert today.
          </motion.p>

          <motion.div
            variants={itemVariants}
            className="flex flex-col sm:flex-row gap-4 justify-center items-center"
          >
            <Button
              size="lg"
              asChild
              className="bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 text-white shadow-lg shadow-purple-500/30 hover:shadow-xl hover:shadow-purple-500/40 transition-all duration-300 px-8 py-6 text-lg rounded-full"
            >
              <Link href="/dashboard" className="flex items-center gap-2">
                <Zap className="h-5 w-5" />
                Get Started Free
              </Link>
            </Button>
            <Button
              size="lg"
              variant="outline"
              asChild
              className="border-2 border-slate-300 dark:border-slate-600 hover:bg-slate-100 dark:hover:bg-slate-800 px-8 py-6 text-lg rounded-full"
            >
              <Link href="/auth/login">
                Sign In
              </Link>
            </Button>
          </motion.div>
        </motion.div>

        {/* Stats Section */}
        <motion.div
          className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-20 max-w-4xl mx-auto"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          variants={containerVariants}
        >
          {stats.map((stat, index) => (
            <motion.div
              key={index}
              variants={itemVariants}
              className="text-center p-6 rounded-2xl bg-white/60 dark:bg-slate-800/60 backdrop-blur-sm border border-slate-200 dark:border-slate-700 shadow-lg"
            >
              <div className="text-3xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-indigo-600 to-purple-600 dark:from-indigo-400 dark:to-purple-400 mb-1">
                {stat.value}
              </div>
              <div className="text-sm text-slate-600 dark:text-slate-400 font-medium">
                {stat.label}
              </div>
            </motion.div>
          ))}
        </motion.div>

        {/* Features Section */}
        <motion.div
          className="mb-20"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          variants={containerVariants}
        >
          <motion.div variants={itemVariants} className="text-center mb-12">
            <h2 className="text-4xl md:text-5xl font-bold text-slate-800 dark:text-slate-100 mb-4">
              Everything You Need to Learn
            </h2>
            <p className="text-xl text-slate-600 dark:text-slate-300 max-w-2xl mx-auto">
              Powerful features designed to accelerate your Python learning journey
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 max-w-7xl mx-auto">
            {features.map((feature, index) => (
              <motion.div
                key={index}
                variants={itemVariants}
                whileHover={{
                  y: -8,
                  transition: { duration: 0.3 }
                }}
              >
                <Card className="h-full bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm border-slate-200 dark:border-slate-700 shadow-lg hover:shadow-2xl transition-all duration-300 group overflow-hidden relative">
                  <div className={`absolute inset-0 bg-gradient-to-br ${feature.gradient} opacity-0 group-hover:opacity-5 transition-opacity duration-300`} />

                  <CardHeader className="relative">
                    <div className={`inline-flex p-3 rounded-xl bg-gradient-to-br ${feature.gradient} text-white mb-4 shadow-lg`}>
                      {feature.icon}
                    </div>
                    <CardTitle className="text-xl font-bold text-slate-800 dark:text-slate-100">
                      {feature.title}
                    </CardTitle>
                  </CardHeader>

                  <CardContent className="relative">
                    <CardDescription className="text-slate-600 dark:text-slate-400 leading-relaxed">
                      {feature.description}
                    </CardDescription>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </div>
        </motion.div>

        {/* CTA Section */}
        <motion.div
          className="max-w-4xl mx-auto"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          variants={containerVariants}
        >
          <motion.div variants={itemVariants}>
            <Card className="relative overflow-hidden bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-600 border-0 shadow-2xl">
              <div className="absolute inset-0 bg-grid-white/10 [mask-image:linear-gradient(0deg,transparent,rgba(255,255,255,0.5))]" />

              <CardHeader className="relative text-center pb-4">
                <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-white/20 backdrop-blur-sm mb-4 mx-auto">
                  <Award className="h-8 w-8 text-white" />
                </div>
                <CardTitle className="text-3xl md:text-4xl font-bold text-white mb-3">
                  Ready to Start Your Journey?
                </CardTitle>
                <CardDescription className="text-lg text-indigo-100">
                  Join thousands of students already mastering Python with our AI-powered platform.
                  Start learning for free today!
                </CardDescription>
              </CardHeader>

              <CardContent className="relative text-center pt-2 pb-8">
                <Button
                  size="lg"
                  className="bg-white text-indigo-600 hover:bg-indigo-50 shadow-xl hover:shadow-2xl transition-all duration-300 px-8 py-6 text-lg rounded-full font-semibold"
                  asChild
                >
                  <Link href="/dashboard" className="flex items-center gap-2">
                    Begin Your Journey
                    <Zap className="h-5 w-5" />
                  </Link>
                </Button>
                <p className="text-indigo-100 text-sm mt-4">
                  No credit card required • Free forever plan available
                </p>
              </CardContent>
            </Card>
          </motion.div>
        </motion.div>
      </div>
    </div>
  )
}