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

## Error Handling and Logging

### Error Handling Principles

#### Never Ignore Errors
- Every error must be caught and handled appropriately
- Use try-catch blocks for synchronous code
- Use catchError operator for RxJS observables
- Provide user-friendly error messages
- Log all errors for debugging and monitoring

#### Global Error Handler
- Implement a global ErrorHandler service
- Catch unhandled errors and exceptions
- Log errors to monitoring service (e.g., Sentry, LogRocket)
- Display user-friendly error notifications

```typescript
@Injectable()
export class GlobalErrorHandler implements ErrorHandler {
  constructor(private injector: Injector) {}

  handleError(error: Error | HttpErrorResponse): void {
    const notificationService = this.injector.get(NotificationService);
    const logger = this.injector.get(LoggerService);

    if (error instanceof HttpErrorResponse) {
      // Server error
      logger.error('HTTP Error', { status: error.status, message: error.message });
      notificationService.error('Server error occurred. Please try again.');
    } else {
      // Client error
      logger.error('Client Error', { message: error.message, stack: error.stack });
      notificationService.error('An unexpected error occurred.');
    }
  }
}
```

#### HTTP Error Handling
- Use interceptors for global HTTP error handling
- Handle specific status codes appropriately
- Provide context-specific error messages
- Retry failed requests when appropriate

```typescript
export class ErrorInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    return next.handle(req).pipe(
      catchError((error: HttpErrorResponse) => {
        let errorMessage = 'An error occurred';
        
        if (error.status === 401) {
          errorMessage = 'Unauthorized. Please login.';
          // Redirect to login
        } else if (error.status === 404) {
          errorMessage = 'Resource not found.';
        } else if (error.status === 500) {
          errorMessage = 'Server error. Please try again later.';
        }
        
        return throwError(() => new Error(errorMessage));
      })
    );
  }
}
```

### Structured Logging

#### Logging Service
- Implement a centralized logging service
- Include structured context with every log
- Support multiple log levels (debug, info, warn, error)
- Send logs to backend or monitoring service

```typescript
@Injectable({ providedIn: 'root' })
export class LoggerService {
  debug(message: string, context?: any): void {
    if (!environment.production) {
      console.debug(`[DEBUG] ${message}`, context);
    }
  }

  info(message: string, context?: any): void {
    console.log(`[INFO] ${message}`, context);
    this.sendToBackend('info', message, context);
  }

  warn(message: string, context?: any): void {
    console.warn(`[WARN] ${message}`, context);
    this.sendToBackend('warn', message, context);
  }

  error(message: string, context?: any): void {
    console.error(`[ERROR] ${message}`, context);
    this.sendToBackend('error', message, context);
  }

  private sendToBackend(level: string, message: string, context?: any): void {
    // Send to backend logging endpoint
  }
}
```

#### What to Log

**Info Level:**
- User authentication events (login, logout)
- Navigation events
- Important user actions (form submissions, file uploads)
- API request/response summaries

**Warning Level:**
- Validation failures
- Deprecated feature usage
- Performance issues (slow responses)
- Recoverable errors

**Error Level:**
- Unhandled exceptions
- HTTP errors
- Failed API requests
- Runtime errors

**Never Log:**
- Passwords or authentication tokens
- Credit card numbers or PII
- Full request/response bodies (unless sanitized)
- API keys or secrets

### Avatar Upload Logging and Error Handling

When implementing avatar upload functionality, follow these specific requirements:

#### Upload Start
Log when the upload process begins with:
- Operation name: "Avatar Upload"
- User ID
- File name and size
- MIME type

```typescript
uploadAvatar(file: File): Observable<UploadResponse> {
  this.logger.info('Avatar upload started', {
    operation: 'avatar-upload',
    userId: this.authService.currentUser()?.id,
    fileName: file.name,
    fileSize: file.size,
    mimeType: file.type
  });

  // Implementation...
}
```

#### Validation Step
Log validation results:
- File type validation
- File size validation
- Image dimension validation (if applicable)

