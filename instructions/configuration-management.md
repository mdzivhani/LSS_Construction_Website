# Configuration Management

## Overview

Configuration management ensures that applications can run in different environments without code changes. Follow these guidelines to manage settings effectively and securely.

## Principles

- **Separation**: Keep configuration separate from code
- **Environment-Specific**: Different values for dev/test/prod
- **Security**: Never commit secrets to source control
- **Hierarchy**: Layer configurations from general to specific
- **Type Safety**: Use strongly-typed configuration classes
- **Validation**: Validate configuration at startup

## CRITICAL SECURITY RULES

### ⚠️ NEVER DO THESE:

1. **DO NOT hard-code sensitive values** (passwords, API keys, connection strings, secrets) in any code file
2. **DO NOT commit .env files** with actual values to git (only .env.example with placeholders)
3. **DO NOT commit appsettings files** with production credentials
4. **DO NOT add sensitive values in plain text** anywhere in the codebase
5. **DO NOT push environment-specific files** with real credentials to repositories

### ✅ ALWAYS DO THESE:

1. **ALWAYS use environment variables** for sensitive configuration
2. **ALWAYS use placeholders** in example/template files (e.g., `YOUR_DATABASE_PASSWORD_HERE`)
3. **ALWAYS validate** that .gitignore excludes all sensitive files before committing
4. **ALWAYS use secrets management** systems for production (Azure Key Vault, AWS Secrets Manager, etc.)
5. **ALWAYS document** what environment variables are needed without exposing their actual values

## Backend Configuration (.NET)

### Configuration Files

#### appsettings.json (Base Configuration)

{

"Logging": {

"LogLevel": {

"Default": "Information",

"Microsoft": "Warning"

}

},

"ConnectionStrings": {

"DefaultConnection": "Server=(localdb)\\\\mssqllocaldb;Database=MyApp;Trusted_Connection=True;"

},

"AppSettings": {

"ApplicationName": "MyService",

"MaxRetryAttempts": 3,

"TimeoutSeconds": 30

},

"FeatureFlags": {

"EnableNewFeature": false

}

}

#### appsettings.Development.json

{

"Logging": {

"LogLevel": {

"Default": "Debug"

}

},

"ConnectionStrings": {

"DefaultConnection": "Server=localhost;Database=MyApp_Dev;..."

}

}

#### appsettings.Production.json

{

"Logging": {

"LogLevel": {

"Default": "Warning"

}

}

}

### Strongly-Typed Configuration

#### Define Configuration Classes

public class AppSettings

{

public string ApplicationName { get; set; } = string.Empty;

public int MaxRetryAttempts { get; set; }

public int TimeoutSeconds { get; set; }

}

public class FeatureFlags

{

public bool EnableNewFeature { get; set; }

}

#### Register in Program.cs

var builder = WebApplication.CreateBuilder(args);

// Bind configuration

var appSettings = new AppSettings();

builder.Configuration.GetSection("AppSettings").Bind(appSettings);

builder.Services.AddSingleton(appSettings);

// Or use Options pattern

builder.Services.Configure&lt;AppSettings&gt;(

builder.Configuration.GetSection("AppSettings"));

#### Inject and Use

public class MyService

{

private readonly AppSettings \_settings;

public MyService(AppSettings settings)

{

\_settings = settings;

}

public void DoWork()

{

var timeout = TimeSpan.FromSeconds(\_settings.TimeoutSeconds);

// Use configuration

}

}

### Configuration Sources

#### Hierarchy (Lowest to Highest Priority)

- appsettings.json
- appsettings.{Environment}.json
- User Secrets (development only)
- Environment Variables
- Command Line Arguments
- Azure Key Vault / Cloud Secrets (production)

#### Loading Configuration

var builder = WebApplication.CreateBuilder(args);

builder.Configuration

.AddJsonFile("appsettings.json", optional: false)

.AddJsonFile(\$"appsettings.{builder.Environment.EnvironmentName}.json", optional: true)

.AddEnvironmentVariables()

.AddCommandLine(args);

// Add User Secrets in Development

if (builder.Environment.IsDevelopment())

{

builder.Configuration.AddUserSecrets&lt;Program&gt;();

}

// Add Azure Key Vault in Production

if (builder.Environment.IsProduction())

{

var keyVaultUrl = builder.Configuration\["KeyVaultUrl"\];

builder.Configuration.AddAzureKeyVault(new Uri(keyVaultUrl), new DefaultAzureCredential());

}

### Environment Variables

#### Naming Convention

Use double underscore \__ to represent nested configuration:

\# appsettings.json structure:

\# ConnectionStrings:DefaultConnection

export ConnectionStrings_\_DefaultConnection="Server=..."

\# AppSettings:MaxRetryAttempts

export AppSettings_\_MaxRetryAttempts=5

\# Logging:LogLevel:Default

export Logging_\_LogLevel_\_Default="Information"

#### Docker / Kubernetes

\# kubernetes deployment

env:

