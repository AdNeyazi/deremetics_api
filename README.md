# DERMATICS API (Rails)

JSON API for the DERMATICS Next.js frontend. See [../SETUP.md](../SETUP.md) for full monorepo setup.

```bash
bundle install
bin/rails db:prepare db:seed
JWT_SECRET=dev-secret-change-me FRONTEND_ORIGIN=http://localhost:3000 bin/rails server -p 3001
```

Health: `GET /up` · API root: `GET /api`
