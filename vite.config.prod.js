import { defineConfig } from 'vite';

export default defineConfig(({ command, mode, ssrBuild }) => {
  console.log('command', command);
  if (command === 'build') {
    return {
      base: '/convert-coord/',
      build: {
        outDir: 'dist-prod',
      },
    };
  } else {
    return {
      base: '/',
    };
  }
});
