# Testing Practices

## Test Philosophy

- Tests are first-class citizens - treat them with the same care as production code
- Write tests to verify behavior, not implementation
- Tests should be readable, maintainable, and fast
- Aim for high coverage, but focus on critical paths and edge cases

## Test Types

### Unit Tests

**Purpose**: Test individual components in isolation

**Characteristics**:

- Fast execution (milliseconds)
- No external dependencies (database, network, file system)
- Use mocks/stubs for dependencies
- Focus on single responsibility

**When to Write**:

- Business logic and algorithms
- Data transformations
- Validation logic
- Pure functions

### Integration Tests

**Purpose**: Test how components work together

**Characteristics**:

- Slower than unit tests (seconds)
- May use real dependencies (in-memory database, test containers)
- Test end-to-end flows within a service
- Verify component interactions

**When to Write**:

- Database operations
- API endpoints
- Message handling
- External service integration

### End-to-End Tests

**Purpose**: Test complete user workflows

**Characteristics**:

- Slowest tests (minutes)
- Use real or staging environments
- Test through UI or API
- Verify system behavior

**When to Write**:

- Critical user journeys
- Multi-service interactions
- Production-like scenarios

## Test Structure

### AAA Pattern

Organize tests using Arrange-Act-Assert:

\[Test\]

public void CalculateTotal_WithDiscount_ReturnsDiscountedPrice()

{

// Arrange

var cart = new ShoppingCart();

cart.AddItem(new Item { Price = 100 });

var discount = new Discount { Percentage = 10 };

// Act

var total = cart.CalculateTotal(discount);

// Assert

Assert.That(total, Is.EqualTo(90));

}

**Do NOT add Arrange/Act/Assert comments** unless the test is particularly complex.

### Test Naming

#### Backend (C#)

Pattern: MethodName_Scenario_ExpectedBehavior

Examples:

ProcessOrder_WithValidData_ReturnsSuccess()

ValidateUser_WithExpiredToken_ThrowsUnauthorizedException()

GetUsers_WhenDatabaseEmpty_ReturnsEmptyList()

#### Frontend (TypeScript)

Pattern: should \[expected behavior\] when \[scenario\]

Examples:

it('should load users when component initializes', () => { });

it('should display error message when login fails', () => { });

it('should disable submit button when form is invalid', () => { });

### Test Organization

#### Mirror Production Structure

Production:

ServiceName/Features/Users/UserService.cs

Tests:

ServiceName.UnitTests/Features/Users/UserServiceTests.cs

#### Group Related Tests

\[TestFixture\]

public class UserServiceTests

{

\[TestFixture\]

public class CreateUser

{

\[Test\]

public void WithValidData_ReturnsSuccess() { }

\[Test\]

public void WithDuplicateEmail_ThrowsException() { }

}

\[TestFixture\]

public class UpdateUser

{

\[Test\]

public void WithValidData_UpdatesSuccessfully() { }

}

}

## Backend Testing (C# / .NET)

### Framework

- Use **NUnit**, **xUnit**, or **MSTest** (choose one per project)
- Use **Moq** or **NSubstitute** for mocking
- Use **FluentAssertions** for readable assertions (optional)

### Unit Test Example

\[TestFixture\]

public class DataProcessorTests

{

private Mock&lt;IFeatureFlag&gt; \_mockFeatureFlag;

private DataProcessor \_sut; // System Under Test

\[SetUp\]

public void Setup()

{

\_mockFeatureFlag = new Mock&lt;IFeatureFlag&gt;();

\_sut = new DataProcessor(\_mockFeatureFlag.Object);

}

\[Test\]

\[Parallelizable\]

public void Process_WhenFeatureDisabled_ReturnsOriginalData()

{

// Arrange

\_mockFeatureFlag.Setup(x => x.Enabled).Returns(false);

var data = new List&lt;DataPoint&gt; { new() { X = 1, Y = 1 } };

// Act

var result = \_sut.Process(data);

// Assert

Assert.That(result, Is.SameAs(data));

}

}

### Integration Test Example

\[TestFixture\]

public class UserRepositoryTests

{

private DbContextOptions&lt;AppDbContext&gt; \_options;

private AppDbContext \_context;

\[SetUp\]

public void Setup()

{

\_options = new DbContextOptionsBuilder&lt;AppDbContext&gt;()

.UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())

.Options;

\_context = new AppDbContext(\_options);

}

