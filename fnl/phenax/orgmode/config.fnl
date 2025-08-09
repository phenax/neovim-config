(local notes-path (vim.fn.expand "~/nixos/extras/notes"))

{:notes_entry_file (vim.fs.joinpath notes-path :index.org) :path notes-path}
