# Project Structure Guidelines

## Overall Organization

### Monorepo vs Multi-Repo

- Use monorepo for tightly coupled services that share code
- Keep all related services in a single repository for easier coordination
- Use clear folder boundaries between different parts of the system

### Top-Level Structure

project-root/

+-- Backend/ # All backend services

+-- Frontend/ # All frontend applications

+-- Shared/ # Shared libraries and utilities

+-- Tests/ # Cross-cutting test utilities

+-- Deployment/ # Infrastructure and deployment configs

+-- docs/ # Documentation

+-- .github/ # CI/CD workflows

+-- README.md

+-- .gitignore

+-- .editorconfig

+-- global.json / package.json

## Backend Structure

### Service Organization

Each service should follow this pattern:

Backend/

+-- ServiceName/

+-- ServiceName/ # Main service project (Web API)

¦ +-- Program.cs

¦ +-- appsettings.json

¦ +-- Controllers/

¦ +-- Infrastructure/

¦ +-- ServiceName.csproj

¦

+-- ServiceName.Logic/ # Business logic

¦ +-- Features/ # Organize by feature

¦ ¦ +-- Users/

¦ ¦ ¦ +-- UserService.cs

¦ ¦ ¦ +-- UserValidator.cs

¦ ¦ ¦ +-- UserMapper.cs

¦ ¦ +-- Orders/

¦ +-- Interfaces/

¦ +-- ServiceName.Logic.csproj

¦

+-- ServiceName.Data/ # Data access layer

¦ +-- Contexts/

¦ +-- Repositories/

¦ +-- Entities/

¦ +-- Migrations/

¦ +-- ServiceName.Data.csproj

¦

+-- ServiceName.Common/ # Shared DTOs, interfaces

¦ +-- Dtos/

¦ +-- Interfaces/

¦ +-- Events/

¦ +-- ServiceName.Common.csproj

¦

+-- ServiceName.UnitTests/ # Unit tests

¦ +-- Features/ # Mirror production structure

¦ +-- ServiceName.UnitTests.csproj

¦

+-- ServiceName.IntegrationTests/ # Integration tests

+-- ServiceName.IntegrationTests.csproj

### Shared Backend Code

Backend/Shared/

+-- Core.Common/ # Common utilities, constants

+-- Core.Logic/ # Shared business logic

+-- Core.Data/ # Shared data access patterns

+-- Core.Service/ # Service infrastructure

+-- Core.Events/ # Event bus and messaging

+-- Core.Logging/ # Logging infrastructure

+-- Core.Testing/ # Test utilities

## Frontend Structure

### Application Organization

Frontend/

+-- AppName/

+-- src/

¦ +-- app/

¦ ¦ +-- core/ # Singleton services, guards

¦ ¦ ¦ +-- api-services/

¦ ¦ ¦ +-- guards/

¦ ¦ ¦ +-- interceptors/

¦ ¦ ¦ +-- services/

¦ ¦ ¦

¦ ¦ +-- shared/ # Reusable components, pipes, directives

¦ ¦ ¦ +-- components/

¦ ¦ ¦ +-- directives/

¦ ¦ ¦ +-- pipes/

¦ ¦ ¦ +-- layouts/

¦ ¦ ¦ +-- models/

¦ ¦ ¦

¦ ¦ +-- features/ # Feature modules

¦ ¦ ¦ +-- dashboard/

¦ ¦ ¦ ¦ +-- components/

¦ ¦ ¦ ¦ +-- services/

¦ ¦ ¦ ¦ +-- dashboard.routes.ts

¦ ¦ ¦ +-- users/

¦ ¦ ¦ +-- orders/

¦ ¦ ¦

¦ ¦ +-- store/ # ngrx store (if global)

¦ ¦ ¦ +-- actions/

¦ ¦ ¦ +-- effects/

¦ ¦ ¦ +-- reducers/

¦ ¦ ¦ +-- selectors/

¦ ¦ ¦

¦ ¦ +-- store-modules/ # Feature-specific stores

¦ ¦ +-- users-store/

¦ ¦ +-- orders-store/

¦ ¦

¦ +-- assets/ # Static assets

¦ +-- environments/ # Environment configs

¦ +-- styles/ # Global styles

¦

+-- angular.json

+-- tsconfig.json

+-- package.json

+-- README.md

### Feature Module Pattern

Each feature should be self-contained:

features/feature-name/

+-- components/

¦ +-- feature-list/

¦ ¦ +-- feature-list.component.ts

¦ ¦ +-- feature-list.component.html

¦ ¦ +-- feature-list.component.scss

¦ ¦ +-- feature-list.component.spec.ts

¦ +-- feature-detail/

+-- services/

¦ +-- feature.service.ts

