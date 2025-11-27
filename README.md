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

## Key Innovation: Declarative Routing

**The entire routing infrastructure is auto-generated from ViewModels.** Just create a ViewModel with a `RouteConfig` and the build system automatically generates:

✨ **Activities** - Discovered from ViewModels
✨ **Tabs** - With icons and ordering from `TabConfig`
✨ **Routes** - All enum cases with parameters
✨ **Mappings** - ViewModel lookup tables for O(1) routing

**Example:** Add a new tab by creating a ViewModel:
```swift
extension SettingsViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: .ecommerce,
            tab: TabConfig(identifier: "settings", icon: "gear", index: 4),
            path: "/settings"
        )
    }
    // ... protocol methods
}
```

**Build** → Tab appears in UI, routing works, deeplinks supported. **Zero manual updates.**

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

## URL-Based Navigation & Auto-Generated Routing

### Core Concept

**Everything is declarative and auto-generated**. The routing system is entirely driven by ViewModels:

- ✅ Activities auto-generated from ViewModels
- ✅ Tabs auto-generated with icons and ordering
- ✅ Routes auto-generated with parameter support
- ✅ All navigation mappings generated at build time

**Zero manual maintenance** - just create a ViewModel and View, the rest is automatic.

### How It Works

1. **ViewModels declare routing via RouteConfig**
2. **Build script scans all ViewModels**
3. **Auto-generates 4 files:**
   - `Route.swift` - All route cases
   - `RoutableTypes.swift` - ViewModel array + lookup map
   - `Activity.swift` - All activities with metadata
   - `Tab.swift` - All tabs with icons, titles, activity mapping

### RouteConfig & TabConfig

```swift
/// Tab configuration - defines a new tab in the tab bar
struct TabConfig {
    let identifier: String  // Tab enum case name: "home", "cart", etc.
    let icon: String        // SF Symbol: "house.fill", "cart.fill"
    let index: Int          // Tab bar position: 0, 1, 2, 3...
}

/// Route configuration - every ViewModel has one
struct RouteConfig {
    let activity: Activity      // Which activity (.ecommerce, .brochure)
    let tab: TabConfig?         // Tab config if this is a root view, nil for details
    let path: String            // URL path pattern: "/products/:id"
    let requiresAuth: Bool      // Authentication requirement
}
```

### ViewModel Examples

**Tab Root View** (creates a new tab):
```swift
extension HomeViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: .ecommerce,
            tab: TabConfig(identifier: "home", icon: "house.fill", index: 0),
            path: "/home"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        return .home
    }

    static func extractParameters(from route: Route) -> [String: String] {
        return [:]
    }

    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        let viewModel = HomeViewModel(coordinator: coordinator)
        return AnyView(HomeView(viewModel: viewModel))
    }
}
```

**Detail View** (no tab, opens in current context):
```swift
extension ProductDetailViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: .ecommerce,
            // No tab - opens in current tab
            path: "/products/:id"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        guard let id = parameters["id"], let productId = Int(id) else {
            return nil
        }
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
        return AnyView(Text("Invalid route").foregroundColor(.red))
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
   - Extracts tab query parameter: "products"
   - Matches path pattern: "/products/:id"
   - Extracts path parameters: ["id": "123"]
   - Calls ProductDetailViewModel.createRoute(["id": "123"])
   - Gets RouteConfig from ProductDetailViewModel
   ↓
   Returns: (activity: .ecommerce, tab: .products, route: .productDetail(Product))
   ↓
3. AppCoordinator
   - Switch activity if different
   - Switch tab if specified (from URL or config)
   - Lookup ViewModel using routableTypeMap[route.identifier]
   - Call ViewModel.createView(route, coordinator)
   ↓
4. View Displayed
```

### URL Pattern Matching

Supports dynamic parameters with type-safe extraction:
- `/home` → Exact match, no parameters
- `/products/:id` → Matches `/products/123`, extracts `id=123`
- `/brochures/:id` → Matches `/brochures/5`, extracts `id=5`
- Multiple parameters: `/users/:userId/orders/:orderId`

### Tab Switching via URL

URLs can include optional `?tab=` query parameter:
```
myapp://products/1              → Opens in current tab
myapp://products/1?tab=products → Switches to Products tab first
myapp://cart?tab=cart           → Switches to Cart tab
```

---

## Auto-Generated Files

### Build Script Intelligence

The build script (`Scripts/generate_routable_files.sh`) runs before each compilation and:

**Scans ViewModels:**
1. Finds all `*ViewModel.swift` files with `Routable` conformance
2. Extracts `activity` from RouteConfig
3. Extracts `TabConfig` (identifier, icon, index) if present
4. Extracts `path` pattern for URL matching
5. Generates route identifiers from ViewModel names

