#!/usr/bin/env python3
"""Updates streak/activity-log.md with a daily dev tip to keep the GitHub streak alive."""

import os
from datetime import datetime, timezone

TIPS = [
    "Git tip: `git bisect` does a binary search through commits to find where a bug was introduced.",
    "Git tip: `git stash push -m 'description'` lets you name your stashes for easy retrieval.",
    "Git tip: `git log --oneline --graph --all` shows a visual branch tree in the terminal.",
    "Git tip: `git commit --fixup <hash>` creates a fixup commit that `git rebase --autosquash` can auto-merge.",
    "Git tip: `git diff --word-diff` shows changes word-by-word instead of line-by-line.",
    "Git tip: `git shortlog -sn` shows a contributor leaderboard sorted by commit count.",
    "Git tip: Use `git worktree` to check out multiple branches simultaneously into separate directories.",
    "Git tip: `git blame -L 10,20 file.py` limits blame output to a specific line range.",
    "Terminal tip: `ctrl+r` in bash/zsh opens reverse history search — type any part of a past command.",
    "Terminal tip: `!!` repeats the last command. `sudo !!` re-runs it with sudo.",
    "Terminal tip: `cd -` takes you back to the previous directory instantly.",
    "Terminal tip: `ctrl+a` jumps to start of line, `ctrl+e` to end — faster than arrow keys.",
    "Terminal tip: Prefix a command with a space to keep it out of shell history.",
    "Terminal tip: `watch -n 2 <command>` reruns a command every 2 seconds — great for monitoring.",
    "Terminal tip: `tee file.txt` pipes output to both a file and stdout at the same time.",
    "Python tip: `enumerate(iterable, start=1)` gives you 1-based indices without math.",
    "Python tip: `dict.setdefault(key, []).append(val)` is a clean way to build a dict of lists.",
    "Python tip: Use `@functools.lru_cache` to memoize expensive pure functions with one decorator.",
    "Python tip: `zip(*matrix)` transposes a 2D list — elegant and Pythonic.",
    "Python tip: `a, *rest, b = iterable` unpacks first, last, and everything in between in one line.",
    "Python tip: `pathlib.Path` is the modern, cross-platform way to handle file paths.",
    "Python tip: Use `__slots__` on data-heavy classes to cut memory usage significantly.",
    "Python tip: `itertools.chain.from_iterable(nested)` flattens one level of nesting lazily.",
    "Dev tip: Read error messages from the bottom up — the root cause is almost always last.",
    "Dev tip: The fastest way to understand unfamiliar code is to run it with a debugger, not just read it.",
    "Dev tip: Write the test first, even if just as a comment — it clarifies what 'done' means.",
    "Dev tip: Name variables by what they *are*, name functions by what they *do*.",
    "Dev tip: If you need a comment to explain what code does, consider renaming instead.",
    "Dev tip: Sleep on hard bugs — your brain keeps working. A fresh look finds what focus missed.",
    "Dev tip: `TODO:` is fine, but `TODO(yourname): reason` is actually actionable.",
    "Dev tip: Before optimizing, measure. Premature optimization solves the wrong problem.",
    "Dev tip: Rubber duck debugging works. Explaining the problem out loud forces you to articulate assumptions.",
    "Dev tip: Small, frequent commits are easier to review, revert, and bisect than big ones.",
    "Dev tip: A good error message names the file, line, received value, and expected value.",
    "Dev tip: If you're not sure where a bug is, add logging. Then add more logging.",
    "Regex tip: `\\b` matches a word boundary — use it to avoid matching substrings inside longer words.",
    "Regex tip: Non-capturing groups `(?:...)` are faster when you don't need to capture the match.",
    "Regex tip: `.*?` (lazy) vs `.*` (greedy) — lazy stops at the first match, greedy at the last.",
    "SQL tip: `EXPLAIN ANALYZE` shows the actual query plan with real row counts and timings.",
    "SQL tip: Partial indexes (`WHERE condition`) are much smaller and faster for filtered queries.",
    "SQL tip: `COALESCE(a, b, c)` returns the first non-NULL value — useful for default fallbacks.",
    "SQL tip: Window functions like `ROW_NUMBER() OVER (PARTITION BY ...)` avoid many self-joins.",
    "Linux tip: `lsof -i :8080` shows which process is listening on port 8080.",
    "Linux tip: `htop` is a much more readable alternative to `top` for process monitoring.",
    "Linux tip: `du -sh * | sort -hr` finds your biggest directories, sorted by size.",
    "Linux tip: `ss -tulnp` lists all listening sockets with the process name attached.",
    "Linux tip: `journalctl -u service -f` tails logs for a specific systemd service live.",
    "Linux tip: `find . -name '*.log' -mtime +7 -delete` removes log files older than 7 days.",
    "Security tip: Secrets go in environment variables or a secrets manager, never in source code.",
    "Security tip: Always hash passwords with bcrypt, scrypt, or Argon2 — never MD5 or SHA-1.",
    "Security tip: Parameterized queries eliminate SQL injection — string formatting in queries does not.",
    "Security tip: Set `Content-Security-Policy` headers to block XSS in browsers that support it.",
    "Security tip: The principle of least privilege: give code only the permissions it actually needs.",
    "Career tip: The best code is code someone else can maintain without asking you questions.",
    "Career tip: Being able to explain a complex concept simply is a more valuable skill than knowing it.",
    "Career tip: Code reviews are about the code, not the coder. Give and receive them that way.",
    "Career tip: Writing a clear bug report is often harder than fixing the bug — it's a valuable skill.",
    "Career tip: The most impactful thing you can do is unblock your teammates.",
    "Fun fact: The first computer bug was an actual moth found in a relay of the Harvard Mark II in 1947.",
    "Fun fact: The average web page today is larger in bytes than the entire memory of the Apollo 11 computer.",
    "Fun fact: Git was created by Linus Torvalds in 2005 to manage the Linux kernel after a licensing dispute.",
    "Fun fact: The QWERTY keyboard layout was designed in 1873 to prevent typewriter jams, not for speed.",
    "Fun fact: Stack Overflow was founded in 2008 by Joel Spolsky and Jeff Atwood.",
    "Fun fact: Python is named after Monty Python's Flying Circus, not the snake.",
]


def main():
    now = datetime.now(timezone.utc)
    today = now.strftime("%Y-%m-%d")
    time_str = now.strftime("%H:%M UTC")

    # Deterministic rotation based on day-of-year so same day always gets same tip
    tip = TIPS[now.timetuple().tm_yday % len(TIPS)]

    log_path = "streak/activity-log.md"
    os.makedirs("streak", exist_ok=True)

    if not os.path.exists(log_path):
        with open(log_path, "w") as f:
            f.write("# Daily Activity Log\n\n")
            f.write("Auto-updated daily to keep the GitHub contribution streak alive.\n")
            f.write("Each entry includes a dev tip or fun fact.\n\n")
            f.write("---\n")

    with open(log_path, "a") as f:
        f.write(f"\n## {today} — {time_str}\n\n")
        f.write(f"> {tip}\n")


if __name__ == "__main__":
    main()
