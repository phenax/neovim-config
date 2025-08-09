(local text {})

(fn text.get_selection_lines []
  (local (start-row start-col end-row end-col) (text.get_selection_range))
  (vim.api.nvim_buf_get_text 0 (- start-row 1) (- start-col 1) (- end-row 1)
                             end-col {}))

(fn text.get_selection_text []
  (local (line-start col-start line-end col-end) (text.get_selection_range))
  (local lines (vim.api.nvim_buf_get_lines 0 (- line-start 1) line-end false))
  (if (= (length lines) 0)
      ""
      (= (length lines) 1)
      (string.sub (. lines 1) col-start col-end)
      (do
        (tset lines 1 (string.sub (. lines 1) col-start))
        (tset lines (length lines)
              (string.sub (. lines (length lines)) 1 col-end))
        (table.concat lines "\n"))))

(fn text.get_selection_range []
  (text.enter_normal_mode)
  (local [_ line-start col-start] (vim.fn.getpos "'<"))
  (local [_ line-end col-end] (vim.fn.getpos "'>"))
  (local col-end-adjusted (math.min col-end (- (vim.fn.col [line-end "$"]) 1)))
  (values line-start col-start line-end col-end-adjusted))

(fn text.enter_normal_mode []
  (vim.cmd.normal (vim.api.nvim_replace_termcodes :<esc> true false true)))

text
