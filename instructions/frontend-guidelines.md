# Frontend Development Guidelines

## Technology Stack

- Use the latest LTS version of Node.js
- Use modern TypeScript with strict type checking
- Use Angular with standalone components
- Use RxJS for reactive programming
- Use ngrx for state management

## TypeScript Configuration

### Strict Type Checking

{

"strict": true,

"noImplicitReturns": true,

"noUnusedParameters": true,

"noUnusedLocals": true,

"noEmitOnError": true,

"forceConsistentCasingInFileNames": true

}

### Type Safety

- Avoid any type unless absolutely necessary (document why)
- Avoid type assertions (as) except as const (document reasoning)
- Use TypeScript's type system to prevent runtime errors
- Prefer type inference when the type is obvious

## Variable Declarations

- Use const for variables that are not reassigned
- Use let only when a variable needs to be reassigned
- Never use var
- Destructure objects and arrays where appropriate

## Operators

- Use === for equality checks (except == null for null/undefined check)
- Prefer ?? over || for nullish coalescing
- Use ??= for nullish assignment
- Use optional chaining ?. instead of explicit null checks

## Functional Programming

- Prefer functional style over imperative
- Use array methods: map, filter, reduce, find
- Extract complex array method logic into separate functions
- Prefer for-of loops over traditional for loops when iterating arrays

## Asynchronous Code

- Use async/await instead of .then() chaining
- Handle errors with try-catch blocks
- Avoid nested promises
- Use Promise.all() for parallel operations

## Imports & Modules

- Use ES6 import statements
- Group imports: external ? internal ? relative
- Ignore unused imports (handled by linter)
- Use path aliases from tsconfig.json

## Angular Best Practices

### Components

#### Structure

- Always use standalone components
- Keep components small and focused (< 200 lines)
- Use OnPush change detection: changeDetection: ChangeDetectionStrategy.OnPush
- Use inline templates for small components (= 5 lines)
- Prefer reactive forms over template-driven forms

#### Component API

- Use input() function instead of @Input() decorator
- Use output() function instead of @Output() decorator
- Use viewChild() for template queries
- Use signals for local component state

#### Templates

- Use native control flow (@if, @for, @switch) instead of structural directives
- DO NOT use ngClass; use \[class.name\] bindings
- DO NOT use ngStyle; use \[style.property\] bindings
- Keep template logic simple - move complexity to component class
- Use async pipe for observables

### State Management with ngrx

#### Local vs Global State

- Use **signals** for local component state
- Use **ngrx store** for global/shared state
- Use computed() for derived state

#### Store Structure

// Actions

export const loadUsers = createAction('\[Users\] Load');

export const loadUsersSuccess = createAction(

'\[Users\] Load Success',

props&lt;{ users: User\[\] }&gt;()

);

// Reducer

export const usersReducer = createReducer(

initialState,

on(loadUsersSuccess, (state, { users }) => ({ ...state, users }))

);

// Selectors

export const selectUsers = createSelector(

selectUsersState,

(state) => state.users

);

// Effects

loadUsers\$ = createEffect(() =>

this.actions\$.pipe(

ofType(loadUsers),

switchMap(() =>

this.service.getUsers().pipe(

map(users => loadUsersSuccess({ users })),

catchError(error => of(loadUsersFailure({ error })))

)

)

)

);

#### Effects Best Practices

- Use createEffect with ofType for action handling
- Keep effects simple and focused
- Use ToastEffects for showing toast messages
- Handle errors within effects

### Reactive Programming

#### Observable Patterns

- Prefer reactive style with observables and async pipe
- Use combineLatest to combine multiple observables into a view model
- Consider moving complex combination logic into selectors
- Assign observables in constructor (TypeScript needs this for type inference)

// Good pattern

readonly viewModel\$ = combineLatest({

users: this.store.select(selectUsers),

loading: this.store.select(selectLoading),

filter: this.filterControl.valueChanges

}).pipe(

map(({ users, loading, filter }) => ({

users: this.filterUsers(users, filter),

loading

}))

);

#### Component Input with Observables

- Receiving components must allow null in input types when using async pipe
- The async pipe emits null until the observable emits a value

### Dependency Injection

- Use inject() function instead of constructor injection
- Register services with providedIn: 'root' for singletons
- Design services around single responsibility

### Services

- Keep services focused on one responsibility
- Use dependency injection
- Make services stateless when possible
- Use observables for async operations

## Naming Conventions

### Files

- Components: component-name.component.ts
- Services: service-name.service.ts
- Models: model-name.model.ts
- Interfaces: interface-name.interface.ts or interface-name.ts