```typescript
private validateFile(file: File): boolean {
  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
  const maxSize = 5 * 1024 * 1024; // 5MB

  if (!allowedTypes.includes(file.type)) {
    this.logger.warn('Avatar upload failed: invalid file type', {
      operation: 'avatar-upload-validation',
      fileName: file.name,
      mimeType: file.type,
      allowedTypes
    });
    return false;
  }

  if (file.size > maxSize) {
    this.logger.warn('Avatar upload failed: file too large', {
      operation: 'avatar-upload-validation',
      fileName: file.name,
      fileSize: file.size,
      maxSize
    });
    return false;
  }

  return true;
}
```

#### Upload Success
Log when upload completes successfully:
- Upload duration
- Final file URL
- User ID

```typescript
this.http.post<UploadResponse>('/api/auth/avatar', formData).pipe(
  tap(response => {
    this.logger.info('Avatar upload successful', {
      operation: 'avatar-upload-success',
      userId: this.authService.currentUser()?.id,
      fileUrl: response.fileUrl,
      duration: Date.now() - startTime
    });
  }),
  catchError(error => this.handleUploadError(error))
);
```

#### Error Handling
Catch and log all upload errors:
- Network errors
- Server errors (4xx, 5xx)
- Validation errors
- Unexpected errors

```typescript
private handleUploadError(error: HttpErrorResponse): Observable<never> {
  this.logger.error('Avatar upload failed', {
    operation: 'avatar-upload-error',
    userId: this.authService.currentUser()?.id,
    status: error.status,
    message: error.message,
    error: error.error
  });

  let userMessage = 'Failed to upload avatar. Please try again.';

  if (error.status === 413) {
    userMessage = 'File is too large. Maximum size is 5MB.';
  } else if (error.status === 415) {
    userMessage = 'Invalid file type. Please upload a JPEG, PNG, or GIF image.';
  }

  this.notificationService.error(userMessage);
  return throwError(() => new Error(userMessage));
}
```

#### Required Tags for Searchability
Always include these tags in avatar upload logs:
- "avatar" - for all avatar-related operations
- "upload" - for upload operations
- "error" - for error cases

This allows easy searching through logs:
```bash
# Search for all avatar upload errors
grep -i "avatar.*upload.*error" logs/
```

### User Action Logging

#### Track Important User Actions
```typescript
// Login
this.logger.info('User logged in', {
  userId: user.id,
  email: user.email,
  timestamp: new Date().toISOString()
});

// Profile update
this.logger.info('Profile updated', {
  userId: user.id,
  fields: Object.keys(updatedFields)
});

// Navigation
this.router.events.pipe(
  filter(event => event instanceof NavigationEnd)
).subscribe((event: NavigationEnd) => {
  this.logger.info('Navigation', {
    url: event.url,
    userId: this.authService.currentUser()?.id
  });
});
```

### Performance Monitoring

#### Log Performance Metrics
```typescript
export class PerformanceInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const startTime = Date.now();

    return next.handle(req).pipe(
      tap(() => {
        const duration = Date.now() - startTime;
        if (duration > 1000) {
          this.logger.warn('Slow API request', {
            url: req.url,
            method: req.method,
            duration
          });
        }
      })
    );
  }
}
```

### Error Boundaries

#### Component Error Boundaries
```typescript
@Component({
  selector: 'app-error-boundary',
  template: `
    @if (hasError) {
      <div class="error-boundary">
        <h2>Something went wrong</h2>
        <button (click)="retry()">Try Again</button>
      </div>
    } @else {
      <ng-content></ng-content>
    }
  `
})
export class ErrorBoundaryComponent {
  hasError = signal(false);

  constructor(private logger: LoggerService) {}

  handleError(error: Error): void {
    this.hasError.set(true);
    this.logger.error('Component error', {
      component: 'ErrorBoundary',
      message: error.message,
      stack: error.stack
    });
  }

  retry(): void {
    this.hasError.set(false);
  }
}
```

## Best Practices Summary

- **Type Safety**: Leverage TypeScript to catch errors at compile time
- **Immutability**: Treat data as immutable, use spread operator for updates
- **Reactive**: Embrace reactive programming with RxJS
- **Simplicity**: Keep components and services simple and focused
- **Testability**: Write testable code with clear dependencies
- **Performance**: Use OnPush, signals, and lazy loading
- **Accessibility**: Ensure components are accessible (ARIA, keyboard navigation)
- **Consistency**: Follow established patterns and conventions
- **Error Handling**: Never ignore errors, use global error handler, provide user-friendly messages
- **Logging**: Use structured logging with context, never log sensitive data