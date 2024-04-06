return {
  'dmmulroy/tsc.nvim',
  ft = { 'typescript', 'typescriptreact', 'tsx' },
  enabled = false,
  opts = {
    flags = {
      build = true,
      noEmit = true,
      watch = false,
    },
  },
}
