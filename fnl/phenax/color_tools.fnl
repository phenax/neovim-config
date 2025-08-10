(import-macros {: cmd!} :phenax.macros)
(local {: present?} (require :phenax.utils.utils))

(local M {:ns (vim.api.nvim_create_namespace :phenax/colorize)})

(fn M.initialize []
  (cmd! :ColorizeBuf (fn [] (M.colorize-buffer)) {})
  (cmd! :ColorizeClear (fn [] (M.clear-colors)) {}))

(fn M.clear-colors [] (vim.api.nvim_buf_clear_namespace 0 M.ns 0 -1))

(fn colors-iterator [text]
  (var start 0)
  (local hex-pattern "(#%x%x%x%x%x%x)")
  (fn []
    (local (cstart cend color) (string.find text hex-pattern start))
    (set start cend)
    (when (present? color) (values cstart cend color))))

(fn M.colorize-buffer []
  (local buf 0)
  (vim.api.nvim_buf_clear_namespace buf M.ns 0 -1)
  (local lines (vim.api.nvim_buf_get_lines buf 0 -1 false))
  (each [lineindex line (ipairs lines)]
    (each [colstart colend color (colors-iterator line)]
      (local hl_name (M.create-colorize-hl color))
      (M.highlight_text buf hl_name {: colstart : colend :line lineindex}))))

(fn M.highlight_text [buf hl_name {: line : colstart : colend}]
  (vim.api.nvim_buf_set_extmark buf M.ns (- line 1) (- colstart 1)
                                {:end_col colend
                                 :hl_group hl_name
                                 :strict false
                                 :invalidate true
                                 :priority 1000}))

(fn M.create-colorize-hl [color]
  (local hl_name (.. "@colorizer." (string.gsub color "[#%s]+" "")))
  (local fg (if (= color "#ffffff") "#000000" "#ffffff")) ; TODO: Use a better way to contrast?
  (vim.api.nvim_set_hl 0 hl_name {:bg color : fg})
  hl_name)

M
