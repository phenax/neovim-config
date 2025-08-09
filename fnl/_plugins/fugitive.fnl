(import-macros {: key! : cmd! : aucmd!} :phenax.macros)
(local {: present?} (require :phenax.utils.utils))
(local plugin {})
(local m {})

(fn plugin.config []
  ;; Git buffer configuration
  (local group (vim.api.nvim_create_augroup :phenax/fugitive {:clear true}))
  (aucmd! :BufReadPost
          {: group
           :pattern "fugitive://*"
           :callback (fn [opts]
                       (m.setup_fugitive_buffer opts.buf))})
  (aucmd! :FileType
          {: group
           :pattern :git
           :callback (fn [opts]
                       (m.setup_git_buffer opts.buf))})
  ;; Open files command
  (cmd! :GFilesOpen (fn [opts] (m.open_file_command opts))
        {:force true :nargs "*"})
  ;; Keys
  (key! :n :<localleader>gs :<cmd>G<cr>)
  (key! :n :<localleader>gaf "<cmd>G add %<cr>")
  (key! :n :<localleader>gcc "<cmd>G commit<cr>")
  (key! :n :<localleader>gca "<cmd>G commit --amend<cr>")
  (key! :n :<localleader>gpp "<cmd>G push<cr>")
  (key! :n :<localleader>gpu "<cmd>G pull<cr>")
  (key! :n :<leader>grf "<cmd>G reset HEAD^1 -- %<cr>")
  (key! :n :<localleader>glm "<cmd>G log --oneline HEAD...origin/master<cr>")
  (key! :n :<localleader>gll "<cmd>G log --oneline<cr>")
  (key! :n :<localleader>gl<space> ":G log --oneline HEAD...HEAD~")
  (key! :n :<localleader>goe :<cmd>GFilesOpen<cr>)
  (key! :n :<localleader>gow "<cmd>GFilesOpen w<cr>")
  (key! :n :<leader>gl "<cmd>diffget //2<cr>")
  (key! :n :<leader>gr "<cmd>diffget //3<cr>"))

(fn m.open_file_command [opts]
  (local rev (if (= opts.args :w) (vim.fn.expand :<cword>) opts.args))
  (print (.. "Opening files from " (or rev "last commit") "..."))
  (m.open_files_in_commit rev))

(fn m.setup_fugitive_buffer [buf]
  (local opts {:buffer buf :remap true})
  (vim.keymap.set :n :a "-" opts)
  (vim.keymap.set :n :<Down> ")" opts)
  (vim.keymap.set :n :<Up> "(" opts)
  (vim.keymap.set :n :<Right> ">" opts)
  (vim.keymap.set :n :<Left> "<" opts)
  (m.setup_git_buffer buf))

(fn m.setup_git_buffer [buf]
  (local opts {:buffer buf :nowait true :remap true})
  (vim.keymap.set :n :q :gq opts)
  (vim.keymap.set :n :gd m.diffview_for_commit_or_file_under_cursor opts)
  (vim.keymap.set :n :fl m.files_for_commit_under_cursor opts)
  (vim.api.nvim_set_option_value :bufhidden :delete {: buf})
  (vim.api.nvim_set_option_value :buflisted false {: buf}))

(fn m.files_for_commit_under_cursor []
  "Show a split window with files changed in the commit id under cursor"
  (let [rev (vim.fn.expand :<cword>)]
    (vim.cmd.Git (.. "show --name-only " rev))))

(fn m.diffview_for_commit_or_file_under_cursor []
  "Show a diff window for the commit or file under cursor.
  If the current buffer starts with `commit <rev>`, it will show a diff for the file path under cursor on that commit.
  Otherwise, word under cursor is used as revision"
  (local buf (vim.api.nvim_get_current_buf))
  (local first-line (. (vim.api.nvim_buf_get_lines buf 0 1 false) 1))
  (local (rev file) (if (string.match first-line "^commit%s+")
                        (do
                          (local rev
                                 (first-line.gsub first-line "^commit%s+" ""))
                          (local file (vim.fn.expand :<cfile>))
                          (values rev file))
                        (do
                          (local rev (vim.fn.expand :<cword>))
                          (values rev nil))))
  (m.show_diff_in_term rev file))

(var current-term nil)

(fn m.show_diff_in_term [rev ?file]
  "Open a new term with the diff for the given revision.
  If file is present, shows diff for just the file"
  (when current-term (current-term:close))
  (local cmd (if (present? ?file)
                 [:git :show rev "--" ?file]
                 [:git :show rev]))
  (set current-term
       (Snacks.terminal.open cmd
                             {:interactive false
                              :win {:style :phenax_git_diff}})))

(fn m.open_files_in_commit [rev]
  "Open all files changed in the given revision"
  (local git-command [:git :--no-pager :show :--name-only :--pretty=])
  (when (present? rev)
    (table.insert git-command rev))
  (local result (-> (vim.system git-command {}) (: :wait)))
  (when (not= result.code 0)
    (print (.. "Exited with " result.code ": " (or result.stderr :error))))
  (when (present? result.stdout)
    (each [file-name (string.gmatch result.stdout "[^\n]+")]
      (vim.cmd.edit file-name))))

plugin

;; gu: go to untracked changes
;; gU: go to unstaged changes
;; gs: go to staged changes
;;
;; rr: rebase continue
;; ri: interactive on commit
;; ra: rebase abort
;; ru: rebase against upstream
;; re: edit rebase todo list
;; rm: directly go to edit commit under cursor
;;
;; cc: commit
;; ca: commit amend
;; P: Push commit upstream
;;
;; ) and (: goto next item in status
;; X: reset file
;; dv: diff vert
;; dq: quit diff
;; gO: open file vert split
