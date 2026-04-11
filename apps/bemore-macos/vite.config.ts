import react from '@vitejs/plugin-react';
import {defineConfig} from 'vite';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 4318,
    host: '127.0.0.1',
    proxy: {
      '/api': 'http://127.0.0.1:4319',
    },
  },
  preview: {
    port: 4318,
    host: '127.0.0.1',
  },
});
