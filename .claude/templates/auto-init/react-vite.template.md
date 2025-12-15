# PROJECT MEMORY

## Project Overview

**Project Name:** {{PROJECT_NAME}}
**Framework:** {{FRAMEWORK}} {{FRAMEWORK_VERSION}}
**Build Tool:** Vite
**Generated:** {{GENERATED_DATE}}

Modern React SPA with TypeScript, Vite bundler, and component-driven development.

---

## Tech Stack

### Frontend
- **Framework**: React {{FRAMEWORK_VERSION}}
- **Build Tool**: Vite (fast HMR on port {{HMR_PORT}})
- **Language**: TypeScript (strict mode)
- **Styling**: Tailwind CSS / CSS Modules
- **State Management**: [Zustand / Redux / Context API]

### Development
- **Package Manager**: {{PACKAGE_MANAGER}}
- **Testing**: {{TEST_FRAMEWORK}} + React Testing Library
- **Linting**: ESLint + Prettier
- **Bundling**: Vite with fast refresh

### Key Dependencies
{{DEPENDENCIES_LIST}}

---

## Folder Structure

```
{{PROJECT_PATH}}/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.test.tsx
│   │   │   └── Button.module.css
│   │   └── ...
│   ├── pages/               # Page components
│   ├── hooks/               # Custom React hooks
│   ├── stores/              # State management (Zustand/Redux)
│   ├── services/            # API clients, utilities
│   ├── types/               # TypeScript interfaces
│   ├── styles/              # Global styles
│   ├── App.tsx              # Root component
│   └── main.tsx             # Entry point
├── public/                  # Static assets
├── vite.config.ts           # Vite configuration
├── tsconfig.json            # TypeScript configuration
└── package.json
```

---

## Coding Preferences

### Component Architecture
- **Functional components only** (no class components)
- **Hooks for state**: useState, useEffect, custom hooks
- **Named exports** for tree-shaking
- **Colocation**: Components with their styles and tests

### Component Pattern

```tsx
// src/components/Button/Button.tsx
interface ButtonProps {
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
  children: React.ReactNode;
}

export function Button({
  onClick,
  variant = 'primary',
  disabled = false,
  children
}: ButtonProps) {
  return (
    <button
      className={`btn btn-${variant}`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
```

### Custom Hooks Pattern

```tsx
// src/hooks/useFetch.ts
export function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(setData)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [url]);

  return { data, loading, error };
}
```

### Styling
- **Tailwind utility classes** preferred
- **CSS Modules** for component-scoped styles
- **Design tokens** instead of hardcoded colors
- **No !important** - refactor CSS instead

### Imports
- **Destructure imports**: `import { useState } from 'react'`
- **Group imports**: React → libraries → local
- **Absolute imports**: Use `@/` path alias from tsconfig

---

## Common Commands

### Development
```bash
{{PACKAGE_MANAGER}} run dev         # Start dev server (localhost:{{HMR_PORT}})
{{PACKAGE_MANAGER}} run build       # Build for production
{{PACKAGE_MANAGER}} run preview     # Preview production build
```

### Testing
```bash
{{PACKAGE_MANAGER}} run test        # Run all tests
{{PACKAGE_MANAGER}} run test:watch # Run tests in watch mode
{{PACKAGE_MANAGER}} run coverage    # Generate coverage report
```

### Code Quality
```bash
{{PACKAGE_MANAGER}} run lint        # Lint all files
{{PACKAGE_MANAGER}} run format      # Format with Prettier
{{PACKAGE_MANAGER}} run type-check  # TypeScript type checking
```

### File-Scoped Commands (PREFERRED)
```bash
# Type check single file
npx tsc --noEmit src/components/Button.tsx

# Format single file
npx prettier --write src/components/Button.tsx

# Lint single file
npx eslint --fix src/components/Button.tsx

# Test single file
{{PACKAGE_MANAGER}} run test src/components/Button.test.tsx
```

---

## Testing Guidelines

### Test Structure
```tsx
// src/components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { Button } from './Button';

describe('Button', () => {
  it('should render with children', () => {
    render(<Button onClick={() => {}}>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('should call onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click</Button>);

    fireEvent.click(screen.getByText('Click'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('should be disabled when disabled prop is true', () => {
    render(<Button onClick={() => {}} disabled>Disabled</Button>);
    expect(screen.getByText('Disabled')).toBeDisabled();
  });
});
```

---

## Important Quirks & Gotchas

### Vite Specific
- **HMR Port**: Development server runs on port {{HMR_PORT}} by default
- **Environment Variables**: Use `import.meta.env.VITE_` prefix
- **Asset Imports**: Import assets directly: `import logo from './logo.svg'`
- **Path Aliases**: Configure in vite.config.ts and tsconfig.json

### React Best Practices
- **Keys in lists**: Always provide unique keys for list items
- **useEffect dependencies**: Include all dependencies in dependency array
- **Memoization**: Use `useMemo` and `useCallback` only when needed
- **State updates**: Use functional form for updates based on previous state

### Build Optimization
- **Code splitting**: Use `React.lazy()` and `Suspense` for route-based splitting
- **Tree shaking**: Named exports enable better tree shaking
- **Bundle analysis**: Run `npx vite-bundle-visualizer` to analyze bundle

---

## When Stuck

1. **Check console errors** - Browser DevTools console shows React errors
2. **Verify imports** - Ensure path aliases are configured in both vite.config.ts and tsconfig.json
3. **Clear Vite cache** - Delete `node_modules/.vite` folder
4. **Check HMR** - If hot reload breaks, restart dev server
5. **Review dependencies** - Ensure all peer dependencies are installed
6. **Open draft PR** - Share your approach for feedback

---

## Additional Resources

- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vitejs.dev/)
- [TypeScript React Cheatsheet](https://react-typescript-cheatsheet.netlify.app/)
- [Testing Library](https://testing-library.com/react)

---

*Auto-generated by CLAUDE.md Auto-Init System on {{GENERATED_DATE}}*
