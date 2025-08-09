-- [nfnl] fnl/phenax/orgmode/config.fnl
local notes_path = vim.fn.expand("~/nixos/extras/notes")
return {notes_entry_file = vim.fs.joinpath(notes_path, "index.org"), path = notes_path}
