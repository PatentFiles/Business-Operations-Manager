# Windows first-run baseline for Business Operations Manager

Status: testing instructions for the **unmodified upstream-derived runtime**. They are not a claim that this fork has passed a Windows acceptance run.
Baseline commit before BOM changes: `be08705f6637435795fa8e40130c67fb40a79f67`.

## Why use WSL2 first?

The current project declares Node.js **24.11.0+** and pnpm **9.15.4**. The upstream installation guide documents macOS, Linux and WSL2. On Windows, begin with WSL2 Ubuntu rather than assuming the complete native runner, embedded PostgreSQL and shell scripts work in Windows PowerShell. The user's earlier Windows environment reported Node.js 22.23.4, which is too old for this fork.

Running in WSL2 still opens the application from the Windows browser at `http://localhost:3100` when WSL localhost forwarding is available.

### Preflight from Windows PowerShell (read-only)

When the BOM repository is cloned on Windows, run:

```powershell
powershell.exe -NoProfile -File .\scripts\bom-windows-readiness.ps1
```

The checker reports available commands and version mismatches. It never installs software, modifies files or touches credentials. It checks the Windows host; the application prerequisites must also be checked **inside Ubuntu**, because WSL has its own Node/pnpm installation.

### Set up WSL2 if not installed

From a regular Windows PowerShell terminal, inspect:

```powershell
wsl --status
wsl --list --verbose
```

If WSL2/Ubuntu is missing, consult the [Microsoft WSL installation guide](https://learn.microsoft.com/windows/wsl/install). The standard setup command is `wsl --install -d Ubuntu`; this changes your computer and may require admin approval and restart. Do not run it automatically from BOM or install a distribution you already have.

### In the Ubuntu/WSL2 terminal

1. Install Node.js 24.11.0 or later from the [official Node.js distribution instructions](https://nodejs.org/en/download). Prefer supported Node 24 LTS; a Node 22 installation on Windows does not satisfy the WSL Node requirement. Verify with `node --version`.
2. Ensure `git` and `npm` are installed; verify with `git --version` and `npm --version`.
3. Install the repository-pinned pnpm after Node is ready:

```bash
npm install --global pnpm@9.15.4
pnpm --version
```

4. Clone the **BOM fork** into a Linux home directory (not a Windows-mounted folder). This is a shallow checkout, avoiding most history:

```bash
cd ~
git clone --filter=blob:none --depth=1 --single-branch \
  https://github.com/PatentFiles/Business-Operations-Manager.git
cd Business-Operations-Manager
git rev-parse HEAD
pnpm install --frozen-lockfile
```

Do not clone `paperclipai/paperclip` if you intend to test or change the BOM fork. The workspace intentionally retains `@paperclipai/*` package names while those internal APIs remain compatible.

5. Start a single isolated foreground development instance:

```bash
pnpm dev:once --data-dir "$HOME/.bom-baseline-test"
```

Open `http://localhost:3100` from Windows. The repository's dev runner supports `--data-dir`; this avoids using an existing/default Paperclip database. Keep the terminal open during the test. Stop with Ctrl+C when finished.

If dependency installation/build fails because the native Paperclip Runner needs Rust, follow the repository's `doc/DEVELOPING.md` and runner instructions to configure a qualified Rust toolchain or compatible prebuilt runner. Do not switch to another branch, silently disable sandbox restrictions or install arbitrary tools to make a failure disappear.

## Minimum smoke checks

1. The app starts and loads in a Windows browser, with no unrecoverable frontend or API errors.
2. Create **Test Company BOM** with no payment integrations or customer data.
3. Open its dashboard and inspect company switcher, Goals, Agents, Org chart, Tasks, Approvals and Costs.
4. Add a safe sample goal and inspect the CEO setup path. Do not assume an agent can execute until a supported runtime/provider is configured and budget approved.
5. Stop and restart with the **same isolated data directory**. Verify the test company and any safe configuration persist.
6. Check an intentionally unavailable provider; BOM should show an unconfigured/error state rather than successful activity.
7. Test browser layout at desktop and narrow widths. Record clipping, empty states, focus, navigation and errors.

**Do not start actual model heartbeats, send messages, publish to social media, run external automation or attach real business/payment data during the first smoke test.** These need separate consent and cost checks.

## Optional developer verification

From the cloned repository when dependencies are installed:

```bash
pnpm --filter @paperclipai/ui typecheck
pnpm --filter @paperclipai/server typecheck
```

The full suite and build are significantly heavier:

```bash
pnpm verify
```

Never claim they passed unless these commands actually completed with successful exit status. An unavailable runner or a skipped test is not a pass.

## Troubleshooting facts to report

Copy the non-secret portions of the output below when reporting a failure:

```bash
uname -a
node --version
pnpm --version
git rev-parse HEAD
git status --short
```

Also provide the exact command, first relevant error, and whether `http://localhost:3100` loaded. Remove tokens, database passwords, keys, private URLs, user/customer data and full environment dumps from logs before sharing.

## After the baseline

Do not rebase, reset or overwrite a working install to test BOM changes. Keep a separate checkout/branch and data directory for BOM development. Start with the first reviewed change in [BOM_PRODUCT_FOUNDATION_v0.1.md](BOM_PRODUCT_FOUNDATION_v0.1.md), and verify source/type/tests/browser behavior before promotion to `master`. Existing Paperclip runtime identifiers stay unchanged until a safe, tested branding/migration plan is approved.
