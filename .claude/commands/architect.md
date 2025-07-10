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

6. **Create GitHub Issue**
   - Use `gh issue create` to create a new issue with the feature specification
   - Include all architectural decisions and rationale
   - Add implementation tasks as a checklist
   - Include test plan and acceptance criteria
   - Note the issue number for reference

7. **Create Feature Branch**
   - Generate appropriate branch name (e.g., feature/component-name)
   - Create the branch without checking it out:
     ```bash
     git branch feature/component-name
     ```
   - Push the branch to origin:
     ```bash
     git push -u origin feature/component-name
     ```

8. **Create Git Worktree**
   - Extract issue number from the created issue
   - Create a worktree for isolated development:
     ```bash
     git worktree add ./features/$(basename $(pwd))-issue-<ISSUE_NUMBER> feature/component-name
     ```
   - Inform user about the worktree location
   - Suggest launching Claude in the worktree:
     ```bash
     cd ./features/$(basename $(pwd))-issue-<ISSUE_NUMBER> && claude
     ```

9. **Documentation**
   - Update CLAUDE.md if needed for future reference
   - Consider if README updates are needed
   - Document any new patterns introduced

The issue should include:
- **Summary**: Clear description of what's being built and why
- **Architecture Overview**: High-level design with components
- **Technical Design**: Detailed implementation approach
- **API/Interface Design**: If applicable
- **Data Flow**: How data moves through the system
- **Tasks Checklist**: Broken down implementation steps
- **Testing Strategy**: How to verify the implementation
- **Acceptance Criteria**: How to know when the feature is complete

Remember to:
- Keep designs modular and maintainable
- Follow existing project conventions
- Consider future extensibility
- Document trade-offs and decisions
- Ensure the design aligns with project goals

Final Output:
```
✓ Feature specification created
✓ Issue created: #456
✓ Branch created: feature/component-name
✓ Branch pushed to origin
✓ Worktree created at: ./features/project-issue-456

Next steps:
1. Launch Claude in the worktree:
   cd ./features/project-issue-456 && claude

2. In the new Claude session, run:
   /implement #456

3. When done, clean up the worktree:
   git worktree remove ./features/project-issue-456
```