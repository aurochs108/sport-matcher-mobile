# Repository Instructions

## Testing

- Always use Mockito-generated mocks for tests.
- Prefer `@GenerateMocks` plus generated `*.mocks.dart` files over handwritten fake or mock classes.
- Stub behavior with `when(...).thenAnswer(...)` or `when(...).thenReturn(...)`, and verify interactions with `verify(...).called(...)` where interaction assertions matter.

## UI

- When adding or changing UI styling, prefer existing values and helpers from `AppTheme` for spacing, colors, radii, and related shared styling before introducing inline constants.
- If no existing `AppTheme` value fits a repeated or shared UI need, suggest adding a new variable/helper to `AppTheme`.
