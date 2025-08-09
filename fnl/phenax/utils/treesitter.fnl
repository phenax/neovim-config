(local core (require :nfnl.core))
(local ts_utils (require :nvim-treesitter.ts_utils))

(local tsutils {})

(fn tsutils.find_closest_parent [node pred]
  (if (core.nil? node) nil
      (if (pred node) node
          (do
            (local parent (node:parent))
            (when parent (tsutils.find_closest_parent parent pred))))))

(fn tsutils.find_closest_parent_of_type [node types]
  (tsutils.find_closest_parent node (fn [n] (vim.tbl_contains types (n:type)))))

(fn tsutils.get_node_at_cursor [win] (ts_utils.get_node_at_cursor win))

(fn tsutils.get_root_node [bufnr]
  (local ft (. vim.bo bufnr :filetype))
  (local parser (vim.treesitter.get_parser bufnr ft))
  (when parser
    (: (core.first (parser:parse)) :root)))

(fn tsutils.get_node_indentation [node]
  (let [(end-row _) (node:start)
        [line] (vim.api.nvim_buf_get_lines 0 end-row (+ end-row 1) false)]
    (core.str (string.match line "^%s*"))))

(fn tsutils.replace_node_with_text [buf node lines]
  (local [sr sc _ er ec _] (vim.treesitter.get_range node buf))
  (vim.api.nvim_buf_set_text buf sr sc er ec lines))

(fn tsutils.->text [node buf] (vim.treesitter.get_node_text node (or buf 0)))

tsutils
