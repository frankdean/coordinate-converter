import { nodeResolve } from '@rollup/plugin-node-resolve';
import commonjs from '@rollup/plugin-commonjs';
import terser from '@rollup/plugin-terser';

export default {
  input: 'index.js',
  output: {
    compact: true,
    dir: 'dist',
    format: 'iife',
    entryFileNames: '[name].js',
    sourcemap: true
  },
  plugins: [
    terser( {
      compress: { defaults: true },
    }),
    nodeResolve({
      moduleDirectories: ['.', 'node_modules']
    }),
    commonjs()
  ]
};
