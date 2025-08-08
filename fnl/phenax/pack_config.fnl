(local core (require :nfnl.core))
(local pack {})

; @class Spec
; @field name string?
; @field enabled boolean?
; @field keys table? TODO: remove this
; @field config function?
; @field priority number?

(fn pack.load [path]
  (local specs (vim.tbl_values (pack.load_modules path)))
  (table.sort specs (fn [m1 m2] (pack.package_sorter m1 m2)))
  (each [_ spec (ipairs specs)] (pack.configure_module_spec spec)))

(fn pack.configure_module_spec [spec]
  (when (or (not spec) (= spec.enabled false)) (lua "return "))

  (fn _configure []
    (each [_ value (ipairs (or spec.keys {}))]
      (local [key action] value)
      (vim.keymap.set (or value.mode :n) key action
                      {:remap value.remap :silent value.silent}))
    (when (core.function? spec.config) (spec.config)))

  (local (ok error) (pcall _configure))
  (when (not ok)
    (vim.notify (.. "[Plugin config error: " (or spec.name :<unknown>) "] "
                    error) vim.log.levels.ERROR)))

(fn pack.load_modules [path]
  (local modules_names (pack.ls_modules path))
  (local mods {})
  (each [_ modname (pairs modules_names)]
    (local defaults {:enabled true :name modname :priority 0})
    (local (ok mod) (pcall require modname))
    (if ok
        (tset mods modname
              (vim.tbl_extend :force defaults (or mod {:enabled false})))
        (vim.notify (.. "[Plugin load error: " modname "] " mod)
                    vim.log.levels.ERROR)))
  mods)

(fn pack.ls_modules [path]
  (local handle (vim.uv.fs_scandir (.. (vim.fn.stdpath :config) :/lua/ path)))
  (local modules {})
  (while handle
    (local (name _) (vim.uv.fs_scandir_next handle))
    (when (not name) (lua :break))
    (when (string.match name :.lua$)
      (local modname (.. path "." (string.gsub name :.lua$ "")))
      (table.insert modules modname)))
  modules)

(fn pack.package_sorter [m1 m2]
  (if (not= m1.priority m2.priority)
      (> m1.priority m2.priority)
      (< m1.name m2.name)))

pack
