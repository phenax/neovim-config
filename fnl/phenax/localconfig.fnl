(import-macros {: key! : aucmd! : cmd!} :phenax.macros)
(local {: nil?} (require :nfnl.core))
(local {: not_nil?} (require :phenax.utils.utils))

(local localconf
       {:local_config_file :.local.lua
        :safe_dirs_file (vim.fs.joinpath (vim.fn.stdpath :data)
                                         :phenax-autoload-safe-dirs)})

(fn localconf.initialize []
  (key! :n :<leader>cz (fn [] (localconf.trust_and_load_local_config)))
  (cmd! :LocalConfigAllow (fn [] (localconf.trust_and_load_local_config)) {})
  (aucmd! :VimEnter
          {:callback (fn [] (vim.defer_fn localconf.load_local_config 200))}))

(fn localconf.trust_and_load_local_config []
  (when (not (localconf.is_safe_dir))
    (localconf.prompt_add_safe (vim.fn.getcwd)))
  (localconf.load_local_config))

(fn localconf.load_local_config []
  (when (and (localconf.file_exists localconf.local_config_file)
             (localconf.is_safe_dir))
    (dofile localconf.local_config_file)
    (print "Loaded .local.lua")))

(fn localconf.is_safe_dir []
  (local file (io.open localconf.safe_dirs_file :r))
  (if (nil? file)
      false
      (do
        (local cwd (vim.fn.getcwd))
        (local contains_cwd
               (-> (file:lines)
                   vim.iter
                   (: :any (fn [dir] (= dir cwd)))))
        (file:close)
        contains_cwd)))

(fn localconf.prompt_add_safe [dir]
  (local file (io.open localconf.safe_dirs_file :a+))
  (assert file "Unable to safe dirs config")
  (local answer
         (vim.fn.input ".local.lua found. Add directory as safe (y/n)? "))
  (when (= (answer:lower) :y)
    (file:write (.. dir "\n"))
    (file:flush))
  (file:close))

(fn localconf.file_exists [filepath]
  (not_nil? (vim.uv.fs_stat filepath)))

localconf
