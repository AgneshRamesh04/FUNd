# FUNd - Feature-First Clean Architecture Guide

## Architecture Overview

The FUNd app now follows **Feature-First Clean Architecture** with strict separation of concerns across three layers per feature:

```
features/
├── feature_name/
│   ├── presentation/       # UI Layer (Screens, Widgets, Providers)
│   ├── domain/            # Business Logic Layer (Entities, Repositories, UseCases)
│   └── data/              # Data Layer (Models, DataSources, Repository Implementations)
├── (other features...)
└── core/                  # Shared utilities (Theme, Constants, DI)
```

## Architecture Principles

### 1. **Dependency Rule**
Dependencies only flow inward:

```
Presentation → Domain ← Data
      ↓         ↓         ↓
   UI/Widgets  Entities  Models
   Screens     UseCases  DataSources
   Providers   Repos     Implementations
```

### 2. **Layer Responsibilities**

#### **Presentation Layer** (`presentation/`)
- **Purpose**: Handle UI and user interaction
- **Components**:
  - `screens/` - Full-page UI screens
  - `widgets/` - Reusable UI components
  - `providers/` - Riverpod providers for state management
- **Independence**: NO direct database calls
- **Dependencies**: Only on Domain layer (UseCases, Entities)

#### **Domain Layer** (`domain/`)
- **Purpose**: Core business logic, independent of frameworks
- **Components**:
  - `entities/` - Pure Dart classes (business objects)
  - `repositories/` - Abstract interfaces (contracts)
  - `usecases/` - Implement specific business operations
- **Independence**: NO Flutter dependencies, NO external frameworks
- **Dependencies**: None (pure Dart)

#### **Data Layer** (`data/`)
- **Purpose**: Implement data access logic
- **Components**:
  - `models/` - DTO objects with serialization logic
  - `data_sources/` - Abstract interfaces for remote/local access
  - `repositories/` - Implement domain repositories
- **Independence**: Handles Supabase, SQLite, API calls
- **Dependencies**: On Domain (repositories, entities)

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── di/
│   │   └── service_locator.dart      # Dependency injection setup
│   ├── theme/
│   │   └── app_theme.dart            # Material theme
│   ├── constants/
│   │   └── app_constants.dart        # App-wide constants
│   ├── utils/
│   │   ├── app_utils.dart            # Utility functions
│   │   └── widgets.dart              # Shared UI widgets
│   ├── services/
│   │   ├── supabase_service.dart     # Backend integration
│   │   └── auth_service.dart         # Auth logic
│   └── database/
│       └── models.dart               # Legacy (to be removed)
│
├── features/
│   ├── transactions/                 # Transaction Feature
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── add_transaction_screen.dart
│   │   │   ├── widgets/
│   │   │   └── providers/
│   │   │       ├── transaction_providers.dart
│   │   │       └── transaction_form_provider.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── transaction_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── transaction_repository.dart
│   │   │   └── usecases/
│   │   │       └── transaction_usecases.dart
│   │   └── data/
│   │       ├── models/
│   │       │   └── transaction_model.dart
│   │       ├── data_sources/
│   │       │   └── transaction_data_sources.dart
│   │       └── repositories/
│   │           └── transaction_repository_impl.dart
│   │
│   ├── home/                         # Home Feature
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   └── providers/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── home_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── home_repository.dart
│   │   │   └── usecases/
│   │   │       └── home_usecases.dart
│   │   └── data/
│   │       ├── models/
│   │       ├── data_sources/
│   │       └── repositories/
│   │
│   ├── personal/                    # Personal Feature
│   │   ├── presentation/
│   │   │   └── screens/
│   │   │       └── personal_screen.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── data/
│   │
│   ├── shared/                      # Shared Expenses Feature
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   └── auth/                        # Authentication Feature
│       ├── presentation/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user_entity.dart
│       │   ├── repositories/
│       │   │   └── auth_repository.dart
│       │   └── usecases/
│       │       └── auth_usecases.dart
│       └── data/
```

## Data Flow Example: Fetching Transactions

### 1. **Presentation Layer** (Screens ask for data)
```dart
// HomeScreen displays data
final transactions = ref.watch(transactionsProvider);

