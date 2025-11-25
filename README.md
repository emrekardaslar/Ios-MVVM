# iOS MVVM Architecture Template

## Overview

This project demonstrates a scalable iOS application architecture using MVVM (Model-View-ViewModel) pattern with Activity-based multi-app support, URL-driven navigation, auto-generated routing, and Dependency Injection.

**Tech Stack:**
- SwiftUI
- Swift Concurrency (async/await)
- Combine (for reactive bindings)

**Core Patterns:**
- MVVM (Model-View-ViewModel)
- Activity Pattern (Multi-app support)
- URL-Based Navigation with Coordinator
- Repository Pattern (Data Layer)
- Dependency Injection (Loose Coupling)
- Auto-Generated Routing (Build-time code generation)

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
│   │   ├── SavedViewModel.swift
│   │   ├── OrdersViewModel.swift
│   │   ├── ReviewsViewModel.swift
│   │   └── BrochuresViewModel.swift
│   └── Models/
│       ├── Product.swift
│       └── Order.swift
├── Presentation/
│   ├── Views/
│   │   ├── TabBarView.swift
│   │   ├── ActivitySwitcherView.swift
│   │   ├── HomeView.swift
│   │   ├── ProductListView.swift
│   │   ├── ProductDetailView.swift
│   │   ├── FavoritesView.swift
│   │   ├── SavedView.swift
│   │   ├── OrdersView.swift
│   │   ├── ReviewsView.swift
│   │   └── BrochuresView.swift
│   └── Coordinator/
│       ├── Coordinator.swift
│       ├── AppCoordinator.swift
│       ├── Activity.swift
│       ├── RouteConfig.swift
│       ├── Route.swift (auto-generated)
│       ├── Tab.swift
│       ├── Routable.swift
│       ├── URLRouter.swift
│       └── RoutableTypes.swift (auto-generated)
├── DI/
│   └── DIContainer.swift
├── Scripts/
│   └── generate_routable_files.sh
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
  - Uses URL-based navigation
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
  - Manages navigation flow and activities
  - Holds NavigationPath per tab (SwiftUI)
  - Creates Views with their ViewModels
  - Handles deep linking, URLs, and routing
  - Manages activity switching

**Responsibilities:**
- UI rendering
- User interaction handling
- Screen navigation
- Activity management

---

## Activity System: Multi-App Architecture

### What is an Activity?

An **Activity** represents a complete app context within your application. Think of it as having multiple mini-apps in one:

```swift
enum Activity: String, CaseIterable {
    case ecommerce  // Shopping app context
    case brochure   // Catalog/Marketing app context
}
```

### Why Activities?

**Use Cases:**
- **Multi-app in one**: B2C shopping + B2B wholesale + Admin portal
- **Context switching**: Buyer mode vs Seller mode vs Agent mode
- **Feature isolation**: Personal banking + Business banking + Investments

**Benefits:**
- Clean separation of concerns
- Independent tab sets per activity
- Preserved navigation state when switching
- Shared infrastructure (auth, payments, data)

### Activity Structure

Each activity has:
- **Display name**: User-facing label
- **Icon**: Visual identifier
- **Default tab**: Initial tab when switching to activity
- **Tab set**: Tabs that belong to this activity

```
E-Commerce Activity          Brochure Activity
┌─────────────────┐         ┌─────────────────┐
│ [Home] tab      │         │ [Brochures] tab │
│ [Products] tab  │         └─────────────────┘
│ [Favorites] tab │
└─────────────────┘
```

### Switching Activities

**Manual**: User taps "Apps" button in navigation bar
- Shows menu with all activities
- Current activity marked with checkmark
- Switches activity and resets to default tab

**Automatic**: Via URL navigation
- Deep link includes activity information
- AppCoordinator automatically switches if needed
- Navigation state preserved across switches

---

## URL-Based Navigation

### Core Concept

**Everything navigates using web URLs**. Whether it's:
- User tapping a button
- Deep link from notification
- Universal link from web
- App link from another app

All use the same API: `coordinator.navigate(to: URL)`

### RouteConfig

ViewModels declare their routing configuration:

```swift
struct RouteConfig {
    let activity: Activity     // Which activity this belongs to
    let tab: Tab?             // Optional: which tab to navigate to (nil = stay on current tab)
    let path: String          // URL path pattern
    let requiresAuth: Bool    // Authentication requirement
}
```

### ViewModel Example

