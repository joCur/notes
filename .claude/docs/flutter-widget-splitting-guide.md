# Flutter Widget Splitting Guide

A simple decision framework for structuring screens and widgets in Flutter.

## Quick Decision Tree

When building any screen or widget, ask yourself these questions in order:

### 1. Is this more than 50 lines of code?
- **YES** → Split it into smaller widgets
- **NO** → Continue to question 2

### 2. Does it represent a logical UI component?
Examples: a card, a header, a list item, a form section
- **YES** → Split it into a separate widget
- **NO** → Continue to question 3

### 3. Is this code repeated or could it use `const`?
- **YES** → Split it into a separate widget
- **NO** → Keep it inline in the current build method

### 4. Will this widget be used in multiple places?
- **YES** → Create a **public widget** in a separate file
- **NO** → Create a **private widget** (prefixed with `_`) in the same file

## The Golden Rules

### Rule 1: Always Use Widget Classes, Never Methods
```dart
// ❌ WRONG - Don't do this
Widget _buildHeader() {
  return Container(...);
}

// ✅ CORRECT - Do this instead
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(...);
  }
}
```

**Why?** Methods rebuild every time, widgets can be optimized by Flutter.

### Rule 2: Use `const` Everywhere Possible
```dart
// ✅ Good - Flutter can cache these
const SizedBox(height: 16),
const Icon(Icons.home),
const Text('Title'),
const Padding(padding: EdgeInsets.all(8.0)),

// Use const for entire widgets when possible
const ProductHeader(), // Widget won't rebuild unnecessarily
```

**Why?** Can improve performance by 30-60% in complex screens.

### Rule 3: Split Based on Responsibility, Not Just Reuse
Even if you only use a widget once, split it if it has a clear, distinct purpose.

```dart
// A screen with clear sections
class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _AppBar(),           // Split - logical component
      body: Column(
        children: [
          const _Header(),               // Split - distinct section
          const _FilterBar(),            // Split - separate responsibility
          Expanded(child: _ProductGrid()), // Split - complex component
        ],
      ),
    );
  }
}
```

## When to Keep Widgets in the Same File

Use **private widgets** (prefix with `_`) in the same file when:

1. The widget is only used by one parent widget
2. The widget is an implementation detail
3. The widget is relatively simple (< 100 lines)
4. The widget is tightly coupled to its parent

```dart
// product_card.dart
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _ProductImage(imageUrl: product.imageUrl),    // Private - same file
          _ProductInfo(product: product),                // Private - same file
          _AddToCartButton(productId: product.id),       // Private - same file
        ],
      ),
    );
  }
}

// Private widgets below in same file
class _ProductImage extends StatelessWidget {
  final String imageUrl;
  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Image.network(imageUrl, height: 200);
  }
}

class _ProductInfo extends StatelessWidget {
  final Product product;
  const _ProductInfo({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(product.name),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final String productId;
  const _AddToCartButton({required this.productId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _addToCart(productId),
      child: const Text('Add to Cart'),
    );
  }

  void _addToCart(String id) {
    // Implementation
  }
}
```

## When to Create Separate Files

Create a **public widget** in a separate file when:

1. The widget is used in 2+ different screens/widgets
2. The widget is complex (> 100 lines)
3. The widget is part of a shared component library
4. The widget needs its own test file

```dart
// lib/widgets/custom_button.dart
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
```

## Practical Example: Building a Profile Screen

Let's build a profile screen step by step:

```dart
// 1. Start with the screen structure
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // This section is getting long...
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(radius: 50),
                  const SizedBox(height: 8),
                  Text('John Doe', style: TextStyle(fontSize: 24)),
                  Text('john@example.com'),
                ],
              ),
            ),
            // More sections...
          ],
        ),
      ),
    );
  }
}

// 2. Split into logical components (private widgets in same file)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            _ProfileHeader(),    // Split - clear section
            _ProfileStats(),     // Split - separate responsibility
            _ProfileSettings(),  // Split - distinct component
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        children: [
          CircleAvatar(radius: 50),
          SizedBox(height: 8),
          Text('John Doe', style: TextStyle(fontSize: 24)),
          Text('john@example.com'),
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatCard(label: 'Posts', value: '42'),
        _StatCard(label: 'Followers', value: '1.2K'),
        _StatCard(label: 'Following', value: '234'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}

class _ProfileSettings extends StatelessWidget {
  const _ProfileSettings();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {},
        ),
        // More settings...
      ],
    );
  }
}
```

## Red Flags: When You're Doing It Wrong

### 🚩 Your build() method is 100+ lines
**Fix:** Split into smaller widget classes

### 🚩 You're using methods that return widgets
```dart
Widget _buildSomething() { ... } // ❌ Wrong
```
**Fix:** Convert to StatelessWidget classes

### 🚩 You're not using `const` on static widgets
```dart
Text('Hello')              // ❌ Missing const
const Text('Hello')        // ✅ Correct
```

### 🚩 You're passing 6+ parameters to a widget
**Fix:** This widget might be doing too much. Consider:
- Creating a data class to group parameters
- Splitting the widget further
- Using inherited widgets or state management

### 🚩 Every widget is in its own file
**Fix:** Use private widgets in the same file for implementation details

## Performance Tips

1. **Use `const` constructors everywhere possible** → 30-60% faster rebuilds
2. **Split frequently rebuilding sections** → Isolate what needs to update
3. **Make static UI elements `const`** → Flutter will reuse them
4. **Keep widgets focused** → Easier for Flutter to optimize

## Summary Checklist

When building any screen or widget:

- [ ] Is my build() method under 100 lines?
- [ ] Have I split logical sections into separate widgets?
- [ ] Am I using widget classes instead of methods?
- [ ] Have I used `const` on all static elements?
- [ ] Are implementation details marked as private (`_WidgetName`)?
- [ ] Are reusable components in separate files?
- [ ] Can Flutter optimize my widget tree effectively?

## Quick Reference

| Scenario | What to Do |
|----------|------------|
| Static UI element | Use `const` |
| Screen section (header, footer, etc.) | Private widget in same file |
| Reusable component (button, card, etc.) | Public widget in separate file |
| Build method > 50 lines | Split into smaller widgets |
| Implementation detail | Private widget (`_Name`) |
| Used in multiple places | Public widget in separate file |
| State class | Private class in same file |

---

**Remember:** Flutter is designed for deeply nested widget trees. Don't be afraid to split things up—it's the Flutter way!
