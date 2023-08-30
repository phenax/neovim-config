
build:
	nix build -L

update-plugin-manager:
	nix flake lock --update-input nvim-plugin-manager

update-all:
	nix flake update

backup-packer:
	cp -r ~/.local/share/nvim/site/pack/packer ../backups/packer

restore-packer:
	cp -r ../backups/packer ~/.local/share/nvim/site/pack/packer

