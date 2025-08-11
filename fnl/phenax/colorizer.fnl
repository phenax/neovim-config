(import-macros {: cmd! : aucmd!} :phenax.macros)
(local {: not_nil?} (require :phenax.utils.utils))

(local M {:ns (vim.api.nvim_create_namespace :phenax/colorize)
          :config {:colors []}})

;; fnlfmt: skip
(set M.config.colors
     [{:pattern "\\#[A-Fa-f0-9]\\{6}"
       :highlight (fn [color]
                    ;; TODO: Use a better way to contrast?
                    (local fg (if (= color "#ffffff") "#000000" "#ffffff")) 
                    (local hl_name (.. "@colorizer." (string.gsub color "[#%s]+" "")))
                    (pcall vim.api.nvim_set_hl 0 hl_name {:bg color : fg})
                    hl_name)}])

;; TODO: tailwind support {https://github.com/catgoose/nvim-colorizer.lua/blob/master/lua/colorizer/tailwind.lua}

(fn M.initialize []
  (cmd! :ColorizeBuf (fn [] (M.create-highlighting-on-buffer 0)) {})
  (cmd! :ColorizeBufClear (fn [] (M.clear-colors 0)) {})
  (aucmd! [:TextChanged :InsertLeave]
          {:callback (fn [opts]
                       (when (. vim.b opts.buf :_phenax_colorized)
                         (M.create-highlighting-on-buffer opts.buf)))}))

(lambda M.clear-colors [buf]
  (vim.api.nvim_buf_clear_namespace buf M.ns 0 -1)
  (set (. vim.b buf :_phenax_colorized) false))

(lambda M.create-highlighting-on-buffer [buf]
  (local buf (if (= buf 0) (vim.api.nvim_get_current_buf) buf))
  (vim.api.nvim_buf_clear_namespace buf M.ns 0 -1)
  (local lines (vim.api.nvim_buf_get_lines buf 0 -1 false))
  (set (. vim.b buf :_phenax_colorized) true)
  (each [lineindex line (ipairs lines)]
    (each [_ hlconfig (ipairs M.config.colors)]
      (M.create-highlighting-on-line buf hlconfig {: line : lineindex}))))

(fn M.create-highlighting-on-line [buf hlconfig {: line : lineindex}]
  (each [colstart colend text (M.match-line-iterator buf hlconfig.pattern line
                                                     lineindex)]
    (local hl_name (hlconfig.highlight text))
    (M.highlight-range buf hl_name {: colstart : colend :line lineindex})))

(fn M.highlight-range [buf hl_name {: line : colstart : colend}]
  (vim.api.nvim_buf_set_extmark buf M.ns (- line 1) (- colstart 1)
                                {:end_col colend
                                 :hl_group hl_name
                                 :strict false
                                 :invalidate true
                                 :priority 1000}))

(fn M.match-line-iterator [buf pattern line lineindex]
  "Creates an iterator for finding pattern ranges in text"
  (var start 0)
  (local re (vim.regex pattern))
  (fn []
    (var (cstart cend) (re:match_line buf (- lineindex 1) start))
    (when (not_nil? cstart)
      (set cstart (+ cstart start))
      (set cend (+ cend start))
      (local color (string.sub line (+ cstart 1) cend))
      (set start cend)
      (values cstart cend color))))

M
