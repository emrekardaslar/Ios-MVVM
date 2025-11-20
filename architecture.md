# iOS MVVM Architecture Template

## Overview

This project demonstrates a scalable iOS application architecture using MVVM (Model-View-ViewModel) pattern with Coordinator-based navigation, Repository pattern, and Dependency Injection.

**Tech Stack:**
- SwiftUI
- Swift Concurrency (async/await)
- Combine (for reactive bindings)

**Core Patterns:**
- MVVM (Model-View-ViewModel)
- Coordinator Pattern (Navigation)
- Repository Pattern (Data Layer)
- Dependency Injection (Loose Coupling)

---

## Project Structure

```
Ios-MVVM/
├── Infrastructure/
│   ├── Repositories/
│   │   ├── Protocols/
│   │   │   └── ProductRepositoryProtocol.swift
│   │   └── Implementations/
│   │       └── ProductRepository.swift
│   └── Services/
│       └── NetworkService.swift
├── Application/
│   ├── ViewModels/
│   │   ├── ProductListViewModel.swift
│   │   └── ProductDetailViewModel.swift
│   └── Models/
│       └── Product.swift
├── Presentation/
│   ├── Views/
│   │   ├── ProductListView.swift
│   │   └── ProductDetailView.swift
│   └── Coordinator/
│       ├── Coordinator.swift
│       ├── AppCoordinator.swift
│       └── Route.swift
├── DI/
│   └── DIContainer.swift
└── App/
    └── Ios_MVVMApp.swift
```

---

## Architecture Layers

### 1. Infrastructure Layer
**Purpose:** Data access and external service communication

**Components:**
- **NetworkService**: Handles HTTP requests using URLSession with async/await
- **Repositories**: Abstracts data sources and provides domain models
  - Uses protocols for abstraction (testability)
  - Transforms network responses to domain models
  - Can combine multiple data sources (API, local storage, cache)

**Responsibilities:**
- API communication
- Data parsing and transformation
- Error handling at network level

---

### 2. Application Layer
**Purpose:** Business logic and state management

**Components:**
- **ViewModels**:
  - Contains business logic
  - Manages UI state using `@Published` properties
  - Communicates with repositories for data
  - Delegates navigation to Coordinator
  - No direct UIKit/SwiftUI dependencies (testable)

- **Models**:
  - Domain models (business entities)
  - Plain Swift structs/classes

**Responsibilities:**
- Business logic execution
- State management
- Data transformation for UI
- Validation

---

### 3. Presentation Layer
**Purpose:** User interface and navigation

**Components:**
- **Views (SwiftUI)**:
  - Displays UI
  - Observes ViewModel state
  - Delegates user actions to ViewModel
  - No business logic

- **Coordinator**:
  - Manages navigation flow
  - Holds NavigationPath (SwiftUI)
  - Creates Views with their ViewModels
  - Handles deep linking and routing

**Responsibilities:**
- UI rendering
- User interaction handling
- Screen navigation

---

## Navigation: Coordinator Pattern

### Why Coordinator?
- Decouples navigation logic from ViewModels
- ViewModels remain testable (no navigation dependencies)
- Centralized routing makes deep linking easier
- Reusable navigation flows

### Implementation Approach

**1. Route Definition (Enum-based)**
```swift
enum Route: Hashable {
    case productList
    case productDetail(Product)
}
```

**2. Coordinator Protocol**
```swift
protocol Coordinator {
    func navigate(to route: Route)
    func pop()
    func popToRoot()
}
```

**3. AppCoordinator (Implementation)**
- Holds `NavigationPath` for SwiftUI NavigationStack
- Implements navigation methods
- Creates Views with injected ViewModels
- ViewModels receive coordinator reference

**4. ViewModel → Coordinator Communication**
ViewModels hold a reference to the coordinator:
```swift
class ProductListViewModel: ObservableObject {
    private let coordinator: Coordinator

    func didSelectProduct(_ product: Product) {
        coordinator.navigate(to: .productDetail(product))
    }
}
```

---

## Dependency Injection

### DIContainer
A simple container that holds and provides dependencies:

**What it holds:**
- NetworkService (singleton)
- Repositories (singleton)
- Coordinator (singleton)

**How it works:**
1. Container initialized at app startup
2. Coordinator gets injected with container
3. Coordinator creates ViewModels and injects their dependencies
4. ViewModels receive: repository + coordinator

**Benefits:**
- Loose coupling
- Easy testing (swap real implementations with mocks)
- Single source of truth for dependencies
- No external framework needed

---

## Data Flow

### Example: Loading Product List

```
1. User opens app
   └─> ProductListView appears

2. View initializes ViewModel
   └─> ViewModel.loadProducts() called

3. ViewModel calls Repository
   └─> ProductRepository.fetchProducts()

4. Repository calls NetworkService
   └─> NetworkService.request<[Product]>(endpoint: "/products")

5. Network response flows back
   └─> NetworkService returns [ProductDTO]
   └─> Repository transforms to [Product]
   └─> ViewModel updates @Published property
   └─> View automatically updates (SwiftUI)
```

### Example: Navigation

```
1. User taps product
   └─> View calls ViewModel.didSelectProduct(product)

2. ViewModel delegates to Coordinator
   └─> coordinator.navigate(to: .productDetail(product))

3. Coordinator updates NavigationPath
   └─> SwiftUI NavigationStack pushes new view

4. Coordinator creates ProductDetailView
   └─> Injects ProductDetailViewModel with product + dependencies
   └─> View appears
```

---

## Testing Strategy

### ViewModel Tests
- Mock the repository (protocol-based)
- Mock the coordinator
- Test business logic in isolation
- Verify navigation calls

### Repository Tests
- Mock the NetworkService
- Test data transformation
- Test error handling

### Integration Tests
- Test full flow with real dependencies
- Verify data propagation

---

## Key Principles

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Dependency Inversion**: Depend on abstractions (protocols), not concretions
3. **Testability**: All components can be tested in isolation
4. **Scalability**: Easy to add new features without modifying existing code
5. **Simplicity**: No over-engineering, just enough architecture for growth

---

## Example Use Case: Product List → Product Detail

**Screens:**
1. **Product List**: Grid/List of products with image, name, price
2. **Product Detail**: Full product info with description

**Flow:**
1. App launches → DIContainer created
2. AppCoordinator initialized with NavigationStack
3. ProductListView shown (root)
4. User taps product → ViewModel notifies Coordinator
5. Coordinator pushes ProductDetailView
6. ProductDetailView displays product data

**Data Source:**
- Mock API or real REST API (configurable)
- Products fetched via ProductRepository
- NetworkService handles HTTP

---

## Future Enhancements

This template can be extended with:
- Authentication flow (separate AuthCoordinator)
- Local persistence (CoreData/Realm)
- Caching layer in repositories
- Analytics integration
- Error handling UI
- Loading states
- Pull-to-refresh
- Search and filtering

---

## Conclusion

This architecture provides a solid foundation for iOS apps that need to scale. While it might seem complex for a 2-screen app, it demonstrates industry best practices and makes future growth painless.

**When to use this:**
- Medium to large apps
- Apps with complex navigation
- Apps requiring high testability
- Team projects with multiple developers
- Long-term maintained projects

**When to simplify:**
- Quick prototypes
- Single-screen apps
- Proof of concepts