**Collects Metadata:**
- Unique activities across all ViewModels
- Unique tabs with their icons and indexes
- Tab-to-activity mappings
- Default tab for each activity (prefers "home", otherwise lowest index)
- Route-to-ViewModel mappings

**Generates 4 Files:**

### 1. Route.swift

All route cases with associated values:

```swift
// 🤖 AUTO-GENERATED - DO NOT EDIT
enum Route: Hashable {
    case home
    case productList
    case productDetail(Product)
    case favorites
    case cart
    case saved
    case orders
    case reviews
    case brochures
    case brochureDetail(Brochure)

    var identifier: String {
        Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }
}
```

### 2. RoutableTypes.swift

ViewModel array for iteration + O(1) lookup map:

```swift
// 🤖 AUTO-GENERATED - DO NOT EDIT
let routableTypes: [any Routable.Type] = [
    HomeViewModel.self,
    ProductListViewModel.self,
    ProductDetailViewModel.self,
    FavoritesViewModel.self,
    CartViewModel.self,
    SavedViewModel.self,
    OrdersViewModel.self,
    ReviewsViewModel.self,
    BrochuresViewModel.self,
    BrochureDetailViewModel.self
]

// O(1) route identifier to ViewModel lookup
let routableTypeMap: [String: any Routable.Type] = [
    "home": HomeViewModel.self,
    "productList": ProductListViewModel.self,
    "productDetail": ProductDetailViewModel.self,
    "favorites": FavoritesViewModel.self,
    "cart": CartViewModel.self,
    "saved": SavedViewModel.self,
    "orders": OrdersViewModel.self,
    "reviews": ReviewsViewModel.self,
    "brochures": BrochuresViewModel.self,
    "brochureDetail": BrochureDetailViewModel.self
]
```

### 3. Activity.swift

All activities with display names and default tabs:

```swift
// 🤖 AUTO-GENERATED - DO NOT EDIT
enum Activity: String, Codable, CaseIterable {
    case ecommerce
    case brochure

    var displayName: String {
        switch self {
        case .ecommerce:
            return "Ecommerce"
        case .brochure:
            return "Brochure"
        }
    }

    var defaultTab: Tab {
        switch self {
        case .ecommerce:
            return .home
        case .brochure:
            return .brochures
        }
    }
}
```

### 4. Tab.swift

All tabs with icons, titles, activity mapping, and root routes:

```swift
// 🤖 AUTO-GENERATED - DO NOT EDIT
enum Tab: String, CaseIterable {
    case home
    case products
    case favorites
    case cart
    case brochures

    var title: String {
        switch self {
        case .home: return "Home"
        case .products: return "Products"
        case .favorites: return "Favorites"
        case .cart: return "Cart"
        case .brochures: return "Brochures"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .products: return "bag.fill"
        case .favorites: return "heart.fill"
        case .cart: return "cart.fill"
        case .brochures: return "book.fill"
        }
    }

    var activity: Activity {
        switch self {
        case .home: return .ecommerce
        case .products: return .ecommerce
        case .favorites: return .ecommerce
        case .cart: return .ecommerce
        case .brochures: return .brochure
        }
    }

    var rootRoute: Route {
        switch self {
        case .home: return .home
        case .products: return .productList
        case .favorites: return .favorites
        case .cart: return .cart
        case .brochures: return .brochures
        }
    }

    static func tabs(for activity: Activity) -> [Tab] {
        allCases.filter { $0.activity == activity }
    }
}
```

### Benefits

- ✅ **Zero manual maintenance** - just create ViewModels
- ✅ **Compile-time safety** - type-checked at build time
- ✅ **O(1) lookups** - instant route-to-ViewModel mapping
- ✅ **Clean git diffs** - generated files in `.gitignore`
- ✅ **No boilerplate** - no switch statements, registrations, or manual enums
- ✅ **Tab ordering** - controlled by index in TabConfig
- ✅ **Activity detection** - automatically discovered from ViewModels

### Adding New Features

**Example 1: Add a New Tab (Settings)**

1. Create `SettingsViewModel.swift`:
```swift
extension SettingsViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: .ecommerce,
            tab: TabConfig(identifier: "settings", icon: "gear", index: 4),
            path: "/settings"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        return .settings
    }

    static func extractParameters(from route: Route) -> [String: String] {
        return [:]
    }

    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        let viewModel = SettingsViewModel(coordinator: coordinator)
        return AnyView(SettingsView(viewModel: viewModel))
    }
}
```

2. Create `SettingsView.swift`:
```swift
struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        Text("Settings")
            .navigationTitle("Settings")
    }
}
```

3. **Build project** → Everything auto-generated:
   - ✅ `.settings` route case added to Route enum
   - ✅ `.settings` tab case added to Tab enum
   - ✅ SettingsViewModel added to routableTypes array
   - ✅ "settings" → SettingsViewModel mapping added to routableTypeMap
   - ✅ Tab appears in tab bar at index 4
   - ✅ Icon "gear" automatically used

