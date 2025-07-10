Please architect and design the following feature or system component: $ARGUMENTS

Follow these steps to create a comprehensive architectural design:

1. **Understand the Requirements**
   - Analyze the feature/component requirements
   - Identify key functional and non-functional requirements
   - List any constraints or dependencies

2. **Research Existing Architecture**
   - Use search tools to understand the current codebase structure
   - Identify integration points with existing components
   - Note any patterns or conventions already in use

3. **Design the Architecture**
   - Create a high-level design overview
   - Break down into modular components
   - Define interfaces and data flow
   - Consider appropriate design patterns

4. **Implementation Plan**
   - Create a detailed step-by-step implementation plan
   - Identify tasks that can be parallelized
   - Estimate complexity and timeline
   - Define success criteria

5. **Technical Considerations**
   - Performance implications
   - Scalability requirements
   - Security considerations
   - Testing strategy
   - Error handling approach

6. **Create Feature Branch**
   - Generate appropriate branch name (e.g., feature/component-name)
   - Use `git checkout -b` to create the branch
   - Create an initial Commit before creating the Pull Request
   - Switch back to master branch 

7. **Create Pull Request**
   - Use `gh pr create` with comprehensive PR description
   - Include all architectural decisions and rationale
   - Add task checklist for implementation
   - Include test plan
   - Note the PR number for worktree creation

8. **Create Git Worktree**
   - Extract PR number from the created PR
   - Create a worktree for isolated development:
     ```bash
     git worktree add ./features/$(basename $(pwd))-pr-<PR_NUMBER> <BRANCH_NAME>
     ```
   - Inform user about the worktree location
   - Suggest launching Claude in the worktree:
     ```bash
     cd ./features/$(basename $(pwd))-pr-<PR_NUMBER> && claude
     ```

9. **Documentation**
   - Update CLAUDE.md if needed for future reference
   - Consider if README updates are needed
   - Document any new patterns introduced

The PR should include:
- **Summary**: Clear description of what's being built and why
- **Architecture Overview**: High-level design with components
- **Technical Design**: Detailed implementation approach
- **API/Interface Design**: If applicable
- **Data Flow**: How data moves through the system
- **Tasks Checklist**: Broken down implementation steps
- **Testing Strategy**: How to verify the implementation
- **Timeline**: Estimated schedule for completion

Remember to:
- Keep designs modular and maintainable
- Follow existing project conventions
- Consider future extensibility
- Document trade-offs and decisions
- Ensure the design aligns with project goals

Final Output:
```
✓ Feature specification created
✓ Branch created: feature/component-name
✓ Pull request created: #123
✓ Worktree created at: ./features/project-pr-123

Next steps:
1. Launch Claude in the worktree:
   cd ./features/project-pr-123 && claude

2. In the new Claude session, run:
   /implement https://github.com/owner/repo/pull/123

3. When done, clean up the worktree:
   git worktree remove ./features/project-pr-123
```