+-- models/

¦ +-- feature.model.ts

+-- store/ # Feature-specific store (optional)

¦ +-- feature.actions.ts

¦ +-- feature.reducer.ts

¦ +-- feature.effects.ts

¦ +-- feature.selectors.ts

+-- feature.routes.ts

## Deployment Structure

Deployment/

+-- charts/ # Helm charts for Kubernetes

¦ +-- service-name/

¦ +-- Chart.yaml

¦ +-- values.yaml

¦ +-- templates/

¦

+-- scripts/ # Deployment scripts

¦ +-- deploy.sh

¦ +-- rollback.sh

¦

+-- docker/ # Docker configurations

+-- Dockerfile

## Documentation Structure

docs/

+-- architecture/ # Architecture decisions

¦ +-- adr-001-use-microservices.md

¦ +-- system-overview.md

¦

+-- api/ # API documentation

¦ +-- service-endpoints.md

¦

+-- dev-instructions/ # Development guides

¦ +-- setup.md

¦ +-- debugging.md

¦ +-- testing.md

¦

+-- deployment/ # Deployment guides

+-- kubernetes-setup.md

## Configuration Files

### Root Level

- README.md - Project overview and getting started
- .gitignore - Git ignore patterns
- .editorconfig - Editor configuration
- global.json - .NET SDK version
- Directory.Packages.props - Centralized NuGet package versions
- docker-compose.yml - Local development environment

### CI/CD

.github/

+-- workflows/

¦ +-- backend-build.yml

¦ +-- frontend-build.yml

¦ +-- deploy-dev.yml

¦ +-- deploy-prod.yml

¦

+-- CODEOWNERS # Code ownership

+-- pull_request_template.md

## Test Structure

### Mirror Production Structure

Test files should mirror the structure of production code:

Production:

ServiceName.Logic/Features/Users/UserService.cs

Tests:

ServiceName.UnitTests/Features/Users/UserServiceTests.cs

### Test Organization

- Unit tests in \*.UnitTests project
- Integration tests in \*.IntegrationTests project
- End-to-end tests in separate Tests/E2E folder
- Shared test utilities in TestsCommon or TestHelpers folder

## Shared Code Guidelines

### When to Share Code

- **Do**: Share DTOs, interfaces, constants, utilities
- **Do**: Share validation logic and business rules
- **Do**: Share common infrastructure (logging, caching)
- **Don't**: Share database entities across services
- **Don't**: Create tight coupling between services through shared logic

### Shared Project Structure

Shared/

+-- Common/

¦ +-- Constants/

¦ +-- Extensions/

¦ +-- Utilities/

¦

+-- Contracts/ # DTOs and interfaces

¦ +-- Requests/

¦ +-- Responses/

¦ +-- Events/

¦

+-- Infrastructure/

+-- Logging/

+-- Caching/

+-- Messaging/

## Naming Conventions

### Projects

- Use descriptive names: CompanyName.ServiceName.Layer
- Examples:
  - Ats.UserManagement.Service
  - Ats.UserManagement.Logic
  - Ats.UserManagement.Data

### Folders

- Use PascalCase for folder names
- Use plural for collections: Controllers, Services, Models
- Use singular for single-purpose folders: Infrastructure, Configuration

### Files

- Match file name to main type inside
- Include type suffix: UserService.cs, UserDto.cs
- Test files: UserServiceTests.cs or UserService.spec.ts

## Architectural Boundaries

### Enforce Dependencies

Use automated checks to prevent:

- Services depending on each other directly (use APIs)
- Test projects referenced by production code
- Circular dependencies between projects
- Data layer depending on service layer

### Example Validation

&lt;!-- Directory.Packages.props --&gt;

&lt;Target Name="ValidateEmulatorReferences" BeforeTargets="CoreCompile"&gt;

<Error Condition="..."

Text="ARCHITECTURAL BOUNDARY VIOLATION:

Services should not reference emulator projects"/>

&lt;/Target&gt;

## Scalability Considerations

### Microservices

- Each service should be independently deployable
- Share code through packages, not project references
- Use event-driven communication between services
- Maintain database per service pattern

### Modular Monolith

- Organize by feature/domain
- Use clear namespace boundaries
- Prepare for future extraction to microservices
- Keep data access layer isolated

## Best Practices

- **Consistency**: Follow the same structure across all services
- **Isolation**: Keep services loosely coupled
- **Discoverability**: Make it easy to find code by following conventions
- **Testability**: Structure code to make testing straightforward
- **Documentation**: Include README files in major folders
- **Automation**: Use scripts to generate new services/features with correct structure
- **Clear Boundaries**: Use namespaces and projects to enforce architectural boundaries
- **Single Responsibility**: Each project should have one clear purpose