\[TearDown\]

public void TearDown()

{

\_context.Dispose();

}

\[Test\]

public async Task GetByIdAsync_ExistingUser_ReturnsUser()

{

// Arrange

var user = new User { Id = Guid.NewGuid(), Name = "Test" };

\_context.Users.Add(user);

await \_context.SaveChangesAsync();

var repository = new UserRepository(\_context);

// Act

var result = await repository.GetByIdAsync(user.Id);

// Assert

Assert.That(result.Name, Is.EqualTo("Test"));

}

}

### Test Attributes

\[Test\] // Marks a test method

\[TestCase(1, 2, 3)\] // Parameterized test

\[Parallelizable\] // Can run in parallel

\[Category("Integration")\]// Categorize tests

\[Ignore("WIP")\] // Temporarily skip

\[Timeout(1000)\] // Timeout in milliseconds

## Frontend Testing (TypeScript / Angular)

### Framework

- Use **Jasmine** for testing framework
- Use **Karma** for test runner
- Use **Spectator** for simplified component testing (optional)
- Use **jasmine-marbles** for testing observables

### Component Test Example

describe('UserListComponent', () => {

let spectator: Spectator&lt;UserListComponent&gt;;

let mockStore: MockStore;

const createComponent = createComponentFactory({

component: UserListComponent,

providers: \[provideMockStore({ initialState })\],

imports: \[CommonModule\]

});

beforeEach(() => {

spectator = createComponent();

mockStore = spectator.inject(MockStore);

});

it('should load users on init', () => {

const users = \[{ id: 1, name: 'John' }\];

mockStore.overrideSelector(selectUsers, users);

spectator.detectChanges();

expect(spectator.queryAll('.user-item')).toHaveLength(1);

});

});

### Service Test Example

describe('UserService', () => {

let service: UserService;

let httpMock: HttpTestingController;

beforeEach(() => {

TestBed.configureTestingModule({

imports: \[HttpClientTestingModule\],

providers: \[UserService\]

});

service = TestBed.inject(UserService);

httpMock = TestBed.inject(HttpTestingController);

});

afterEach(() => {

httpMock.verify();

});

it('should fetch users', () => {

const mockUsers = \[{ id: 1, name: 'John' }\];

service.getUsers().subscribe(users => {

expect(users).toEqual(mockUsers);

});

const req = httpMock.expectOne('/api/users');

expect(req.request.method).toBe('GET');

req.flush(mockUsers);

});

});

### Observable Testing

it('should emit filtered users', () => {

const users = \[

{ id: 1, name: 'John' },

{ id: 2, name: 'Jane' }

\];

const filter = 'John';

const result\$ = service.filterUsers(users, filter);

const expected = cold('(a|)', { a: \[users\[0\]\] });

expect(result\$).toBeObservable(expected);

});

### Test Data Best Practices

#### Always Create Shallow Copies

// Good - creates a copy

const testUser = { ...mockUserData };

// Bad - mutates original

const testUser = mockUserData;

#### Use Test Helpers

// test-helpers/user-helper.ts

export class UserTestHelper {

static createUser(overrides?: Partial&lt;User&gt;): User {

return {

id: 1,

name: 'Test User',

email: '<test@example.com>',

...overrides

};

}

static createUsers(count: number): User\[\] {

return Array.from({ length: count }, (\_, i) =>

this.createUser({ id: i + 1 })

);

}

}

## Running Tests

### Backend

\# Run all tests

dotnet test

\# Run specific test file

dotnet test --filter FullyQualifiedName~UserServiceTests

\# Run with coverage

dotnet test /p:CollectCoverage=true

\# Run in parallel

dotnet test --parallel

### Frontend

\# Run all tests (one-time)

yarn test-silent

\# Run tests in watch mode

yarn test-watch

\# Run single file (use fdescribe in code, remove before commit)

yarn test-watch

\# Run with coverage

yarn test

\# Run linter

yarn lint-silent

## Mocking

### Backend Mocking

// Setup mock behavior

\_mockRepository

.Setup(x => x.GetByIdAsync(It.IsAny&lt;Guid&gt;()))

.ReturnsAsync(new User { Name = "Test" });

// Verify method was called

\_mockRepository.Verify(

x => x.SaveAsync(It.IsAny&lt;User&gt;()),

Times.Once

);

