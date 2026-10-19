.PHONY: default
default: rebuild

.PHONY: rebuild
rebuild: sudo nixos-rebuild --flake .#$(shell hostname) switch
