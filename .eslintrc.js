module.exports = {
  // parserに'vue-eslint-parser'を指定し、'@typescript-eslint/parser'はparserOptionsに指定する
  parser: 'vue-eslint-parser',

  parserOptions: {
    parser: '@typescript-eslint/parser',
  },

  extends: [
    'plugin:@typescript-eslint/recommended',
    'plugin:vue/recommended',
    'prettier/@typescript-eslint',
    'plugin:prettier/recommended',
    'plugin:vue/essential',
    '@vue/prettier',
    '@vue/typescript',
  ],

  rules: {
    'prettier/prettier': [
      'error',
      {
        singleQuote: true,
        semi: false,
        trailingComma: 'es5',
      },
    ],
    'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',
    '@typescript-eslint/explicit-function-return-type': false,
  },

  root: true,

  env: {
    node: true,
  },
}
