# Fedora Settings

## default shell ZSH

```bash
sudo dnf install zsh -y && chsh -s $(which zsh)
```

## Oh my posh
```bash
mkdir ~/.config/zsh && curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.config/zsh
```

## SDKMAN
```
curl -s "https://get.sdkman.io" | bash
```

## Links

| subject| links                                        |
|------- |----------------------------------------------|
| apps   |[Default Apps](./apps/readme.md)              |
| dnf    |[DNF](./dnf/readme.md)                        |
| fonts  |[Missing fonts](./fonts/readme.md)            |
| nvidia |[Configure nvidia drivers](./nvidia/readme.md)|