// Provider fetches using UseCase
final transactionsProvider = FutureProvider<List<TransactionEntity>>((ref) async {
  final useCase = ref.watch(getTransactionsUseCaseProvider);
  return useCase();
});
```

### 2. **Domain Layer** (UseCases orchestrate business logic)
```dart
// UseCase delegates to repository
class GetTransactionsUseCase {
  final TransactionRepository repository;
  
  Future<List<TransactionEntity>> call() async {
    return repository.getTransactions();  // ← Abstract interface
  }
}
```

### 3. **Data Layer** (Repository implements domain contract)
```dart
// Concrete implementation
class TransactionRepositoryImpl implements TransactionRepository {
  @override
  Future<List<TransactionEntity>> getTransactions() async {
    try {
      // Call remote data source (Supabase)
      final models = await remoteDataSource.getTransactions();
      
      // Convert to entities and return
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Fallback to local cache
      final cached = await localDataSource.getCachedTransactions();
      return cached.map((model) => model.toEntity()).toList();
    }
  }
}
```

## Dependency Injection (GetIt)

Service Locator setup in `core/di/service_locator.dart`:

```dart
// Register dependencies
getIt.registerSingleton<TransactionRepository>(
  TransactionRepositoryImpl(
    remoteDataSource: getIt<TransactionRemoteDataSource>(),
    localDataSource: getIt<TransactionLocalDataSource>(),
  ),
);

getIt.registerSingleton(GetTransactionsUseCase(getIt()));
```

**Usage**:
```dart
// In providers or anywhere you need it
final useCase = getIt<GetTransactionsUseCase>();
```

## State Management (Riverpod)

### Feature-Level Providers Pattern

```dart
// lib/features/transactions/presentation/providers/transaction_providers.dart

// 1. UseCase providers (singleton from GetIt)
final getTransactionsUseCaseProvider = Provider(
  (_) => getIt<GetTransactionsUseCase>(),
);

// 2. Data providers (computed from usecases)
final transactionsProvider = FutureProvider<List<TransactionEntity>>((ref) async {
  final useCase = ref.watch(getTransactionsUseCaseProvider);
  return useCase();
});

// 3. Derived data providers
final userBorrowsProvider = FutureProvider.family<List<TransactionEntity>, String>(
  (ref, userId) async {
    final transactions = await ref.watch(transactionsProvider.future);
    return transactions.where((t) => t.receivedBy == userId).toList();
  },
);

// 4. State providers (for mutable state)
final transactionFormProvider = StateNotifierProvider<
    TransactionFormNotifier, 
    TransactionEntity?>((ref) {
  return TransactionFormNotifier();
});
```

## Creating a New Feature

### Step 1: Create Directory Structure
```bash
mkdir -p lib/features/myfeature/{presentation,domain,data}/{screens,widgets,providers,entities,repositories,usecases,models,data_sources}
```

### Step 2: Define Domain (Business Logic)
```dart
// domain/entities/my_entity.dart
class MyEntity extends Equatable {
  final String id;
  final String name;
  
  const MyEntity({required this.id, required this.name});
  
  @override
  List<Object?> get props => [id, name];
}

// domain/repositories/my_repository.dart
abstract class MyRepository {
  Future<List<MyEntity>> getItems();
  Future<MyEntity> createItem(MyEntity item);
}

// domain/usecases/my_usecases.dart
class GetItemsUseCase {
  final MyRepository repository;
  GetItemsUseCase(this.repository);
  
  Future<List<MyEntity>> call() => repository.getItems();
}
```

### Step 3: Implement Data Layer
```dart
// data/models/my_model.dart
@JsonSerializable()
class MyModel {
  final String id;
  final String name;
  
  MyEntity toEntity() => MyEntity(id: id, name: name);
  
  static MyModel fromEntity(MyEntity entity) =>
      MyModel(id: entity.id, name: entity.name);
}