```swift
extension ProductDetailViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: .ecommerce,
            tab: nil,  // No specific tab - opens in current tab
            path: "/products/:id"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        guard let id = parameters["id"], let productId = Int(id) else {
            return nil
        }
        // Fetch product from repository or mock data
        let product = Product.mockList.first { $0.id == productId } ?? Product.mock
        return .productDetail(product)
    }

    static func extractParameters(from route: Route) -> [String: String] {
        if case .productDetail(let product) = route {
            return ["id": "\(product.id)"]
        }
        return [:]
    }

    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        if case .productDetail(let product) = route {
            let viewModel = ProductDetailViewModel(product: product, coordinator: coordinator)
            return AnyView(ProductDetailView(viewModel: viewModel))
        }
        return AnyView(Text("Invalid route for ProductDetail").foregroundColor(.red))
    }
}
```

### Navigation Flow

```
1. User Action / External Trigger
   ↓
   coordinator.navigate(to: "https://myapp.com/products/123?tab=products")
   ↓
2. URLRouter.route(from: URL)
   - Extracts tab from query parameter: tab = "products"
   - Matches path pattern: "/products/:id"
   - Extracts parameters: id = "123"
   - Calls ProductDetailViewModel.createRoute(["id": "123"])
   - Gets RouteConfig from ProductDetailViewModel
   ↓
   Returns: (activity: .ecommerce, tab: .products, route: .productDetail(Product))
   ↓
3. AppCoordinator
   - Switch activity if different
   - Switch tab if specified (from URL or RouteConfig)
   - Use routableTypeMap to find ViewModel by route identifier
   - Build view using ViewModel.createView()
   ↓
4. View Displayed
```

### URL Pattern Matching

Supports dynamic parameters:
- `/home` → Exact match
- `/products/:id` → Matches `/products/123`, extracts `id=123`
- `/users/:userId/orders/:orderId` → Multiple parameters

---

## Auto-Generated Routing

### Build-Time Code Generation

A shell script (`Scripts/generate_routable_files.sh`) runs before compilation:

**What it does:**
1. Scans all `*ViewModel.swift` files
2. Finds extensions conforming to `Routable`
3. Extracts `routeConfig.path` from each
4. Generates route identifiers from ViewModel names (e.g., `ProductDetailViewModel` → `productDetail`)
5. Generates two files:
   - `Route.swift` - Enum with all route cases
   - `RoutableTypes.swift` - Array of ViewModel types + route identifier map

**Example Output:**

```swift
// Route.swift (auto-generated)
enum Route: Hashable {
    case home
    case productList
    case productDetail(Product)
    case favorites
    case saved
    case orders
    case reviews
    case brochures
    case brochureDetail(Brochure)

    var identifier: String {
        Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }
}

// RoutableTypes.swift (auto-generated)
let routableTypes: [any Routable.Type] = [
    HomeViewModel.self,
    ProductListViewModel.self,
    ProductDetailViewModel.self,
    FavoritesViewModel.self,
    SavedViewModel.self,
    OrdersViewModel.self,
    ReviewsViewModel.self,
    BrochuresViewModel.self,
    BrochureDetailViewModel.self
]

// Auto-generated map for O(1) route lookup
let routableTypeMap: [String: any Routable.Type] = [
    "home": HomeViewModel.self,
    "productList": ProductListViewModel.self,
    "productDetail": ProductDetailViewModel.self,
    "favorites": FavoritesViewModel.self,
    "saved": SavedViewModel.self,
    "orders": OrdersViewModel.self,
    "reviews": ReviewsViewModel.self,
    "brochures": BrochuresViewModel.self,
    "brochureDetail": BrochureDetailViewModel.self
]
```

**Benefits:**
- Zero manual maintenance
- Compile-time safety
- O(1) route lookup via map
- Clean git diffs (files in `.gitignore`)
- No switch statements or manual registration needed

### Adding a New Route

**Example: Add Product Reviews**

1. Create `ProductReviewsViewModel.swift`:
```swift
extension ProductReviewsViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: .ecommerce,
            tab: nil,  // Opens in current tab
            path: "/products/:id/reviews"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        guard let id = parameters["id"], let productId = Int(id) else {
            return nil
        }
        let product = Product.mockList.first { $0.id == productId } ?? Product.mock
        return .productReviews(product)
    }

    static func extractParameters(from route: Route) -> [String: String] {
        if case .productReviews(let product) = route {
            return ["id": "\(product.id)"]
        }
        return [:]
    }

    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        // ... create and return view
    }
}
```

2. **Build project** → Route, map entry, and identifier automatically generated!

3. Use anywhere:
```swift
// Internal navigation (stays on current tab)
coordinator.navigate(to: "https://myapp.com/products/123/reviews")

// From deeplink with specific tab
coordinator.navigate(to: "myapp://products/123/reviews?tab=products")
```

**That's it!** No URLRouter changes, no manual registration, no enum updates, no canHandle needed.

---

## Coordinator Pattern

### AppCoordinator

Manages navigation for all activities:

