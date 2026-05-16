# Repository Instructions

## Testing

- Always use Mockito-generated mocks for tests.
- Prefer `@GenerateMocks` plus generated `*.mocks.dart` files over handwritten fake or mock classes.
- Stub behavior with `when(...).thenAnswer(...)` or `when(...).thenReturn(...)`, and verify interactions with `verify(...).called(...)` where interaction assertions matter.
