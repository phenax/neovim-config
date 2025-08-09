(import-macros {: key! : cmd!} :phenax.macros)
(local {: not_nil?} (require :phenax.utils.utils))
(local core (require :nfnl.core))
(local str (require :nfnl.string))
(local {: nil? : contains?} core)

(local rulerline {:max_width 50
                  :simple_ruler_fts [:fugitive :orgagenda]
                  :show_diagnostics? true
                  :show_filestatus? true
                  :show_filename? true
                  :show_linenum? true})

(fn rulerline.initialize []
  (set vim.opt.ruler true)
  (set vim.opt.laststatus 1)
  (rulerline.set_ruler_format))

(fn rulerline.special_buffers []
  (if (= vim.bo.buftype :terminal) " <term> "
      (= vim.bo.filetype :fugitive) " <git> "
      (vim.tbl_contains rulerline.simple_ruler_fts vim.bo.filetype) ""
      nil))

(fn rulerline.path_segment []
  "%#RulerFilePath#%{v:lua._RulerFilePath()}%#Normal#")

(fn rulerline.status_segment []
  "%#RulerFileStatus#%{%v:lua._RulerFileStatus()%}%#Normal#")

(fn rulerline.diagnostics_segment []
  "%{%v:lua._RulerDiagnostic()%}%#Normal#")

(fn rulerline.is_simple_ruler []
  (contains? rulerline.simple_ruler_fts vim.bo.filetype))

(fn rulerline.set_ruler_format []
  (local diag (if rulerline.show_diagnostics?
                  (.. " " (rulerline.diagnostics_segment))
                  ""))
  (local status (if rulerline.show_filestatus?
                    (.. " " (rulerline.status_segment))
                    ""))
  (local filepath (if rulerline.show_filename?
                      (.. " " (rulerline.path_segment))
                      ""))
  (local linenum (if rulerline.show_linenum? (.. " " "%<%l/%L, %v") ""))
  (local format (.. "%=" diag status linenum filepath))
  (set vim.opt.rulerformat (.. "%" rulerline.max_width "(" format "%)"))
  (set vim.opt.statusline
       (.. "%<" "%{repeat('─', winwidth(0))}" "%= " format)))

(fn rulerline.diagnostics []
  (local icons {:Error "" :Hint "" :Info "" :Warn ""})
  (lambda to-diagnostic-text [[severity icon]]
    (local severity-value (. vim.diagnostic.severity (string.upper severity)))
    (local count (length (vim.diagnostic.get 0 {:severity severity-value})))
    (if (> count 0)
        (.. "%#DiagnosticSign" severity "#" icon " " count)
        nil))
  (->> icons
       (core.map-indexed to-diagnostic-text)
       (core.remove nil?)
       (str.join " ")))

(fn rulerline.get_short_path [path win-width]
  (local segments (vim.split path "/"))
  (case (length segments)
    0 path
    1 (. segments 1)
    _ (do
        (var dir (. segments (- (length segments) 1)))
        (var fname (. segments (length segments)))
        (if (or (> (string.len dir) 25) (> (string.len (.. dir fname)) 50))
            (set dir (.. (string.sub dir 1 5) "…"))
            (and (> (string.len dir) 5) (< win-width 85))
            (set dir (.. (string.sub dir 1 5) "…")))
        (when (> (string.len fname) 40)
          (set fname (.. (string.sub fname 1 10) "…"
                         (string.sub fname (- 10) (- 1)))))
        (.. dir "/" fname))))

(fn _G._RulerFilePath []
  (local buf-path (vim.api.nvim_buf_get_name 0))
  (local special-name (rulerline.special_buffers))
  (if (not_nil? special-name) special-name
      (= buf-path "") ""
      (.. " " (rulerline.get_short_path buf-path vim.o.columns) " ")))

(fn _G._RulerDiagnostic []
  (if (rulerline.is_simple_ruler) ""
      (or (rulerline.diagnostics) "")))

(fn _G._RulerFileStatus []
  (if (rulerline.is_simple_ruler) "" "%m%r"))

rulerline
