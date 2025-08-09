(require :_settings.settings)
(require :_settings.basic-keybinds)
(require :_settings.ft)

(let [theme (require :_settings.theme)] (theme.setup :default))

(require :_settings.packages)
(let [pack (require :phenax.pack_config)] (pack.load :_plugins))