// Setup property

\_mockService.Setup(x => x.IsEnabled).Returns(true);

### Frontend Mocking

// Mock service

const mockUserService = jasmine.createSpyObj('UserService', \['getUsers'\]);

mockUserService.getUsers.and.returnValue(of(\[...\]));

// Mock store

const mockStore = provideMockStore({ initialState });

// Override selector

mockStore.overrideSelector(selectUsers, mockUsers);

## Test Coverage

### Coverage Goals

- **Critical paths**: 100% coverage
- **Business logic**: 80-90% coverage
- **Overall project**: 70-80% coverage
- **UI components**: 60-70% coverage

### Exclude from Coverage

Use \[ExcludeFromCodeCoverage\] for:

- Auto-generated code (migrations, scaffolding)
- DTOs with no logic
- Program.cs / Startup.cs
- Feature flags (simple boolean wrappers)
- Infrastructure plumbing

### Coverage Configuration

&lt;!-- CodeCoverage.runsettings --&gt;

&lt;ModulePaths&gt;

&lt;Include&gt;

&lt;ModulePath&gt;.\*\\.dll&lt;/ModulePath&gt;

&lt;/Include&gt;

&lt;Exclude&gt;

&lt;ModulePath&gt;.\*Tests\\.dll&lt;/ModulePath&gt;

&lt;ModulePath&gt;.\*TestAdapter\\.dll&lt;/ModulePath&gt;

&lt;/Exclude&gt;

&lt;/ModulePaths&gt;

## Test Data Management

### Builders Pattern

public class UserBuilder

{

private User \_user = new User

{

Id = Guid.NewGuid(),

Name = "Test User"

};

public UserBuilder WithName(string name)

{

\_user.Name = name;

return this;

}

public UserBuilder WithEmail(string email)

{

\_user.Email = email;

return this;

}

public User Build() => \_user;

}

// Usage

var user = new UserBuilder()

.WithName("John")

.WithEmail("<john@example.com>")

.Build();

### Fixture Files

Store complex test data in files:

Tests/Fixtures/

+-- users.json

+-- orders.json

+-- paths.json

var json = await File.ReadAllTextAsync("Fixtures/users.json");

var users = JsonSerializer.Deserialize&lt;User\[\]&gt;(json);

## Performance Testing

### Backend

\[Test\]

\[Performance\]

public void ProcessLargeDataset_CompletesInReasonableTime()

{

var stopwatch = Stopwatch.StartNew();

\_service.ProcessData(largeDataset);

stopwatch.Stop();

Assert.That(stopwatch.ElapsedMilliseconds, Is.LessThan(1000));

}

### Frontend

Use Cypress or similar for performance testing:

cy.visit('/dashboard');

cy.window().then(win => {

const performance = win.performance;

const loadTime = performance.timing.loadEventEnd -

performance.timing.navigationStart;

expect(loadTime).to.be.lessThan(3000);

});

## Common Pitfalls

### Don't Test Implementation Details

// Bad - tests implementation

Assert.That(\_service.InternalCache, Has.Count.EqualTo(1));

// Good - tests behavior

var result = \_service.GetUser(userId);

Assert.That(result.Name, Is.EqualTo("John"));

### Don't Share State Between Tests

// Bad - shared mutable state

private static User \_sharedUser = new User();

// Good - fresh state per test

\[SetUp\]

public void Setup()

{

\_user = new User();

}

### Don't Make Tests Dependent

// Bad - Test2 depends on Test1

\[Test\]

public void Test1_CreateUser() { /\* creates user \*/ }

\[Test\]

public void Test2_UpdateUser() { /\* assumes user exists \*/ }

// Good - each test is independent

\[Test\]

public void UpdateUser_ExistingUser_UpdatesSuccessfully()

{

// Arrange: create user in this test

var user = CreateTestUser();

// ...

}

## Best Practices Summary

- **Fast**: Unit tests should run in milliseconds
- **Isolated**: Tests should not depend on each other
- **Repeatable**: Same results every time
- **Self-Validating**: Pass/fail, no manual inspection
- **Timely**: Write tests alongside production code
- **Readable**: Tests are documentation
- **Maintainable**: Easy to update when requirements change
- **Focused**: One assertion concept per test
- **Realistic**: Use realistic test data
- **Automated**: Run automatically in CI/CD pipeline