```swift
@MainActor
class AppCoordinator: ObservableObject, Coordinator {
    @Published var currentActivity: Activity = .ecommerce
    @Published var currentTab: Tab = .home
    @Published private(set) var paths: [Tab: NavigationPath] = [:]

    // Navigate via URL
    func navigate(to url: URL) {
        guard let (activity, tab, route) = urlRouter.route(from: url) else {
            return
        }

        // Switch activity if different
        if activity != currentActivity {
            currentActivity = activity
        }

        // Switch tab if different
        if tab != currentTab && tab.activity == currentActivity {
            currentTab = tab
        }

        // Navigate to route
        navigate(to: route)
    }

    // Switch activity manually
    func switchActivity(to activity: Activity) {
        currentActivity = activity
        currentTab = activity.defaultTab
    }
}
```

**Key Features:**
- Manages current activity and tab
- Handles URL-based navigation
- Preserves navigation stacks per tab
- Automatic activity/tab switching
- Builds views dynamically via Routable types

### URLRouter

Parses URLs and maps to routes:

```swift
class URLRouter {
    func route(from url: URL) -> (activity: Activity, tab: Tab, route: Route)? {
        // Extract path from URL
        // Match against ViewModel path patterns
        // Extract parameters
        // Return activity, tab, and route
    }

    func url(for route: Route) -> URL? {
        // Reverse: Convert route to URL
        // Find ViewModel, get path, replace parameters
    }
}
```

---

## Dependency Injection

### DIContainer

Simple container for managing dependencies:

```swift
class DIContainer {
    static let shared = DIContainer()

    private(set) lazy var networkService = NetworkService()
    private(set) lazy var productRepository: ProductRepositoryProtocol =
        ProductRepository(networkService: networkService)

    private weak var coordinator: AppCoordinator?

    func setCoordinator(_ coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
}
```

**Initialization Flow:**
1. App launches → Create DIContainer
2. Create AppCoordinator with container
3. ViewModels receive dependencies via coordinator

---

## Data Flow Examples

### Example 1: Loading Products

```
1. User opens Products tab
   ↓
2. ProductListView appears
   ↓
3. ViewModel.loadProducts() called
   ↓
4. Repository.fetchProducts()
   ↓
5. NetworkService makes API call
   ↓
6. Data flows back: Network → Repository → ViewModel
   ↓
7. ViewModel updates @Published property
   ↓
8. SwiftUI automatically updates view
```

### Example 2: URL Navigation

```
1. User taps product
   ↓
2. ViewModel calls: coordinator.navigate(to: "https://myapp.com/products/123")
   ↓
3. URLRouter parses URL:
   - Path: /products/123
   - Matches: ProductDetailViewModel
   - Extracts: id = 123
   - Returns: (ecommerce, products, .productDetail(Product))
   ↓
4. AppCoordinator:
   - Activity already ecommerce ✓
   - Tab already products ✓
   - Push ProductDetailView
   ↓
5. ProductDetailView appears with product data
```

### Example 3: Activity Switch via URL

```
1. User receives notification: "https://myapp.com/brochures"
2. Currently on: E-commerce Home tab
   ↓
3. URLRouter returns: (brochure, brochures, .brochures)
   ↓
4. AppCoordinator:
   - Activity ecommerce ≠ brochure → Switch activity
   - Tab home ≠ brochures → Switch tab
   - Navigate to .brochures
   ↓
5. UI updates:
   - Shows Brochure activity
   - Shows Brochures tab
   - BrochuresView displayed
   - E-commerce state preserved
```

---

## Testing Strategy

### ViewModel Tests
```swift
func testProductSelection() {
    let mockCoordinator = MockCoordinator()
    let mockRepository = MockProductRepository()
    let viewModel = ProductListViewModel(
        productRepository: mockRepository,
        coordinator: mockCoordinator
    )

    viewModel.didSelectProduct(Product.mock)

    XCTAssertTrue(mockCoordinator.navigatedToProduct)
}
```

### Repository Tests
```swift
func testFetchProducts() async throws {
    let mockNetworkService = MockNetworkService()
    let repository = ProductRepository(networkService: mockNetworkService)

    let products = try await repository.fetchProducts()

    XCTAssertEqual(products.count, 5)
}
```

### URL Routing Tests
```swift
func testURLParsing() {
    let router = URLRouter()
    let url = URL(string: "https://myapp.com/products/123?tab=products")!

    let result = router.route(from: url)

    XCTAssertEqual(result?.activity, .ecommerce)
    XCTAssertEqual(result?.tab, .products)
}
```

---

## Deeplinks, Universal Links & Notifications

### URL Schemes

The app supports both custom schemes and universal links:

