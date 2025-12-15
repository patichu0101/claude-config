# PROJECT MEMORY

## Project Overview

**Project Name:** {{PROJECT_NAME}}
**Framework:** {{FRAMEWORK}} {{FRAMEWORK_VERSION}}
**Router Type:** {{ROUTER_TYPE}} Router
**Generated:** {{GENERATED_DATE}}

Full-stack React framework with file-based routing, API routes, and built-in SSR/SSG.

---

## Tech Stack

### Frontend
- **Framework**: {{FRAMEWORK}} {{FRAMEWORK_VERSION}}
- **Router**: {{ROUTER_TYPE}} Router (file-based routing)
- **UI**: React Server Components + Client Components
- **Styling**: Tailwind CSS (app/globals.css)
- **Language**: TypeScript (strict mode)

### Backend
- **API**: Next.js API routes and Server Actions
- **Database**: [Specify: Prisma, Drizzle, TypeORM, etc.]
- **Authentication**: [Specify: NextAuth, Clerk, Auth0, etc.]

### Development
- **Package Manager**: {{PACKAGE_MANAGER}}
- **Testing**: {{TEST_FRAMEWORK}}
- **Linting**: ESLint + Prettier
- **Type Checking**: TypeScript strict mode

### Key Dependencies
{{DEPENDENCIES_LIST}}

---

## Folder Structure ({{ROUTER_TYPE}} Router)

```
{{PROJECT_PATH}}/
├── app/
│   ├── api/                    # API routes
│   │   ├── auth/route.ts      # Authentication endpoints
│   │   └── [resource]/route.ts # RESTful endpoints
│   ├── dashboard/              # Route group
│   │   ├── page.tsx           # Route page component
│   │   └── layout.tsx         # Shared layout
│   ├── layout.tsx              # Root layout
│   ├── page.tsx                # Home page
│   └── globals.css             # Global styles
├── components/
│   ├── ui/                     # Reusable UI components
│   └── forms/                  # Form components
├── lib/
│   ├── db.ts                   # Database client
│   ├── auth.ts                 # Auth utilities
│   └── api.ts                  # API client
├── types/
│   └── index.ts                # TypeScript types
├── public/                     # Static assets
├── next.config.js              # Next.js configuration
└── package.json
```

---

## Coding Preferences

### Component Architecture
- **Functional components only** (no class components)
- **Server Components by default** (no 'use client' unless needed)
- **Client boundary**: Mark interactive components with 'use client' at top
- **Colocation**: Keep components close to where they're used

### Server vs Client Components

**Server Components (default):**
```tsx
// app/components/Button.tsx
export function Button({ children }: { children: React.ReactNode }) {
  return <button className="btn">{children}</button>;
}
```

**Client Components (interactive):**
```tsx
// app/components/Counter.tsx
'use client';
import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);
  return (
    <button onClick={() => setCount(count + 1)}>
      Count: {count}
    </button>
  );
}
```

### API Routes Pattern

**Route Handlers (app/api):**
```tsx
// app/api/posts/route.ts
import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  try {
    const posts = await db.post.findMany();
    return NextResponse.json(posts);
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch posts' }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const data = await request.json();
    const post = await db.post.create({ data });
    return NextResponse.json(post, { status: 201 });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to create post' }, { status: 500 });
  }
}
```

### Layouts & Routing
- **Shared layouts**: layout.tsx at each route segment
- **Nested routes**: Use folder structure (app/blog/[slug]/page.tsx)
- **Dynamic routes**: [slug] for single param, [...slug] for catch-all
- **Route groups**: (auth) folders for organization without affecting URL

### Code Style
- **Named exports** over default exports
- **Explicit return types** for exported functions
- **camelCase** for variables/functions, **PascalCase** for components
- **Avoid `any`**: Use proper TypeScript types
- **Async/await** over promises with .then()

---

## Common Commands

### Development
```bash
{{PACKAGE_MANAGER}} run dev         # Start dev server (localhost:3000)
{{PACKAGE_MANAGER}} run build       # Build for production
{{PACKAGE_MANAGER}} run start       # Start production server
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
npx tsc --noEmit app/page.tsx

# Format single file
npx prettier --write app/page.tsx

# Lint single file
npx eslint --fix app/page.tsx

# Test single file
{{PACKAGE_MANAGER}} run test --testPathPattern=page.test.tsx
```

---

## Database Integration

- **Migrations**: Always run migrations before deploying
- **Seed data**: Use seed script for local development
- **Type safety**: Generate TypeScript types from database schema
- **Connection pooling**: Configure connection pool for production
- **Environment variables**: Store database credentials in .env.local (never commit)

---

## Important Quirks & Gotchas

### Next.js Specific
- **Trailing slashes**: Configure `trailingSlash` in next.config.js
- **Image optimization**: Always use `next/image` instead of `<img>`
- **Font loading**: Use `next/font` for web fonts (better performance)
- **CORS**: Not needed for same-origin API routes
- **Environment variables**: Use `NEXT_PUBLIC_` prefix for client-side vars

### Build Cache
- **Clear cache**: Delete `.next` folder if seeing stale behavior
- **Incremental builds**: Next.js caches between builds for speed

### Server Actions
- **'use server'** directive required for Server Actions
- **Only in Server Components**: Client Components cannot define Server Actions
- **Form actions**: Use Server Actions for form submissions (no API route needed)

---

## When Stuck

1. **Check middleware chain** - Verify middleware.ts is configured correctly
2. **Environment variables** - Ensure all required env vars are set in .env.local
3. **Clear build cache** - Delete `.next` folder and rebuild
4. **Check router type** - Confirm you're using {{ROUTER_TYPE}} Router patterns
5. **Review Server/Client boundaries** - Ensure 'use client' is only where needed
6. **Open draft PR** - Share your approach for feedback

---

## Additional Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [App Router Migration Guide](https://nextjs.org/docs/app/building-your-application/upgrading/app-router-migration)
- [Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components)
- [API Routes](https://nextjs.org/docs/app/building-your-application/routing/route-handlers)

---

*Auto-generated by CLAUDE.md Auto-Init System on {{GENERATED_DATE}}*
