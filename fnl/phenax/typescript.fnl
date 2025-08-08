(import-macros {: cmd! : =>} :phenax.macros)
(local core (require :nfnl.core))
(local {: present?} (require :phenax.utils.utils))

(local ts {})

(fn ts.initialize []
  (cmd! :Tsc (=> (. :fargs) core.first ts.typecheck) {:nargs "*"}))

(fn ts.typecheck [path]
  (vim.fn.setqflist {} :r)
  (vim.cmd.copen)
  (ts.run_tsc_async path))

(fn ts.add_line_to_qflist [line]
  (local err_qf_item (ts.parse_tsc_error_to_qfitem line))
  (when (present? err_qf_item)
    (vim.schedule (fn [] (vim.fn.setqflist [err_qf_item] :a)))))

(fn ts.parse_tsc_error_to_qfitem [error-line]
  (local (path line col msg)
         (error-line:match "^(.-)%((%d+),(%d+)%)%s*:%s*(.+)$"))
  (when (and path line col)
    {:col (tonumber col)
     :filename path
     :lnum (tonumber line)
     :text msg
     :type :E}))

(fn ts.get_tsc_command [?path]
  (let [stat (vim.uv.fs_stat (or ?path "."))]
    (var path-args {})
    (if (and stat (= stat.type :directory))
        (set path-args [:-p (or ?path ".")])
        (set path-args [?path]))
    (core.concat (ts.get_tsc) path-args [:--pretty :false :--noEmit])))

(fn ts.run_tsc_async [?path]
  (fn on_exit [result]
    (vim.notify (.. "Exited with: " result.code) vim.log.levels.INFO)
    (when (present? result.stderr)
      (vim.notify (.. "[tsc errors" ": " result.code "] " result.stderr)
                  vim.log.levels.ERROR)))

  (fn on_stdout [data]
    (when (present? data)
      (-> (data:gmatch "[^\r\n]+")
          vim.iter
          (: :each ts.add_line_to_qflist))))

  (vim.system (ts.get_tsc_command ?path)
              {:text true :stdout (fn [_ data] (on_stdout data))}
              (fn [res]
                (vim.schedule (fn [] (on_exit res))))))

(fn ts.get_tsc []
  (if (vim.uv.fs_stat :./node_modules/.bin/tsc)
      [:./node_modules/.bin/tsc]
      [:tsc]))

ts