### Variables & Functions

- Use camelCase for variables and functions
- Use descriptive names that convey intent
- Avoid single-letter names except for loop indices
- Avoid abbreviations unless universally understood

### Classes & Interfaces

- Use PascalCase for classes and interfaces
- Add appropriate suffix: UserService, UserComponent
- Don't prefix interfaces with I

### Constants & Enums

- Use UPPER_SNAKE_CASE for constants
- Use PascalCase for enum names
- Use PascalCase for enum values

## Testing

### Unit Tests with Jasmine/Karma

#### Test Structure

- One test file per component/service: \*.spec.ts
- Use descriptive test names: should load users when component initializes
- Follow AAA pattern (Arrange, Act, Assert)
- Do NOT add Arrange/Act/Assert comments

#### Test Data

- Always create shallow copies from mock data
- Use spread operator: { ...mockData }
- Or use cloneDeep from lodash

#### Running Tests

- Use fdescribe to run single file tests (remove before commit)
- Run tests: yarn test-watch (continuous) or yarn test-silent (once)
- DO NOT use testNamePattern (not supported in Angular)
- Run linter: yarn lint-silent

#### Mocking

- Mock dependencies using test doubles
- Use provideMock for service mocking
- Create mock factories for complex objects

### Best Practices

- Test business logic, not implementation details
- Aim for high coverage but focus on critical paths
- Test error scenarios and edge cases
- Keep tests independent and isolated

## Code Quality

### Avoid Common Pitfalls

- Don't use console.log in production (OK for debugging, remove before commit)
- Avoid dead code and useless checks
- Don't re-check conditions that TypeScript already ensures
- Remove unused variables and imports (linter handles this)

### Method Parameters

- Be restrictive: pass only what's needed
- For single property, pass that property, not the whole object
- For 2 properties, consider using Pick&lt;Type, 'prop1' | 'prop2'&gt;

### Readability

- Use descriptive variable names
- Avoid abbreviations
- Comments should explain "why", not "what"
- Keep methods short and focused

## Styling

### CSS/SCSS

- Use component-scoped styles
- Follow BEM or similar naming convention
- Use CSS custom properties for theming
- Avoid !important unless absolutely necessary

### Class Bindings

// Good

&lt;div \[class.active\]="isActive" \[class.disabled\]="isDisabled"&gt;

// Bad

&lt;div \[ngClass\]="{ active: isActive, disabled: isDisabled }"&gt;

### Style Bindings

// Good

&lt;div \[style.width.px\]="width" \[style.color\]="color"&gt;

// Bad

&lt;div \[ngStyle\]="{ width: width + 'px', color: color }"&gt;

## Images

- Use NgOptimizedImage directive for all static images
- Provide width and height attributes
- Use appropriate image formats (WebP when possible)

## Performance

### Change Detection

- Use OnPush change detection strategy
- Use signals for fine-grained reactivity
- Avoid expensive operations in templates
- Use trackBy with @for loops

### Lazy Loading

- Implement lazy loading for feature routes
- Use dynamic imports for code splitting
- Preload strategies for better UX

### Bundle Optimization

- Tree-shake unused code
- Analyze bundle size regularly
- Split vendor and application bundles

## Linting & Formatting

- Use ESLint with TypeScript parser
- Configure Prettier for consistent formatting
- Use .editorconfig for editor consistency
- Run linter before commits (use husky/lint-staged)

## rxjs Patterns

### Operators

- Use switchMap for cancellable requests
- Use mergeMap for concurrent requests
- Use concatMap for sequential requests
- Use exhaustMap to ignore new requests while one is pending

### Subscriptions

- Unsubscribe to prevent memory leaks
- Use takeUntil with destroy\$ observable
- Prefer async pipe over manual subscription
- Use take(1) for one-time subscriptions

## Documentation

### Code Comments

- Keep comments terse and relevant
- Document complex logic or non-obvious decisions
- Use JSDoc for public APIs
- Update comments when code changes

### README Files

- Document setup and development workflow
- List prerequisites and dependencies
- Provide examples for common tasks
- Keep it up-to-date

## Best Practices Summary

- **Type Safety**: Leverage TypeScript to catch errors at compile time
- **Immutability**: Treat data as immutable, use spread operator for updates
- **Reactive**: Embrace reactive programming with RxJS
- **Simplicity**: Keep components and services simple and focused
- **Testability**: Write testable code with clear dependencies
- **Performance**: Use OnPush, signals, and lazy loading
- **Accessibility**: Ensure components are accessible (ARIA, keyboard navigation)
- **Consistency**: Follow established patterns and conventions