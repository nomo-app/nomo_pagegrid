Please implement the feature specified in the following issue: $ARGUMENTS

Options:
- `--no-confirm`: Skip user confirmation steps and implement automatically based on the specification

Follow these steps to implement the feature based on the issue specification:

1. **Fetch and Analyze Issue**
   - Use `gh issue view $ARGUMENTS` to get the issue details
   - Extract the feature specification from the issue description
   - Identify the implementation tasks and requirements
   - Note any architectural decisions or constraints

2. **Verify Environment**
   - Confirm we're in the correct worktree with `git status`
   - Get the current branch name to verify we're on the feature branch
   - Note: This command should be run from within the worktree created by the architect command

3. **Review Implementation Plan**
   - If `--no-confirm` is NOT used:
     - Present the extracted implementation tasks to the user
     - Ask for clarification on any ambiguous requirements
     - Confirm the implementation approach before proceeding
     - Example: "I found these implementation tasks: [list]. Should I proceed with [approach]?"
   - If `--no-confirm` is used:
     - Log the implementation plan for reference
     - Proceed automatically with best judgment

4. **Interactive Implementation**
   - If `--no-confirm` is NOT used:
     - For each major component or task:
       - Explain what you're about to implement
       - Ask for user confirmation or alternative approach
       - Show code snippets for review before writing files
     - Example: "I'll now implement the SliverNomoPageGrid widget. Here's my approach: [details]. Does this look correct?"
   - If `--no-confirm` is used:
     - Implement each component based on specification
     - Log progress as you go
     - Make reasonable decisions based on existing patterns

5. **Code Implementation**
   - Implement features incrementally, one component at a time
   - Follow existing code patterns and conventions
   - Use appropriate design patterns from the specification
   - Ensure proper error handling and edge cases
   - **Stage changes after each component/subtask is complete**

6. **Code Quality**
   - Run linting and formatting tools after each component
   - Fix any linting errors immediately
   - Ensure code follows project style guidelines
   - Run type checking if available
   - **Stage all changes for the current subtask**

7. **Review and Commit**
   - After implementing and staging changes for a subtask:
   - Use `git status` to show staged files
   - Use `git diff --staged` to show staged changes
   - If `--no-confirm` is NOT used:
     - Ask user: "I've staged the changes for [subtask]. Please review them in VSCode. Should I commit these changes? (yes/no)"
     - Wait for user confirmation before committing
     - If user says no, ask what changes they'd like or if they want to manually commit
   - If `--no-confirm` is used:
     - Automatically commit the staged changes
   - Use descriptive commit messages referencing the issue number
   - Examples:
     - "feat: add basic SliverNomoPageGrid wrapper (#ISSUE_NUMBER)"
     - "feat: implement scroll coordination for SliverNomoPageGrid (#ISSUE_NUMBER)"
     - "feat: add drag-drop coordinate handling (#ISSUE_NUMBER)"
     - "docs: update README with SliverNomoPageGrid usage (#ISSUE_NUMBER)"

8. **Integration**
   - Integrate new components with existing code
   - Update any necessary imports or exports
   - Ensure backward compatibility if required
   - Update example app if specified in issue
   - Stage and review changes as in step 7

9. **Documentation Updates**
   - Add inline code documentation
   - Update README if new public APIs are added
   - Update CLAUDE.md if new patterns are introduced
   - Add usage examples where appropriate
   - Stage and review changes as in step 7

10. **Final Review**
    - Show summary of all changes made
    - If `--no-confirm` is NOT used:
      - Ask user to review the implementation
      - Make any requested adjustments
    - Push all commits to the feature branch

11. **Create Pull Request**
    - Use `gh pr create` to create a pull request
    - Link the PR to the original issue with "Closes #ISSUE_NUMBER"
    - Include implementation summary in PR description
    - List all changes made during implementation
    - Add any notes about design decisions or trade-offs
    - Request review if appropriate

