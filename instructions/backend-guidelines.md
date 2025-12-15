# Backend Development Guidelines

## Language & Framework {#language-framework}

- Use the latest stable .NET version specified in global.json

- Enable nullable reference types: \<Nullable\>enable\</Nullable\>

- Target framework should be consistent across projects

## Project Structure

### Organization

- Organize code by feature/domain, not by technical type

- Use layered architecture: Service → Logic → Data

- Keep shared/common code in separate projects

- Example structure:

> Service/
>
> ├── ServiceName/ \# Main service project
>
> ├── ServiceName.Logic/ \# Business logic
>
> ├── ServiceName.Data/ \# Data access layer
>
> ├── ServiceName.Common/ \# Shared DTOs, interfaces
>
> ├── ServiceName.UnitTests/
>
> └── ServiceName.IntegrationTests/

### Dependencies

- Use centralized package management with Directory.Packages.props

- Lock package versions with RestorePackagesWithLockFile

- Minimize circular dependencies between projects

- Use architectural boundary validation to enforce dependency rules

## Code Organization

### Namespaces

- Follow folder structure: namespace Company.ServiceName.Feature;

- Use file-scoped namespaces (C# 10+)

- One namespace per file

### Interfaces

- Define interfaces in the same file or in dedicated interface files

- Use I prefix for interfaces

- Place interfaces close to their implementations

- For service interfaces, define in Common/Interfaces folder for
  > cross-service usage

### Classes

- One public class per file

- Use descriptive, specific names

- Keep classes focused on a single responsibility

- Prefer composition over inheritance

## Naming Conventions

### General

- Use PascalCase for classes, methods, properties, and constants

- Use camelCase for local variables and parameters

- Use descriptive names that convey intent

- Avoid abbreviations unless universally understood

### Methods

- Use verbs for method names: GetUser, CreateOrder, ProcessPayment

- Async methods should end with Async suffix

- Boolean methods should use Is, Has, Can: IsValid, HasPermission

### Properties

- Use nouns or noun phrases

- Boolean properties: IsEnabled, HasChildren, CanExecute

### Constants

- Use PascalCase for public constants

- Use UPPER_CASE only if following external conventions (e.g.,
  > environment variables)

## Coding Practices

### Dependency Injection

- Register services in Program.cs or extension methods

- Use constructor injection for required dependencies

- Prefer IServiceProvider only when absolutely necessary

- Register services with appropriate lifetime (Singleton, Scoped,
  > Transient)

### Error Handling

- Use exceptions for exceptional cases

- Create custom exceptions for domain-specific errors

- Log errors with appropriate context

- Return meaningful error messages to clients

## Error Handling and Logging

Every feature must have proper error handling and structured logging.

### Error Handling Principles

- **Never ignore or hide errors**
  - Catch exceptions only when you can handle them
  - If you cannot recover, log the error with full context and pass it to the global error handler

- **Global Error Handler**
  - Each backend must have a global error handler that logs the exception and returns a JSON error response with the correct HTTP status code
  - Do not expose stack traces to users in production
  - Return structured error responses: `{"error": "message", "code": "ERROR_CODE"}`

- **Exception Handling Best Practices**
  - Use specific exception types for different error scenarios
  - Include relevant context in exception messages
  - Log at the appropriate level (Warning for expected errors, Error for unexpected)
  - Return appropriate HTTP status codes (400 Bad Request, 401 Unauthorized, 404 Not Found, 500 Internal Server Error)

### Structured Logging

- **Use structured logging with clear fields**:
  - Operation name (e.g., "UserLogin", "AvatarUpload", "ProfileUpdate")
  - Timestamp (automatic with most logging frameworks)
  - User ID (when applicable)
  - Entity ID (e.g., business ID, booking ID)
  - Important parameters (file size, request type, etc.)
  
- **Never log sensitive data**:
  - Passwords, tokens, API keys
  - Credit card numbers, personal identification numbers
  - Full user details unless necessary

- **Log major events at appropriate levels**:
  - **Debug**: Detailed diagnostic information for troubleshooting
  - **Info**: Normal application flow (login, profile updates, avatar uploads, bookings)
  - **Warning**: Validation failures, expected errors, recoverable issues
  - **Error**: Unexpected errors, exceptions, failed operations
  - **Critical**: System failures, data corruption, security breaches

### Events to Log

Log the following major events at **Info** level:
- User registration and login
- Profile updates (name, phone, location changes)
- Avatar uploads (start and completion)
- Business listings created or updated
- Bookings and reservations
- Payment transactions
- Data exports or imports

Log the following at **Warning** level:
- Validation failures (invalid email, weak password, file too large)
- Rate limiting triggers
- Deprecated API usage
- Authentication failures (wrong password)

Log the following at **Error** level:
- Unhandled exceptions
- Database connection failures
- Third-party API failures
- File system errors
- Data integrity issues

### Logging Infrastructure

- **All services must write logs to a file or central logging system**
  - Use consistent log format across all services
  - Rotate log files to prevent disk space issues
  - Consider using centralized logging (ELK stack, CloudWatch, Application Insights)

- **Use consistent keywords for easy searching**:
  - Tag logs with operation names: "[UserLogin]", "[AvatarUpload]", "[ProfileUpdate]"
  - Use structured fields that can be queried
  - Include correlation IDs for request tracking

### Avatar Upload Logging and Error Handling

When a user uploads a profile picture, follow these specific logging and error handling guidelines:

#### Upload Start
- Log at **Info** level when upload begins:
  ```
  Logger.Info("Avatar upload started", new {
      Operation = "AvatarUpload",
      UserId = userId,
      FileName = file.FileName,
      FileSize = file.Length,
      FileType = file.ContentType,
      Tags = new[] { "avatar", "upload" }
  });
  ```

#### Validation Steps
- Log all validation checks:
  - File type validation (JPG, PNG only)
  - File size validation (< 1MB)
  - File content validation (actual image data)
  
- If validation fails, log at **Warning** level and return 400 response:
  ```
  Logger.Warning("Avatar upload validation failed", new {
      Operation = "AvatarUpload",
      UserId = userId,
      FileName = file.FileName,
      Reason = "File size exceeds 1MB limit",
      FileSize = file.Length,
      Tags = new[] { "avatar", "upload", "validation_error" }
  });
  return BadRequest(new { error = "File size exceeds 1MB limit" });
  ```

#### File Save Success
- After saving the image, log the saved file path or storage key at **Info** level:
  ```
  Logger.Info("Avatar file saved successfully", new {
      Operation = "AvatarUpload",
      UserId = userId,
      FilePath = savedFilePath,
      FileSize = file.Length,
      Tags = new[] { "avatar", "upload" }
  });
  ```

#### Database Update
- When user profile is updated with new picture path/URL, log at **Info** level:
  ```
  Logger.Info("User profile updated with new avatar", new {
      Operation = "ProfileUpdate",
      UserId = userId,
      Field = "ProfilePicture",
      NewValue = avatarUrl,
      Tags = new[] { "avatar", "profile" }
  });
  ```

#### Error Handling
- If an error occurs at any step, log at **Error** level with full context:
  ```
  Logger.Error("Avatar upload failed", exception, new {
      Operation = "AvatarUpload",
      UserId = userId,
      FileName = file.FileName,
      Step = "FileSave",
      ErrorMessage = exception.Message,
      StackTrace = exception.StackTrace,
      Tags = new[] { "avatar", "upload", "error" }
  });
  return StatusCode(500, new { 
      error = "Avatar upload failed", 
      code = "AVATAR_UPLOAD_ERROR" 
  });
  ```

#### Required Tags
Include these three tags in all avatar-related logs for easy searching:
1. **"avatar"** - Identifies avatar-related operations
2. **"upload"** - Identifies upload operations (or "delete" for removal)
3. **"error"** - Identifies error scenarios (only when errors occur)

### Logging Examples

**Successful user login**:
```csharp
Logger.Info("User logged in successfully", new {
    Operation = "UserLogin",
    UserId = user.Id,
    Email = user.Email,
    LoginMethod = "Password",
    IpAddress = request.IpAddress
});
```

**Validation failure**:
```csharp
Logger.Warning("Profile update validation failed", new {
    Operation = "ProfileUpdate",
    UserId = userId,
    Field = "Phone",
    Reason = "Invalid phone number format",
    ProvidedValue = phoneNumber
});
```

**Unexpected error**:
```csharp
Logger.Error("Database query failed", exception, new {
    Operation = "GetUserProfile",
    UserId = userId,
    Query = "SELECT * FROM users WHERE id = @userId",
    ErrorMessage = exception.Message,
    StackTrace = exception.StackTrace
});
```

### Asynchronous Code

- Use async/await for I/O-bound operations

- Suffix async methods with Async

- Avoid async void except for event handlers

- Use ConfigureAwait(false) in library code

### LINQ & Collections {#linq-collections}

- Prefer LINQ for data transformations

- Use appropriate collection types (List, HashSet, Dictionary)

- Avoid multiple enumeration of IEnumerable

- Use ToList() or ToArray() if multiple iterations needed

### Resource Management

- Implement IDisposable for unmanaged resources

- Use using statements for disposable objects

- Prefer using declarations (C# 8+) for cleaner code

## Data Access

### Entity Framework / Dapper {#entity-framework-dapper}

- Use repositories to abstract data access

- Implement Unit of Work pattern for transactions

- Use async methods for database operations

- Keep database context lifetime scoped

### Database Migrations

- Use EF Core migrations for schema changes

- Name migrations descriptively: 20231115_AddUserEmailIndex

- Test migrations in development before production

- Use separate migration contexts if needed

## API Design

### Controllers

- Keep controllers thin - delegate to services

- Use appropriate HTTP verbs (GET, POST, PUT, DELETE, PATCH)

- Return appropriate status codes

- Use DTOs for request/response objects

### Endpoints

- Use RESTful conventions when applicable

- Version APIs when breaking changes occur

- Document endpoints with XML comments or Swagger

### Validation

- Validate inputs at the API boundary

- Use data annotations or FluentValidation

- Return clear validation error messages

## Configuration

### appsettings.json {#appsettings.json}

- Use structured configuration

- Separate concerns: Database, Logging, Features

- Use environment-specific files: appsettings.Development.json

- Never commit secrets - use user secrets or key vaults

### Feature Flags

- Use feature flags for gradual rollouts

- Implement flags as injectable services

- Document default states

- Exclude feature flag classes from code coverage

## Testing

### Unit Tests

- Use NUnit, xUnit, or MSTest consistently

- One test class per production class

- Name tests: MethodName_Scenario_ExpectedBehavior

- Use AAA pattern: Arrange, Act, Assert

- Mock external dependencies

- Test both happy paths and error cases

### Integration Tests

- Test end-to-end flows

- Use test databases or in-memory providers

- Clean up test data after execution

- Use descriptive test names

### Test Organization

- Mirror production code structure in test projects

- Group related tests using nested classes or folders

- Use test helpers and builders for complex setups

## Documentation

### XML Comments

- Document public APIs, interfaces, and complex methods

- Use \<summary\>, \<param\>, \<returns\>, \<exception\>

- Keep comments concise and up-to-date

- Avoid obvious comments

### README Files

- Include README in each major service folder

- Document setup, configuration, and dependencies

- Provide examples for common use cases

## Performance

- Use Span\<T\> and Memory\<T\> for high-performance scenarios

- Avoid allocations in hot paths

- Use pooling for frequently created objects

- Profile before optimizing

- Benchmark critical paths

## Security

- Validate and sanitize all inputs

- Use parameterized queries to prevent SQL injection

- Implement proper authentication and authorization

- Never log sensitive data (passwords, tokens)

- Use HTTPS for all communications

## Code Attributes

### Common Attributes

- \[ExcludeFromCodeCoverage\] - for auto-generated code, DTOs,
  > Program.cs

- \[Obsolete\] - mark deprecated code with migration guidance

- \[Required\], \[Range\] - for validation

### Custom Attributes

- Create custom attributes for cross-cutting concerns

- Use attributes for authorization:
  > \[AuthorizeAction(Actions.ViewResources)\]

## Code Style

- Use .editorconfig for consistent formatting

- Follow team\'s ReSharper or Rider settings

- Keep methods short and focused (\< 30 lines ideally)

- Limit constructor parameters (\< 5 parameters)

- Avoid deep nesting (\< 4 levels)

## Best Practices Summary

1.  **Single Responsibility**: Each class/method should do one thing
    > well

2.  **DRY**: Don\'t Repeat Yourself - extract common code

3.  **KISS**: Keep It Simple, Stupid - avoid over-engineering

4.  **YAGNI**: You Aren\'t Gonna Need It - don\'t add unnecessary
    > features

5.  **Composition over Inheritance**: Favor composition for flexibility

6.  **Dependency Inversion**: Depend on abstractions, not concretions

7.  **Interface Segregation**: Keep interfaces focused and minimal

8.  **Open/Closed**: Open for extension, closed for modification
