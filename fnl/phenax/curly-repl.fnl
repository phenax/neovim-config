(local core (require :nfnl.core))
(local curly {})

(fn curly.repl_config []
  (var cfg-path (vim.fn.stdpath :config))
  (when vim.g.__phenax_test
    (set cfg-path (vim.fn.expand "~/nixos/config/nvim")))
  ;; Repl config
  {:clear_screen false
   :command (.. "PATH=\"$PATH:" cfg-path "/bin\" zsh")
   :env curly.get_env
   :preprocess curly.command_preprocessor
   :preprocess_buffer_lines curly.multi_command_preprocessor
   :restart_job_on_send true})

(fn curly.command_preprocessor [cmd-str]
  (let [parsed-cmd (curly.curl_command_parser cmd-str)]
    (.. " " (curly.command_slashify parsed-cmd))))

(fn curly.multi_command_preprocessor [cmd-lines]
  (local cmds {})
  (each [_ line (ipairs cmd-lines)]
    (var cmd "")
    (if (core.empty? line)
        (do
          (table.insert cmds (curly.command_preprocessor cmd))
          (set cmd ""))
        (set cmd (.. cmd "\n" line))))
  (table.concat cmds ";\n"))

(fn curly.curl_command_parser [cmd-str]
  (var json-started false)
  (var json-str "")
  (local cmd {})
  (local lines (-> cmd-str (string.gsub "\\\n" "\n")
                   (string.gmatch "([^\n]*)\n?")))
  (each [line lines]
    (local trimmed-line
           (-> line
               (string.gsub "^%s*" "")
               (string.gsub "%s*$" "")
               (string.gsub "%s*#%s.*$" "")))
    (if json-started
        (do
          (set json-str (.. json-str trimmed-line))
          (when (= trimmed-line "}")
            (local (ok _) (pcall vim.json.decode json-str))
            (when ok (set json-started false)
              (table.insert cmd (vim.json.encode json-str)))))
        (= trimmed-line "{")
        (do
          (set json-started true)
          (set json-str (.. json-str trimmed-line)))
        (table.insert cmd trimmed-line)))
  (table.concat cmd " "))

(fn curly.command_slashify [input]
  (-> input (string.gsub "\\\n" "\n") (string.gsub "\n" " \\\n")))

(fn curly.get_env []
  (local handle (io.open :./env.json :r))
  (when handle
    (local result (handle:read :a))
    (handle:close)
    (vim.json.decode result)))

curly