Important Guidelines:
- **Prerequisite**: Run this command from within the worktree created by the architect command
- **Isolated Environment**: Implementation happens in a dedicated worktree
- **No Testing**: This command focuses only on implementation, not testing
- **Interactive Process**: Confirm approach with user before implementing (unless `--no-confirm` is used)
- **Incremental Implementation**: Build features step by step, not all at once
- **Staging Process**:
  - Stage changes after implementing each subtask using `git add`
  - Show staged files with `git status`
  - Allow user to review staged changes in VSCode before committing
  - Only commit after user approval (unless `--no-confirm` is used)
- **User Feedback**: Pause for user input at major decision points (unless `--no-confirm` is used)
- **Code Quality**: Ensure lint-free, well-formatted code
- **Automatic Mode**: With `--no-confirm`, make reasonable decisions based on specification and patterns

Example Interaction (Normal Mode):
```
Claude: Verifying environment...
✓ Currently in worktree for branch: feature/sliver-nomo-pagegrid

I've analyzed issue #123. The specification requires:
1. Basic SliverNomoPageGrid wrapper
2. Scroll coordination handling
3. Drag-drop coordinate adjustments

Shall I start with the basic wrapper implementation? I plan to add the SliverNomoPageGrid class to `lib/nomo_pagegrid.dart`. Is this the correct approach?

User: Yes, that's correct

Claude: I'm implementing the basic SliverNomoPageGrid wrapper...
✓ Implementation complete
✓ Running flutter analyze - all checks passed
✓ Staged changes: lib/nomo_pagegrid.dart

I've staged the changes for the basic SliverNomoPageGrid wrapper. Please review them in VSCode. Should I commit these changes? (yes/no)

User: yes

Claude: ✓ Committed: "feat: add basic SliverNomoPageGrid wrapper (#123)"

Now implementing scroll coordination handling...
✓ Implementation complete
✓ Running flutter analyze - all checks passed
✓ Staged changes: lib/nomo_pagegrid.dart

I've staged the changes for scroll coordination. Please review them in VSCode. Should I commit these changes? (yes/no)

User: yes

Claude: ✓ Committed: "feat: implement scroll coordination for SliverNomoPageGrid (#123)"

[After all implementation is complete]

Claude: All implementation tasks are complete. Creating pull request...

✓ Pull request created: #124
  Title: Implement SliverNomoPageGrid feature
  Closes: #123
```

Example Interaction (With --no-confirm):
```
Claude: Verifying environment...
✓ Currently in worktree for branch: feature/sliver-nomo-pagegrid

I've analyzed issue #123. The specification requires:
1. Basic SliverNomoPageGrid wrapper
2. Scroll coordination handling
3. Drag-drop coordinate adjustments

Starting implementation based on specification...

✓ Implementing basic SliverNomoPageGrid wrapper in lib/nomo_pagegrid.dart
✓ Running flutter analyze - all checks passed
✓ Committed: "feat: add basic SliverNomoPageGrid wrapper (#123)"

✓ Adding scroll coordination handling
✓ Running flutter analyze - all checks passed
✓ Committed: "feat: implement scroll coordination for SliverNomoPageGrid (#123)"

✓ Implementing drag-drop coordinate adjustments
✓ Running flutter analyze - all checks passed
✓ Committed: "feat: add drag-drop coordinate handling (#123)"

✓ Pushed all changes to feature/sliver-nomo-pagegrid

✓ Pull request created: #124
  Title: Implement SliverNomoPageGrid feature
  Closes: #123

Implementation complete. PR #124 has been created and linked to issue #123.
```

Workflow Summary:
1. **Architect command** creates the feature specification, issue, and worktree
2. **Launch Claude** in the worktree: `cd ./features/project-issue-123 && claude`
3. **Implement command** executes the implementation based on the issue spec
4. **Pull request** is created automatically at the end to close the issue

Remember:
- This command must be run from within a worktree
- Ask before making significant decisions (unless `--no-confirm` is used)
- Show code before writing to files (unless `--no-confirm` is used)
- Implement incrementally with user feedback (or automatically with `--no-confirm`)
- Focus on implementation only, not testing
- Keep commits clean and descriptive
- PR is created automatically when implementation is complete