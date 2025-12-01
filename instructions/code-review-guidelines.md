# Code Review Guidelines

## Purpose

Code reviews ensure code quality, share knowledge, catch bugs early, and maintain consistent standards across the team.

## Goals

- **Quality**: Improve code quality and catch bugs
- **Knowledge**: Share knowledge across the team
- **Consistency**: Maintain coding standards
- **Mentorship**: Help less experienced developers grow
- **Collaboration**: Foster team collaboration

## Review Process

### 1\. Before Creating a PR

#### Author Checklist

- Code is complete and tested
- All tests pass locally
- Code follows project style guidelines
- Self-reviewed the changes
- No debug code or commented-out code
- Documentation updated (if needed)
- Commit messages are clear and descriptive
- PR is reasonably sized (< 400 lines ideally)
- PR description is complete

#### Self-Review

Before requesting review, review your own code:

- Read every line as if seeing it for the first time
- Look for typos, formatting issues
- Check for accidental debug code
- Verify logic and edge cases
- Ensure tests are meaningful

### 2\. Creating the PR

#### PR Title

- Clear and descriptive
- Include ticket number if applicable
- Use conventional commit format

Examples:

feat: Add user authentication (JIRA-123)

fix: Resolve memory leak in vehicle tracking

refactor: Extract validation logic to separate service

#### PR Description

Use a template:

\## Description

Implements path simplification for vehicle routes using the Ramer-Douglas-Peucker algorithm.

\## Changes

\- Added PathTransformer with RDP algorithm

\- Added feature flag for gradual rollout

\- Updated MessageHandler to use transformer

\- Added comprehensive unit tests

\## Testing

\- Unit tests: All passing

\- Integration tests: All passing

\- Manual testing: Tested with real path data, 95% size reduction

\## Screenshots

\[If UI changes\]

\## Related Issues

Fixes #123

Relates to #456

\## Checklist

\- \[x\] Code follows style guidelines

\- \[x\] Self-reviewed

\- \[x\] Added/updated tests

\- \[x\] Updated documentation

\- \[x\] No warnings introduced

### 3\. Requesting Review

#### Choose Reviewers

- At least 1-2 reviewers
- Include someone familiar with the area
- Include someone less familiar (fresh perspective)
- Consider time zones and availability

#### Set Priority

- **Urgent**: Critical bug fixes
- **High**: Blocking other work
- **Normal**: Most PRs
- **Low**: Nice-to-have improvements

### 4\. During Review

#### For Authors

- **Be Responsive**: Reply to comments promptly
- **Be Open**: Accept feedback gracefully
- **Explain**: If you disagree, explain your reasoning
- **Learn**: View feedback as learning opportunity
- **Ask Questions**: If you don't understand a comment
- **Update PR**: Make requested changes
- **Re-request Review**: After addressing comments

#### For Reviewers

- **Be Timely**: Review within 1 business day (normal priority)
- **Be Thorough**: But don't nitpick every detail
- **Be Constructive**: Suggest improvements, don't just criticize
- **Be Kind**: Use positive language
- **Be Clear**: Make it clear what's required vs. optional
- **Ask Questions**: Instead of making assumptions
- **Acknowledge Good Work**: Praise good solutions

## What to Review

### 1\. Functionality

- Does the code do what it's supposed to?
- Are edge cases handled?
- Is error handling appropriate?
- Are there potential bugs?
- Are there security vulnerabilities?

### 2\. Code Quality

- Is it readable and maintainable?
- Does it follow project conventions?
- Is it well-structured?
- Are there code smells?
- Is complexity appropriate?
- Are names descriptive?

### 3\. Testing

- Are tests comprehensive?
- Do tests verify behavior, not implementation?
- Are edge cases tested?
- Do tests have good coverage?
- Are test names descriptive?

### 4\. Performance

- Are there performance implications?
- Are database queries optimized?
- Are resources managed properly?
- Are there potential memory leaks?

### 5\. Security

- Are inputs validated?
- Are there SQL injection vulnerabilities?
- Is sensitive data protected?
- Are authentication/authorization checks correct?

### 6\. Documentation

- Are public APIs documented?
- Are complex algorithms explained?
- Is the README updated if needed?
- Are comments helpful (not redundant)?

### 7\. Architecture

- Does it fit with overall architecture?
- Are dependencies appropriate?
- Is separation of concerns maintained?
- Are architectural boundaries respected?

## Comment Types

Use prefixes to clarify comment intent:

### ?? Required (Blocking)

Must be fixed before merge.

?? This will cause a null reference exception when user is not found

### ?? Suggestion (Non-blocking)

Nice to have, but optional.

?? Consider extracting this logic to a separate method for reusability

### ?? Question

Need clarification or explanation.

?? Why do we need to check this condition twice?

### ?? Praise

Acknowledge good work.

?? Nice solution! This is much cleaner than the previous approach

### ?? Note / FYI

Informational, no action needed.

?? There's a library function that does this: Array.sort()

### ?? Nitpick

Minor style issue, optional fix.

?? Nitpick: Extra blank line here

## Review Comments - Best Practices

### Be Specific

? Bad: "This is wrong"

? Good: "This will fail when userId is null. Consider adding a null check."

? Bad: "Improve this"

? Good: "This method is doing three things. Consider extracting the validation logic into ValidateUser()."

### Be Constructive

? Bad: "This code is terrible"

? Good: "This approach might cause performance issues with large datasets. Have you considered using pagination?"

