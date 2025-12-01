# Pull Request Checklist

Use this checklist for every project to ensure smooth reviews and consistent previews.

## Required Steps

- Link PR number: Add the PR number and URL in the task or issue description for quick access.
- Labels: Apply `frontend`, `ready-for-review` (and any relevant labels like `design`, `bugfix`).
- Request reviews: Add GitHub Copilot and relevant human reviewers.
- Preview build: Trigger a preview build to visually verify changes.

## How-To

- Link PR
  - Copy the PR URL from GitHub and paste into the task/issue or chat.

- Add Labels
  - Open the PR → right sidebar → Labels → select `frontend`, `ready-for-review`.

- Request Copilot Review
  - Open the PR → right sidebar → Reviewers → add GitHub Copilot.
  - If Copilot integration is enabled, it will post an automated review.

- Trigger Preview Build
  - If your repo has a preview workflow, use the PR Checks tab → `Preview Deploy` → `Re-run`.
  - Or trigger manually via CLI (if `gh` is installed):

```bash
# Example using GitHub CLI (requires gh installed and authenticated)
gh pr checkout <PR_NUMBER>
gh workflow run preview.yml -f pr_number=<PR_NUMBER>
```

## Optional Checks

- Verify links: Run a quick local build and check pages touched.
- Accessibility: Basic color contrast and keyboard navigation checks.
- Screenshots: Attach before/after screenshots in the PR description.

## Notes

- Keep PRs focused and small; group related changes.
- Ensure all commits are pushed to the PR branch before requesting review.