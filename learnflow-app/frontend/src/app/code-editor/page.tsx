'use client';

import { useState } from 'react';
import MonacoEditor from '@/components/editor/MonacoEditor';
import axios from 'axios';

const CodeEditorPage = () => {
  const [code, setCode] = useState<string>(
    `# Welcome to LearnFlow Python Code Editor\ndef hello_world():\n    return "Hello, World!"\n\nprint(hello_world())`
  );
  const [output, setOutput] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [language, setLanguage] = useState<string>('python');

  const handleRunCode = async () => {
    setIsLoading(true);
    setOutput('Running code...');

    try {
      // In a real implementation, this would send the code to a backend for execution
      // For now, we'll simulate a backend call
      console.log('Sending code to backend:', code);

      // Simulate API call to backend service for code execution
      // const response = await axios.post('/api/execute-code', {
      //   code,
      //   language
      // });

      // For demonstration, we'll just show the code in the output
      setTimeout(() => {
        setOutput(`Code executed successfully!\n\nYour code:\n${code}`);
        setIsLoading(false);
      }, 1000);
    } catch (error) {
      console.error('Error executing code:', error);
      setOutput('Error executing code. Please check your code and try again.');
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-6xl mx-auto px-4">
        <div className="mb-6">
          <h1 className="text-3xl font-bold text-gray-900">Python Code Editor</h1>
          <p className="mt-2 text-gray-600">Write, edit, and execute Python code in our integrated editor</p>
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
                disabled // Only Python for now
              >
                <option value="python">Python</option>
              </select>
            </div>
            <button
              onClick={handleRunCode}
              disabled={isLoading}
              className={`bg-indigo-600 text-white px-4 py-2 rounded-md transition-colors ${
                isLoading ? 'opacity-50 cursor-not-allowed' : 'hover:bg-indigo-700'
              }`}
            >
              {isLoading ? 'Running...' : 'Run Code'}
            </button>
          </div>

          <div className="border border-gray-300 rounded-md overflow-hidden">
            <MonacoEditor
              value={code}
              onChange={(newValue) => setCode(newValue || '')}
              language={language}
              height="400px"
            />
          </div>

          <div className="mt-4">
            <h3 className="font-medium text-gray-900 mb-2">Output:</h3>
            <div className="bg-gray-900 text-green-400 font-mono text-sm p-4 rounded-md min-h-[100px] max-h-60 overflow-auto">
              {output || '// Output will appear here after running your code'}
            </div>
          </div>

          <div className="mt-4 p-4 bg-blue-50 rounded-md">
            <h3 className="font-medium text-blue-900 mb-2">Python Tips:</h3>
            <ul className="text-sm text-blue-800 list-disc pl-5 space-y-1">
              <li>Write clean Python code with proper indentation (4 spaces)</li>
              <li>Press Ctrl+Space for autocomplete suggestions</li>
              <li>Press F1 for the command palette</li>
              <li>Your code is securely saved to your account</li>
              <li>Use print() statements to see output in the console</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CodeEditorPage;
