local notes_path = vim.fn.expand '~/nixos/extras/notes'
return {
  path = notes_path,
  notes_entry_file = vim.fs.joinpath(notes_path, 'index.org'),
}