\- name: ConnectionStrings_\_DefaultConnection

valueFrom:

secretKeyRef:

name: database-secret

key: connection-string

\- name: AppSettings_\_MaxRetryAttempts

value: "3"

### Secrets Management

#### User Secrets (Development Only)

\# Initialize user secrets

dotnet user-secrets init

\# Set a secret

dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=..."

\# List secrets

dotnet user-secrets list

\# Remove secret

dotnet user-secrets remove "ConnectionStrings:DefaultConnection"

In code:

// User secrets are automatically loaded in Development

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

#### Azure Key Vault (Production)

builder.Configuration.AddAzureKeyVault(

new Uri("<https://myvault.vault.azure.net/>"),

new DefaultAzureCredential()

);

#### Never Commit Secrets

\# .gitignore

appsettings.\*.json

!appsettings.json

!appsettings.Development.json

\*.user

secrets.json

.env

### Configuration Validation

#### Validate on Startup

public class AppSettings

{

public string ApplicationName { get; set; } = string.Empty;

\[Range(1, 10)\]

public int MaxRetryAttempts { get; set; }

\[Range(1, 300)\]

public int TimeoutSeconds { get; set; }

public void Validate()

{

if (string.IsNullOrWhiteSpace(ApplicationName))

throw new InvalidOperationException("ApplicationName is required");

if (MaxRetryAttempts &lt; 1 || MaxRetryAttempts &gt; 10)

throw new InvalidOperationException("MaxRetryAttempts must be between 1 and 10");

}

}

// In Program.cs

var appSettings = new AppSettings();

builder.Configuration.GetSection("AppSettings").Bind(appSettings);

appSettings.Validate(); // Fail fast if config is invalid

builder.Services.AddSingleton(appSettings);

#### Use Options Pattern with Validation

builder.Services.AddOptions&lt;AppSettings&gt;()

.Bind(builder.Configuration.GetSection("AppSettings"))

.ValidateDataAnnotations()

.ValidateOnStart();

### Feature Flags

#### Simple Feature Flag

public class FeatureFlags

{

public bool EnableNewFeature { get; set; }

}

public interface IFeatureFlag

{

bool Enabled { get; }

}

public class DataProcessingFeatureFlag : IFeatureFlag

{

public bool Enabled { get; private set; }

public void UpdateFlag(bool enabled)

{

Enabled = enabled;

}

}

#### Register Feature Flag

builder.Services.AddSingleton&lt;DataProcessingFeatureFlag&gt;();

// Load from configuration

var featureFlag = builder.Services.BuildServiceProvider()

.GetRequiredService&lt;DataProcessingFeatureFlag&gt;();

featureFlag.UpdateFlag(builder.Configuration.GetValue&lt;bool&gt;("FeatureFlags:DataProcessing"));

#### Use in Code

public class DataProcessor

{

private readonly DataProcessingFeatureFlag \_featureFlag;

public DataProcessor(DataProcessingFeatureFlag featureFlag)

{

\_featureFlag = featureFlag;

}

public IList&lt;DataPoint&gt; Process(IList&lt;DataPoint&gt;? data)

{

if (!\_featureFlag.Enabled || data == null)

return data ?? Array.Empty&lt;DataPoint&gt;();

return ProcessData(data);

}

}

## Frontend Configuration (Angular)

### Environment Files

#### environment.ts (Development)

export const environment = {

production: false,

apiUrl: '<http://localhost:5000/api>',

enableLogging: true,

featureFlags: {

enableNewDashboard: true,

enableExperimentalFeatures: true

}

};

#### environment.prod.ts (Production)

export const environment = {

production: true,

apiUrl: '<https://api.example.com/api>',

enableLogging: false,

featureFlags: {

enableNewDashboard: false,

enableExperimentalFeatures: false

}

};

#### angular.json Configuration

{

"projects": {

"my-app": {

"architect": {

"build": {

"configurations": {

"production": {

"fileReplacements": \[

{

"replace": "src/environments/environment.ts",

"with": "src/environments/environment.prod.ts"

}

\]

},

"staging": {

"fileReplacements": \[

{

"replace": "src/environments/environment.ts",

"with": "src/environments/environment.staging.ts"

}

\]

}

}

}

}

}

}

}

### Using Environment Config

import { environment } from '../environments/environment';

@Injectable({ providedIn: 'root' })

