(local core (require :nfnl.core))
(local ts_utils (require :nvim-treesitter.ts_utils))

(local M {})

(fn M.find_closest_parent [node pred]
  (if (core.nil? node) nil
      (if (pred node) node
          (do
            (local parent (node:parent))
            (when parent (M.find_closest_parent parent pred))))))

(fn M.find_closest_parent_of_type [node types]
  (M.find_closest_parent node (fn [n] (vim.tbl_contains types (n:type)))))

(fn M.get_node_at_cursor [win] (ts_utils.get_node_at_cursor win))

(fn M.get_root_node [bufnr]
  (local ft (. vim.bo bufnr :filetype))
  (local parser (vim.treesitter.get_parser bufnr ft))
  (when parser
    (: (core.first (parser:parse)) :root)))

(fn M.get_node_indentation [node]
  (let [(end-row _) (node:start)
        [line] (vim.api.nvim_buf_get_lines 0 end-row (+ end-row 1) false)]
    (core.str (string.match line "^%s*"))))

M
