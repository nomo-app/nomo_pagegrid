Please validate the implementation in the following pull request by writing comprehensive tests: $ARGUMENTS

Options:
- `--no-confirm`: Skip user confirmation steps and write tests automatically based on the specification

Follow these steps to validate the feature implementation:

1. **Fetch and Analyze PR**
   - Use `gh pr view $ARGUMENTS` to get the PR details
   - Extract the feature specification and implementation details
   - Identify what needs to be tested based on the specification
   - Review the actual implementation to understand the code

2. **Verify Environment**
   - Confirm we're in the correct worktree with `git status`
   - Verify the branch matches the PR: `gh pr view $ARGUMENTS --json headRefName -q .headRefName`
   - Note: This command should be run from within the worktree created by the architect command

3. **Determine Testing Scope**
   - If `--no-confirm` is NOT used:
     - Present the identified test areas to the user
     - Ask about desired test coverage level:
       - Basic: Core functionality only
       - Comprehensive: All features and edge cases
       - Extensive: Including performance and integration tests
     - Example: "I've identified these areas to test: [list]. How extensive should the testing be?"
   - If `--no-confirm` is used:
     - Default to comprehensive testing
     - Test all public APIs and key behaviors

4. **Test Planning**
   - Create a test plan based on the specification
   - Identify test cases for:
     - Happy path scenarios
     - Edge cases
     - Error conditions
     - Business logic validation
   - Group tests logically by component or feature

5. **Write Tests**
   - If `--no-confirm` is NOT used:
     - For each test group:
       - Explain what will be tested
       - Show test code before writing
       - Ask for confirmation or adjustments
   - If `--no-confirm` is used:
     - Write all tests based on the plan
     - Use descriptive test names
     - Add comments for complex test logic
   - **Important**: Never create mocks - use real implementations or existing test utilities
   - **Commit after completing each test group**

6. **Test Implementation**
   - Focus on testing actual business logic
   - Ensure tests cover:
     - Public API contracts
     - State management
     - User interactions
     - Integration points
   - Use existing test patterns from the codebase
   - **Commit working tests before moving to next group**

7. **Run Tests**
   - Execute the test suite
   - Fix any failing tests
   - Ensure all new tests pass
   - Run existing tests to ensure no regression

8. **Validate Business Logic**
   - If `--no-confirm` is NOT used:
     - Review test results with user
     - Confirm tests adequately cover business requirements
     - Ask: "Do these tests properly validate the business logic?"
   - Only proceed to validation after confirmation

9. **Analyze Implementation**
   - Review the implementation against the specification
   - Check for:
     - Missing features
     - Incorrect implementations
     - Performance issues
     - Code quality concerns
   - Document findings

10. **Post Findings to PR**
    - Create a validation report
    - Use `gh pr comment` to add findings to the PR:
      ```bash
      gh pr comment $ARGUMENTS --body "Validation Report: [findings]"
      ```
    - Include:
      - Test coverage summary
      - Business logic validation results
      - Any issues or concerns found
      - Recommendations for improvements

11. **Final Push**
    - Ensure all incremental commits have been made
    - Push all test commits to the PR branch
    - Note: Most commits should already be done incrementally during step 5-6

Important Guidelines:
- **Incremental Commits**: Commit after each test group is complete and passing
- **No Mocks**: Never create mock objects - use real implementations
- **Business Logic Focus**: Ensure tests validate actual business requirements
- **User Confirmation**: Confirm test coverage meets expectations before validating
- **Comprehensive Coverage**: Test both success and failure scenarios
- **Clear Test Names**: Use descriptive names that explain what is being tested
- **Existing Patterns**: Follow the project's existing test patterns and conventions

Example Interaction (Normal Mode):
```
Claude: Analyzing PR #123 for validation...

I've identified the following areas that need testing:
1. SliverNomoPageGrid widget initialization
2. Drag and drop functionality in sliver context
3. Scroll coordination between inner and outer scrollables
4. State management during item reordering

How extensive should the testing be?
- Basic: Core functionality only
- Comprehensive: All features and edge cases (recommended)
- Extensive: Including performance and integration tests

User: Comprehensive

Claude: I'll write comprehensive tests. Here's the first test for widget initialization:
[shows test code]
Does this properly test the business logic?

User: Yes, but also test the height parameter validation

Claude: Good point. Here's the updated test:
[shows updated test code]

[... continues with other tests ...]

Claude: All tests are written and passing. The tests validate:
✓ Widget initialization with various parameters
✓ Drag and drop maintains item order correctly
✓ Scroll coordination prevents conflicts
✓ State updates trigger appropriate callbacks

Do these tests adequately validate the business logic?

User: Yes

Claude: Running final validation of the implementation...

Posting validation report to PR #123...
```

Example Interaction (With --no-confirm):
```
Claude: Analyzing PR #123 for validation...

Identified test areas:
1. SliverNomoPageGrid widget initialization
2. Drag and drop functionality
3. Scroll coordination
4. State management

Writing comprehensive tests...

✓ Created widget initialization tests
✓ All tests passing
✓ Committed: "test: add widget initialization tests for SliverNomoPageGrid (#123)"

✓ Created drag and drop interaction tests  
✓ All tests passing
✓ Committed: "test: add drag-drop tests for SliverNomoPageGrid (#123)"

✓ Created scroll coordination tests
✓ All tests passing
✓ Committed: "test: add scroll coordination tests (#123)"

✓ Created state management tests
✓ All tests passing
✓ Committed: "test: add state management tests (#123)"

Validating implementation against specification...

✓ All specified features are implemented correctly
✓ Business logic matches requirements
⚠ Found minor issue: Missing parameter validation for negative height

Posting validation report to PR #123...
✓ Validation complete
```

Workflow Summary:
1. **Validate command** analyzes the PR and writes tests
2. **User confirms** test coverage is appropriate (unless --no-confirm)
3. **Tests are run** to ensure correctness
4. **Implementation is validated** against specification
5. **Findings are posted** to the PR as a comment

Remember:
- Never create mocks - use real implementations
- Focus on testing business logic
- Get user confirmation on test coverage
- Only validate after tests are confirmed correct
- Post clear, actionable findings to the PR
- Commit after each test group is complete