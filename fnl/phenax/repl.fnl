(import-macros {: key! : cmd!} :phenax.macros)
(local text (require :phenax.utils.text))
(local {: not_nil? : present?} (require :phenax.utils.utils))
(local {: nil?} (require :nfnl.core))
(local curly (require :phenax.curly-repl))

(local default-config {:clear_screen true
                       :command :node
                       :default_selection_cmd :vip
                       :height (fn [lines] (* lines 0.4))
                       :preprocess (fn [input] input)
                       :preprocess_buffer_lines (fn [lines]
                                                  [(table.concat lines "\n")])
                       :restart_job_on_send false
                       :vertical true
                       :width (fn [cols] (* cols 0.4))})

(fn command-slashify [input]
  (-> input (string.gsub "\\\n" "\n") (string.gsub "\n" " \\\n")))

(set _G.Repl
     (vim.tbl_extend :force default-config
                     {:replModes {:node {:config {:command :node}}
                                  :shell {:config {:command (. vim.env :SHELL)
                                                   :preprocess command-slashify}}
                                  :shell_curl {:config (curly.repl_config)}}}))

(local repl {:buffer nil
             :channel_id nil
             :config _G.Repl
             :visible false
             :window nil})

(fn _G.Repl.apply_repl_mode [name] (repl.apply_repl_mode name))

(fn repl.initialize []
  (key! :n :<c-t><c-t> (fn [] (repl.start_term)))
  (key! [:v :n] :<c-t><cr> (fn [] (repl.send_selection)))
  (key! [:v :n] "<c-t>]" (fn [] (repl.send_buffer)))
  (key! :n :<c-t>q (fn [] (repl.close_term)))
  (key! :n :<c-t><Tab> (fn [] (repl.select_repl_mode)))
  (key! :n :<c-t>c (fn [] (repl.send_interrupt)))
  (cmd! :ReplCmd
        (fn [opts]
          (when (not= opts.nargs 0)
            (set repl.config.command opts.args)
            (print (.. "[repl] command: " repl.config.command))))
        {:force true :nargs "*"})
  (cmd! :ReplClearToggle
        (fn []
          (set repl.config.clear_screen (not repl.config.clear_screen))
          (print (.. "[repl] clear screen: "
                     (or (and repl.config.clear_screen :enabled) :disabled))))
        {:force true})
  (cmd! :ReplVertToggle (fn []
                          (set repl.config.vertical (not repl.config.vertical))
                          (print (.. "[repl] split: "
                                     (or (and repl.config.vertical :vertical)
                                         :horizontal)))
                          (when (repl.is_window_valid)
                            (repl.toggle_window)
                            (repl.toggle_window)))
        {:force true}))

(fn repl.close_term [close]
  (repl.stop_job)
  (set repl.visible false)
  (when (and close (not_nil? repl.window))
    (pcall vim.api.nvim_win_close repl.window true)
    (set repl.window nil))
  (when (and close (not_nil? repl.buffer))
    (pcall vim.api.nvim_buf_delete repl.buffer {:force true})
    (set repl.buffer nil)))

(fn repl.restart_job []
  (repl.stop_job)
  (repl.start_job))

(fn repl.stop_job []
  (when (not_nil? repl.channel_id)
    (pcall vim.fn.jobstop repl.channel_id))
  (set repl.channel_id nil))

(fn repl.start_job []
  (set repl.channel_id
       (vim.api.nvim_buf_call repl.buffer
                              (fn []
                                (var env repl.config.env)
                                (when (= (type env) :function) (set env (env)))
                                (vim.fn.jobstart repl.config.command
                                                 {: env :term true})))))

(fn repl.start_term [force-open]
  (repl.toggle_window force-open)
  (when (not repl.channel_id) (repl.start_job)))

(fn repl.toggle_window [force-open]
  (when (and (and force-open repl.visible) (repl.is_window_valid))
    (lua "return "))
  (if (and (and repl.channel_id repl.visible) (repl.is_window_valid))
      (do
        (vim.api.nvim_win_close repl.window true)
        (set repl.window nil)
        (set repl.visible false))
      (do
        (when (not (repl.is_buffer_valid))
          (set repl.buffer (vim.api.nvim_create_buf false false)))
        (set repl.window
             (vim.api.nvim_open_win repl.buffer false
                                    {:vertical repl.config.vertical}))
        (if repl.config.vertical
            (vim.api.nvim_win_set_width repl.window
                                        (math.floor (repl.config.width vim.o.columns)))
            (vim.api.nvim_win_set_height repl.window
                                         (math.floor (repl.config.height vim.o.lines))))
        (vim.api.nvim_set_option_value :winbar repl.config.command
                                       {:win repl.window})
        (set repl.visible true))))

(fn repl.send_buffer []
  (let [lines (vim.api.nvim_buf_get_lines 0 0 (- 1) false)]
    (var cmds (repl.config.preprocess_buffer_lines lines))
    (when (not= (type cmds) :table) (set cmds [cmds]))
    (each [_ cmd (ipairs cmds)] (repl.send cmd true))))

(fn repl.send_selection []
  (var old-pos nil)
  (local is-visual-mode (: (vim.fn.mode) :match "[vV]"))
  (when (not is-visual-mode) (set old-pos (vim.api.nvim_win_get_cursor 0))
    (vim.cmd.normal repl.config.default_selection_cmd))
  (vim.cmd.normal (vim.api.nvim_replace_termcodes :<esc> true false true))
  (local selected-text (repl.config.preprocess (text.get_selection_text)))
  (when old-pos (vim.api.nvim_win_set_cursor 0 old-pos))
  (repl.send selected-text true))

(fn repl.send_interrupt [] (when (= repl.channel_id nil) (lua "return "))
  (local ctrl-c (vim.api.nvim_replace_termcodes :<c-c> true false true))
  (vim.api.nvim_chan_send repl.channel_id ctrl-c))

(fn repl.send [input with-return]
  (when (not input) (lua "return "))
  (when repl.config.restart_job_on_send (repl.close_term true))
  (when (or (nil? repl.channel_id) (<= repl.channel_id 0))
    (repl.start_term repl.config.restart_job_on_send))
  (when (or (nil? repl.channel_id) (<= repl.channel_id 0)) (lua "return "))
  (when repl.config.clear_screen (vim.api.nvim_chan_send repl.channel_id "\f"))
  (vim.api.nvim_chan_send repl.channel_id input)
  (when with-return (vim.api.nvim_chan_send repl.channel_id "\n")))

(fn repl.is_window_valid []
  (and repl.window (vim.api.nvim_win_is_valid repl.window)))

(fn repl.is_buffer_valid []
  (and repl.buffer (vim.api.nvim_buf_is_loaded repl.buffer)))

(fn repl.select_repl_mode []
  (let [options (vim.tbl_keys repl.config.replModes)]
    (table.sort options)
    (vim.ui.select options {:prompt "Repl mode:"}
                   (fn [mode-name]
                     (when (present? mode-name)
                       (repl.apply_repl_mode mode-name)
                       (vim.defer_fn (fn [] (repl.start_term true)) 200))))))

(fn repl.apply_repl_mode [mode-name]
  (when (not mode-name) (lua "return "))
  (local mode (. repl.config.replModes mode-name))
  (when (not mode) (print (.. "Invalid repl mode" mode-name)) (lua "return "))
  (local new-config (vim.tbl_extend :force {} default-config
                                    (or mode.config {})))
  (when (not= new-config.command repl.config.command) (repl.close_term true))
  (each [k v (pairs new-config)] (tset repl.config k v))
  (when (= (type mode.setup) :function) (mode.setup)))

repl
