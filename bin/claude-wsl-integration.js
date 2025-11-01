#!/usr/bin/env node

import chalk from "chalk";
import { showError } from "../lib/ui.js";
import { install } from "../lib/commands/install.js";

async function main() {
  const args = process.argv.slice(2);
  const command = args[0];

  try {
    switch (command) {
      case "init":
      case "install":
      case undefined:
        await install();
        break;
      case "help":
      case "--help":
      case "-h":
        console.log(`
${chalk.red.bold("Claude WSL Integration")} ${chalk.white("- Visual notifications for Claude Code")}

${chalk.red.bold("Usage:")}
  ${chalk.white("claude-wsl-integration")} ${chalk.gray("[init]")}     ${chalk.dim("Install the integration")}
  ${chalk.white("claude-wsl-integration install")}    ${chalk.dim("Install the integration")}
  ${chalk.white("claude-wsl-integration help")}       ${chalk.dim("Show this help message")}

${chalk.red.bold("Examples:")}
  ${chalk.white("claude-wsl-integration")}            ${chalk.dim("# Init (default action)")}
  ${chalk.white("claude-wsl-integration init")}       ${chalk.dim("# Explicitly init")}
  ${chalk.white("claude-wsl-integration install")}    ${chalk.dim("# Same as init")}

${chalk.red.bold("For more information, visit:")}
  ${chalk.cyan("https://github.com/fullstacktard/claude-wsl-integration")}
`);
        break;
      default:
        showError(`Unknown command: ${command}`);
        showError("Run 'claude-wsl-integration help' for usage information");
        process.exit(1);
    }
  } catch (error) {
    showError(`Error: ${error.message}`);
    if (process.env.DEBUG) {
      console.error(error);
    }
    process.exit(1);
  }
}

main();