// data/data_sources/my_data_sources.dart
abstract class MyRemoteDataSource {
  Future<List<MyModel>> getItems();
}

// data/repositories/my_repository_impl.dart
class MyRepositoryImpl implements MyRepository {
  final MyRemoteDataSource remoteDataSource;
  
  @override
  Future<List<MyEntity>> getItems() async {
    final models = await remoteDataSource.getItems();
    return models.map((m) => m.toEntity()).toList();
  }
}
```

### Step 4: Register in Service Locator
```dart
// core/di/service_locator.dart
getIt.registerSingleton<MyRepository>(
  MyRepositoryImpl(remoteDataSource: getIt()),
);

getIt.registerSingleton(GetItemsUseCase(getIt()));
```

### Step 5: Create Presentation Layer
```dart
// presentation/providers/my_providers.dart
final getItemsUseCaseProvider = Provider((_) => getIt<GetItemsUseCase>());

final itemsProvider = FutureProvider<List<MyEntity>>((ref) async {
  final useCase = ref.watch(getItemsUseCaseProvider);
  return useCase();
});

// presentation/screens/my_screen.dart
class MyScreen extends ConsumerWidget {
  const MyScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsProvider);
    
    return items.when(
      data: (items) => ListView(...),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

## Best Practices

### 1. **Entity Independence**
- Entities should be pure Dart classes with NO Flutter imports
- They represent core business domain objects

### 2. **Repository Abstraction**
- Always define abstract repositories in domain layer
- Implement in data layer
- Use for testing (can mock easily)

### 3. **UseCase Responsibility**
- Each UseCase handles ONE specific business operation
- Compose multiple UseCases if needed
- Keep them simple and focused

### 4. **Data Layer Conversion**
- Models convert from/to API/database format
- Entities are independent of data sources
- Conversion happens at boundary between layers

### 5. **No Framework Dependencies in Domain**
- Domain layer has ZERO Flutter imports
- Makes it reusable and testable
- Pure Dart business logic

### 6. **Feature Independence**
- Each feature can be developed independently
- Features only communicate through shared core services
- Easy to add/remove features

### 7. **Testing Strategy**
```dart
// Unit test (domain layer - fastest)
test('Calculate pool balance', () {
  expect(service.calculateBalance(...), equals(500.0));
});

// Widget test (presentation layer)
testWidgets('Show home screen', (tester) async {
  await tester.pumpWidget(...);
  expect(find.text('Pool Balance'), findsOneWidget);
});

// Integration test (full feature flow)
testWidgets('User can add transaction', (tester) async {
  // Complete user journey
});
```

## Migration Path from Old Structure

### What Changed
- ✅ Models moved to feature-specific `data/models/`
- ✅ Screens moved to `presentation/screens/`
- ✅ Providers moved to `presentation/providers/`
- ✅ Services separated into domain (UseCases) and data (implementations)
- ✅ Added dependency injection via GetIt
- ✅ Centralized business logic in UseCases

### What to Update
1. **Imports**: Update all feature imports to use new paths
2. **Providers**: Move to feature-level providers
3. **Services**: Convert to Data layer implementations
4. **Tests**: Update imports and test structure

## Advantages of This Architecture

1. **Testability**: Easy to unit test business logic independently
2. **Maintainability**: Clear separation makes code easier to understand
3. **Scalability**: Can add features without impacting existing code
4. **Flexibility**: Swap implementations (Supabase → REST API)
5. **Reusability**: Domain layer can be extracted to package
6. **Dependency Management**: GetIt handles all wiring
7. **Framework Independence**: Domain layer has zero Flutter dependency

## Resources

- [Clean Architecture by Robert Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Reso Coder's Flutter Clean Architecture](https://resocoder.com/)
- [GetIt Dependency Injection](https://pub.dev/packages/get_it)
- [Riverpod State Management](https://riverpod.dev/)

---

**Version**: 2.0 (Clean Architecture)
**Last Updated**: March 2026
