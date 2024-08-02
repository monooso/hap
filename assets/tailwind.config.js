import daisyui from "daisyui";

/** @type {import('tailwindcss').Config} */
export const content = [
  './js/**/*.js',
  '../lib/*_web.ex',
  '../lib/*_web/**/*.*ex',
];

export const theme = {
  extend: {},
};

export const plugins = [daisyui];