export class ApiService {

private apiUrl = environment.apiUrl;

constructor(private http: HttpClient) {}

getUsers(): Observable&lt;User\[\]&gt; {

return this.http.get&lt;User\[\]&gt;(\`\${this.apiUrl}/users\`);

}

}

### Runtime Configuration

For values that can't be set at build time:

#### assets/config.json

{

"apiUrl": "<https://api.example.com>",

"features": {

"enableNewDashboard": true

}

}

#### Load at Startup

export function initializeApp(http: HttpClient) {

return (): Promise&lt;any&gt; => {

return http.get('/assets/config.json')

.toPromise()

.then(config => {

// Store config in service or provide globally

});

};

}

// app.config.ts

export const appConfig: ApplicationConfig = {

providers: \[

{

provide: APP_INITIALIZER,

useFactory: initializeApp,

deps: \[HttpClient\],

multi: true

}

\]

};

## Kubernetes Configuration

### ConfigMaps

For non-sensitive configuration:

apiVersion: v1

kind: ConfigMap

metadata:

name: app-config

data:

appsettings.json: |

{

"AppSettings": {

"MaxRetryAttempts": 3,

"TimeoutSeconds": 30

}

}

ASPNETCORE_ENVIRONMENT: "Production"

Mount as file:

volumes:

\- name: config-volume

configMap:

name: app-config

volumeMounts:

\- name: config-volume

mountPath: /app/config

Or as environment variables:

envFrom:

\- configMapRef:

name: app-config

### Secrets

For sensitive data:

apiVersion: v1

kind: Secret

metadata:

name: app-secrets

type: Opaque

data:

database-connection: &lt;base64-encoded-value&gt;

api-key: &lt;base64-encoded-value&gt;

Use in deployment:

env:

\- name: ConnectionStrings_\_DefaultConnection

valueFrom:

secretKeyRef:

name: app-secrets

key: database-connection

## Docker Configuration

### Dockerfile

FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

COPY . .

\# Don't bake secrets into image

\# Use environment variables or mounted volumes

ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT \["dotnet", "MyApp.dll"\]

### docker-compose.yml

services:

myapp:

image: myapp:latest

environment:

\- ASPNETCORE_ENVIRONMENT=Development

\- ConnectionStrings_\_DefaultConnection=Server=db;Database=MyApp;

env_file:

\- .env # Load from file

volumes:

\- ./appsettings.Development.json:/app/appsettings.Development.json

### .env File

\# .env (never commit this)

DATABASE_PASSWORD=secret123

API_KEY=abc123xyz

REDIS_CONNECTION=localhost:6379

## Configuration Best Practices

### 1\. Never Commit Secrets

\# Always ignore

appsettings.\*.json

!appsettings.json

!appsettings.Development.json

\*.user

secrets.json

.env

.env.\*

### 2\. Use Structured Configuration

{

"Database": {

"ConnectionString": "...",

"CommandTimeout": 30,

"MaxRetries": 3

},

"Logging": {

"LogLevel": {

"Default": "Information"

}

}

}

### 3\. Provide Defaults

public class AppSettings

{

public int MaxRetryAttempts { get; set; } = 3;

public int TimeoutSeconds { get; set; } = 30;

}

### 4\. Document Configuration

/// &lt;summary&gt;

/// Application configuration settings

/// &lt;/summary&gt;

public class AppSettings

{

/// &lt;summary&gt;

/// Maximum number of retry attempts for failed operations.

/// Default: 3, Range: 1-10

/// &lt;/summary&gt;

public int MaxRetryAttempts { get; set; } = 3;

}

### 5\. Validate Early

Fail fast if configuration is invalid:

var appSettings = new AppSettings();

builder.Configuration.GetSection("AppSettings").Bind(appSettings);

appSettings.Validate(); // Throws if invalid

### 6\. Use Type-Safe Access

// Good

var timeout = \_appSettings.TimeoutSeconds;

// Avoid

var timeout = int.Parse(Configuration\["AppSettings:TimeoutSeconds"\]);

### 7\. Environment-Specific Settings

Only override what changes:

// appsettings.Production.json

{

"ConnectionStrings": {

"DefaultConnection": "production-connection-string"

}

// Don't repeat all settings, only overrides

}

### 8\. Use Feature Flags for Gradual Rollouts

{

"FeatureFlags": {

"DataProcessing": false // Default off, enable per environment

}

}

## Example Configuration Structure

### Backend Service

MyService/

+-- appsettings.json # Base config, committed

+-- appsettings.Development.json # Dev overrides, committed

+-- appsettings.Production.json # Prod overrides, committed

+-- appsettings.Local.json # Local overrides, NOT committed

+-- Program.cs

### Frontend Application

src/

+-- environments/

� +-- environment.ts # Development

� +-- environment.prod.ts # Production

� +-- environment.staging.ts # Staging

� +-- environment.local.ts # Local (NOT committed)

+-- assets/

+-- config.json # Runtime config

## Security Checklist

- No secrets in source control
- Secrets stored in secure vault (Azure Key Vault, AWS Secrets Manager)
- Use environment variables for secrets
- Restrict access to production configuration
- Rotate secrets regularly
- Use managed identities where possible
- Encrypt sensitive config files
- Log configuration loading (but not values)
- Validate configuration on startup
- Document all configuration options

## Summary

- **Separate**: Configuration from code
- **Secure**: Never commit secrets
- **Validate**: Check configuration at startup
- **Type-Safe**: Use strongly-typed classes
- **Layer**: Override by environment
- **Document**: Explain configuration options
- **Default**: Provide sensible defaults
- **Fail Fast**: Invalid config = startup failure