**Custom Scheme:** `myapp://`
- Configure in Xcode: Target → Info → URL Types
- Example: `myapp://products/1?tab=products`

**Universal Links:** `https://myapp.com`
- Configure in Xcode: Target → Signing & Capabilities → Associated Domains
- Requires server setup with `apple-app-site-association` file
- Example: `https://myapp.com/products/1?tab=products`

### Tab Query Parameter

URLs can include an optional `?tab=` query parameter to specify which tab to open:

```
myapp://products/1              → Opens in current tab
myapp://products/1?tab=products → Switches to Products tab
myapp://brochures/1?tab=brochures → Switches to Brochures tab
```

**Tab values:** `home`, `products`, `favorites`, `brochures`

### Notification Example

Push notification payload with deeplink:

```json
{
  "aps": {
    "alert": {
      "title": "New Product Available",
      "body": "Check out the latest product!"
    }
  },
  "url": "myapp://products/123?tab=products"
}
```

Handle notification:
```swift
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
) {
    let userInfo = response.notification.request.content.userInfo
    if let urlString = userInfo["url"] as? String,
       let url = URL(string: urlString) {
        coordinator.navigate(to: url)
    }
    completionHandler()
}
```

### Testing Deeplinks

**In Simulator:**
```bash
xcrun simctl openurl booted "myapp://products/1?tab=products"
```

**In Safari:**
Type `myapp://products/1?tab=products` in address bar

**From Code:**
```swift
coordinator.navigate(to: "myapp://products/1?tab=products")
```

---

## Key Principles

1. **URL-Driven Navigation**: Single API for all navigation sources
2. **ViewModel-Driven Routing**: ViewModels define their own routes
3. **Activity Isolation**: Clean separation of app contexts
4. **Auto-Generation**: Build-time code generation eliminates boilerplate
5. **Separation of Concerns**: Each layer has a single responsibility
6. **Dependency Inversion**: Depend on abstractions (protocols)
7. **Testability**: All components can be tested in isolation
8. **Scalability**: Easy to add new features/activities/routes

---

## Current Implementation

### Activities
- **E-commerce**: Home, Products, Favorites tabs
- **Brochure**: Brochures tab

### Routes (9 total)
- Home (`/home`)
- Product List (`/products`)
- Product Detail (`/products/:id`)
- Favorites (`/favorites`)
- Saved (`/saved`)
- Orders (`/orders`)
- Reviews (`/reviews`)
- Brochures (`/brochures`)
- Brochure Detail (`/brochures/:id`)

### Features
- ✅ URL-based navigation (internal + external)
- ✅ Activity switching (manual + automatic)
- ✅ Deep linking support (custom scheme + universal links)
- ✅ Auto-generated routing with O(1) lookup map
- ✅ Multi-tab navigation with optional tab parameter
- ✅ State preservation per tab
- ✅ Pattern matching with parameters
- ✅ Activity switcher UI component
- ✅ Query parameter tab switching (`?tab=products`)
- ✅ Notification deeplink handling

---

## Build Configuration

### Xcode Build Phase
**Name**: "Generate Routable Files"
**Script**: `bash "${SRCROOT}/Scripts/generate_routable_files.sh"`
**Runs**: Before "Compile Sources"
**Output Files**:
- `${SRCROOT}/Ios-MVVM/Presentation/Coordinator/Route.swift`
- `${SRCROOT}/Ios-MVVM/Presentation/Coordinator/RoutableTypes.swift`

### Requirements
- `ENABLE_USER_SCRIPT_SANDBOXING = NO` (required for file system access)
- Both output files in `.gitignore`

---

## Future Enhancements

Potential extensions:
- **Authentication**: Auth flow with saved deep links
- **Analytics**: Track navigation events
- **Error Handling**: Unified error presentation
- **Caching**: Route-based data caching
- **Animations**: Custom transitions per route
- **Query Parameters**: Support for URL query strings
- **Activity History**: Back button across activities
- **Dynamic Activities**: Load activities from server config

---

## When to Use This Architecture

**Best for:**
- Medium to large apps
- Apps with multiple contexts/modes
- Apps requiring deep linking
- Multi-tenant applications
- Apps with complex navigation
- Team projects
- Long-term maintained projects

**Overkill for:**
- Simple 2-3 screen apps
- Quick prototypes
- Proof of concepts
- Single-purpose utilities

---

## Conclusion

This architecture provides a production-ready foundation for scalable iOS apps. The combination of Activities, URL-based navigation, and auto-generated routing creates a flexible system that grows with your app's complexity while remaining maintainable and testable.

**Key Innovation**: ViewModels define their own routing, and the system automatically discovers and registers them at build time. Adding new features is as simple as creating a new ViewModel with a RouteConfig—everything else is handled automatically.