4. Use anywhere:
```swift
coordinator.navigate(to: "myapp://settings?tab=settings")
```

**Example 2: Add a Detail View (Order Detail)**

1. Create `OrderDetailViewModel.swift`:
```swift
extension OrderDetailViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: .ecommerce,
            // No tab - opens in current tab
            path: "/orders/:id"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        guard let id = parameters["id"], let orderId = Int(id) else {
            return nil
        }
        let order = Order.mockOrders.first { $0.id == orderId } ?? Order.mock
        return .orderDetail(order)
    }

    static func extractParameters(from route: Route) -> [String: String] {
        if case .orderDetail(let order) = route {
            return ["id": "\(order.id)"]
        }
        return [:]
    }

    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        if case .orderDetail(let order) = route {
            let viewModel = OrderDetailViewModel(order: order, coordinator: coordinator)
            return AnyView(OrderDetailView(viewModel: viewModel))
        }
        return AnyView(Text("Invalid route").foregroundColor(.red))
    }
}
```

2. Create `OrderDetailView.swift`

3. **Build project** → `.orderDetail(Order)` route added, no tab created

4. Navigate from OrdersView:
```swift
viewModel.didSelectOrder(order)
// Inside ViewModel:
coordinator?.navigate(to: "https://myapp.com/orders/\(order.id)")
```

**That's it!** No manual updates to:
- ❌ Activity enum
- ❌ Tab enum (unless you want a tab)
- ❌ Route enum
- ❌ URLRouter
- ❌ Any registration or mapping code

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
    let url = URL(string: "https://myapp.com/products/123")!

    let result = router.route(from: url)

    XCTAssertEqual(result?.activity, .ecommerce)
    XCTAssertEqual(result?.tab, .products)
}
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

### Activities (Auto-Generated)
- **Ecommerce**: 4 tabs (Home, Products, Favorites, Cart)
- **Brochure**: 1 tab (Brochures)

### Tabs (Auto-Generated)
- **Home** - Index 0, Icon: house.fill (Ecommerce)
- **Products** - Index 1, Icon: bag.fill (Ecommerce)
- **Favorites** - Index 2, Icon: heart.fill (Ecommerce)
- **Cart** - Index 3, Icon: cart.fill (Ecommerce)
- **Brochures** - Index 0, Icon: book.fill (Brochure)

### Routes (10 total, Auto-Generated)
- Home (`/home`)
- Product List (`/products`)
- Product Detail (`/products/:id`) - with parameter
- Favorites (`/favorites`)
- Cart (`/cart`)
- Saved (`/saved`)
- Orders (`/orders`)
- Reviews (`/reviews`)
- Brochures (`/brochures`)
- Brochure Detail (`/brochures/:id`) - with parameter

### Features
- ✅ **Fully auto-generated routing** - Activities, Tabs, Routes, Mappings
- ✅ **Declarative configuration** - TabConfig defines everything
- ✅ **URL-based navigation** - Internal & external (deeplinks, notifications)
- ✅ **Activity switching** - Manual via UI + automatic via URL
- ✅ **Deep linking support** - Custom scheme (`myapp://`) + Universal links
- ✅ **Tab query parameters** - `?tab=products` for explicit tab switching
- ✅ **Multi-tab navigation** - Independent navigation stacks per tab
- ✅ **State preservation** - Navigation state maintained per tab
- ✅ **Pattern matching** - Dynamic URL parameters (`:id`, `:userId`, etc.)
- ✅ **Activity switcher** - UI component for switching between activities
- ✅ **O(1) route lookup** - Fast ViewModel resolution via map
- ✅ **Zero boilerplate** - No manual enums, registrations, or switch statements

---

## Build Configuration

### Xcode Build Phase
**Name**: "Generate Routable Files"
**Script**: `bash "${SRCROOT}/Scripts/generate_routable_files.sh"`
**Runs**: Before "Compile Sources"
**Output Files** (Auto-Generated):
- `${SRCROOT}/Ios-MVVM/Presentation/Coordinator/Route.swift`
- `${SRCROOT}/Ios-MVVM/Presentation/Coordinator/RoutableTypes.swift`
- `${SRCROOT}/Ios-MVVM/Presentation/Coordinator/Activity.swift`
- `${SRCROOT}/Ios-MVVM/Presentation/Coordinator/Tab.swift`

### Requirements
- `ENABLE_USER_SCRIPT_SANDBOXING = NO` (required for file system access)

### .gitignore
Generated files should be in `.gitignore`:
```
# Auto-generated routing files
Ios-MVVM/Presentation/Coordinator/Route.swift
Ios-MVVM/Presentation/Coordinator/RoutableTypes.swift
Ios-MVVM/Presentation/Coordinator/Activity.swift
Ios-MVVM/Presentation/Coordinator/Tab.swift
```

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
