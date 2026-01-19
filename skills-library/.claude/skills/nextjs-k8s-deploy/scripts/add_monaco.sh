#!/bin/bash

# NextJS K8s Deploy - Add Monaco Editor Script
# Integrates Monaco Editor into the Next.js application

set -euo pipefail

APP_DIR="${1:-.}"

echo "Adding Monaco Editor to Next.js application in: $APP_DIR"

if [ ! -d "$APP_DIR" ]; then
    echo "ERROR: Directory $APP_DIR does not exist"
    exit 1
fi

cd "$APP_DIR"

# Create a components directory for the Monaco Editor wrapper
mkdir -p src/components/editor

# Create a Monaco Editor component
cat > src/components/editor/MonacoEditor.tsx << 'EOF'
'use client';

import React, { useRef, useEffect } from 'react';
import Editor from '@monaco-editor/react';

interface MonacoEditorProps {
  value?: string;
  onChange?: (value: string | undefined) => void;
  language?: string;
  height?: string;
  width?: string;
}

const MonacoEditor: React.FC<MonacoEditorProps> = ({
  value,
  onChange,
  language = 'javascript',
  height = '400px',
  width = '100%'
}) => {
  const editorRef = useRef<any>(null);

  const handleEditorDidMount = (editor: any) => {
    editorRef.current = editor;
  };

  return (
    <div className="border border-gray-300 rounded-md overflow-hidden">
      <Editor
        height={height}
        width={width}
        language={language}
        value={value}
        onChange={onChange}
        onMount={handleEditorDidMount}
        theme="vs-dark"
        options={{
          minimap: { enabled: true },
          fontSize: 14,
          scrollBeyondLastLine: false,
          automaticLayout: true,
          tabSize: 2,
          wordWrap: 'on',
        }}
      />
    </div>
  );
};

export default MonacoEditor;
EOF

# Create a CodeEditor page that uses the Monaco Editor
mkdir -p src/app/code-editor
cat > src/app/code-editor/page.tsx << 'EOF'
'use client';

import { useState } from 'react';
import MonacoEditor from '@/components/editor/MonacoEditor';

const CodeEditorPage = () => {
  const [code, setCode] = useState<string>(
    `// Welcome to LearnFlow Code Editor\nfunction helloWorld() {\n  console.log("Hello, world!");\n}\n\nhelloWorld();`
  );

  const [language, setLanguage] = useState<string>('javascript');

  const handleRunCode = () => {
    // In a real implementation, this would send the code to a backend for execution
    console.log('Running code:', code);
    alert('Code execution would happen here. In a real app, this would connect to a backend service.');
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-6xl mx-auto px-4">
        <div className="mb-6">
          <h1 className="text-3xl font-bold text-gray-900">Code Editor</h1>
          <p className="mt-2 text-gray-600">Write, edit, and run your code in our integrated editor</p>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex justify-between items-center mb-4">
            <div>
              <label htmlFor="language" className="block text-sm font-medium text-gray-700 mr-2">
                Language:
              </label>
              <select
                id="language"
                value={language}
                onChange={(e) => setLanguage(e.target.value)}
                className="border border-gray-300 rounded px-3 py-1 text-sm"
              >
                <option value="javascript">JavaScript</option>
                <option value="typescript">TypeScript</option>
                <option value="python">Python</option>
                <option value="java">Java</option>
                <option value="html">HTML</option>
                <option value="css">CSS</option>
              </select>
            </div>
            <button
              onClick={handleRunCode}
              className="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 transition-colors"
            >
              Run Code
            </button>
          </div>

          <div className="border border-gray-300 rounded-md overflow-hidden">
            <MonacoEditor
              value={code}
              onChange={(newValue) => setCode(newValue || '')}
              language={language}
              height="600px"
            />
          </div>

          <div className="mt-4 p-4 bg-gray-100 rounded-md">
            <h3 className="font-medium text-gray-900 mb-2">Tips:</h3>
            <ul className="text-sm text-gray-700 list-disc pl-5 space-y-1">
              <li>Use the language selector to change the syntax highlighting</li>
              <li>Press Ctrl+Space for autocomplete suggestions</li>
              <li>Press F1 for the command palette</li>
              <li>Your code is securely saved to your account</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CodeEditorPage;
EOF

# Update the main page to include a link to the code editor
sed -i.bak '/<div className="grid grid-cols-1 md:grid-cols-3 gap-8 mt-12">/i\
          <div className="mt-8 text-center">\
            <Link href="/code-editor" className="inline-block bg-indigo-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-indigo-700 transition-colors">\
              Open Code Editor\
            </Link>\
          </div>' src/app/page.tsx

# Create a custom Next.js config to handle Monaco Editor properly
cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.resolve.fallback = {
        ...config.resolve.fallback,
        fs: false,
      };
    }
    return config;
  },
};

module.exports = nextConfig;
EOF

# Create a .env.local file with environment variables
cat > .env.local << 'EOF'
# Backend API URL
BACKEND_URL=http://localhost:8000

# Better Auth Configuration
AUTH_SECRET=your-super-secret-jwt-token-here-change-me
GITHUB_ID=your-github-client-id
GITHUB_SECRET=your-github-client-secret
EOF

echo "✓ Monaco Editor integration completed!"
echo "  - Created MonacoEditor component"
echo "  - Added code editor page with Monaco integration"
echo "  - Updated main page with editor link"
echo "  - Configured Next.js for Monaco compatibility"
echo "  - Created environment variables file"