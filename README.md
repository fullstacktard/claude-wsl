# claude-wsl

**Visual notifications when Claude Code finishes in WSL.**

![Demo](https://vhs.charm.sh/vhs-U1KWu1eYz5Qr4lTrtT89n.gif)

spent way too long clicking between tabs to check if Claude was done processing. Windows Terminal has progress indicators and toast notifications built in, but Claude Code doesn't use them in WSL. so I fixed it.

## what this does

- **orange circle** when Claude Code is running
- **orange spinner** when Claude is processing
- **bell emoji in tab title** when Claude finishes
- **Windows toast notification** when response is ready
- **directory inheritance** for new tabs (they open where you actually are)

basically: you can work in another tab and get notified when Claude is done. no more compulsive tab checking.

## installation

```bash
npm install -g claude-wsl
claude-wsl install
```

that's it. installer hooks into Claude Code's lifecycle events and adds shell integration to your `.bashrc`. shell integration loads automatically on next terminal start.

## requirements

- Windows Terminal + WSL (Ubuntu/Debian)
- Claude Code installed
- Node.js 18+
- Bash shell

if you're using zsh or fish, this won't work. PRs welcome but I use bash.

## troubleshooting

if something's not working, check [the troubleshooting guide](https://github.com/fullstacktard/claude-wsl#readme).

## license

MIT
