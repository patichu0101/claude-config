# Next.js Example

This example shows the generated `CLAUDE.md` file for a **Next.js 14+ App Router** project.

## What Was Detected

**Framework Detection:**
- Framework: Next.js 14.2.5
- Router: App Router (detected from app/ directory)
- Package Manager: npm
- Test Framework: jest
- Confidence: 95%

**See:** `project-info.json` for full detection results

## Generated Content

The `CLAUDE.md` file includes:

✅ **Server Components Patterns** - Async data fetching, caching strategies
✅ **Client Components** - 'use client' directive, state management
✅ **Route Handlers** - API route patterns (GET, POST, etc.)
✅ **File Structure** - App Router directory organization
✅ **Common Tasks** - Dev server, build, test commands
✅ **Dependencies** - Top 10 project dependencies

## How This Was Generated

```powershell
# 1. Navigate to Next.js project
cd C:\Projects\nextjs-example

# 2. Run auto-init
/init-claude

# 3. Scanner detects:
#    - package.json with "next": "14.2.5"
#    - app/ directory (App Router indicator)
#    - __tests__/ directory (jest tests)

# 4. Selector chooses nextjs.template.md

# 5. Generator replaces placeholders:
#    {{PROJECT_NAME}} → "nextjs-example"
#    {{FRAMEWORK_VERSION}} → "14.2.5"
#    {{ROUTER_TYPE}} → "App Router"
#    etc.

# 6. Conditional sections included:
#    {{#IF SERVER_COMPONENTS}} → true (App Router detected)
#    {{#IF API_ROUTES}} → true (app/api/ detected)

# 7. Result: CLAUDE.md file created
```

## Using This Example

This is a **reference example** showing what gets generated. To try it yourself:

1. Create a Next.js 14+ project
2. Install the auto-init system
3. Run `/init-claude`
4. Compare your result with this example

---

**Template Used:** `nextjs.template.md`
**Detection Confidence:** 95%