? Bad: "Why didn't you use LINQ?"

? Good: "LINQ could make this more readable: users.Where(u => u.IsActive).Select(u => u.Name)"

### Ask Questions

? Bad: "This won't work"

? Good: "What happens if the user is null here?"

? Bad: "Change this"

? Good: "Would it be clearer to extract this to a separate method?"

### Provide Context

? Bad: "Use a dictionary"

? Good: "A dictionary would give O(1) lookup instead of O(n) with the current list, which matters since this is called in a loop"

? Bad: "Follow the style guide"

? Good: "Our style guide (section 3.2) recommends PascalCase for public methods"

### Suggest Solutions

? Bad: "This is inefficient"

? Good: "This loops through all users for each order. Consider building a dictionary first:

var userDict = users.ToDictionary(u => u.Id);

Then: var user = userDict\[order.UserId\];"

## Common Review Scenarios

### Large PRs

?? This PR has 800+ lines of changes. Consider breaking it into smaller, focused PRs:

1\. Core PathTransformer implementation

2\. Integration with MessageHandler

3\. Feature flag and configuration

This will make review easier and reduce merge conflicts.

### Unclear Intent

?? I'm not sure I understand the purpose of this change. Could you explain:

1\. What problem does this solve?

2\. Why this approach?

3\. What are the alternatives?

### Missing Tests

?? This new method needs unit tests, especially for:

\- Happy path with valid input

\- Edge case: empty list

\- Error case: null input

### Style Issues

?? Nitpick: Variable names should be camelCase per our style guide

Consider: userId instead of UserId

### Security Concerns

?? This endpoint is missing authorization. Anyone can access it.

Add: \[Authorize(Policy = Policies.AdminOnly)\]

### Performance Issues

?? This loads all users into memory. For large datasets, consider:

\- Pagination

\- Streaming results

\- Using IQueryable for deferred execution

## Response Time Guidelines

| **Priority** | **Response Time** |
| --- | --- |
| Critical/Hotfix | 2 hours |
| --- | --- |
| High | 4 hours |
| --- | --- |
| Normal | 1 business day |
| --- | --- |
| Low | 2 business days |
| --- | --- |

## Approval Criteria

### When to Approve

- All required changes addressed
- No blocking issues remain
- Tests pass
- Code meets quality standards
- Documentation is adequate

### When to Request Changes

- Blocking issues found
- Major refactoring needed
- Security vulnerabilities
- Missing critical tests
- Doesn't meet requirements

### When to Comment (No Approval)

- Minor suggestions
- Questions for clarification
- Want to see updates before final approval

## After Review

### For Authors

- Address all required comments
- Respond to questions
- Make optional changes at your discretion
- Re-request review
- Thank reviewers

### For Reviewers

- Review updated code
- Verify comments were addressed
- Approve when satisfied
- Follow up on any remaining questions

## Merging

### Before Merge

- All required approvals received
- All CI/CD checks pass
- All comments resolved
- Branch is up to date with target
- No merge conflicts

### Merge Strategy

Choose based on team preference:

- **Squash and Merge**: Clean history, single commit (recommended)
- **Merge Commit**: Preserves all commits
- **Rebase and Merge**: Linear history

### After Merge

- Delete source branch
- Update linked issues/tickets
- Monitor deployment
- Notify team if significant change

## Common Pitfalls to Avoid

### For Authors

? Getting defensive about feedback ? Ignoring review comments ? Making massive PRs ? Not testing before requesting review ? Poor PR descriptions

### For Reviewers

? Being too critical or harsh ? Nitpicking every detail ? Ignoring PRs for days ? Approving without actually reviewing ? Not explaining reasoning

## Review Checklist

### Quick Checklist for Reviewers

- Read PR description
- Understand the changes
- Check out code locally (if complex)
- Review for functionality
- Review for code quality
- Review for tests
- Review for security
- Review for performance
- Provide constructive feedback
- Approve or request changes

## Examples of Good Review Comments

### Functionality Issue

?? This will throw an exception when the list is empty.

Line 45: var first = items\[0\]; // IndexOutOfRangeException

Suggestion:

if (items.Count == 0) return null;

var first = items\[0\];

### Code Quality

?? This method is doing multiple things. Consider Single Responsibility Principle:

Current:

\- Validates input

\- Fetches from database

\- Transforms result

\- Sends notification

Suggestion: Extract SendNotification to separate method or service.

### Testing

?? Missing test for edge case: What happens when userId is invalid?

Please add test:

\[Test\]

public void GetUser_InvalidId_ThrowsNotFoundException() { }

### Performance

?? This could be slow with large datasets. Line 67 loops through all users for each order (O(n²)).

Consider:

var userMap = users.ToDictionary(u => u.Id);

foreach (var order in orders) {

var user = userMap\[order.UserId\]; // O(1)

}

### Positive Feedback

?? Nice refactoring! This is much more readable and testable than the previous version.

The separation of concerns is excellent.

## Best Practices Summary

- **Be Timely**: Review within agreed timeframes
- **Be Thorough**: But don't block on minor issues
- **Be Kind**: Use positive, constructive language
- **Be Clear**: Distinguish required from optional
- **Be Specific**: Point to exact lines and issues
- **Be Helpful**: Suggest solutions, not just problems
- **Be Learning**: Both reviewers and authors learn
- **Be Consistent**: Apply standards uniformly
- **Be Respectful**: Remember there's a person behind the code
- **Be Collaborative**: Work together toward better code