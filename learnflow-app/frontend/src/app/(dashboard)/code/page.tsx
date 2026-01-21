'use client'

import { CodeEditor } from '@/components/code-editor/monaco-editor'
import { motion } from 'framer-motion'

export default function CodePage() {
  return (
    <motion.div
      className="container mx-auto py-6"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.3 }}
    >
      <motion.div
        className="mb-6"
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3 }}
      >
        <h1 className="text-3xl font-bold">Code Playground</h1>
        <p className="text-muted-foreground">
          Practice Python coding with syntax highlighting and execution
        </p>
      </motion.div>

      <motion.div
        className="bg-card rounded-lg border h-[calc(100vh-200px)]"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.1 }}
      >
        <CodeEditor />
      </motion.div>
    </motion.div>
  )
}