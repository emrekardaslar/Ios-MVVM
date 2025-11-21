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
│   │   ├── HomeViewModel.swift
│   │   ├── ProductListViewModel.swift
│   │   ├── ProductDetailViewModel.swift
│   │   ├── FavoritesViewModel.swift
│   │   ├── OrdersViewModel.swift
│   │   └── ReviewsViewModel.swift
│   └── Models/
│       ├── Product.swift
│       └── Order.swift
├── Presentation/
│   ├── Views/
│   │   ├── TabBarView.swift
│   │   ├── HomeView.swift
│   │   ├── ProductListView.swift
│   │   ├── ProductDetailView.swift
│   │   ├── FavoritesView.swift
│   │   ├── OrdersView.swift
│   │   └── ReviewsView.swift
│   └── Coordinator/
│       ├── Coordinator.swift
│       ├── AppCoordinator.swift
│       ├── Route.swift
│       ├── Tab.swift
│       └── ViewFactory.swift
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
- Intent-based API provides semantic navigation methods

### Implementation Approach

**1. Route Definition (Enum-based with Auto-Generated Identifiers)**
```swift
enum Route: Hashable {
    case home
    case productList
    case productDetail(Product)
    case favorites
    case orders
    case reviews

    // Auto-generates identifier using Mirror reflection
    // Associated values map to same identifier (e.g., all productDetail routes → "productDetail")
    var identifier: String {
        Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }
}
```

**2. Tab Definition**
```swift
enum Tab: String, CaseIterable {
    case home
    case products
    case favorites

    var rootRoute: Route {
        switch self {
        case .home: return .home
        case .products: return .productList
        case .favorites: return .favorites
        }
    }
}
```

**3. Coordinator Protocol (Intent-Based Navigation)**
```swift
protocol Coordinator: AnyObject {
    // Basic Navigation
    func pop()
    func popToRoot()

    // Intent-Based Navigation
    func showProduct(_ product: Product)
    func showProducts()
    func showOrders()
    func showReviews()
}
```

**4. AppCoordinator (Implementation)**
- Holds `NavigationPath` per tab (dictionary-based) for independent tab navigation
- Implements intent methods that map to routes internally
- Uses registration pattern for view creation (no switch statements!)
- ViewModels receive coordinator reference

**5. ViewFactory (Registration Pattern)**
Single place to register all routes:
```swift
class ViewFactory {
    static func registerViews(coordinator: AppCoordinator) {
        coordinator.register(identifier: Route.home.identifier) { _ in
            HomeViewModel(coordinator: coordinator) → HomeView
        }

        coordinator.register(identifier: Route.productDetail(Product.mock).identifier) { route in
            if case .productDetail(let product) = route {
                ProductDetailViewModel(product: product, coordinator: coordinator) → ProductDetailView
            }
        }
        // ... other registrations
    }
}
```

**Benefits:**
- Adding new routes only requires one line in ViewFactory
- No switch statements to maintain
- Type-safe route identifiers
- Automatic identifier generation

**How to Add a New Route (Example: Reviews):**
1. Add case to Route enum: `case reviews`
2. Add intent method to Coordinator protocol: `func showReviews()`
3. Implement in AppCoordinator: `func showReviews() { navigate(to: .reviews) }`
4. Register in ViewFactory: `coordinator.register(identifier: Route.reviews.identifier) { ... }`

That's it! The identifier is auto-generated, no manual string mapping needed.

**6. ViewModel → Coordinator Communication (Intent-Based)**
ViewModels express intent, not routes:
```swift
class ProductListViewModel: ObservableObject {
    private weak var coordinator: Coordinator?

    func didSelectProduct(_ product: Product) {
        coordinator?.showProduct(product) // Intent, not route!
    }
}
```

**Why Intent-Based?**
- ViewModels don't know about routes (better separation)
- Coordinator decides routing logic
- More semantic and readable
- Easier to modify routing without touching ViewModels

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

### Example: Navigation (Intent-Based)

```
1. User taps product
   └─> View calls ViewModel.didSelectProduct(product)

2. ViewModel expresses intent to Coordinator
   └─> coordinator.showProduct(product)

3. Coordinator maps intent to route
   └─> navigate(to: .productDetail(product)) [private method]
   └─> Updates current tab's NavigationPath

4. SwiftUI NavigationStack triggers navigationDestination
   └─> Coordinator.build(route) called

5. Coordinator looks up registered view builder
   └─> ViewFactory registration returns ProductDetailView
   └─> Injects ProductDetailViewModel with product + dependencies
   └─> View appears
```

### Multi-Tab Navigation

Each tab maintains its own NavigationPath:
```swift
@Published private(set) var paths: [Tab: NavigationPath] = [:]

// Tab switching preserves navigation state
// Example: Products tab can have ProductDetail stack while Home tab is at root
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

## Example Use Case: Multi-Tab App with Navigation

**Screens:**
1. **Home Tab**: Welcome screen with quick actions and stats
   - Navigate to Orders
   - Navigate to Reviews
2. **Products Tab**: List of products with search/filter
   - Navigate to Product Detail
3. **Favorites Tab**: Saved products
   - Navigate to Product Detail

**Flow:**
1. App launches → DIContainer created
2. AppCoordinator initialized with TabBar and NavigationStacks
3. ViewFactory registers all routes
4. TabBarView shown with three tabs
5. Each tab has independent navigation state
6. User navigates within tabs → Coordinator manages stack per tab
7. Tab switching preserves navigation history

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
